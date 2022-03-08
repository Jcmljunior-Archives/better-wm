#!/usr/bin/env bash

# CONFIGURAÇÕES BÁSICAS PARA A INICIALIZAÇÃO DE UM GERENCIADOR DE JANELAS.
# PROJETO: (https://github.com/jcmljunior/better-wm)
# AUTHOR: JULIO CESAR <jcmljunior@gmail.com>
# VERSÃO: 1.0.0

# A FUNÇÃO "_get_path" RETORNA O CAMINHO ABSOLUTO DO PROJETO DE ACORDO COM AS CONFIGURAÇÕES
# DA VARIAVEL "_PROJECT_MODE".
function _get_path() {
    [[ "$_PROJECT_MODE" == "developer" ]] && printf "%s/Git/%s\n" "$_PROJECT_PATH" "$_PROJECT_DIR" && return 0
    [[ "$_PROJECT_MODE" == "production" ]] && printf "%s/.config/%s\n" "$_PROJECT_PATH" "$_PROJECT_DIR" && return 0
    printf "Operation not permitted.\n" && return 1
}

# A FUNÇÃO "_in_array" PROCURA POR UM VALOR ESPECIFICO EM UM ARRAY.
# DEMO 01: _in_array "O QUE PROCURA?" "AONDE PROCURAR?"
# DEMO 02: _in_array "O QUE PROCURA?" "AONDE PROCURAR 01" "AONDE PROCURAR 02" "AONDE PROCURAR 03" [...]
function _in_array()
{
    declare -- _looking_for; _looking_for="$1"
    declare -a _looking_map; _looking_map=("${@:2}")

    for str in "${_looking_map[@]}"; do
        [[ "$str" =~ .*"$_looking_for".* ]] && printf "TRUE\n" && return 0
    done

    printf "FALSE\n" && return 1
}

function _autoload() {
    declare -I _PROJECT_PATH; _PROJECT_PATH="$_PROJECT_PATH/.config"
    declare -a _directories

    [[ -d "/etc/xdg/autostart" ]] && _directories[0]="/etc/xdg/autostart" || return 1
    [[ -d "$_PROJECT_PATH/autostart" ]] && _directories[1]="$_PROJECT_PATH/autostart"

    for directory in "${_directories[@]}"; do
        declare -x _desktop_entries; _desktop_entries=$(find "$directory" -type f)
        declare -a _desktop_entries_map; _desktop_entries_map=($_desktop_entries)
        declare -- _desktop_entries_not_allowed; _desktop_entries_not_allowed=$(echo -n "$_PROJECT_CONF" | grep -E "AUTOSTART"); _desktop_entries_not_allowed="${_desktop_entries_not_allowed##*=}"

        for application in "${_desktop_entries_map[@]}"; do
            declare -- _desktop_entry_app; _desktop_entry_app=$(grep -E "Exec=" "$application" <<< cat); _desktop_entry_app="${_desktop_entry_app##*Exec=}"
            declare -f _check_str; _check_str=$(_in_array "$application" "$_desktop_entries_not_allowed")

            [[ "$_check_str" == "TRUE" ]] || [[ ! -f "$application" ]] && continue
            
            echo "$application - $_check_str"
        done
    done
}

# A FUNÇÃO "_main" INICIALIZA TODOS OS COMPONENTES.
function _main()
{
    declare -- _use_autoload; _use_autoload=$(echo -n "$_PROJECT_CONF" | grep -E "AUTOSTART_ENABLE"); _use_autoload="${_use_autoload##*=}"
    [[ "$_use_autoload" == "TRUE" ]] && _autoload
}

# DEFINIÇÕES DE PROJETO.
declare -- _PROJECT_MODE; _PROJECT_MODE="developer"
declare -- _PROJECT_PATH; _PROJECT_PATH="/home/USER"; _PROJECT_PATH="${_PROJECT_PATH/USER/$USER}"
declare -- _PROJECT_DIR; _PROJECT_DIR="better-wm"

# DEFINIÇÕES DE FUNCIONALIDADES.
declare -- _PROJECT_CONF; _PROJECT_CONF=$(cat "$(_get_path)""/config.conf")

_main

printf "Done! \n"

exit 0