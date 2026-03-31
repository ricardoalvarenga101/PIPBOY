#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present SeuNome

# Módulo: Games to SD
# Permite mapear um novo diretório (ex: SD externo) para jogos, saves e configs, substituindo o GAMES padrão.

GAMES_ORIG="/storage/roms"
GAMES_NEW="$(get_second_sdcard)/GAMES" # Caminho sugerido para o novo local
CONFIG_FILE="/storage/roms/gamedata/games-to-sd.conf"

# Função para detectar o segundo SD Card
get_second_sdcard() {
    # Lista dispositivos montados em /media, exceto o principal (/storage)
    # Considera apenas diretórios que não sejam o padrão do sistema
    for mount in /media/*; do
        if [ -d "$mount" ] && [ "$mount" != "/media/$(lsblk -no LABEL /dev/mmcblk0p1 2>/dev/null)" ]; then
            # Verifica se não é o mesmo do sistema
            if [ "$mount" != "/media/$(lsblk -no LABEL /dev/root 2>/dev/null)" ]; then
                echo "$mount"
                return 0
            fi
        fi
    done
    return 1
}

# Detecta o segundo SD Card
GAMES_NEW="$(get_second_sdcard)/GAMES"
if [ -z "$GAMES_NEW" ] || [ ! -d "$(dirname "$GAMES_NEW")" ]; then
    text_viewer -m "Não foi detectado um segundo cartão SD!\nInsira o SD secundário e tente novamente." -t "Games to SD"
    exit 1
fi

# Permite customização via config
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Função para criar symlink seguro
safe_symlink() {
    local src="$1"
    local dst="$2"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "$dst.bak.$(date +%s)"
    fi
    ln -sf "$src" "$dst"
}

# Menu para o usuário
text_viewer -y -w -m "Deseja mapear os jogos, saves e configs para o SD externo?\n\nNovo destino: $GAMES_NEW\n\nVocê pode reverter depois." -t "Games to SD"
response=$?

case $response in
    0)
        exit 0
        ;;
    21)
        # Verifica se o novo diretório existe
        if [ ! -d "$GAMES_NEW" ]; then
            text_viewer -m "O diretório $GAMES_NEW não foi encontrado!\nInsira o SD e tente novamente." -t "Games to SD"
            exit 1
        fi
        # Move dados se necessário
        if [ -d "$GAMES_ORIG" ] && [ ! -L "$GAMES_ORIG" ]; then
            rsync -a --ignore-existing "$GAMES_ORIG/" "$GAMES_NEW/"
            mv "$GAMES_ORIG" "$GAMES_ORIG.bak.$(date +%s)"
        fi
        # Cria symlink
        safe_symlink "$GAMES_NEW" "$GAMES_ORIG"
        text_viewer -m "Diretório de jogos agora está no SD externo!" -t "Games to SD"
        ;;
    *)
        # Pergunta se deseja reverter
        text_viewer -y -w -m "Deseja reverter para o diretório original de jogos?\n\nIsso irá restaurar o local padrão." -t "Games to SD"
        revert=$?
        if [ "$revert" = "21" ]; then
            if [ -L "$GAMES_ORIG" ]; then
                rm "$GAMES_ORIG"
                if [ -d "$GAMES_ORIG.bak."* ]; then
                    mv "$GAMES_ORIG.bak."* "$GAMES_ORIG"
                fi
                text_viewer -m "Diretório de jogos restaurado para o local original!" -t "Games to SD"
            else
                text_viewer -m "O diretório original já está em uso." -t "Games to SD"
            fi
        fi
        ;;
esac
