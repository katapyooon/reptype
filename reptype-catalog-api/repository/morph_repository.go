package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"reptype-catalog-api/model"
)

func ListMorphs(ctx context.Context, pool *pgxpool.Pool) ([]model.Morph, error) {
	rows, err := pool.Query(ctx, `
		SELECT code, name, description
		FROM morphs
		ORDER BY id
	`)
	if err != nil {
		return nil, fmt.Errorf("failed to query morphs: %w", err)
	}
	defer rows.Close()

	morphs := []model.Morph{}
	for rows.Next() {
		var m model.Morph
		var description *string
		if err := rows.Scan(&m.Code, &m.Name, &description); err != nil {
			return nil, fmt.Errorf("failed to scan morph: %w", err)
		}
		if description != nil {
			m.Description = *description
		}
		morphs = append(morphs, m)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate morphs: %w", err)
	}

	return morphs, nil
}
