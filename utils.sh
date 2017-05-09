#!/bin/bash -i
# Resolve um caminho para o nome completo
resolvePath() {
	# Caminho
	local path="$1"
	if [[ "$OSTYPE" == *linux* ]]; then
		RETURN_PATH=$(readlink -f $path)
	elif [[ "$OSTYPE" == *darwin* ]]; then
		RETURN_PATH=$(stat -f "%N" $path)
	fi
	echo $RETURN_PATH
}

removeColor() {
	local input="$1"
	if [[ "$OSTYPE" == *linux* ]]; then
		echo "$input" | sed -r 's/\x1B\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]//g'
	elif [[ "$OSTYPE" == *darwin* ]]; then
		echo "$input" | sed -E "s/"$'\E'"\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g"
	fi
}

# Recupera o nome comercial do OS
getOSName() {
	if [[ "$OSTYPE" == *linux* ]]; then
		lsb_release -si
	elif [[ "$OSTYPE" == *darwin* ]]; then
		echo "mac"
	fi
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
	if [[ "$OSTYPE" == *linux* ]]; then
		if [[ $((which apt-get && echo "ok") | tail -n 1) == "ok" ]]; then
			cmd="sudo apt-get install"
		elif [[ $((which pacman && echo "ok") | tail -n 1) == "ok" ]]; then
			cmd="sudo pacman -S --noconfirm"
		fi
	elif [[ "$OSTYPE" == *darwin* ]]; then
		cmd="brew install"
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
		replace="true"
	fi
	CONTAINS=$(cat $BASH_RC | grep $variable)
	if [[ -z "$CONTAINS" ]]; then
		echo -e "\nexport $variable=$value" >> $BASH_RC
		if [[ "$includePath" = "true" ]]; then
			echo 'export PATH=${PATH}:$'$variable >> $BASH_RC	
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

# Resolve o nome base do caminho
resolveBasename() {
	# Caminho
	local path="$1"
	basename $(resolvePath "$path")
}

# Checks md5 sum
checkmd5sum() {
	local path="$1"
	local expectedMD5="$2"
	local calculatedMD5=$(md5sum "$path")
	calculatedMD5=${calculatedMD5:0:32}
	echo "calculatedMD5=$calculatedMD5"
	echo "expectedMD5=$expectedMD5"
	if [[ "$expectedMD5" == "$calculatedMD5" ]]; then
		echo "true"
	else
		echo "false"
	fi
}

askQuestion() {
	local question="$1"
	local required="$2"
	if [[ -z "$required" ]]; then
		required="true"
	fi
	while true; do
		read -p "$question: " answer
		if [ "$required" == "false" ] || [ -n "$answer" ]; then
			echo "$answer"
			break	
		fi
	done
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

# Lê uma senha colocando '*' para os caracteres digitados
readPassword() {
	unset PASSWORD
	unset CHARCOUNT

	stty -echo

	CHARCOUNT=0
	while IFS= read -p "$PROMPT" -r -s -n 1 CHAR
	do
	    # Enter - accept password
	    if [[ $CHAR == $'\0' ]] ; then
	        break
	    fi
	    # Backspace
	    if [[ $CHAR == $'\177' ]] ; then
	        if [ $CHARCOUNT -gt 0 ] ; then
	            CHARCOUNT=$((CHARCOUNT-1))
	            PROMPT=$'\b \b'
	            PASSWORD="${PASSWORD%?}"
	        else
	            PROMPT=''
	        fi
	    else
	        CHARCOUNT=$((CHARCOUNT+1))
	        PROMPT='*'
	        PASSWORD+="$CHAR"
	    fi
	done

	stty echo

	echo $PASSWORD
}

# Verifique se o array ($2) contém o elemento ($1)
# O 2º parâmetro deve ser o array por causa da expansão
containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

# Faz um eval dos argumentos recebidos na execução do programa utilizando getopts.
# A variável OPTS deve ter sido setada na execução do programa.
# Exemplo de variável: 
# OPTS=vf:do: 
# Nesse exemplo os flags 'v' e 'd' não aceitam argumentos (portanto são flags) enquanto 'f' e 'o' aceitam (:)
# Um programa foo que declara com o seguinte código: 
# 
# . utils.sh
# OPTS=vf:do:
# evalArgs "$@"
# echo "o: $o"
# echo "f: $f"
# echo "Flags: ${flags[@]}"
# echo "Args: ${args[@]}"
# 
# e é chamado da seguinte maneira:
# foo -v -f 1 -d -o 2 test1 test2
# Imprime:
# o: 2
# f: 1
# Flags: v d
# Args: test1 test2
evalArgs() {

 	local OPTIND
 	readopt='getopts $OPTS opt;rc=$?;[ $rc$opt == 0? ]&&exit 1;[ $rc == 0 ]||{ shift $[OPTIND-1];false; }'

 	flags=()
	flagsIdx=0

	# Enumerating options
	while eval $readopt
	do
		if [[ -n "$OPTARG" ]]; then
			eval "$opt=$OPTARG"
		else
			flags[flagsIdx]="$opt"
			flagsIdx=$((flagsIdx + 1))
		fi
	done

	args=()
	argsIdx=0

	# Enumerating arguments
	for arg
	do
		args[argsIdx]="$arg"
		argsIdx=$((argsIdx + 1))
	done
	
}
