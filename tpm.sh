#!/bin/bash

# Tirar Proxy do Firefox e do Chrome em Linux Mint
if [ -e /usr/lib/firefox/defaults/pref/firefox.cfg ]; then
   if [ $(grep -i prd /usr/lib/firefox/defaults/pref/firefox.cfg | wc -l) -gt 0 ]; then
       sed -i -e '/network.proxy.autoconfig_url/d' /usr/lib/firefox/defaults/pref/firefox.cfg
       sed -i -e 's/"network.proxy.type",[0-9]*/"network.proxy.type",0/' /usr/lib/firefox/defaults/pref/firefox.cfg
       sed -i -e 's/lockPref/pref/' /usr/lib/firefox/defaults/pref/firefox.cfg
   fi
   sed -i '/network.proxy.type/d' /usr/lib/firefox/defaults/pref/firefox.cfg
   echo "pref(\"network.proxy.type\",0);" >> /usr/lib/firefox/defaults/pref/firefox.cfg
else
  echo "sem arquivo de proxy do firefox"
fi


if [ -e /etc/environment ]; then
    sed -i -e '/http_proxy/d' /etc/environment
    sed -i -e '/https_proxy/d' /etc/environment
    sed -i -e '/ftp_proxy/d' /etc/environment
    sed -i -e '/socks_proxy/d' /etc/environment
fi
if [ -e /etc/apt/apt.conf ]; then
    sed -i -e '/proxy/d' /etc/apt/apt.conf
    sed -i -e '/Proxy/d' /etc/apt/apt.conf
fi
updatedb
locate -i "*google-chrome*desktop" | while read arquivo; do
    #echo "Apagando proxy do arquivo $arquivo .."
    sed -i -e 's# --proxy-pac-url=[^ ]*prd[^ ]*##' "$arquivo"
done


# Tirar Proxy do Chrome da barra de ferramentas

cd /home
for usuario in *; do
   if [[ "$usuario" = *"lost"* ]]; then
       continue
   fi
   if [ ! -e "/home/${usuario}/.config/xfce4/panel" ]; then
       continue
   fi
   #echo "Alterando arquivo pasta /home/${usuario}/.config/xfce4/panel"
   sed -i -e 's# --proxy-pac-url=[^ ]*##g' /home/${usuario}/.config/xfce4/panel/launcher*/*
   find "/home/${usuario}/.config/xfce4/panel" -type f -iname "*desktop" | while read arquivo; do
       if [ "$(grep -i 'google-chrome' "$arquivo" | wc -l)" -gt 0 ]; then
          #echo "Apagando proxy do arquivo $arquivo .."
          sed -i -e 's# --proxy-pac-url=[^ ]*##' "$arquivo"
       fi
   done
done

cd /etc/skel
if [ -e "/etc/skel/.config/xfce4/panel" ]; then
   #echo "Alterando arquivo pasta /etc/skel/.config/xfce4/panel"
   sed -i -e 's# --proxy-pac-url=[^ ]*##g' /etc/skel/.config/xfce4/panel/launcher*/*
fi

# Para GUEST logados
cd /tmp
for usuario in guest*; do
   if [[ "$usuario" = *"lost"* ]]; then
       continue
   fi
   if [ ! -e "/tmp/${usuario}/.config/xfce4/panel" ]; then
       continue
   fi
   sed -i -e 's# --proxy-pac-url=[^ ]*##g' /tmp/${usuario}/.config/xfce4/panel/launcher*/*
   find "/tmp/${usuario}/.config/xfce4/panel" -type f -iname "*desktop" | while read arquivo; do
       if [ "$(grep -i 'google-chrome' "$arquivo" | wc -l)" -gt 0 ]; then
           sed -i -e 's# --proxy-pac-url=[^ ]*##g' "$arquivo"
       fi
   done
done

# remover config do Firefox feita manual
cd /home
for usuario in *; do
  if [[ "$usuario" = *"lost"* ]]; then
      continue
  fi  
  if [ ! -e "/home/${usuario}/.mozilla/firefox/" ]; then
      continue
  fi  
  find "/home/${usuario}/.mozilla/firefox/" -type f -iname "*prefs.js" | while read arquivo; do
     #echo "Apagando proxy do arquivo $arquivo .."
     sed -i -e 's#"network.proxy.type".*#"network.proxy.type", 0);#' "$arquivo"
     sed -i -e "s#'network.proxy.type'.*#'network.proxy.type', 0);#" "$arquivo"
  done
done

echo "tirado proxy ateh de icone chrome barra ferramentas"
