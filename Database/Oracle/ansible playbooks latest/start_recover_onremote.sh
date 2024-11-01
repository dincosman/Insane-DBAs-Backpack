#!/bin/bash
export ORACLE_SID=$1
export ORACLE_HOME=$2
$ORACLE_HOME/bin/sqlplus -s /nolog << END_SQL
conn / as sysdba
set serveroutput on feedback off;
DECLARE
inst_id number;
mrp number;
inst_name varchar2(50);
BEGIN
        IF sys_context ('userenv','database_role') = 'PHYSICAL STANDBY'
        THEN
                select instance_number, instance_name into inst_id, inst_name from v\$instance ;
                select count(*) into mrp from v\$managed_standby where process='MRP0';
                if inst_id = 1 and mrp = 0
                THEN
                        execute immediate 'ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT';
                        dbms_output.put_line('Recovery started on: ' || inst_name);
                ELSE
                        dbms_output.put_line('No action taken. ');
                END IF;
        ELSE
                dbms_output.put_line('No action taken. ');
        END IF;
END;
/
exit;
END_SQL
#