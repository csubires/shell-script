#!/bin/bash
source utils.sh

# Descargar desde el SERVER al destino
# scp user@192.168.65.22:/tmp/tmp.WrhGxIXlIw/20231227_backup_server_6232.cmp /home/user/Documentos/box

# Variables globales
SERVER='user@192.168.65.22'
ORIGEN='/home/user/Documentos/box/upload/*'
DESTINO='/home/user/Documents/upload'


# Se ejecuta al pulsar Ctrl+C
trap ctrl_c INT

function ctrl_c() {
    lg_prt "y" "\n[▲] Saliendo con interrupción"
	exit 1
}

lg_prt "vw" "\n SERVER:" $SERVER
lg_prt "vw" "ORIGEN:" $ORIGEN
lg_prt "vw" "DESTINO:" $DESTINO
lg_prt "y" "\n [▲] Sincronizando carpeta con el servidor\n"


rsync --progress -r $ORIGEN $SERVER:$DESTINO

lg_prt "g" "[✔] Operación finalizada\n"
