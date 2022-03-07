#!/usr/bin/env bash

# CONFIGURAÇÕES BÁSICAS PARA A INICIALIZAÇÃO DO GERENCIADOR DE JANELAS.
# AUTHOR: JULIO CESAR <jcmljunior@gmail.com>
# VERSÃO: 1.0.0

# FORÇA A APRESENTAÇÃO DE ERROS.
set -euo pipefail

# CONFIGURAÇÕES DE PROJETO.
export readonly PROJECT_MODE="developer"
export readonly PROJECT_PATH='/home/USER/.config'
export readonly PROJECT_DIR='better-wm'
export readonly PROJECT_PATH="${PROJECT_PATH/USER/$USER}/$PROJECT_DIR"

# CONFIGURAÇÕES DE FUNCIONALIDADES.
declare -x PROJECT_CONF; PROJECT_CONF=$(cat "${PROJECT_PATH}/config.conf")

# A FUNÇÃO GET_PATH RETORNA O CAMINHO ABSOLUTO DO PROJETO DE DENVOLVIMENTO OU PRODUÇÃO.
function _get_path()
{
    declare -I _path; _path="${PROJECT_PATH/USER/$USER}"
    [[ "$PROJECT_MODE" == "developer" ]] && echo "${_path/.config/Git}" || echo "$_path"
}

# A FUNÇÃO IN_ARRAY PROCURA POR UM VALOR ESPECIFICO EM UM ARRAY.
# DEMO: _in_array "O QUE PROCURA?" "AONDE PROCURAR?"
function _in_array()
{
    declare -I _search; _search="$1"
    declare -Ia _map; mapfile -t _map <<< "${@:2}"
    
    for str in "${_map[@]}"; do
        [[ "$str" =~ .*"$_search".* ]] && echo "TRUE" && return 0
    done
    
    echo "FALSE" && return 1
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
        "${PROJECT_PATH/$PROJECT_DIR}autostart"
    )

    # VERIFICA A EXISTENCIA DO DIRETÓRIO SETADO MANUALMENTE. (REQUERIDO!)
    # CRIA O DIRETÓRIO DE ENTRADAS NA PASTA PESSOAL DO USUÁRIO CASO NÃO EXISTA. (PREVINE ERRO DURANTE A LISTAGEM)
    if [ -d "${_dirs[0]}" ]; then
        [[ ! -d "${_dirs[1]}" ]] && mkdir "${_dirs[1]}"

        for dir in "${_dirs[@]}"; do
            declare -Ix _desktop_entries; _desktop_entries=$(find "$dir" -type f);
            declare -Ia _desktop_entries_map; mapfile -t _desktop_entries_map <<< "$_desktop_entries"
            declare -Ix _desktop_entries_not_allowed; _desktop_entries_not_allowed=$(echo -n "$PROJECT_CONF" | grep -e "AUTOSTART_*" | grep -e "_BLOCKED=*" | awk -F '=' '/=/ {print $2}' | sed -e "s| |\n|")

            for item in "${_desktop_entries_map[@]}"; do
                if [ -f "$item" ]; then
                    # export local _check_str="$(_in_array \""$item"\" \""$_desktop_entries_not_allowed"\")"
                    declare -Ix _desktop_entry_exec; _desktop_entry_exec=$(grep -w "Exec=*" "$item" <<< cat); _desktop_entry_exec="${_desktop_entry_exec/Exec=}"
                    # declare -Ifx _in_array; _in_array "$item" "$_desktop_entries_not_allowed">/dev/null || {
                    #     true () {
                    #         continue
                    #     }
                    # }
                    # declare -Ifx true 1>/dev/null || {
                    #     # declare -Ifx _check_str; _check_str=$(_in_array "$item" "$_desktop_entries_not_allowed")

                    #     function _check_str() {
                    #         echo $(_in_array "$item" "$_desktop_entries_not_allowed")
                    #     }
                    # };

                    # [[ "$(echo -n \""$_check_str"\")" == "TRUE" ]] && continue;

                    if [ -f "$item" ]; then
                        printf "%s \n" "$item"
                    fi
                fi
            done
        done

    fi

    exit 0
}

# A FUNÇÃO MAIN INICIALIZA TODOS OS COMPONENTES.
function _main()
{
    _autoload
}

_main

printf "Done! \n"

exit 0