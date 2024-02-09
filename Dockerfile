# Use a imagem Oracle Database como base
FROM container-registry.oracle.com/database/free:latest

# Altere para o usuário root
USER root

# Atualize o sistema e instale as dependências
RUN yum update -y && \
    yum install -y unzip && \
    yum clean all

# Copie o script de configuração do apex para o contêiner
COPY configure_apex.sh /home/oracle/configure_apex.sh

#permissao
RUN chmod +x /home/oracle/configure_apex.sh

# Copie o script de configuração do rest para o contêiner
COPY configure_rest.sh /home/oracle/configure_rest.sh

#permissao
RUN chmod +x /home/oracle/configure_rest.sh

COPY install.sql /opt/oracle/product/23c/dbhomeFree/apex_230100/apex/install.sql

RUN chmod +x /opt/oracle/product/23c/dbhomeFree/apex_230100/apex/install.sql

# Instala o Java 17
RUN dnf install java-17-openjdk -y

USER oracle

# Crie uma pasta com os instaladores e baixe os mesmos
RUN mkdir /home/oracle/install && \
    cd /home/oracle/install && \
    curl -o apex-latest.zip https://download.oracle.com/otn_software/apex/apex_23.1.zip

COPY install.sql /opt/oracle/product/23c/dbhomeFree/apex_230100/apex/install.sql

RUN cd /opt/oracle/product/23c/dbhomeFree/apex_230100/apex && \
    sqlplus / as sysdba @./install.sql
