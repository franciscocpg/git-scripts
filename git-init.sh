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
# Testar com link simbólico ao invés de copiar
if [[ ! -e "$GIT_IGNORE_GLOBAL_HOME" ]]; then
	ln -s "$FOLDER/.gitignore_global" "$GIT_IGNORE_GLOBAL_HOME"
	git config --global core.excludesfile "$GIT_IGNORE_GLOBAL_HOME"
fi


# Adiciona o path para execução dos comandos
CONTAINS_GIT_TIDEXA_SCRIPTS=$(cat $BASH_RC | grep GIT_TIDEXA_SCRIPTS)
if [[ -z "$CONTAINS_GIT_TIDEXA_SCRIPTS" ]]; then
	echo -e "\nGIT_TIDEXA_SCRIPTS=$FOLDER" >> $BASH_RC
	echo 'PATH=${PATH}:$GIT_TIDEXA_SCRIPTS' >> $BASH_RC	
fi

./git-init-config
