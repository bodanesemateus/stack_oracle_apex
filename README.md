# Stack Oracle + Apex

Neste repositorio contem arquivos para subir um docker local com um container rodando oracle 21 + oracle Apex 23.2.2


docker run -d -it --name oracle23 -p 8521:1521 -p 8500:5500 -p 8023:8080 -p 9043:8443 -e ORACLE_PWD=E container-registry.oracle.com/database/free:latest


================================================================= INSTALL APEX ==============================================================================

mkdir install
cd install
	curl -o apex-latest.zip https://download.oracle.com/otn_software/apex/apex-latest.zip

cd $ORACLE_HOME
mkdir apex_23
cd apex_23
	unzip /home/oracle/install/apex-latest.zip
	cd apex
	sqlplus / as sysdba
	
ALTER SESSION SET CONTAINER = FREEPDB1;
CREATE TABLESPACE APEX DATAFILE '/opt/oracle/oradata/APEX01.dbf' SIZE 200M AUTOEXTEND ON NEXT 200M MAXSIZE 32000M;
ALTER SYSTEM SET JOB_QUEUE_PROCESSES=0;
@apexins APEX APEX TEMP /i/


@apxchpwd ADMIN bodanesemateus@gmail.com Oracle123#apex

@apex_rest_config.sql Oracle123#apex Oracle123#apex
	

ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;

ALTER SYSTEM SET JOB_QUEUE_PROCESSES=1000;

set serverout on
DECLARE
	ACL_PATH VARCHAR2(4000);
BEGIN
	SELECT ACL INTO ACL_PATH FROM DBA_NETWORK_ACLS
	 WHERE HOST = '*' AND LOWER_PORT IS NULL AND UPPER_PORT IS NULL;
	 
	 IF DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE(ACL_PATH, 'APEX_230200', 'connect') IS NULL THEN
		dbms_output.put_line('Adicionado grant de connect ao usuario apex no ACL');
		DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(ACL_PATH, 'APEX_230200', TRUE, 'connect');
	 END IF;
	 
	 IF DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE(ACL_PATH, 'APEX_230200', 'resolve') IS NULL THEN
		dbms_output.put_line('Adicionado grant de resolve ao usuario apex no ACL');
		DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(ACL_PATH, 'APEX_230200', TRUE, 'resolve');
	 END IF;

EXCEPTION
	--when no ACL has been assigned to '*'.
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('adicionado');

END;
/
COMMIT;

====================================================================== INSTALL ORDS ==================================================================================

cd /home/oracle/install 
	curl -o ords.zip https://download.oracle.com/otn_software/java/ords/ords-23.4.0.346.1619.zip



vi .bashprofile

i
	export ORDS_HOME=/opt/oracle/ords
	export ORDS_CONFIG=/opt/oracle/ords
	export PATH=$ORDS_HOME/bin:$JAVA_HOME/bin:PATH
	export ORDS_CONFIG=/opt/oracle/ords
	export PATH

esc
:wq!

source .bashprofile

mkdir $ORDS_HOME
cd $ORDS_HOME
	unzip /home/oracle/install/ords.zip
	cp -r /opt/oracle/product/23c/dbhomeFree/apex_230100/apex/images/ .
	mv images/ i
	
	
echo -e "2\n1\n1\nlocalhost\n1521\nFREEPDB1\nsys\nE\nSYSAUX\nTEMP\n1\n1\n1\n8043\n/opt/oracle/ords/i/\n" |ords install

ords config set jdbc.MaxLimit 1000;
ords config set jdbc.InitialLimit 100;


vi /opt/oracle/ords/scripts/start_ords.sh

#!/bin/bash

export ORDS_HOME=/opt/oracle/ords
export ORDS_CONFIG=/opt/oracle/ords
export PATH=$ORDS_HOME/bin:$JAVA_HOME/bin:PATH
export ORDS_CONFIG=/opt/oracle/ords

nohup ords --config ${ORDS_CONFIG} serve --secure --port 8443 &


vi /opt/oracle/ords/scripts/stop_ords.sh

 

chmod x+ scripts/*.sh

./scripts/start_ords.sh






echo -e "2\n1\n1\nlocalhost\n1521\nFREEPDB1\nsys\nE\nSYSAUX\nTEMP\n1\n1\n1\n8043\n/opt/oracle/ords/i/\n" |ords install







COPY install.sql /opt/oracle/product/23c/dbhomeFree/apex_230100/apex/install.sql

RUN cd /opt/oracle/product/23c/dbhomeFree/apex_230100/apex && \
    sqlplus / as sysdba @./install.sql

COPY configure_apex.sql /opt/oracle/product/23c/dbhomeFree/apex_230100/apex/configure_apex.sql

RUN cd /opt/oracle/product/23c/dbhomeFree/apex_230100/apex && \
    sqlplus / as sysdba @./configure_apex.sql

# Copie o arquivo SQL para o contêiner
COPY configure.sql /home/oracle/configure.sql

# Execute o SQL*Plus como usuário sys para executar os comandos no arquivo SQL
RUN sqlplus / as sysdba @/home/oracle/configure.sql

# Define variáveis de ambiente
ENV ORDS_HOME /opt/oracle/ords
ENV ORDS_CONFIG /opt/oracle/ords
ENV PATH $ORDS_HOME/bin:$JAVA_HOME/bin:$PATH

RUN cd /home/oracle/install && \
    curl -o ords.zip https://download.oracle.com/otn_software/java/ords/ords-23.2.3.242.1937.zip

# Cria o diretório ORDS e descompacta o arquivo
RUN mkdir $ORDS_HOME &&\
    cd $ORDS_HOME && \
    unzip /home/oracle/install/ords.zip && \
    cp -r /opt/oracle/product/23c/dbhomeFree/apex_230100/apex/images/ . && \
    mv images/ i
