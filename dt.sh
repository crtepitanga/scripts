#!/bin/bash

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí instalar o pacote samba"
   exit 1
fi

# desativar touchScreen
if [[ $(lsmod | grep hid_multitouch| wc -l) -gt 0 ]]; then
   modprobe -r hid_multitouch
fi

if [ -e /usr/share/X11/xorg.conf.d/99-no-touchscreen.conf ]; then
    echo "existia arquivo /usr/share/X11/xorg.conf.d/99-no-touchscreen.conf de conteudo "
    cat /usr/share/X11/xorg.conf.d/99-no-touchscreen.conf
    echo -e "\e[31m arquivo re-rescrito. Cuidado!! \e[0m "
else
    touch /usr/share/X11/xorg.conf.d/99-no-touchscreen.conf
fi
if [ $(grep Ignore /usr/share/X11/xorg.conf.d/99-no-touchscreen.conf | grep '"on"' | wc -l) -gt 0 ]; then
    echo "ja constam touchs desativados."
else
    echo -n "desativando touchscreen:"
    arqtmp="/tmp/.arqtmp$$"
    cat > "$arqtmp" << EndOfThisFileIsExactHere
Section "InputClass"
    Identifier         "Touchscreen catchall"
    MatchIsTouchscreen "on"

    Option "Ignore" "on"
EndSection
EndOfThisFileIsExactHere
    echo "" > /usr/share/X11/xorg.conf.d/99-no-touchscreen.conf
    cat "$arqtmp" >> /usr/share/X11/xorg.conf.d/99-no-touchscreen.conf
    echo -e "\e[44m ok \e[0m Por favor reiniciar o computador e testar!"
fi


