#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present SeuNome

# Módulo: Wifi Toggle (OTG)
# Desativa o Wi-Fi nativo e ativa o Wi-Fi via OTG (USB tipo C), ou reverte a operação.

# Função para detectar interfaces Wi-Fi
get_wifi_interfaces() {
    iw dev | awk '/Interface/ {print $2}'
}

# Função para desativar interface
disable_interface() {
    local iface="$1"
    if [ -n "$iface" ]; then
        ip link set "$iface" down
        rfkill block wifi
    fi
}

# Função para ativar interface
enable_interface() {
    local iface="$1"
    if [ -n "$iface" ]; then
        rfkill unblock wifi
        ip link set "$iface" up
    fi
}

# Detecta interfaces
WIFI_NATIVE="wlan0"
WIFI_OTG="wlan1"

# Permite customização via config
CONFIG_FILE="/storage/roms/gamedata/wifi-toggle.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Menu para o usuário
text_viewer -y -w -m "Deseja ativar o Wi-Fi via OTG (USB-C)?\n\nIsso irá desativar o Wi-Fi nativo e ativar o adaptador OTG.\n\nVocê pode reverter depois." -t "Wifi Toggle (OTG)"
response=$?

case $response in
    0)
        exit 0
        ;;
    21)
        # Ativar OTG, desativar nativo
        disable_interface "$WIFI_NATIVE"
        enable_interface "$WIFI_OTG"
        text_viewer -m "Wi-Fi OTG ativado!\nWi-Fi nativo desativado." -t "Wifi Toggle (OTG)"
        ;;
    *)
        # Pergunta se deseja reverter
        text_viewer -y -w -m "Deseja reverter para o Wi-Fi nativo?\n\nIsso irá desativar o OTG e reativar o Wi-Fi interno." -t "Wifi Toggle (OTG)"
        revert=$?
        if [ "$revert" = "21" ]; then
            disable_interface "$WIFI_OTG"
            enable_interface "$WIFI_NATIVE"
            text_viewer -m "Wi-Fi nativo reativado!\nWi-Fi OTG desativado." -t "Wifi Toggle (OTG)"
        fi
        ;;
esac
