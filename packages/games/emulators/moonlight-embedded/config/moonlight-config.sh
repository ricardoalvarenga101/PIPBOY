#!/bin/bash

# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2024-present Ricardo Alvarenga
# Moonlight Configuration Utility

MOONLIGHT_CONFIG_DIR="/storage/.config/moonlight-embedded"
MOONLIGHT_CONFIG="${MOONLIGHT_CONFIG_DIR}/moonlight.conf"
TEMP_CONFIG="/tmp/moonlight_config.tmp"

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

while true; do
    # Menu principal
    choice=$(text_viewer -c \
        "Configurar Moonlight Embedded" \
        "1 - Resolução: $resolution" \
        "2 - FPS: $fps" \
        "3 - Bitrate: ${bitrate} kbps" \
        "4 - Codec: $codec" \
        "5 - App Padrão: ${app:-(sem seleção)}" \
        "6 - Salvar e Sair" \
        "7 - Sair sem Salvar" \
        -t "PipBoy — Moonlight Config")

    case $choice in
        1)
            # Menu de resoluções
            res_choice=$(text_viewer -c \
                "Selecione a Resolução" \
                "1 - 640x360 (Baixa / Menos Bandwidth)" \
                "2 - 800x600 (SVGA)" \
                "3 - 1024x576 (HDTV)" \
                "4 - 854x480 (Recomendado - RG351MP)" \
                "5 - 1280x720 (HD)" \
                "6 - 1366x768 (HD+)" \
                "7 - 1920x1080 (Full HD)" \
                "8 - Outra (digite manualmente)" \
                -t "Resolução")

            case $res_choice in
                1) resolution="640x360" ;;
                2) resolution="800x600" ;;
                3) resolution="1024x576" ;;
                4) resolution="854x480" ;;
                5) resolution="1280x720" ;;
                6) resolution="1366x768" ;;
                7) resolution="1920x1080" ;;
                8)
                    # Input customizado
                    custom_res=$(text_viewer -e -t "Digite a resolução (LARGURAxALTURA):" -i "1280x720")
                    if [ ! -z "$custom_res" ]; then
                        resolution="$custom_res"
                    fi
                    ;;
            esac
            ;;

        2)
            # Menu de FPS
            fps_choice=$(text_viewer -c \
                "Selecione os FPS" \
                "1 - 24 (Mínimo)" \
                "2 - 30 (Recommended - 2.4GHz WiFi)" \
                "3 - 60 (Recomendado - 5GHz WiFi)" \
                "4 - Outro" \
                -t "FPS")

            case $fps_choice in
                1) fps=24 ;;
                2) fps=30 ;;
                3) fps=60 ;;
                4)
                    custom_fps=$(text_viewer -e -t "Digite os FPS desejados:" -i "30")
                    if [ ! -z "$custom_fps" ]; then
                        fps="$custom_fps"
                    fi
                    ;;
            esac
            ;;

        3)
            # Menu de Bitrate
            br_choice=$(text_viewer -c \
                "Selecione o Bitrate" \
                "1 - 2500 kbps (Recomendado - Baixa Latência)" \
                "2 - 5000 kbps (HEVC)" \
                "3 - 8000 kbps (H.264 Bom)" \
                "4 - 15000 kbps (Alta Qualidade)" \
                "5 - Outro" \
                -t "Bitrate")

            case $br_choice in
                1) bitrate=2500 ;;
                2) bitrate=5000 ;;
                3) bitrate=8000 ;;
                4) bitrate=15000 ;;
                5)
                    custom_br=$(text_viewer -e -t "Digite o bitrate (kbps):" -i "5000")
                    if [ ! -z "$custom_br" ]; then
                        bitrate="$custom_br"
                    fi
                    ;;
            esac
            ;;

        4)
            # Menu de Codec
            codec_choice=$(text_viewer -c \
                "Selecione o Codec" \
                "1 - Auto (recomendado)" \
                "2 - H.264 (compatibilidade)" \
                "3 - HEVC / H.265 (eficiência)" \
                -t "Codec")

            case $codec_choice in
                1) codec="auto" ;;
                2) codec="h264" ;;
                3) codec="hevc" ;;
            esac
            ;;

        5)
            # Menu de App
            app_choice=$(text_viewer -c \
                "Selecione o App Padrão" \
                "1 - Desktop" \
                "2 - Steam Big Picture" \
                "3 - Outro (personalizável)" \
                "4 - Sem app padrão" \
                -t "App Padrão")

            case $app_choice in
                1) app="Desktop" ;;
                2) app="Steam Big Picture Mode" ;;
                3)
                    custom_app=$(text_viewer -e -t "Digite o nome do app:" -i "")
                    if [ ! -z "$custom_app" ]; then
                        app="$custom_app"
                    fi
                    ;;
                4) app="" ;;
            esac
            ;;

        6)
            # Salvar configuração
            cat > "${MOONLIGHT_CONFIG}" << EOF
# Configuração do Moonlight Embedded para PipBoy
# Gerado automaticamente: $(date)

resolution="${resolution}"
fps=${fps}
bitrate=${bitrate}
codec="${codec}"
$([ ! -z "$app" ] && echo "app=\"${app}\"")
EOF

            text_viewer -m "Configuração salva com sucesso!\n\nResolução: $resolution\nFPS: $fps\nBitrate: ${bitrate} kbps\nCodec: $codec\n$([ ! -z "$app" ] && echo "App: $app")" \
                -t "PipBoy — Moonlight"
            exit 0
            ;;

        7)
            # Sair sem salvar
            text_viewer -m "Configuração descartada." -t "PipBoy — Moonlight"
            exit 0
            ;;

        *)
            # Menu inválido
            continue
            ;;
    esac
done
