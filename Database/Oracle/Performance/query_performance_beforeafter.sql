SQL> WITH queries_to_measure AS (
    SELECT DISTINCT
        sql_id
    FROM
        gv$sql
    WHERE
            parsing_schema_name = :app_user
        AND upper(sql_fulltext) LIKE '%SDO\_%' ESCAPE '\'
), before_performance AS (
    SELECT
        a.sql_id,
        SUM(buffer_gets_total) / SUM(executions_total)            AS gets_per_exec_before,
        SUM(rows_processed_total) / SUM(executions_total)         AS rows_per_exec_before,
        SUM(elapsed_time_total) / SUM(executions_total) / 1000000 AS time_per_exec_before,
        SUM(executions_total)                                     AS execs_total_before
    FROM
        dba_hist_sqlstat a,
        queries_to_measure
    WHERE
            a.sql_id = queries_to_measure.sql_id
        AND executions_total > 0
        AND snap_id < (
            SELECT
                MAX(snap_id)
            FROM
                dba_hist_snapshot
            WHERE
                begin_interval_time < to_date(:p_change_time, 'DD/MM/YYYY HH24:MI:SS')
        )
    GROUP BY
        a.sql_id
    ORDER BY
        a.sql_id
), after_performance AS (
    SELECT
        b.sql_id,
        SUM(buffer_gets_total) / SUM(executions_total)            AS gets_per_after,
        SUM(rows_processed_total) / SUM(executions_total)         AS rows_per_after,
        SUM(elapsed_time_total) / SUM(executions_total) / 1000000 AS time_per_after,
        SUM(executions_total)                                     AS execs_total_after
    FROM
        dba_hist_sqlstat b,
        queries_to_measure
    WHERE
            b.sql_id = queries_to_measure.sql_id
        AND executions_total > 0
        AND snap_id > (
            SELECT
                MAX(snap_id)
            FROM
                dba_hist_snapshot
            WHERE
                begin_interval_time < to_date(:p_change_time, 'DD/MM/YYYY HH24:MI:SS')
        )
    GROUP BY
        b.sql_id
    ORDER BY
        b.sql_id
)
SELECT
    before_performance.*,
    after_performance.*
FROM
    before_performance,
    after_performance
WHERE
    before_performance.sql_id = after_performance.sql_id (+);
