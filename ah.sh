#!/bin/bash

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root"
   exit 1
fi

me=`basename "$0"`
DIR=$( cd $(dirname $0) ; pwd )
me="$DIR/$me"

function remover_script_do_home() {
   # Ou remover do /tmp tambem
   tmpH=$(echo "$me" | sed 's#/home##' | sed 's#/tmp##')
   if [[ "$tmpH" = "$me" ]]; then
      return
   fi
   rm -- "$0"
   echo -e "\e[1;31mscript removido! Se precisar pfv baixar novamente\e[0m"

}


arqLogDisto="/var/tmp/run-ah-sh.log"

export deuRedePrdSerah=''
function estahNaRedePRD() {
   ping -c1 -w2 10.209.218.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah='sim'
   fi

   ping -c1 -w2 10.209.192.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w2 10.209.210.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w2 10.209.160.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   tmpdeuRedePrdSerah=$(echo $deuRedePrdSerah | sed 's/simsim//')
   if [ "$deuRedePrdSerah" = "$tmpdeuRedePrdSerah" ]; then
      return
   else
      export deuRedePrdSerah="simsim"
   fi
}


if [ -e "/etc/linuxmint/info" ]; then
   if [ -e "/usr/local/bin/ativarupdateapos23h.sh" ]; then
      echo "Mint: correcao de Path "
      jahTemPathCorreto=$(grep 'export PATH' "/usr/local/bin/ativarupdateapos23h.sh" | wc -l)
      if [ $jahTemPathCorreto -eq 0 ]; then
         sed -i 's#/bin/bash#/bin/bash\nexport PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"#' /usr/local/bin/ativarupdateapos23h.sh
      fi
      echo "ok;"
   fi

   if [ -e "/etc/ntp.conf" ]; then
      echo -n "ajuste servidores NTP "
      systemctl stop ntp
      sed -i 's/pool 0.ubuntu.pool.ntp.org iburst/pool 200.189.114.130 iburst/' /etc/ntp.conf
      sed -i 's/pool 1.ubuntu.pool.ntp.org iburst/pool 200.189.114.131 iburst/' /etc/ntp.conf
      sed -i 's/pool 2.ubuntu.pool.ntp.org iburst/pool 200.186.125.195 iburst/' /etc/ntp.conf
      echo -n "ok; "
   else
      echo "Sem NTP"
   fi
   date

   if [ -e /etc/systemd/timesyncd.conf ]; then
      sed -i 's;^#NTP=;NTP=200.189.114.130;' /etc/systemd/timesyncd.conf
      sed -i '/NTP=172.16.0.1/d' /etc/systemd/timesyncd.conf
      ##sed -i '/NTP=200.189.114.130/d' /etc/systemd/timesyncd.conf
      sed -i '/NTP=200.189.114.131/d' /etc/systemd/timesyncd.conf
      sed -i '/NTP=200.186.125.195/d' /etc/systemd/timesyncd.conf
      sed -i '/NTP=200.189.40.8/d' /etc/systemd/timesyncd.conf
      sed -i 's/NTP=200.189.114.130/NTP=200.189.114.130\nNTP=200.189.114.131\nNTP=200.186.125.195\nNTP=200.189.40.8/' /etc/systemd/timesyncd.conf

      timedatectl set-local-rtc 0
      #timedatectl set-ntp 1
      systemctl stop systemd-timesyncd >> /dev/null 2>&1
      systemctl start systemd-timesyncd >> /dev/null 2>&1
      systemctl daemon-reload
      echo "alterado no systemd no timesyncd.conf" >> "$arqLogDisto"
      echo "alterado no systemd no timesyncd.conf"
   fi

   estahNaRedePRD
   if [[ "$deuRedePrdSerah" = "simsim" ]]; then
      echo "Rede Estado, tentando acertar horário agora..."
      ntpdate 200.189.114.130
   else
      echo "Rede particular, tentando acertar horário agora..."
      ntpdate a.st1.ntp.br
      if [ $? -gt 0 ]; then
         ntpdate -u a.st1.ntp.br
         echo "adicionando no crontab via -u"
         arqCron="/tmp/.arqcrontabdover-updates$$"
         if [ -e "$arqCron" ]; then
            rm $arqCron
         fi
         crontab -l >> $arqCron
         sed -i '/a.st1.ntp.br/d' $arqCron
         echo "@hourly /usr/sbin/ntpdate -u a.st1.ntp.br" >> $arqCron
         crontab < $arqCron
         echo "agora $(date +%d/%m/%Y_%H:%M:%S_%N); "

         cat > "/usr/local/bin/arrumarhorario.sh" << EndOfThisFileIsExactHereNowReally
#!/bin/bash
if [ \$(date +%Y) -lt 2021 ]; then
   echo "agora hora ruim sendo \$(date +%d/%m/%Y_%H:%M:%S_%N)"
   date -s "\$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
   systemctl stop systemd-timesyncd
   systemctl stop ntp
   /usr/sbin/ntpdate -u a.st1.ntp.br
   systemctl start ntp
   systemctl start systemd-timesyncd
   hwclock -w
   echo "agora hora boa sendo \$(date +%d/%m/%Y_%H:%M:%S_%N)"
fi
EndOfThisFileIsExactHereNowReally
         chmod +x /usr/local/bin/arrumarhorario.sh
         /usr/local/bin/arrumarhorario.sh
         echo "e agora $(date +%d/%m/%Y_%H:%M:%S_%N); "
         echo "adicionando no crontab: "
         arqCron="/tmp/.arqcrontabdover-updates$$"
         if [ -e "$arqCron" ]; then
            rm $arqCron
         fi
         crontab -l >> $arqCron
         sed -i '/arrumarhorario.sh/d' $arqCron
         echo "*/3 *  * * * /usr/local/bin/arrumarhorario.sh >> /tmp/.arrumando-horario.txt 2>&1" >> $arqCron
         crontab < $arqCron
         echo "ok;"
         #ultimo teste pra $? abaixo dar teste valido
         ntpdate -u a.st1.ntp.br
      fi
      if [ $? -eq 0 ]; then
         echo "atualizado"
      else
         echo "falhou servidor, tentando outros servidores"
         ntpdate 200.192.232.8 200.20.186.76 c.ntp.br gps.ntp.br
         if [ ! $? -eq 0 ]; then
            echo "Falha com varios servidores, por favor tentar novamente."
            echo -e "\e[101m Falha com varios servidores,\e[0m por favor tentar novamente ou talvez abrir chamado com empresa da sua Internet."
            exit 1
         fi
      fi
   fi
   hwclock -w
   systemctl start ntp
   echo -n " hora ok; "
   date
   uptime
   echo "fim"
   exit 0
else
   echo "LE6 lets go: "

   if [ -e "/media/dados/logs/" ]; then
      arqLogDisto="/media/dados/logs/semhorariodeverao.log"
   else
      arqLogDisto="/root/semhorariodeverao.log"
   fi

   echo -n "iniciando: extr"
   echo "Iniciando extrair em um as $(date)" >> "$arqLogDisto"
   semTimeCtl=0
   if [ -e /etc/systemd/timesyncd.conf ]; then
      sed -i 's;^#NTP=;NTP=200.189.114.130;' /etc/systemd/timesyncd.conf
      sed -i '/NTP=172.16.0.1/d' /etc/systemd/timesyncd.conf
      ##sed -i '/NTP=200.189.114.130/d' /etc/systemd/timesyncd.conf
      sed -i '/NTP=200.189.114.131/d' /etc/systemd/timesyncd.conf
      sed -i '/NTP=200.186.125.195/d' /etc/systemd/timesyncd.conf
      sed -i '/NTP=200.189.40.8/d' /etc/systemd/timesyncd.conf
      sed -i 's/NTP=200.189.114.130/NTP=200.189.114.130\nNTP=200.189.114.131\nNTP=200.186.125.195\nNTP=200.189.40.8/' /etc/systemd/timesyncd.conf


      timedatectl set-local-rtc 0
      #timedatectl set-ntp 1
      systemctl stop systemd-timesyncd >> /dev/null 2>&1
      systemctl start systemd-timesyncd >> /dev/null 2>&1
      systemctl daemon-reload
      echo "alterado no systemd" >> "$arqLogDisto"
   else
      semTimeCtl=1
      echo ""
      echo -e "\e[1;31mComputador sem time no systemd, tentando NTP\e[0m "
   fi

   # Pode ter sido instalado o NTP
   if [ -e "/etc/ntp.conf" ]; then
      sed -i 's;^pool 0.ubuntu.pool.ntp.org iburst;pool 200.189.114.130 iburst;' /etc/ntp.conf
      sed -i 's;^pool 1.ubuntu.pool.ntp.org iburst;pool 200.186.125.195 iburst;' /etc/ntp.conf
      sed -i 's;^pool 2.ubuntu.pool.ntp.org iburst;pool 200.189.114.131 iburst;' /etc/ntp.conf
      sed -i 's;^pool 3.ubuntu.pool.ntp.org iburst;pool 200.189.40.8 iburst;' /etc/ntp.conf

      sed -i 's;^server 0.ubuntu.pool.ntp.org;server 200.189.114.130;' /etc/ntp.conf
      sed -i 's;^server 1.ubuntu.pool.ntp.org;server 200.186.125.195;' /etc/ntp.conf
      sed -i 's;^server 2.ubuntu.pool.ntp.org;server 200.189.114.131;' /etc/ntp.conf
      sed -i 's;^server 3.ubuntu.pool.ntp.org;server 200.189.40.8;' /etc/ntp.conf

      if [ -e "/bin/systemctl" ]; then
         systemctl stop ntp
         systemctl start ntp
      else
         /etc/init.d/ntp restart
      fi
      if [ $semTimeCtl -eq 1 ]; then
         echo -e "\e[1;31m...pode demorar uns 2 minutos pra horario sincronizar\e[0m "
      fi

      echo "alterado no NTP" >> "$arqLogDisto"
   else
      if [ $semTimeCtl -eq 1 ]; then
         echo -e "\e[1;31mComputador SEM NTP! Humm, o que fazermos? Uma opção é instalar NTP com apt-get install ntp e rodar script ah.sh novamente\e[0m "
      else
         echo "sem ntp"
      fi
   fi


   echo "finalizou as $(date)" >> "$arqLogDisto"
fi
echo "Fim em $(date)"
remover_script_do_home
