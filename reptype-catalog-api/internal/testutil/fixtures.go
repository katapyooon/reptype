package testutil

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

// SeedFixtures inserts a small, deterministic dataset covering the cases
// tests care about: a morph with a gene that carries both a standalone risk
// and a homozygous combination risk (Enigma), and a morph with no linked
// gene at all (Tangerine, a polygenic/line-bred trait).
func SeedFixtures(ctx context.Context, pool *pgxpool.Pool) error {
	var speciesID int
	if err := pool.QueryRow(ctx, `
		INSERT INTO species (code) VALUES ('leopard_gecko') RETURNING id
	`).Scan(&speciesID); err != nil {
		return fmt.Errorf("failed to seed species: %w", err)
	}

	var enigmaGeneID int
	if err := pool.QueryRow(ctx, `
		INSERT INTO genes (species_id, code, name, inheritance_type, risk_category, risk_note, source_note)
		VALUES ($1, 'enigma', 'Enigma', 'dominant', 'neurological', 'risk note', 'source note')
		RETURNING id
	`, speciesID).Scan(&enigmaGeneID); err != nil {
		return fmt.Errorf("failed to seed enigma gene: %w", err)
	}

	var enigmaMorphID int
	if err := pool.QueryRow(ctx, `
		INSERT INTO morphs (species_id, code, name, description)
		VALUES ($1, 'enigma', 'Enigma', 'enigma description')
		RETURNING id
	`, speciesID).Scan(&enigmaMorphID); err != nil {
		return fmt.Errorf("failed to seed enigma morph: %w", err)
	}

	if _, err := pool.Exec(ctx, `
		INSERT INTO morph_genes (morph_id, gene_id) VALUES ($1, $2)
	`, enigmaMorphID, enigmaGeneID); err != nil {
		return fmt.Errorf("failed to link enigma morph to gene: %w", err)
	}

	if _, err := pool.Exec(ctx, `
		INSERT INTO gene_combination_risks (gene_a_id, gene_b_id, risk_category, severity, note, source_note)
		VALUES ($1, $1, 'lethal', 'avoid', 'combination risk note', 'combination source note')
	`, enigmaGeneID); err != nil {
		return fmt.Errorf("failed to seed gene_combination_risks: %w", err)
	}

	if _, err := pool.Exec(ctx, `
		INSERT INTO morphs (species_id, code, name, description)
		VALUES ($1, 'tangerine', 'Tangerine', 'tangerine description')
	`, speciesID); err != nil {
		return fmt.Errorf("failed to seed tangerine morph: %w", err)
	}

	// A second species with a morph reusing the same code as the leopard gecko's
	// Tangerine, to verify species-scoped queries don't leak across species.
	var otherSpeciesID int
	if err := pool.QueryRow(ctx, `
		INSERT INTO species (code) VALUES ('ball_python') RETURNING id
	`).Scan(&otherSpeciesID); err != nil {
		return fmt.Errorf("failed to seed ball_python species: %w", err)
	}

	if _, err := pool.Exec(ctx, `
		INSERT INTO morphs (species_id, code, name, description)
		VALUES ($1, 'tangerine', 'Ball Python Tangerine', 'other species tangerine description')
	`, otherSpeciesID); err != nil {
		return fmt.Errorf("failed to seed ball_python tangerine morph: %w", err)
	}

	return nil
}
