#!/bin/bash

# Caminho do segundo SD (ajuste conforme seu sistema)
SD2_MOUNT="/media/sd2"

if ! mountpoint -q "$SD2_MOUNT"; then
    echo "Erro: $SD2_MOUNT não está montado!"
    exit 1
fi

# Pastas a redirecionar
DIRS="roms bios saves configs"

# Caminho original (no cartão principal)
ORIG_BASE="/storage"

for dir in $DIRS; do
    # Cria a pasta no SD2 se não existir
    mkdir -p "$SD2_MOUNT/$dir"
    # Remove o diretório original se for pasta ou link
    rm -rf "$ORIG_BASE/$dir"
    # Cria o link simbólico
    ln -s "$SD2_MOUNT/$dir" "$ORIG_BASE/$dir"
done

echo "Redirecionamento concluído! Agora as pastas apontam para o segundo SD."