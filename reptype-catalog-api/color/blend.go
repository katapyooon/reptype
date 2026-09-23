// Package color computes a single representative swatch color for a morph
// from the base colors of the genes it carries.
package color

import (
	"fmt"

	colorful "github.com/lucasb-eyer/go-colorful"
)

// DefaultColor is returned when there are no gene colors to blend,
// representing an individual with no color-affecting genes.
const DefaultColor = "#D9A066"

// Blend combines one or more hex color codes into a single representative
// hex color. Colors are blended pairwise in Lab space (BlendLab), which is
// perceptually more even than blending raw RGB values, and are combined in
// order so that every input color ends up with equal weight in the result.
//
// It only produces one flat color and cannot represent spatial patterns
// (e.g. speckling), so it is meant for UI swatches, not a visual rendering
// of the morph.
func Blend(hexColors []string) (string, error) {
	if len(hexColors) == 0 {
		return DefaultColor, nil
	}

	blended, err := colorful.Hex(hexColors[0])
	if err != nil {
		return "", fmt.Errorf("invalid color %q: %w", hexColors[0], err)
	}

	for i, hex := range hexColors[1:] {
		c, err := colorful.Hex(hex)
		if err != nil {
			return "", fmt.Errorf("invalid color %q: %w", hex, err)
		}
		// Blending in with weight 1/(i+2) keeps every color seen so far,
		// including this one, at an equal share of the running result.
		t := 1 / float64(i+2)
		blended = blended.BlendLab(c, t)
	}

	return blended.Hex(), nil
}
