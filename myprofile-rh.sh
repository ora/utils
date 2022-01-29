#!/bin/bash

packages="nano httpie wget git nc jq unzip"

if [ "$EUID" -ne 0 ]
  then echo "Run as root."
  exit
fi

if [ ! -f /etc/redhat-release ]; then
  echo "Not RH based."
  exit
fi


# Profile stuff

cat <<EOT > /etc/profile.d/my-profile.sh
alias cls='clear'
alias egrep='egrep --color=auto'
alias l='ls -alkh '
alias ll='ls -alF'
alias ..='cd ..'
alias mount='mount |column -t'
alias h='history'
alias gitp="git add -A && git commit -m \"$(whoami) - $(date)\" && git push"

export BLOCK_SIZE=human-readable

PS1='\[\e[0;38;5;49m\]\u\[\e[0;38;5;49m\]@\[\e[0;38;5;49m\]\H\[\e[0;38;5;250m\]:\[\e[0;38;5;45m\]\w\[\e[0;38;5;249m\]\$\[\e[0m\] '

#python3 -c "print('\033[2 q')"

source /etc/os-release && echo -e "\n\e[1;34m⚡ \$(whoami)@\$(hostname)  🖥️ \e[1;31m\$PRETTY_NAME  🕧 \e[1;33m\$(uptime -p)\n"
EOT


# Install packages

yum install epel-release -y
yum install $packages -y


# Install micro and nano schemes

if [ ! -f /usr/local/bin/micro ]; then
	cd ~ && curl -s https://getmic.ro | bash && mv ~/micro /usr/local/bin/
else
    echo "Skipping micro"
fi

[[ ! -e "/home/$SUDO_USER/.nanorc" ]] && sudo runuser -l $SUDO_USER -c 'wget -q https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh' || echo -e "Skipping nano\n"


# Podman installation

read -n 1 -p "Install Podman (y/n): " install_podman

if [[ $install_podman == "Y" || $install_podman == "y" ]]; then
	yum install podman buildah -y
	yum reinstall shadow-utils -y
fi


# AWSCLI installation

echo -e "\n" && read -n 1 -p "Install AWSCLI (y/n): " install_aws

if [[ $install_aws == "Y" || $install_aws == "y" ]]; then
	cd /tmp
	curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	./aws/install --update
	rm -rf /tmp/aws*
fi


# PowerShell installation

echo -e "\n" && read -n 1 -p "Install PowerShell (y/n): " install_pwsh

if [[ $install_pwsh == "Y" || $install_pwsh == "y" ]]; then
	curl -s https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/microsoft.repo
	dnf install powershell
fi

echo -e "\n"
