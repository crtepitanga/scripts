#!/bin/bash
# Desativar acesso aos usuarios nos aplicativos a seguir:
USUARIOS=( "professor" "escola" "Aluno" "aluno" "alunos" )
APLICATIVOS=( "/usr/bin/users-admin" "/usr/bin/mugshot" "/usr/bin/mate-about-me" )

for USUARIO in "${USUARIOS[@]}" ; do
   if [ $(grep "^${USUARIO}:" /etc/passwd | wc -l) -eq 0 ]; then
      echo "Usuario $USUARIO nao consta neste Linux"
      continue
   fi  
   for APLICATIVO in "${APLICATIVOS[@]}" ; do
      if [ -x "$APLICATIVO" ]; then
         /bin/setfacl -m u:${USUARIO}:--- "$APLICATIVO"
      fi  
   done
echo "Aplicativos bloqueados para $USUARIO"
done


