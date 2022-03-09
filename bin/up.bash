#!/usr/bin/env bash

# CONFIGURAÇÕES BÁSICAS PARA A INICIALIZAÇÃO DE UM GERENCIADOR DE JANELAS.
# PROJETO: (https://github.com/jcmljunior/better-wm)
# AUTHOR: JULIO CESAR <jcmljunior@gmail.com>
# VERSÃO: 1.0.0

# A FUNÇÃO "_cleanup" É RESPONSÁVEL POR ELIMINAR ARQUIVOS E CONFIGURAÇÕES TEMPORARIA.
function _cleanup
{
    declare -- _status_code && {
        _status_code="$?"
    }
    declare -a _unset_map && {
        _unset_map=(
            "_PROJECT_PATH"
            "_PROJECT_DIR"
            "_PROJECT_MODE"
            "_PROJECT_CONF"
        )
    }

    for str in "${_unset_map[@]}"; do
        unset -n "$str"
    done

    exit "$_status_code"
}

# A FUNÇÃO "_get_path" RETORNA O CAMINHO ABSOLUTO DO PROJETO DE ACORDO COM AS CONFIGURAÇÕES
# DA VARIAVEL "_PROJECT_MODE".
function _get_path()
{
    [[ "$_PROJECT_MODE" == "developer" ]] && {
        echo "$_PROJECT_PATH/Git/$_PROJECT_DIR"
        return 0
    }

    [[ "$_PROJECT_MODE" == "production" ]] && {
        echo "$_PROJECT_PATH/.config/$_PROJECT_DIR"
        return 0
    }
    
    echo "Operation not permitted."
    return 1
}

# A FUNÇÃO "_in_array" PROCURA POR UM VALOR ESPECIFICO EM UM ARRAY.
# DEMO 01: _in_array "O QUE PROCURA?" "AONDE PROCURAR?"
# DEMO 02: _in_array "O QUE PROCURA?" "AONDE PROCURAR 01" "AONDE PROCURAR 02" "AONDE PROCURAR 03" [...]
function _in_array()
{
    declare -- _looking_for && {
        _looking_for="$1"
    }
    declare -a _looking_map && {
        _looking_map=("${@:2}")
    }

    for str in "${_looking_map[@]}"; do
        [[ "$str" =~ .*"$_looking_for".* ]] && {
            echo "TRUE"
            return 0
        }
    done

    echo "FALSE"
    return 1
}

# A FUNÇÃO "_autoload" INICIA TODAS AS ENTRADAS DE ÁREA DE TRABALHO. (XDG)
function _autoload()
{
    declare -I _PROJECT_PATH && {
        _PROJECT_PATH="$_PROJECT_PATH/.config"
    }
    declare -a _directories

    [[ -d "/etc/xdg/autostart" ]] && {
        _directories[0]="/etc/xdg/autostart" || return 1
    }

    [[ -d "$_PROJECT_PATH/autostart" ]] && {
        _directories[1]="$_PROJECT_PATH/autostart"
    }

    for directory in "${_directories[@]}"; do
        declare -x _desktop_entries && {
            _desktop_entries=$(find "$directory" -type f)
        }
        declare -a _desktop_entries_map && {
            _desktop_entries_map=($_desktop_entries)
        }
        declare -- _desktop_entries_not_allowed && {
            _desktop_entries_not_allowed=$(echo -n "$_PROJECT_CONF" | grep -E "AUTOSTART_BLOCKED")
            _desktop_entries_not_allowed="${_desktop_entries_not_allowed##*=}"
        }

        for application in "${_desktop_entries_map[@]}"; do
            declare -x _desktop_entry_app && {
                _desktop_entry_app=$(grep -E "Exec=" "$application" <<< cat)
                _desktop_entry_app="${_desktop_entry_app##*Exec=}"
            }
            declare -f _check_str && {
                _check_str=$(_in_array "$_desktop_entry_app" "$_desktop_entries_not_allowed")
            }

            [[ "$_check_str" == "TRUE" ]] || [[ ! -f "$application" ]] && continue

            exec "$_desktop_entry_app" &
        done
    done
}

function _keyboard()
{
    declare -- _layout && {
        _layout=$(echo -n "$_PROJECT_CONF" | grep -E "KEYBOARD_LAYOUT")
        _layout="${_layout##*=}"
    }
    declare -- _variant && {
        _variant=$(echo -n "$_PROJECT_CONF" | grep -E "KEYBOARD_VARIANT")
        _variant="${_variant##*=}"
    }
    declare -- _features && {
        _features=$(echo -n "$_PROJECT_CONF" | grep -E "KEYBOARD_FEATURES")
        _features="${_features##*=}"
    }
    declare -- _output

    [[ -n "$_layout" ]] && {
        _output+="-model -layout $_layout "
    }
    [[ -n "$_variant" ]] && {
        _output+="-variant $_variant "
    }
    [[ -n "$_features" ]] && {
        _output+="$_features"
    }

    [[ -x "$(command -v setxkbmap)" ]] && {
        setxkbmap $_output &
    }
}

function _touchpad()
{
    declare -- _tap; _tap=$(echo -n "$_PROJECT_CONF" | grep -E "TOUCHPAD_TAPTOCLICK") && {
        _tap="${_tap##*=}"
    }

    [[ "$_tap" == "TRUE" ]] && [[ -x "$(command -v xinput)" ]] && {
        xinput set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Tapping Enabled' 1 &
    }
}

function _window_manager()
{
    declare -- _window_m && {
        _window_m=$(echo -n "$_PROJECT_CONF" | grep -E "BETTERWM_SESSION")
        _window_m="${_window_m##*=}"
    }

    [[ -x "$(command -v "$_window_m")" ]] && {
        exec "$_window_m"
    }
}

function _xcursor()
{
    [[ -x "$(command -v xsetroot)" ]] && {
        xsetroot -cursor_name left_ptr &
    }
}

# A FUNÇÃO "_main" INICIALIZA TODOS OS COMPONENTES.
function _main()
{
    declare -- _use_autoload && {
        _use_autoload=$(echo -n "$_PROJECT_CONF" | grep -E "AUTOSTART_ENABLE")
        _use_autoload="${_use_autoload##*=}"
    }
    [[ "$_use_autoload" == "TRUE" ]] && _autoload

    declare -- _use_keyboard && {
        _use_keyboard=$(echo -n "$_PROJECT_CONF" | grep -E "KEYBOARD_ENABLED")
        _use_keyboard="${_use_keyboard##*=}"
    }
    [[ "$_use_keyboard" == "TRUE" ]] && _keyboard

    declare -- _use_touchpad && {
        _use_touchpad=$(echo -n "$_PROJECT_CONF" | grep -E "TOUCHPAD_ENABLED")
        _use_touchpad="${_use_touchpad##*=}"
    }
    [[ "$_use_touchpad" == "TRUE" ]] && _touchpad

    _xcursor

    _window_manager
}

# DEFINIÇÕES DE PROJETO.
declare -- _PROJECT_MODE && {
    _PROJECT_MODE="developer"
}
declare -- _PROJECT_PATH && {
    _PROJECT_PATH="/home/USER"
    _PROJECT_PATH="${_PROJECT_PATH/USER/$USER}"
}
declare -- _PROJECT_DIR && {
    _PROJECT_DIR="better-wm"
}

# DEFINIÇÕES DE FUNCIONALIDADES.
declare -- _PROJECT_CONF && {
    _PROJECT_CONF=$(cat "$(_get_path)""/config.conf")
}

_main

echo "Done!"

trap _cleanup exit 0
