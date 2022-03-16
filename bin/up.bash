#!/usr/bin/env bash

# CONFIGURAÇÕES BÁSICAS PARA A INICIALIZAÇÃO DE UM GERENCIADOR DE JANELAS.
# PROJETO: (https://github.com/jcmljunior/better-wm)
# AUTOR: JULIO CESAR <jcmljunior@gmail.com>
# VERSÃO: 1.0.0

# A FUNÇÃO "function_exists" VERIFICA SE UMA FUNÇÃO FOI OU NÃO DEFINIDA.
function @function_exists()
{
  declare -- _check_functions && {
    _check_functions=$(declare -F)
    _check_functions=$(echo "$_check_functions" |  awk '{gsub("declare -f ",""); print}')
    mapfile -t _check_functions <<< "$_check_functions" && {
      _check_functions=("${_check_functions[@]}")
    }
  }

  for fnc in "${_check_functions[@]}"; do
    [[ "$fnc" = "$1" ]] && {
      echo "TRUE"
      return 1
    }
  done

  echo "FALSE"
  return 0
}

function @wm
{
  declare -- _window_manager_session && {
    _window_manager_session=$(echo -n "$_PROJECT_CONF" | grep -E "WINDOW_MANAGER_SESSION")
    _window_manager_session="${_window_manager_session##*=}"
  }

  declare -- _window_manager_options && {
    _window_manager_options=$(echo -n "$_PROJECT_CONF" | grep -E "WINDOW_MANAGER_OPTIONS")
    _window_manager_options="${_window_manager_options##*=}"
    _window_manager_options="${_window_manager_options/BASE_DIR/$_PROJECT_PATH}"
  }

 
  [[ -x "$(command -v "$_window_manager_session")" ]] && {
    exec $(""$_window_manager_session $_window_manager_options"")
  }
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

# A DECLARAÇÃO "_PROJECT_MODE" DEFINE O AMBIENTE DE PRODUÇÃO "PRODUCTION"
# OU DE DESENVOLVIMENTO "DEVELOPER".
declare -- _PROJECT_MODE && {
  _PROJECT_MODE="DEVELOPER"
}

# A DECLARAÇÃO "_PROJECT_PATH" DEFINE O CAMINHO ABSOLUTO DO PROJETO.
declare -- _PROJECT_PATH && {
  _PROJECT_PATH="/home/USER"
  _PROJECT_PATH="${_PROJECT_PATH/USER/$USER}"

  [[ "$_PROJECT_MODE" = "DEVELOPER" ]] && {
    _PROJECT_PATH+="/Git/jcmljunior"
  }

  [[ "$_PROJECT_MODE" = "PRODUCTION" ]] && {
    _PROJECT_PATH+="/.config"
  }

  _PROJECT_PATH+="/better-wm"
}

# A DECLARAÇÃO "_PROJECT_CONF" DEFINE O COMPORTAMENTO DOS COMPONENTES.
declare -- _PROJECT_CONF && {
  [[ -f "$_PROJECT_PATH/config.conf" ]] && {
    _PROJECT_CONF=$(cat < "$_PROJECT_PATH/config.conf")
    # _PROJECT_CONF=$(cat < "$_PROJECT_PATH/config.conf" | xargs echo)
    # _PROJECT_CONF=$(echo "$_PROJECT_CONF" | awk -F '[*]' '{ gsub(/\[/, "\n["); print }')
    # _PROJECT_CONF=$(echo "$_PROJECT_CONF" | sed -e '/^$/d') && {
      # mapfile -t _PROJECT_CONF_MAP <<< "$_PROJECT_CONF"
    # }
  }
}

# declare -a _PROJECT_CONF_MAP && {
#   [[ -n "$_PROJECT_CONF" ]] && {
#     mapfile -t _PROJECT_CONF_MAP <<< "$_PROJECT_CONF" && {
#     declare -- _pos
#     declare -A _arr

#     for ((i = 0; i < ${#_PROJECT_CONF_MAP[@]}; i++)); do

#     declare -- _arr_map && {
#       IFS=$'\n' read -r -a _arr_map <<< "${_PROJECT_CONF_MAP[$i]}"
#       for str in "${_arr_map[@]}"; do

#         [[ -z "${str##*]}" ]] && {
#           _pos="${str:1:-1}"
#           continue
#         }

#         _arr["$_pos"]+="$str "

#       done
#     }

#     done

#     # _PROJECT_CONF_MAP2=(${_arr[@]})

#     for str in "${_arr[@]}"; do
#       echo "$str -"
#     done

#     }
#   }
# }

# declare -A _PROJECT_CONF_MAP2

# A DECLARAÇÃO "_FUNCTIONS_MAP" DEFINE A ORDEM DE EXECUÇÃO DOS COMPONENTES
# NA AUSENCIA DE UM PARAMETRO DE INICIALIZAÇÃO.
declare -a _FUNCTIONS_MAP && {
  _FUNCTIONS_MAP=(
    "@wm"
  )
}

# INICIA COMPONENTES VIA PARAMETRO OU CARREGA A SEQUENCIA DE COMPONENTES
# DEFINIDAS EM "_FUNCTIONS_MAP".
if [[ -z "$1" ]]; then
  for fnc in "${_FUNCTIONS_MAP[@]}"; do
    [[ "$(@function_exists "$fnc")" = "TRUE" ]] && {
      eval "$fnc"
    }
  done
elif [[ -n "$1" ]] && [[ "$(@function_exists "$1")" = "TRUE" ]]; then
  eval "$1"
else
  echo "Oppss, não foi possivel localizar a função solicitada."
fi

# FINALIZA O SCRIPT.
echo ""
echo "Fim!"

trap @autoclean exit 0
