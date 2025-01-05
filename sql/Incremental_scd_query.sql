
CREATE TYPE scd_type AS (
                    quality_class quality_class,
                    is_active boolean,
                    start_year INTEGER,
                    end_year INTEGER
                        )


WITH last_year_scd AS (
    SELECT * FROM actors_history_scd
    WHERE current_year_film = 2019
    AND end_year = 2020
),
     historical_scd AS (
        SELECT
            actor_name,
               quality_class,
               is_active,
               start_year,
               end_year
        FROM actors_history_scd
        WHERE current_year_film = 2019
        AND end_year < 2020
     ),
     this_year_data AS (
         SELECT * FROM actors
         WHERE currentyear_film = 2020
     ),
     unchanged_records AS (
         SELECT
                tyd.actor_name,
                tyd.quality_class,
                tyd.is_active,
                lyscd.start_year,
                tyd.currentyear_film as end_year
        FROM this_year_data tyd
        JOIN last_year_scd lyscd
        ON lyscd.actor_name = tyd.actor_name
         WHERE tyd.quality_class = lyscd.quality_class
         AND tyd.is_active = lyscd.is_active
     ),
     changed_records AS (
        SELECT
                tyd.actor_name,
                UNNEST(ARRAY[
                    ROW(
                        lyscd.quality_class,
                        lyscd.is_active,
                        lyscd.start_year,
                        lyscd.end_year

                        )::scd_type,
                    ROW(
                        tyd.quality_class,
                        tyd.is_active,
                        tyd.currentyear_film,
                        tyd.currentyear_film
                        )::scd_type
                ]) as records
        FROM this_year_data tyd
        LEFT JOIN last_year_scd lyscd
        ON lyscd.actor_name = tyd.actor_name
         WHERE (tyd.quality_class <> lyscd.quality_class
          OR tyd.is_active <> lyscd.is_active)
     ),
     unnested_changed_records AS (

         SELECT actor_name,
                (records::scd_type).quality_class,
                (records::scd_type).is_active,
                (records::scd_type).start_year,
                (records::scd_type).end_year
                FROM changed_records
         ),
     new_records AS (

         SELECT
            tyd.actor_name,
                tyd.quality_class,
                tyd.is_active,
                tyd.currentyear_film AS start_year,
                tyd.currentyear_film AS end_year
         FROM this_year_data tyd
         LEFT JOIN last_year_scd lyscd
             ON tyd.actor_name = lyscd.actor_name
         WHERE lyscd.actor_name IS NULL

     )


SELECT *, 2020 AS current_year_film FROM (
                  SELECT *
                  FROM historical_scd

                  UNION ALL

                  SELECT *
                  FROM unchanged_records

                  UNION ALL

                  SELECT *
                  FROM unnested_changed_records

                  UNION ALL

                  SELECT *
                  FROM new_records
              ) a