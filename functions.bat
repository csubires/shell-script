

# REDUCIR TAMAÑO DE IMAGENES JPG RECURSIVAMENTE (CUIDADO CASESENSITIVE)
find . -name "*.jpg" -exec mogrify -verbose -quality 70 {} +

# REDIMENSIONA TAMAÑO DE IMAGENES JPG RECURSIVAMENTE (CUIDADO CASESENSITIVE)
find . -name "*.jpg" -exec mogrify -verbose -resize 400x400 {} +

# ENCONTRAR DUPLICADOS DE ARCHIVOS
fdupes -S -r . 

# ROTAR VIDEO 90º
ffmpeg -i "20190726_162606.cmp.mp4" -metadata:s:v rotate="90" -codec copy "20190726_162606.cmp666.mp4"

REDUCIR MP3 (CUIDADO CASESENSITIVE)
lame --quiet -vbr-new -V 0 ./11.mp3

# REDUCIR TAMAÑO DE UN VIDEO (CUIDADO CASESENSITIVE)
ffmpeg -i "./willy.mp4" -strict -2 -c:a copy -c:v libx264 -preset fast -crf 28 -qphist -tune stillimage "./willy.cmp.mp4"
ffmpeg -i "./101852.avi" -strict -2 -c:a copy -c:v libx264 -preset fast -crf 28 -qphist -tune stillimage "./101852.cmp.avi"

# REDUCIR TAMAÑO DE UNA CARPETA DE VIDEOS (CUIDADO CASESENSITIVE)
find . -name "*.mp4" -print0|sed -e "s/.mp4//g"| while read -d $'\0' file; do ffmpeg -y -i "$file.mp4" -strict -2 -c:a copy -c:v libx264 -preset fast -crf 28 -qphist -tune stillimage "$file.cmp.mp4" < /dev/null; done
find . -name "*.avi" -print0|sed -e "s/.avi//g"| while read -d $'\0' file; do ffmpeg -y -i "$file.avi" -strict -2 -c:a copy -c:v libx264 -preset fast -crf 28 -qphist -tune stillimage "$file.cmp.avi" < /dev/null; done

# RENOMBRAR ARCHIVOS DE UNA CARPETA Y SUBCARPETAS CON UN NOMBRE ALEATORIO
find -name '*.jpg' -execdir bash -c 'mv -i "{}" "$RANDOM_$RANDOM.jpg"' \;

# CARPETAS COMPARTIDAS DE VMWARE NO FUNCIONAN 
sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
sudo /usr/bin/vmhgfs-fuse .host:/ /mnt/hgfs -o subtype=vmhgfs-fuse,allow_other

cd /mnt/hgfs/COMPRESS

# RENOMBRAR MASIVAMENTE ARCHIVOS QUITANDO UNA PARTE DEL NOMBRE
find . -depth -name "*.m4a" -exec sh -c 'mv "$1" "${1% (128kbit_AAC).m4a}.m4a"' _ {} \;

# DIVIDIR AUDIOS
ffmpeg -i "Cambia la vida.mp3" -f segment -segment_times 30,60,90,120,150,180 -c copy -map 0 "Cambia la vida%02d.mp3"

# Dividir especificando tiempos
ffmpeg -ss 00:00:00 -t 00:30:00 -i "Marco Aurelio - Meditaciones.mp3" -vn -acodec copy "1 - Marco Aurelio - Meditaciones.mp3"
ffmpeg -ss 00:30:00 -t 00:30:00 -i "Marco Aurelio - Meditaciones.mp3" -vn -acodec copy "2 - Marco Aurelio - Meditaciones.mp3"
ffmpeg -ss 01:00:00 -t 00:30:00 -i "Marco Aurelio - Meditaciones.mp3" -vn -acodec copy "3 - Marco Aurelio - Meditaciones.mp3"
