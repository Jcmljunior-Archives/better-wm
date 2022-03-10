#!/usr/bin/env bash

# CONFIGURAÇÕES BÁSICAS PARA A INICIALIZAÇÃO DE UM GERENCIADOR DE JANELAS.
# PROJETO: (https://github.com/jcmljunior/better-wm)
# AUTHOR: JULIO CESAR <jcmljunior@gmail.com>
# VERSÃO: 1.0.0

function @wm
{
    echo "Usando: ${FUNCNAME[0]}"
}


function @autoclean () {
    declare -- _status_code && {
        _status_code="$?"
    }

    exit "$_status_code"
}


function @main
{
    while [[ "$*" ]]; do
        case $1 in
        "-wm" | "--window-manager")
            @wm; shift;;

        "-h" | "--hello")
            @hello; shift;;

        *)
            echo ""
            shift;;
        esac
    done
}

# DEFINE O AMBIENTE DE PRODUÇÃO "PRODUCTION" OU DE DESENVOLVIMENTO "DEVELOPER".
declare -- _PROJECT_MODE && {
    _PROJECT_MODE="DEVELOPER"
}

# DEFINE A DEPURAÇÃO DOS COMPONENTES.
declare -- _PROJECT_DEBUG && {
    _PROJECT_DEBUG="TRUE"
}

# DEFINE O DIRETÓRIO PADRÃO DO PROJETO.
declare -- _PROJECT_DIR && {
    _PROJECT_DIR="better-wm"
}

# DEFINE O CAMINHO ABSOLUTO DO PROJETO.
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

# DEFINE O COMPORTAMENTO DOS COMPONENTES.
declare -- _PROJECT_CONF && {
    _PROJECT_CONF=$(cat "$_PROJECT_PATH/config.conf")
}

# A DECLARAÇÃO "_functions_map" DEFINE A ORDEM DE EXECUÇÃO DOS COMPONENTES
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
echo "Done!"
trap @autoclean exit 0