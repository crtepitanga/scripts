#!/bin/bash

if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario !! Por favor executar como super-usuario."
   exit
fi

cat > "/usr/sbin/apagar-guest-ao-iniciar.sh" << EndOfThisFile
#!/bin/bash
#sed -i '/^guest-/d' /etc/passwd
grep '^guest-' /etc/passwd| while read x; do
   guest=\$(echo "\$x" | cut -d':' -f1)
   if [ -e "/tmp/\$guest" ]; then
       echo "sem remover \$guest por estar logado"
    else
       #echo "remover"
       sed -i "/^\$guest/d" /etc/passwd
    fi
done
EndOfThisFile
chmod +x /usr/sbin/apagar-guest-ao-iniciar.sh

cat > "/etc/systemd/system/limpar-guest-ao-iniciar.service" << EndOfThisFile
[Unit]
Description=Remove Guest from passwd
After=rc-local.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/apagar-guest-ao-iniciar.sh

[Install]
WantedBy=basic.target
EndOfThisFile

echo -n "ativando limpar guests:"
systemctl  enable  limpar-guest-ao-iniciar >> /dev/null 2>&1
if [ $? -eq 0 ]; then
   echo "ativado"
else
   echo "falhou!!"
fi
echo ""
systemctl stop limpar-guest-ao-iniciar >> /dev/null 2>&1
systemctl start limpar-guest-ao-iniciar >> /dev/null 2>&1
echo -n "iniciando o limpar guests: "
if [ $? -eq 0 ]; then
   echo -e "\e[44m Iniciado, proximos reboot sem guest na lista.\e[0m "
else
   echo "falhou!!"
fi
