#!/bin/bash

# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2024-present Ricardo Alvarenga
# Moonlight Configuration Utility

export SDL_GAMECONTROLLERCONFIG_FILE="/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt"
source /usr/bin/env.sh
export TERM=xterm-color
export DIALOGRC=/etc/amberelec.dialogrc
echo -e '\033[?25h\033[?16;224;238c' > /dev/console
clear > /dev/console

gptokeyb moonlight-config.sh -c /usr/config/gptokeyb/settime.gptk &

MOONLIGHT_CONFIG_DIR="/storage/.config/moonlight-embedded"
MOONLIGHT_CONFIG="${MOONLIGHT_CONFIG_DIR}/moonlight.conf"

# Criar diretorio se nao existir
mkdir -p "${MOONLIGHT_CONFIG_DIR}"

# Carregar configuracao atual se existir
if [ -f "${MOONLIGHT_CONFIG}" ]; then
    source "${MOONLIGHT_CONFIG}"
fi

# Valores padrao
resolution=${resolution:-"854x480"}
fps=${fps:-30}
bitrate=${bitrate:-2500}
codec=${codec:-"hevc"}
app=${app:-""}
host=${host:-""}

Quit() {
    kill -9 $(pidof gptokeyb) 2>/dev/null
    echo -e '\033[?25l' > /dev/console
    clear > /dev/console
    exit 0
}

# Teclado virtual navegavel pelo controle (sem teclado fisico necessario)
# Uso: result=$(virtual_input "Titulo" "Prompt" "valor_inicial")
virtual_input() {
    local title="$1"
    local prompt="$2"
    local typed="$3"

    while true; do
        local choice
        choice=$(dialog \
            --title "$title" \
            --menu "${prompt}\n\n  [ ${typed}_ ]" \
            20 50 14 \
            "1" "1"   "2" "2"   "3" "3"   "4" "4"   "5" "5" \
            "6" "6"   "7" "7"   "8" "8"   "9" "9"   "0" "0" \
            "." "."   "x" "x"   "-" "-" \
            "DEL" "<-- Apagar" \
            "OK"  "  Confirmar  " \
            "ESC" "  Cancelar   " \
            2>&1 > /dev/console)

        [ $? -ne 0 ] && return 1

        case "$choice" in
            "DEL") typed="${typed%?}" ;;
            "OK")  printf '%s' "$typed"; return 0 ;;
            "ESC") return 1 ;;
            *)     typed="${typed}${choice}" ;;
        esac
    done
}

while true; do
    choice=$(dialog \
        --title " PipBoy - Moonlight Config " \
        --clear \
        --no-cancel \
        --menu "Configure as opcoes de streaming:" \
        18 60 8 \
        "1" "Resolucao:  ${resolution}" \
        "2" "FPS:        ${fps}" \
        "3" "Bitrate:    ${bitrate} kbps" \
        "4" "Codec:      ${codec}" \
        "5" "App Padrao: ${app:-(sem selecao)}" \
        "6" "Host / IP:  ${host:-(nao configurado)}" \
        "7" "Salvar e Sair" \
        "8" "Sair sem Salvar" \
        2>&1 > /dev/console)

    [ $? -ne 0 ] && Quit

    case $choice in
        1)
            res_choice=$(dialog \
                --title " Resolucao " \
                --clear \
                --menu "Selecione a resolucao:" \
                16 52 8 \
                "1" "640x360   (Baixa / Menos Bandwidth)" \
                "2" "800x600   (SVGA)" \
                "3" "1024x576  (HDTV)" \
                "4" "854x480   (Recomendado - RG351MP)" \
                "5" "1280x720  (HD)" \
                "6" "1366x768  (HD+)" \
                "7" "1920x1080 (Full HD)" \
                "8" "Outra     (Digite manualmente)" \
                2>&1 > /dev/console)

            case $res_choice in
                1) resolution="640x360" ;;
                2) resolution="800x600" ;;
                3) resolution="1024x576" ;;
                4) resolution="854x480" ;;
                5) resolution="1280x720" ;;
                6) resolution="1366x768" ;;
                7) resolution="1920x1080" ;;
                8)
                    custom_res=$(virtual_input " Resolucao Customizada " "Digite a resolucao (LARGURAxALTURA):" "${resolution}")
                    [ $? -eq 0 ] && [ -n "$custom_res" ] && resolution="$custom_res"
                    ;;
            esac
            ;;

        2)
            fps_choice=$(dialog \
                --title " FPS " \
                --clear \
                --menu "Selecione o FPS:" \
                12 50 4 \
                "1" "24  (Minimo)" \
                "2" "30  (Recomendado - WiFi 2.4GHz)" \
                "3" "60  (Recomendado - WiFi 5GHz)" \
                "4" "Outro" \
                2>&1 > /dev/console)

            case $fps_choice in
                1) fps=24 ;;
                2) fps=30 ;;
                3) fps=60 ;;
                4)
                    custom_fps=$(virtual_input " FPS Customizado " "Digite os FPS desejados:" "${fps}")
                    [ $? -eq 0 ] && [ -n "$custom_fps" ] && fps="$custom_fps"
                    ;;
            esac
            ;;

        3)
            br_choice=$(dialog \
                --title " Bitrate " \
                --clear \
                --menu "Selecione o bitrate:" \
                12 52 5 \
                "1" "2500   kbps (Recomendado - Baixa Latencia)" \
                "2" "5000   kbps (HEVC)" \
                "3" "8000   kbps (H.264 Bom)" \
                "4" "15000  kbps (Alta Qualidade)" \
                "5" "Outro" \
                2>&1 > /dev/console)

            case $br_choice in
                1) bitrate=2500 ;;
                2) bitrate=5000 ;;
                3) bitrate=8000 ;;
                4) bitrate=15000 ;;
                5)
                    custom_br=$(virtual_input " Bitrate Customizado " "Digite o bitrate (kbps):" "${bitrate}")
                    [ $? -eq 0 ] && [ -n "$custom_br" ] && bitrate="$custom_br"
                    ;;
            esac
            ;;

        4)
            codec_choice=$(dialog \
                --title " Codec " \
                --clear \
                --menu "Selecione o codec:" \
                10 50 3 \
                "1" "Auto    (recomendado)" \
                "2" "H.264   (compatibilidade)" \
                "3" "HEVC    (H.265 - eficiencia)" \
                2>&1 > /dev/console)

            case $codec_choice in
                1) codec="auto" ;;
                2) codec="h264" ;;
                3) codec="hevc" ;;
            esac
            ;;

        5)
            app_choice=$(dialog \
                --title " App Padrao " \
                --clear \
                --menu "Selecione o app padrao:" \
                11 50 4 \
                "1" "Desktop" \
                "2" "Steam Big Picture Mode" \
                "3" "Outro (personalizavel)" \
                "4" "Sem app padrao" \
                2>&1 > /dev/console)

            case $app_choice in
                1) app="Desktop" ;;
                2) app="Steam Big Picture Mode" ;;
                3)
                    custom_app=$(virtual_input " App Custom " "Digite o nome do app:" "${app}")
                    [ $? -eq 0 ] && [ -n "$custom_app" ] && app="$custom_app"
                    ;;
                4) app="" ;;
            esac
            ;;

        6)
            new_host=$(virtual_input " Host / IP " "Digite o IP do PC (ex: 192.168.1.100):" "${host}")
            [ $? -eq 0 ] && [ -n "$new_host" ] && host="$new_host"
            ;;

        7)
            cat > "${MOONLIGHT_CONFIG}" << EOF
# Configuracao do Moonlight Embedded para PipBoy
# Gerado automaticamente: $(date)

resolution="${resolution}"
fps=${fps}
bitrate=${bitrate}
codec="${codec}"
$([ -n "$app" ] && echo "app=\"${app}\"")
$([ -n "$host" ] && echo "host=\"${host}\"")
EOF

            dialog \
                --title " PipBoy - Moonlight " \
                --msgbox "Configuracao salva!\n\nResolucao: ${resolution}\nFPS: ${fps}\nBitrate: ${bitrate} kbps\nCodec: ${codec}" \
                10 50 2>&1 > /dev/console
            Quit
            ;;

        8)
            Quit
            ;;
    esac
done
