#!/bin/bash

PROVISION_DIR="/tmp/provision"

fancy_echo() {
  echo $1
}

info() {
  fancy_echo " INFO | $1"
}

warn() {
  fancy_echo " WARN | $1"
}

function pause(){
  printf "\n%b\n" "$*"
  read -p ""
}

xcode_cli_tools() {
  xcode_status=$(xcode-select --print 2> /dev/null)
  if [ $? -gt 0 ]; then
    info "Installing command line tools"
  else
    warn "Command line tools are already installed"
    return
  fi
  xcode-select --install 2> /dev/null
  pause "Press return once the command line tools are installed."
}
ansible_deps() {
  info "Installing python dependencies"
  if [ ! -x /usr/local/bin/pip ]; then
    sudo easy_install -q pip
    sudo pip -q install virtualenv
  fi
  mkdir -p $PROVISION_DIR
  virtualenv $PROVISION_DIR
  /tmp/provision/bin/pip -q install ansible
}
ansible() {
  info "Running Ansible"
  $PROVISION_DIR/bin/ansible-playbook $PROVISION_DIR/repo/ansible/playbook.yml -e install_user=`whoami`  -i $PROVISION_DIR/repo/ansible/hosts --ask-sudo-pass
}
clone_repo() {
  git clone -q https://github.com/sthulb/laptop-osx.git $PROVISION_DIR/repo
}
main() {
  xcode_cli_tools
  clone_repo
  ansible_deps
  ansible
}
if [ $# -eq 0 ]; then
  main
fi
