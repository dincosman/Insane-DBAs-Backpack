SQL> select dbms_metadata.get_ddl ('PROCOBJ',job_name,owner) from dba_scheduler_jobs where owner='HR' and job_name='JOB_HR_SENDMAIL'
