ALTER TABLE gene_combination_risks DROP CONSTRAINT gene_combination_risks_gene_a_id_gene_b_id_key;
ALTER TABLE gene_combination_risks DROP COLUMN source_note;
ALTER TABLE genes DROP COLUMN source_note;
