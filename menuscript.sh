#!/bin/bash

#LISTA DE COLÉGIOS COM SEUS RESPECTIVOS INEP's

 function INEP(){
 
INEP_ESCOLA=$( dialog --stdout \
	--menu "SELECIONE SUA ESCOLA" 50 70 120 \
	41095065 "-->> ADELIA BIANCO SEGURO C E EF M" \
	41095936 "-->> ADONIS MORSKI C E EF M PROFIS" \
	41096053 "-->> ANTONIO DORIGON C E EF M PROFIS" \
	41039343 "-->> ARI KFFURI C E C EF M" \
	41382404 "-->> ARROIO GRANDE C E C EF M" \
	41096126 "-->> AURELIO B DE HOLANDA C E C E F M" \
	41372514 "-->> BELA VISTA C E C EF M" \
	41039408 "-->> CARLOS DRUM ANDRADE C E EF M N PROFIS" \
	41145585 "-->> CEEBJA CASTURINA C BONFIM EF M" \
	41155190 "-->> CEEP - PROF. MIGUEL CARLOS PAROLO" \
	41373006 "-->> CHAPADAO C E C EF M" \
	01026158 "-->> CRTE PITANGA - NRE PITANGA" \
	41148649 "-->> ESTRELA DO OESTE C E C EF M" \
	41383354 "-->> FRANCISCO C DA COSTA C E C EF M" \
	41095537 "-->> JOAO C DA COSTA C E EF M" \
	41097564 "-->> JOAO CIONEK C E C EF M P" \
	41095553 "-->> JOAO F NEVES C E DR EF M N PROFIS" \
	41095901 "-->> JOAO PAULO II C E EF M" \
	41097610 "-->> JOSE DE ANCHIETA C E EF M N PROFIS" \
	41096347 "-->> JULIA H DE SOUZA C E PROFA EF M" \
	41094921 "-->> LARANJAL C E DE EF M" \
	41386981 "-->> NATAL PONTAROLO C E C EF M" \
	01000023 "-->> NTE PITANGA - NRE PITANGA" \
	41039556 "-->> OLIDIA ROCHA C E C E F M" \
	41096908 "-->> PEDRO I C E D EF M PROFIS N" \
	41367103 "-->> PINHAL GRANDE C E C EF M" \
	41097033 "-->> RIO DO MEIO C E C EF M" \
	41382390 "-->> SAO JOAO DA COLINA C E C EF M" \
	41097793 "-->> SAO MANOEL C E C DE EF M" \
	41357876 "-->> SITIO BOA VENTURA C E C EF M" \
	41097297 "-->> TIRADENTES E E EF" \
	41097335 "-->> VICTOR C DE ALMEIDA C E C PE EF M" \
	41039637 "-->> VINICIUS DE MORAES C E C E F M" \
	41039661 "-->> VOLTA GRANDE E E C DE EF" \
	41097394 "-->> ZELIO DZIUBATE C E C EF M" \
	41597940 "-->> ZUMBI DOS PALMARES C E C EF M" )

	
	echo "O usuário escolheu: $INEP_ESCOLA"
	
	clear

}
INEP

#COMANDO PARA BUSCAR O MODELO DA MÁQUINA
MODELO=$( dmidecode -t system | grep 'Product Name: ' | cut -d':' -f2 | sed -e s/'^ '// -e s/' '/'_'/g )

#COMANDO PARA BUSCAR O IP DA MÁQUINA
meuip_local=$(ip -4 a | sort -f | grep 'inet' | grep -v 192.168.122 | grep -v 127.0.0 | awk '{print $2}' | sed 's#/.*##' |  tail -1)
meuip_rede=$(ip -4 a | sort -f | grep 'inet' | grep -v 192.168.122 | grep -v 127.0.0 | awk '{print $2}' |  tail -1)

function PREPARAR_MAQUINA(){
   #INÍCIO FUNÇÃO PREPARAR MÁQUINA

	cd /tmp
	
echo -e "\e[37;44;1m INSTALANDO REPOSITÓRIO DA CELAPAR E ATUALIZANDO PACOTES \e[m\n"

	rm repositorios.deb 
	wget http://ubuntu.celepar.parana/repositorios.deb
	if [ -e repositorios.deb ];then
		dpkg -i repositorios.deb
		
	fi
	apt-get update
echo -e "\e[37;44;1m INSTALANDO SSH  \e[m\n"

	apt-get install -y ssh
	
echo -e "\e[37;44;1m VERIFICANDO SE TEM SSHPASS E FPING (INSTALAR CASO NECESSÁRIO)  \e[m\n"	
	
# Testar se tem sshpass
if [ ! -x "/usr/bin/sshpass" ]; then
    
    apt-get  install -y sshpass
    
    else   
    echo "SSPPASS JÁ INSTALADO"
fi
if [ ! -x "/usr/bin/fping" ]; then
   
    apt-get  install -y fping
   else
   echo "FPING JÁ INSTALADO"
fi

echo -e "\e[37;44;1m VERIFICANDO HOSTMANE E PADRONIZANDO A MÁQUINA  \e[m\n"

#VERIFICAR HOSTMANE E PADRONIZAR MÁQUINA

case $MODELO in

#MODELO NETBOOKS VERDINHOS			
             Positivo_Duo_ZE3630)
			PREFIXO='n'
			;;

#MODELO DESKTOP POSITIVO D610
			D610) 
            		PREFIXO='e'
			;;
#MODELO DESKTOP POSITIVO D480
			POS-EIB85CZ) 
            		PREFIXO='e'
			;;
			POS-EIB75CO)
   			PREFIXO='e'
   			;;
#MODELO DESKTOP POSITIVO D3400
			D3400) 
          		  PREFIXO='e'
			;;
#MODELO DESKTOP POSITIVO D3400 (com placa diferente)
			POSITIVO_MASTER)
			 PREFIXO='e'
			;;
#MODELO DESKTOP DELL
			OptiPlex*) 
           		 PREFIXO='d'
			;;
            
#MODELO EDUCATRON
		    	*C1300*)
         		PREFIXO='t'
			;;
#MODELO NOTEBOOK EDUCAÇÃO INTEGRAL
			N4340)
			PREFIXO='n'
			;;
			
			N4340)
    			PREFIXO='n'
  			;;
	
  			A14CR6A)
    			PREFIXO='n'
  			;;	
  			
  			*)
     			 echo "Acesso Linux nao identificado ainda"
     			 echo "MODELO $MODELO"

  			;;	 	
		
        esac
 
    # pegar fim mac
    export fimMac=''
ipLinks=$(ip link show | grep ^[0-9] | cut -d':' -f2 | sed 's/ //g')
for i in $ipLinks; do
   if [[ "$i" = "lo" ]]; then
      continue
   fi

   if [ "$fimMac" = "" ]; then
      mac=$(ifconfig "$i" | grep -i ether | sed 's/^ *ether *//' | cut -d ' ' -f1 |sed 's/:/-/g'|sed 's/ //g')
      if [ ${#mac} -gt 17 ] || [ ${#mac} -le 15 ] ; then
         mac=$(ifconfig "$i" 2>> /dev/null | grep 'ether '| sed 's/^[ \t]*ether //' | sed 's/ .*//' | sed 's/:/-/g'|sed 's/ //g')
      fi
      if [ ${#mac} -gt 17 ] || [ ${#mac} -le 15 ] ; then
         mac=$(ifconfig $ipLink |sed 's/^enp.*HW //;q'|sed 's/^enp.*HWaddr //;q'|sed 's/:/-/g'|sed 's/ //g')
      fi

      #echo "MAC eh [$mac]"
      fimMac=$(echo $mac | sed 's/-//g' | sed 's/[^a-fA-F0-9]//g' | cut -c7- )
   fi
done
   if [ "$fimMac" = "" ]; then
   echo "script falhou ao pegar mac :( "
   
   fi
 
   if [ $(grep "$INEP_ESCOLA" /etc/hostname | wc -l) -eq 1 ]; then
      echo "CONSTA INEP NO HOSTNAME JÁ👍️👍️👍️"
      
   fi
   hostName=$(hostname) # txxxx-abcdef
   export hostnameCorreto="${PREFIXO}${INEP_ESCOLA}-${fimMac}"
   echo ">>>HOSTNAME CORRETO PARA O EQUIPAMENTO É:'$hostnameCorreto'"
   if [ $(grep "$hostnameCorreto" /etc/hostname | wc -l) -eq 0 ]; then
      echo "HOSTNAME ESTAVA ERRADO E FOI CORRIGIDO👏️👏️👏️"
      echo "$hostnameCorreto" > /etc/hostname
      sed -i "s/$hostName/$hostnameCorreto/" /etc/hosts
      hostnamectl set-hostname "$hostnameCorreto"
      if [ $(grep "$hostnameCorreto" /etc/hosts | wc -l) -eq 0 ]; then
         echo "127.0.1.1 $hostnameCorreto" >> /etc/hosts
      fi
      if [ -x /usr/bin/ocsinventory-agent ]; then
          echo "criando OCS em Nohup"
          cat > "/tmp/.nohupdoocs.sh" << EndOfThisFileIsExactHereNowReally

EndOfThisFileIsExactHereNowReally
           chmod +x /tmp/.nohupdoocs.sh
           nohup bash /tmp/.nohupdoocs.sh -d >> /dev/null 2>&1
           echo "add OCS NoHUPP; "
      fi
   else
      echo "HOSTNAME ESTÁ CORRETO👍️👍️👍️ "
   fi
   
   #FIM HOSTMANE E PADRONIZAR MÁQUINA
}

#FIM FUNÇÃO PREPARAR MÁQUINA


function atualizaNavegadores() {
    cd /tmp
    # Atualizar navegadores em background e trocar fundo de tela
    #script="/tmp/.rodar-em-background$$"
    #cat > "\${script}" << FimDoScriptBg
      #!/bin/bash
      cd /tmp
      wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
      rm repositorios.deb 2>> /dev/null
      wget http://ubuntu.celepar.parana/repositorios.deb
      if [ -e repositorios.deb ]; then
          dpkg -i repositorios.deb
      fi
      apt-get  update
      apt-get -y install firefox firefox-locale-pt google-chrome-stable
      rm pi1.sh 2>> /dev/null
      wget  jonilso.com/pi1.sh
      bash pi1.sh
      rm confmozilla.tar.gz 2>> /dev/null
      wget  jonilso.com/confmozilla.tar.gz
      cd /etc/skel
      mv .mozilla /tmp/.antigo-mozilla$$
      tar -xzf /tmp/confmozilla.tar.gz
      echo "Usuario convidado com novas configs do FIREFOX"
      

     if [ -e /home/escola ]; then
         echo "Fazendo Chrome Anonimo pra user Escola"
         updatedb
         locate -i "/home/escola/*google-chrome*desktop" | while read arquivo; do
             sed -i -e 's# --incognito##' "$arquivo"
             sed -i -e 's#^Exec.*#& --incognito#' "$arquivo"
         done

         usuario=escola
         if [ ! -e "/home/${usuario}/.config/xfce4/panel" ]; then
             continue
         fi
         #echo "Alterando arquivo pasta /home/\\\${usuario}/.config/xfce4/panel"
         sed -i -e 's# --incognito##g' /home/${usuario}/.config/xfce4/panel/launcher*/*
         find "/home/${usuario}/.config/xfce4/panel" -type f -iname "*desktop" | while read arquivo; do
             if [ "$(grep -i 'google-chrome' "$arquivo" | wc -l)" -gt 0 ]; then
                sed -i -e 's#^Exec.*#& --incognito#' "$arquivo"
             fi
         done
      fi

     
#FimDoScriptBg
 #     bash "\${script}" < /dev/null &> /dev/null & disown
 #     echo "Rodando script em background"
}

function ativartrocafundodetela(){

   #INÍCIO FUNÇÃO ATIVAR TROCA FONDO DE TELA
    cd /tmp
    
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
export deuRedePrdSerah=''

me=`basename "$0"`
me="$(pwd)/$me"
arqLogDisto="/var/log/.executado-ativar-troca-fundo-tela-$(date +%d_%m_%Y_%H_%M).txt"
echo "Logs no arquivo $arqLogDisto"
echo "iniciando execucao $me em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"

estahNaRedePRD() {
   #ping -c1 -w2 10.209.218.1 >> /dev/null 2>&1
   ping -c1 10.209.218.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah='sim'
   fi

   #ping -c1 -w2 10.209.192.1 >> /dev/null 2>&1
   ping -c1 10.209.192.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w5 10.209.210.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w5 10.209.160.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   tmpdeuRedePrdSerah=$(echo $deuRedePrdSerah | sed 's/simsim//')
   if [ "$deuRedePrdSerah" = "$tmpdeuRedePrdSerah" ]; then
      ping -c1 ubuntu.celepar.parana >> /dev/null 2>&1
      if [ $? -eq 0 ]; then
         wget -q http://ubuntu.celepar.parana/repositorios.deb
         if [ $? -eq 0 ]; then
            export deuRedePrdSerah="simsim"
         fi
      fi

      return
   else
      export deuRedePrdSerah="simsim"
   fi
}

# Checar qual rede que está
estahNaRedePRD

if [[ "$deuRedePrdSerah" == "simsim" ]]; then
   export urlLog="10.209.160.12/prova/?"
else
   export urlLog="jonilso.com/prova/?"
fi

export ips=""
export macs=""
ipLinks=$(ip link show | grep ^[0-9] | cut -d':' -f2 | sed 's/ //g')
for i in $ipLinks; do
   if [[ "$i" = "lo" ]]; then
      continue
   fi
   if [[ "${i:0:4}" = "virb" ]]; then
      continue
   fi
   ip=$(ip -4 a show $i | grep 'inet ' | awk '{print $2}' | sed 's#/.*##' | tail -1 | sed 's/[^a-zA-Z0-9._-]//g')
   if [[ "$ip" != "" ]]; then
      if [ -z "$ips" ]; then
         ips="$ip"
      else
         ips="${ips};$ip"
      fi
   fi
   mac=$(ip a show "$i" | grep -i ether | awk '{print $2}' | tail -1 |sed 's/:/-/g'|sed 's/ //g' | sed 's/[^a-zA-Z0-9_-]//g')
   if [[ "$mac" = "" ]]; then
      mac=$(ifconfig "$i" | grep -i ether | sed 's/^ *ether *//' | cut -d ' ' -f1 | tail -1 |sed 's/:/-/g'|sed 's/ //g' | sed 's/[^a-zA-Z0-9_-]//g')
   fi
   if [[ "$mac" != "" ]]; then
      if [ -z "$macs" ]; then
         macs="$mac"
      else
         macs="${macs};$mac"
      fi
   fi
done
#echo "Os ips sao $ips fim"
#echo "Os macs sao $macs fim"
export hostname=$(hostname|sed 's/[^a-zA-Z0-9_-]//g')

#echo "ip=${ips}&mac=${macs}&h=${hostname}"
mkdir -p /tmp/.logs-ativar-fundo-telas 2>> /dev/null

enviarLog() {
   posicao="EdTrn-$1"
   if [ "$ips" = "" ]; then ips="i"; fi
   if [ "$macs" = "" ]; then macs="m"; fi
   if [ "$hostname" = "" ]; then hostname="h"; fi
   cd /tmp/.logs-ativar-fundo-telas
   wget -q "${urlLog}ip=${ips}&mac=${macs}&h=${hostname}&pos=${posicao}" &> /dev/null & disown
   sleep 4
   rm index* 2>> /dev/null
}


if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario !! Por favor executar como super-usuario."
   enviarLog "NaoEraRoot"
   exit
fi
enviarLog "rootIniciando"

TIPO=$( dmidecode -t system | grep 'Product Name: ' | cut -d':' -f2 | sed -e s/'^ '// -e s/' '/'_'/g )
if [[ "$TIPO" = "Smart_Client_4K" ]]; then
    export TIPO="C1300"
fi
TMPTIPO=$(echo $TIPO | sed 's/C1300//g')
if [[ "$TIPO" = "C1300" ]] || [[ "$TIPO" = "To_be_filled_by_O.E.M." ]] || [[ "$TIPO" != "$TMPTIPO" ]]; then
    echo "Configurando Educatron para troca de fundo de tela!" >> "$arqLogDisto"
else
    echo "Nao eh educatron. nada foi modificado!" >> "$arqLogDisto"
    enviarLog "TipoNaoEraEducatron"
    #exit
fi
if [ -e /var/mstech ]; then
    echo "Nao eh educatron. nada foi modificado!" >> "$arqLogDisto"
    enviarLog "TemPastaMsTech"
    #exit
fi

TEMPOCHECKFUNDOTELA=509 #cada quantos seg checa se mudou fundo de tela
IMGBAIXARNOLOOP=7 # cada qtas iteracoes de `sleep TEMPOCHECKFUNDOTELA` daí checa online se mudou algo

DEFAULTBACKGROUND="/usr/share/backgrounds/linuxmint/default_background.jpg"
imgPadraoMint="/usr/share/backgrounds/linuxmint/sele_ring.jpg"
imgPadraoMintOrig="/root/arquivos_originais/backgrounds_linuxmint_sele_ring.jpg"

# LISTA DE IPS POR INEP
cd /tmp/
listaInepsIps="/var/tmp/.listainepsips.txt"
arquivoNome="$listaInepsIps"
if [ -e "$arquivoNome" ]; then
    rm -f "$arquivoNome" >> /dev/null 2>&1
fi
cat > "${arquivoNome}" << EndOfThisFileIsExactHere
EndOfThisFileIsExactHere

export inep=$(hostname | sed 's/^[a-zA-Z]//' | cut -c1-8)
tmpInep=$(echo $inep | sed 's/^[a-zA-Z-]//g')
if [[ "$inep" == "$tmpInep" ]]; then
    echo -e "\e[42;30m Parece haver INEP no hostname! \e[0m"
else
    #Procurar inep noutro local
    if [ -e /etc/inep ]; then
        export inep=$(head -1 /etc/inep)
    else
        # Olhar pelo gateway se tem na lista de IPs-INEP
        export inep=""
        if [ ! -x /usr/sbin/route ] && [ ! -x /sbin/route ]; then
           echo "Sem Route neste equipamento"
        else
           rotas=$(route -n | grep ^[0-9] | grep -v '^0.0.0.0 ' | grep -v '^169.254.0.0 ' | cut -d' ' -f1)
           for rota in $rotas; do
               if [ $(grep ";${rota};" "$listaInepsIps" | wc -l) -gt 0 ]; then
                   export inep=$(grep ";${rota};" "$listaInepsIps" | cut -d';' -f1)
                   if [ -n "$inep" ]; then
                      echo "$inep" > /etc/inep
                      echo "Achado inep $inep no pelo arquivo $listaInepsIps"
                      break
                   fi
               fi
           done
        fi
    fi
fi
rm "$listaInepsIps" 2>> /dev/null


if [ -e "/etc/xdg/autostart/volume150.desktop" ]; then
   sed -i -e 's/Terminal=true/Terminal=false/' /etc/xdg/autostart/volume150.desktop 2>> /dev/null
fi
if [ -f "/home/framework/Área de Trabalho/libreoffice7.0-calc.desktop" ]; then
    sed -i -e 's/=Exel$/=Excel/' "/home/framework/Área de Trabalho/libreoffice7.0-calc.desktop" 2>> /dev/null
fi
if [ ! -e "/root/arquivos_originais" ]; then
   mkdir -p /root/arquivos_originais 2>> /dev/null
fi

echo "tirando link simbolico fundo" >> "$arqLogDisto"
rm "$DEFAULTBACKGROUND" 2>> /dev/null
cp "$imgPadraoMint" "$DEFAULTBACKGROUND" 2>> /dev/null
if [ ! -e "$imgPadraoMintOrig" ]; then
   cp "$imgPadraoMint" "$imgPadraoMintOrig" 2>> /dev/null
else
   echo "jah tinha bkp $imgPadraoMintOrig" >> "$arqLogDisto"
fi


if [ ! -e "/root/bin" ]; then
   mkdir -p /root/bin 2>> /dev/null
fi
if [ ! -d "/root/bin" ]; then
   mv /root/bin /root/bin$$
   mkdir -p /root/bin 2>> /dev/null
fi

# Criar 2 arquivos: trocando-fundo-tela.sh e sincronizar-com-prdsuporte.py
cat > "/root/bin/sincronizar-com-prdsuporte.py" << EndOfThisFileIsExactHere
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import requests, os, time
#import sys
from bs4 import BeautifulSoup as bs
from os.path import exists
import urllib.request
import random, json, argparse

def argumentos():
    parser = argparse.ArgumentParser()
    parser.add_argument('--inep', type=str, required=False)
    parser.add_argument('--pasta', type=str, required=False)
    parser.add_argument('--tempo', type=str, required=False)
    args = parser.parse_args()
    return args

#from subprocess import check_output
#ips = check_output(['hostname', '--all-ip-addresses'])

def getRoute():
    rotas = []
    try:
        texto = os.popen('route -n | grep ^[0-9]').read()
    except:
        print("Erro ao tentar pegar rota")
        return rotas
    for item in texto.split('\n'):
        rota = item.split(' ')[0]
        #['0.0.0.0', '10.138.142.0', '169.254.0.0']
        if rota == '0.0.0.0': continue
        if rota == '169.254.0.0': continue
        if rota != "":
            rotas.append(rota)

    return rotas

def listarImagens():
    lista = []
    for f in os.listdir():
        if f.endswith(('.png', '.PNG', '.jpg', '.jpeg', '.JPG', '.JPEG')):
            lista.append(f)
    return lista

def removerAntigas(imagensLocais,imagensPortal):
    for f in imagensLocais:
        if f in imagensPortal:
            print("imagem", f, "estah na lista do portal")
        else:
            print("removendo", f)
            f = f.replace("'", "")
            os.system("rm '" + f + "' 2>> /dev/null")
    return


def baixarImagens(url, args):
    if args.pasta:
        print("baixar imagens da pasta", args.pasta)
        url = url + args.pasta + '/'
    else:
        print("baixar da raiz mesmo")
    #print("baixando da url ", url)

    if args.tempo:
        try:
            print(" em instantes ...")
            time.sleep(random.randint(1, 29))
        except:
            time.sleep(3)
    lista = {}
    try:
        r = requests.get(url)
    except:
        print("sem internet serah? tentar novamente em 30s")
        time.sleep(30)
        try:
            r = requests.get(url)
        except:
            print("eh, sem internet pelo visto")
            return lista

    #print(r.text)
    soup = bs(r.content, features="html.parser")
    #print(soup.prettify())
    for i, link in enumerate(soup.findAll('a')):
        url_imagem = url + link.get('href')
        arquivo = soup.select('a')[i].attrs['href']
        if url_imagem.endswith(('.png', '.PNG', '.jpg', '.jpeg', '.JPG', '.JPEG')):
            print('Arquivo', arquivo)
            if exists(arquivo):
                print("Ja temos arquivo",arquivo)
            else:
                print("baixando arquivo", arquivo)
                try:
                    urllib.request.urlretrieve(url_imagem, arquivo)
                except:
                    print("falhou download ou hd lotou/erro, removendo parcial se salvou")
                    arquivo = arquivo.replace("'","")
                    os.system("rm '" + arquivo + "' 2>> /dev/null")
                    continue
            lista[arquivo] = 1
    return lista

def baixarImagensDiversas(url, imagensBaixar, args):
    lista = {}
    for arquivo in imagensBaixar:
        print("tentando baixar", arquivo)
        if exists(arquivo):
            print("Ja temos arquivo",arquivo)
        else:
            print("baixando arquivo", arquivo)
            try:
                urllib.request.urlretrieve(url + arquivo, arquivo)
            except:
                print("falhou download ou hd lotou/erro, removendo parcial se salvou")
                arquivo = arquivo.replace("'","")
                os.system("rm '" + arquivo + "' 2>> /dev/null")
                continue
        lista[arquivo] = 1
    return lista


def baixarJson(url):
    lista = {}
    try:
        r = requests.get(url)
    except:
        print("sem internet serah? tentar novamente em 30s")
        time.sleep(30)
        try:
            r = requests.get(url)
        except:
            print("eh, sem internet pelo visto")
            return lista
    try:
        lista = json.loads(r.content)
    except:
        print("falha ao converter json da string [")
        print(r.content)
        print("]")
        lista = {}
    return lista

def listaParaBaixar(jsonImgsIneps, args):
    indice = 'imagenslogin'
    lista = []
    if args.inep and len(args.inep) == 0:
        return None
    if args.pasta:  # provavelmente 'papeldeparede'
        if args.pasta in jsonImgsIneps:
            indice = args.pasta

    if not indice in jsonImgsIneps:
        print("sem indice [", indice, "] na lista ")
        print(jsonImgsIneps)
        return None

    for imagem in jsonImgsIneps[indice]:
        if args.inep in jsonImgsIneps[indice][imagem]:
            lista.append(imagem)

    if len(lista) > 0:
        return lista
    else:
        return None



if __name__ == '__main__':
    url = 'http://200.201.113.219/educatron/'

    imagensBaixar = None

    args = argumentos()

    imagensLocais = listarImagens()

    if args.pasta == 'papeldeparede':
        print("nem olhar config.txt")
    else:
        if args.inep:
            jsonImgsIneps = baixarJson(url + 'diversos/config.txt')
            imagensBaixar = listaParaBaixar(jsonImgsIneps, args)

    if imagensBaixar is None:
        imagensPortal = baixarImagens(url, args)
    else:
        print("pra inep '" + args.inep + "' baixar especifico da lista " + repr(imagensBaixar))
        imagensPortal = baixarImagensDiversas(url + 'diversos/', imagensBaixar, args)


    removerAntigas(imagensLocais,imagensPortal)
EndOfThisFileIsExactHere
chmod +x /root/bin/sincronizar-com-prdsuporte.py


cat > "/root/bin/starttrocarfundotela.sh" << EndOfThisFileIsExactHere
#!/bin/bash
case \$1 in
    start)
        echo "Iniciando mudar fundo de tela em start"
        /root/bin/trocando-fundo-tela.sh < /dev/null &> /dev/null & disown
        exit
    ;;
    stop)
        echo "Parando o mudar fundo de tela"
        killall trocando-fundo-tela.sh
        exit
    ;;
    restart)
        echo "Restart o mudar fundo de tela"
        killall trocando-fundo-tela.sh
        /root/bin/trocando-fundo-tela.sh < /dev/null &> /dev/null & disown
        exit
    ;;
esac
echo "Iniciando systemctl em \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "/var/log/.log-script-mudar-fundo-tela1.log"
/root/bin/trocando-fundo-tela.sh < /dev/null &> "/tmp/.log-script-mudar-fundo-tela.log" & disown
echo "fim do start systemctl em \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "/var/log/.log-script-mudar-fundo-tela1.log"
exit

EndOfThisFileIsExactHere
chmod +x "/root/bin/starttrocarfundotela.sh"

cat > "/root/bin/trocando-fundo-tela.sh" << EndOfThisFileIsExactHere
#!/bin/bash

IMGBAIXARNOLOOP=$IMGBAIXARNOLOOP
TEMPOCHECKFUNDOTELA=$TEMPOCHECKFUNDOTELA

mintVinteOuUm=\$(hostnamectl | grep 'Operating System' | grep 'Linux Mint 2[01]' | wc -l)


arqLogDisto="/var/log/.log-script-mudar-fundo-tela1.log"
mv /var/log/.log-script-mudar-fundo-tela5.log /tmp 2>> /dev/null
for i in {5..1}; do
    j=\$((i -1))
    mv "/var/log/.log-script-mudar-fundo-tela\${j}.log" "/var/log/.log-script-mudar-fundo-tela\${i}.log" 2>> /dev/null
done

echo "Iniciando trabalhos em \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "\$arqLogDisto"

pegueInep() {
    export inep=\$(hostname | sed 's/^[a-zA-Z]//' | cut -c1-8)
    tmpInep=\$(echo \$inep | sed 's/^[a-zA-Z-]//g')
    if [[ "\$inep" == "\$tmpInep" ]]; then
        echo "ok"
    else
        #Procurar inep noutro local
        if [ -e /etc/inep ]; then
            export inep=\$(head -1 /etc/inep)
        else
            export inep=""
        fi
    fi
}

voltarImagemFabricaPParede() {
   echo "rodando voltarImagemFabricaPParede" >> "\$arqLogDisto"
   if [ -e "\$imgLoginOrig" ];  then cp "\$imgLoginOrig" "\$imgLogin"; fi
   if [ -e "\$imgLoginOrigJ" ];  then cp "\$imgLoginOrigJ" "\$imgLoginJ"; fi
   if [ -e "\$imgDesktopOrig" ];  then cp "\$imgDesktopOrig" "\$imgDesktop"; fi
   if [ -e "\$imgPrIntegralOrig" ];  then
      if [ -e "\$imgPrIntegral" ]; then
         cp "\$imgPrIntegralOrig" "\$imgPrIntegral"
      fi
   fi
}

voltarImagemFabricaLogin() {
   echo "rodando voltarImagemFabricaLogin" >> "\$arqLogDisto"
   cp "\$imgPadraoMintOrig" "\$DEFAULTBACKGROUND"
   reinicieLightDm
}

mudarImagemPParede() {
   echo -n "rodando mudarImagemPParede papel de parede " >> "\$arqLogDisto"
   if [ -e "\$imgLogin" ]; then cp "\$1" "\$imgLogin"; fi
   echo -n "." >> "\$arqLogDisto"
   if [ -e "\$imgLoginJ" ]; then cp "\$1" "\$imgLoginJ"; fi
   echo -n "." >> "\$arqLogDisto"
   if [ -e "\$imgDesktop" ]; then cp "\$1" "\$imgDesktop"; fi
   echo -n "." >> "\$arqLogDisto"
   if [ -e "\$imgPrIntegral" ]; then cp "\$1" "\$imgPrIntegral"; fi
   echo -n ". ok! " >> "\$arqLogDisto"
}

mudarImagemFundoLogin() {
   echo "rodando mudarImagemFundoLogin" >> "\$arqLogDisto"
   cp "\$1" "\$DEFAULTBACKGROUND"
   reinicieLightDm
}

compareComHashImgs() {
   echo "!comparando \$1 com \$2" >> "\$arqLogDisto"
   md5sum "\$1" "\$2" >> "\$arqLogDisto"
   # devolver 0 se iguais (padrao com argumento)
   if [ -z "\$1" ]; then
      return 1
   fi
   if [ -z "\$2" ]; then
      return 1
   fi

   # Se \$2 nao existe, trocar
   if [ ! -e "\$2" ]; then
      #echo "Nao existia \$2"
      return 1
   fi

   if [[ \$(md5sum "\$1" "\$2" | awk '{print \$1}' | uniq | wc -l) == 1 ]]; then
      return 0
   fi
   return 1
}

reinicieLightDm () {
   arqLock="/var/log/.lock-script-mudar-fundo-tela-\$(date +%d_%m_%Y).txt"
   if [ -e "\$arqLock" ]; then
      echo "Tem trava pra restart do lightdm, dah sem restart - \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "\$arqLogDisto"
      return
   else
      echo "reiniciando lightdm \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "\$arqLogDisto"
   fi
   # Tem alguem logado?
   logado=\$(/usr/bin/w | grep -v 'LOGIN@' | grep -v 'load average:' | awk '{print \$3}' | grep ':[0-9]' | wc -l)
   if [ \$logado -eq 0 ]; then
       logado=\$(/usr/bin/w | grep 'xfce4-session' | wc -l)
   fi
   if [ \$logado -eq 0 ]; then
      echo "vamos reiniciar o lightdm pra mostrar nova tela \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "\$arqLogDisto"
      echo "Ninguem logado, entao reiniciar LightDM ..." >> "\$arqLogDisto"
      # tentar 3 vezes, reiniciar se nao resolver reiniciar PC
      for q in {1..5}; do
         echo "tentativa \$q de reiniciar lightdm" >> "\$arqLogDisto"
         systemctl restart lightdm >> /dev/null 2>&1&
         echo "resultado \$? de reiniciar lightdm \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "\$arqLogDisto"
         sleep 10
         travouLightdm=\$(ps aux | grep lightdm | grep -v grep | wc -l)
         if [ \$mintVinteOuUm -gt 0 ]; then
            travouLightdm=\$(ps aux | grep light | awk '{print \$1}' | grep lightdm | wc -l)
         fi
         if [ \$travouLightdm -gt 1 ]; then
            echo "nao travou light, por seguranca olhar novamente em 10s" >> "\$arqLogDisto"
            sleep 10
            travouLightdm=\$(ps aux | grep lightdm | grep -v grep | wc -l)
            if [ \$mintVinteOuUm -gt 0 ]; then
               travouLightdm=\$(ps aux | grep light | awk '{print \$1}' | grep lightdm | wc -l)
            fi

            if [ \$travouLightdm -gt 1 ]; then
               break
            fi
         fi
      done

      sleep 8
      # Tem alguem logado?
      logado=\$(/usr/bin/w | grep -v 'LOGIN@' | grep -v 'load average:' | awk '{print \$3}' | grep ':[0-9]' | wc -l)
      if [ \$logado -eq 0 ]; then
          logado=\$(/usr/bin/w | grep 'xfce4-session' | wc -l)
      fi
      # Se ninguem logado, ver se LIGHTDM TRAVOU
      if [ \$mintVinteOuUm -gt 0 ]; then
         travouLightdm=\$(ps aux | grep light | awk '{print \$1}' | grep lightdm | wc -l)
      else
         travouLightdm=\$(ps aux | grep lightdm | grep -v grep | wc -l)
      fi
      if [ \$logado -eq 0 ] && [ \$travouLightdm -le 1 ]; then
         echo "lightdm travou, reboot em 1min" >> "\$arqLogDisto"
         echo "travou o lightdm, reiniciando em 1min entao (ninguem logado) \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "\$arqLogDisto"
         #arqLock="/var/log/.lock-script-mudar-fundo-tela-\$(date +%d_%m_%Y).txt"
         rm /var/log/.lock-script-mudar-fundo-tela* 2>> /dev/null
         echo "Criada trava pra restart do lightdm - \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "\$arqLock"
         /sbin/shutdown -r +1 "Server will restart in 1 minute. Please save your work." >> "\$arqLogDisto"
      else
         echo "ninguem logado e light nao travou \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "\$arqLogDisto"
         echo "lightdm ok;" >> "\$arqLogDisto"
      fi
   else
      echo "ha \$logado logado" >> "\$arqLogDisto"
   fi
}

checandoPastaImgLogin() {
   echo "Check pasta imgs pra antes do Login" >> "\$arqLogDisto"
   cd "/root/imgs-para-fundo-tela"
   imgDefault="\$DEFAULTBACKGROUND"
   imgDefaultOrig="\$imgPadraoMintOrig"
   voltarFabrica="voltarImagemFabricaLogin"
   mudarPraImagem="mudarImagemFundoLogin"

   exibirImagemNum=\$1
   quantas=\$(ls -1 | grep ".png$\|.PNG$\|.jpg$\|.jpeg$\|.JPG$\|.JPEG" | wc -l)
   echo "Total d imagens encontradas: \$quantas e exibirImagemNum: \$exibirImagemNum" >> "\$arqLogDisto"
   if [ \$exibirImagemNum -gt \$quantas ]; then
      exibirImagemNum=1
   fi

   if [ \$quantas -eq 0 ]; then
      compareComHashImgs "\$imgDefault" "\$imgDefaultOrig"
      if [ \$? -eq 1 ]; then
         \$voltarFabrica
      else
         echo "jah esta na imagem de fabrica" >> "\$arqLogDisto"
      fi
   else
      imagem=\$(ls -1 * | grep ".png$\|.PNG$\|.jpg$\|.jpeg$\|.JPG$\|.JPEG" | head -\$exibirImagemNum | tail -1)
      compareComHashImgs "\$imagem" "\$imgDefault"
      if [ \$? -eq 1 ]; then
         \$mudarPraImagem "\$imagem"
      else
         echo "jah esta com '\$imagem' de fundo de tela" >> "\$arqLogDisto"
      fi

   fi

   exibirImagemNum=\$((exibirImagemNum + 1))
   return \$exibirImagemNum
}

checandoPastaImgPParede() {
   echo "Check pasta imgs pra papel de parede" >> "\$arqLogDisto"
   exibirImagemNum=\$1
   cd "/root/imgs-para-fundo-tela/papeldeparede"
   imgDefault="\$imgLoginJ"
   imgDefaultOrig="\$imgLoginOrigJ"
   voltarFabrica="voltarImagemFabricaPParede"
   mudarPraImagem="mudarImagemPParede"

   exibirImagemNum=\$1
   quantas=\$(ls -1 | grep ".png$\|.PNG$\|.jpg$\|.jpeg$\|.JPG$\|.JPEG" | wc -l)
   echo "Total d imagens encontradas: \$quantas e exibirImagemNum: \$exibirImagemNum" >> "\$arqLogDisto"
   if [ \$exibirImagemNum -gt \$quantas ]; then
      exibirImagemNum=1
   fi

   if [ \$quantas -eq 0 ]; then
      compareComHashImgs "\$imgDefault" "\$imgDefaultOrig"
      if [ \$? -eq 1 ]; then
         \$voltarFabrica
      else
         echo "jah esta na imagem de fabrica" >> "\$arqLogDisto"
      fi
   else
      imagem=\$(ls -1 * | grep ".png$\|.PNG$\|.jpg$\|.jpeg$\|.JPG$\|.JPEG" | head -\$exibirImagemNum | tail -1)
      compareComHashImgs "\$imagem" "\$imgDefault"
      if [ \$? -eq 1 ]; then
         \$mudarPraImagem "\$imagem"
      else
         echo "jah esta com '\$imagem' de fundo de tela" >> "\$arqLogDisto"
      fi

   fi

   exibirImagemNum=\$((exibirImagemNum + 1))
   return \$exibirImagemNum
}

DEFAULTBACKGROUND="/usr/share/backgrounds/linuxmint/default_background.jpg"
imgPadraoMintOrig="/root/arquivos_originais/backgrounds_linuxmint_sele_ring.jpg"
imgPadraoMint="/usr/share/backgrounds/linuxmint/sele_ring.jpg"
imgLoginOrig="/root/arquivos_originais/xfce4_backdrops_bkp-linuxmint.png"
imgLogin="/usr/share/xfce4/backdrops/linuxmint.png"
imgLoginOrigJ="/root/arquivos_originais/xfce4_backdrops_bkp-linuxmint.jpg"
imgLoginJ="/usr/share/xfce4/backdrops/linuxmint.jpg"
imgDesktopOrig="/root/arquivos_originais/backgrounds_linuxmint_bkp-linuxmint.jpg"
imgDesktop="/usr/share/backgrounds/linuxmint/linuxmint.jpg"
imgPrIntegralOrig="/root/arquivos_originais/0-parana-integral.jpg"
imgPrIntegral="/usr/share/xfce4/backdrops/0-parana-integral.jpg"

if [ ! -e "/root/arquivos_originais" ]; then
   mkdir -p /root/arquivos_originais 2>> /dev/null
fi
if [ ! -e "/root/bin" ]; then
   mkdir -p /root/bin 2>> /dev/null
fi
if [ ! -e "/root/imgs-para-fundo-tela/papeldeparede/" ]; then
   mkdir -p "/root/imgs-para-fundo-tela/papeldeparede/" 2>> /dev/null
fi

# backup
if [ ! -f "\$imgLoginOrig" ]; then
   if [ -e "\$imgLogin" ]; then
      cp "\$imgLogin" "\$imgLoginOrig" 2>> /dev/null
   fi
fi
if [ ! -f "\$imgLoginOrigJ" ]; then
   if [ -e "\$imgLoginJ" ]; then
      cp "\$imgLoginJ" "\$imgLoginOrigJ" 2>> /dev/null
   fi
fi
if [ ! -f "\$imgDesktopOrig" ]; then
   if [ -e "\$imgDesktop" ]; then
      cp "\$imgDesktop" "\$imgDesktopOrig" 2>> /dev/null
   fi
fi
if [ ! -f "\$imgPrIntegralOrig" ]; then
   if [ -e "\$imgPrIntegral" ]; then
      cp "\$imgPrIntegral" "\$imgPrIntegralOrig" 2>> /dev/null
   fi
fi
if [ ! -f "imgPadraoMintOrig" ]; then
   if [ -e "\$imgPadraoMint" ]; then
      cp "\$imgPadraoMint" "\$imgPadraoMintOrig" 2>> /dev/null
   fi
fi

# INEP
export inep=""
pegueInep
echo "Inep eh \$inep deste hw"
# Pasta baixar imagens em sincronia com prdsuporte
echo " +++ iniciando python " >> "\$arqLogDisto"
cd "/root/imgs-para-fundo-tela"
/root/bin/sincronizar-com-prdsuporte.py --inep "\$inep" >> "\$arqLogDisto" 2>&1
cp *.* papeldeparede/
cd "/root/imgs-para-fundo-tela/papeldeparede"
/root/bin/sincronizar-com-prdsuporte.py --inep "\$inep" --pasta papeldeparede >> "\$arqLogDisto" 2>&1

if [ -e "/root/imgs-para-fundo-tela/formadores_material-educatron-login.jpg" ]; then
   shasum=\$(sha256sum /root/imgs-para-fundo-tela/formadores_material-educatron-login.jpg | cut -d' ' -f1)
   if [ "\$shasum" = "e53e21a24bc75002efbfe7c6abc2ffc1516a060f11017a1630465fd2a7f28609" ]; then
      cp /root/imgs-para-fundo-tela/papeldeparede/campanha_agrinhoprog_educatron-papel-de-parede.jpg /root/imgs-para-fundo-tela/formadores_material-educatron-login.jpg 2>> /dev/null
   fi
fi

exibirImgNumLogin=1
exibirImgNumPParede=1
countBaixarImgs=0
while true; do
   echo " +++++ Inicio do while em \$(date +%d/%m/%Y_%H:%M:%S_%N) +++++++" >> "\$arqLogDisto"

   checandoPastaImgLogin \$exibirImgNumLogin
   exibirImgNumLogin=\$?

   checandoPastaImgPParede \$exibirImgNumPParede
   exibirImgNumPParede=\$?

   echo " vamos para uma espera \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "\$arqLogDisto"
   sleep \$TEMPOCHECKFUNDOTELA

   pegueInep

   ((countBaixarImgs++))
   if [ \$countBaixarImgs -ge \$IMGBAIXARNOLOOP ]; then
      echo " +++ iniciando python " >> "\$arqLogDisto"

      cd "/root/imgs-para-fundo-tela"
      /root/bin/sincronizar-com-prdsuporte.py --inep "\$inep" >> "\$arqLogDisto" 2>&1
      cp *.* papeldeparede/
      cd "/root/imgs-para-fundo-tela/papeldeparede"
      #TODO ARRUMAR argumentos
      /root/bin/sincronizar-com-prdsuporte.py --inep "\$inep" --pasta papeldeparede --tempo random >> "\$arqLogDisto" 2>&1

      if [ -e "/root/imgs-para-fundo-tela/formadores_material-educatron-login.jpg" ]; then
         shasum=\$(sha256sum /root/imgs-para-fundo-tela/formadores_material-educatron-login.jpg | cut -d' ' -f1)
         if [ "\$shasum" = "e53e21a24bc75002efbfe7c6abc2ffc1516a060f11017a1630465fd2a7f28609" ]; then
            cp /root/imgs-para-fundo-tela/papeldeparede/campanha_agrinhoprog_educatron-papel-de-parede.jpg /root/imgs-para-fundo-tela/formadores_material-educatron-login.jpg 2>> /dev/null
         fi
      fi

      countBaixarImgs=0
   fi
done
EndOfThisFileIsExactHere
chmod +x /root/bin/trocando-fundo-tela.sh


cat > "/etc/systemd/system/trocando-fundo-de-tela.service" << EndOfThisFileIsExactHere
[Unit]
Description=Trocando fundo de tela
Requires=network-online.target
After=network-online.target

[Service]
Type=forking
ExecStart=/root/bin/starttrocarfundotela.sh &

[Install]
WantedBy=multi-user.target
EndOfThisFileIsExactHere
#Restart=on-failure
#RestartSec=10

cat > "/usr/local/bin/restaurefundotela.sh" << EndOfThisFileIsExactHere
#!/bin/bash
if [ -e '/usr/share/xfce4/backdrops/0-parana-integral.jpg' ]; then
    FUNDOTELA="/usr/share/xfce4/backdrops/0-parana-integral.jpg"
elif [ -e "/usr/share/xfce4/backdrops/linuxmint.jpg" ]; then
    FUNDOTELA="/usr/share/xfce4/backdrops/linuxmint.jpg"
elif [ -e "/usr/share/xfce4/backdrops/linuxmint.png" ]; then
    FUNDOTELA="/usr/share/xfce4/backdrops/linuxmint.png"
else
    FUNDOTELA="/usr/share/backgrounds/linuxmint/linuxmint.jpg"
fi
if [ -e "/usr/bin/xfce4-session" ]; then
   xfconf-query -c xfce4-desktop -lv | while read param; do
   {
       lastImage=\$(echo "\$param" | grep "last-image" | sed 's/[ \t].*//')
       backdropCycle=\$(echo "\$param" | grep "backdrop-cycle-enable" | sed 's/[ \t].*//')
       if [ "\$lastImage" = "" ] && [ "\$backdropCycle" = "" ]; then
           continue;
       fi

       if [ "\$backdropCycle" != "" ]; then
           #echo "desativado Cycle"
           xfconf-query -c xfce4-desktop -p "\$backdropCycle" -r -R
       fi

       if [ "\$lastImage" != "" ]; then
           #echo "mudando fundo tela ao padrao"
           xfconf-query -c xfce4-desktop -p "\$lastImage" -s "\$FUNDOTELA"
       fi
   }
   done
else
   gsettings set org.cinnamon.desktop.background picture-uri "file://\$FUNDOTELA"
fi
#echo fim
EndOfThisFileIsExactHere
chmod +x /usr/local/bin/restaurefundotela.sh

cat > "/usr/local/bin/restauretelalogout.sh" << EndOfThisFileIsExactHere
#!/bin/bash
/usr/local/bin/restaurefundotela.sh
#echo fim
EndOfThisFileIsExactHere
chmod +x "/usr/local/bin/restauretelalogout.sh"

cat > "/usr/local/bin/restauretelalogin.sh" << EndOfThisFileIsExactHere
#!/bin/bash
while true; do
    /usr/local/bin/restaurefundotela.sh
    sleep 500
done
#echo fim
EndOfThisFileIsExactHere
chmod +x /usr/local/bin/restauretelalogin.sh


cat > "/etc/xdg/autostart/restaurar-fundo-tela-ao-deslogar.desktop" << EndOfThisFileIsExactHere
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=Restaurar fundo tela ao Deslogar
Comment=Restaurar fundo tela ao Deslogar
Exec=/usr/local/bin/restauretelalogout.sh
RunHook=1
StartupNotify=false
Terminal=false
Hidden=true
EndOfThisFileIsExactHere
chmod +x /etc/xdg/autostart/restaurar-fundo-tela-ao-deslogar.desktop

cat > /etc/xdg/autostart/restaurar-fundo-tela.desktop << EndOfThisFileIsExactHereNowReally
[Desktop Entry]
Version=1.0
Type=Application
Name=RestaurarFundoTela
Comment=RestaurarFundoTela
Exec=/usr/local/bin/restauretelalogin.sh
Icon=preferences-system-sound
Path=
Terminal=false
StartupNotify=false
EndOfThisFileIsExactHereNowReally
chmod +x /etc/xdg/autostart/restaurar-fundo-tela.desktop

if [ -e "/var/lib/lightdm/.cache/slick-greeter/state" ]; then
    sed -i 's/last-user=.*/last-user=*guest/g' /var/lib/lightdm/.cache/slick-greeter/state
fi

if [ -e "/etc/lightdm/slick-greeter.conf" ]; then
    if [ "$(grep 'draw-user-backgrounds' "/etc/lightdm/slick-greeter.conf" | wc -l)" -gt 0 ]; then
        sed -i 's/draw-user-backgrounds=.*/draw-user-backgrounds=false/' /etc/lightdm/slick-greeter.conf
    else
        echo "draw-user-backgrounds=false" >> /etc/lightdm/slick-greeter.conf
    fi
else
    echo "[Greeter]" > /etc/lightdm/slick-greeter.conf
    echo "draw-user-backgrounds=false" >> /etc/lightdm/slick-greeter.conf
fi

killall trocando-fundo-tela.sh 2>> /dev/null
systemctl kill -s SIGKILL trocando-fundo-de-tela >> /dev/null 2>&1
systemctl  disable  trocando-fundo-de-tela >> /dev/null 2>&1
echo -n "ativando trocar fundo de tela: " >> "$arqLogDisto"
systemctl  enable  trocando-fundo-de-tela >> /dev/null 2>&1
if [ $? -eq 0 ]; then
   echo "ativado" >> "$arqLogDisto"
else
   echo "falhou!!" >> "$arqLogDisto"
fi

#systemctl start trocando-fundo-de-tela >> /dev/null 2>&1

echo "checando systemctl status..." >> "$arqLogDisto"
echo "checando systemctl status..."
sleep 4
if [ $(ps aux | grep trocando-fundo-tela.sh | grep -v grep | wc -l) -gt 0 ]; then
   echo -e "Script trocando-fundo-tela.sh \e[1;92mparece ok. Por favor checar melhor! \e[0m" >> "$arqLogDisto"
   echo -e "Script trocando-fundo-tela.sh \e[1;92mparece ok. Por favor checar melhor! \e[0m"
   enviarLog "ShowNoPrimeiro"
   exit
fi
echo "."
sleep 8
if [ $(ps aux | grep trocando-fundo-tela.sh | grep -v grep | wc -l) -gt 0 ]; then
   echo -e "Script trocando-fundo-tela.sh \e[1;92mparece ok. Por favor checar melhor! \e[0m" >> "$arqLogDisto"
   echo -e "Script trocando-fundo-tela.sh \e[1;92mparece ok. Por favor checar melhor! \e[0m"
   enviarLog "ShowNoSegundo"
   exit
fi
sleep 8
echo ".."
if [ $(ps aux | grep trocando-fundo-tela.sh | grep -v grep | wc -l) -gt 0 ]; then
   echo -e "Script trocando-fundo-tela.sh \e[1;92mparece ok. Por favor checar melhor! \e[0m" >> "$arqLogDisto"
   echo -e "Script trocando-fundo-tela.sh \e[1;92mparece ok. Por favor checar melhor! \e[0m"
else
   echo "Via systemctl nao constou! Vamos iniciar via comando..." >> "$arqLogDisto"
   echo "Via systemctl nao constou! Vamos iniciar via comando..."
   /root/bin/starttrocarfundotela.sh < /dev/null &> /dev/null & disown
   sleep 4
   if [ $(ps aux | grep trocando-fundo-tela.sh | grep -v grep | wc -l) -gt 0 ]; then
       echo -e "Script trocando-fundo-tela.sh \e[1;92mconsta executando ok! \e[0m" >> "$arqLogDisto"
       echo -e "Script trocando-fundo-tela.sh \e[1;92mconsta executando ok! \e[0m"
   else
       echo "Falhou. Por favor testar reiniciar computador" >> "$arqLogDisto"
       echo "Falhou. Por favor testar reiniciar computador"
   fi
fi



echo "apagando ips do arquivo $me em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
sed -i -e '/^[0-9]*;10.[0-9.]*;2[0-9]$/d' "$me" >> "$arqLogDisto" 2>&1

enviarLog "TerminouComSucesso"
echo "fim"

}

function atalhopaginainicial(){
    cd /tmp
    if [ -e atalhopaginainicial.sh ]; then
        #rm atalhopaginainicial.sh
        echo "Jah tinha atalhopaginainicial.sh no temp"
    else
        wget jonilso.com/atalhopaginainicial.sh
        bash  atalhopaginainicial.sh
    fi
}

function resetbackgrounds() {
    if [ -e "rb.sh" ]; then
        rm rb.sh
    fi

    if [ -e "/usr/local/bin/restaurefundotela.sh" ]; then
        echo "jah com rb.sh no /usr/local/bin/restaurefundotela.sh "
    else
        echo "instalando reset de fundo de tela"
        wget jonilso.com/rb.sh
        bash rb.sh
    fi

}

#FIM FUNÇÃO ATIVAR TROCA FUNDO DE TELA

function limparguests() {
    if [ -e "lg.sh" ]; then
        rm lg.sh
    fi

    if [ -e "/usr/sbin/apagar-guest-ao-iniciar.sh" ]; then
        echo "jah com lg.sh nele"
    else
        echo "instalando limpar guests"
        wget https://raw.githubusercontent.com/crtepitanga/scripts/main/lg.sh -O lg.sh
        bash lg.sh
    fi

}

function instalascratch(){
    cd /tmp
    if [ -e scratch.sh ]; then
        #rm s.sh
        echo "Jah tinha scratch.sh no temp"
    else
        wget -q https://raw.githubusercontent.com/crtepitanga/scripts/main/scratch.sh -O scratch.sh
        bash  scratch.sh

        echo "SCRATCH STALADO 👍️👍️👍️"
    fi
}

function bloquearaplicativos(){
USUARIOS=( "professor" "escola" "Aluno" "aluno" "alunos" )
APLICATIVOS=( "/usr/bin/users-admin" "/usr/bin/mugshot" "/usr/bin/mate-about-me" )

for USUARIO in "${USUARIOS[@]}" ; do
   if [ $(grep "^${USUARIO}:" /etc/passwd | wc -l) -eq 0 ]; then
      echo "Usuario $USUARIO nao consta neste Linux"
      continue
   fi  
   for APLICATIVO in "${APLICATIVOS[@]}" ; do
      if [ -x "$APLICATIVO" ]; then
         /bin/setfacl -m u:${USUARIO}:--- "$APLICATIVO"
      fi  
   done
   echo "Aplicativos bloqueados para $USUARIO"
done

}

function atualizahoraedata(){
cd /tmp
    if [ -e ah.sh ]; then
        #rm ah.sh
        echo "Jah tinha ah.sh no temp"
    else
        wget https://raw.githubusercontent.com/crtepitanga/scripts/main/ah.sh -O ah.sh
        bash  ah.sh

        echo "DATA E HORA ATUALIZADAS 👍️👍️👍️"
    fi
}

function instalacertificado(){
	cd /tmp
	
	if [ -e cert.sh ];then
	 	bash cert.sh
	else  	
		wget https://raw.githubusercontent.com/crtepitanga/scripts/main/cert.sh -O cert.sh
		bash cert.sh
		
		echo "CERTIFICADO INSTALADO 👍️👍️👍️"
	fi

}

function atomvscode(){
cd /tmp
 if [ ! -e "/usr/bin/atom" ] || [ ! -e "/usr/share/code/code" ]; then
          wget  https://raw.githubusercontent.com/crtepitanga/scripts/main/av.sh -O av.sh
          bash av.sh

          echo "ATOM E VSCODE INSTALADOS 👍️👍️👍️"
      else
         echo "ATOM E VSCODE JÁ ESTAVAM INSTALADOS 👍️👍️👍️"
      fi

}

function ativartap(){
	cd /tmp
		case $MODELO in

#MODELO NETBOOKS VERDINHOS			
             Positivo_Duo_ZE3630)
			echo "ESSE COMANDO É ESPECÍFICO PARA NOTEBOOKS POSITIVO DA EDUCAÇÃO INTEGRAL.👎️👎️👎️"
			;;

#MODELO DESKTOP POSITIVO D610
			D610) 
            		echo "ESSE COMANDO É ESPECÍFICO PARA NOTEBOOKS POSITIVO DA EDUCAÇÃO INTEGRAL.👎️👎️👎️"
			;;
#MODELO DESKTOP POSITIVO D480
			POS-EIB85CZ) 
            		echo "ESSE COMANDO É ESPECÍFICO PARA NOTEBOOKS POSITIVO DA EDUCAÇÃO INTEGRAL.👎️👎️👎️"
			;;
			POS-EIB75CO)
   			echo "ESSE COMANDO É ESPECÍFICO PARA NOTEBOOKS POSITIVO DA EDUCAÇÃO INTEGRAL.👎️👎️👎️"
   			;;
#MODELO DESKTOP POSITIVO D3400
			D3400) 
          		  echo "ESSE COMANDO É ESPECÍFICO PARA NOTEBOOKS POSITIVO DA EDUCAÇÃO INTEGRAL.👎️👎️👎️"
			;;
			
#MODELO DESKTOP POSITIVO D3400
			POSITIVO_MASTER) 
          		  echo "ESSE COMANDO É ESPECÍFICO PARA NOTEBOOKS POSITIVO DA EDUCAÇÃO INTEGRAL.👎️👎️👎️"
			;;
#MODELO DESKTOP DELL
			OptiPlex*) 
           		 echo "ESSE COMANDO É ESPECÍFICO PARA NOTEBOOKS POSITIVO DA EDUCAÇÃO INTEGRAL.👎️👎️👎️"
			;;
            
#MODELO EDUCATRON
		    	*C1300*)
         		echo "ESSE COMANDO É ESPECÍFICO PARA NOTEBOOKS POSITIVO DA EDUCAÇÃO INTEGRAL.👎️👎️👎️"
			;;
#MODELO NOTEBOOK EDUCAÇÃO INTEGRAL
			N4340)
			if [ -e tap.sh ];then
	 			bash tap.sh
			else  	
				wget https://raw.githubusercontent.com/crtepitanga/scripts/main/tap.sh -O tap.sh
				bash tap.sh
			fi
			;;
			
			A14CR6A)
    			echo "ESSE COMANDO É ESPECÍFICO PARA NOTEBOOKS POSITIVO DA EDUCAÇÃO INTEGRAL.👎️👎️👎️"
  			;;	
  			
  			*)
     			 echo "Acesso Linux nao identificado ainda"
     			 echo "MODELO $MODELO"

  			;;	 	 	
		
       		 esac
	
	
}

function desabilitar_proxy(){
	cd /tmp
	
		if [ -e tpm.sh ];then
	 		bash tpm.sh
		else  	
			wget https://raw.githubusercontent.com/crtepitanga/scripts/main/tpm.sh -O tmp.sh
			bash tpm.sh
		echo "PROXY DESABILITADO NOS NAVEGADORES 👍️👍️👍️"
		fi
	
		
}

function desbloquea_tela(){
	cd /tmp
	
		if [ -e tb.sh ];then
	 		bash tb.sh
		else  	
			wget https://raw.githubusercontent.com/crtepitanga/scripts/main/tb.sh -O tb.sh
			bash tb.sh
		
		fi
	
		
}

function desativa_touch(){
	cd /tmp
		case $MODELO in

#MODELO NETBOOKS VERDINHOS			
             Positivo_Duo_ZE3630)
			if [ -e dt.sh ];then
	 			bash dt.sh
			else  	
				wget https://raw.githubusercontent.com/crtepitanga/scripts/main/dt.sh -O dt.sh
				bash dt.sh

            echo "TOUCHSCRENN DESATIVADO"
			fi
			;;

# OUTRO MODELO 
			*) 
            		
            		echo "ESSE COMANDO É ESPECÍFICO PARA NETEBOOKS VERDINHOS 👎️👎️👎️"
            		
			;;

		
       		 esac
	
	
}

function desativa_convidado(){
	cd /tmp
	
		if [ -e semconvidado.sh ];then
	 		bash semconvidado.sh
		else  	
			wget https://raw.githubusercontent.com/crtepitanga/scripts/main/semconvidado.sh -O semconvidado.sh
			bash semconvidado.sh
		
		fi
	
		
}

function driver_mblock(){
	cd /tmp
	
		if [ -e mlink.sh ];then
	 		bash mlink.sh
		else  	
			wget https://raw.githubusercontent.com/crtepitanga/scripts/main/mlink.sh -O mlink.sh
			bash mlink.sh
		
		fi
			
}

function medidor_mec(){
	cd /tmp
	
		if [ -e medidor.sh ];then
	 		bash medidor.sh
		else  	
			wget https://raw.githubusercontent.com/crtepitanga/scripts/main/medidor.sh -O medidor.sh
			bash medidor.sh
		
		fi
	
		
}


function instalar_vnc(){
	cd /tmp
	
		#!/bin/bash

if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario !! Por favor executar como super-usuario."
   exit
fi

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
      ping -c1 -w2 10.132.214.1 >> /dev/null 2>&1
      if [ $? -eq 0 ]; then
         if [ $(route -n | egrep "10.132.214.1[ \t]"| wc -l) -gt 0 ]; then
            export deuRedePrdSerah="simsim"
         fi
      fi
      return
   else
      export deuRedePrdSerah="simsim"
   fi
}

trocarRepositoriosSePrecisar() {
   estahNaRedePRD
   if [[ "$deuRedePrdSerah" = "simsim" ]]; then
      echo "Rede Estado, trocando repositorios daeh .."
      cd /tmp
      rm repositorios.deb 2>> /dev/null
      wget http://ubuntu.celepar.parana/repositorios.deb
      if [ -e "repositorios.deb" ]; then
         dpkg -i repositorios.deb
         sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
         sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
         apt-get  update
         if [ -e "/var/mstech/updates/" ] && [ -e "/home/ccs-client/" ] ; then
            echo 'parece um c3'
         else
            apt-get -y install  code-repo
         fi
      else
         echo "ERRO AO BAIXAR repositorios"
      fi
   else
      echo "Num tah na rede PRD"
   fi
}


if [ -e "/usr/bin/x11vnc" ]; then
   # Estah rodando serah
   vncRunning=$(ps aux | grep "/usr/bin/x11vnc" | grep -v grep | wc -l)
   if [ $vncRunning -gt 0 ]; then
      killall "/usr/bin/x11vnc"
   fi

else
   echo -e "\e[45m Nao tem x11vnc! Vamos instalar ele ebaa, soh um pouco ... \e[0m "
   sleep 2
   trocarRepositoriosSePrecisar
   apt-get update >> /tmp/.vncloginstall.txt 2>&1
   apt-get -y  install  x11vnc >> /tmp/.vncloginstall.txt 2>&1
   if [ $? -eq 0 ]; then
      ok=1
   else
      echo -e "\e[1;31m falhou ao tentar instalar x11vnc. Saindo. Pfv tentar novamente! \e[0m "
      exit 1
   fi
   echo ""
fi

#read -p "Qual a senha para o VNC: " -s SENHAVNC
echo -e -n "\e[44mQual a senha para o VNC:\e[0m "
read -s SENHAVNC
SENHAVNC=$(echo "$SENHAVNC" | sed 's/ //g')
echo "A senha é: Sc3l3p@r "

if [ "$SENHAVNC" = "Sc3l3p@r" ]; then
   echo -e "\e[1;31m Senha vazia detectada Saindo. Pfv tentar novamente! \e[0m "
   exit 1
fi
echo ""
echo ""
#echo -e -n "\e[44mPor favor digitar novamente a senha do VNC:\e[0m "
read -s SENHAVNC1
echo ""
if [ "$SENHAVNC" = "$SENHAVNC1" ]; then
   ok=1
else
   echo ""
   echo -e "\e[1;31m Senhas nao conferiram. Saindo! Pfv tentar novamente! \e[0m "
   exit 1
fi

sudo x11vnc -storepasswd /root/.vncpasswd >> /dev/null 2>> /dev/null << ENDDOC
$SENHAVNC
$SENHAVNC
y
ENDDOC

echo "..."

cp /root/.vncpasswd /etc/x11vnc.pass

chmod go+r /etc/x11vnc.pass
cat > "/etc/systemd/system/vnc-server.service" << EndOfThisFileIsExactHereNowReally
[Unit]
Description=VNC Server for X11
Requires=display-manager.service
After=display-manager.service

[Service]
Type=forking
ExecStart=/usr/bin/x11vnc -auth guess -display :0 -rfbauth /etc/x11vnc.pass -forever -shared -bg -logappend /var/log/x11vnc.log
#ExecStart=/usr/bin/x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :0 -auth guess -rfbauth -rfbauth /etc/.vncpasswd
#ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EndOfThisFileIsExactHereNowReally

echo -n "ativando vnc: "
systemctl  enable  vnc-server >> /dev/null 2>&1
if [ $? -eq 0 ]; then
   echo "ativado"
else
   echo "falhou!!"
fi
systemctl stop vnc-server >> /dev/null 2>&1
systemctl start vnc-server >> /dev/null 2>&1
echo -n "iniciando o vnc: "
if [ $? -eq 0 ]; then
   echo "iniciado"
else
   echo "falhou!!"
fi

echo -e "Vnc parece tudo ok.\e[1;92m Por favor testar!\e[0m"
		
}

function limpar_update(){
	cd /tmp
	
		if [ -e j.sh ];then
	 		bash j.sh
		else  	
			wget https://raw.githubusercontent.com/crtepitanga/scripts/main/j.sh -0 j.sh
			bash j.sh
		
		fi
	
		
}

function pagina_inicial_navegadores(){
	cd /tmp
	
		if [ -e pi1.sh ];then
	 		bash pi1.sh
		else  	
			wget https://raw.githubusercontent.com/crtepitanga/scripts/main/pi1.sh -O pi1.sh
			bash pi1.sh
		
		fi
	
		
}



function MENU(){
OPCAO=$( dialog --stdout \
	--menu "O QUE DESEJA ATUALIZAR?" 0 0 0 \
	1 "-->> Atualizar esta maquina" \
	2 "-->> Atualizar todas as maquinas desse modelo" \
	3 "-->> Atualizar todas as maquinas da escola" )

clear
}

MENU

function maquina_atual(){
OPCAO_M_ATUAL=" "
OPCAO_M_ATUAL=$( dialog --stdout \
	--menu "QUAL FORMA DE ATUALIZAÇÃO?" 0 0 0 \
	1 "-->> Atualização completa da máquina" \
	2 "-->> Atualização/instalação de alguns programas" )

clear
} 



if [ "$OPCAO" -eq 1 ]; then
#CHAMA MENU DE OPÇÕES MAQUINA ATUAL 	
    
    maquina_atual
#INICIO ATUALIZAÇÃO COMPLETA DA MÁQUINA DE ACORDO COM O MODELO
if [ "$OPCAO_M_ATUAL" -eq 1 ];then
	
	PREPARAR_MAQUINA
	
	case $MODELO in

#MODELO NETBOOKS VERDINHOS			
        Positivo_Duo_ZE3630)
	cd /tmp
		wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-verdinhos.sh -O p2-verdinhos.sh && bash p2-verdinhos.sh $meuip_local/32 "$INEP_ESCOLA"                         
	     	
	;;

#MODELO DESKTOP POSITIVO D610
			D610) 
               cd /tmp
		            wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-d610.sh -O p2-d610.sh && bash p2-d610.sh $meuip_local/32 "$INEP_ESCOLA"
			    
			         ativartrocafundodetela
			;;
#MODELO DESKTOP POSITIVO D480
			POS-EIB85CZ) 
            		cd /tmp
		       	wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-d480.sh -O p2-d480.sh && bash p2-d480.sh $meuip_local/32 "$INEP_ESCOLA"
		;;
#MODELO DESKTOP POSITIVO D3400
			D3400) 
          		  cd /tmp

			    wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-d3400.sh -O p2-d3400.sh && bash p2-d3400.sh $meuip_local/32 "$INEP_ESCOLA"
			;;
			
#MODELO DESKTOP POSITIVO D3400 (EXCESSÃO COM PLACA DIREFENTE)
			
			POSITIVO_MASTER) 
          		  cd /tmp
			    wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-d3400.sh -O p2-d3400.sh && bash p2-d3400.sh $meuip_local/32 "$INEP_ESCOLA"
			;;
#MODELO DESKTOP DELL
			OptiPlex*) 
           		 cd /tmp
			    wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-dell.sh -O p2-dell.sh && bash p2-dell.sh $meuip_local/32 "$INEP_ESCOLA"
			;;
            
#MODELO EDUCATRON
		    *C1300*)
         	cd /tmp
		       	wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-educatron.sh -O p2-educatron.sh && bash p2-educatron.sh $meuip_local/32 "$INEP_ESCOLA"
			;;
#MODELO NOTEBOOK EDUCAÇÃO INTEGRAL
			N4340)
			cd /tmp
			   	wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-integral.sh -O p2-integral.sh && bash p2-integral.sh $meuip_local/32 "$INEP_ESCOLA"
			;;
			
			*)
     			 echo "Acesso Linux nao identificado ainda"
     			 echo "MODELO $MODELO"

  			;;	 		 	
		
        esac
	fi		
		
#FIM ATUALIZAÇÃO COMPLETA DA MÁQUINA DE ACORDO COM O MODELO	
	

fi

if [ "$OPCAO_M_ATUAL" -eq 2 ];then	 	
		
	CHECKLIST=$(dialog --stdout \
	--title "ATUALIZAÇÃO PARCIAL DA MÁQUINA" \
	--separate-output \
	--checklist "Navegue com o mouse ou setas 'pra cima/pra baixo' e marque pressionando a barra de espaço" 0 0 0 \
    "1" "-->> ajustar  hora e data" off \
    "2" "-->> Ativar plano de fundo padrão do Estado" off \
    "3" "-->> Ativar TAP do Touchpad Notebooks ED. Integral" off \
    "4" "-->> Atualizar chrome e firefox" off \
    "5" "-->> Bloquear opção alterar usuário/senha" off \
    "6" "-->> Criar atalho Plataformas Educacionais area de trabalho" off \
    "7" "-->> Desabilitar proxy dos navegadores no Linux Mint" off \
    "8" "-->> Desativar bloqueio de tela" off \
    "9" "-->> Desativar Touchscreen Netbooks Verdes" off \
    "10" "-->> Desativar usuário convidado" off \
    "11" "-->> Instalar ATOM e VSCODE" off \
    "12" "-->> Instalar Certificado" off \
    "13" "-->> Instalar driver do Mblock" off \
    "14" "-->> Instalar Medidor" off \
    "15" "-->> Instalar Scratch" off \
    "16" "-->> Instalar VNC no Linux" off \
    "17" "-->> Limpar o UPDATE" off \
    "18" "-->> Página inicial das Plataformas no Chrome e Firefox" off \
    "19" "-->> Preparar máquina para atualização" on \
    "20" "-->> Remover usuários Guest" off \
    "21" "-->> Remover/Resetar plano de fundo" off)
    
    #dialog --msgbox "Opções Selecionadas: $CHECKLIST" 10 45
    
clear

echo -n >/tmp/itens.txt

echo -n >/tmp/itens1.txt

echo -n >/tmp/itens2.txt

echo -e "$CHECKLIST" >/tmp/itens.txt

sed 's/ /\n/g' /tmp/itens.txt >/tmp/itens1.txt

cat /tmp/itens1.txt | awk -F " " '{print "SELECIONADOS" $1 }' >/tmp/itens2.txt

cat /tmp/itens2.txt | sed -r 's/(SELECIONADOS)//g'|
while read  SELECIONADOS
do
    	   	if [ "$SELECIONADOS" -eq 1 ];then

echo -e "\e[37;44;1m==============================AJUSTAR HORA E DATA=============================== \e[m\n"

			atualizahoraedata;
					
echo -e "\e[37;44;1m============================FIM AJUSTAR HORA E DATA============================= \e[m\n"

		elif [ "$SELECIONADOS" -eq 2 ];then

echo -e "\e[37;44;1m====================ATIVAR PLANO DE FUNDO PADRÃO DO ESTADO===================== \e[m\n"
		
			ativartrocafundodetela;
	
echo -e "\e[37;44;1m==================FIM ATIVAR PLANO DE FUNDO PADRÃO DO ESTADO=================== \e[m\n"

		elif [ "$SELECIONADOS" -eq 3 ];then

echo -e "\e[37;44;1m====================ATIVAR TAP NOTEBOOKS ED. INTEGRAL===================== \e[m\n"
		
			ativartap;
	
echo -e "\e[37;44;1m==================FIM ATIVAR TAP NOTEBOOKS ED. INTEGRAL=================== \e[m\n"

		elif [ "$SELECIONADOS" -eq 4 ];then
		
echo -e "\e[37;44;1m===================ATUALIZAR NAVEGADORES CHROME E FIREFOX===================== \e[m\n"

			atualizaNavegadores;

echo -e "\e[37;44;1m=======================FIM ATUALIZAÇÃO DE NAVEGADORES========================== \e[m\n"

		elif [ "$SELECIONADOS" -eq 5 ];then

echo -e "\e[37;44;1m======================BLOQUEAR OPÇÃO ALTERAR USUÁRIO/SENHA====================== \e[m\n"
			
			bloquearaplicativos;

echo -e "\e[37;44;1m====================FIM BLOQUEAR OPÇÃO ALTERAR USUÁRIO/SENHA==================== \e[m\n"	


		elif [ "$SELECIONADOS" -eq 6 ];then
		
echo -e "\e[37;44;1m=================INSERIR ATALHO PLATAFORMAS NA AREA DE TRABALHO================= \e[m\n"

			atalhopaginainicial;
		
echo -e "\e[37;44;1m===============FIM INSERIR ATALHO PLATAFORMAS NA AREA DE TRABALHO=============== \e[m\n"

		elif [ "$SELECIONADOS" -eq 7 ];then

echo -e "\e[37;44;1m======================DESABILITANDO PROXY NAVEGADORES=========================== \e[m\n"

			desabilitar_proxy;
					
echo -e "\e[37;44;1m====================FIM DESABILITANDO PROXY NAVEGADORES========================== \e[m\n"
		
		elif [ "$SELECIONADOS" -eq 8 ];then

echo -e "\e[37;44;1m============================DESATIVAR BLOQUEIO DE TELA============================ \e[m\n"

			desbloquea_tela;
					
echo -e "\e[37;44;1m==========================FIM DESATIVAR BLOQUEIO DE TELA========================== \e[m\n"
					
		elif [ "$SELECIONADOS" -eq 9 ];then    		

echo -e "\e[37;44;1m==================DESATIVAR TOUCHSCREEN NETBOOKS VERDINHOS====================== \e[m\n"
		 	
		 	desativa_touch;
		 	
echo -e "\e[37;44;1m===============FIM DESATIVAR TOUCHSCREEN NETBOOKS VERDINHOS==================== \e[m\n"

		elif [ "$SELECIONADOS" -eq 10 ];then    		

echo -e "\e[37;44;1m==========================DESATIVAR USUÁRIO CONVIDADO========================== \e[m\n"
		 	
		 	desativa_convidado;
		 	
echo -e "\e[37;44;1m=======================FIM DESATIVAR USUÁRIO CONVIDADO========================= \e[m\n"
	
		elif [ "$SELECIONADOS" -eq 11 ];then

echo -e "\e[37;44;1m============================INSTALAR ATOM E VSCODE================================ \e[m\n"

			atomvscode;

echo -e "\e[37;44;1m==========================FIM INSTALAR ATOM E VSCODE============================== \e[m\n"

		elif [ "$SELECIONADOS" -eq 12 ];then

echo -e "\e[37;44;1m============================INSTALAR CERTIFICADO================================ \e[m\n"

			instalacertificado;

echo -e "\e[37;44;1m==========================FIM INSTALAR CERTIFICADO============================== \e[m\n"

		elif [ "$SELECIONADOS" -eq 13 ];then

echo -e "\e[37;44;1m============================INSTALAR DRIVER MBLOCK================================ \e[m\n"

			driver_mblock;

echo -e "\e[37;44;1m==========================FIM INSTALAR DRIVER MBLOCK============================== \e[m\n"

		elif [ "$SELECIONADOS" -eq 14 ];then

echo -e "\e[37;44;1m============================INSTALANDO MEDIDOR MEC================================ \e[m\n"

			medidor_mec;

echo -e "\e[37;44;1m==========================FIM INSTALANDO MEDIDOR MEC============================== \e[m\n"


    		elif [ "$SELECIONADOS" -eq 15 ];then

echo -e "\e[37;44;1m==============================INSTALAR SCRATCH================================== \e[m\n"

			instalascratch;

echo -e "\e[37;44;1m============================FIM INSTALAR SCRATCH================================ \e[m\n"


		elif [ "$SELECIONADOS" -eq 16 ];then

echo -e "\e[37;44;1m================================INSTALANDO VNC==================================== \e[m\n"

			instalar_vnc;

echo -e "\e[37;44;1m==============================FIM INSTALANDO VNC================================== \e[m\n"
    	
    		elif [ "$SELECIONADOS" -eq 17 ];then

echo -e "\e[37;44;1m===========================LIMPANDO O APT-GET UPDATE============================== \e[m\n"

			limpar_update;

echo -e "\e[37;44;1m=========================FIM LIMPANDO O APT-GET UPDATE============================ \e[m\n"

			elif [ "$SELECIONADOS" -eq 18 ];then

echo -e "\e[37;44;1m==============ADICIONAR PAGINA INICIAL PLATAFORMAS NOS NAVEGADORES================ \e[m\n"

			pagina_inicial_navegadores;

echo -e "\e[37;44;1m=============FIM ADICIONAR PAGINA INICIAL PLATAFORMAS NOS NAVEGADORES============= \e[m\n"

			elif [ "$SELECIONADOS" -eq 19 ];then    		

echo -e "\e[37;44;1m==============INSTALAR REPOSITÓRIO DA CELAPAR E ATUALIZAR PACOTES============== \e[m\n"
		 	
		 	PREPARAR_MAQUINA;
		 	
echo -e "\e[37;44;1m==========================FIM DA PREPARAÇÃO MÁQUINA============================ \e[m\n"					
	
			elif [ "$SELECIONADOS" -eq 20 ];then

echo -e "\e[37;44;1m=============================EXCLUIR USUARIOS GUEST============================= \e[m\n"

			limparguests;
			
echo -e "\e[37;44;1m===========================FIM EXCLUIR USUARIOS GUEST=========================== \e[m\n"
				
		elif [ "$SELECIONADOS" -eq 21 ];then

echo -e "\e[37;44;1m===========================RESTAURAR O PLANO DE FUNDO=========================== \e[m\n"

			resetbackgrounds;
					
echo -e "\e[37;44;1m=========================FIM RESTAURAR O PLANO DE FUNDO========================= \e[m\n"

			
		fi
	
	done
		
fi

if [ "$OPCAO" -eq 2 ]; then
PREPARAR_MAQUINA
	#INÍCIO ATUALIZAÇÃO COMPLETA DAS MÁQUINAS DESSE MODELO

case $MODELO in

#MODELO NETBOOKS VERDINHOS			
        Positivo_Duo_ZE3630)
	cd /tmp
		wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-verdinhos.sh -O p2-verdinhos.sh && bash p2-verdinhos.sh $meuip_rede "$INEP_ESCOLA"                         
	     	
	;;

#MODELO DESKTOP POSITIVO D610
			D610) 
               cd /tmp
		            wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-d610.sh -O p2-d610.sh && bash p2-d610.sh $meuip_rede "$INEP_ESCOLA"
			    
			         ativartrocafundodetela
			;;
#MODELO DESKTOP POSITIVO D480
			POS-EIB85CZ) 
            		cd /tmp
		       	wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-d480.sh -O p2-d480.sh && bash p2-d480.sh $meuip_rede "$INEP_ESCOLA"
		;;
#MODELO DESKTOP POSITIVO D3400
			D3400) 
          		  cd /tmp

			    wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-d3400.sh -O p2-d3400.sh && bash p2-d3400.sh $meuip_rede "$INEP_ESCOLA"
			;;
			
#MODELO DESKTOP POSITIVO D3400 (EXCESSÃO COM PLACA DIREFENTE)
			
			POSITIVO_MASTER) 
          		  cd /tmp
			    wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-d3400.sh -O p2-d3400.sh && bash p2-d3400.sh $meuip_rede "$INEP_ESCOLA"
			;;
#MODELO DESKTOP DELL
			OptiPlex*) 
           		 cd /tmp
			    wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-dell.sh -O p2-dell.sh && bash p2-dell.sh $meuip_rede "$INEP_ESCOLA"
			;;
            
#MODELO EDUCATRON
		    *C1300*)
         	cd /tmp
		       	wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-educatron.sh -O p2-educatron.sh && bash p2-educatron.sh $meuip_rede "$INEP_ESCOLA"
			;;
#MODELO NOTEBOOK EDUCAÇÃO INTEGRAL
			N4340)
			cd /tmp
			   	wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-integral.sh -O p2-integral.sh && bash p2-integral.sh $meuip_rede "$INEP_ESCOLA"
			;;
			
			*)
     			 echo "Acesso Linux nao identificado ainda"
     			 echo "MODELO $MODELO"

  			;;	 		 	
 	
		
        esac
			
#FIM ATUALIZAÇÃO COMPLETA DAS MÁQUINAS DESSE MODELO
	
fi

if [ "$OPCAO" -eq 3 ]; then
PREPARAR_MAQUINA 
#ATUALIZAÇÃO COMPLETA DE TODAS AS MÁQUINAS DA ESCOLA
	cd /tmp

         wget https://raw.githubusercontent.com/crtepitanga/scripts/main/p2-completo.sh -O p2-completo.sh && bash p2-completo.sh $meuip_rede "$INEP_ESCOLA"


fi
#FIM ATUALIZAÇÃO COMPLETA DE TODAS AS MÁQUINAS DA ESCOLA 








