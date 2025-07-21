#!/bin/bash
# Script para atualização dos Computadores Amarelos e CCE dos Laboratórios de Informática das Escolas
# Por: Pedro Peraçoli / CRTE / ASSIS CHATEAUBRIAND em 22/06/2022
# Colaboração: Jonilso - CRTE/NRE de Guarapuava
# Versão 2 de 26/09/2022 - Instalação do Certificado de Segurança - Script cert.sh - Colaboração: Jonilso - CRTE/NRE de Guarapuava
# Versão 3 de 13/03/2023 - Script Repositórios Celepar - Colaboração: Jonilso - CRTE/NRE de Guarapuava
# Versão 4 de 23/05/2023 - Script s.sh Instalação Scratch - 23/05/2023 - Colaboração: Jonilso - CRTE/NRE de Guarapuava
# Versão 5 de 29/05/2023 - Script Icones-Area-de-Trabalho.sh - 29/05/2023 - Sequência Ícones Área de Trabalho
# Versão 6 de 30/05/2023 - Script bloquearapps.sh Desativar acesso aos usuarios aos aplicativos desejados - 30/05/2023 - Colaboração: Jonilso - CRTE/NRE de Guarapuava

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root!"
   exit 1
fi

#---------------Bloquear Área de Trabalho---------------#
cd /home
rm /home/.usuarios.txt 2>> /dev/null
ls /home/ >> /home/.usuarios.txt
usuario=/home/.usuarios.txt

for usuario in *; do
   if [ $usuario  =  $usuario ]; then

       sudo cp /usr/share/applications/thunar.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/google-chrome.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/firefox.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/libreoffice-writer.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/libreoffice-calc.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/libreoffice-impress.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /opt/libreoffice7.0/share/xdg/writer.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /opt/libreoffice7.0/share/xdg/calc.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /opt/libreoffice7.0/share/xdg/impress.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/atom.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/code.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/packettracer73.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/gns3.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/mysql-workbench.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/scratch-desktop.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/gimp-2.10.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo chown $usuario.$usuario -R /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo chown -h $usuario /home/$usuario/Área\ de\ trabalho/*.desktop 1>/dev/null 2>/dev/null
       chmod 755 /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       chmod +x /home/$usuario/Área\ de\ trabalho/*.desktop 1>/dev/null 2>/dev/null
       ##sudo rm -Rf /home/$usuario/.config/google-chrome/
       ##sudo rm -Rf /home/$usuario/.mozilla/
       
       echo "Area de trabalho desbloqueada para o usuário: $usuario "
      
       continue
       fi
       sudo cp -r /home/escola/Área\ de\ trabalho/paginainicial.desktop /home/administrador/Downloads/ 1>/dev/null 2>/dev/null
       sudo cp -r /home/$usuario/Área\ de\ trabalho/* /home/$usuario/Documentos/ 1>/dev/null 2>/dev/null
       sudo rm -rf /home/$usuario/Documentos/*.desktop 1>/dev/null 2>/dev/null
       sudo rm -rf /home/$usuario/Área\ de\ trabalho/* 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/thunar.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/google-chrome.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/firefox.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/libreoffice-writer.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/libreoffice-calc.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/libreoffice-impress.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /opt/libreoffice7.0/share/xdg/writer.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /opt/libreoffice7.0/share/xdg/calc.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /opt/libreoffice7.0/share/xdg/impress.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/atom.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/code.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/packettracer73.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/gns3.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/mysql-workbench.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/scratch-desktop.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp /usr/share/applications/gimp-2.10.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo cp -r /home/administrador/Downloads/paginainicial.desktop /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo chown root.root -R /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       sudo chown -h $usuario /home/$usuario/Área\ de\ trabalho/*.desktop 1>/dev/null 2>/dev/null
       chmod +x /home/$usuario/Área\ de\ trabalho/*.desktop 1>/dev/null 2>/dev/null
       chmod 755 /home/$usuario/Área\ de\ trabalho/ 1>/dev/null 2>/dev/null
       ##sudo rm -Rf /home/$usuario/.config/google-chrome/
       ##sudo rm -Rf /home/$usuario/.mozilla/
       chmod -R 755 /home/$usuario/.config/xfce4/ 1>/dev/null 2>/dev/null
       echo -e "\e[44mPermissões criadas para o usuário $usuario\e[0m "
done

#---------------Fim Desbloquear Área de Trabalho---------------#


#-----------------------------------------Ícones Área de Trabalho-----------------------------------#
mkdir -p /tmp/.IconesAreadeTrabalho 2>> /dev/null
IconesAreadeTrabalho="/tmp/.IconesAreadeTrabalho/IconesAreadeTrabalho.tar.gz"
rm -f "$IconesAreadeTrabalho" >> /dev/null 2>&1
cat > "${IconesAreadeTrabalho}.b64" << EndOfThisFileIsExactHereNowReally
H4sIAJOsgGQAA+1cTXPiOBDlzK/wfcugb2UOOcxht2pue9jb1NSWx4jgGsAp2dlw3d+2f2yFzTCB
YFmyHFEJ/S5UJejJIHX361aLL3m5VVX6WassXaj0L519z1bl/PNiU2yLqtbZotTzhap+1OXjvDBv
rmZVrpXaohR/QmyHEcUznU9sQAgJxhLziiVHL18PkCjBjFFGEJUUJYaSIDlJkJV1JDxVdabNo2Qv
P/GF9/X9v/0kyfH1neDrbnlY3fQfpaui3KZshtGM/pbqfFms1d/LUm+y+tv08Of7Wj+p6fTazw0Y
B18u2/+fapE9lA/G4EONf+Jl/4Sjvf0jxgjYfwyA/d82Ouz/9yov19nR9sPm2Fs45xb7R439M4SN
n0AiQYRyiiYJH+cj2nHj9t+x/k76j9+x3R2TvRGgx/9jSnjj/7lZf0HYXv9hAf4/Cob6/6/zVblR
85NvZf7fv2YbJQuVNNtobfbRQ1k+rFWar7R59+ww07epLp/v8dS4mHvkTLUuvmtVLpdFruSMp8+6
qJU+paSelGYnZ3W+Sg8kp2SoIcNDny/P1vkpIfN8unr1tM30pYdy58jLxdnXLj0ZloVWy3J3SkLC
1q7YPGpVVaec3JMzq8vNKYP4yXBto3pH6PD/f+hso55L/SMw9Dfwiv/Y6H9CBMIQ/2PATf+dBX7K
0U7iTw6pX4O++I+4NOtPuFl7QsVe/5ntwiH+x0Bg/FftPunx+MghGnYyOQUg1+dwijyuZC4SpJPL
Qxl1crwOgfhMtHQOfS0MzvVOO/RMdlx7uwJGRm/8t5b/SH/yN+n3/0TgY/xHguzrfyYXBP8fA4H+
f3ncJ8PyF9t4J8dvIxiQMdro+nMp22hLuuIw2pqp3g3/TpzioY3PI4x5PJZFLlzbYD4Yhut/Tt5A
/1MqSav/Efj/GAD9D/of9P/twu7/x5nD//yPmJAA9b8YcDr/C5xjwPkv41D/jYJB+s8n+Z845P9E
/Dz/lUQ29V9Bof8vCt5K/4WptjHE0YDs35UrTEX2VwI6h7qUVDoHe9UQXL+KAGFvqadc2ypuB871
34A5/M9/GeEE4n8M9Pf/hs8x4PxfIg7rHwMh/X+tDBQs8P7Hy/4/SXDT/0cI9P9FAfT/uSoi6P+D
/r+Ph8H3f1ybvycO+b8kx/5vStr7Pxj6v6Ig0P8//tono3hsHz4nL2Il7M/ErcM9gpvP5+qPHFY2
l7BhJfDqircy9Ucf63B76Lm25XwMBN7/7Bf/E7/73+Lg/zkD/x8DcP/zthGe//cfA7nn/xgxRJr8
H0P+HwWQ/0P+D/n/7SLg/N/ptz/26PP/bf8nJYQyxEXT/ykI6L8ouFr/p/OZ9+i9AJcbN52PrUft
KH3txJx7El67duf2ios+/TwwQP/nLSAw/3fqAXOv/xpCzpr8X8D9ryiA+i/Uf0OyIqj/vm8M0v8e
Z3979Pr/X/2/AkvW3P+ScP8rCqD/F/p/u29/Qf/vR0fY7z+4lYBcz/+kkEy0+p+C/48DOP+7bXid
/w2cA3nf/+OYQP9/FLjXf4bP4bX+7f0PygWsfwx0rP+oc/iv/14vwPoDAADAW+J/84jlAQBoAAA=
EndOfThisFileIsExactHereNowReally
base64 -d "${IconesAreadeTrabalho}.b64" >> "$IconesAreadeTrabalho"
cd /tmp/.IconesAreadeTrabalho/
tar -xzf /tmp/.IconesAreadeTrabalho/IconesAreadeTrabalho.tar.gz

echo -e "\nDescompactou pastas Ícones Área de Trabalho - OK"

sudo cp -rf /tmp/.IconesAreadeTrabalho/Icones-Area-de-Trabaho/Administrador/desktop/ /home/administrador/.config/xfce4/ 1>/dev/null 2>/dev/null
sudo cp -rf /tmp/.IconesAreadeTrabalho/Icones-Area-de-Trabaho/Escola/desktop/ /home/escola/.config/xfce4/ 1>/dev/null 2>/dev/null
sudo cp -rf /tmp/.IconesAreadeTrabalho/Icones-Area-de-Trabaho/Aluno/desktop/ /home/aluno/.config/xfce4/ 1>/dev/null 2>/dev/null
sudo cp -rf /tmp/.IconesAreadeTrabalho/Icones-Area-de-Trabaho/Alunos/desktop/ /home/alunos/.config/xfce4/ 1>/dev/null 2>/dev/null
sudo cp -rf /tmp/.IconesAreadeTrabalho/Icones-Area-de-Trabaho/Professor/desktop/ /home/professor/.config/xfce4/ 1>/dev/null 2>/dev/null
sudo cp -rf /tmp/.IconesAreadeTrabalho/Icones-Area-de-Trabaho/Pedagogico/desktop/ /home/pedagogico/.config/xfce4/ 1>/dev/null 2>/dev/null
sudo cp -rf /tmp/.IconesAreadeTrabalho/Icones-Area-de-Trabaho/Framework/desktop/ /home/framework/.config/xfce4/ 1>/dev/null 2>/dev/null

sudo chmod +x /home/administrador/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chmod +x /home/pedagogico/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chmod +x /home/escola/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chmod +x /home/aluno/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chmod +x /home/alunos/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chmod +x /home/professor/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chmod +x /home/framework/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null

sudo chown -h administrador /home/administrador/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown -h pedagogico /home/pedagogico/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown -h escola /home/escola/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown -h aluno /home/pedagogico/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown -h alunos /home/pedagogico/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown -h professor /home/pedagogico/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown -h framework /home/framework/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null

sudo chown administrador.administrador -R /home/administrador/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown pedagogico.pedagogico -R /home/pedagogico/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown escola.escola -R /home/escola/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown aluno.aluno -R /home/escola/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown alunos.alunos -R /home/escola/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown professor.professor -R /home/escola/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null
sudo chown framework.framework -R /home/framework/.config/xfce4/desktop/ 1>/dev/null 2>/dev/null


echo -e "\e[44m\nÍcones Área de Trabalho, defenidos com Sucesso!!!\e[0m\n "


#-----------------------------------------Fim Ícones Área de Trabalho-----------------------------------#


#-----------------------------------------Ativar acesso aos usuarios aos aplicativos desejados-----------------------------------#

USUARIOS=( "pedagogico" "professor" "escola" "Aluno" "aluno" "alunos" )
APLICATIVOS=( "/usr/bin/exo-desktop-item-edit" "/usr/bin/nm-applet" "/usr/bin/xfce4-appearance-settings" "/usr/bin/users-admin" "/usr/bin/mugshot" "/usr/bin/mate-about-me" "/usr/bin/mintupdate" "/usr/bin/mintinstall" "/usr/bin/nm-connection-editor" )
for USUARIO in "${USUARIOS[@]}" ; do 
   if [ $(grep "^${USUARIO}:" /etc/passwd | wc -l) -eq 0 ]; then
      echo "Usuario $USUARIO nao consta neste Linux"
      continue
   fi
   for APLICATIVO in "${APLICATIVOS[@]}" ; do
      if [ -x "$APLICATIVO" ]; then
         /bin/setfacl -b "$APLICATIVO"
      fi
   done
   echo "Aplicativos alterar usuario e senha desbloqueados para $USUARIO"
echo "Aplicativo Aparencia desbloqueado para $USUARIO"
done

#-----------------------------------------Fim Ativar acesso aos usuarios aos aplicativos desejados-----------------------------------#

