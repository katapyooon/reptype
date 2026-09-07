package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"reptype-catalog-api/model"
)

var ErrMorphNotFound = errors.New("morph not found")

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

func GetMorphDetail(ctx context.Context, pool *pgxpool.Pool, code string) (*model.MorphDetail, error) {
	var detail model.MorphDetail
	var morphID int
	var description *string

	err := pool.QueryRow(ctx, `
		SELECT id, code, name, description
		FROM morphs
		WHERE code = $1
	`, code).Scan(&morphID, &detail.Code, &detail.Name, &description)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrMorphNotFound
		}
		return nil, fmt.Errorf("failed to query morph: %w", err)
	}
	if description != nil {
		detail.Description = *description
	}

	geneIDs, err := geneIDsForMorph(ctx, pool, morphID)
	if err != nil {
		return nil, err
	}

	genes, err := genesByIDs(ctx, pool, geneIDs)
	if err != nil {
		return nil, err
	}
	detail.Genes = genes

	combinationRisks, err := combinationRisksForGenes(ctx, pool, geneIDs)
	if err != nil {
		return nil, err
	}
	detail.CombinationRisks = combinationRisks

	return &detail, nil
}

func geneIDsForMorph(ctx context.Context, pool *pgxpool.Pool, morphID int) ([]int, error) {
	rows, err := pool.Query(ctx, `
		SELECT gene_id FROM morph_genes WHERE morph_id = $1
	`, morphID)
	if err != nil {
		return nil, fmt.Errorf("failed to query morph_genes: %w", err)
	}
	defer rows.Close()

	geneIDs := []int{}
	for rows.Next() {
		var id int
		if err := rows.Scan(&id); err != nil {
			return nil, fmt.Errorf("failed to scan morph_genes: %w", err)
		}
		geneIDs = append(geneIDs, id)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate morph_genes: %w", err)
	}

	return geneIDs, nil
}

func genesByIDs(ctx context.Context, pool *pgxpool.Pool, geneIDs []int) ([]model.Gene, error) {
	genes := []model.Gene{}
	if len(geneIDs) == 0 {
		return genes, nil
	}

	rows, err := pool.Query(ctx, `
		SELECT code, name, inheritance_type, risk_category, risk_note, source_note
		FROM genes
		WHERE id = ANY($1)
		ORDER BY id
	`, geneIDs)
	if err != nil {
		return nil, fmt.Errorf("failed to query genes: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var g model.Gene
		if err := rows.Scan(&g.Code, &g.Name, &g.InheritanceType, &g.RiskCategory, &g.RiskNote, &g.SourceNote); err != nil {
			return nil, fmt.Errorf("failed to scan gene: %w", err)
		}
		genes = append(genes, g)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate genes: %w", err)
	}

	return genes, nil
}

func combinationRisksForGenes(ctx context.Context, pool *pgxpool.Pool, geneIDs []int) ([]model.CombinationRisk, error) {
	risks := []model.CombinationRisk{}
	if len(geneIDs) == 0 {
		return risks, nil
	}

	rows, err := pool.Query(ctx, `
		SELECT ga.code, gb.code, r.risk_category, r.severity, r.note, r.source_note
		FROM gene_combination_risks r
		JOIN genes ga ON ga.id = r.gene_a_id
		JOIN genes gb ON gb.id = r.gene_b_id
		WHERE r.gene_a_id = ANY($1) OR r.gene_b_id = ANY($1)
		ORDER BY r.id
	`, geneIDs)
	if err != nil {
		return nil, fmt.Errorf("failed to query gene_combination_risks: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var geneACode, geneBCode string
		var r model.CombinationRisk
		if err := rows.Scan(&geneACode, &geneBCode, &r.RiskCategory, &r.Severity, &r.Note, &r.SourceNote); err != nil {
			return nil, fmt.Errorf("failed to scan gene_combination_risk: %w", err)
		}
		r.GeneCodes = []string{geneACode, geneBCode}
		risks = append(risks, r)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate gene_combination_risks: %w", err)
	}

	return risks, nil
}
