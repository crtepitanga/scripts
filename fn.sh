#!/bin/bash


if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute como SuperUsuário. Encerrando!"
   exit 1
fi


echo "Iniciando, aguarde ..."

################################################################################
# Desabiliar a função fn do teclado do Netbook
################################################################################
 
 echo -e "\e[43m########################### DESABILITAR A FUNÇÃO FN DO TECLADO DO NETBOOK ############################ \e[0m "
   cd /home/administrador/.config/xfce4/xfconf/xfce-perchannel-xml && sed -i 's/value="true"/value="false"/' keyboards.xml
   cat keyboards.xml
   echo -e "\e[46m============ Desabilitado a função fn do teclado do usuário administrador ================= \e[0m "

   cd /home/escola/.config/xfce4/xfconf/xfce-perchannel-xml && sed -i 's/value="true"/value="false"/' keyboards.xml
   cat keyboards.xml
   echo -e "\e[46m============ Desabilitado a função fn do teclado do usuário escola ================= \e[0m "
   cd /home/alunos/.config/xfce4/xfconf/xfce-perchannel-xml && sed -i 's/value="true"/value="false"/' keyboards.xml
   cat keyboards.xml
   echo -e "\e[46m============ Desabilitado a função fn do teclado do usuário alunos ================= \e[0m "
   cd /home/pedagogico/.config/xfce4/xfconf/xfce-perchannel-xml && sed -i 's/value="true"/value="false"/' keyboards.xml
   cat keyboards.xml
   echo -e "\e[46m============ Desabilitado a função fn do teclado do usuário pedagogico ================= \e[0m "
   cd /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml && sed -i 's/value="true"/value="false"/' keyboards.xml
   cat keyboards.xml
   echo -e "\e[46m============ Desabilitado a função fn do teclado do usuário convidado ================= \e[0m "oo
   echo ""
   echo ""
   
 echo -e "\e[43m########################### FIM DESABILITAR A FUNÇÃO FN DO TECLADO DO NETBOOK ############################ \e[0m "
 
   
   

   #cat keyboards.xml



