ALTER TABLE genes ADD COLUMN source_note TEXT;
ALTER TABLE gene_combination_risks ADD COLUMN source_note TEXT;
ALTER TABLE gene_combination_risks ADD CONSTRAINT gene_combination_risks_gene_a_id_gene_b_id_key UNIQUE (gene_a_id, gene_b_id);
