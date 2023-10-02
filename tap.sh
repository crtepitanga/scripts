#!/bin/bash

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root"
   exit 1
fi

echo -n "ativando touch pos login: "
cat > "/etc/xdg/autostart/ativartouch.desktop" << EndOfThisFileIsExactHere
[Desktop Entry]
Version=1.0
Type=Application
Name=AtivarTouch
Comment=AtivarTouch
Exec=/usr/bin/xinput  set-prop "ELAN0415:00 04F3:316F Touchpad" 322 1
Path=
Terminal=false
StartupNotify=false
EndOfThisFileIsExactHere
chmod +x /etc/xdg/autostart/ativartouch.desktop
echo "ok"

echo -n "checando tap antes do login: "

if [ $(grep Tapping /usr/share/X11/xorg.conf.d/40-libinput.conf | wc -l) -gt 0 ]; then
    echo "ja consta ativado."
else
    echo "ativando..:"
    arqtmp="/tmp/.arqtmp$$"
    cat > "$arqtmp" << EndOfThisFileIsExactHere
Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
        Option "Tapping" "on"
EndSection
EndOfThisFileIsExactHere
    echo "" >> /usr/share/X11/xorg.conf.d/40-libinput.conf
    cat "$arqtmp" >> /usr/share/X11/xorg.conf.d/40-libinput.conf
    echo "ok"
fi

if [ -e "/etc/xdg/autostart/volume150.desktop" ]; then
   sed -i 's/Terminal=true/Terminal=false/' /etc/xdg/autostart/volume150.desktop
fi

echo -e "\e[44mPor favor reiniciar o computador e testar\e[0m "
