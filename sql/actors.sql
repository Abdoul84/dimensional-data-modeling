CREATE TYPE films AS (
    year INTEGER,
    film TEXT,
    votes INTEGER,
    rating REAL,
    filmid TEXT
);

CREATE TYPE quality_class AS ENUM ('bad', 'average' , 'good', 'star');

CREATE TABLE actors (
    actor_id TEXT,
    actor_name TEXT,
    films_details films[],
    quality_class quality_class,
    is_active BOOLEAN,
    currentyear_film INTEGER,
    PRIMARY KEY (actor_id, currentyear_film)
);








