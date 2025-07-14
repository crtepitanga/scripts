#!/bin/bash

ARQLOG="/var/log/.log-mudanca-pagina-inicial.log"
echo "Log: executou mudanca pagina inicial e criado atalhos em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$ARQLOG"

if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario !! Por favor executar como super-usuario."
   exit
fi

if [ -e "/opt/google/chrome/google-chrome" ]; then
    echo "chrome indo pra nova pg inicial de fabrica" >> "$ARQLOG"
    sed -i 's# www.google.com.*$# https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
    sed -i 's# www.gmail.com.*$# https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
    sed -i 's#^ *exec -a "\$0" "\$HERE/chrome" "\$@"$#& https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
else
    echo "sem chrome" >> "$ARQLOG"
fi

echo "em firefox com nova pagina inicial tb ..." >> "$ARQLOG"
if [ -e "/usr/lib/firefox/defaults/pref/firefox.cfg" ]; then
    sed -i '/browser.startup.homepage/d' /usr/lib/firefox/defaults/pref/firefox.cfg 2>> /dev/null
    echo "pref(\"browser.startup.homepage\",\"https://www.educacao.pr.gov.br/iniciar\");" >> /usr/lib/firefox/defaults/pref/firefox.cfg
    echo "ok" >> "$ARQLOG"
else
    echo "sem arquivo /usr/lib/firefox/defaults/pref/firefox.cfg" >> "$ARQLOG"
fi
if [ -f "/home/framework/Área de trabalho/libreoffice7.0-calc.desktop" ]; then
    sed -i -e 's/=Exel$/=Excel/' "/home/framework/Área de trabalho/libreoffice7.0-calc.desktop"
fi


# configurar pagina inicial do firefox para essa tambem em config user
cd /home
for usuario in *; do
   if [[ "$usuario" = *"lost"* ]]; then
       #echo "Pasta lost+found nem mexeremos" >> "$ARQLOG"
       continue
   fi
   if [ ! -e "/home/${usuario}/.mozilla/firefox/" ]; then
       continue
   fi
   cd "/home/${usuario}/.mozilla/firefox"
   for diretorio in *; do
       if [ ! -e "${diretorio}/prefs.js" ]; then
           continue
       fi
       sed -i -e '/browser\.startup\.homepage/d' "/home/${usuario}/.mozilla/firefox/${diretorio}/prefs.js"
       if [ -e "/home/${usuario}/.mozilla/firefox/${diretorio}/user.js" ]; then
           sed -i -e '/browser\.startup\.homepage/d' "/home/${usuario}/.mozilla/firefox/${diretorio}/user.js"
       fi
       echo 'user_pref("browser.startup.homepage", "www.educacao.pr.gov.br/iniciar");' >> "/home/${usuario}/.mozilla/firefox/${diretorio}/prefs.js"
       echo 'user_pref("browser.startup.homepage", "www.educacao.pr.gov.br/iniciar");' >> "/home/${usuario}/.mozilla/firefox/${diretorio}/user.js"
   done
done


# Icone
arquivoNome="/tmp/.iconeplataformas.jpeg"
cat > "${arquivoNome}.b64" << EndOfThisFile
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
IQgBCEIAQhCAEIQgBCEIAQhCAEIQgD//2Q==
EndOfThisFile
base64 -d "${arquivoNome}.b64" > "$arquivoNome"
rm "${arquivoNome}.b64"
cp "${arquivoNome}" /usr/share/icons/iconeplataformas.jpeg
chmod ugo+rx /usr/share/icons/iconeplataformas.jpeg 2>> /dev/null


scriptAbrirAtalho="/usr/local/bin/abrirsiteplataformas.sh"
cat > "${scriptAbrirAtalho}" << EndOfThisFile
#!/bin/bash
site="www.educacao.pr.gov.br/iniciar"
if [ "\$(grep "^[ \t]*exec .*www.educacao.pr.gov.br/iniciar" /opt/google/chrome/google-chrome | wc -l)" -gt 0 ]; then
    site=""
fi
if [ "\$1" = "" ]; then
    /usr/bin/google-chrome-stable --password-store=basic -start-maximized \$site < /dev/null &> /dev/null & disown
else
    /usr/bin/google-chrome-stable --password-store=basic -start-maximized --incognito \$site < /dev/null &> /dev/null & disown
fi
EndOfThisFile
chmod +x "$scriptAbrirAtalho"

# Fazer atalho na area de trabalho para pagina Inicial
arquivoNome="/tmp/.modeloatalho.desktop"
cat > "${arquivoNome}" << EndOfThisFile
[Desktop Entry]
Version=1.0
Name=Plataformas Educacionais
GenericName=Plataformas Educacionais
GenericName[pt]=Plataformas Educacionais
GenericName[pt_BR]=Plataformas Educacionais
Comment=Plataformas Educacionais
Comment[pt_BR]=Plataformas Educacionais
Exec=$scriptAbrirAtalho
StartupNotify=true
Terminal=false
Icon=/usr/share/icons/iconeplataformas.jpeg
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/ftp;x-scheme-handler/http;x-scheme-handler/https;
Actions=new-window;new-private-window;
EndOfThisFile

# Abrir em modo janela privativa
atalhoEscola="/tmp/.modeloatalhoescola.desktop"
cat > "${atalhoEscola}" << EndOfThisFile
[Desktop Entry]
Version=1.0
Name=Plataformas Educacionais
GenericName=Plataformas Educacionais
GenericName[pt]=Plataformas Educacionais
GenericName[pt_BR]=Plataformas Educacionais
Comment=Plataformas Educacionais
Comment[pt_BR]=Plataformas Educacionais
Exec=$scriptAbrirAtalho escola
StartupNotify=true
Terminal=false
Icon=/usr/share/icons/iconeplataformas.jpeg
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/ftp;x-scheme-handler/http;x-scheme-handler/https;
Actions=new-window;new-private-window;
EndOfThisFile


cd /home
for usuario in * ; do
   if [[ "$usuario" = *"lost"* ]]; then
       #echo "Pasta lost+found nem mexeremos" >> "$ARQLOG"
       continue
   fi
   cd "/home/$usuario"
   if [[ ! -e 'Área de trabalho' ]]; then
       echo "sem area trabalho $usuario " >> "$ARQLOG"
       continue
   fi
   if [[ "$usuario" = "escola" ]]; then
       cp "$atalhoEscola" "/home/${usuario}/Área de trabalho/paginainicial.desktop"
    else
       cp "$arquivoNome" "/home/${usuario}/Área de trabalho/paginainicial.desktop"
   fi
   chown "$usuario":"$usuario" "/home/${usuario}/Área de trabalho/paginainicial.desktop" 2>> /dev/null
   chmod +x "/home/${usuario}/Área de trabalho/paginainicial.desktop"
   echo "Criado atalho para $usuario " >> "$ARQLOG"
   echo "Criado atalho para $usuario "
done

if [[ -e '/etc/skel/Área de trabalho' ]]; then
   echo "copiando para skel " >> "$ARQLOG"
   cp "$arquivoNome" "/etc/skel/Área de trabalho/paginainicial.desktop"
else
   echo "sem area trabalho skel " >> "$ARQLOG"
fi


# Fazer do skel e do user guest logado

# Para GUEST logados
cd /tmp
for usuario in guest*; do
   cd /tmp
   if [[ "$usuario" = *"lost"* ]]; then
       continue
   fi
   if [ ! -e "$usuario" ]; then
       continue
   fi
   cd "$usuario"
   if [[ ! -e 'Área de trabalho' ]]; then
       echo "sem area trabalho $usuario " >> "$ARQLOG"
       continue
   fi
   cp "$arquivoNome" "/tmp/${usuario}/Área de trabalho/paginainicial.desktop"
   chown "$usuario":"$usuario" "/tmp/${usuario}/Área de trabalho/paginainicial.desktop"
   chmod +x "/tmp/${usuario}/Área de trabalho/paginainicial.desktop"
done

echo "Log: fim em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$ARQLOG"
echo "fim"

