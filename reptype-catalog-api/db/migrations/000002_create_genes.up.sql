CREATE TABLE genes (
    id               SERIAL PRIMARY KEY,
    species_id       INT NOT NULL REFERENCES species(id),
    code             VARCHAR NOT NULL,
    name             VARCHAR NOT NULL,
    inheritance_type VARCHAR NOT NULL,
    risk_category    VARCHAR,
    risk_note        TEXT,
    UNIQUE (species_id, code)
);