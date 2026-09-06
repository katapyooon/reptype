package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"reptype-catalog-api/repository"
)

func ListMorphs(pool *pgxpool.Pool) gin.HandlerFunc {
	return func(c *gin.Context) {
		morphs, err := repository.ListMorphs(c.Request.Context(), pool)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch morphs"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"morphs": morphs})
	}
}
