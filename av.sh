#!/bin/bash

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root!"
   exit 1
fi

if [ ! -e "/etc/linuxmint/info" ]; then
    echo "Maquina Linux fora do padrao"
    exit 1
fi

LOCK='/var/run/executandoScriptAvParaAtomVsCode.lock'
PID=$(cat $LOCK 2>/dev/null)
if [ ! -z "$PID" ] && kill -0 $PID 2>/dev/null
then
   echo already running
   exit 1
fi
trap "rm -f $LOCK ; exit" INT TERM EXIT
echo $$ > $LOCK



versaoMint=$(cat /etc/linuxmint/info | grep 'RELEASE=' | cut -d'=' -f2 | head -1)
if [ "$versaoMint" = "18.3" ]; then
   if [ -e /opt/mstech/updatemanager.jar ]; then
      echo "Tentando baixar pacotes do C3 ..."
      cd /tmp
      ping -c1 -w2 -q 172.16.0.1
      if [ $? -eq 0 ]; then
         /usr/bin/wget http://172.16.0.1:65432/updates/atom-paramint183_2022-06-20_10-48-49.sh
         /usr/bin/wget http://172.16.0.1:65432/updates/vscode159-paramint183_2022-06-13_10-40-25.sh
      fi
      #mesmo q tenha vscode, baixar pra alocar traducoes pra convidado
      /usr/bin/wget -c www.labmovel.seed.pr.gov.br/Updates/vscode159-paramint183_2022-06-13_10-40-25.sh
      bash vscode159-paramint183_2022-06-13_10-40-25.sh
      /usr/bin/wget -c www.labmovel.seed.pr.gov.br/Updates/atom-paramint183_2022-06-20_10-48-49.sh
      bash atom-paramint183_2022-06-20_10-48-49.sh
      if [ $? -eq 0 ]; then
         echo "instalou ok o Atom;"
      else
         echo -e "\e[1;31m Algum erro ocorreu!\e[0m"
      fi
      exit
   fi
fi
echo "Nao é Netbook Verde! Baixando arquivo especifico entao..."
#www.labmovel.seed.pr.gov.br/Updates/atom-paramint183_2022-06-20_10-48-49.sh

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
      return
   else
      export deuRedePrdSerah="simsim"
   fi
}


#estahNaRedePRD
#if [[ "$deuRedePrdSerah" = "simsim" ]]; then
#   echo "na rede do Estado;"
#   export http_proxy=http://prdproxy.prd:8080
#else
#   echo "em rede particular;"
#fi

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
      rm /etc/apt/sources.list.d/vscode.list &> /dev/null
      apt-get  install  code-repo
      apt-get  update
   fi
fi


cd /tmp/
if [ -e "atom-vscode.sh" ]; then
   mv atom-vscode.sh atom-vscode.sh$$
fi
wget jonilso.web178.kinghost.net/atom-vscode.sh
bash atom-vscode.sh


rm $LOCK
echo ""

# ----REMOVER SCRIPT menuv01 FINALIZAR------------
if [ -e /home/administrador ]; then
   cd /home/administrador && rm menuv01
   echo -e "\e[46m============ Script menuv01 excluido, favor digitar o comando wget seulink.net/menuv01 caso precise baixar novamente ================= \e[0m "
elif [ -e /home/admin ]; then
cd /home/administrador && rm menuv01
echo -e "\e[46m============ Script menuv01 excluido, favor digitar o comando wget seulink.net/menuv01 caso precise baixar novamente ================= \e[0m "
elif [ -e /home/pedagogico ]; then
cd /home/administrador && rm menuv01
echo -e "\e[46m============ Script menuv01 excluido, favor digitar o comando wget seulink.net/menuv01 caso precise baixar novamente ================= \e[0m "

fi

# ----REMOVER SCRIPT av.sh FINALIZAR------------
cd /tmp && rm *.sh
