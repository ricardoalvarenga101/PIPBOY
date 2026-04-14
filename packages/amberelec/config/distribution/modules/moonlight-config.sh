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

# Criar diretório se não existir
mkdir -p "${MOONLIGHT_CONFIG_DIR}"

# Carregar configuração atual se existir
if [ -f "${MOONLIGHT_CONFIG}" ]; then
    source "${MOONLIGHT_CONFIG}"
fi

# Valores padrão
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

while true; do
    choice=$(dialog \
        --title " PipBoy — Moonlight Config " \
        --clear \
        --no-cancel \
        --menu "Configure as opções de streaming:" \
        18 60 8 \
        "1" "Resolução:  ${resolution}" \
        "2" "FPS:        ${fps}" \
        "3" "Bitrate:    ${bitrate} kbps" \
        "4" "Codec:      ${codec}" \
        "5" "App Padrão: ${app:-(sem seleção)}" \
        "6" "Host / IP:  ${host:-(não configurado)}" \
        "7" "Salvar e Sair" \
        "8" "Sair sem Salvar" \
        2>&1 > /dev/console)

    [ $? -ne 0 ] && Quit

    case $choice in
        1)
            res_choice=$(dialog \
                --title " Resolução " \
                --clear \
                --menu "Selecione a resolução:" \
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
                    custom_res=$(dialog \
                        --title " Resolução Customizada " \
                        --inputbox "Digite a resolução (LARGURAxALTURA):" \
                        8 44 "${resolution}" \
                        2>&1 > /dev/console)
                    [ $? -eq 0 ] && [ -n "$custom_res" ] && resolution="$custom_res"
                    ;;
            esac
            ;;

        2)
            fps_choice=$(dialog \
                --title " FPS " \
                --clear \
                --menu "Selecione os FPS:" \
                12 50 4 \
                "1" "24  (Mínimo)" \
                "2" "30  (Recomendado - WiFi 2.4GHz)" \
                "3" "60  (Recomendado - WiFi 5GHz)" \
                "4" "Outro" \
                2>&1 > /dev/console)

            case $fps_choice in
                1) fps=24 ;;
                2) fps=30 ;;
                3) fps=60 ;;
                4)
                    custom_fps=$(dialog \
                        --title " FPS Customizado " \
                        --inputbox "Digite os FPS desejados:" \
                        8 40 "${fps}" \
                        2>&1 > /dev/console)
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
                "1" "2500   kbps (Recomendado - Baixa Latência)" \
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
                    custom_br=$(dialog \
                        --title " Bitrate Customizado " \
                        --inputbox "Digite o bitrate (kbps):" \
                        8 40 "${bitrate}" \
                        2>&1 > /dev/console)
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
                "3" "HEVC    (H.265 - eficiência)" \
                2>&1 > /dev/console)

            case $codec_choice in
                1) codec="auto" ;;
                2) codec="h264" ;;
                3) codec="hevc" ;;
            esac
            ;;

        5)
            app_choice=$(dialog \
                --title " App Padrão " \
                --clear \
                --menu "Selecione o app padrão:" \
                11 50 4 \
                "1" "Desktop" \
                "2" "Steam Big Picture Mode" \
                "3" "Outro (personalizável)" \
                "4" "Sem app padrão" \
                2>&1 > /dev/console)

            case $app_choice in
                1) app="Desktop" ;;
                2) app="Steam Big Picture Mode" ;;
                3)
                    custom_app=$(dialog \
                        --title " App Customizado " \
                        --inputbox "Digite o nome do app:" \
                        8 40 "${app}" \
                        2>&1 > /dev/console)
                    [ $? -eq 0 ] && [ -n "$custom_app" ] && app="$custom_app"
                    ;;
                4) app="" ;;
            esac
            ;;

        6)
            new_host=$(dialog \
                --title " Host / IP " \
                --inputbox "Digite o IP ou hostname do PC:" \
                8 50 "${host}" \
                2>&1 > /dev/console)
            [ $? -eq 0 ] && [ -n "$new_host" ] && host="$new_host"
            ;;

        7)
            cat > "${MOONLIGHT_CONFIG}" << EOF
# Configuração do Moonlight Embedded para PipBoy
# Gerado automaticamente: $(date)

resolution="${resolution}"
fps=${fps}
bitrate=${bitrate}
codec="${codec}"
$([ -n "$app" ] && echo "app=\"${app}\"")
$([ -n "$host" ] && echo "host=\"${host}\"")
EOF

            dialog \
                --title " PipBoy — Moonlight " \
                --msgbox "Configuração salva!\n\nResolução: ${resolution}\nFPS: ${fps}\nBitrate: ${bitrate} kbps\nCodec: ${codec}" \
                10 50 2>&1 > /dev/console
            Quit
            ;;

        8)
            Quit
            ;;
    esac
done
