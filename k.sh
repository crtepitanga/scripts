#!/bin/bash


# Script para instalação do modo Kiosk

export arqLogDisto="/var/log/.log-install-android-studio-girafe.log"
export GREP_COLOR='0;31;42'
export NC="\033[0m"
export VERMELHO="\033[0;41m" # vermelho
export VERDE="\033[0;42m" # Verde
export AMARELO="\033[30;103m" # Amarelo

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí instalar o programas"
   exit 1
fi

wget -qO - "https://winunix.github.io/debs/winunix.asc" | sudo tee /etc/apt/trusted.gpg.d/winunix.asc

echo "deb https://winunix.github.io/debs jammy main" | sudo tee /etc/apt/sources.list.d/winunix-jammy.list

sudo apt-get update

sudo apt-get -y install kiosk-mode-xfce4

enable-kiosk-mode
