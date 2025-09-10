#!/bin/bash

export arqLog="/var/log/.log-desativando_google-Lens-do-Chrome.log"
echo "Desativando o google lens do Chrome em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLog"

if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario !! Por favor executar como super-usuario."
   exit
fi

LOCK='/var/run/lock-desativando-google-lens.lock'
PID=$(cat $LOCK 2>/dev/null)
if [ ! -z "$PID" ] && kill -0 $PID 2>/dev/null
then
   echo already running
   exit 1
fi
trap "rm -f $LOCK ; exit" INT TERM EXIT
echo $$ > $LOCK

if [ -e "/opt/google/chrome/google-chrome" ]; then
   sed -i 's# www.google.com.*$# --password-store=basic https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
   sed -i 's# www.gmail.com.*$# --password-store=basic https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
   sed -i 's#^ *exec -a "\$0" "\$HERE/chrome" "\$@" *$#& --password-store=basic https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
   sed -i 's# --password-store=basic --password-store=basic$# --password-store=basic#' /opt/google/chrome/google-chrome
   if [ $(grep 'password-store=basic' /opt/google/chrome/google-chrome | wc -l) -eq 0 ]; then
      sed -i 's# https://www.educacao.*$# --password-store=basic https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
   fi

   sed -i 's# --password-store=basic# --disable-features=Lens --password-store=basic#' /opt/google/chrome/google-chrome

   if [ $(grep 'LensOverlay' /opt/google/chrome/google-chrome | wc -l) -ne 0 ]; then
      echo "Desativado o Lens do Google Chrome"
   else
      echo "Eita, sem desativar o Google Lens afff"
   fi
else
   echo "sem chrome"
fi
