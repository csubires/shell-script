#!/bin/bash
source utils.sh

DIR="/mnt/hgfs/COMPRESS"	# Carpeta de media

clear

# Ir a la carpeta donde estan las imagenes y videos
if [ -d "$DIR" ]; then
	lg_prt "y" "[▲] \"$DIR\" Ya estaba montado"
	cd "$DIR"
else
	lg_prt "oy" "[▲] Carpeta compartida VMware no disponible."  "Montando...\n"
	sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
	lg_prt "gw" "[✔] Se ha montado el directiorio:" "$DIR\n"
fi