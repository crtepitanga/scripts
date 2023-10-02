#!/bin/bash

echo "Executou mudanca pagina inicial em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> /var/log/.log-mudanca-pagina-inicial.log

if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario !! Por favor executar como super-usuario."
   exit
fi

if [ -e "/opt/google/chrome/google-chrome" ]; then
    echo "chrome indo pra nova pg inicial de fabrica"
    sed -i 's# www.google.com.*$# https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
    sed -i 's# www.gmail.com.*$# https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
    sed -i 's#^ *exec -a "\$0" "\$HERE/chrome" "\$@"$#& https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
else
    echo "sem chrome"
fi

echo "em firefox com nova pagina inicial tb ..."
if [ -e "/usr/bin/firefox" ]; then
   sed -i 's# www.educacao.pr.gov.br/iniciar##g' /usr/bin/firefox
   sed -i 's#^[ \t]*exec.*#& www.educacao.pr.gov.br/iniciar#g' /usr/bin/firefox
fi
if [ -e "/usr/lib/firefox/defaults/pref/firefox.cfg" ]; then
    sed -i '/browser.startup.homepage/d' /usr/lib/firefox/defaults/pref/firefox.cfg 2>> /dev/null
    echo "pref(\"browser.startup.homepage\",\"https://www.educacao.pr.gov.br/iniciar\");" >> /usr/lib/firefox/defaults/pref/firefox.cfg
    echo "ok"
else
    echo "sem arquivo /usr/lib/firefox/defaults/pref/firefox.cfg"
fi
if [ -f "/home/framework/Área de Trabalho/libreoffice7.0-calc.desktop" ]; then
    sed -i -e 's/=Exel$/=Excel/' "/home/framework/Área de Trabalho/libreoffice7.0-calc.desktop"
fi



# configurar pagina inicial do firefox para essa tambem em config user
cd /home
for usuario in *; do
   if [[ "$usuario" = *"lost"* ]]; then
       #echo "Pasta lost+found nem mexeremos"
       continue
   fi
   if [ ! -e "/home/${usuario}/.mozilla/firefox/" ]; then
       continue
   fi
   echo "Alterando arquivo pasta /home/${usuario}/.mozilla/firefox"
   cd "/home/${usuario}/.mozilla/firefox"
   for diretorio in *; do
       if [ ! -e "${diretorio}/prefs.js" ]; then
           continue
       fi
       echo "removendo do /home/${usuario}/.mozilla/firefox/${diretorio}/prefs.js"
       sed -i -e '/browser\.startup\.homepage/d' "/home/${usuario}/.mozilla/firefox/${diretorio}/prefs.js"
       if [ -e "/home/${usuario}/.mozilla/firefox/${diretorio}/user.js" ]; then
           sed -i -e '/browser\.startup\.homepage/d' "/home/${usuario}/.mozilla/firefox/${diretorio}/user.js"
       fi
       echo 'user_pref("browser.startup.homepage", "www.educacao.pr.gov.br/iniciar");' >> "/home/${usuario}/.mozilla/firefox/${diretorio}/prefs.js"
       echo 'user_pref("browser.startup.homepage", "www.educacao.pr.gov.br/iniciar");' >> "/home/${usuario}/.mozilla/firefox/${diretorio}/user.js"
   done
done



# Fazer do skel e do user guest logado

echo "fim"

