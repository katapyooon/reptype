CREATE TABLE morphs (
    id          SERIAL PRIMARY KEY,
    species_id  INT NOT NULL REFERENCES species(id),
    code        VARCHAR NOT NULL,
    name        VARCHAR NOT NULL,
    description TEXT,
    image_path  VARCHAR,
    UNIQUE (species_id, code)
);