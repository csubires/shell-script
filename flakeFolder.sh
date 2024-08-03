#!/bin/bash
source utils.sh


# Se ejecuta al pulsar Ctrl+C
trap ctrl_c INT

function ctrl_c() {
    lg_prt "y" "[▲] Saliendo con interrupción"
	exit 1
}


# Panel de ayuda
function helpPanel() {
	clear
    lg_prt "wtw" "\n" "FLAKE8 TO FOLDER" "\n"
    lg_prt "woyb" "Uso:" "./flakeFolder.sh" "<Path>" "<Opción>" 
    lg_prt "bw" "\t-f, --flake" "\tUtiliza Flake8 cada archivo *.py de un directorio"
    lg_prt "bw" "\t-t, --todo" "\tBusca \"TODO\" en archivos *.py"
    lg_prt "bw" "\t-i, --import" "\tBusca \"import\" en archivos *.py"
    lg_prt "bw" "\t-h, --help" "\tMostrar ayuda"
    lg_prt "wc" "\n Ejemplos:\n" "./flakeFolder.sh \"/temp/my_project\" -f\n"
	exit 0
}


function run_flake8() {
    # Encontrar arhivos *.py y aplicarle flake8
    lg_prt "wtw" "\n" "Procesando archivos con flake8" "\n"
    lg_prt "uy" "ERRORS\tPATH"
    lg_prt "w" " "
    find "$1" -type f -iname "*.py" -not -path "*__*" -not -path "*test*" | while read -r d; do 
        num_of_errors=$(flake8 $d --ignore=W191,E501,F405 | wc -l)
        [[ $num_of_errors > 0 ]] && cres="yr" || cres="yg"
        lg_prt "$cres" "$num_of_errors" "\t$d"
    done
    lg_prt "y" "\n\n flake8 --ignore=W191,E501,F405 <PATH>"
}


function search_todos() {
    # Encontrar todo dentro de los archivos *.py
    lg_prt "wtw" "\n" "Buscando \"todos\" en archivos *.py" "\n"
    grep -r --color="auto" "TODO" "$1"
}


function search_imports() {
    # Encontrar import dentro de los archivos *.py
    lg_prt "wtw" "\n" "Buscando \"import\" en archivos *.py" "\n"
    lg_prt "y" "\tCadenas \"import\" encontradas:\n"
    grep -R --include="*.py" "import" "$1" | awk '{print $2}' | sort --unique | grep -v "\\.\\b" | grep -v "from" | grep -v "import"
}



# MENU
if [[ -d $1 && $2 ]] || [[ $1 == "-h" || $1 == "--help" ]]; then
    clear
    lg_prt "wgwy" "Ruta:" "$1" "Opción:" "$2"

    case "$2" in
        -f|--flake)     run_flake8 $1;;
        -t|--todo)      search_todos $1;;
        -i|--import)    search_imports $1;;
        -h|--help|*)    helpPanel;;
    esac

    lg_prt "g" "\n[✔] Programa finalizó correctamente"
else 
    lg_prt "ry" "[✖] Parametros no válidos o insuficientes." "Usa --help"
fi

