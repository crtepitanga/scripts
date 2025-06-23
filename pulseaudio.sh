#!/bin/bash


# Configura Volume do som e do Microfone ao fazer login

if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario !! Por favor executar como super-usuario."
   exit
fi


cat > "/usr/local/bin/ajuste_volumes.sh" << EndOfThisFileIsExactHereNowReally
#!/bin/bash
# Volume em 50%
/usr/bin/pactl set-sink-volume 0 50%
# Microfones em 25%
/usr/bin/pactl set-source-volume 0 25%
/usr/bin/pactl set-source-volume 1 25%
/usr/bin/pactl load-module module-echo-cancel aec_method=webrtc sink_properties=device.description="Noise_Reduction" aec_args="analog_gain_control=0\ digital_gain_control=0"
EndOfThisFileIsExactHereNowReally
chmod +x "/usr/local/bin/ajuste_volumes.sh"


cat > "/etc/xdg/autostart/volumemic.desktop" << EndOfThisFileIsExactHereNowReally
[Desktop Entry]
Version=1.0
Type=Application
Name=Configura Volume ao fazer login
Comment=Configura Volume ao fazer login
Exec=/usr/local/bin/ajuste_volumes.sh
Icon=preferences-system-sound
Path=
Terminal=false
StartupNotify=false
EndOfThisFileIsExactHereNowReally

echo "ativado controle de volume ao fazer login: ok "
echo "ativado controle de ruídos e eco ao fazer login: ok "
echo -e "\e[1;34m Por favor sair do login e entrar novamente pra testar!\e[0m"
echo -e "\e[1;34m ou rodar comando ajuste_volumes.sh no terminal do usuário\e[0m"
