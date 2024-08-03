#!/bin/bash
source utils.sh


# Variables globales
USER="user"							# Usuario local
filepass="/etc/openvpn/.secret"		# Archivos de login de VPN

# Archivos de configuración VPN
declare -A fileovpn
fileovpn[CA149]="/home/${USER}/Documentos/VPN/CA149/vpnbook-ca149-tcp443.ovpn"
fileovpn[CA196]="/home/${USER}/Documentos/VPN/CA196/vpnbook-ca196-tcp443.ovpn"
fileovpn[DE20]="/home/${USER}/Documentos/VPN/DE20/vpnbook-de20-tcp443.ovpn"
fileovpn[FR200]="/home/${USER}/Documentos/VPN/FR200/vpnbook-fr200-tcp443.ovpn"
fileovpn[FR231]="/home/${USER}/Documentos/VPN/FR231/vpnbook-fr231-tcp443.ovpn"
fileovpn[PL134]="/home/${USER}/Documentos/VPN/PL134/vpnbook-pl134-tcp443.ovpn"
fileovpn[US1]="/home/${USER}/Documentos/VPN/US1/vpnbook-us1-tcp443.ovpn"
fileovpn[US2]="/home/${USER}/Documentos/VPN/US2/vpnbook-us2-tcp443.ovpn"



# Se ejecuta al pulsar Ctrl+C
trap ctrl_c INT

function ctrl_c() {
    lg_prt "y" "\n[▲] Saliendo con interrupción"
	exit 1
}


# Panel de ayuda
function helpPanel() {
	clear
	
	lg_prt "wtw" "\n" "OPEN VPN STARTER" "\n"
	lg_prt "wobv" "Uso:" "./vpnStart.sh" "<Opción>" "<Country>"
	
	lg_prt "bwr" "\t-c, --country" "\tIniciar conexión con una VPN" "Necesario ROOT"
	lg_prt "vyw" "\t\tCA149" "\tCANADÁ" "(p2p)"
	lg_prt "vyw" "\t\tCA196" "\tCANADÁ" "(Solo web)"
	lg_prt "vyw" "\t\tDE20" "\tALEMANIA" "(p2p)"
	lg_prt "vyw" "\t\tFR200" "\tFRANCIA" "(p2p)"
	lg_prt "vyw" "\t\tFR231" "\tFRANCIA" "(Solo web)"
	lg_prt "vyw" "\t\tPL134" "\tPOLONIA" "(p2p)"
	lg_prt "vyw" "\t\tUS1" "\tESTADOS UNIDOS" "(Solo web)"
	lg_prt "vyw" "\t\tUS2" "\tESTADOS UNIDOS" "(Solo web)"
	
	lg_prt "bwr" "\n\t-p, --passwrd" "\tCambiar la contraeña" "Necesario ROOT"
	lg_prt "bwr" "\t-r, --reset" "\tResetear la conexión" "Necesario ROOT"
	lg_prt "bw" "\t-h, --help" "\tMostrar ayuda"
	
	lg_prt "wc" "\n Ejemplos:\n" "\t./vpnStart.sh -c FR231"
	lg_prt "c" "\t./vpnStart.sh --reset\n"
	exit 0
}


# Activar la VPN
function startVPN() {
	clear

	# Comprobar si el cortafuegos está activo
	if sudo ufw status | grep -q inactivo$; then
		lg_prt "y" "\n[▲] El cortafuegos está deshabilitado\n"
		# Pedir confirmación
		read -p "¿Habilitar cortafuegos? (S/N): " -n 1 -r
		[[ $REPLY =~ ^[Ss]$ ]] && lg_prt "w" " \n"  || exit 1		
	    ufw enable
	    sleep 3
	    clear
	fi
	
	if [[ "${fileovpn[$1]}" ]]; then
		lg_prt "yw" "\n\tArchivo OVPN:" "${fileovpn[$1]}"
		lg_prt "yw" "\tArchivo PASS:" "$filepass\n"
		openvpn --auth-nocache --config ${fileovpn[$1]} --auth-user-pass $filepass
		exit 0
	else
		lg_prt "ryr" "\n[✖] El país" "\"$1\"" "no está disponible\n"
		exit 1
	fi
}

# Cambiar la contraseña del archivo de login del VPN
function changePsswd() {
	clear

	lg_prt "yw" "\n\tArchivo PASS:" "\t$filepass"
	lg_prt "vw" "\n\tUser:" "\t\t$(head $filepass -n 1)"
	lg_prt "vw" "\tOld Passwrd:" "\t$(tail $filepass -n 1)"
	lg_prt "vg" "\tNew Passwrd:" "\t$1"
	sed -i "2s/.*/$1/" $filepass
	lg_prt "g" "\n [✔] Contraseña modificada correctamente"
	exit 0
}

# Resetear conexión
function resetConnection() {
	clear
	
	lg_prt "yw" "[▲] Reseteando conexión" "Espere..."
	service network-manager restart
	sleep 3
	#clear
	lg_prt "g" "\n [✔] Conexión reseteada"
	exit 0
}



if [[ "$(id -u)" == "0" ]]; then

	# Control o MENU
	if [[ $1 ]]; then 

		# MENU
		case "$1" in
			-c|--country) 	[[ $2 ]] && startVPN $2 || lg_prt "ry" "[✖] Parametros insuficientes" "Usa --help";;
			-p|--passwrd) 	[[ $2 ]] && changePsswd $2 || lg_prt "ry" "[✖] Parametros insuficientes" "Usa --help";;
			-r|--reset) 	resetConnection;;
	        -h|--help|*) 	helpPanel;;
		esac

		exit 0
	else 
		lg_prt "ry" "[✖] Parametros no válidos o insuficientes." "Usa --help"

	fi

else
	 lg_prt "r" "[✖] Es necesario tener permisos ROOT"
	 exit 1
fi


# Optener la ip pública después de conectar curl ipinfo.io/ip