#!/bin/bash

# instalar repositorios Celepar e SSH

#if [ ! $(/usr/bin/whoami) = 'root' ]; then
if [ "$(id -u)" -ne 0 ]; then
   echo "Por favor execute com SuperUsuário root!"
   exit 1
fi

if [ ! -e "/etc/linuxmint/info" ]; then
    echo "Maquina Linux fora do padrao"
    if [ -e "/var/mstech/updates/" ]; then
       echo "c3"
    else
       if [ -e /etc/sddm.conf ]; then
         echo Wubuntu
       else
         exit 1
       fi
    fi
fi

if [[ "$1" = "-f" ]]; then
   if [ -e /etc/apt/sources.list.d/ubuntu-parana.list ]; then
      if [ ! -e /etc/apt/sources.list.d/repositorios-parana.list ]; then
         cp /etc/apt/sources.list.d/ubuntu-parana.list /etc/apt/sources.list.d/repositorios-parana.list
         sed -i -e '/ubuntu.celepar.parana\/ubuntu-celepar/d' /etc/apt/sources.list.d/repositorios-parana.list
         sed -i -e '/ubuntu.celepar.parana\/google-chrome/d' /etc/apt/sources.list.d/repositorios-parana.list
         sed -i -e 's/ubuntu.celepar.parana\/c3sl\/ubuntu/www.repositorio.pr.gov.br\/ubuntu/' /etc/apt/sources.list.d/repositorios-parana.list
         sed -i -e 's/ubuntu.celepar.parana\/c3slmint/www.repositorios.pr.gov.br\/linuxmint/' /etc/apt/sources.list.d/repositorios-parana.list
      fi

      rm /etc/apt/sources.list.d/ubuntu-parana.list
   fi
fi

export deuRedePrdSerah=''
function estahNaRedePRD() {
   echo "Checando se tem rede das escolas..."
   for ip in "${IPS[@]}" ; do
      ping -c1 -w2 "$ip" >> /dev/null 2>&1
      if [ $? -eq 0 ]; then
         export deuRedePrdSerah="sim$deuRedePrdSerah"
      fi
      if [[ "$deuRedePrdSerah" = 'simsim' ]]; then
         echo "ok"
         return
      fi
   done

   tmpdeuRedePrdSerah=$(echo $deuRedePrdSerah | sed 's/simsim//')
   if [ "$deuRedePrdSerah" = "$tmpdeuRedePrdSerah" ]; then
      ping -c1 -w2 "$IP_test_extra" >> /dev/null 2>&1
      if [ $? -eq 0 ]; then
         if [ $(route -n | egrep "${IP_test_extra}[ \t]"| wc -l) -gt 0 ]; then
            export deuRedePrdSerah="simsim"
         fi
      fi
      return
   else
      export deuRedePrdSerah="simsim"
   fi
}

ENCRYPTED_FILE="arquivo_conteudo_criptografado.gpg"
DECRYPTED_FILE="decrypted_file.txt"

SHA_GPG_undo="c3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFCZ1FDYmdaNmZGT0xXVTJCbFJQcDZT
bjREM0h5ajhMNUpaVmhjdkJSSVZnUVpBbWxzeFFCRS8yY3Bka2djbHcyMW92bjhmd3Noam5lZnVr
NmE3ZGV6eHp2d29kNmlhazdmZ3lpY3g3cnA3Ymt5aGN1d3k3ZS9NZ2RFaUhwZlJWaHZ2SG83RC96
VHc5L1Vod2FaVHFxYTVGQWZRZTlFSURzUjZSOWVxNjhkZHV1REsvSEtKclN6cUVHUCtBYng1Vzh0
eHo4NW1SSHAydFYwRGpDSzNiTERYRkVFQUNONkprTW1ZVENjN05sTFNUVE4="

cat > "${ENCRYPTED_FILE}.b64" << EndOfThisFileIsHere
jA0ECQMCm1vPgQ1O3Sfq0okBeoL0NqEUhbiQTyZ+MUUKbbML07iDL5UOeOXQsj3f9FnkXNqJlFrD
r0GUHQM9zguzPY8J1gzD6jvHcdoNntmMF+w7xh0pSMLgHS8qktfpWjLTGugLDZlQxNymFscOdYdw
gE1g3pc15/Qz9/JoOICmx0XepS0DpIthgvIl9i3WRb64iwMqM9ST2g==
EndOfThisFileIsHere

base64 -d "${ENCRYPTED_FILE}.b64" > "${ENCRYPTED_FILE}"

if [ -e "$DECRYPTED_FILE" ]; then
   rm "$DECRYPTED_FILE"
fi

gpg --batch --yes --passphrase-fd 0 --output "$DECRYPTED_FILE" "$ENCRYPTED_FILE" <<< $(echo "$SHA_GPG_undo" | base64 -d | cut -d'/' -f2) 2>> /dev/null

chmod 600 "$DECRYPTED_FILE"

export IP_test_extra=$(head -n 1 $DECRYPTED_FILE | tail -1 )
export IPS=()

while read ip; do
{
    if [[ "$ip" = "$IP_test_extra" ]]; then
       continue
    fi
    IPS+=("$ip")

} < /dev/null
done < "$DECRYPTED_FILE"

shred -u "$DECRYPTED_FILE"
shred -u "$ENCRYPTED_FILE"


estahNaRedePRD
if [[ "$deuRedePrdSerah" = "simsim" ]]; then
   echo "Rede Estado, trocando repositorios daeh .."
   cd /tmp
   rm repositorios.deb 2>> /dev/null
   wget http://ubuntu.celepar.parana/repositorios.deb
   if [ ! -e "repositorios.deb" ]; then
      wget 200.201.113.219/repositorios.deb
   fi
   if [ -e "repositorios.deb" ]; then
      for i in {1..3}; do
         dpkg -i repositorios.deb
         if [ $? -ne 0 ]; then
            echo "deu erro no instalar repositorios, testando em 3 segundos"
            sleep 3
         fi
      done
      sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
      sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
      if [ -e "/etc/apt/sources.list.d/vscode.list" ]; then
         sed -i -e 's/^deb/###deb/' "/etc/apt/sources.list.d/vscode.list" 
      fi
      apt-get  update
      #if [ -e "/var/mstech/updates/" ] && [ -e "/home/ccs-client/" ] ; then
      #   echo 'parece um c3'
      #else
      #   apt-get -y install  code-repo
      #fi
   else
      echo "ERRO AO BAIXAR repositorios"
   fi

   if [ ! -e /etc/apt/sources.list.d/repositorios-parana.list ]; then
      if [ -e /etc/apt/sources.list.d/ubuntu-parana.list ]; then
         cp /etc/apt/sources.list.d/ubuntu-parana.list /etc/apt/sources.list.d/repositorios-parana.list
         sed -i -e '/ubuntu.celepar.parana\/ubuntu-celepar/d' /etc/apt/sources.list.d/repositorios-parana.list
         sed -i -e '/ubuntu.celepar.parana\/google-chrome/d' /etc/apt/sources.list.d/repositorios-parana.list
         sed -i -e 's/ubuntu.celepar.parana\/c3sl\/ubuntu/www.repositorio.pr.gov.br\/ubuntu/' /etc/apt/sources.list.d/repositorios-parana.list
         sed -i -e 's/ubuntu.celepar.parana\/c3slmint/www.repositorios.pr.gov.br\/linuxmint/' /etc/apt/sources.list.d/repositorios-parana.list
      fi
   fi

else
   echo "Hum! Parecendo ser rede particular hein! Daeh sem usarmos repositorios ubuntu.celepar.parana por agora"
   if [ ! -e "/etc/apt/sources.list.d/google-chrome.list" ]; then
      echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list.d/google-chrome.list
   fi

   sed -i -e 's/^###deb/deb/' /etc/apt/sources.list.d/official-package-repositories.list
   if [ -e /etc/apt/sources.list.d/ubuntu-parana.list ] ; then
      rm /etc/apt/sources.list.d/ubuntu-parana.list
   fi

   if [ -e /etc/apt/sources.list.d/vscode.list ]; then
      sed -i -e 's/^##*deb/deb/' /etc/apt/sources.list.d/vscode.list
   fi
   if [ -e /etc/apt/sources.list.d/vscode_celepar.list ]; then
      rm /etc/apt/sources.list.d/vscode_celepar.list
   fi

   apt-get clean

fi

apt-get  update
if [ "$(ps aux | grep sshd | grep sbin | wc -l)" -eq 0 ]; then
   apt-get -y install ssh
fi
echo "fim"
