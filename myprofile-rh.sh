#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Run as root."
  exit
fi

if command -v apt-get >/dev/null; then installer="sudo apt-get install -y"
elif command -v dnf >/dev/null; then installer="sudo dnf install -y"
elif command -v yum >/dev/null; then installer="sudo yum install -y"
elif command -v pacman >/dev/null; then installer="sudo pacman -S --noconfirm"
elif command -v zypper >/dev/null; then installer="sudo zypper install -y"
elif command -v apk >/dev/null; then installer="sudo apk add"
else echo "Package manager not found." && exit 1; fi

packages="nano httpie wget git jq unzip bind9-utils htop hostname bat"
profile_config="/etc/profile.d/custom_profile.sh"

trst=`tput sgr0`
tgrn=`tput setaf 2`
tyel=`tput setaf 3`
tdim=`tput dim`

# Add profile customizations

echo -e "\n${tgrn}Adding profile customizations → ${tyel}$profile_config\n"

cat <<EOT > $profile_config
alias cls="clear"
alias l="ls -alkh "
alias ll="ls -alF "
alias ..="cd .."
alias ~="cd ~"
alias mount="mount | column -t"
alias h="history"

export BLOCK_SIZE=human-readable

PS1='\[\e[0;38;5;49m\]\u\[\e[0;38;5;49m\]@\[\e[0;38;5;49m\]\H\[\e[0;38;5;250m\]:\[\e[0;38;5;45m\]\w\[\e[0;38;5;249m\]\$\[\e[0m\] '

python3 -c "print('\033[2 q')"

source /etc/os-release && echo -e "\n\e[1;30m→ \$(whoami)@\$(hostname)  § \$PRETTY_NAME  ↑ \$(uptime -p)\e[0m\n"

gitpush(){
  [ "$1" ] || { echo "Missing comment."; return 1; }
  git add . && git commit -am "$1" && git push
}

ipinfo(){
  [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] &&
  curl -s "http://ip-api.com/json/$1?fields=status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon,timezone,offset,currency,isp,org,as,asname,reverse,mobile,proxy,hosting,query" | jq ||
  echo "Invalid or missing IP."
}
EOT

# if [ ! -f /etc/redhat-release ]; then
#   echo "Remaining steps require a Red Hat compatible system."
#   exit
# fi

# Install packages

read -n1 -p "${tgrn}Install Packages ${tdim}[$packages]${trst} ${tyel}[y/N]${trst} " r; echo
if [[ $r =~ [Yy] ]]; then
    curl -sSL https://raw.githubusercontent.com/karol-broda/snitch/master/install.sh | INSTALL_DIR=/usr/bin/ sh
    (command -v dnf || command -v yum) >/dev/null && dnf install epel-release python3 -y
    $installer $packages
fi

# Install micro and nano schemes

read -p "${tgrn}Install Editors ${tyel}[y/n]${trst} " install_editors

	if [[ $install_editors == "Y" || $install_editors == "y" ]]; then
		if [ ! -f /usr/local/bin/micro ]; then
        		cd ~ && curl -s https://getmic.ro | bash && mv ~/micro /usr/local/bin/
		else
			echo "Skipping micro"
		fi
	[[ ! -e "/home/$SUDO_USER/.nanorc" ]] && sudo runuser -l $SUDO_USER -c 'wget -q https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh' || echo -e "Skipping nano schemes\n"
fi

# AWSCLI installation

read -p "${tgrn}Install AWSCLI ${tyel}[y/n]${trst} " install_aws

if [[ $install_aws == "Y" || $install_aws == "y" ]]; then
  $installer curl unzip -y
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -q /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install --update
  rm -rf /tmp/awscliv2.zip /tmp/aws
fi


# PowerShell installation

read -p "${tgrn}Install PowerShell ${tyel}[y/n]${trst} " install_pwsh

if [[ $install_pwsh == "Y" || $install_pwsh == "y" ]]; then
	curl -s https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/microsoft.repo
	$installer powershell -y
fi


# Podman installation

read -p "${tgrn}Install Podman ${tyel}[y/n]${trst} " install_podman

if [[ $install_podman == "Y" || $install_podman == "y" ]]; then
        $installer podman buildah -y
#        $installer reinstall shadow-utils -y
fi
