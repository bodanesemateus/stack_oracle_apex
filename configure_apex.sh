#!/bin/bash
# Script to configure Oracle APEX

# Execute o script apxchpwd.sql com as variáveis de ambiente
sqlplus / as sysdba <<EOF
ALTER SESSION SET CONTAINER = FREEPDB1;
@/opt/oracle/product/23c/dbhomeFree/apex_230100/apex/apxchpwd.sql $APEX_ADMIN_USER $APEX_ADMIN_EMAIL $APEX_ADMIN_PASSWORD
EXIT;
EOF
