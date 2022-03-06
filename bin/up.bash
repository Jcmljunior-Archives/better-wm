#!/usr/bin/env bash

# CONFIGURAÇÕES BÁSICAS PARA A INICIALIZAÇÃO DO GERENCIADOR DE JANELAS.
# AUTHOR: JULIO CESAR <jcmljunior@gmail.com>
# VERSÃO: 1.0.0

# FORÇA A APRESENTAÇÃO DE ERROS.
set -euo pipefail

# CONFIGURAÇÕES DE PROJETO.
export readonly PROJECT_PATH='/home/USER/.config'
export readonly PROJECT_DIR='better-wm'
export readonly PROJECT_PATH="${PROJECT_PATH/USER/$USER}/$PROJECT_DIR"

# CONFIGURAÇÕES DE FUNCIONALIDADES.
declare -x PROJECT_CONF; PROJECT_CONF=$(cat "${PROJECT_PATH}/config.conf")

# A FUNÇÃO IN_ARRAY PROCURA POR UM VALOR ESPECIFICO EM UM ARRAY.
# DEMO: _in_array "O QUE PROCURA?" "AONDE PROCURAR?"
function _in_array()
{
    declare -I _search; _search="$1"
    declare -Ia _arrs; mapfile _arrs <<< "${@:2}"
    
    for str in "${_arrs[@]}"; do
        [[ "$str" == *"$_search"* ]] && printf "TRUE" && return 0
    done

    printf "FALSE" && return 1
}

# A FUNÇÃO AUTOLOAD INICIALIZA TODAS AS ENTRADAS DE ÁREA DE TRABALHO. (XDG)
# DEFINE OS DIRETÓRIOS A SEREM PESQUISADOS.
# PERCORRE OS DIRETÓRIOS INFORMADO. (LOOP)
# DEFINE O SEU RESPECTIVO CONTEÚDO.
# ALTERA O FORMATO DOS VALORES ENCONTRADOS PARA ARRAY.
# OBTEM A LISTA DE APLICAÇÕES QUE NÃO DEVEM SER CARREGADAS. (!!!)
# PERCORRE OS ELEMENTOS CONVERTIDO EM ARRAY. (LOOP)
# VERIFICA SE O TIPO DE ELEMENTO ENCONTRADO É DO TIPO ARQUIVO.
# FILTRA O ELEMENTO ATUAL: OBTEM O VALOR DO EXECUTAVEL.
# EXECUTA O ELEMENTO.
function _autoload()
{
    declare -Ia _dirs; _dirs=(
        "/etc/xdg/autostart"
        "/home/USER/.config/autostart"
    )

    for dir in "${_dirs[@]}"; do
        declare -Ix _dir_ls; _dir_ls=$(find "${dir/USER/$USER}" -type f);
        declare -Ia _items; mapfile -t _items <<< "$_dir_ls"
        # declare -Ix _NOT_LOADABLE; _NOT_LOADABLE=$(echo -n "$PROJECT_CONF" | grep -e "AUTOSTART_*" | grep -e "_BLOCKED=*" | awk -F '=' '/=/ {print $2}' | sed -e "s| |\n|")

        for ((i = 0; i < ${#_items[@]}; i++)); do       
            if [ -f "${_items[$i]}" ]; then
                declare -Ix _PATH; _PATH=$(grep -w "Exec=*" "${_items[$i]}" <<< cat)
                
                printf "%s \n" "${_PATH/Exec=/}"
            fi
        done
    done
}

# A FUNÇÃO MAIN INICIALIZA TODOS OS COMPONENTES.
function _main()
{
    _autoload
}

_main

echo "Done!"

exit 0