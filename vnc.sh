#!/bin/bash

if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario !! Por favor executar como super-usuario."
   exit
fi

export deuRedePrdSerah=''
function estahNaRedePRD() {
   ping -c1 -w2 10.209.218.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah='sim'
   fi

   ping -c1 -w2 10.209.192.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w2 10.209.210.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w2 10.209.160.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   tmpdeuRedePrdSerah=$(echo $deuRedePrdSerah | sed 's/simsim//')
   if [ "$deuRedePrdSerah" = "$tmpdeuRedePrdSerah" ]; then
      ping -c1 -w2 10.132.214.1 >> /dev/null 2>&1
      if [ $? -eq 0 ]; then
         if [ $(route -n | egrep "10.132.214.1[ \t]"| wc -l) -gt 0 ]; then
            export deuRedePrdSerah="simsim"
         fi
      fi
      return
   else
      export deuRedePrdSerah="simsim"
   fi
}

trocarRepositoriosSePrecisar() {
   estahNaRedePRD
   if [[ "$deuRedePrdSerah" = "simsim" ]]; then
      echo "Rede Estado, trocando repositorios daeh .."
      cd /tmp
      rm repositorios.deb 2>> /dev/null
      wget http://ubuntu.celepar.parana/repositorios.deb
      if [ -e "repositorios.deb" ]; then
         dpkg -i repositorios.deb
         sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
         sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
         apt-get  update
         if [ -e "/var/mstech/updates/" ] && [ -e "/home/ccs-client/" ] ; then
            echo 'parece um c3'
         else
            apt-get -y install  code-repo
         fi
      else
         echo "ERRO AO BAIXAR repositorios"
      fi
   else
      echo "Num tah na rede PRD"
   fi
}


if [ -e "/usr/bin/x11vnc" ]; then
   # Estah rodando serah
   vncRunning=$(ps aux | grep "/usr/bin/x11vnc" | grep -v grep | wc -l)
   if [ $vncRunning -gt 0 ]; then
      killall "/usr/bin/x11vnc"
   fi

else
   echo -e "\e[45m Nao tem x11vnc! Vamos instalar ele ebaa, soh um pouco ... \e[0m "
   sleep 2
   trocarRepositoriosSePrecisar
   apt-get update >> /tmp/.vncloginstall.txt 2>&1
   apt-get -y  install  x11vnc >> /tmp/.vncloginstall.txt 2>&1
   if [ $? -eq 0 ]; then
      ok=1
   else
      echo -e "\e[1;31m falhou ao tentar instalar x11vnc. Saindo. Pfv tentar novamente! \e[0m "
      exit 1
   fi
   echo ""
fi

#read -p "Qual a senha para o VNC: " -s SENHAVNC
echo -e -n "\e[44mQual a senha para o VNC:\e[0m "
read -s SENHAVNC
SENHAVNC=$(echo "$SENHAVNC" | sed 's/ //g')
if [ "$SENHAVNC" = "" ]; then
   echo -e "\e[1;31m Senha vazia detectada Saindo. Pfv tentar novamente! \e[0m "
   exit 1
fi
echo ""
echo ""
echo -e -n "\e[44mPor favor digitar novamente a senha do VNC:\e[0m "
read -s SENHAVNC1
echo ""
if [ "$SENHAVNC" = "$SENHAVNC1" ]; then
   ok=1
else
   echo ""
   echo -e "\e[1;31m Senhas nao conferiram. Saindo! Pfv tentar novamente! \e[0m "
   exit 1
fi

sudo x11vnc -storepasswd /root/.vncpasswd >> /dev/null 2>> /dev/null << ENDDOC
$SENHAVNC
$SENHAVNC
y
ENDDOC

echo "..."

cp /root/.vncpasswd /etc/x11vnc.pass

chmod go+r /etc/x11vnc.pass
cat > "/etc/systemd/system/vnc-server.service" << EndOfThisFileIsExactHereNowReally
[Unit]
Description=VNC Server for X11
Requires=display-manager.service
After=display-manager.service

[Service]
Type=forking
ExecStart=/usr/bin/x11vnc -auth guess -display :0 -rfbauth /etc/x11vnc.pass -forever -shared -bg -logappend /var/log/x11vnc.log
#ExecStart=/usr/bin/x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :0 -auth guess -rfbauth -rfbauth /etc/.vncpasswd
#ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EndOfThisFileIsExactHereNowReally

echo -n "ativando vnc: "
systemctl  enable  vnc-server >> /dev/null 2>&1
if [ $? -eq 0 ]; then
   echo "ativado"
else
   echo "falhou!!"
fi
systemctl stop vnc-server >> /dev/null 2>&1
systemctl start vnc-server >> /dev/null 2>&1
echo -n "iniciando o vnc: "
if [ $? -eq 0 ]; then
   echo "iniciado"
else
   echo "falhou!!"
fi

echo -e "Vnc parece tudo ok.\e[1;92m Por favor testar!\e[0m"
