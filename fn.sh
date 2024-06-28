#!/bin/bash


if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute como SuperUsuário. Encerrando!"
   exit 1
fi

me=`basename "$0"`
DIR=$( cd $(dirname $0) ; pwd )
me="$DIR/$me"


echo "Iniciando, aguarde ..."


remover_este_script() {
   # Remover se estiver no /home ou no /tmp
   tmpH=$(echo "$me" | sed 's#/home##' | sed 's#/tmp##')
   if [[ "$tmpH" = "$me" ]]; then
      return
   fi
   rm -- "$me" 2>> /dev/null
   echo -e "\e[1;31mscript removido! Se precisar pfv baixar novamente\e[0m"
}


################################################################################
# Desabiliar a função fn do teclado do Netbook
################################################################################
 
echo -e "\e[43m#################### DESABILITAR A FUNÇÃO FN DO TECLADO DO NETBOOK ###################### \e[0m "
if [ -e /home/administrador/.config/xfce4/xfconf/xfce-perchannel-xml ]; then
   cd /home/administrador/.config/xfce4/xfconf/xfce-perchannel-xml && sed -i 's/value="true"/value="false"/' keyboards.xml
   cat keyboards.xml
   echo -e "\e[46m============ Desabilitado a função fn do teclado do usuário administrador ================= \e[0m "
fi

if [ -e /home/escola/.config/xfce4/xfconf/xfce-perchannel-xml ]; then
   cd /home/escola/.config/xfce4/xfconf/xfce-perchannel-xml && sed -i 's/value="true"/value="false"/' keyboards.xml
   cat keyboards.xml
   echo -e "\e[46m============ Desabilitado a função fn do teclado do usuário escola ================= \e[0m "
fi

if [ -e /home/alunos/.config/xfce4/xfconf/xfce-perchannel-xml ]; then
   cd /home/alunos/.config/xfce4/xfconf/xfce-perchannel-xml && sed -i 's/value="true"/value="false"/' keyboards.xml
   cat keyboards.xml
   echo -e "\e[46m============ Desabilitado a função fn do teclado do usuário alunos ================= \e[0m "
fi

if [ -e /home/pedagogico/.config/xfce4/xfconf/xfce-perchannel-xml ]; then
   cd /home/pedagogico/.config/xfce4/xfconf/xfce-perchannel-xml && sed -i 's/value="true"/value="false"/' keyboards.xml
   cat keyboards.xml
   echo -e "\e[46m============ Desabilitado a função fn do teclado do usuário pedagogico ================= \e[0m "
fi


if [ -e /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml ]; then
   cd /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml && sed -i 's/value="true"/value="false"/' keyboards.xml
   cat keyboards.xml
   echo -e "\e[46m============ Desabilitado a função fn do teclado do usuário convidado ================= \e[0m "oo
fi

echo ""
echo ""
   
 echo -e "\e[43m################## FIM DESABILITAR A FUNÇÃO FN DO TECLADO DO NETBOOK ####################### \e[0m "
 
remover_este_script




