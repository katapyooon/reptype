package color_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"reptype-catalog-api/color"
)

func TestBlend_NoColors(t *testing.T) {
	got, err := color.Blend(nil)
	require.NoError(t, err)
	assert.Equal(t, color.DefaultColor, got)
}

func TestBlend_SingleColor(t *testing.T) {
	got, err := color.Blend([]string{"#FFD54F"})
	require.NoError(t, err)
	assert.Equal(t, "#ffd54f", got)
}

func TestBlend_TwoColors_IsBetweenInputs(t *testing.T) {
	got, err := color.Blend([]string{"#000000", "#ffffff"})
	require.NoError(t, err)

	assert.NotEqual(t, "#000000", got)
	assert.NotEqual(t, "#ffffff", got)
	assert.Regexp(t, `^#[0-9a-f]{6}$`, got)
}

func TestBlend_IsOrderIndependent(t *testing.T) {
	forward, err := color.Blend([]string{"#ffd54f", "#ffffff", "#546e7a"})
	require.NoError(t, err)

	backward, err := color.Blend([]string{"#546e7a", "#ffffff", "#ffd54f"})
	require.NoError(t, err)

	assert.Equal(t, forward, backward)
}

func TestBlend_InvalidColor(t *testing.T) {
	_, err := color.Blend([]string{"not-a-color"})
	assert.Error(t, err)
}

func TestBlend_InvalidColorAmongValid(t *testing.T) {
	_, err := color.Blend([]string{"#ffffff", "not-a-color"})
	assert.Error(t, err)
}
