package handler_test

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"reptype-catalog-api/handler"
	"reptype-catalog-api/internal/testutil"
	"reptype-catalog-api/model"
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

	gin.SetMode(gin.TestMode)

	code := m.Run()
	pool.Close()
	os.Exit(code)
}

func setupRouter() *gin.Engine {
	r := gin.New()
	r.GET("/api/v1/morphs", handler.ListMorphs(testPool))
	r.GET("/api/v1/morphs/:code", handler.GetMorphDetail(testPool))
	return r
}

func TestListMorphsHandler(t *testing.T) {
	r := setupRouter()
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/morphs", nil)

	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var body struct {
		Morphs []model.Morph `json:"morphs"`
	}
	require.NoError(t, json.Unmarshal(w.Body.Bytes(), &body))
	require.Len(t, body.Morphs, 2)
	assert.Equal(t, "enigma", body.Morphs[0].Code)
	assert.Equal(t, "Enigma", body.Morphs[0].Name)
	assert.Equal(t, "tangerine", body.Morphs[1].Code)
	assert.Equal(t, "Tangerine", body.Morphs[1].Name)
}

func TestGetMorphDetailHandler_Found(t *testing.T) {
	r := setupRouter()
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/morphs/enigma", nil)

	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var detail model.MorphDetail
	require.NoError(t, json.Unmarshal(w.Body.Bytes(), &detail))
	assert.Equal(t, "enigma", detail.Code)

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

func TestGetMorphDetailHandler_NotFound(t *testing.T) {
	r := setupRouter()
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/morphs/does_not_exist", nil)

	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusNotFound, w.Code)
}
