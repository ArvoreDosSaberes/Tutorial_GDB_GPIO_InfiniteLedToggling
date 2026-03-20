#!/bin/bash

# Script de flash para STM32F411RETx usando OpenOCD
# Baseado nas configurações do STM32CubeIDE

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_NAME="GPIO_InfiniteLedToggling"
BUILD_DIR="build"

echo -e "${GREEN}=== Flash Script para STM32F411RETx ===${NC}"

# Verificar se OpenOCD está instalado
if ! command -v openocd &> /dev/null; then
    echo -e "${RED}ERRO: openocd não encontrado!${NC}"
    echo -e "${YELLOW}Instale OpenOCD para usar este script${NC}"
    exit 1
fi

# Verificar se o ELF existe
if [ ! -f "$BUILD_DIR/$PROJECT_NAME.elf" ]; then
    echo -e "${RED}ERRO: $PROJECT_NAME.elf não encontrado!${NC}"
    echo -e "${YELLOW}Execute ./build.sh primeiro${NC}"
    exit 1
fi

echo -e "${BLUE}Conectando ao dispositivo e gravando...${NC}"

# Usar OpenOCD para gravar
openocd \
    -f interface/stlink.cfg \
    -f target/stm32f4x.cfg \
    -c "program $BUILD_DIR/$PROJECT_NAME.elf verify reset exit" \
    2>&1 | while read line; do
        if echo "$line" | grep -q "Error\|Failed"; then
            echo -e "${RED}$line${NC}"
        elif echo "$line" | grep -q "Info\|Verified\|Wrote"; then
            echo -e "${GREEN}$line${NC}"
        else
            echo "$line"
        fi
    done

# Verificar resultado
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✓ Flash concluído com sucesso!${NC}"
    echo -e "${BLUE}O dispositivo está executando o programa${NC}"
else
    echo -e "${RED}✗ Falha no flash!${NC}"
    echo -e "${YELLOW}Verifique a conexão do ST-Link e se o dispositivo está acessível${NC}"
    exit 1
fi
