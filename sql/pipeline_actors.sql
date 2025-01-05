WITH lastyear_film AS (
    SELECT *
    FROM actors
    WHERE currentyear_film = 1970
), thisyear_film AS (
    SELECT DISTINCT ON (actorid) *
    FROM actor_films
    WHERE year = 1971
)
INSERT INTO actors (
    actor_id,
    actor_name,
    films_details,
    quality_class,
    is_active,
    currentyear_film
)
SELECT
    COALESCE(lyf.actor_id, tyf.actorid) AS actor_id,
    COALESCE(lyf.actor_name, tyf.actor) AS actor_name,
    COALESCE(
        lyf.films_details,
        ARRAY[]::films[]
    ) ||
    CASE
        WHEN tyf.year IS NOT NULL THEN
            ARRAY[
                ROW(
                    tyf.year,
                    tyf.film,
                    tyf.votes,
                    tyf.rating,
                    tyf.filmid
                )::films
            ]
        ELSE
            ARRAY[]::films[]
    END AS films_details,
    CASE
        WHEN tyf.year IS NOT NULL THEN
            (CASE WHEN tyf.rating > 8 THEN 'star'
                  WHEN tyf.rating > 7 AND tyf.rating <= 8 THEN 'good'
                  WHEN tyf.rating > 6 AND tyf.rating <= 7 THEN 'average'
                  ELSE 'bad' END)::quality_class
            ELSE lyf.quality_class
    END AS quality_class,
    tyf.year IS NOT NULL AS is_active,
    1971 AS currentyear_film
FROM
    lastyear_film lyf
FULL OUTER JOIN
    thisyear_film tyf
ON
    lyf.actor_id = tyf.actorid
WHERE NOT EXISTS (
    SELECT 1
    FROM actors a
    WHERE a.actor_id = COALESCE(lyf.actor_id, tyf.actorid)
      AND a.currentyear_film = 1971
);
