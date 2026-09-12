package handler

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"reptype-catalog-api/repository"
)

func ListMorphs(pool *pgxpool.Pool) gin.HandlerFunc {
	return func(c *gin.Context) {
		speciesCode := c.Query("species")

		morphs, err := repository.ListMorphs(c.Request.Context(), pool, speciesCode)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch morphs"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"morphs": morphs})
	}
}

func GetMorphDetail(pool *pgxpool.Pool) gin.HandlerFunc {
	return func(c *gin.Context) {
		code := c.Param("code")
		speciesCode := c.Query("species")

		detail, err := repository.GetMorphDetail(c.Request.Context(), pool, speciesCode, code)
		if err != nil {
			if errors.Is(err, repository.ErrMorphNotFound) {
				c.JSON(http.StatusNotFound, gin.H{"error": "morph not found"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch morph"})
			return
		}

		c.JSON(http.StatusOK, detail)
	}
}
