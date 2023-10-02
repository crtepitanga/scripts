#!/bin/bash


if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí instalar programas "
   exit 1
fi


 rm /var/lib/apt/lists/*

 rm /var/lib/apt/lists/partial/*

 apt-get clean

 apt-get update

