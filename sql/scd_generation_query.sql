WITH streak_started AS (
    SELECT actor_name,
           currentyear_film,
           quality_class,
           LAG(quality_class,1) OVER
           (PARTITION BY actor_name ORDER BY currentyear_film) <> quality_class
           or LAG(quality_class,1) OVER
           (PARTITION BY actor_name ORDER BY currentyear_film) IS NULL as did_change
    FROM actors
),
    streak_pinger AS (
        SELECT actor_name,
               quality_class,
               currentyear_film,
               SUM(CASE WHEN did_change THEN 1 ELSE 0 END)
                   OVER (PARTITION BY actor_name ORDER BY currentyear_film) AS streak_found
        FROM streak_started
    ),
    aggregated AS (
        SELECT
            actor_name,
            quality_class,
            streak_found,
            MIN(currentyear_film) AS start_date,
            MAX(currentyear_film) AS end_date
        FROM streak_pinger
        GROUP BY 1,2,3
    )
    SELECT actor_name, quality_class, start_date, end_date
    FROM aggregated;
