CREATE TABLE morph_genes (
    morph_id INT NOT NULL REFERENCES morphs(id),
    gene_id  INT NOT NULL REFERENCES genes(id),
    PRIMARY KEY (morph_id, gene_id)
);