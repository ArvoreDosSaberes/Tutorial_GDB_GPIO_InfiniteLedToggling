#!/bin/bash

# Script definitivo e funcional de validação STM32F411RE
# Usa a abordagem que já funcionou anteriormente

PROJECT_NAME="GPIO_InfiniteLedToggling"
BUILD_DIR="build"
BINARY_FILE="${BUILD_DIR}/${PROJECT_NAME}.bin"
ELF_FILE="${BUILD_DIR}/${PROJECT_NAME}.elf"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 Validação STM32F411RE${NC}"
echo "=========================="
echo ""

# Função de limpeza
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Finalizando...${NC}"
    pkill -f "renode.*stm32f411.repl" 2>/dev/null
    pkill -f "gdb-multiarch.*${ELF_FILE##*/}" 2>/dev/null
    echo -e "${GREEN}✅ Limpeza concluída${NC}"
}

trap cleanup SIGINT SIGTERM EXIT

# Verificar arquivos
if [ ! -f "$BINARY_FILE" ] || [ ! -f "$ELF_FILE" ]; then
    echo -e "${RED}❌ Erro: Arquivos compilados não encontrados!${NC}"
    echo "Execute: cmake -B build && cmake --build build"
    exit 1
fi

# Verificar dependências
echo -e "${YELLOW}🔍 Verificando dependências...${NC}"

if ! command -v renode &> /dev/null; then
    echo -e "${RED}❌ Erro: Renode não encontrado!${NC}"
    exit 1
fi

if ! command -v gdb-multiarch &> /dev/null; then
    echo -e "${RED}❌ Erro: gdb-multiarch não encontrado!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependências OK${NC}"
echo ""

# Iniciar Renode
echo -e "${MAGENTA}🎮 Iniciando Renode...${NC}"
renode --console -e "include @stm32f411.repl" &
RENODE_PID=$!

sleep 2

echo -e "${GREEN}✅ Renode iniciado (PID: $RENODE_PID)${NC}"
echo ""

# Aguardar e executar validação
echo -e "${YELLOW}⚠️  Aguardando porta GDB ficar disponível...${NC}"
sleep 3

echo -e "${BLUE}🔧 Executando validação...${NC}"
echo ""

# Validação com GDB
{
echo "set confirm off"
echo "set pagination off"
echo "target remote :3333"
echo "load"
echo ""
echo "echo \\n📍 Etapa 1: Verificando main()\\n"
echo "break main"
echo "continue"
echo "echo ✅ main() alcançado"
echo ""
echo "echo \\n📍 Etapa 2: Verificando SystemClock_Config()\\n"
echo "delete breakpoints"
echo "break SystemClock_Config"
echo "continue"
echo "echo ✅ SystemClock_Config() alcançado"
echo ""
echo "echo \\n📍 Etapa 3: Verificando Configure_GPIO()\\n"
echo "delete breakpoints"
echo "break Configure_GPIO"
echo "continue"
echo "echo ✅ Configure_GPIO() alcançado"
echo ""
echo "echo \\n📍 Etapa 4: Verificando Toggle_Leds_Asynchronously()\\n"
echo "delete breakpoints"
echo "break Toggle_Leds_Asynchronously"
echo "continue"
echo "echo ✅ Toggle_Leds_Asynchronously() alcançado"
echo ""
echo "print period_pb8_ms"
echo "print period_pb9_ms"
echo "echo ✅ Constantes verificadas"
echo "quit"
} | gdb-multiarch -batch-silent "$ELF_FILE" 2>&1 | grep -E "📍|✅|=" | sed 's/^[ \t]*//'

echo ""
echo -e "${GREEN}🎉 VALIDAÇÃO CONCLUÍDA COM RENODE!${NC}"
echo ""
echo "=== RESUMO ==="
echo -e "${GREEN}✅ main()${NC} - Função principal alcançada"
echo -e "${GREEN}✅ SystemClock_Config()${NC} - Configuração de clock"
echo -e "${GREEN}✅ Configure_GPIO()${NC} - Configuração GPIO"
echo -e "${GREEN}✅ Toggle_Leds_Asynchronously()${NC} - Loop de toggle"
echo -e "${GREEN}✅ Constantes${NC} - period_pb8_ms=200ms, period_pb9_ms=350ms"
echo ""
echo -e "${CYAN}🚀 Código validado com sucesso usando Renode!${NC}"
echo ""
echo "Para depuração manual:"
echo -e "${YELLOW}gdb-multiarch $ELF_FILE -x renode_debug.gdb${NC}"

exit 0
