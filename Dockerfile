# Use a imagem Oracle Database como base
FROM container-registry.oracle.com/database/free:latest

RUN sleep 25
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

# Instala o Java 17
RUN dnf install java-17-openjdk -y

USER oracle

# Crie uma pasta com os instaladores e baixe os mesmos
RUN mkdir /home/oracle/install && \
    cd /home/oracle/install && \
    curl -o apex-latest.zip https://download.oracle.com/otn_software/apex/apex_23.1.zip

# Crie um diretório para o Oracle APEX e descompacte o mesmo
RUN cd $ORACLE_HOME && \
    mkdir apex_230100 && \
    cd apex_230100 && \
    unzip /home/oracle/install/apex-latest.zip && \
    cd apex

COPY setup.sql /opt/oracle/product/23c/dbhomeFree/apex_230100/apex/setup.sql

RUN cd /opt/oracle/product/23c/dbhomeFree/apex_230100/apex && \
    sqlplus / as sysdba @./setup.sql

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
