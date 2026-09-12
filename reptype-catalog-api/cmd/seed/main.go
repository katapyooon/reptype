package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"

	"reptype-catalog-api/db"
)

type gene struct {
	code            string
	name            string
	inheritanceType string
	riskCategory    *string
	riskNote        *string
	sourceNote      *string
}

type morph struct {
	code        string
	name        string
	description string
	geneCodes   []string
}

type combinationRisk struct {
	geneCodeA    string
	geneCodeB    string
	riskCategory string
	severity     string
	note         string
	sourceNote   string
}

func strPtr(s string) *string { return &s }

const speciesCode = "leopard_gecko"

var genes = []gene{
	{
		code:            "tremper_albino",
		name:            "Tremper Albino",
		inheritanceType: "recessive",
	},
	{
		code:            "rainwater_albino",
		name:            "Rainwater Albino",
		inheritanceType: "recessive",
	},
	{
		code:            "bell_albino",
		name:            "Bell Albino",
		inheritanceType: "recessive",
	},
	{
		code:            "mack_snow",
		name:            "Mack Snow",
		inheritanceType: "incomplete_dominant",
	},
	{
		code:            "enigma",
		name:            "Enigma",
		inheritanceType: "dominant",
		riskCategory:    strPtr("neurological"),
		riskNote:        strPtr("ヘテロ接合(1コピー)でも平衡感覚障害・首振り・けいれん等の神経症状(エニグマ症候群)が発症しうる常染色体優性の障害とされる。"),
		sourceNote:      strPtr("Bargen, B. \"Enigma Syndrome in Leopard Geckos: An Autosomal Dominant Disorder\" Gecko Time (breeder opinion, not peer-reviewed). https://geckotime.com/enigma-syndrome/"),
	},
	{
		code:            "lemon_frost",
		name:            "Lemon Frost",
		inheritanceType: "incomplete_dominant",
		riskCategory:    strPtr("tumor"),
		riskNote:        strPtr("lf対立遺伝子を持つ個体の80%以上(ヘテロ・ホモ接合問わず)が生後6ヶ月〜5年でイリドフォローマ(腫瘍)を発症する。候補原因遺伝子はSPINT1(腫瘍抑制遺伝子)。"),
		sourceNote:      strPtr("Guo L, et al. \"Genetics of white color and iridophoroma in 'Lemon Frost' leopard geckos\" PLOS Genetics 17(6):e1009580, 2021 (peer-reviewed). https://doi.org/10.1371/journal.pgen.1009580"),
	},
}

var morphs = []morph{
	{code: "tremper_albino", name: "Tremper Albino", description: "灰色がかったピンクの目と、冷たいラベンダー・イエロー系の体色が特徴のアルビノ系統。", geneCodes: []string{"tremper_albino"}},
	{code: "rainwater_albino", name: "Rainwater Albino", description: "淡いピンクの目と、柔らかいクリーム・イエロー系の体色が特徴のアルビノ系統。", geneCodes: []string{"rainwater_albino"}},
	{code: "bell_albino", name: "Bell Albino", description: "ピンクがかった目と、暖かみのあるイエロー・ピンク系の体色が特徴のアルビノ系統。", geneCodes: []string{"bell_albino"}},
	{code: "mack_snow", name: "Mack Snow", description: "黒色色素が減少し、白っぽい地色になるモルフ。", geneCodes: []string{"mack_snow"}},
	{code: "enigma", name: "Enigma", description: "不規則な斑点模様が特徴のモルフ。", geneCodes: []string{"enigma"}},
	{code: "lemon_frost", name: "Lemon Frost", description: "白色の増加と明るい黄色・オレンジ色が特徴のモルフ。", geneCodes: []string{"lemon_frost"}},
	// ポリジーン(複数遺伝子が関与し、単純なメンデル比が存在しない)のラインブリード系統。
	// 単一遺伝子座を前提としたgenesには紐付けず、図鑑表示専用のモルフとして登録する。
	{code: "tangerine", name: "Tangerine", description: "体の黒色色素を減らし、オレンジ色を濃くしたモルフ。", geneCodes: []string{}},
	{code: "black_night", name: "Black Night", description: "黒色を濃くしたモルフ。", geneCodes: []string{}},
	{code: "inferno", name: "Inferno", description: "全身が赤みを帯びたオレンジ色になるモルフ。", geneCodes: []string{}},
}

var combinationRisks = []combinationRisk{
	{
		geneCodeA:    "enigma",
		geneCodeB:    "enigma",
		riskCategory: "lethal",
		severity:     "avoid",
		note:         "ホモ接合(AA)は多くの場合胚が致死となり、孵化前に流産することが報告されている。",
		sourceNote:   "Bargen, B. \"Enigma Syndrome in Leopard Geckos: An Autosomal Dominant Disorder\" Gecko Time. https://geckotime.com/enigma-syndrome/",
	},
	{
		geneCodeA:    "lemon_frost",
		geneCodeB:    "lemon_frost",
		riskCategory: "tumor",
		severity:     "avoid",
		note:         "ホモ接合(Super Lemon Frost)では腫瘍がより広範囲化し、肝臓・眼・筋肉への転移の可能性も報告されている。",
		sourceNote:   "Guo L, et al. PLOS Genetics 17(6):e1009580, 2021. https://doi.org/10.1371/journal.pgen.1009580",
	},
}

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("no .env file found, using environment variables as-is")
	}

	ctx := context.Background()
	pool, err := db.NewPool(ctx)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	defer pool.Close()

	if err := seed(ctx, pool); err != nil {
		log.Fatalf("failed to seed data: %v", err)
	}

	log.Println("seed completed")
}

func seed(ctx context.Context, pool *pgxpool.Pool) error {
	var speciesID int
	err := pool.QueryRow(ctx, `
		INSERT INTO species (code) VALUES ($1)
		ON CONFLICT (code) DO UPDATE SET code = EXCLUDED.code
		RETURNING id
	`, speciesCode).Scan(&speciesID)
	if err != nil {
		return fmt.Errorf("failed to upsert species: %w", err)
	}

	geneIDs := make(map[string]int, len(genes))
	for _, g := range genes {
		var geneID int
		err := pool.QueryRow(ctx, `
			INSERT INTO genes (species_id, code, name, inheritance_type, risk_category, risk_note, source_note)
			VALUES ($1, $2, $3, $4, $5, $6, $7)
			ON CONFLICT (species_id, code) DO UPDATE SET
				name = EXCLUDED.name,
				inheritance_type = EXCLUDED.inheritance_type,
				risk_category = EXCLUDED.risk_category,
				risk_note = EXCLUDED.risk_note,
				source_note = EXCLUDED.source_note
			RETURNING id
		`, speciesID, g.code, g.name, g.inheritanceType, g.riskCategory, g.riskNote, g.sourceNote).Scan(&geneID)
		if err != nil {
			return fmt.Errorf("failed to upsert gene %s: %w", g.code, err)
		}
		geneIDs[g.code] = geneID
	}

	for _, m := range morphs {
		var morphID int
		err := pool.QueryRow(ctx, `
			INSERT INTO morphs (species_id, code, name, description)
			VALUES ($1, $2, $3, $4)
			ON CONFLICT (species_id, code) DO UPDATE SET
				name = EXCLUDED.name,
				description = EXCLUDED.description
			RETURNING id
		`, speciesID, m.code, m.name, m.description).Scan(&morphID)
		if err != nil {
			return fmt.Errorf("failed to upsert morph %s: %w", m.code, err)
		}

		for _, geneCode := range m.geneCodes {
			geneID, ok := geneIDs[geneCode]
			if !ok {
				return fmt.Errorf("unknown gene code %s referenced by morph %s", geneCode, m.code)
			}
			_, err := pool.Exec(ctx, `
				INSERT INTO morph_genes (morph_id, gene_id) VALUES ($1, $2)
				ON CONFLICT DO NOTHING
			`, morphID, geneID)
			if err != nil {
				return fmt.Errorf("failed to link morph %s to gene %s: %w", m.code, geneCode, err)
			}
		}
	}

	for _, r := range combinationRisks {
		geneAID, ok := geneIDs[r.geneCodeA]
		if !ok {
			return fmt.Errorf("unknown gene code %s in combination risk", r.geneCodeA)
		}
		geneBID, ok := geneIDs[r.geneCodeB]
		if !ok {
			return fmt.Errorf("unknown gene code %s in combination risk", r.geneCodeB)
		}
		if geneAID > geneBID {
			geneAID, geneBID = geneBID, geneAID
		}

		_, err := pool.Exec(ctx, `
			INSERT INTO gene_combination_risks (gene_a_id, gene_b_id, risk_category, severity, note, source_note)
			VALUES ($1, $2, $3, $4, $5, $6)
			ON CONFLICT DO NOTHING
		`, geneAID, geneBID, r.riskCategory, r.severity, r.note, r.sourceNote)
		if err != nil {
			return fmt.Errorf("failed to upsert combination risk %s x %s: %w", r.geneCodeA, r.geneCodeB, err)
		}
	}

	return nil
}
