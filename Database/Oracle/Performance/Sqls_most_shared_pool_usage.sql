-- Top 20 SQL plans consuming most memory from shared pool
-- if plan_hash_value equals 0, then insert or pl/sql statement, look for sql_text with substr.

SELECT
    *
FROM
    (
        SELECT
            plan_hash_value,
            COUNT(sql_id),
            SUM(sharable_mem)
        FROM
            gv$sql
        GROUP BY
            plan_hash_value
        ORDER BY
            3 DESC
    )
WHERE
    ROWNUM <= 20;
