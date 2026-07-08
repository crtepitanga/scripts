#!/bin/bash

# Script para bloqueio definitivo do Google Lens e ferramentas de captura/upload (Chrome e Firefox)
export arqLog="/var/log/.log-bloqueio-total-lens.log"
echo "Iniciando bloqueio do Google Lens em $(date +%d/%m/%Y_%H:%M:%S)" >> "$arqLog"

# 1. Validação de Super-Usuário
if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario (root) !!"
   exit 1
fi

LOCK='/var/run/lock-desativando-google-lens.lock'
PID=$(cat $LOCK 2>/dev/null)
if [ ! -z "$PID" ] && kill -0 $PID 2>/dev/null
then
   echo already running
   exit 1
fi
trap "rm -f $LOCK ; exit" INT TERM EXIT
echo $$ > $LOCK

# ==============================================================================
# CONFIGURAÇÃO - GOOGLE CHROME
# ==============================================================================
DIR_POLICIES_CHROME="/etc/opt/chrome/policies/managed"
mkdir -p "$DIR_POLICIES_CHROME"

# Gerando o arquivo de política JSON para o Chrome
cat << EOF > "$DIR_POLICIES_CHROME/bloqueio_lens.json"
{
  "LensOverlaySettings": 1,
  "SearchByImageEnabled": false,
  "URLBlocklist": [
    "lens.google.com",
    "lens.google.com/*",
    "google.com/searchbyimage*",
    "google.com.br/searchbyimage*"
  ]
}
EOF
chmod 644 "$DIR_POLICIES_CHROME/bloqueio_lens.json"

# Bloqueio de Prints de Tela no Chrome
cat << EOF > "$DIR_POLICIES_CHROME/bloqueio_screenshots.json"
{
  "ScreenCaptureAllowed": false
}
EOF
chmod 644 "$DIR_POLICIES_CHROME/bloqueio_screenshots.json"


# ==============================================================================
# CONFIGURAÇÃO - MOZILLA FIREFOX (Nova Seção)
# ==============================================================================
# O Firefox procura políticas em /etc/firefox/policies/
DIR_POLICIES_FOX="/etc/firefox/policies"
mkdir -p "$DIR_POLICIES_FOX"

# Gerando o arquivo de políticas corporativas do Firefox
# - WebsiteFilter: Bloqueia o Lens e buscas por imagem
# - DisableFirefoxScreenshots: Desativa a ferramenta nativa de captura do Firefox
cat << EOF > "$DIR_POLICIES_FOX/policies.json"
{
  "policies": {
    "WebsiteFilter": {
      "Block": [
        "*://lens.google.com/*",
        "*://*.google.com/searchbyimage*",
        "*://*.google.com.br/searchbyimage*"
      ]
    },
    "DisableFirefoxScreenshots": true
  }
}
EOF
chmod 644 "$DIR_POLICIES_FOX/policies.json"


# ==============================================================================
# AJUSTE DO ARQUIVO /ETC/HOSTS
# ==============================================================================
# Limpa regras antigas que começavam com 0.0.0.0
sed -i '/^0.0.0.0/d' /etc/hosts

# Nota: O arquivo hosts não aceita caminhos (/) ou protocolos (https). Apenas domínios puros.
echo -e "\n0.0.0.0 lens.google.com
0.0.0.0 www.lens.google.com" >> /etc/hosts


# ==============================================================================
# FINALIZAÇÃO
# ==============================================================================
echo "Políticas aplicadas com sucesso. Google Lens e Screenshots bloqueados no Chrome e Firefox." >> "$arqLog"
echo "Por favor, reinicie ambos os navegadores para aplicar as alterações."
