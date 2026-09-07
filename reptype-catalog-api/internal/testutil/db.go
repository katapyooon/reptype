// Package testutil provides shared database setup helpers for tests that
// need a real Postgres instance (repository and handler integration tests).
package testutil

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"sort"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"

	"reptype-catalog-api/db"
)

// SetupTestDB connects to the test database (configured via the same DB_*
// environment variables as the application) and resets its schema by
// re-applying every migration in db/migrations from scratch.
func SetupTestDB(ctx context.Context) (*pgxpool.Pool, error) {
	pool, err := db.NewPool(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to test database: %w", err)
	}

	if err := resetSchema(ctx, pool); err != nil {
		pool.Close()
		return nil, err
	}

	return pool, nil
}

func resetSchema(ctx context.Context, pool *pgxpool.Pool) error {
	if _, err := pool.Exec(ctx, "DROP SCHEMA public CASCADE"); err != nil {
		return fmt.Errorf("failed to drop schema: %w", err)
	}
	if _, err := pool.Exec(ctx, "CREATE SCHEMA public"); err != nil {
		return fmt.Errorf("failed to create schema: %w", err)
	}

	migrationsDir, err := migrationsDir()
	if err != nil {
		return err
	}

	files, err := upMigrationFiles(migrationsDir)
	if err != nil {
		return err
	}

	for _, f := range files {
		if err := applyMigrationFile(ctx, pool, filepath.Join(migrationsDir, f)); err != nil {
			return err
		}
	}

	return nil
}

func migrationsDir() (string, error) {
	_, thisFile, _, ok := runtime.Caller(0)
	if !ok {
		return "", fmt.Errorf("failed to resolve testutil package location")
	}
	// this file lives at <module-root>/internal/testutil/db.go
	moduleRoot := filepath.Join(filepath.Dir(thisFile), "..", "..")
	return filepath.Join(moduleRoot, "db", "migrations"), nil
}

func upMigrationFiles(dir string) ([]string, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, fmt.Errorf("failed to read migrations dir: %w", err)
	}

	var files []string
	for _, e := range entries {
		if strings.HasSuffix(e.Name(), ".up.sql") {
			files = append(files, e.Name())
		}
	}
	sort.Strings(files)

	return files, nil
}

func applyMigrationFile(ctx context.Context, pool *pgxpool.Pool, path string) error {
	// #nosec G304 -- path is built from db/migrations, a fixed directory resolved
	// via runtime.Caller, not from external or user-controlled input.
	content, err := os.ReadFile(path)
	if err != nil {
		return fmt.Errorf("failed to read migration file %s: %w", path, err)
	}

	// pgx prepares statements individually, so a file containing several
	// semicolon-separated DDL statements must be split and applied one at a time.
	for _, stmt := range strings.Split(string(content), ";") {
		stmt = strings.TrimSpace(stmt)
		if stmt == "" {
			continue
		}
		if _, err := pool.Exec(ctx, stmt); err != nil {
			return fmt.Errorf("failed to apply statement from %s: %w", path, err)
		}
	}

	return nil
}
