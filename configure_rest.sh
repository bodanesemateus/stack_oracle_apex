#!/bin/bash
# Script to configure Oracle APEX

# Define variáveis de ambiente para o usuário admin, email e senha
LISTENER="$LISTENER"
PUBLIC="$PUBLIC"

# Execute o script apex_rest_config.sql com as variáveis de ambiente
sqlplus / as sysdba <<EOF
ALTER SESSION SET CONTAINER = FREEPDB1;
@apex_rest_config.sql $LISTENER $PUBLIC
EXIT;
EOF
