#!/bin/bash

# Detecta interfaces Wi-Fi
INTERNAL_IFACE="wlan0"
USB_IFACE=$(ls /sys/class/net | grep -E 'wlan[1-9]|wlx')

case "$1" in
  otg)
    echo "Desativando Wi-Fi interno ($INTERNAL_IFACE)..."
    ifconfig $INTERNAL_IFACE down
    # Opcional: rmmod do driver interno, ex: rmmod 8723ds
    echo "Ativando Wi-Fi USB ($USB_IFACE)..."
    ifconfig $USB_IFACE up
    ;;
  interno)
    echo "Desativando Wi-Fi USB ($USB_IFACE)..."
    ifconfig $USB_IFACE down
    echo "Ativando Wi-Fi interno ($INTERNAL_IFACE)..."
    ifconfig $INTERNAL_IFACE up
    ;;
  *)
    echo "Uso: $0 [otg|interno]"
    ;;
esac