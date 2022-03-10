#!/usr/bin/env bash

# CONFIGURAÇÕES BÁSICAS PARA A INICIALIZAÇÃO DE UM GERENCIADOR DE JANELAS.
# PROJETO: (https://github.com/jcmljunior/better-wm)
# AUTHOR: JULIO CESAR <jcmljunior@gmail.com>
# VERSÃO: 1.0.0

function @wm
{
    echo "Usando: ${FUNCNAME[0]}"
}

# A FUNÇÃO "@autoclean" ELIMINA TODA A BAGUNÇA FEITA PELO SCRIPT.
function @autoclean () {
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

        *)
            echo ""
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
    _PROJECT_DEBUG="TRUE"
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
    _PROJECT_CONF=$(cat "$_PROJECT_PATH/config.conf")
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
echo "Done!"
trap @autoclean exit 0