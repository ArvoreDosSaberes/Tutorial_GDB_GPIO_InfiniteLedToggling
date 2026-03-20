#!/bin/bash

# Script de build para projeto STM32F411RETx
# Baseado no CMake e ferramentas do STM32CubeIDE

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Build Script para STM32F411RETx ===${NC}"

# Verificar se as ferramentas ARM estão disponíveis
if ! command -v arm-none-eabi-gcc &> /dev/null; then
    echo -e "${RED}ERRO: arm-none-eabi-gcc não encontrado!${NC}"
    echo -e "${YELLOW}Instale o toolchain ARM ou verifique o PATH${NC}"
    exit 1
fi

# Verificar OpenOCD
if ! command -v openocd &> /dev/null; then
    echo -e "${YELLOW}AVISO: openocd não encontrado! Flash e debug não funcionarão${NC}"
fi

# Criar diretório de build
BUILD_DIR="build"
if [ -d "$BUILD_DIR" ]; then
    echo -e "${YELLOW}Limpando diretório de build...${NC}"
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configurar CMake
echo -e "${GREEN}Configurando CMake...${NC}"
cmake .. -DCMAKE_BUILD_TYPE=Debug

# Compilar
echo -e "${GREEN}Compilando projeto...${NC}"
make -j$(nproc)

# Verificar se o ELF foi gerado
if [ -f "GPIO_InfiniteLedToggling.elf" ]; then
    echo -e "${GREEN}✓ Build concluído com sucesso!${NC}"
    
    # Mostrar informações do binário
    echo -e "${GREEN}=== Informações do binário ===${NC}"
    arm-none-eabi-size GPIO_InfiniteLedToggling.elf
    
    echo -e "${GREEN}=== Arquivos gerados ===${NC}"
    ls -la *.elf *.hex *.bin 2>/dev/null || echo "Apenas ELF disponível"
    
else
    echo -e "${RED}✗ Falha no build!${NC}"
    exit 1
fi

echo -e "${GREEN}=== Build finalizado ===${NC}"
