#!/bin/bash

# Script para instalação do Arduino 2.3.2 em D3400

export arqLogDisto="/var/log/.log-install-arduino-ide-2.3.2.log"



if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí instalar o programas"
   exit 1
fi

echo "Iniciando. logs salvos no arquivo [$arqLogDisto]"
if [ -e "$arqLogDisto" ]; then
    echo "Iniciada RE-execucao as $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
else
    echo "Iniciando em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
fi

logMsg() {
   echo "$1"
   echo "$1 ($(date +%d/%m/%Y_%H:%M:%S_%N))" >> "$arqLogDisto"
}


LOCK='/var/run/installArduinoIde2.3.2.lock'
PID=$(cat $LOCK 2>/dev/null)
if [ ! -z "$PID" ] && kill -0 $PID 2>/dev/null
then
   logMsg already running
   exit 1
fi
trap "rm -f $LOCK ; exit" INT TERM EXIT
echo $$ > $LOCK

if [ -x '/usr/bin/mokutil' ]; then
   if [[ "$(mokutil --sb-state)" = "SecureBoot enabled" ]]; then
      logMsg -e "CONSTA MODO SEGURO ATIVADO. POR FAVOR DESATIVAR NA BIOS! "
      #if [ -e "$LOCK" ]; then rm -f "$LOCK"; fi
      #exit 0
   fi
fi


if [ -e "/opt/arduino-2.3.2/AppRun" ] && [ -e "/opt/arduino-ide_2.3.2_Linux_64bit.AppImage.sha256sum" ] && [ -e "/usr/share/applications/arduino232.desktop" ] && [ -e "/home/escola/.arduino15" ]; then	
   logMsg "Jah consta que tem o Arduino 2.3.3. saindo. Fim"
  if [ -e "$LOCK" ]; then rm -f "$LOCK"; 
  fi
  echo "fim"
  exit 0
fi


TIPO=$( /usr/sbin/dmidecode -t system | grep 'Product Name: ' | cut -d':' -f2 | sed -e s/'^ '// -e s/' '/'_'/g )
case "$TIPO" in
  Positivo_Duo_ZE3630)
    echo -e "\e[46mNetbook Verde Linux Mint \e[0m " >> "$arqLogDisto"
    echo -e "\e[46mNetbook Verde Linux Mint \e[0m "
    versaoMint=$(cat /etc/linuxmint/info | grep 'RELEASE=' | cut -d'=' -f2 | head -1)
    if [ "$versaoMint" = "18.3" ]; then
       if [ -e /opt/mstech/updatemanager.jar ]; then
           if [ -e "$LOCK" ]; then rm -f "$LOCK"; fi
           exit 0
       fi
    fi
  ;;
esac



baixarArquivo() {

   export arqPrograma="$1"

   export ipServer="200.201.113.219"
   export repositorioArq="http://${ipServer}/$arqPrograma"


   if [[ -x /usr/bin/lftp ]]; then
      echo "Iniciada baixar pelo LFTP as $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
      lftp -c "set net:idle 10
      set net:max-retries 0
      set net:reconnect-interval-base 3
      set net:reconnect-interval-max 3
      set ssl:verify-certificate false
      pget -n 10 -c \"${repositorioArq}\""

      logMsg "Lftp terminou de executar, vejamos ..."

      checarHash "$arqPrograma" "$repositorioArq"

   else
      logMsg "Iniciada baixar pelo WGET"
      wget --no-check-certificate --retry-connrefused --read-timeout=30 --tries=1 --waitretry=1 -q -c "${repositorioArq}"

      logMsg "Wget terminou de executar, vejamos ..."

      checarHash "$arqPrograma" "$repositorioArq"

   fi
}

checarHash() {
   arqPrograma=$1
   repositorioArq=$2

   if [ -e "$arqPrograma" ]; then
      wget --no-check-certificate --retry-connrefused --read-timeout=30 --tries=1 --waitretry=1 -q -c "${repositorioArq}.sha256sum"
      if sha256sum -c "${arqPrograma}.sha256sum" ; then
         logMsg "Checou ok o hash sha256. Descompactar entao"
         #descompactarCriarAtalhos
         return
      else
         logMsg "Falhou checagem de hash sha256. Remover e tentar novamente!"
         rm "$arqPrograma" >> "$arqLogDisto" 2>> "$arqLogDisto"
      fi
   else
      logMsg " mas nao existe arquivo $repositorioArq ."
   fi
}

removerAtalhos() {
   # remover 221 atalho
   nomeAtalho="$1"
   if [ -e "/etc/skel/Área de trabalho/$nomeAtalho" ]; then
       rm "/etc/skel/Área de trabalho/$nomeAtalho"
   fi
   cd /home
   for usuario in *; do
       if [[ "$usuario" = *"lost"* ]]; then
           #echo "Pasta lost+found nem mexeremos"
           continue
       fi
       if [ -d "/home/${usuario}" ]; then
           cd "/home/${usuario}/"
       else
           continue
       fi
       if [[ ! -e 'Área de trabalho' ]]; then
           continue
       fi

       if [ -e "/home/${usuario}/Área de trabalho/$nomeAtalho" ]; then
           rm "/home/${usuario}/Área de trabalho/$nomeAtalho" 
       fi
   done
}


copiarAtalhos() {
   nomeAtalho="$1"
   if [ "$2" = "" ]; then
      enderecoAtalho="/usr/share/applications/$nomeAtalho"
   else
      enderecoAtalho="$2"
   fi
   pastaT='Área de trabalho'
   pastat='Área de trabalho'
   echo "Copiando atalhos do $nomeAtalho"

   cd /home
   for usuario in *; do
       if [[ "$usuario" = *"lost"* ]]; then
           #echo "Pasta lost+found nem mexeremos"
           continue
       fi
       if [ -d "/home/${usuario}" ]; then
           cd "/home/${usuario}/"
       else
           continue
       fi
       if [[ ! -e 'Área de trabalho' ]]; then
           if [[ ! -e "$pastat" ]]; then
              mkdir 'Área de trabalho'
              chown "${usuario}:${usuario}" 'Área de trabalho'
           fi
       fi

       if [ ! -e "$enderecoAtalho" ]; then
           echo "Nao existe atalho pra copiar"; continue
       fi

       if [[ -e "$pastat" ]]; then
          cp "$enderecoAtalho" "/home/${usuario}/${pastat}/" 1>/dev/null 2>/dev/null
          chown "${usuario}:${usuario}" "/home/${usuario}/${pastat}/${nomeAtalho}" 1>/dev/null 2>/dev/null
          chmod ugo+x  "/home/${usuario}/${pastat}/${nomeAtalho}" 1>/dev/null 2>/dev/null
       fi
       if [[ -e "$pastaT" ]] ; then
          cp "$enderecoAtalho" "/home/${usuario}/${pastaT}/" 1>/dev/null 2>/dev/null
          chown "${usuario}:${usuario}" "/home/${usuario}/${pastaT}/${nomeAtalho}" 1>/dev/null 2>/dev/null
          chmod ugo+x  "/home/${usuario}/${pastaT}/${nomeAtalho}" 1>/dev/null 2>/dev/null
       fi

       #logMsg "Atalhos criados para usuário $usuario "

   done

   # copiar atalho para convidados no skel
   usuario="skel"
   cd /etc/skel
   if [[ -e "$pastat" ]]; then
      cp "$enderecoAtalho" "/etc/${usuario}/${pastat}/" 1>/dev/null 2>/dev/null
      chmod ugo+x  "/etc/${usuario}/${pastat}/${nomeAtalho}" 1>/dev/null 2>/dev/null
   fi
   if [[ -e "$pastaT" ]] ; then
      cp "$enderecoAtalho" "/etc/${usuario}/${pastaT}/" 1>/dev/null 2>/dev/null
      chmod ugo+x  "/etc/${usuario}/${pastaT}/${nomeAtalho}" 1>/dev/null 2>/dev/null
   fi
   #echo "Copiado para skel Convidados"
   cd - >> /dev/null 2>> /dev/null


   # copiar pra Convidado logado
   grep '^guest-' /etc/passwd| while read x; do
      guest=$(echo "$x" | cut -d':' -f1)
      if [ -e "/tmp/$guest" ]; then
         #echo "Copiando para convidado $guest"
         cp "$enderecoAtalho" "/tmp/${guest}/Área de trabalho/" 1>/dev/null 2>/dev/null
         chown "${guest}:${guest}" "/tmp/${guest}/Área de trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
         chmod +x "/tmp/${guest}/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null

         cp "$enderecoAtalho" "/tmp/${guest}/Área de trabalho/" 1>/dev/null 2>/dev/null
         chown "${guest}:${guest}" "/tmp/${guest}/Área de trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
         chmod +x "/tmp/${guest}/Área de trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
       fi
   done
}


arquivoNome="/opt/arduino-ide_2.3.2.png"

if [ -e "/opt/arduino-ide_2.3.2_Linux_64bit.AppImage" ] && [ -e "/usr/share/applications/arduino232.desktop" ]; then
   logMsg "Já tem Arduino232"
else

   cd /opt/

   baixarArquivo "arduino-ide_2.3.2_Linux_64bit.AppImage"
   baixarArquivo "config-arduino221.tar.gz"

   chmod ugo+rx /opt/arduino-ide_2.3.2_Linux_64bit.AppImage

   cat > "${arquivoNome}.b64" << EndOfThisFile
iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAAACXBIWXMAAAsSAAALEgHS3X78AAAg
AElEQVR4nO1dB3gc1fGf3eunU3dXsdy7MdXdGAjFNhDbGIxNCPWfQBKIgZhASAik0BxKCD20AAZj
UwwudGMbVyBxt7HBtqxiS27SnU7Xb/f/zdtd6SSk270tV6T3+7795HLafTs3v3nz5s2bYXieBwoK
is4Jln7vFBSdF9QAUFB0YlADQEHRiUENAAVFJwY1ABQUnRjUAFBQdGJQA0BB0YlBDQAFRScGNQAU
FJ0Y1ABQUHRiUANAQdGJYaZffsfCbZu+mW1mmZ74Ui6z5WwLy+RLL2hh2dwuNltZvBc+HgyWhznO
Lf09zPF13kh4Df45wvFHHh9z5tudXcYdCfQwUIbh1xs293aYTNOzLQK5uzsco/AN+me78lq/SWMk
CgcaGlr829FAEGr9/jZfurvDAd3sthb/1jc7G7LMph999ocGbz3+rPX7t6KRaAiH1/ij0aVPjxt9
qPN8G5kPagDSGL/ZsHl8lsU8LdtsGdvDaR/V0+HIdZrNDI7YF4nAgQYv1PoDcDQQgKPiT28kAgcb
vIa8VJ9sF7jMZuhmt0M3h5387O6wQ99sFzjNgjPpi0T4I36/u8YX2NoQCW9sDEdWPDVu9PqO8H10
RFADkEaYt+nrK3Kt1tldbbYx3Rz2boU2G2HVrno3ITuS/KDXSwjeGImk1dizzGZiIPq4XMQ4oFEY
lpdL/u9EMBg56g8cPRYMbnKHQm8/MeasxSkfMAUBNQApBM7wORbLNT2djmm9XVk9cXZHkpd7vbCz
rp4QHX9mMobn5xHDgD/LROOAXsIhb+ORIz7/Ck84/B/qIaQO1AAkGb/d+PXlhTbbTaWurDG9nA6n
LxKFnXV1sKvODV8fP05m+Y4MNABndekCw/JzYXh+PjjNJjjs8/sqvI2bTgSDz/1z7FlLOo82pB7U
ACQBSPruDvvv+2S7RhZYbZZjgQAh+9fHTsCuDJ/htWJYfh6c1bWQGIWudjucDAXDBxu822v9gYep
MTAe1AAYhJvWbSztYrc/2i/bNaWH05F1PBCEb44dhy+P1BIXn+LHwCXCOT27w5ldu0AXuw1qfP7G
/Q3ej44HAnc8N2FsBRWZ/qAGQGfM3/ztX4uynNcOzMkpxkj96ppaWENJnzDQGJzdsztM7tGd7DDs
83iqqht9ry4YfcafMuxV0hrUAOgAYba3/WNQbu5PC2xW6+56NyH9mprajH+3dMDZPboTYzA0LxdO
BkOhvW73B8cDwd9Rr0A7qAHQgJvXbRxb5nK9VJbtGsQDz649UgsfVx0GXONT6A+MEVxU3Asm9ewO
DDBceYN3b7nXe8OzE8ZupOJWB2oAVACJX+rKemlIXu4QXNu/X14B3x4/QZJzkgVGeg6TtEe2DVF9
kqlFuCQ4o0shzCgrJbGCPfXuPRXeRmoIVIAagARw07qNY0qzsl4anJc7tKKxET6pqoZ1NUcNfSby
m2GYpj9nAiSNQt0yWrsm9OgGFxYXQWlWFnxX795d0dh4w3MTxm7KEFGlHNQAKMAvCfGdhPjf1bvh
/UOVqGyGPItlGIH0kEGMlwMvGAW8OIP0bXBeLszoXUJ+CobAd8Pz1BDIghqAOLhx7fqSsmzXR4Ny
c4edCAbgzR8Owv9OnNT1GRLhpZ+dAZIhMMIgnFZYAHP794FCmx32ut27yhu8U16cNL6yk4g2YVAD
0A7u+ea/SPzzvZGI6YPyClhfq5+rj2Q3MQywHWqaVwseOB4gyvO6GoPx3bvBT8tK8fBSdK/b/dnf
zzx9SrLfLBNADUAr/Gb9pptHFOQ/ZmVZ++fVh+Gz6iO6BPck0puYzk74+EBDoJcxwGDh+UU94SdF
vSDEcYEdJ+tuf2r8mGeNfYPMAjUAIm5cu35Mv5zsN8tcrj5bT5yERQcOwolAUPN9kfBmlhVnewql
QK8gwnHEGGhFod0GV/btA6MKCzAh6+B+T8PcFyeN7/TxAaAGQMAdm75ZOCw/d3ZjOGJ6dd8PsNft
0XQ/5LrVxIKJoRXX9ECU5yAU5TTvKAzKzYFrB/aHLIs5uqvO/fajY868Kj3eMHXo1AYAZ/2BuTlL
ezmd3ZdXVMHyCm2xIpztBeLT6d4IoDeAhkCrV3BxaQlcXFoMh32+2n1uz/TO7A10WgNw+8av3xic
l3vlsUDA9Pq+/VDV2Kj6XhaWJRclfnKABiDMceRSi+KsLLh6YD/MLox+V+9e9NjYs37W4QXXBjqd
Abh+zbrRA3JylvZ0OnqsrKyClRVVqu+Fa3uHyQSU96kBqq4/GiWxArWYWloMU0uK4YjPX/O9xzP9
5bMnbO5MMuxUBuDX6zb+aWRB/r3eSMT87z37VM/6ZpYBm8kEZrrGTwtEeA6CxBCo02X0Bv5vyEDc
MoxsP1n3l6cnjP1rhxNSO+g0BuCuzd+uHZibM3HzsePw3sFD4FextYdbeVjBhhI/PYGGACssqdlC
dJjNMLNPbxjdtQvsc3u+emj0GZM6g8w6vAG4dvXas4bm53/sNJny3ys/BF8fPZbwPRhRQXDWp0h/
oDeABl6NZp/VrSvMLOsNvmi0bndd3UWvTp70dUf+yju0AfjF2vX/N7Ig/5njgaD5rR/2Q3WjL+F7
IOkxoYQu8zMLvFg6HY1BoijKcsKc/v3wpCEuCX71wqTx/+6ocuqwBuA36zY+PqIgfx7W3Hvr+/0k
WJQI0N13Wcwkuk+RucCdAm84kvCyAIO7cwb0IzULd5yse+KpCWNv64hq0CENwF2bv/1fWbbr1E8r
q+HTquqEf99hNhGXv/Mcz+nYwGNHuCTwRxL3Bi4oLoILSoqgvMG75aHRZ5zW0QTVoQzA1avWFPXL
ydnczWEvWrz/IHx77HhCv4+zfo7FAhYTnfU7IsJRDjzhcMLewBldu8AV/fpgyfbq/R7P6NfPPTvx
WSVN0WEMwNWrVhcNzM3d7jCbC17Y/R1meSX0+3aTCVwWS1PxDYqOCdR3bzgMgQSXhL2cTvjF0MHo
SZzc53aPfP3cyR3CCHQIA3DtqrUXD8rPXRTmuKzX9/4ARxIgPyPO+lYa4e9UCEWjxBtIRP97Op1w
9aD+GBdq3FvnvvLVcyctz3SZZbwBQPIPL8x/70QgaHlxz3cJrfMwky/PagWWHtXrlOA4HupDoYQy
CTE+dOOQwXjCMLzzRN3MTDcCGW0AkPxDC/LeOxkIWl76bm9C5McgX47VYuj4KDIDnlA4ocQwNAI3
DB4EBXZbePfJ+ow2AhlrAK5etebi4fn5750IBiwv79mX0Jou12olBoCCQgIaAHcopFgeGDO6fshA
LD0W3llXN/P1c8/OSCOQkQbg6lWrLx6an//eAY/H8v6BcsXkxyh/gd1GXH8KitbApcDJQFDxLgEa
gRl9y6BvTk54NzECkzPOCGScAbj6i9UXD8nPe++Ap8GCCT5KgQk9+XYbPbJLERd41LguEEzoqDEm
DPXNyQ7vqauf+fp5mWUEMsoAXPX56mlDC/Lex4Dff75T7vYj+QsddprYQ6EImDh0wh9QbATQE7hm
8EASGNx9sn7Gwp9MXpEpks4YA4DkH5Kf9/7JYGLkxzz+PJvN8PFRdDzUB4OKC8JKRqDAZkNPIGOM
QEYYgDmfreo1MC93rycUdr2293vl5LeYIZ+Sn0ID6tAIhJUbgZ8PGoC7S9599e5Bb51/7uF0l33a
GwAkf2m2ayvPQ9eXdn+XIPntho+PouOjLhhIyAjcMHQwVok6VtHgHZXuRiDtw+G9srLWW1lT13f2
H6Dkp0gJUJdQp5QAdRR1FXUWdTfdv7G09gB+89WGjd0djjEv79kLR/1+Rb/jtFhItJ+CQm/g7oAv
HFZ0124OB1w/ZBDU+v2bnpo4bmy6fhlp6wFc88XqB7s67GOWH6pIiPy4zy8116QXvfS8ULdQx5QA
dRZ1F3UYddlYtqhHWhqAuZ+tuqZPTvZd64/UwM4TJ6C5t2z7F7poBXTmpzAYghEwK9JJ1F3UYdRl
1Ol0/G7SbglwxSefnzogL3dTeYPXuvTAQUW/k0Xcfrrmp0ge6gIBaFS4HJjetw+UZbtC39e7xyy+
8Cdb0ulrSruE+GKX66OTgaD1o/IKUFLV0WIyQQElP0WSgTqHXYrCCgLTqMuzB/Szom4DQI90+q7S
aglw45drPzKzTPePD1UqKuaI5O/mdCZlbBQUrYG6Z1FQRwJ1GXUadRt1PJ0EmTYGYO5nq27v4XRe
9GXVYUVBPzzY08XhID9pqIteqbha6mB8oE6jbqOOo64bzSelSIsYwMyPPiXr/n31buunCht09nBl
gYWlVXwoUo8wF4Uar7IuUxeUlsDAvFwSD3hvygUpjwekRQygh9O5xBsOW9dUHVa07i90ODDRIhlD
o6CQBepiod0BJxR4rqjjvbKcVtR5AOifaummfAnws89WPZ1tsfRbfvCQonV/ltVCLgqKdIJSvUQd
R11HnUfdT/UrpNQAoOvfzeG4YXPtUTjuD8h+Hgt34uxPQZGOIJ6pgqAg6jrqPOo+ciCVr5LSJUA3
h31xXTBo+6a2VvazJODidKjq90ZBkSygjtZ4vbJVhVDn++Rk25ADADAgVV9QyjyAuZ9+8VSWxdL/
i0pl/fkLnA4w0VJeFGkO1FHUVSVA3UcOIBdS9VYp2QWYvuKTUb1zsjdtPXbM9m2tfLfeLKsVChUK
lYIiHXDC54dGBUVGz+jeFUZ17Ro85GkYs3TahVuTPfSUTKkFdtvLvnBYEfmxgGc+XfdTZBhQZ5UU
n0UOIBeQE6l4w6QbgBkrP52bbbWeuqqqWsFxCsH1xzwLJZ+lF73S5UKdLRBjVnIXcgE5gdxINh+T
bgC6O+1Pl3s8cKSxUVY02TYr2Gj9fooMBeou6rCcniMXkBPIjWS/aVINwOyPP3uN4yFv4+EaWbNo
ZljIpYd8KDIcqMOoy3L6jpxAbiBHkvnGSTMAUz9c2T3fZrt85/ETpDurHAqznIpyrCko0hmow6jL
ckBOIDeQI8iVZL1S0gxAns22yBeJ2HefPCn7WYz6U9efoqMAdRl1Wg7IDeQIciVZr54UAzD1wxUj
c22WyVuOHSNtmeP5QtioN59u+VF0MKBOC02o29d95AZyBLmCnEmGBJJiAHJt1n82hMKwv94t/1mH
nbr+FB0OqNOo23JAjiBXkDPJkIHhBgAtWbbFOvmbmlpFgb9sWs6booMCdVtJQBC5gpxJhhdguAHI
tlifqPX5oLLBK/vZgqwso4dDQZFSKNFx5ApyBrlj9FgNNQBk9rdaztl27LjsZzFQYlfYfIGCIlOB
Oq4kwI2cQe4Y7QUYagBcFsvjWD31qM8nmwyRp2B9REHRESDoenw+IGeQO8ghI1/ZMANw4dJlI1wW
y7nf1dXJftaB234KGy5QUGQ6UNcdCrYFkTvIIeSSUa9smM+dbbE+7g2F4WC9R/azeQ56zp+icwF1
3h+Mf1oQuTOsoJBwCQB+YoSADDkOfO67S7sXuVzl/609ascc53jIstlo8I+iU+JkYyM0BoNxX70s
JwdO794tUO31lq26bLp85ZwEYcgSwGmx3BnhOHu1Vz7yn0X791N0UijRfeQQcgk5ZYSUDFkCZFss
1+DMH+a4uJ/DtRBd+1N0Vkj6H4xzNgY5hFwqy8nB3oJ36C0q3T2AKUuX3Wxi2cLv6+plEx5y7Q4A
XILQi16d9BI4EJ8nyCXkFHJLb77q7gHYTeZrjvl84AtH4n4Oa6dZLZbMCf5JsRKeB61xEwZTnaV0
Z5r23KllixxALkTjeMvIJeSU02xBL+BZPZ+vaxAQg389spw1/6s9ChWehrifLXC5wJnO6/+2lDIa
BR6/KDJbxV/etAtMBWUYYLBclFhCutMZBCrbFvAFg3BSJl5WmpMNp3XvBjWNvh56BgN19QBsJtPv
sGPqIRny48EIO+6DptsX0loxOQ54PL2IP7ko8JEI8OEI5JhNMKRLIRTn5JALUZLb/GeEJxiEXUeb
ax5uqqwCTygIe46fADCZgbGYgTGbgWFNwLMsMKiw+BOgYxoDhbIdWpCPGXAwpriYfDzHboNhXbu2
uFWVxwOVbk/Tn6vcHth97Bg04Fo6A2WLXEBDFa+UOHJqeJcuhGMAMF+vZ+tqABxm8+WHZLb9QEz8
wRdOh76EBOI4yAxEFDMCfCQKEIkAFw7D6J7dYWxRL6KUw7p3h2y7Ms/l/P792vz33TW1sPvoUdhU
VQ0bqw+TSC+LwVBUWrMJGJNZUNhM9wzaJH2zbHs57DCmqCeMKS6CoV27wtDu3RTddnQ7/94QCMCu
mlrYWFEJm6qrYdPhI8CYLW3LVirYmQZyxe8ZOSG3JYjcKsnOvlxPA6DbEuC8d5dO7uJwfLmmsgrc
MgkO3fPywGJOg95+scSPSrNQGLhQEGYNHABjinrBhQMHKia8WlTVu+HTfd/Dkj17YE+9GxiLVZjB
0lRhZdGOQUX5DsnLgVmDBsKF/ftBUW6uocNAg/Dxd3vh0+/3w6fl5cBYrcBabcBYLES+uExIF7mG
I1Gora+P+5lcmxXOLimG437/OV9cNn21Hs/VzQBMXbpsMQNw+SqZ7r4Ws5kYgJSiLeKHQtDLaoF5
o8+ECwcMMJz07aGqvh6WbN8J73z3HVT7A2mrsG2iHYPay26DWYMGwOXDhhpO+vYgGYPH12+Cw8EA
sHYHMQjpJFc0AOFI/OD5uaUlGDhfsnL6JVfo8UzdDMD0ZSuPVXoauuw+cSLu5/KyssCVqjr/7RD/
rK6FMG/0WTCmtCQ142oHS7ZuS2uFbYKMQZ01YnjqxxiDTQfL4fENG0l/via54jJB8rRSJFOv3w/1
jfHbjA8tLISSnOzjSy+Z2jXuBxVCFwNwzjvvn51vt61eX3UYPDLdUHoVFgpr22QD16GSSxoONxH/
tjQkfmss2bIVHtuAhiCYVgpL0IZcJeJfnmbEb42NB8vh/lVfwh6PF1isRIXFaEjwMDXGFbl4WGYC
zbFaYXxxL6gLBCd/OWvGGq3P1CUIaGbYuf5wBDwya38MdCS93Ffs7IQzUzAALo6HeyeOS7uZqT1c
fuoocqEhuP/L1eBFQ+CwA5NKhe0Ach3bpww+vuE6eGnjZnji62/AG4kAi6XoLdaUGFcSDLRYwR9n
EkWOIdeQcwCg2QDo4gFcvHT5wcNeb9meE/Er/uZnZ4MzmWtrMbsMt5v4cAi4QADOL+oFj025KGVr
fK3wBALw2Jdr4OUdO4F1OonCkqAhbnXF7hoYiTbket3QIXD7uLEZLdfbl62Ez6qqgHU4UuYN+AJB
qGuIv40+pLAAerlc5cunX9xH6/M0G4BJi98dmm+37/rmSA0pYBAPPQsLk+cBiK6psB4NgisahXsn
jofLRxp2tDqp2HjgINy+8iM4HAoTQ8BgsFBSWCNlHCvXYBB6Wczw6PnnwZjepekopoRBvKw1X4HX
ZAbWbku6ccVcgCMyy4B8ux3O7NkD+TZs7RWX7dbyPM1nAcwMc3E4GpUlP0l2YFngcf/f6EsUJIf7
+IEADLLb4e3LZnQY8iPG9u0Dn9x4PfykZw+IeBrIe5L3RYIiT/WWsZiaLsg1DFzAD+f16A4f/2xu
hyE/iMutxbNnEZ2JeL0QNVqurS7kiF2mWAhyDTmH3NP6vpoNgMVkulSO/AgbGgB0OYy+xIQTwICU
3w/n9+gGS668HIb2SFqzlaQhx26Hl+bMhj9PGAucx0PeF8Ih8v4oB3LpIW/xXrjWh2AA+EYf3HvW
GfDijEsz1uWPh6E9e8KSq+fAWXm5MXINN8vVYB22KagWhJxD7ml9V+0GgGFPPekPyJ5oQqsm1yVV
84WzE8eR7D3O74eZZb3h3zOnQ3YH7zF447ix8PE1P4OscBCijT7ggsKsxYsZeJrkGiPTqN8PzlAI
Vl5xGVx/xulp8ObGAY3rO9ddA5f1LYOIx0P0iegVLn+0ylTmIh6AzIeQc8g9rQLQZAAmLFoyiQfe
KVf002RiyYknQ498irnluA3F+3wws6wUHpt2kfGakiYY2rMHfHLNz2Gw3QpRorA+QRZivr1WmXI+
Hwy22eDjubMVp+x2BDw+aybM6t+XyBT1SrNMFVzIFeSMXNFQ5B5yUIuYNRkAM8te5I9EICCTvWT4
7N965u/TGx6bNkXLq2UkivPzYMnVV8Eguw0ibg+ZsVXPWq1kOshhh8VzLofiVGdxpgBoBC4b0A8i
DUKsBQOgRnsCcnEA5BxyDzmoRSKaDICJYSY2yCT+IKwK1jSqISWioMsbCMBlnZT8EtB1ffe6a+H8
Xj2EWcvvFxJ0pBlLCaRIvxRH6dkDlsydTe7dWfHErJlwfnEviHq9wOGhHZlqV1qhhDPIPeSglkdp
SgRiGWZgvT8omKw4sJKyXwZuoXA8+VIGO51w33nnGPccEZUnTsD6vfug8uRJ2PDDAfCEw7CrpoYk
j8S+J/aCG9ajB+TYrDCsZw8Y378/DC8phhyDU6FzHHZ45eqrYN4778E73x8AkxRewjMFrMx2FiE/
T47m8n40qGVJW0p5/H7YWVkJ6/d9DzsPHyFZpXhy0k1OycWOmYfhPXtAttUK4/r2gRFFRTCsuBhK
CgsMHd8/Z10Gl73yH/jO7xdSslmTvDxVgnBGhlfIvTybbaCW56jOAxj35ttDs222XduPHoX6QPvH
GPHwT5cCg74YaaYKBiArFIKNN1xr2CyFpH/+i1WE8LuO1pJjpmTfHUlFcvQtwJha7cGTZBncMxdS
ZMmMGonA2LLeMGXYULhyzGjDjcF1ry+Ez6oOgyknhyS4QLxcgTZm/hcvm27o+JD0izZshI927IQN
eGJPg1yHde8Gs884HaaMHGmYMaiqq4PzX3wFGm12YLOyhHEalHtx/OTJuIeD8uw2GNmtGzQEg8M2
zJ2tKh9AtQGY8NbiG7IslhfXVlbF/ZzDbofcmEIZuiHG9Y82NsLiS6fBWAP2ozfs2wePrPwINpZX
CAqJl635hB5RULTW0gGdlhNV8wEZoqThphNymESDyjt71Ckw+8zTYdyAAfrLSCTYzH+/DN/hyULR
CJDZq7XCxsgT1/yDHXZ4x0C3H+X61qavYfH/thgi17GlJTD/wvMNkSsmYc16ewmYcnLljaoGuD0e
8MtssU8qKYbGcPjGdXOueEnNk1QvARiGOa1epoABGL3+xyBVMAg3DB2sO/lRQRes/Bg2VFaRdFsT
ZjGigpKDOOKpPPzSpZzxdhRAykuQDsyAlEUXDhFFXbL/ACzetRvGFBXB/PPPg3ED+uv6HuhhvPd/
N8DMV16F7/w+UmOg3Tx3UZ5DnE5YMudyQ8ifLLlurquHy1593RC5YhLWDSOGw8u79mBxS2ClceoM
5I6cAUAOWk2m0wBAlQFQ7QFMfvudLUd9vlEHZXr+FxYUkGWArohx/XsxDHzyszm6KSvOmLf853X4
eN8+YB1OIc3W7hCUVKosk0jNuXj176QCJDhrBfxkq+2K4cPgr9Mv1X1pgLnuZ/3rmbZd11ZLqU0G
LKVQrvcseRcWb93aIeTq8QfgJ888B0cYFtjsbMF70dkLQPf/xMn452v65OVCN6dz6+rZs1TlBKg2
AOcuftdb7vZkHZZp+91D7z1jyfKjq6qz64+z089ffAUaGAZMLhewzixgHPbmmQndUa1lulorblPh
jBAJunG+RnBFI/CXKRfBlaPP0uW9JOw6cgQuW7QYGi02wXUVjYC07ndFIvDO9Et03+fH2MmCTz5L
uVx7WSzw5GUzdPMGNuw/ALMWLQZTfj4xasSQ6bwMqKk9Gvf/e2W7oCw3p3HVFZe51Nxfld9yxutv
YTGCrEayBdj+bqbVakzTD150VS8o6qkb+V9Y9SVMf+7f4LVawVxQAKa8fGBzsoUvVlqbxrqkar9o
6XdFF5fc12YTZsWcbPLcRocT5i1bAde88h8yc+qFYT17wl/OngRRcT8bwjFrZ78f7hs3Wlfy49iv
ee4F+NOKj1Ir1+xsYHPz4DDPw8yXX4VFm7/W5f3G9esLF5b1JgaGyDGRrVaFEDjUPscEDkKWyMmE
ocoAmFhmHFrZxjgdTRBmo1x/UWHvP3eyLre95fWF8KdPPgNzfj5RUhaDO+gm2+wtXWW9I73iPZsV
VnDP8fk4js+qquHcfz4Fu6qrdXvkFaedCpcP6AecV0xqQTfZ74NZfXrDFTqe48ftvMkPPgwfHyxP
vVztglxN2TlkDPOWfgi3vLFQl0f9depF5GAUehrodegNOQ4hB3mSPciMU/NoVQaAATgjwnHYsyzu
50wmk/5ZUtEocOEQzBrQT5esNFSExbv3AJuXR2YJBtdzYmQXYk8vGpnJKD6DzIK4FsZIvThrVfM8
zHjxFfho+w7N7yrhn7NmwmBXFklqiTZ6YZDTAY/rmDz10ZatMP3Jp6A6HEkfuaIhwHP+KNecXFi8
a48uRqA4Px8uHzwIOL94alDnDEGTKX7xXImHyEk141cXuuQhD1t/y41eVw8g9hy6PwC/mzhe8y3/
+M57RBFwOwdnB0aanaRIdLKrF0kuLBoBHIc4a3mtNrj2rbd1c10Rr865ElzhELhCIXh1hn57/bin
//NXXoUGsyWt5MqIRoAVjYBJNAIvrNZeXHf+uZMN8wIIh2R4JnJR1WyoiqEsw4wPkgSF+OsdyQPQ
C7yYm35B7xLNs/+iTZvhhW++BVNezOwk1tnjU1ljT3q2NGuJOXBoqW9d+iH5Lz2CgyUF+XDHxPEk
+IZnCPTAok2b4JZ33iMzPuvKBsblIu532sgVx9BKpn/85HMoKSiEKRpqRaAXgLGAT2uOknJiTFPu
gvb3FTyA+CxCLjrMZlUzosopmoegAkvHsibZdEbF4PA8epSsWWcPG6rpVjsrq+CPy1YAm4URaRcp
tAmYeMKIqbz6xnFUgiHj4bGxhb1ZB259/0Py5yvHaDcCvzxb00GyFkCDeuu7HwhBPoxjxFQpgkTl
Gntirj1IsYOESNaeTD+AVcVFUKIhY3X2KSPh4/LlZGsTk5iEd9YOwiEZCFxUp5fswwwAACAASURB
VLTqgoAMe2owGv8EoOD+67QS4nFdJaR+FjvscNGQwapeVsJvFr5JtqRIQMqBM5RZzOkGI1ekiV84
JByXxSxUrXW5wJSbA7cu/QAWbdJvOaAVizZuglvffR/YvFww5eYK++KkViG6/AnKlZcaiYRIgxZS
26D1FQqS/8fPCX0EE5BtGzL1Wixw65J3NUlhyvBhkINjDwUA1IwrziW3lEYumlTWBlDlAWCIIxiJ
7wGweq/1xCKUFw1ou92WUjy/ajXsxnbLBQXAkFkqpuZbOgLXr2Iwi22a8Ri49YMPIdfp0OS66gFc
86Pbj3vhZL0vyVRNMU0xzoNG/vI+ZcK5e14ihgRBBku+/wGqcO2L8kn0+2stU56HjUePwaJvvoUr
z1QVSyOYfcoIeHHPXmHc0vElHfSKlckyRC7yKj2AhA3Aqa++Pt5psUCEi8Z10XDQuvX+kxJ/wiG4
SEMSB+5LP/L5F0JQyiEoKqRTj8J4wHFicBBnVp4HFni45f2lsLSwAIYXFaVkSLjVd8/SDwXSO7MA
pPW+GN0nSES2YhuxIosLbj8rPhHX7z8AFX4fsGxW0/o+YYgyBcxHcDhhweo1mgzAlCFD4IWt24EJ
h4HVsfktKxXTaQfIRdRh5OaWa69en9C9VYynAIeCtcnjwRRbSVXrBUKBihyTCcb1KVMxZAHPrfqy
2fWXlFXsHKvbWI26pC632FsBy4GT3QE7/HzhIl2ThZQCn3npk09Bg8lExsLGelNq5UkCvXzTDBoP
mLZMjixzIjHUPE+UKRm3wwHVoTAs+ua/qmUyrn8/yMGJD5cA0ha5DvogtxWIXBSlkHAQQ+U2oLxV
50GnJRAnnE+HKAfjevVSNVwJi/67RdiOstqF02axwalMuMQgFpAgloNE2g9HovDz1/RJakkElz7+
JDSYLGJyj0sI+OHYNH/fnKKtNKHDsFSaS+Mz8Vw/Ru9tDuIFaMG4khKAUJgcVyaBax30SpEPpdKL
TdgAMMCcHo7KC91itenHKdz+i0RgaJdCVS+JWLl1G1Q0eEl6KM78vBFJSsm4YrezMGEoywUbao/C
I598plo2iQIP9eysd5PjxYxLCPhhgg8vJfjoIAc5kKAw6JBwE5OABQ47VAVDJMdfLYb16C4UZEWd
1aMoKwhckvsQchK5meiwVXgAfJ4/Ek6eymM0FeMNkRCM19DDb+X2HcDYxHPn2HZb2gzORDMQE8nG
XQxc0iz4ah2s/+EH1fJRivX79sHzGzcC68oStvvEXZSEo/1tfM+EKj8K+sWD2KFI0hMtMjU1pw2/
tWWravmM79tHOICEHOGi2saUwCVyMuGEDlVLgKTGzKQ2VJEoKQOlFiv37Gma/RPKRpP6DKBbauSV
6EGSmFx3KbvtlveWGhoPwHtf/e+XScCPuP0xJwq1yrPFuX4l9fZimpI2/U7sPRORpyRLkoFpgw3V
h5X9XhsYUdSL1COASDjx71QD1D5G9Tagss/pA078stWeUd9ZVQWeSBRMGJlFV1UmqNL8AmJACi15
lDNst4AchcWyV7gWTXRLC8mHUWzOBVUeN9nl+NslmhvGtIk/LHkHPFiy2uVSlzkZT57SMe9QECDi
lL8VORQWITkB5OkxRkitPHkx+7KyzguVdXVQkp+v7L1igPUGyI5VJCoULUmWAVDJtoQNAM9DrqIb
61wJaFxpserfXff9D8LRU6l/npIMMklZsbAEnpqT8rz1/kKJsgpBKKyQg3dXrLQxZwdIV9toFF7Y
sg2mDB0C4/tpy5doDXT939q6DUz5BcQDaCqAoRRK5ImfCYWBcyoo2oEk8wm99BlroGUtATXylHID
iDxNsP7AQbjy9MQNAGJ8WW/Y5PESA6fHRqBSLinlZot7J/oLDMDwEEZfZXmgV2IN0+pn4qisryfk
F9o+m5pTU+NBnJFQWWtuuVmnd2kfC75aD49u3Q4s2UZLwAsgRgDjAQwwdg6YcARuee8D+N/823Ud
368XLhIKeTjFLVSzuqUUyvO9n14M4zTEcxAf/vaWuP+/oaISZn6wPDF5MlhLQDAelW6P6rG1pAaj
Dxdk+IactJvMCZ/nVhMEhFBUSXBDX+Ta1Peg23GkVlirSnvUil5T2HrkZWoe6AVS4wCfFVWxbmwR
DxAi2XruCjy8YiVUBQJkx0GofGNN/LBLrDwNODf/I4gFQxOSZ9OOgAV2Hj+u+tG5hlR6js+3kMrz
AAkbgKjBfdHau4Z1U1XwRIC0dSYqrdKtKo6cP0iCsiIwmysSFZ6pUkYkqQm9HIcDnv/mW10CglgO
/bl1G4WZP8tFEpGILFWMT5JnMjIveTFwnLA8xbqEbplEt3gY0atnSjgSVSFXdbsAiiyNnq+mEbGt
VxN+rrEdYJrFxcc8S4WMyPlWBsBsIn3tPQwLf/hgmeZhPbR8BXi4qFDDz2Yh91e/5QfiOxpvAEST
E/NnZTJkRDmSbVbNz0/g2Ro5kMQgIDaNk49u6vkV63EvNeZEJ/OT0LM0PxMTnHB9LqU5ax0XI1bq
NZmb1tJqz/UnU56gQZ68hnds/Vzd3ldudud4gZsJImEPQPEj9HQAtEoxxQ5IUsbY4uIh12qFBy6Z
pnlYd0+bCjlWi1CJScoA1SPF1WhoGRu+H6dhkHrrvsKhqFlZqVwCJB87ZcojG4ZkHRPWqTimsNUW
gV+cNkqX2v7YYuumMWOE5BYMVGoN4BlRBFSv50glxTmOGFC1wL6GyYZaTqrwAHhsSSz/OZ2Nn5Iu
RO1hOAZlVORlS3vKSYHUFENtLn1MzcQimxXunDRBt1H//qILoNhubWqNzassfNkkz2QZADXyJEeS
ozCsaxfVj67Hjszin5PlAJhVHr9POAYQ5fkdFpY9U+5zen7FvMb7lebnAYOVU8XUTJKhpSAxRMoP
/+kbb5HW45h8YkgikNkMVYGgkIuOz1QxczW1xgoE4Knp+mcCPj1jOvx04SLgxSO/CRf4jJHnPV98
CaRbZGt5ikZsRI/u8MCsmXFvd/eixbCzpvbHfflEeeIufsLybJJjGEpzspX9Tluvqkv2SmKwsCzh
ZqK/pyIVmK/nFaQ4hkNBMFvV7923xrqKStW/O6FfP+C+XAuMlCOuZFYnWWEmUuNt48l64YCHQZmA
jJi5hs/iE0kCioHQ2isIvxg2GMYZ0CR1fP9+cOWQQbBo/8Em0iWUCRgjz92+QNvyRAMQDguFWmSw
o6YWNtTUCsVdYjvyaJGnaICw8Oz4MvV1J77afwBMXYVtaz20JYLp0XJBd+EQVX2i907cACS036DH
6zc7QtjfTs26dnhRL8hhGfCGQ8BweLTSJF+0EZeQJtzvNgNjcgATtRmX190id52N2WJTAOlwTTgE
xVYz3DlBVX8IRcCg4op/PA7epiajjHIvQEae0tqbnAVQ8B2TE51ZWBhFqEVAUqJbpAMnKE+yRMRD
RVEozcqCEpWVkknuBcO3sU2aBKjYCzT0MJAua72myigs7Dh8GMb37avqNlMHDoC3yw+RWadpVArz
w4nBMBv8JbaqjKMITSclI2R9/tqVswxr5w3iQZc35s6GS998W6hMFHuuQuHZhfbkyYheDPmMWYGH
RmZ5oZsSKZPW2htRK89oFMaVqC+xtr2yChiTmaQUa253lgDU5gEkHATkeL7eqsCF1jMIKBVtWHeg
XNVLIqYNHSJ0i8XDKJgmmsCzSaEL3F838kq0mEaMu4r9/OefNgqGd++uWj5KgYeMfjnqFHIQB+VJ
OuEk+F22KU+pP6CUsSkH8T6xv9P6fmrlOUdDoVU8eEZOnJpNunY/kgNyErmZ6HgT3wUA7r+Mgiyw
CAbNdHlzMaRiMsHO2tpEh9uEqSOGQwmeDgsEyTYZ6FiyKekXJ+XVC12SLurZA+7UoVOSUuBSYLjL
BbzPT8pf6SLLpr4BCvsHtPd7ai5x3x89KdSR8RrqTu44UiM2B7G07Ieg4SJckrkBcayAS7igYeJ5
AHxMNqeMydKFF2hB0eMwW2Bdtbb91TmnjCQtnLC6cEJeQDraALFDcpHZBE9frF9fP6VYduN1kB2N
iPIMq94abEd1ZCF9Tjd5oj6EwnDnuNGa5LKuvJwYAF7qgaiXPGRfIAHhxSDxw0AcfwK/ZrllAKfj
iS/hpJsZPBwH6w+or9f2q0kThOYN0pZeEiu26IamoF8YcjgO3phxiaHr/vaAz1x29VzIjgidmsnJ
O73kqWTNrFffiRh5ltitZJJQi3X7vgc37mKYTbp2PpbjkpXUt+QJNxO9d8JBwP2//uXXg577t9BQ
IQ64iPrTVC0gCRFz0a02WLFnn+pAIAax7po8Cf6wZh3wNnvzHnKmQIqU44wb8MPr0y+B4T3Ul0nT
CkywemDyJPj1J583zSRMoiXXWoNhwBMOw/qD5WJ5bXGK45s6bZDdBw9mJmpNKorNnwgG4c7J2pKn
VmDdSYsl8bJzMpDjEivGGZCbid5bXW9Ajgczw8S19iRvXC9IlW8sFnhr1254YNpFqm9806SJ8Oa2
HbALz7e37guQzoglv98P/zrnbBhvwH5/ophz+mnkN3QxAuL23c66erjkzbeBb2wUPItYPcNdAoz+
Y0HS7Gxhu0/LwR0xf2JclwJNsz9i4bf/FY5Nmy26ZjzyMjUNCBdVnl1QNf1xwG82ycycUSz5pCOE
5A5hGbBy125NN35m5nTIwfP3pLlEcos3qsKPyD8R5oxMuPiLYUAj8PSFPwHO26BtOUAKmwjJQqTZ
SGEhSahpfeG/4/+TRpwqE6daL6We1jCpIFZs3QYe3GLGTEmLvp6lHJeQi8hJNfdWPUol5wG4aERF
yKONS8qtFDvjvLl1m9phE2Bi0APnTRYV1ifUpyOtzvRr6KjLheMRy6KTzDm/TyD/CH3Iv/CrdfDg
+0t1uVezEfColyn5joV4D5MlVDpmsdloXl7zJTUfzXIIzUdbJPoovGJlGvDBUxecCyUa282/uflr
oeo0ZjGS2V+fsvOcTBNeUMjFdn9XzS9xPL/WxDKj5ew7F44oam+sDExTB5eVB8pVV22VMOeM02H7
kRp4fvvOZtc10Tp3RkJK8hELaeKa/1/nnq0b+SuOn4C7Fr8L7mAALj7jDBhRor7oqoSm5cDHnwky
5WOWA6A0MUz8nnELjY2jYU0BtgTbucfk+6O38rexY2DqoIEJ3ODHwKpJK77bC2xBIdFPUjdBpzbz
XHPbr3ZhYhnCSTX3V9sXoN6igNgRVFwd50SiSFYLSRV98Isv1Qy9BR68ZBpcOaAfRBsaSDINF9F3
O0v11SrJxxUKwQczLtGUoNIac59/ATy4rMrJgbmvvKZbPwHiCVx0PhlzU7IQBtkSOY2pJPlKTRci
Sa4RQa6z+5TBTTJNSJXggRUfAdgdQgqz1aLb9h8vckgOyEXkpJqxqzQA3H+bPRy+3YuL6FhQUyrY
aBI65L61+zviBWjFM1fMgjkD+gHXIK5fk9zQoQUkWcas94c77bDs8hkwvndv3R5z1+J3YMfJesGl
zi+AKo6Dmxct0e3+aASWz50NxRibatAYF9ADbcj1yj5l8PQlUzXfvOLECXhzy1ahTRsaAFOCpyRl
QDgUh2MSD5GTau6vygCEotFvFOUChPSvqBvbzfWu5R/pck80Ag+ePbFtZU2WwrbakuJ9jXBln1JY
Nne2po5IrbFww0Z4dsMmYHOyyexP+vvl5MDKigp46ONPdXsObhF+9csbYUqv7sA3eNJKrk9NnqgL
+RF3LXlXCEaiAZC6I+sIOQ5JOQDISTVPZdRWaO3zr2c97kAg2xuKH6HMKdVv5iIQj4xioImrqyMz
zYR+6vICWmPdgYNw1fsfQINZOGTyo1LiRsQGJPnHKClGpZ+54FzNa9PW2FFZCVOffAY8NiuweQXA
ulxCU0w8TOT1Ald/Et68YhZM03GpgXh2/QZ4aNPXKZdridUCz1xwnm7bp+v27oOpmBNTUABsfj4w
pGS6Rdf38VQcivv/LqsVcu32hoO33Jyj5v6qw4c8z+0ykcqp8VcxURkDoQZN572dTrh56Qe6rV8n
9O0DO359E0zBDq8N4g6BeIBI15krxiVtTuwJkH3vOWUlsP3/rtWd/CijKU88BR4TS9qKN/X1QwMg
dhrGf7/5/aWwo6pa12ffPH4ckeuVZaXGyhXacPfxOaJcv7p6jm7kR3ne9OZb5Egy6iHRR51nf4E7
8fmFHEQuqn2GBgMAa80K+sFzehsAKRZAOrk6oCoUgQc/X6Xb7THFdeHsWbBs1nQYl5MNXIPnxwqr
Rmlbkx5npVCIRPdRQcfl5cK2a6+Cp6dN0T21l5Af+/ljC7GcXFLfn7T2EmdhYlDx71kuaLDYYNqL
L+veZBTf6ZmfXtK+XFs39VQq21i5So1GJeL7fTAuNweWTb9Yd7k+sHwFVPqDQpNUu0P37D8AkTsy
/EIOIhfVPkNdJqAQUd1iU3BuOxIMgAVdTZ3BiE0xwZkFz27ZBtOGDiaVf/TChD5lsLxPGazYvQee
/fZ/sL72mLjPa2kK9CTaFbepm200Qk7y4fbenEED4OYzTjXsKK9E/p1uD9lDl/r5tyjpJfYXJFFs
nocGL8DUF16Clb+4gaRP6wlJrusOlsObO3bBW3u/b9m1WbwUy7ZVl2Bp5h/frSvcNfYsQ7Il0fV/
BuMoavskKgRyRw7IQY7jt6h9huoYQNHj/+pnZtkfTvp8EIxzWIG1WiGrZy+142sfkpuH20wNDZAT
8MG6X/0SSgsK9H+W2F/wmc3fwLrDR2BnnbvlOlZBo1EQi00i6aeWlcC0fv3g4kEDDD/IM+f5F2HF
gYPN5MdgVVuzVasoOe9tgOFZTkOMQCywytPCbdthxQ8HYF31YWFsZoWyjZVrJAzD8/PgqmFDYdrA
/lCSm3CfTEXAqP+4h/4BDTYrMBhHwaQkm82Q/JHGI4fjetA2kwkKnE6IcFz/6ttu2a/mGaoNAKL0
iaeqPMFgkU9mr9JVUmLMoRuxGg5R2AYPDHc6YOX/GauwIBqDrw5VwI5jx2DH0ePgDgZhx9G2y5ZP
KC0hfQ1HdO0KE0qLYYKO23lyuOm1N+DNXbvlyS+hXSNwo+EyBdEYYHLWugqU7XFwh8JEru42KkKP
6NaNyHVCSTGM6NYVRnbvpjmbT3Z8oje1w+MhW6gMpiOjTNF70pn86NV4K+PXwXRaLJBjs1VXzPuN
6iwu1UsAEJYBO6wmtsgXim9Eov4AmJ3yPd8THwAIGWNYE87pgp0NHrhp8bvw5jU/0/9ZMUBFm2uw
smkBKuovX3sDVuxvNfObWxWp+BGE0mvkcyLfdzY0wNTnX4SVvzTeCKA3hEuECRoKchiJO5e8Czvq
3YJMnUItQkaKg+kM5IxcHMRqIqXAE64EHAtN0zIP/BolGYFRBWsZVYhZv5LeddnZsLKqGm5e/I4x
z8sASLNUE/mzY8ivxE1tkqmwM4C/v7PRR4yA3oHBTALxpnbujpGpPfHS6AlACWdIBiDwa7Q8R5sB
4OELPIssdzIw4vMZlzYr1YYjs5YDIDsb3vx+P9zUCY0Ark8vevxJ2F7vBgbXwHhcFmVitiSWOtuG
THc0+mDoQwt03yLMBCD5F+7crU2miaYA+3xxJYOcI3UAePhCiwg1GYDq22/FjMAGm1xGIK7T9SoQ
0hbamLXe6mRGAJN8xj7wcLOLmujM3xptyLTBaoMp/34Jlm/fnoQ3Sg9I5NdFpgpBqjzL8MUmZAA2
IAe1PEtzZI7n+HXYlSRevjJechZNM9oxAp3BdX368y9g7MP/AI/Zoq+itmME5ix8Gx5Y+bHer5FW
EBKnnkw6+UGa/WX4hJxD7ml9lnYDAPwHSs4jRwNJIGEbCrv++AmY8vyLHdJ1RSWd8+zz5EwEm5vX
KjKtk6L+SKY55DkPrd8IU596tkMaV/SmcCm17nBN0skPCrlCegEC/4HWZ2k2AAwwn+NaxCKzDCBx
AD7BGvI6xQRw/TrlxZdh4eaES6alLb7auw/GPvgwLD9QDgzmoeflk0M9hqxPW8kUn4PPW3fiJAx9
8BFYvl1TIDqtgIelLnryadjh9iR1zd908Zyst4xcQ84h97TKTlMegISe/3hiZyASGdYok/Zr69IV
zAZkBbaJFoUfMM/eC7zXCxf37QPPz52dlH1tI4Az7vzFS2Dhlu1CDrrLJWSj2WMO2RjVjeZHRUoC
5HQdkWu/vvDw9EuhtNCYRCyjgXL9xauvwXLMTMR+gyhXTPMl0f7kFYqJeL0QPH4s7meyrFawm827
jvxunubqMJryACTwwH9oNbHDGmU2RKO+RjBnJ8kAiO3EGMYitptigbdYYEV1NQx96BH4wzlnw68m
T07OWHQCrvUf+ORT8DAssAX5AvHRkGEqqrQlBQadrpPui7kXrFiKyyzUacSOwSjXr578F/xq9Fnw
m3MmZ5SBxVn/zveXtpSr00HyS4zc6msLyBG5xAKy/w/8h3o8TxcPoMeCx7GsyjfuQADTEuN+1oVd
V+Uac+qJ9matxkYYkZ8LD//0Epg4YEDyxqMCqKB/X/kxVDQ2CsqJM1TsrC/l0CezlJnkYYmFNWPl
Wmq3wR/OPw+uGqOtyYbRwGXU31d+RDpPtylXI72ptsBz4C2P3/4O1/65Qvr4mTXzb/tW6yN1MQAg
GIFKfyRc7JMpYGArLARLbpKz6FqdDQc8KYan8DAu4ffBhKIi+MMF56WdIWgmvk9wRR3i0VN7Emf9
eJCRa6nDQQzBJaeMTCuPoJn4VWkl17C7HoIn4vf2cFot4DBbqmrm31aixzN1MwDdFzz2DMfxN9cH
4mcw4eEgZ7EuY08crWctrFyLMxfmvTcp7E/gklNGpExhMZnnjQ0b4Y2vv4UKb2OzgjqEmnOk6GSq
Zv32ICPXHGDgZ6eNgp+NPkuX4qNqgGv8ZVu2wlOr15JzBukoV19Vpezx+Ty7HViWebZ2/u2/0uOZ
OnoAj53BA/+NJxCUXQY4iorBhCeoUoHYWYucIos0K6x0BQNwyaDBcPHwoUmZvZD0y7Zugzc2fw07
ao+SI8dNba/R3ZMUFFOeja6koxYK5Tqyaze46szTYdKA/jCi2FhjgKRfu3cfLNu+Axb+939pLddo
MAj+6qq4n0H3P8duw+j/mTXzb9fs/oOeBgDR7eFHdwYjkWFypwPN2dlg79ZNt+eqQhsKS2YvLNKB
VjgUFIpKhIIwsbQ3TOxbRpYIp5QUazYIOyqrYHtVFaz9/gdShuxQQ4PQEx+rymBdeQw+WcU/k+Ox
aUz81lAiV/wZDkFpTg5MLCuDif36wsjiIs0GAQm/rbISvtr3Paz94QdYd/CQQHqUJ6nlkL5yDRw9
CpGGhrifwdN/NrN519Hf36FbVxhdDUDXhx+9E3j+YbllALpZztLe6dGXL1Zhm6rKNBfsaKm0WDY8
SoIwI3v2gN55eVCal0vaMvUuLIDSwsIWt95eWQlubKHNMLC9uhoq3B7YXlMj1L1HxUOXEwuMkHJS
WJrL3FymC/9uMjW7pJDmxG+N9uQqGgRs0U56/2FzDowboWyjURjZszs55juyRw8h2MXzMLKkBHKd
zUYXPaZDx08QeRyqq4MKtxsq6t1wqL6+qbuQINtmY0r+bklPuaJ8fBWHBDnFAbr/wDC/P/b7Ox7R
69m6GoC8Bx7Jt7DsSfQAQjIdTW1du4EFkyzSBZIcpF2DtpQWy01xYi98TihC0aS8pAtOWxKGGIUU
il0QBUQDILY9FwgvVcNpo7NsJhG/NdqSKyeW/oqKwcOIKFupLJhaueLfWUaQn2RgWxvTNJRruKEB
gsfarichAav/ogcQ5riC+j/cqb0evghdDQCiy0MLlkc5bppctWD8YrJK0/Pcd/tKG5OPHVOJpskw
tCVLJkYhJbJLdQ1ZMVdByqLsKKRvD63kSv4YFduHcXxTPcAWRkGpXGMrCDFCB+FMMaaNFeWyh+Ww
+q+JZVccv2v+xXo+W5dEoFhwHP+qiWGnsUDaFbX7OXSxI34/mNIxYSRWWfAdyGEnU0tFlApRisrL
xDOkkkIyrSLMomLy0EEJ3xqtSdgkW76lcdAqV8gc2UZJvwT59t8mhiXc0vv5unsAiC4PLqgIRiIl
ARmrhuS39yrS/flJQRuzWVx09NldL3QyuQYOVxMjEA92sxmDf5XH756ve4VTQ6JwHM8/iQcW5L4O
fHG5l09bNLmaohsqd7V2RSnaRieSqxL9Z8TDP8gpI8ZgkAHgXmIY8JgxsCVz/inS4DFiCBQUaQ9B
9+PzAzmEXEJOGfE+hhiA+nvuquN5fpmivgENHtnqJxQUHQ2o80omP+QQcgk5ZYQIDNuI5zj+XoZn
SOFCuUPQoWPxjz9SUHQ0EJ2X4QVyBzmEXDLq9Q0zAPV/vOsAnmeRKxSCiDZ6MzcWQEGRIMjav9Er
+0sidxaKXDIEum8DxoLjuXtZBq7CBoZRmSyn0MkTYC9KzUERCopkAnVd7sy/UPWXx+CfYbM/GOkB
APEC7iZegFWBF8D5fdQLoOjwQB1HXZeDtWn2v9uw2R+MNgAg1Di4F5OClHQSDtXWGD0cCoqUgui4
DA+QK8gZ5I7RYzXcANT/6e4DHMAbFlLHPP67c+EwhPFABwVFBwTqNuq4HA/Ivj/AG8gdo6WQlON4
DPB/xowGM6Ztyrx++MRx2VNRFBSZBtRp1G3ZfX+S2ixyJglIigFw/+kPaMneUJIdiKe/QjInoygo
Mg2o0+RkYxwwzZH/N0TOGI6kHchneLiV4cFjVpAXEHG7aUCQosMAdRl1WnbtT/b9wYNcSda7J80A
uO/9Qx0wzJNY1ohRkLcdrDlClwIUGQ/UYdRlOSAnzMK5hicJV5IEQ04DxkP2/X8/FOW4UrmCIQhL
fj5Yu6a4dBgFhQag6x+uk+czbvuZWLai4c/39E6mvA1NBGob/HUmlvmCJce94xufcN1JYF0uMDmd
yR8mBYVGRH0+osNyEFrskwD5dcmWedI9AITrvr99yPP8JUEFh4AYiwXsUHaHJAAACYhJREFUvcua
q+ZQUGQAsNJR4FA58DIFcoEc+DHjEmCZ974/XprsN0tJVU6O437LMIx4XDg+UIBhuitAkWFAnVVC
fuG4L+NBTqTiDVNiAHx/ufcgz3P3m7CuG4kHytQMcNdD1Bu/ZDIFRboAdRV1Vk6vUfeRA8gF5EQq
hp+SJYAE131/Xctx3EQlAUGsAGsv60OWBBQU6Qqc9QPlB2X3/EEM/LEs+5X3vj9NStXrpLQwPxfl
rmGA8Sg5J4BrqqBM5xQKilQDdVSodCyf74+6jxxI5ZBTagB8f/0zuj33mxTmBnCBAISOHE7K2Cgo
EgXqJifTFAfEPX+T0JTkfpEDKUNKlwASsu79y1qe5yeGsQ68gs9be/YCc25ucgZHQaEAmOmnZHKS
0n0Zhvmq8S/3psz1l5AGvbmw+jN3DcOA26SgiCheoSPViiwtBUUyIHim1Yp01yQU+XSjzqfDl5MW
BsD31/sOAg/Xs9gnAm2kvBwhiL3UFGyzUFAYCdRB1EUlOou6zQp/vp7ofBogLQwAovGvf36PYZh/
KT0rQIKCVZVCwIWCIgVIRAelXH/UcdT1dPm+0iIGEAvHH/+8jQcYGVFIbNZuB3uffskaHgVFEwIH
9yteipqFo/Db/X+7/5R0kmDaeAAxmI6HBzFKqsCrgmggAMHD1WkzeIrOAdQ51D0lOipG/N2ibqcV
0s4A+P92/0EGYEbMVoksMOuKGgGKZAF1Tcj0k4e0xY06jbqdbl9SOnoAaAS+5Dn+ehQbozAoGKmn
RoDCeBDyY91KBTop6S/qMup0On49aRcDiIXtnnv/AwA/jyrMD0CY8/LBmqkdhynSGiFCfmW1OjCM
bRJOsL4W/Ptf0mLLry2ktQFA2O+5dw0PMIkaAYpUQg35GYC1gb//5ex0/uLScgkQi3A0+lMA2K40
HoDALypElwMUOiER8kNz0G+7qLtpjbT3ABCm39+TZ2bZrTxAb7kWY7EgnkAR9QQo1CNUnTj5GYBD
EY4bFX3472nf5CLtPQCEIEh+BgO826Sgt0BTHYH6kxCiJwgpVAJ1B3VIqb6hbqKOoq5mAvkhUzwA
Cba7/3gqD/Alz/O5cvUEY4HJQrayvrSsGIUikAy/8gMJnTdhSXEbxs0AnBN88G9bMkXSGWUAQKsR
KO0NjMVq6PgoMht8OERy+zsD+SETDQDCdpc6I4AegK1PX2IMKChaA0kfPHggofMlLcj/UGaRHzLV
AAAxAveoMgIIa3EJCRBSUEggO0dVlQnJoyX5/55x5IdMNgCg0QiYselIUYlhY6PIHISqKyGioHlH
LDoC+SHTDQCIRoDj+S95gNxE34W1O8DWm8YFOivIev8QrvcT60Mp5va7WYbJaPJDRzAACNvviRF4
HwB64/sk8kYYF8AlgSknx8ARUqQboh4PcfkTWe8zIvkB4BDLMDOCD2c2+aGjGACEaf7deQzDrGYA
TknUCIC4JLD07EW3Cjs4kPDhI4cTdvkl8vMA23ienxxd8GBG7PPLocMYACBG4K48lmGWAsDZaowA
Y7WCrbgE2CyXQSOkSCW4Rq9QwScUSmgUMTP/Go7np0cXPNQhyA8dzQBIMN9596sAcA2oMAIIc5eu
YOnWnXoDHQRk1j9aC5HjxxJ+IUJ7gfz/iTzy4LUdTTYd0gAgzPPvxk6rL6vxBEDyBkpKwES9gYxG
FGf9ysRnfWg5818fWfDgKx1RPh3WACAsd959Di8EBxPeJpRgzi8gR4upN5BZwFmfnOJT0J67LbAC
8d0Mw8wIP/JgWhbz0AMd2gAg2N/9vkyMC6gKDoK4U2Dp3gMsXboaMEIKvRE+fgzCtTWqKkbHzPrb
cL3P/ePh8o78BXV4AyDBPP+uJwDgt2qNADQtC0rpsiBNIbj7FarcfWhJ/n9GFjw0r+NLrBMZABCM
wAwAeEXLkgBhcrmIR0ANQXoAiY8zftTrVT0eyeUHgOsiCx56v0MJKA46lQFAsHfcWcYA4C4BKdWk
5e1Nublg61VMPAOK5ANn+uDhKoi63aqfHdOCBkvPXcs9+kiHdvlbo9MZAAnsHXfOYwDuQ29AqwTM
BQVgzi8kngGF8cCZPlJ3AiIn1QX4JIjkd/MA93GPPvJEZ/zqOq0BAJ29AWhaGvSkhsAgIPHDtUc0
ufpAZ/0W6NQGQAJ7u37eAIjBQmuPnmSJQLcPtQEj+ejih2qOqA7uxaLFrP9Y55z1Y0ENgAj29vno
DaBCkEquuhgCkwlMuXlg6doNWIdDj2F2GnB+P4SPHYWou16XBrAxs/4HPMA87rEFnXbWjwU1AK3A
3j5/srgs6A06GQIEGgBzQSG5qFfQNpDokZMnyIUGQA/EEP8QcfcfW7A6fd449aAGoB2Y77jzPp7n
5+m1LIgFegXm3Fzys7MbA8HFr4eI201+6gnJ3WcY5onIo4/cl9IXTVNQAxAH7O3z8XThEzzPk9ZO
RkgKjQAGDc1oDDrJdiKu5bG5Jgbz9CY9xMz6DMP8h+N5dPc7zOk9vUENgAKwt/0O04nvM9IQgBg8
NOehQcgG1pXdYbwDnOU5bwNEvQ2ksaYewby20Ir493GP/4Ou82VADUACQEMAwm5BUpo9sg4niR2Y
srOb/pwJwPU75/dBtKGh6c9JAjaTpcRPANQAqECyDUEsiHfgdABjtRGDwFptKVs64EzOhYKE5Dz+
9PnJLJ8CUOKrBDUAGhBjCKZjsDClY3E4yZIBjQFrswn/1iohCY2HErQmMScm3nDBICE9cemTN6u3
B8z/XUqJrw3UAOgAdt7v8gAAq8XMk7YPKQzDIRDyNV7lnvgHDe5pBDUAOoOZd8d00RikfWvoDMMH
SHr+iUeXdnZB6AlqAAwCM+8OySvA65QO+ZLGYxsISVlIfDrbGwBqAJIAZt4do0RDMJ0uEWRxSFzb
I+m3pvlYMx7UACQZzG9vHyUagunUM2jCNpH0S/l/PkZJn0RQA5BCML+9HXcRJovGYHKqdxKSCIzg
rxZJv5r/52M0ip8iUAOQRhC9g8niNaoDLRfQrd8qkn41neXTB9QApDFED2GUeElGId29BHcM2fHn
VjrDpy+oAcgwMLfelhdjFPJEwwBSVaMkYo34KCR6fRPZn3ycRuszCNQAdDAwt94mGQaIMRISJOMR
D1tFQkuQyI2o5598nLrvHQjUAFBQdGKw9MunoOi8oAaAgqITgxoACopODGoAKCg6MagBoKDoxKAG
gIKiE4MaAAqKTgxqACgoOjGoAaCg6MSgBoCCohODGgAKis4KAPh/3cCoYy6mj6YAAAAASUVORK5C
YII=
EndOfThisFile
   base64 -d "${arquivoNome}.b64" > "$arquivoNome"
   chmod ugo+rx "$arquivoNome"

fi


if [ ! -e '/opt/arduino-2.3.2/' ]; then
   cd /opt
   agora=$(date +%d_%m_%Y_%H_%M_%S_%N)
   if [ -e 'squashfs-root' ]; then
     mv 'squashfs-root' "squashfs-root-$agora"
   fi
   echo "Descompactando para o usuario Convidado poder usar ..."
   /opt/arduino-ide_2.3.2_Linux_64bit.AppImage --appimage-extract 2>&1 >> "$arqLogDisto"
   if [ -e "squashfs-root" ]; then
     if [ -e "arduino-2.3.2" ]; then
        mv "arduino-2.3.2" "arduino-2.3.2-$agora"
     fi
     mv "squashfs-root" "arduino-2.3.2"
     chmod -R ugo+rx "/opt/arduino-2.3.2"
   fi
   # devolver o q tinha
   if [ -e  "squashfs-root-$agora" ]; then
     mv "squashfs-root-$agora" "squashfs-root"
   fi
fi

echo "[Desktop Entry]
Type=Application
Name=Arduino IDE
GenericName=Arduino IDE
Comment=Open-source electronics prototyping platform
Exec=/opt/arduino-2.3.2/AppRun
Icon=$arquivoNome
Terminal=false
Categories=Development;IDE;Electronics;
MimeType=text/x-arduino;
Keywords=embedded electronics;electronics;avr;microcontroller;
StartupWMClass=processing-app-Base" >> /usr/share/applications/arduino232.desktop


if [ -e "/opt/arduino-ide_2.3.2_Linux_64bit.AppImage" ] && [ -e "/usr/share/applications/arduino232.desktop" ]; then
   removerAtalhos "arduino221.desktop"
   copiarAtalhos "arduino232.desktop"
else
   logMsg "Falhou algo"
   ls -lhatr /opt >> "$arqLogDisto"
   echo "falhou em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
fi

USUARIOS=( "pedagogico" "administrador" "professor" "escola" "Aluno" "aluno" "alunos" )


 for usuarios in "${USUARIOS[@]}" ; do
      if id "$usuarios" >/dev/null 2>&1; then
      	 cd /home/"$usuarios"
         tar -xzf /opt/config-arduino221.tar.gz
         chown -R "$usuarios":"$usuarios" /home/"$usuarios"     
         usermod -aG plugdev,dialout,tty "$usuarios"
         
         echo "Permissões atualizadas ao usuário: $usuarios"
      else
         echo "Nao existe usuario $usuario"
      fi
   done
   
#if id "escola" >/dev/null 2>&1; then
 #  cd /home/escola
  # tar -xzf /opt/config-arduino221.tar.gz
   #chown -R escola:escola /home/escola
   #usermod -a -G plugdev,dialout,tty escola
#else
 #  logMsg "Nao existe usuario escola "
#fi


echo "Fim em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
if [ -e "$LOCK" ]; then rm -f "$LOCK"; fi
echo "fim"

