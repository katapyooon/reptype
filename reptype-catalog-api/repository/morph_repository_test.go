package repository_test

import (
	"context"
	"fmt"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"reptype-catalog-api/internal/testutil"
	"reptype-catalog-api/repository"
)

var testPool *pgxpool.Pool

func TestMain(m *testing.M) {
	ctx := context.Background()

	pool, err := testutil.SetupTestDB(ctx)
	if err != nil {
		fmt.Fprintln(os.Stderr, "failed to set up test database:", err)
		os.Exit(1)
	}
	if err := testutil.SeedFixtures(ctx, pool); err != nil {
		fmt.Fprintln(os.Stderr, "failed to seed fixtures:", err)
		os.Exit(1)
	}
	testPool = pool

	code := m.Run()
	pool.Close()
	os.Exit(code)
}

func TestListMorphs_AllSpecies(t *testing.T) {
	morphs, err := repository.ListMorphs(context.Background(), testPool, "")
	require.NoError(t, err)
	require.Len(t, morphs, 3)

	assert.Equal(t, "enigma", morphs[0].Code)
	assert.Equal(t, "Enigma", morphs[0].Name)
	assert.Equal(t, "tangerine", morphs[1].Code)
	assert.Equal(t, "Tangerine", morphs[1].Name)
	assert.Equal(t, "Ball Python Tangerine", morphs[2].Name)
}

func TestListMorphs_FilteredBySpecies(t *testing.T) {
	morphs, err := repository.ListMorphs(context.Background(), testPool, "leopard_gecko")
	require.NoError(t, err)
	require.Len(t, morphs, 2)
	assert.Equal(t, "enigma", morphs[0].Code)
	assert.Equal(t, "tangerine", morphs[1].Code)
	assert.Equal(t, "Tangerine", morphs[1].Name)

	ballPythonMorphs, err := repository.ListMorphs(context.Background(), testPool, "ball_python")
	require.NoError(t, err)
	require.Len(t, ballPythonMorphs, 1)
	assert.Equal(t, "Ball Python Tangerine", ballPythonMorphs[0].Name)
}

func TestGetMorphDetail_WithGeneAndCombinationRisk(t *testing.T) {
	detail, err := repository.GetMorphDetail(context.Background(), testPool, "", "enigma")
	require.NoError(t, err)

	assert.Equal(t, "enigma", detail.Code)
	assert.Equal(t, "Enigma", detail.Name)

	require.Len(t, detail.Genes, 1)
	gene := detail.Genes[0]
	assert.Equal(t, "enigma", gene.Code)
	assert.Equal(t, "dominant", gene.InheritanceType)
	require.NotNil(t, gene.RiskCategory)
	assert.Equal(t, "neurological", *gene.RiskCategory)

	require.Len(t, detail.CombinationRisks, 1)
	risk := detail.CombinationRisks[0]
	assert.ElementsMatch(t, []string{"enigma", "enigma"}, risk.GeneCodes)
	assert.Equal(t, "lethal", risk.RiskCategory)
	assert.Equal(t, "avoid", risk.Severity)
}

func TestGetMorphDetail_WithoutGenes(t *testing.T) {
	detail, err := repository.GetMorphDetail(context.Background(), testPool, "", "tangerine")
	require.NoError(t, err)

	assert.Equal(t, "tangerine", detail.Code)
	assert.Equal(t, "Tangerine", detail.Name)
	assert.Empty(t, detail.Genes)
	assert.Empty(t, detail.CombinationRisks)
}

func TestGetMorphDetail_ScopedBySpecies(t *testing.T) {
	leopardTangerine, err := repository.GetMorphDetail(context.Background(), testPool, "leopard_gecko", "tangerine")
	require.NoError(t, err)
	assert.Equal(t, "Tangerine", leopardTangerine.Name)

	ballPythonTangerine, err := repository.GetMorphDetail(context.Background(), testPool, "ball_python", "tangerine")
	require.NoError(t, err)
	assert.Equal(t, "Ball Python Tangerine", ballPythonTangerine.Name)

	_, err = repository.GetMorphDetail(context.Background(), testPool, "leopard_gecko", "does_not_exist")
	assert.ErrorIs(t, err, repository.ErrMorphNotFound)
}

func TestGetMorphDetail_NotFound(t *testing.T) {
	_, err := repository.GetMorphDetail(context.Background(), testPool, "", "does_not_exist")
	assert.ErrorIs(t, err, repository.ErrMorphNotFound)
}
