#!/usr/bin/env bash

# CONFIGURAÇÕES BÁSICAS PARA A INICIALIZAÇÃO DE UM GERENCIADOR DE JANELAS.
# PROJETO: (https://github.com/jcmljunior/better-wm)
# AUTHOR: JULIO CESAR <jcmljunior@gmail.com>
# VERSÃO: 1.0.0

# A FUNÇÃO "@start_function" APRESENTA A MENSAGEM DE LOG INICIAL DE TODAS AS FUNÇÕES.
function @start_function()
{
    @logger "Iniciando função: $1" [[ -z "$2" ]] && "$2"
}

# A FUNÇÃO "@end_function" APRESENTA A MENSAGEM DE LOG FINAL DE TODAS AS FUNÇÕES.
function @end_function()
{
    @logger "Encerrando função: $1" "$2"
}

# NECESSITA DE REFORMULAÇÃO NAS REGRAS IFS.
# function @limbo
# {
#     @start_function "${FUNCNAME[0]}"

#     declare -A _config
#     declare -- _current
#     declare -a _array && {
#         IFS=$'\n' read -r -d '' -a _array <<< "$_PROJECT_CONF"
#         for str in "${_array[@]}"; do
#             str=""

#             if [[ -z "${str##*]}" ]]; then
#                 _current="${str:1:-1}"
#             elif [[ -n "${str##*]}" ]] ; then
#                 _config[$_current]+="$(echo -n "$str ")" && {
#                     continue
#                 }
#             else
#                @logger "Oppss, o identificador chave no array precisa de conter os seguintes caracteres. [...]"
#                return 1
#             fi
#         done
#     }

#     for str in "${!_config[@]}"; do
#         echo "$str - ${_config[$str]}"
#     done

#     @end_function "${FUNCNAME[0]}" "TRUE"
# }

function @wm
{
    @start_function "${FUNCNAME[0]}"
    
    echo "Hello World!"
    echo "Hello World!"
    echo "Hello World!"

    @end_function "${FUNCNAME[0]}" "TRUE"
}

# A FUNÇÃO "@logger" VERIFICA SE DEVE OU NÃO EXIBIR LOGS.
function @logger ()
{
    declare -- _length && {
        _length="${#1}"
    }

    declare -- _stroke && {
        for (( i=1; i<="$_length"; i++ )); do
            _stroke+="-"
        done
    }

    [[ -n "$2" ]] && {
        printf "\n"
    }

    [[ "$_PROJECT_DEBUG" == "TRUE" ]] || [[ "$_PROJECT_MODE" == "DEVELOPER" ]] && {
        printf "%s \n" "$_stroke"
        printf "%s \n" "$1"
        printf "%s \n" "$_stroke"
        return 0
    }

    return 1
}

# A FUNÇÃO "@autoclean" ELIMINA TODA A BAGUNÇA FEITA PELO SCRIPT.
function @autoclean ()
{
    declare -- _status_code && {
        _status_code="$?"
    }

    declare -a _unset_map && {
        _unset_map=(
            "_PROJECT_MODE"
            "_PROJECT_DEBUG"
            "_PROJECT_DIR"
            "_PROJECT_PATH"
            "_PROJECT_CONF"
            "_PROJECT_LANG"
            "_FUNCTIONS_MAP"
        )
    }

    for str in "${_unset_map[@]}"; do
        unset -n "$str"
    done

    exit "$_status_code"
}

# A FUNÇÃO "@main" INICIA OS COMPONENTES DE FORMA SELETIVA.
function @main
{    
    while [[ "$*" ]]; do
        case $1 in
        "-wm" | "--window-manager")
            @wm; shift;;

        # "--limbo")
        #     @limbo; shift;;

        *)
            @logger "Oppss, a função chamada não existe." "TRUE"
            shift;;
        esac
    done
}

# A DECLARAÇÃO "_PROJECT_MODE" DEFINE O AMBIENTE DE PRODUÇÃO "PRODUCTION"
# OU DE DESENVOLVIMENTO "DEVELOPER".
declare -- _PROJECT_MODE && {
    _PROJECT_MODE="DEVELOPER"
}

# A DECLARAÇÃO "_PROJECT_DEBUG" DEFINE A DEPURAÇÃO DOS COMPONENTES.
declare -- _PROJECT_DEBUG && {
    _PROJECT_DEBUG="FALSE"
}

# A DECLARAÇÃO "_PROJECT_DIR" DEFINE O DIRETÓRIO PADRÃO DO PROJETO.
declare -- _PROJECT_DIR && {
    _PROJECT_DIR="better-wm"
}

# A DECLARAÇÃO "_PROJECT_PATH" DEFINE O CAMINHO ABSOLUTO DO PROJETO.
declare -- _PROJECT_PATH && {
    _PROJECT_PATH="/home/USER"
    _PROJECT_PATH="${_PROJECT_PATH/USER/$USER}"

    [[ "$_PROJECT_MODE" == "DEVELOPER" ]] && {
        _PROJECT_PATH+="/Git"
    }

    [[ "$_PROJECT_MODE" == "PRODUCTION" ]] && {
        _PROJECT_PATH+="/.config"
    }

    _PROJECT_PATH+="/$_PROJECT_DIR"
}

# A DECLARAÇÃO "_PROJECT_CONF" DEFINE O COMPORTAMENTO DOS COMPONENTES.
declare -- _PROJECT_CONF && {
    [[ -f "$_PROJECT_PATH/config.conf" ]] && {
        _PROJECT_CONF=$(cat "$_PROJECT_PATH/config.conf")
    }
}

# A DECLARAÇÃO "_PROJECT_LANG" DEFINE O IDIOMA PARA A EXIBIÇÃO DE LOGS.
declare -- _PROJECT_LANG && {
    [[ -f "/etc/locale.conf" ]] && {
        _PROJECT_LANG=$(cat "/etc/locale.conf")
        _PROJECT_LANG="${_PROJECT_LANG##*=}"
        _PROJECT_LANG=$(echo -n "$_PROJECT_LANG" | awk -F "." '/./ { print $1 }')
    }
}

# A DECLARAÇÃO "_FUNCTIONS_MAP" DEFINE A ORDEM DE EXECUÇÃO DOS COMPONENTES
# NA AUSENCIA DE UM PARAMETRO DE INICIALIZAÇÃO.
declare -a _FUNCTIONS_MAP && {
    _FUNCTIONS_MAP=(
        "--window-manager"
    )
}

# INICIA COMPONENTES VIA PARAMETRO OU CARREGA A SEQUENCIA DE COMPONENTES
# DEFINIDAS EM "_FUNCTIONS_MAP".
[[ -n "$1" ]] && @main "$@"
[[ -z "$1" ]] && {
    for fnc in "${_FUNCTIONS_MAP[@]}"; do
        @main "$fnc"
    done
}

# FINALIZA O SCRIPT.
@logger "Fim!" "TRUE"
trap @autoclean exit 0