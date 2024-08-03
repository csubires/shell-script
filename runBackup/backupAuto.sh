#!/bin/bash
source ./../utils.sh


#Variables globales
FOLDER_USER="user"
NAME_BACKUP="_backup_linux_"
EXPLORER="nemo"
DATESTR="$(date +%Y%m%d)"

#Paths
MYCONFIG_FOLDER="/home/$FOLDER_USER/Documentos/Config/"
FOLDER_LIST="./folder_list.txt"
FILE_LIST="./file_list.txt"

# Se ejecuta al pulsar Ctrl+C
trap ctrl_c INT

function ctrl_c() {
    lg_prt "y" "\n[▲] Saliendo con interrupción"
	exit 1
}


# Panel de ayuda
function helpPanel() {
	clear
	
	lg_prt "wtw" "\n" "BACKUP LINUX AUTO" "\n"
	lg_prt "wob" "Uso:" "./backupAuto.sh" "<Opción>"
	
	lg_prt "bwr" "\t-r, --collection" "\tRecopilación de configuraciones y comandos" "Necesario ROOT"
	lg_prt "bwr" "\t-c, --compress" "\tCompresión y Cifrado del backup" "Necesario ROOT"
	lg_prt "bw" "\t-h, --help" "\t\tMostrar ayuda"
	
	lg_prt "wc" "\n Ejemplos:\n" "\t./backupAuto.sh -r"
	lg_prt "c" "\t./backupAuto.sh --compress\n"
	exit 0
}



# Recopilar todos los archivos de configuración del PC
function collection() {
	clear
	
	lg_prt "wtw" "\n" "RECOPILACIÓN DE CONFIGURACIONES Y COMANDOS" "\n\n"
	
	name_backup_folder="${MYCONFIG_FOLDER}${DATESTR}_backup_conf/"
	mkdir "${name_backup_folder}" 2>/dev/null
	
	counter=0
	while read -r line; do
		let counter++
		lg_prt "yw" "\tCopiando [$counter]" "\t$line"
		cp -R $line $name_backup_folder
	done < "./$FILE_LIST"
	
	lg_prt "yw" "\n\n\t[▲] Recopilando información con comandos" "Espere..."
	# Modulos python3 instalados manualmente
	ls "/home/$FOLDER_USER/.local/lib/python3.8/site-packages" > "${name_backup_folder}pip3_modules.txt"
	# Información sobre interfaces de redes
	ifconfig > "${name_backup_folder}ipconfig.txt" && ip r >> "${name_backup_folder}ipconfig.txt"
	# Modificaciones en el kernel
	sysctl -p > "${name_backup_folder}sysctl_mod.txt"
	# IPtable
    iptables -S > "${name_backup_folder}IPtables.txt"
    # Estado de servicios
    service --status-all > "${name_backup_folder}services.txt"
    # Programas flatpak
    flatpak list > "${name_backup_folder}flatpak.txt"

    lg_prt "g" "\t[✔] Archivos de configuración guardados en $name_backup_folder"
	lg_prt "ywyw" "\n\t[▲] Copiar manualmente" "\"Marcadores de firefox\"" "a" "$name_backup_folder"
	lg_prt "ywyw" "\t[▲] Copiar manualmente" "\"Configuración del cortafuegos (ufw)\"" "a" "$name_backup_folder \n"

	# Cambiar propietario y grupo para poder borrar carpeta
	chown "$FOLDER_USER:$FOLDER_USER" -R $name_backup_folder
    
	exit 0
}


# Comprimir y cifrar la colección
function compress() {
	clear
	# Crear e ir a la carpeta temporal
	TEMP_FOLDER="$(mktemp -d)"


	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	lg_prt "wtw" "\n" "COMPRESIÓN Y CIFRADO DEL BACKUP" "\n\n"
	sleep 2
	
	KEY="$(echo 'MVEydzNlNHI1dDZ5Cg==' | base64 -d | sha256sum | head -c 32 | base64)"
	numrand="$(shuf -i 1-100000 -n 1)"
	
	lg_prt "yw" "\n Fecha:" "\t$DATESTR"
	lg_prt "yw" "Listado:" "\t$FOLDER_LIST"
	lg_prt "yw" "\n\t[▲] Comprimiento." "Espere..."
	
	#zip --password 1Q2w3e4r5t6y "${DATESTR}_backup_linux_${numrand}.cmp" -9 -r@ < "${listado}"
	7z a -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -mhe=on -p"${KEY}" -t7z "${TEMP_FOLDER}/${DATESTR}${NAME_BACKUP}${numrand}.cmp" @"${FOLDER_LIST}"

	# Cambiar propietario y grupo para poder borrar carpeta
	chown "$FOLDER_USER:$FOLDER_USER" -R "$TEMP_FOLDER"
	chmod 666 "${TEMP_FOLDER}/${DATESTR}${NAME_BACKUP}${numrand}.cmp"
	sleep 2
	# Abrir la carpeta temporal en el explorador
	eval "$EXPLORER $TEMP_FOLDER"
	exit 0
}



# Control o MENU
if [[ $1 && -d $MYCONFIG_FOLDER ]]; then 

	# MENU
	case "$1" in
		-r|--collection)	[[ "$(id -u)" == "0" ]] && collection || lg_prt "r" "[✖] Es necesario tener permisos ROOT";;
		-c|--compress) 		[[ "$(id -u)" == "0" ]] && compress || lg_prt "r" "[✖] Es necesario tener permisos ROOT";;
        -h|--help|*) 		helpPanel;;
	esac

	exit 0
else 
	lg_prt "ryr" "[✖] Parametros insuficientes o no existe" "\"$MYCONFIG_FOLDER\"." "Usa --help"

fi
