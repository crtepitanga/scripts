#!/bin/bash

# Instalacao do programa Mlink pra Mblock com auto-startup

USUARIOS=( "pedagogico" "administrador" "professor" "escola" "Aluno" "aluno" "alunos" )

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí instalar o pacote sshpass"
   exit 1
fi
if [ -e "/etc/xdg/autostart/mblock-mlink.desktop" ]; then
   echo -e "\033[0;42m Jah tem Mblok Mlink instalado! \e[0m"
else
   echo "Ainda sem Mblok Mlink Offline"
   cd /tmp/
   if [ -e "/tmp/mLink-1.2.0-amd64.deb" ]; then
      rm /tmp/mLink-1.2.0-amd64.deb
   fi
   wget -c -q https://dl.makeblock.com/mblock5/linux/mLink-1.2.0-amd64.deb
   cat > "/tmp/.checksum-md5-mlink-mblock.md5" << EndOfThisFileIsExactHere
8c06d0d2569800d1d31c4703992213e1  mLink-1.2.0-amd64.deb
EndOfThisFileIsExactHere
   echo "Verificando md5sum dos arquivos da imagem $(date)" >> .log-md5sum-arquivos.txt
   if md5sum -c "/tmp/.checksum-md5-mlink-mblock.md5" >> .log-md5sum-arquivos.txt ; then
       echo "Checou tdo ok uhuu"
   else
       echo "deu erro erro no Download, saindo... Por favor testar novamente"
       exit 1
   fi

   dpkg -i mLink-1.2.0-amd64.deb
   if [ "$?" -eq 0 ]; then
      echo "sucesso no dpkg"
   else
      echo "erro no dkpg. saindo"
      exit 1
   fi

   for usuario in "${USUARIOS[@]}" ; do
      if id "$usuario" >/dev/null 2>&1; then
         usermod -aG plugdev,dialout,tty "$usuario"
         echo "Top ok ao user: $usuario"
      #else
      #   echo "Nao existe usuario $usuario"
      fi
   done

   cat > "/etc/xdg/autostart/mblock-mlink.desktop" << EndOfThisFileIsExactHere
[Desktop Entry]
Type=Application
Exec=mblock-mlink start
Hidden=false
Name[pt_BR]=Mlink
Name=Mlink
Comment[pt_BR]=
Comment=
X-MATE-Autostart-Delay=0
Terminal=false
EndOfThisFileIsExactHere

fi


APPNAME="mBlock IDE"
EXECMD="google-chrome --app=https://ide.mblock.cc/"
ICONURL="https://ide.mblock.cc/favicon.ico"

ICON_PATH="/usr/share/pixmaps/mblock.png"
DESKTOP_FILE="/usr/share/applications/mblock.desktop"

echo "[+] Baixando ícone do mBlock..."
sudo wget -q -O "$ICON_PATH" "$ICONURL"

if [ ! -f "$ICON_PATH" ]; then
    echo "[!] Erro: não foi possível baixar o ícone!"
    exit 1
fi

echo "[+] Criando arquivo .desktop..."
sudo bash -c "cat > $DESKTOP_FILE" <<EOL
[Desktop Entry]
Name=$APPNAME
Comment=Ambiente de programação mBlock Online
Exec=$EXECMD
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Education;Development;
EOL

sudo chmod +x "$DESKTOP_FILE"

echo "[✔] Atalho criado em: $DESKTOP_FILE"
echo "[✔] Ícone salvo em: $ICON_PATH"
echo "[✔] Agora procure por 'mBlock IDE' no menu e abra direto."

# echo "Por favor reiniciar e tentar acessar site https://ide.mblock.cc/"

