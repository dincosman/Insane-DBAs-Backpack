DECLARE
patch_name VARCHAR2 (4000);
BEGIN
patch_name := DBMS_SQLDIAG.create_sql_patch (sql_id => '16rzwmtc4wpqu', hint_text => 'PARALLEL(2)', name=>'SQLPATCH_PRODUCTS_PARALLEL');
END;
