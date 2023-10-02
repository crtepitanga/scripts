#!/bin/bash
# Atualizado: CRTE Guarapuava

#clear

echo -e "\n - - Remover acesso de alunos sem senha no LE5 - -\n"

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí remover acesso sem senha"
   exit 1
fi

sed -i -e 's/allow-guest=true/allow-guest=false/' /etc/lightdm/lightdm.conf

echo "Ok! removido com sucesso, mas ... "
echo "IMPORTANTE: reiniciar o computador pra ter efeito!"
echo ""

