#!/bin/bash

# Set Oracle environment variables
source /home/oracle/.bashrc
export ORAENV_ASK=NO
export ORACLE_SID=bltdb1
. oraenv bltdb1
#export ORACLE_PDB_SID=testpdb

# Execute SQL query and spool output to file
$ORACLE_HOME/bin/sqlplus -s /nolog << EOF
conn /  as sysdba
SET LONG 50000
SET LONGCHUNKSIZE 50000
SET LINESIZE 32767
SET PAGESIZE 0
SET FEEDBACK OFF
SET TRIMSPOOL ON
SET TAB OFF
SET SERVEROUTPUT OFF
SET VERIFY OFF
SET HEADING OFF
SET TERMOUT OFF
SET ECHO OFF
@audit_record_spooler.sql
EOF
