#!/bin/bash

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root"
   echo "sudo  bash  $0"
   exit 1
fi

LOCK='/var/run/instalandocertificadofiltro.lock'
PID=$(cat $LOCK 2>/dev/null)
if [ ! -z "$PID" ] && kill -0 $PID 2>/dev/null
then
   echo already running
   exit 1
fi
trap "rm -f $LOCK ; exit" INT TERM EXIT
echo $$ > $LOCK

cd /tmp/
if [ -e "/tmp/caf.deb.b64" ]; then
   rm /tmp/caf.deb.b64
fi
if [ -e "/tmp/caf.deb" ]; then
   rm /tmp/caf.deb
fi
cat > "/tmp/caf.deb.b64" << EndOfThisFileIsExactHereNowReally
ITxhcmNoPgpkZWJpYW4tYmluYXJ5ICAgMTY2MjQ4MDgwNyAgMCAgICAgMCAgICAgMTAwNjQ0ICA0
ICAgICAgICAgYAoyLjAKY29udHJvbC50YXIuenN0IDE2NjI0ODA4MDcgIDAgICAgIDAgICAgIDEw
MDY0NCAgNzEzICAgICAgIGAKKLUv/QBoBRYANiZ1J+Cy6AGoSiboTZQmxocriOTeCgIq16z38bXF
L6mRWnOcMphh8GObH2kAagBqAE6aJjfh+xjt3AuZm0g+pTDjGtH5q1/ib5rCamf+WL+A5HntvJqW
//h6D3sznVgEo1+eAzki1DiHqqnynoMeZVmsR00VRVmovbna2CQoW3sh9wszzqDKITdZVoVylqVy
FepBDqoqy0FNCi29x94Ogz/lWPvg7x8W+wspnSF2wvFfzndACj/Ics2uC3+f8I+sTgmHF34cQ2oj
zvj1Ge7gVjJ85o24QuMNmczGL/dznXCi/fI3y7MT70Jjam2OKhjXa1I/wJ9hnNjM9yOW9T/f0JWT
EALUCSYKm/YXdnC7OGsKEBYLGouKDAN+6TDjSaUW8zenyNY0NhrFP/IZuXzcVvp3WM9fF+imSJLk
gUW3ssKQSWGWFyhuO/G7C/5mnIlVG7tOl7yJxB/D2N3B8Gp1Xi1AoOLey7jOjO2nSVAHBc+52adx
hcXyKPcoy7OqioMgz4XaeZ4f33VeHiOnkd/HWc0mtuOB/3ZHiL8TEgC63wBmckqz2jpeNoxjkUfy
k/VXKzEYl4yITJoEQCLx98D6GF4AbWVv6nS/FoMep4QFnm+UDNrEX+Q4WiBwRGTKaDpRN0gPu69Y
gStoMI8K6xwiGP8pPf+oQ2wHoHQIxwD6poNVxIhlogETBnIJ9dSgjyNshEw4NQDKwAUHMRQS8LDd
DQ0IMhI8piUKCF22TkHxonIxBiAADyNooLAFd8brQK4vbqhGBrIcKZGY320BCb3QEwEyV7dwYN0W
1nl0JKT2P20PBXBwYLC0emPHBkhdCwywGgg8iB0wpSgUUYMJMAUFwB7AWyzhkibgjaR8VzGmowz4
A0oXQCt4Sl8gbWOigoUi2MBSYJgDi+MBn+RZusPBcvYHlHy9/ArBDj4oAPPJuQEKZGF0YS50YXIu
enN0ICAgIDE2NjI0ODA4MDcgIDAgICAgIDAgICAgIDEwMDY0NCAgMjEwNCAgICAgIGAKKLUv/QBo
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
EndOfThisFileIsExactHereNowReally
base64 -d /tmp/caf.deb.b64 > /tmp/caf.deb
mv /tmp/caf.deb /tmp/ca-filtrowebseed.deb

wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
if [ ! $? = 0 ]; then
   wget -q -O - https://jonilso.web178.kinghost.net/linux_signing_key.pub | sudo apt-key add -
fi
apt-get update 
apt-get -y install libnss3-tools
if [ -e "/etc/linuxmint/info" ]; then
   versaoMint=$(cat /etc/linuxmint/info | grep 'RELEASE=' | cut -d'=' -f2 | head -1)
   if [ "$versaoMint" = "18.3" ]; then
      apt-get install -y dpkg
   fi
fi
if [ "$(hostnamectl | grep 'Operating System' | grep 'Ubuntu 16.04' | wc -l)" = 1 ]; then
   apt-get install -y dpkg
fi

dpkg -i ca-filtrowebseed.deb
rm -f $LOCK
exit 0
