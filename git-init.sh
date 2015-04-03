#!/bin/bash
# Script de inicialização de ambiente debian/ubuntu

# Ignorar globalmente
cp .gitignore_global ~
git config --global core.excludesfile ~/.gitignore_global

# Adiciona o path para execução dos comandos
FOLDER=$(pwd)
echo "GIT_TIDEXA_SCRIPTS=$FOLDER" >> ~/.bashrc
echo 'PATH=${PATH}:$GIT_TIDEXA_SCRIPTS' >> ~/.bashrc