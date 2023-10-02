#!/bin/bash

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí instalar o pacote sshpass"
   exit 1
fi

if [ -e /opt/mstech/updatemanager.jar ]; then
   echo "Tem Java de BM" >> /var/log/.log-tb.sh.txt
   echo "Tem Java de BM. Saindo"
   exit
fi

if [ -e "/etc/linuxmint/info" ]; then
   versaoMint=$(cat /etc/linuxmint/info | grep 'RELEASE=' | cut -d'=' -f2 | head -1)
   if [ "$versaoMint" = "18.3" ] ; then
      echo "Mint 18.3 nao testado direito" >> /var/log/.log-tb.sh.txt
      exit
   fi
fi

TIPO=$( dmidecode -t system | grep 'Product Name: ' | cut -d':' -f2 | sed -e s/'^ '// -e s/' '/'_'/g )

case "$TIPO" in
  *C1300*)
    echo "EDUCATRON ENCONTRADO AQUI"
  ;;
  *To_be_filled_by_O.E.M.*)
    echo "PROVAVEL EDUCATRON ENCONTRADO AQUI"
  ;;
   *)
    echo "Nao consta como educatron. Cuidado!"
    #exit
  ;;
esac

if [ "$(dpkg -l | grep xfce4-power-manager[^a-zA-Z-] | tail -1 | cut -c1-2)" = 'ii' ]; then 
   if [ $( upower -e | grep BAT | wc -l) -eq 0 ]; then
      # Sem bateria
      echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf.d/70-linuxmint.conf
      echo "user-session=xfce" >> /etc/lightdm/lightdm.conf.d/70-linuxmint.conf
      echo "xserver-command=X -s 0 dpms" >> /etc/lightdm/lightdm.conf.d/70-linuxmint.conf
      apt-get -y purge  xfce4-power-manager light-locker
      echo "por favor reiniciar e testar!"
   else
      echo "Detectado que tem Bateria! saindo sem fazer"
   fi

else 
   echo "jah configurado tb.sh"
fi

