#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Variables globales
DIR=""

# Se ejecuta al pulsar Ctrl+C
trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[!] Saliendo con interrupción${endColour}"
	IFS=$SAVEIFS
	exit 1
}

echo -e "\n${blueColour} [!] Sincronizando carpetas${endColour}\n"
rsync -a --progress --delete ~/Documentos/forexport /media/veracrypt7

echo -e "\n${blueColour} [!] Comprobando las diferencias${endColour}\n"
diff -r ~/Documentos/forexport /media/veracrypt7/forexport
