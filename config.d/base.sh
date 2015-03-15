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

## install packages for jenkins/hubot

su - ${user} -c "bash -ex" <<'EOS'
  deploy_to=/var/tmp/buildbook-rhel6

  if ! [[ -d "${deploy_to}" ]]; then
    git clone https://github.com/wakameci/buildbook-rhel6.git ${deploy_to}
  fi

  cd ${deploy_to}
  git checkout master
  git pull

  addpkgs="
   jenkins.master hubot.common httpd
  "

  if [[ -n "$(echo ${addpkgs})" ]]; then
    sudo ./run-book.sh ${addpkgs}
  fi
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

usermod -s /bin/bash jenkins

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

## install rbenv for jenkins

su - jenkins -c "bash -ex" <<'EOS'
  until curl -fSkL -o /tmp/dot.rbenv.tar.gz http://dlc.wakame.axsh.jp/wakameci/kemumaki-box-rhel6/current/dot.rbenv.tar.gz; do
    sleep 1
  done
  tar zxf /tmp/dot.rbenv.tar.gz -C /var/lib/jenkins/
  rm /tmp/dot.rbenv.tar.gz
EOS

## restart jenkins service

chkconfig --list jenkins
chkconfig jenkins on
chkconfig --list jenkins

service jenkins restart

## setup httpd for local yum repository

chkconfig --list httpd
chkconfig httpd on
chkconfig --list httpd

service httpd restart
