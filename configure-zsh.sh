#!/bin/bash
set -eu

#Global variables
GREEN="\e[92m"
RED="\e[31m"
END="\e[0m"
BLUE="\e[34m"
YELLOW="\e[33m"

center() {
	termwidth="$(tput cols)"
	padding="$(printf '%0.1s' ={1..500})"
	printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

update_system() {
  printf "${GREEN}"
  center "Update System"
  printf "${END}"
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get dist-upgrade -y
  sudo apt autoremove -y
}

install_dependencies() {
  printf "${BLUE}"
  center "Install Dependencies"
  printf "${END}"
  sudo apt-get install -y wget zsh git aptitude
}

download_oh_my_zsh() {
  cd $HOME
  printf "${GREEN}"
  center "Download Oh My Zsh"
  printf "${END}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

download_zinit() {
  cd $HOME
  printf "${YELLOW}"
  center "Download Zinit Plugin Manager"
  printf "${END}"
  bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
}

configure_zsh() {
  printf "${BLUE}"
  center "Set ZSH as default"
  printf "${END}"

  sudo sed -i 's/required/sufficient/g' /etc/pam.d/chsh
  chsh -s $(which zsh) $USER

  wget https://raw.githubusercontent.com/itbrasil-odoo/linux-server-zsh/main/.zshrc -O $HOME/.zshrc
}


download_theme() {
  printf "${YELLOW}"
  center "Download spaceship theme"
  printf "${END}"

  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
  SPACESHIP_DIR="$HOME/.oh-my-zsh/custom/themes/spaceship-prompt"
  git clone https://github.com/denysdovhan/spaceship-prompt.git $SPACESHIP_DIR
  git clone https://github.com/spaceship-prompt/spaceship-vi-mode.git $ZSH_CUSTOM/plugins/spaceship-vi-mode

  if [ -d "$SPACESHIP_DIR/" ]
  then
    ln -s "$SPACESHIP_DIR/spaceship.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
    sed -i -- 's/robbyrussell/spaceship/g' ~/.zshrc
  fi
}

finish() {
  printf "${GREEN}"
  center "Process completed"
  center "Switching to ZSH and downloading settings"
  printf "${END}"

  zsh
}

main() {
  update_system
  install_dependencies
  download_oh_my_zsh
  download_zinit
  configure_zsh
  download_theme
  finish
}

main