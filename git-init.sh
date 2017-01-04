#!/bin/bash
clear
set -e
# Importação
. ./utils.sh

# Script de inicialização de ambiente debian/ubuntu
GIT_IGNORE_GLOBAL_HOME=~/.gitignore_global
FOLDER=$(pwd)

# jq utilizado para trabalhar com as respostas em JSON
# da API do gitlab
installSoft jq

# No mac vamos utilizar sourcetree (stree na linha de comando)
if [[ "$OSTYPE" == *darwin* ]]; then
	brew install Caskroom/cask/sourcetree
else
	# Meld será a ferramenta de diferenciação
	installSoft meld
fi

# Color output
git config --global color.ui always
git config --global color.status always

./git-init-config "false"
