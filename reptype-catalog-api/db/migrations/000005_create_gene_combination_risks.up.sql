CREATE TABLE gene_combination_risks (
    id            SERIAL PRIMARY KEY,
    gene_a_id     INT NOT NULL REFERENCES genes(id),
    gene_b_id     INT NOT NULL REFERENCES genes(id),
    risk_category VARCHAR NOT NULL,
    severity      VARCHAR NOT NULL,
    note          TEXT NOT NULL,
    CHECK (gene_a_id <= gene_b_id)
);