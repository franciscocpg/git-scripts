#!/bin/bash -i
BASH_RC=~/.bashrc

# Recupera o nome comercial do OS
getOSName() {
	lsb_release -si	
}

# Recupera a versão do OS
getOSVersion() {
	lsb_release -sr
}

# Recupera a arquitetura do OS
getOSArch() {
	uname -m | sed 's/x86_//;s/i[3-6]86/32/'
}

# Instala um sw no OS de acordo com o gerenciador de pacotes
# default para o OS
installSoft() {
	local cmd="";
	# Nome do sw
	local soft="$1"
	if [[ $(getOSName) == "Ubuntu" ]]; then
		cmd="sudo apt-get install"
	elif [[ $(getOSName) == "CentOS" ]]; then
		cmd="sudo yum install"
	fi
	cmd="$cmd $soft"
	$cmd
}

# Adiciona variáveis globais para o arquivo .bashrc
appendToBashRC() {
	# Nome da varíavel
	local variable="$1"
	# Valor da variável
	local value="$2"
	# Se é para incluir na variável $PATH
	local includePath="$3"
	# Se é para substituir o valor caso a variável já exista
	local replace="$4"
	if [[ -z "$includePath" ]]; then
		includePath="false"
	fi
	if [[ -z "$replace" ]]; then
		replace="false"
	fi
	CONTAINS=$(cat $BASH_RC | grep $variable)
	if [[ -z "$CONTAINS" ]]; then
		echo -e "\nexport $variable=$value" >> $BASH_RC
		if [[ "$includePath" = "true" ]]; then
			echo 'export PATH=${PATH}:$'$variable'/bin' >> $BASH_RC	
		fi
	elif [[ "$replace" = "true" ]]; then
		CONTENTS=$(cat $BASH_RC)
		# Recupera o valor da variável
		eval VALUE=\$$variable
		REPLACE="$variable=$VALUE"
		NEW_VALUE="$variable=$value"
		# Substitui apenas a primeira ocorrência
		# Para substituir todas seria com duas barras CONTENTS=${CONTENTS//$REPLACE/$NEW_VALUE}
		CONTENTS=${CONTENTS/$REPLACE/$NEW_VALUE}
		# Salva no arquivo
		echo -e "$CONTENTS" > $BASH_RC
	fi
}

# Resolve um caminho para o nome completo
resolvePath() {
	# Caminho
	local path="$1"
	chd $path
	RETURN_PATH=$(pwd)
	chd -
	echo $RETURN_PATH
}

# Resolve o nome base do caminho
resolveBasename() {
	# Caminho
	local path="$1"
	basename $(resolvePath "$path")
}

# Pergunta com resposta sim (s) ou não (n)
ask() {
	# Pergunta
	local question="$1"
	while true; do
		read -p "$question[s/n]" sn
		case $sn in
			[Ss]* ) break;;
			[Nn]* ) break;;
			* ) echo "Entre s[sim] ou n[não]";;
		esac
	done
	# Converte em minúsculo
	echo ${sn,,}
}

# Wrapper do comando "cd" mas sem output
chd() {
	cd "$1" -> /dev/null
}