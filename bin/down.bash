#!/usr/bin/env bash

# CONFIGURAÇÕES BÁSICAS PARA O ENCERRAMENTO DE UM GERENCIADOR DE JANELAS.
# PROJETO: (https://github.com/jcmljunior/better-wm)
# AUTOR: JULIO CESAR <jcmljunior@gmail.com>
# VERSÃO: 1.0.0

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

function @main()
{
  declare -- _wallpaper_enabled && {
    _wallpaper_enabled=$(echo "$_PROJECT_CONF" | grep -E "WALLPAPER_ENABLED=*")
    _wallpaper_enabled="${_wallpaper_enabled##*=}"
  }

  [ "$_wallpaper_enabled" != "TRUE" ] && return 0

  [ ! -x "$(command -v feh)" ] && {
    echo "Oppss, não foi possível encontrar feh."
    return 1
  }

  exec feh --bg-scale ~/.config/better-wm/background/background-exit2.png &

  [ -x "$(command -v xdotool)" ] && return 0

  declare -- _window_manager_session && {
    _window_manager_session=$(echo "$_PROJECT_CONF" | grep -E "WINDOW_MANAGER_SESSION=*")
    _window_manager_session="${_window_manager_session##*=}"
  }

  [ "$_window_manager_session" = "i3" ] && {
    exec xdotool key super+b
  }
  
  return 0
}

@main

exit 0

