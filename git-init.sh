#!/bin/bash
# Importação
. ./utils.sh

# Script de inicialização de ambiente debian/ubuntu
BASH_RC=~/.bashrc
GIT_IGNORE_GLOBAL_HOME=~/.gitignore_global
FOLDER=$(pwd)

# jq utilizado para trabalhar com as respostas em JSON
# da API do gitlab
installSoft jq

# Meld será a ferramenta de diferenciação
installSoft meld

# Ignorar globalmente
# cp .gitignore_global ~ 
if [[ ! -e "$GIT_IGNORE_GLOBAL_HOME" ]]; then
	ln -s "$FOLDER/.gitignore_global" "$GIT_IGNORE_GLOBAL_HOME"
	git config --global core.excludesfile "$GIT_IGNORE_GLOBAL_HOME"
fi

# Color output
git config --global color.ui always
git config --global color.status always

# Adiciona o path para execução dos comandos
CONTAINS_GIT_TIDEXA_SCRIPTS=$(cat $BASH_RC | grep GIT_TIDEXA_SCRIPTS)
if [[ -z "$CONTAINS_GIT_TIDEXA_SCRIPTS" ]]; then
	echo -e "\nGIT_TIDEXA_SCRIPTS=$FOLDER" >> $BASH_RC
	echo 'PATH=${PATH}:$GIT_TIDEXA_SCRIPTS' >> $BASH_RC	
fi

# Instalação do certificado GITLAB
sudo wget https://www.startssl.com/certs/sub.class1.server.ca.pem -O /usr/share/ca-certificates/mozilla/StartCom_Class_1_Primary_Intermediate_Server_CA.crt
sudo sh -c 'echo "mozilla/StartCom_Class_1_Primary_Intermediate_Server_CA.crt" >> /etc/ca-certificates.conf'
sudo update-ca-certificates

./git-init-config "false" "$FOLDER"
