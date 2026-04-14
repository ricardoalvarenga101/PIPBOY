#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Script de build rápido para moonlight-embedded

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== PipBoy Moonlight Embedded Build ===${NC}\n"

# Verificar se está no diretório correto
if [ ! -f "Makefile" ]; then
    echo -e "${RED}Erro: Execute este script da raiz do projeto PipBoy${NC}"
    exit 1
fi

# Definir device e arquitetura
DEVICE="${1:-RG351MP}"
ARCH="aarch64"

echo -e "${YELLOW}Configuração:${NC}"
echo "Device: $DEVICE"
echo "Arch: $ARCH"
echo -e ""

# Opção 1: Build completo da distro (lento mas recomendado para primeira vez)
read -p "Deseja fazer build COMPLETO (1) ou apenas MOONLIGHT (2)? (padrão: 2): " build_option
build_option=${build_option:-2}

if [ "$build_option" = "1" ]; then
    echo -e "${YELLOW}Iniciando build COMPLETO da distro...${NC}"
    make clean RG351MP
    make $DEVICE
    
elif [ "$build_option" = "2" ]; then
    echo -e "${YELLOW}Iniciando build de moonlight-embedded...${NC}"
    
    # Clean do pacote amberelec (que depende de moonlight-embedded)
    echo -e "\n${YELLOW}1. Limpando pacotes dependentes...${NC}"
    DEVICE=$DEVICE ARCH=$ARCH ./scripts/clean amberelec
    
    # Build do moonlight-embedded
    echo -e "\n${YELLOW}2. Compilando moonlight-embedded...${NC}"
    DEVICE=$DEVICE ARCH=$ARCH ./scripts/build moonlight-embedded
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✓ moonlight-embedded compilado com sucesso!${NC}"
    else
        echo -e "\n${RED}✗ Erro na compilação de moonlight-embedded${NC}"
        exit 1
    fi
    
    # Rebuild de amberelec com o novo pacote
    echo -e "\n${YELLOW}3. Recompilando amberelec (com moonlight-embedded)...${NC}"
    DEVICE=$DEVICE ARCH=$ARCH ./scripts/build amberelec
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✓ amberelec compilado com sucesso!${NC}"
    else
        echo -e "\n${RED}✗ Erro na compilação de amberelec${NC}"
        exit 1
    fi
fi

echo -e "\n${GREEN}=== Build Concluído ===${NC}"
echo -e "\nPróximos passos:"
echo "1. Gere a imagem: make image DEVICE=$DEVICE"
echo "2. Ou use Docker: make docker-$DEVICE"
echo -e "\n${YELLOW}Nota:${NC} A imagem será salva em target/"
