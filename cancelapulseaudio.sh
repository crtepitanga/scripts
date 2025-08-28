#!/bin/bash

# Script para desfazer configurações de volume e microfone
# Criado para reverter as alterações do script anterior

if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuário !! Por favor executar como root."
   exit 1
fi

# Caminhos dos arquivos criados pelo script original
SCRIPT_PATH="/usr/local/bin/ajuste_volumes.sh"
AUTOSTART_PATH="/etc/xdg/autostart/volumemic.desktop"

# Remove o script de ajuste de volumes, se existir
if [ -f "$SCRIPT_PATH" ]; then
    rm -f "$SCRIPT_PATH"
    echo "Removido: $SCRIPT_PATH"
else
    echo "Arquivo não encontrado: $SCRIPT_PATH"
fi

# Remove o arquivo de autostart, se existir
if [ -f "$AUTOSTART_PATH" ]; then
    rm -f "$AUTOSTART_PATH"
    echo "Removido: $AUTOSTART_PATH"
else
    echo "Arquivo não encontrado: $AUTOSTART_PATH"
fi

# Mensagem final
echo "Configuração de ajuste de volume e microfone DESFEITA com sucesso!"
echo -e "\e[1;34mReinicie a sessão para aplicar as alterações.\e[0m"
