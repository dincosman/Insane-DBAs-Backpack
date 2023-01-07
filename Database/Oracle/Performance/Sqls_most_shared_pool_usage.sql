-- Top 20 SQL statement using same plan and consuming most memory from shared pool
-- if plan_hash_value equals 0, then insert or plsql statement then look for sql_text with substr.

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
    ROWNUM < 20;