package model

type Morph struct {
	Code        string `json:"code"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

type Gene struct {
	Code            string  `json:"code"`
	Name            string  `json:"name"`
	InheritanceType string  `json:"inheritance_type"`
	RiskCategory    *string `json:"risk_category"`
	RiskNote        *string `json:"risk_note"`
	SourceNote      *string `json:"source_note"`
}

type CombinationRisk struct {
	GeneCodes    []string `json:"gene_codes"`
	RiskCategory string   `json:"risk_category"`
	Severity     string   `json:"severity"`
	Note         string   `json:"note"`
	SourceNote   *string  `json:"source_note"`
}

type MorphDetail struct {
	Code             string            `json:"code"`
	Name             string            `json:"name"`
	Description      string            `json:"description"`
	Genes            []Gene            `json:"genes"`
	CombinationRisks []CombinationRisk `json:"combination_risks"`
}
