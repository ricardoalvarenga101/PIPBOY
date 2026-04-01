#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present PipBoy
#
# Alterna entre o WiFi interno (2.4GHz embarcado) e um adaptador USB via OTG (5GHz).
# A preferência é persistida via wifi.internal.disabled e sobrevive a reinicializações.

. /etc/profile

CURRENT=$(get_ee_setting wifi.internal.disabled)

# Detectar qual interface OTG USB está presente (wlan1, wlan2, etc.)
OTG_IF=$(ls /sys/class/net/ 2>/dev/null | grep -E '^wlan[1-9]' | head -1)

if [ "$CURRENT" == "1" ]; then
    # -----------------------------------------------------------------------
    # Estado atual: WiFi INTERNO desabilitado, adaptador OTG em uso
    # -----------------------------------------------------------------------
    if [ -n "$OTG_IF" ]; then
        OTG_INFO="Adaptador OTG ativo: ${OTG_IF}"
    else
        OTG_INFO="(adaptador OTG não detectado no momento)"
    fi

    text_viewer -w -y \
        -t "WiFi - Modo Atual: ADAPTADOR OTG" \
        -m "\nO WiFi interno (2.4GHz) está DESABILITADO.\n${OTG_INFO}\n\nDeseja voltar ao WiFi INTERNO (2.4GHz)?\n\nYES = Ativar WiFi interno, desabilitar OTG\nNO  = Manter adaptador OTG ativo"
    response=$?

    if [ "$response" -eq 0 ]; then
        set_ee_setting wifi.internal.disabled 0
        batocera-internal-wifi enable
        text_viewer -w \
            -t "WiFi Interno Ativado" \
            -m "\nWiFi interno (2.4GHz) ativado com sucesso.\n\nO adaptador OTG não será mais priorizado.\nReconecte ao WiFi pelas Configurações de Rede se necessário.\n\nEsta escolha é mantida após reinicialização."
    fi
else
    # -----------------------------------------------------------------------
    # Estado atual: WiFi INTERNO habilitado (padrão)
    # -----------------------------------------------------------------------
    if [ -z "$OTG_IF" ]; then
        text_viewer -w -e \
            -t "Adaptador OTG Não Detectado" \
            -m "\nNenhum adaptador WiFi USB foi encontrado na porta OTG.\n\nCertifique-se de que:\n  - O adaptador está conectado na porta OTG\n  - O driver do chipset está disponível\n    (ex: RTL8812AU, RTL8821CU, RTL88x2BU)\n\nConecte o adaptador e tente novamente."
        exit 0
    fi

    # Tentar obter frequências suportadas pelo adaptador OTG
    OTG_BANDS="5GHz"
    if command -v iw &>/dev/null; then
        if iw dev "$OTG_IF" info 2>/dev/null | grep -q "5[0-9][0-9][0-9]"; then
            OTG_BANDS="5GHz confirmado"
        fi
    fi

    text_viewer -w -y \
        -t "WiFi - Modo Atual: INTERNO (2.4GHz)" \
        -m "\nO WiFi interno (2.4GHz) está ATIVO.\nAdaptador OTG detectado: ${OTG_IF} (${OTG_BANDS})\n\nDeseja usar o ADAPTADOR OTG no lugar do WiFi interno?\n\nYES = Desabilitar interno, usar adaptador OTG\nNO  = Manter WiFi interno ativo"
    response=$?

    if [ "$response" -eq 0 ]; then
        set_ee_setting wifi.internal.disabled 1
        batocera-internal-wifi disable
        text_viewer -w \
            -t "Adaptador OTG Ativado" \
            -m "\nWiFi interno desabilitado.\nAdaptador OTG (${OTG_IF}) está ativo.\n\nReconecte ao WiFi 5GHz pelas Configurações de Rede.\n\nEsta escolha é mantida após reinicialização:\no WiFi interno permanecerá bloqueado até você\nreverter por este menu."
    fi
fi
