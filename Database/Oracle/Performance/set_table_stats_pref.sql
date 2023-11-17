
-- Set table preference not to collect histogram on specified column

BEGIN
  DBMS_STATS.SET_TABLE_PREFS ('ACCS' ,'T_ACC_DOC','METHOD_OPT','FOR ALL COLUMNS SIZE AUTO, FOR COLUMNS SIZE 1 SYS_NC00076$,SYS_NC00077$');
END;

-- To reset table statistics collection preference

BEGIN
  DBMS_STATS.DELETE_TABLE_PREFS  ('ACCS' ,'T_ACC_DOC','METHOD_OPT');
END;