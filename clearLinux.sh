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

# Se ejecuta al pulsar Ctrl+C
trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[!]Saliendo con interrupción${endColour}"
	exit 1
}

# Panel de ayuda
function helpPanel(){
	clear
	echo -e "\n${redColour}[!] Uso: ./cleanLinux.sh${endColour}"
	echo -e "\n\t${grayColour}[-i]${endColour}${yellowColour} Mostrar espacio eliminable${endColour}${blueColour} (Ejemplo: -i algo)${endColour}"
	echo -e "\t${grayColour}[-c]${endColour}${yellowColour} Limpiar sistema${endColour}${blueColour} (Ejemplo: -c algo)${endColour}"
	echo -e "\t${grayColour}[-m]${endColour}${yellowColour} Mejorar rentimiento del sistema${endColour}${blueColour} (Ejemplo: -m algo)${endColour}"
	echo -e "\t${grayColour}[-h]${endColour}${yellowColour} Mostrar este panel de ayuda${endColour}\n"
	exit 0
}

# Información sobre espacio del sistema
function infoSize(){
	clear
	echo -e "\n\t${yellowColour}[*] Espacio total y libre del sistema ${endColour}\n"
	df -h
	echo -e "\n\t${yellowColour}[*] Tamaño de la cache de aplicaciones ${endColour}\n"
	sudo du -sh /var/cache/apt
	echo -e "\n\t${yellowColour}[*] Tamaño de cache de miniaturas ${endColour}\n"
	sudo du -sh ~/.cache/thumbnails
	echo -e "\n\t${yellowColour}[*] Tamaño del directorio \"/var\" ${endColour}\n"
	du -sch /var/*
	echo -e "\n\t${yellowColour}[*] Tamaño del directorio \"/tmp\" ${endColour}\n"
	du -sch /tmp
	echo -e "\n\t${yellowColour}[*] Tamaño del directorio \"/var/log\" ${endColour}\n"
	du -h /var/log/
	echo -e "\n\t${yellowColour}[*] Tamaño del directorio de usuario \"~\" ${endColour}\n"
	sudo du -bsh ~/
	echo -e "\n\t${yellowColour}[*] Uso de disco de \"journalctl\" ${endColour}\n"
	journalctl --disk-usage
	echo -e "\n\t${yellowColour}[*] Listado de kernels del sistema ${endColour}\n"
	sudo dpkg --list 'linux-image*'
	echo -e "\n\t${greenColour} Tarea finalizada${endColour}\n"
	exit 0
}

# Limpiar linux
function cleanLinux(){
	clear
	echo -e "\n\t${yellowColour}[*] Iniciando limpieza de linux ${endColour}\n"
	
	read -p "1.) ¿Eliminar paquetes de la cache de aplicaciones? (si/no): " resp
	if [ "$resp" == "si" ];	then
		apt-get clean
		apt purge
		apt-get autoclean
		apt autoremove
		sleep 3
		clear
	fi
	
	read -p "2.) ¿Eliminar cache de miniaturas? (si/no): " resp
	if [ "$resp" == "si" ];	then
		rm -rf ~/.thumbnails/
		sleep 3
		clear
	fi
	
	read -p "3.) ¿Eliminar logs de \"journalctl\"? (si/no): " resp
	if [ "$resp" == "si" ];	then
		journalctl --vacuum-time=5d
		journalctl --vacuum-size=100M
		sleep 3
		clear
	fi
	
	read -p "4.) ¿Eliminar todos los logs? (si/no): " resp
	if [ "$resp" == "si" ];	then
		rm -v /var/log/*log*
		sleep 3
		clear
	fi	

	read -p "5.) ¿Eliminar kernels antiguos? (si/no): " resp
	if [ "$resp" == "si" ];	then
		echo -e "\n\t${redColour}[!] Mejor hazlo a mano !${endColour}\n"
		echo -e "\t${redColour}sudo apt-get remove linux-image-VERSION"
		echo -e "\t${redColour}sudo apt-get purge linux-image-x.x.x.x-generic"
		sleep 3
		clear
	fi	

	echo -e "\n\t${greenColour} Tarea finalizada${endColour}\n"
	exit 0
}

# Hardening linux
function hardLinux(){
	clear
	echo -e "\n\t${yellowColour}[*] Iniciando hardening de linux ${endColour}\n"
	
	read -p "1.) ¿Deshabilitar \"journalctl\"? (si/no): " resp
	if [ "$resp" == "si" ];	then
		service rsyslog stop
		systemctl disable rsyslog
		sleep 3
		clear
	fi

	echo -e "\n\t${greenColour} Tarea finalizada${endColour}\n"
	exit 0
}

# main
parameter_counter=0

if [ "$(id -u)" == "0" ]; then
	while getopts ":i:c:m:h:" arg; do
		case $arg in
			i) infoSize;;
			c) cleanLinux;;
			m) hardLinux;;
			h) helpPanel;;
		esac
	done

	if [ $parameter_counter -eq 0 ]; then
		helpPanel
	elif [ $parameter_counter -eq 1 ]; then
		infoSize
	else
		helpPanel
	fi

else
	echo -e "\n${redColour}[!] Es necesario ejecutar como root${endColour}\n"
	exit 1
fi
