#!/bin/bash

# Script de debug para STM32F411RETx usando OpenOCD e GDB
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

echo -e "${GREEN}=== Debug Script para STM32F411RETx ===${NC}"

# Verificar se as ferramentas estão instaladas
if ! command -v openocd &> /dev/null; then
    echo -e "${RED}ERRO: openocd não encontrado!${NC}"
    exit 1
fi

if ! command -v gdb-multiarch &> /dev/null; then
    echo -e "${RED}ERRO: gdb-multiarch não encontrado!${NC}"
    exit 1
fi

# Verificar se o ELF existe
if [ ! -f "$BUILD_DIR/$PROJECT_NAME.elf" ]; then
    echo -e "${RED}ERRO: $PROJECT_NAME.elf não encontrado!${NC}"
    echo -e "${YELLOW}Execute ./build.sh primeiro${NC}"
    exit 1
fi

# Função para limpar ao sair
cleanup() {
    echo -e "${YELLOW}Encerrando sessão de debug...${NC}"
    if [ ! -z "$OPENOCD_PID" ]; then
        kill $OPENOCD_PID 2>/dev/null || true
    fi
    exit 0
}

# Configurar trap para limpeza
trap cleanup SIGINT SIGTERM

echo -e "${BLUE}Iniciando OpenOCD em background...${NC}"

# Iniciar OpenOCD em background
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg > openocd.log 2>&1 &
OPENOCD_PID=$!

# Aguardar OpenOCD inicializar
echo -e "${YELLOW}Aguardando OpenOCD inicializar...${NC}"
sleep 3

# Verificar se OpenOCD está rodando
if ! kill -0 $OPENOCD_PID 2>/dev/null; then
    echo -e "${RED}ERRO: OpenOCD falhou ao iniciar!${NC}"
    echo -e "${YELLOW}Verifique o log em openocd.log${NC}"
    cat openocd.log
    exit 1
fi

# Verificar se a porta 3333 está acessível
echo -e "${YELLOW}Verificando conexão com o target...${NC}"
if ! nc -z localhost 3333 2>/dev/null; then
    echo -e "${RED}ERRO: OpenOCD não está escutando na porta 3333!${NC}"
    cat openocd.log
    kill $OPENOCD_PID
    exit 1
fi

echo -e "${GREEN}✓ OpenOCD iniciado com sucesso!${NC}"
echo -e "${BLUE}Iniciando GDB...${NC}"
echo -e "${YELLOW}Use 'monitor reset init' para resetar o dispositivo${NC}"
echo -e "${YELLOW}Use 'continue' para executar o programa${NC}"
echo -e "${YELLOW}Use Ctrl+C para sair${NC}"

# Iniciar GDB
cd "$BUILD_DIR"
gdb-multiarch "$PROJECT_NAME.elf" -ex "target remote localhost:3333" -ex "monitor reset init"

# Limpeza
cleanup
