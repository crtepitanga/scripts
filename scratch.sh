#!/bin/bash

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí instalar o pacote sshpass"
   exit 1
fi

#if [ ! -e "/usr/bin/scratch-desktop" ]; then

cd /tmp/
if [ -e "scratch-desktop_3.3.0-1_amd64_2023-05-22_17-12-30.deb" ]; then
    rm "scratch-desktop_3.3.0-1_amd64_2023-05-22_17-12-30.deb"
fi
wget -c www.labmovel.seed.pr.gov.br/Updates/scratch-desktop_3.3.0-1_amd64_2023-05-22_17-12-30.deb
cat > "/tmp/.checksum-md5-scratch.md5" << EndOfThisFileIsExactHere
07374ae3366a1fb3c8bdb8927519ba77  scratch-desktop_3.3.0-1_amd64_2023-05-22_17-12-30.deb
EndOfThisFileIsExactHere

echo "Verificando md5sum dos arquivos da imagem $(date)" >> .log-md5sum-arquivos.txt
if md5sum -c "/tmp/.checksum-md5-scratch.md5" >> .log-md5sum-arquivos.txt ; then
    echo "Checou tdo ok uhuu"
else
    echo "deu erro erro no Download, saindo... Por favor testar novamente"
    exit 1
fi

addEscola=0
if [ $(grep '^escola:' /etc/passwd | wc -l) -eq 0 ]; then
   useradd -m -p saQBGXbuhKtSo escola >> /dev/null 2>&1
   echo "Criando usuario escola pra nao falhar o .deb"
   addEscola=1
fi

dpkg  -i  scratch-desktop_3.3.0-1_amd64_2023-05-22_17-12-30.deb
if [ $? -eq 0 ]; then
   echo -e "\033[0;42m Scratch instalado com sucesso! Por favor testar! \e[0m"
else
    echo -e "\033[0;41m Falhou ao instalar o Scratch.... Por favor tente novamente! \e[0m"
fi

#remover user escola se acabamos de criar
if [ $addEscola -eq 1 ]; then
   deluser escola
fi

if [ ! -e "/usr/share/applications/scratch-desktop.desktop" ]; then
   exit
fi
# copiar atalho scratch para home dos usuarios normais
cd /home
for usuario in *; do
    if [[ "$usuario" = *"lost"* ]]; then
        echo "Pasta lost+found nem mexeremos"
        continue
    fi
    if [ -d "/home/${usuario}" ]; then
        cd "/home/${usuario}/"
    else
        continue
    fi
    if [[ ! -e 'Área de Trabalho' ]]; then
        mkdir 'Área de Trabalho'
        chown "${usuario}.${usuario}" 'Área de Trabalho'
    fi
    cp "/usr/share/applications/scratch-desktop.desktop" "/home/${usuario}/Área de Trabalho/" 1>/dev/null 2>/dev/null
    chown "${usuario}:${usuario}" "/home/${usuario}/Área de Trabalho/scratch-desktop.desktop" 1>/dev/null 2>/dev/null
    chmod ugo+x  "/home/${usuario}/Área de Trabalho/scratch-desktop.desktop" 1>/dev/null 2>/dev/null
    echo "Atalho copiado para $usuario "
done
# copiar atalho para convidados no skel
if [ -e "/etc/skel/Área de Trabalho/" ]; then
    cp "/usr/share/applications/scratch-desktop.desktop" "/etc/skel/Área de Trabalho/"
    chmod ugo+x "/etc/skel/Área de Trabalho/*desktop" 1>/dev/null 2>/dev/null
    echo "Copiado atalho para Convidados"
fi

# copiar pra Convidado logado
grep '^guest-' /etc/passwd| while read x; do
   guest=$(echo "$x" | cut -d':' -f1)
   if [ -e "/tmp/$guest" ]; then
       echo "Copiando para convidado $guest"
      cp "/usr/share/applications/scratch-desktop.desktop" "/tmp/${guest}/Área de Trabalho/" 1>/dev/null 2>/dev/null
      chown "${guest}:${guest}" "/tmp/${guest}/Área de Trabalho/scratch-desktop.desktop" 1>/dev/null 2>/dev/null
      chmod +x "/tmp/${guest}/Área de Trabalho/scratch-desktop.desktop" 1>/dev/null 2>/dev/null
    fi
done
