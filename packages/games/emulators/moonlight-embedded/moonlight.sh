#!/bin/bash

# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2024-present Ricardo Alvarenga

# Moonlight Embedded Launcher for PipBoy

MOONLIGHT_BIN="/usr/bin/moonlight"
MOONLIGHT_CONFIG="/storage/.config/moonlight-embedded"
MOONLIGHT_CACHE="/storage/.cache/moonlight-embedded"

# Create config directories if they don't exist
mkdir -p "${MOONLIGHT_CONFIG}"
mkdir -p "${MOONLIGHT_CACHE}"

# Configurar ambiente SDL para DRM/KMS (RK3326 nao usa fbcon)
export SDL_VIDEODRIVER=kmsdrm

# Run moonlight
exec "${MOONLIGHT_BIN}" "$@"
