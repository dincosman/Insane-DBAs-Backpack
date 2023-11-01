SQL> CREATE TABLE SYSTEM.t_client_nls_temp
			(
				parameter    VARCHAR2 (100),
				value        VARCHAR2 (100)
			);

SQL> CREATE or replace TRIGGER SYSTEM.trg_client_HR_nls
				AFTER LOGON
				ON HR.SCHEMA
			DECLARE
				p_param   VARCHAR2 (100);
				p_value    VARCHAR2 (100);
			BEGIN
				FOR rec IN (SELECT parameter, VALUE FROM nls_session_parameters)
				LOOP
					SELECT parameter, VALUE
					  INTO p_param, p_value
					  FROM nls_session_parameters
					 WHERE parameter = rec.parameter;

					INSERT INTO SYSTEM.t_client_nls_temp
						 VALUES (p_param, p_value);

					COMMIT;
				END LOOP;
			END;
