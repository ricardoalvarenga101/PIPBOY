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

# Export environment variables for proper display
export SDL_VIDEODRIVER=fbcon
export SDL_FBDEV=/dev/fb0

# Run moonlight
exec "${MOONLIGHT_BIN}" "$@"
