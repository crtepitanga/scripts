#!/bin/bash

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí instalar o pacote samba"
   exit 1
fi

echo "Testando a rede, aguarde ..."

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
      ping -c1 -w2 ubuntu.celepar.parana >> /dev/null 2>&1
      if [ $? -eq 0 ]; then
         wget -q http://ubuntu.celepar.parana/repositorios.deb
         if [ $? -eq 0 ]; then
            export deuRedePrdSerah="simsim"
         fi
      fi

      return
   else
      export deuRedePrdSerah="simsim"
   fi
}

estahNaRedePRD
if [[ "$deuRedePrdSerah" = "simsim" ]]; then
   echo "Rede Estado, daeh precisamos trocar repositorios ... "
   cd /tmp
   rm repositorios.deb 2>> /dev/null
   wget http://ubuntu.celepar.parana/repositorios.deb
   if [ -e "repositorios.deb" ]; then
      dpkg -i repositorios.deb
      sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
      sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
      apt-get  update
   else
      echo "ERRO AO BAIXAR repositorios"
   fi
else
   echo "Num tah na rede PRD"
fi

# Computador eh netbook serah?
grep -q 'CPU N3350' /proc/cpuinfo
if [ $? -eq 0 ]; then
   #Netbook
   apt-get -y install inetutils-traceroute
   apt-get -y install traceroute
   apt-get -y install fping
   apt-get -y install --allow-downgrades libcurl3-gnutls=7.47.0-1ubuntu2
   apt-get -y install curl

   if [ ! -e '/usr/bin/curl' ]; then
      echo -e "\e[1;31m ERRO: falhou a instalacao do CURL, por favor tentar novamente ou um apt-get update e script novamente\e[0m"
      exit 1
   fi
fi

cd /tmp/
if [ -e MedidorEducacaoConectada-linux.run ]; then
  rm MedidorEducacaoConectada-linux.run
fi
wget http://download.simet.nic.br/medidor-educ-conectada/linux/MedidorEducacaoConectada-linux.run

chmod  +x MedidorEducacaoConectada-linux.run

./MedidorEducacaoConectada-linux.run
