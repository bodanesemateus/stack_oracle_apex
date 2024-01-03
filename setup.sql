-- setup.sql
ALTER SESSION SET CONTAINER = FREEPDB1;

CREATE TABLESPACE APEX DATAFILE '/opt/oracle/oradata/APEX01.dbf' SIZE 200M AUTOEXTEND ON NEXT 200M MAXSIZE 32000M;

ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 0;

commit;

EXIT;