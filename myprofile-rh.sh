#!/bin/bash

packages="nano httpie wget git jq unzip bind-utils htop hostname"
profile_config="/etc/profile.d/my-profile.sh"
trst=`tput sgr0`
tgrn=`tput setaf 2`
tyel=`tput setaf 3`
tdim=`tput dim`

if [ "$EUID" -ne 0 ]
  then echo "Run as root."
  exit
fi

# Profile stuff

echo -e "\n${tgrn}Adding profile customizations → ${tyel}$profile_config\n"

cat <<EOT > $profile_config
alias cls="clear"
alias l="ls -alkh "
alias ll="ls -alF "
alias ..="cd .."
alias ~="cd ~"
alias mount="mount | column -t"
alias h="history"
alias gitp="git add -A && git commit -m \"\$(whoami) - \$(date)\" && git push"
alias amzw="aws sts get-caller-identity | jq"

export BLOCK_SIZE=human-readable

PS1='\[\e[0;38;5;49m\]\u\[\e[0;38;5;49m\]@\[\e[0;38;5;49m\]\H\[\e[0;38;5;250m\]:\[\e[0;38;5;45m\]\w\[\e[0;38;5;249m\]\$\[\e[0m\] '

python -c "print('\033[2 q')"

source /etc/os-release && echo -e "\n\e[1;30m→ \$(whoami)@\$(hostname)  § \$PRETTY_NAME  ↑ \$(uptime -p)\e[0m\n"
EOT


if [ ! -f /etc/redhat-release ]; then
  echo "Remaining steps require a Red Hat compatbile system."
  exit
fi



# Install yum packages

read -p "${tgrn}Install Packages ${tdim}[$packages]${trst} ${tyel}[y/n]${trst} " install_packages

if [[ $install_packages == "Y" || $install_packages == "y" ]]; then
        yum install epel-release python3 -y
        yum install $packages -y
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
  dnf install curl unzip -y
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -q /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install --update
  rm -rf /tmp/awscliv2.zip /tmp/aws
fi



# PowerShell installation

read -p "${tgrn}Install PowerShell ${tyel}[y/n]${trst} " install_pwsh

if [[ $install_pwsh == "Y" || $install_pwsh == "y" ]]; then
	curl -s https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/microsoft.repo
	yum install powershell -y
fi



# Podman installation

read -p "${tgrn}Install Podman ${tyel}[y/n]${trst} " install_podman

if [[ $install_podman == "Y" || $install_podman == "y" ]]; then
        yum install podman buildah -y
        yum reinstall shadow-utils -y
fi
