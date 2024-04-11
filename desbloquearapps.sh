#!/bin/bash

#-----------------------------------------Ativar acesso aos usuarios aos aplicativos desejados-----------------------------------#

USUARIOS=( "pedagogico" "professor" "escola" "Aluno" "aluno" "alunos" )
APLICATIVOS=( "/usr/bin/xfce4-appearance-settings" "/usr/bin/users-admin" "/usr/bin/mugshot" "/usr/bin/mate-about-me" "/usr/bin/mintupdate" "/usr/bin/mintinstall" "/usr/bin/nm-connection/editor" )

for USUARIO in "${USUARIOS[@]}" ; do 
   if [ $(grep "^${USUARIO}:" /etc/passwd | wc -l) -eq 0 ]; then
      echo "Usuario $USUARIO nao consta neste Linux"
      continue
   fi
   for APLICATIVO in "${APLICATIVOS[@]}" ; do
      if [ -x "$APLICATIVO" ]; then
         /bin/setfacl -b "$APLICATIVO"
      fi
   done
   echo "Aplicativos alterar usuario e senha desbloqueados para $USUARIO"
echo "Aplicativo Aparencia desbloqueado para $USUARIO"
done

#-----------------------------------------Fim Desativar acesso aos usuarios aos aplicativos desejados-----------------------------------#

