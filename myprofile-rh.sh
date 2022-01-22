#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Run as root."
  exit
fi

if [ ! -f /etc/redhat-release ]; then
  echo "Not RH based."
  exit
fi

packages="nano httpie wget git nc jq unzip"

cat <<EOT > /etc/profile.d/my-profile.sh
alias cls='clear'
alias egrep='egrep --color=auto'
alias l='ls -alkh '
alias ll='ls -alF'
alias ..='cd ..'
alias mount='mount |column -t'
alias h='history'

export BLOCK_SIZE=human-readable

PS1='\[\e[0;38;5;49m\]\u\[\e[0;38;5;49m\]@\[\e[0;38;5;49m\]\H\[\e[0;38;5;250m\]:\[\e[0;38;5;45m\]\w\[\e[0;38;5;249m\]\$\[\e[0m\] '
EOT

yum install epel-release -y
yum install $packages -y

cd ~ && curl -s https://getmic.ro | bash && mv ~/micro /usr/local/bin/

sudo runuser -l $SUDO_USER -c 'wget -q https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh'

# Podman installation

read -p "Install Podman (Y/N): " install_podman

if [[ $install_podman == "Y" || $install_podman == "y" ]]; then
	yum install podman buildah -y
	yum reinstall shadow-utils
fi


# AWSCLI installation

read -p "Install AWSCLI (Y/N): " install_aws

if [[ $install_aws == "Y" || $install_aws == "y" ]]; then
	cd /tmp
	curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	./aws/install --update
	rm -rf /tmp/aws*
fi


# PowerShell installation

read -p "Install PowerShell (Y/N): " install_pwsh

if [[ $install_pwsh == "Y" || $install_pwsh == "y" ]]; then
	curl -s https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/microsoft.repo
	dnf install powershell
fi
