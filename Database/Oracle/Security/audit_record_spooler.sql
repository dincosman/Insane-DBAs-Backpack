#SQL query to generate JSON output
SPOOL audit.log APPEND

SELECT '{ "oracle_audit": ' ||
            json_object(
                'AUDIT_TYPE' VALUE AUDIT_TYPE,
                'SESSIONID' VALUE SESSIONID,
                'OS_USERNAME' VALUE OS_USERNAME,
                'USERHOST' VALUE USERHOST,
                'TERMINAL' VALUE TERMINAL,
                'INSTANCE_ID' VALUE INSTANCE_ID,
                'DBID' VALUE DBID,
                'AUTHENTICATION_TYPE' VALUE AUTHENTICATION_TYPE,
                'DBUSERNAME' VALUE DBUSERNAME,
                'CLIENT_PROGRAM_NAME' VALUE CLIENT_PROGRAM_NAME,
                'DBLINK_INFO' VALUE DBLINK_INFO,
                'ENTRY_ID' VALUE ENTRY_ID,
                'EVENT_TIMESTAMP' VALUE EVENT_TIMESTAMP,
                'ACTION_NAME' VALUE ACTION_NAME,
                'RETURN_CODE' VALUE RETURN_CODE,
                'OS_PROCESS' VALUE OS_PROCESS,
                'TRANSACTION_ID' VALUE TRANSACTION_ID,
                'OBJECT_SCHEMA' VALUE OBJECT_SCHEMA,
                'OBJECT_NAME' VALUE OBJECT_NAME,
                'SQL_TEXT' VALUE REPLACE(REPLACE(REPLACE(SQL_TEXT, CHR(0), ''), CHR(10), ''), CHR(13), ''), -- Handling null characters, line breaks
                'SQL_BINDS' VALUE REPLACE(REPLACE(REPLACE(SQL_BINDS, CHR(0), ''), CHR(10), ''), CHR(13), ''),
                'SYSTEM_PRIVILEGE_USED' VALUE SYSTEM_PRIVILEGE_USED,
                'UNIFIED_AUDIT_POLICIES' VALUE UNIFIED_AUDIT_POLICIES,
                'RMAN_OPERATION' VALUE RMAN_OPERATION,
                'RMAN_OBJECT_TYPE' VALUE RMAN_OBJECT_TYPE,
                'RMAN_DEVICE_TYPE' VALUE RMAN_DEVICE_TYPE
            RETURNING CLOB) ||
            ' }' AS json_output
        FROM unified_audit_trail;
        
SPOOL OFF
