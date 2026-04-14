#!/bin/bash

# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2024-present Ricardo Alvarenga
# Moonlight Stream Launcher - Inicia sessão de streaming pelo EmulationStation

MOONLIGHT_CONFIG="/storage/.config/moonlight-embedded/moonlight.conf"
MOONLIGHT_BIN="/usr/bin/moonlight"

# Verificar se o binário existe
if [ ! -x "${MOONLIGHT_BIN}" ]; then
    text_viewer -m "Moonlight não encontrado.\nVerifique a instalação." -t "Moonlight"
    exit 1
fi

# Verificar se o arquivo de configuração existe
if [ ! -f "${MOONLIGHT_CONFIG}" ]; then
    text_viewer -m "Configuração não encontrada.\n\nAcesse Tools > Moonlight Settings\ne configure o host e as opções antes de iniciar." \
        -t "Moonlight"
    exit 1
fi

# Carregar configuração
source "${MOONLIGHT_CONFIG}"

# Verificar se o host está configurado
if [ -z "${host}" ]; then
    text_viewer -m "Host não configurado.\n\nAcesse Tools > Moonlight Settings\ne informe o IP ou hostname do seu PC." \
        -t "Moonlight"
    exit 1
fi

# Parsear resolução (ex: 854x480 → width=854 height=480)
width=$(echo "${resolution:-854x480}" | cut -d'x' -f1)
height=$(echo "${resolution:-854x480}" | cut -d'x' -f2)

# Montar argumentos
MOONLIGHT_ARGS="stream"
MOONLIGHT_ARGS="${MOONLIGHT_ARGS} -width ${width}"
MOONLIGHT_ARGS="${MOONLIGHT_ARGS} -height ${height}"
MOONLIGHT_ARGS="${MOONLIGHT_ARGS} -fps ${fps:-30}"
MOONLIGHT_ARGS="${MOONLIGHT_ARGS} -bitrate ${bitrate:-2500}"

if [ -n "${codec}" ] && [ "${codec}" != "auto" ]; then
    MOONLIGHT_ARGS="${MOONLIGHT_ARGS} -codec ${codec}"
fi

if [ -n "${app}" ]; then
    MOONLIGHT_ARGS="${MOONLIGHT_ARGS} -app \"${app}\""
fi

MOONLIGHT_ARGS="${MOONLIGHT_ARGS} ${host}"

# Configurar ambiente SDL para framebuffer
export SDL_VIDEODRIVER=fbcon
export SDL_FBDEV=/dev/fb0

# Iniciar streaming
eval "${MOONLIGHT_BIN} ${MOONLIGHT_ARGS}"
