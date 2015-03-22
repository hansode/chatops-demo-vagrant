#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

# Do some changes ...

user=${user:-vagrant}

## 1: install packages

su - ${user} -c "bash -ex" <<'EOS'
  addpkgs="
   hold-releasever.hold-baseurl
   jenkins.master
   hubot.common
   jenkins.plugin.rbenv
   httpd
   rpmbuild
  "

  if [[ -z "$(echo ${addpkgs})" ]]; then
    exit 0
  fi

  deploy_to=/var/tmp/buildbook-rhel6

  if ! [[ -d "${deploy_to}" ]]; then
    git clone https://github.com/wakameci/buildbook-rhel6.git ${deploy_to}
  fi

  cd ${deploy_to}
  git checkout master
  git pull

  sudo ./run-book.sh ${addpkgs}
EOS

## 2: configure jenkins

su - jenkins -c "bash -ex" <<'EOS'
  umask 077

  deploy_to=/var/tmp/chatops-demo-jenkins

  if ! [[ -d "${deploy_to}" ]]; then
    git clone https://github.com/hansode/chatops-demo-jenkins.git ${deploy_to}
  fi

  cd ${deploy_to}
  git checkout master
  git pull

  rsync -ax ${deploy_to}/.git /var/lib/jenkins
  cd /var/lib/jenkins
  git status
  git checkout .
  git status
EOS

## 3: restart services
## setup httpd for local yum repository

svcs="
 jenkins
 httpd
"

for svc in ${svcs}; do
  chkconfig --list ${svc}
  chkconfig ${svc} on
  chkconfig --list ${svc}

  service ${svc} restart
done

## 4: install custom hubot

su - ${user} -c "bash -ex" <<'EOS'
  deploy_to=${HOME}/chatops-demo-hubot-hipchat

  if ! [[ -d "${deploy_to}" ]]; then
    git clone https://github.com/hansode/chatops-demo-hubot-hipchat.git ${deploy_to}
  fi

  cd ${deploy_to}
  git checkout master
  git pull
EOS

## 5: vagrant-specific hubot integration

su - ${user} -c "bash -ex" <<'EOS'
  if [[ -d /vagrant ]]; then
    ln -fs /vagrant/dot.hubotrc ${HOME}/.hubotrc
  fi
EOS

if [[ -d /vagrant ]] && [[ -d /etc/init ]]; then
  cat <<-'EOS' > /etc/init/hubot.conf
	description Hubot

	respawn
	respawn limit 5 60

	script
	  sleep 3
	  su - vagrant -c /home/vagrant/chatops-demo-hubot-hipchat/bin/hubot-hipchat-jenkins
	end script
	EOS

  initctl stop  hubot || :
  initctl start hubot
fi
