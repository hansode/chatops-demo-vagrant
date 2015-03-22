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

## install packages

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

## install chatops-demo-hubot-hipchat

su - ${user} -c "bash -ex" <<'EOS'
  deploy_to=${HOME}/chatops-demo-hubot-hipchat

  if ! [[ -d "${deploy_to}" ]]; then
    git clone https://github.com/hansode/chatops-demo-hubot-hipchat.git ${deploy_to}
  fi

  cd ${deploy_to}
  git checkout master
  git pull
EOS

## install chatops-demo-jenkins

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

## restart services
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
