#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Run as root."
  exit
fi

pkgs="nano httpie mc wget git nc"

cat <<EOT > /etc/profile.d/my-profile.sh
alias cls='clear'
alias egrep='egrep --color=auto'
alias l='ls -alkh '
alias ll='ls -alF'

export BLOCK_SIZE=human-readable

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
EOT

yum install epel-release -y
yum install $pkgs -y

cd ~ && curl -s https://getmic.ro | bash && mv ~/micro /usr/local/bin/
wget -q https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh


read -p "Install Podman (Y/N): " install_podman

if [ $install_podman == "Y" ]; then
	yum install podman buildah -y
	yum reinstall shadow-utils
fi

read -p "Install AWSCLI (Y/N): " install_aws

if [ $install_aws == "Y" ]; then
	cd /tmp
	curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	./aws/install --update
	rm -rf /tmp/aws*
fi

read -p "Install PowerShell (Y/N): " install_pwsh

if [ $install_pwsh == "Y" ]; then
	curl -s https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/microsoft.repo
	dnf install powershell
fi

