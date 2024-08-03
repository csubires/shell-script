#!/bin/bash
source utils.sh


# Variables globales
DIR="/mnt/hgfs/COMPRESS/"	# Carpeta de media


# Se ejecuta al pulsar Ctrl+C
trap ctrl_c INT

function ctrl_c() {
    lg_prt "y" "[▲] Saliendo con interrupción"
	exit 1
}


# Panel de ayuda
function helpPanel() {
	clear
	
	lg_prt "wy" "Ruta:" "$DIR"
	lg_prt "wtw" "\n" "REDUCE MEDIA" "\n"
	lg_prt "wobv" "Uso:" "./reduceMedia.sh" "<Opción>" "<Modo>"
	
	lg_prt "y" "\nREDUCCIONES"
	lg_prt "bw" "\t-r, --reduce" "\tModo de reducción de archivos"
	lg_prt "vw" "\t\timg" "\tReducir imagenes jpg, jpeg, png, bmp"
	lg_prt "vw" "\t\tmp4" "\tReducir videos MP4"
	lg_prt "vw" "\t\tavi" "\tReducir videos AVI"
	lg_prt "vw" "\t\tmov" "\tReducir videos MOV"
	lg_prt "vw" "\t\tmp3" "\tReducir audios MP3"
	
	lg_prt "y" "\nCONVERSIONES"
	lg_prt "bw" "\t-c, --m4atomp3" "Convertir archivos M4A a MP3"
	lg_prt "bw" "\t-j, --tifTojpg" "Convertir archivos TIF a JPG"

	lg_prt "y" "\nIMAGENES"
	lg_prt "bw" "\t-d, --rmexit" "\tBorrar metadatos EXIF de imagenes"
	lg_prt "bw" "\t-m, --renamimg" "Renombrar imagenes aleatoriamente"
	lg_prt "bw" "\t-s, --redi400" "\tRedimensionar imagenes a x400px"
	lg_prt "bw" "\t-t, --redi1080" "Redimensionar imagenes a x1080px"
	lg_prt "bw" "\t-a, --auto" "\tModo automático (d+t+r img)"
	
	lg_prt "y" "\nEXTRAS"
	lg_prt "bw" "\t-p, --splitmp3" "\tDividir archivos MP3s en trozos de 30 minutos"
	lg_prt "bw" "\t-f, --findu" "\tBuscar archivos duplicados"
	lg_prt "bw" "\t-g, --group" "\tAgrupar archivos de video en una carpeta"
	lg_prt "bw" "\t-z, --rmstring" "Eliminar \"substring\" del nombre de los archivos"
	lg_prt "bw" "\t-h, --help" "\tMostrar ayuda"
	
	lg_prt "wc" "\n Ejemplos:\n" "\t./flakeFolder.sh -r img"
	lg_prt "c" "\t./flakeFolder.sh -c-"

	exit 0
}


# Generar string aleatorios
randpw() { < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo; }


# Ejecuta los distintos modos de reducción
function reduceMedia() {
	clear
	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	lg_prt "wtw" "\n" "REDUCIR $1" "\n"
	# Pedir confirmación
	read -p "¿Estas seguro? (S/N): " -n 1 -r
	[[ $REPLY =~ ^[Ss]$ ]] && lg_prt "w" " \n" || exit 0
	init_size=$(du -bsh | awk '{print $1}') # Tamaño inicial de la carpeta

    case "$1" in
        img) 
            find . -type f -iregex ".*\.jpg\|.*\.jpeg\|.*\.png\|.*\.bmp" -exec mogrify -verbose -quality 70 {} + ;;
        mp4)
            find . -type f \( -iname \*.mp4 \) -print0|sed -e "s/.mp4//g"| while read -d $'\0' file; do 
            	ffmpeg -y -i "$file.mp4" -strict -2 -c:a copy -c:v libx264 -preset fast -crf 28 -qphist -tune stillimage "$file.cmp.mp4" < /dev/null;
            done ;;
        
        avi)
            find . -type f \( -iname \*.avi \) -print0|sed -e "s/.avi//g"| while read -d $'\0' file; do
            	ffmpeg -y -i "$file.avi" -strict -2 -c:a copy -c:v libx264 -preset fast -crf 28 -qphist -tune stillimage "$file.cmp.avi" < /dev/null; 
            done ;;            
            
         mov)
			find . -type f \( -iname \*.mov \) -print0|sed -e "s/.mov//g"| while read -d $'\0' file; do 
				ffmpeg -y -i "$file.mov" -strict -2 -c:a copy -c:v libx264 -preset fast -crf 28 -qphist -tune stillimage "$file.cmp.mov" < /dev/null; 
			done ;;
           
         mp3)
			lame --quiet -vbr-new -V 0 ./*.mp3 ;; 
            
        *)
            lg_prt "ry" "[✖] Parametro no válido." "Usa --help" ;;
    esac

	end_size=$(du -bsh | awk '{print $1}') # Tamaño final de la carpeta
	lg_prt "wywy" "\n Tamaño Inicial:" "\t$init_size" "\n Tamaño Final:" "\t$end_size"
	lg_prt "g" "Archivos \"$1\" reducidos"
	return 0
}


# Convertir m4a a mp3 y comprimir
function conv2mp3() {
	clear
	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	lg_prt "wtw" "\n" "CONVERTIR M4A A MP3" "\n"
	# Pedir confirmación
	read -p "¿Estas seguro? (S/N): " -n 1 -r
	[[ $REPLY =~ ^[Ss]$ ]] && lg_prt "w" " \n"  || exit 0

	find . -type f \( -iname \*.m4a \) -print0|sed -e "s/.m4a//g"| while read -d $'\0' file; do 
		ffmpeg -i "$file.m4a" -c:v copy -c:a libmp3lame -b:a 96k "$file.mp3" < /dev/null; 
	done
	
	lg_prt "g" "\n[✔] Tarea finalizada correctamente"
	exit 0
}


# Convertir tif a jpg
function tifTojpg(){
	clear
	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	lg_prt "wtw" "\n" "CONVERTIR TIF A JPG" "\n"
	# Pedir confirmación
	read -p "¿Estas seguro? (S/N): " -n 1 -r
	[[ $REPLY =~ ^[Ss]$ ]] && lg_prt "w" " \n"  || exit 0
	
	find . -type f \( -iname \*.TIF \) -exec mogrify -format jpg *.tif > /dev/null {} +

	lg_prt "g" "\n[✔] Tarea finalizada correctamente"
	exit 0
}


# Eliminar subcadena del nombre de los archivos
function removeString() {
	clear
	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	lg_prt "wtw" "\n" "ELIMINAR \"SUBSTRING\" DEL NOMBRE DE LOS ARCHIVOS" "\n"
	# Pedir confirmación
	read -p "¿Estas seguro? (S/N): " -n 1 -r
	[[ $REPLY =~ ^[Ss]$ ]] && lg_prt "w" " \n"  || exit 0
	
	lg_prt "w" "Escribe el string a eliminar:"
	read varname
	find . -name "*$varname*" | sed -e "p;s/$varname//" | xargs -n2 mv
	lg_prt "g" "\n[✔] Tarea finalizada correctamente"
	exit 0
}


# Eliminar los datos EXIT de las imagenes jpg, jpeg, png, bmp
function removeEXIT(){
	clear
	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	lg_prt "wtw" "\n" "BORRAR METADATOS EXIF DE IMAGENES" "\n"
	# Pedir confirmación
	read -p "¿Estas seguro? (S/N): " -n 1 -r
	[[ $REPLY =~ ^[Ss]$ ]] && lg_prt "w" " \n"  || exit 0
	
	find . -type f -iregex ".*\.jpg\|.*\.jpeg\|.*\.png\|.*\.bmp" -exec mogrify -verbose -strip {} +
	lg_prt "g" "\n[✔] Tarea finalizada correctamente"
	return 0
}


# Renombrar archivos jpg, jpeg, png, bmp masivamente con nombres aleatorios
function renameJPGs(){
	clear
	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	lg_prt "wtw" "\n" "RENOMBRAR IMAGENES ALEATORIAMENTE" "\n"
	# Pedir confirmación
	read -p "¿Estas seguro? (S/N): " -n 1 -r
	[[ $REPLY =~ ^[Ss]$ ]] && lg_prt "w" " \n" || exit 0
	
	find . -type f -iregex ".*\.jpg\|.*\.jpeg\|.*\.png\|.*\.bmp" -execdir bash -c 'mv -i "{}" "$(shuf -i 1-100000 -n 1)_$(shuf -i 1-100000 -n 1).jpg"' \;
	lg_prt "g" "\n[✔] Tarea finalizada correctamente"
	exit 0
}


# Redimensionar archivos jpg, jpeg, png, bmp masivamente con dimensiones de 400px
function resizeJPG(){
	clear
	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	lg_prt "wtw" "\n" "REDIMENSIONAR IMAGENES A x$1px" "\n"
	# Pedir confirmación
	read -p "¿Estas seguro? (S/N): " -n 1 -r
	[[ $REPLY =~ ^[Ss]$ ]] && lg_prt "w" " \n" || exit 0
	
	#find . -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.bmp \) -exec mogrify -verbose -resize 400x400 {} +
	
	if [[ $1 -eq 400 ]]; then
		find . -type f -iregex ".*\.jpg\|.*\.jpeg\|.*\.png\|.*\.bmp" -exec sh -c 'identify -format "%[fx:(h>400)]\n" "$0" | grep -q 1' {} \; -print0 | xargs -0 mogrify -verbose -resize 'x400'
	else
		find . -type f -iregex ".*\.jpg\|.*\.jpeg\|.*\.png\|.*\.bmp" -exec sh -c 'identify -format "%[fx:(h>1080)]\n" "$0" | grep -q 1' {} \; -print0 | xargs -0 mogrify -verbose -resize 'x1080'
	fi
	
	lg_prt "g" "\n[✔] Tarea finalizada correctamente"
	return 0
}


# Dividir audios en trozos de 30 minutos
function splitmp3() {
	clear
	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	lg_prt "wtw" "\n" "DIVIDIR MP3s EN TROZOS DE 30 MINUTOS" "\n"
	# Pedir confirmación
	read -p "¿Estas seguro? (S/N): " -n 1 -r
	[[ $REPLY =~ ^[Ss]$ ]] && lg_prt "w" " \n"  || exit 0

    find . -type f -iregex ".*\.mp3" -print0|sed -e "s/.mp3//g"| while read -d $'\0' file; do
        lg_prt "wyw" "\n" "$file" "\n"
		new_dir="${file##*/}_split"
		mkdir "$new_dir"        
	    # Dividir audio en segmentos de 30 minutos, reset_timestamps - Resetea el contador de 30 minutos
	    ffmpeg -i "$file.mp3" -hide_banner -loglevel error -stats -f segment -segment_times 1800,3600,5400,7200,9000,10800,12600,14400 -c copy -map 0 "$new_dir/$file-%02d.mp3" < /dev/null;
    done;
	lg_prt "g" "\n[✔] Tarea finalizada correctamente"
	exit 0
}


# Encontrar archivos duplicados
function findDuple(){
	clear
	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	lg_prt "wtw" "\n" "BUSCAR ARCHIVOS DUPLICADOS" "\n"
	fdupes -S -r . 
	lg_prt "g" "\n[✔] Tarea finalizada correctamente"
	exit 0
}


# Agrupar todos los videos en una sola carpeta
function groupVideo(){
	clear
	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	lg_prt "wtw" "\n" "AGRUPAR ARCHIVOS DE VIDEO EN UNA CARPETA" "\n"
	mkdir "${DIR}all_videos" 2>/dev/null
	
	find . -type f -iregex ".*\.avi\|.*\.mp4\|.*\.mov\|.*\.wmv\|.*\.3gpp\|.*\.mpeg" -exec mv {} "${DIR}all_videos" \;

	lg_prt "g" "Archivos de video movidos a \"$DIR\all_videos\""
	exit 0
}


# Aplicar varias funciones consecutivamente
function autoMatic(){
	lg_prt "yw" "\n\t[▲] Estas en el directorio:" "$(pwd)"
	clear
	removeEXIT
	resizeJPG 1080
	reduceMedia img
	exit 0
}



# Ir a la carpeta donde estan las imagenes y videos
if [ -d "$DIR" ]; then
	cd "$DIR"
else
	lg_prt "ry" "[▲] Carpeta de archivos media no disponible." "Montando..."
	sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
	lg_prt "g" "\nSe ha montado el directiorio $DIR\n"
fi



# Control o MENU
if [[ $1 ]]; then 
	lg_prt "gy" "Ruta: $DIR, Opción: $1"

	# MENU
	case "$1" in
		-r|--reduce) [[ $2 ]] && reduceMedia $2 || lg_prt "ry" "[✖] Parametros no válidos o insuficientes." "Usa --help";;
		-c|--m4atomp3) 	conv2mp3;;
		-j|--tifTojpg) 	tifTojpg;;
		-d|--rmexit) 	removeEXIT;;
		-m|--renamimg) 	renameJPGs;;
		-s|--redi400) 	resizeJPG 400;;
		-t|--redi1080) 	resizeJPG 1080;;
		-a|--auto) 		autoMatic;;
        -p|--splitmp3)  splitmp3;;
		-f|--findu) 	findDuple;;
		-g|--group) 	groupVideo;;
		-z|--rmstring) 	removeString;;	        
        -h|--help|*) 	helpPanel;;
	esac

	exit 0
else 
	lg_prt "ry" "[✖] Parametros no válidos o insuficientes." "Usa --help"

fi



#  ------------ TODO ------------


# Mostrar progresión de compresión : cambiar find por while y meter files.tmp
# dividir archivos
# https://unix.stackexchange.com/questions/280767/how-do-i-split-an-audio-file-into-multiple
