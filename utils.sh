getOSName() {
	lsb_release -si	
}

getOSVersion() {
	lsb_release -sr
}

getOSArch() {
	uname -m | sed 's/x86_//;s/i[3-6]86/32/'
}

installSoft() {
	local cmd="";
	local soft="$1"
	if [[ $(getOSName) == "Ubuntu" ]]; then
		cmd="sudo apt-get install"
	elif [[ $(getOSName) == "Ubuntu" ]]; then
		cmd="sudo apt-get install"
	fi
	cmd="$cmd $soft"
	$cmd
}