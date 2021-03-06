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
    [ "$fnc" = "$1" ] && {
      echo "TRUE"
      return 1
    }
  done

  echo "FALSE"
  return 0
}

# A FUNÇÃO "@config_keyboard" DEFINE AJUSTES AO COMPONENTE TECLADO.
function @config_keyboard()
{
  declare -- _keyboard_enabled && {
    _keyboard_enabled=$(echo -n "$_PROJECT_CONF" | grep -E "KEYBOARD_ENABLED")
    _keyboard_enabled="${_keyboard_enabled##*=}"
  }

  [ "$_keyboard_enabled" != "TRUE" ] && return 0

  declare -- _output

  declare -- _keyboard_model && {
    _keyboard_model=$(echo -n "$_PROJECT_CONF" | grep -E "KEYBOARD_MODEL")
    _keyboard_model="${_keyboard_model##*=}"
  }

  declare -- _keyboard_layout && {
  _keyboard_layout=$(echo -n "$_PROJECT_CONF" | grep -E "KEYBOARD_LAYOUT")
    _keyboard_layout="${_keyboard_layout##*=}"
  }
  
  declare -- _keyboard_variant && {
    _keyboard_variant=$(echo -n "$_PROJECT_CONF" | grep -E "KEYBOARD_VARIANT")
    _keyboard_variant="${_keyboard_variant##*=}"
  }

  declare -- _keyboard_options && {
    _keyboard_options=$(echo -n "$_PROJECT_CONF" | grep -E "KEYBOARD_OPTIONS")
    _keyboard_options="${_keyboard_options##*=}"
  }

  [ -n "$_keyboard_model" ] && \
    _output+="-model ${_keyboard_model} "

  [ -n "$_keyboard_layout" ] && \
    _output+="-layout ${_keyboard_layout} "

  [ -n "$_keyboard_variant" ] && \
    _output+="-variant ${_keyboard_variant} "

  [ -n "$_keyboard_options" ] && \
    _output+="-options ${_keyboard_options}"

  [[ ! -x "$(command -v setxkbmap)" ]] && {
    echo "Oppss, não foi possível encontrar setxkbmap."
    return 1
  }
  
  setxkbmap $(echo -n "$_output")
  return 0
}

# A FUNÇÃO "@config_touchpad" DEFINE AJUSTES AO COMPONENTE TOUCHPAD.
function @config_touchpad()
{
  declare -- _touchpad_enabled && {
    _touchpad_enabled=$(echo -n "$_PROJECT_CONF" | grep -E "TOUCHPAD_ENABLED")
    _touchpad_enabled="${_touchpad_enabled##*=}"
  }

  [ "$_touchpad_enabled" != "TRUE" ] && return 0

  [[ ! -x "$(command -v xinput)" ]] && {
    echo "Oppss, não foi possível encontrar xinput."
    return 1
  }

  xinput set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Tapping Enabled' 1
  return 0
}

# A FUNÇÃO "@wm" INICIALIZA O GERENCIADOR DE JANELAS.
function @wm
{
  declare -- _window_manager_session && {
    _window_manager_session=$(echo -n "$_PROJECT_CONF" | grep -E "WINDOW_MANAGER_SESSION")
    _window_manager_session="${_window_manager_session##*=}"
  }

  declare -- _window_manager_options && {
    _window_manager_options=$(echo -n "$_PROJECT_CONF" | grep -E "WINDOW_MANAGER_OPTIONS")
    _window_manager_options="${_window_manager_options##*=}"
    [ -n "$_window_manager_options" ] && {
      _window_manager_options="${_window_manager_options/BASE_DIR/$_PROJECT_PATH}"
    }
  }

 
  [[ ! -x "$(command -v "$_window_manager_session")" ]] && {
    echo "Oppss, não foi possível encontrar "$_window_manager_session"."
    exit 1
  }
  
  exec $(echo ""$_window_manager_session" "$_window_manager_options"")
}

# A FUNÇÃO "@autostart" INICIALIZA APLICAÇÕES DEFINIDAS EM AUTOSTART.
function @autostart()
{
  declare -- _autostart_enabled && {
    _autostart_enabled=$(echo -n "$_PROJECT_CONF" | grep -E "AUTOSTART_ENABLED")
    _autostart_enabled="${_autostart_enabled##*=}"
  }

  [ "$_autostart_enabled" != "TRUE" ] && return 0
  
  declare -- _autostart_await && {
    _autostart_await=$(echo -n "$_PROJECT_CONF" | grep -E "AUTOSTART_AWAIT")
    _autostart_await="${_autostart_await##*=}"
  }

  [[ ! "$_autostart_await" =~ ^-?[0-9]+$ ]] && {
    echo "Oppss, o tempo de inicialização precisa ser um valor inteiro."
    return 1
  }

  [ ! -d "$_PROJECT_PATH/autostart" ] && \
    mkdir "$_PROJECT_PATH/autostart"
  
  sleep "$_autostart_await" &>/dev/null && {
    declare -- _autostart_apps && {
      _autostart_apps=$(find "$_PROJECT_PATH/autostart" -type f)
      mapfile -t _autostart_apps <<< "$_autostart_apps"
    }

    for str in "${_autostart_apps[@]}"; do

      [ ! -f "$str" ] || \
      [[ ! "$str" =~ .*".desktop"*. ]] && \
        continue

      declare -- _read_desktop_entry && {
        _read_desktop_entry=$(cat "$str" | grep -E "Exec=*")
        _read_desktop_entry="${_read_desktop_entry##*Exec=}"
      }

      [ -z "$_read_desktop_entry" ] && continue

      exec $(echo -n "$_read_desktop_entry") &   
    done
  }

  return 0
}

# A FUNÇÃO "@wallpaper" DEFINE AJUSTES AO COMPONENTE DE PLANO DE FUNDO.
function @wallpaper()
{
  declare -- _wallpaper_enabled && {
    _wallpaper_enabled=$(echo "$_PROJECT_CONF" | grep -E "WALLPAPER_ENABLED=*")
    _wallpaper_enabled="${_wallpaper_enabled##*=}"
  }

  [ "$_wallpaper_enabled" != "TRUE" ] && return 0

  [[ ! -x "$(command -v feh)" ]] && {
    echo "Oppss, não foi possível encontrar feh."
    return 1
  }
  
  exec feh --conversion-timeout 1 --bg-fill ~/.config/better-wm/background/01.png & 

  return 0
}

# A FUNÇÃO "@autoclean" ELIMINA TODA A BAGUNÇA FEITA PELO SCRIPT.
function @autoclean ()
{
  declare -- _status_code && {
    _status_code="$?"
  }

  declare -a _unset_map && {
    _unset_map=(
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

# A DECLARAÇÃO "_PROJECT_PATH" DEFINE O CAMINHO ABSOLUTO DO PROJETO.
declare -- _PROJECT_PATH && {
  _PROJECT_PATH="/home/USER"
  _PROJECT_PATH="${_PROJECT_PATH/USER/$USER}/.config/better-wm"
}

# A DECLARAÇÃO "_PROJECT_CONF" DEFINE O COMPORTAMENTO DOS COMPONENTES.
declare -- _PROJECT_CONF && {
  [[ -f "$_PROJECT_PATH/i3/config.conf" ]] && {
    _PROJECT_CONF=$(cat < "$_PROJECT_PATH/i3/config.conf")
  }
}

# A DECLARAÇÃO "_FUNCTIONS_MAP" DEFINE A ORDEM DE EXECUÇÃO DOS COMPONENTES
# NA AUSENCIA DE UM PARAMETRO DE INICIALIZAÇÃO.
declare -a _FUNCTIONS_MAP && {
  _FUNCTIONS_MAP=(
    "@config_keyboard"
    "@config_touchpad"
    "@wallpaper"
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
