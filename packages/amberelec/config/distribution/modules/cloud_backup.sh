#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Xargon (https://github.com/XargonWan)

# Create rclone dir if it does not exist
mkdir -p /storage/roms/gamedata/rclone/

# Source CLOUD_SYNC_PATH and CLOUD_SYNC_REMOTE
CLOUD_SYNC_CONFIG="/storage/roms/gamedata/rclone/cloud-sync.conf"
if [ ! -f "$CLOUD_SYNC_CONFIG" ]; then
    cp /usr/config/cloud-sync.conf "$CLOUD_SYNC_CONFIG"
fi
source "$CLOUD_SYNC_CONFIG"

# If the rclone rules don't exist it will copy the default ones
if [ ! -f /storage/roms/gamedata/rclone/cloud-sync-rules.conf ]; then
    cp /usr/config/cloud-sync-rules.conf /storage/roms/gamedata/rclone/
fi

# If the user didn't provide the rclone config file the program script will end
if [ ! -f "/roms/gamedata/rclone/rclone.conf" ]; then
    text_viewer -w -e -m "ERRO: /roms/gamedata/rclone/rclone.conf está ausente\nPor favor forneça o arquivo rclone.conf.\n\nPara mais informações, consulte: https://rclone.org/" -t "PipBoy — Backup na Nuvem"
    exit 0
fi

text_viewer -y -w -m "Deseja fazer backup dos seus dados na nuvem?" -t "PipBoy — Backup na Nuvem"
response=$?

case $response in
    
    0)
        exit 0
        ;;

    21)
        clear > /dev/console
        rclone sync /storage/roms/ "$CLOUD_SYNC_REMOTE":"$CLOUD_SYNC_PATH" --filter-from /roms/gamedata/rclone/cloud-sync-rules.conf -P --config /roms/gamedata/rclone/rclone.conf --log-level DEBUG --log-file /tmp/logs/cloud-sync.log 2>&1 > /dev/console
        text_viewer -m "Backup concluído!" -t "PipBoy — Backup na Nuvem"
        ;;
esac
