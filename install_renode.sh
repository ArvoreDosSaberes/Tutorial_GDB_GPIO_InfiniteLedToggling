#!/bin/bash

# Script de instalação do Renode para STM32
# Instala Renode e configura dependências

echo -e "\033[0;36m🚀 Instalando Renode para depuração STM32F411RE\033[0m"
echo "================================================"
echo ""

# Verificar se já está instalado
if command -v renode &> /dev/null; then
    echo -e "\033[0;32m✅ Renode já está instalado!\033[0m"
    renode --version
    echo ""
    echo "Pronto para usar: ./validate_renode.sh"
    exit 0
fi

# Instalar dependências
echo -e "\033[1;33m🔧 Instalando dependências...\033[0m"

# Ubuntu/Debian
if command -v apt &> /dev/null; then
    echo "Detectado Ubuntu/Debian, instalando dependências..."
    sudo apt update
    sudo apt install -y wget tar mono-complete
    
# MacOS
elif command -v brew &> /dev/null; then
    echo "Detectado MacOS, instalando dependências..."
    brew install mono
    
else
    echo -e "\033[0;31m❌ Sistema não suportado automaticamente\033[0m"
    echo "Por favor, instale manualmente:"
    echo "1. Instale Mono Framework"
    echo "2. Download Renode do GitHub"
    exit 1
fi

# Baixar Renode
echo ""
echo -e "${YELLOW}📥 Baixando Renode...${NC}"

RENODE_VERSION="1.16.1"
RENODE_URL="https://github.com/renode/renode/releases/download/v${RENODE_VERSION}/renode-${RENODE_VERSION}.linux-portable.tar.gz"

wget "$RENODE_URL" -O renode.tar.gz

if [ $? -ne 0 ]; then
    echo -e "\033[0;31m❌ Erro ao baixar Renode!\033[0m"
    exit 1
fi

# Extrair
echo ""
echo -e "${YELLOW}📦 Extraindo Renode...${NC}"
tar -xzf renode.tar.gz

# Mover para /usr/local/bin
echo ""
echo -e "${YELLOW}🔧 Instalando Renode...${NC}"
# Remover instalação anterior se existir
sudo rm -f /usr/local/bin/renode
sudo cp renode_1.16.1_portable/renode /usr/local/bin/
sudo cp -r renode_1.16.1_portable/platforms /usr/local/bin/

# Limpar
echo ""
echo -e "${YELLOW}🧹 Limpando arquivos temporários...${NC}"
rm -rf renode.tar.gz renode_1.16.1_portable

# Verificar instalação
echo ""
echo -e "\033[0;36m🔍 Verificando instalação...\033[0m"

if command -v renode &> /dev/null; then
    echo -e "\033[0;32m✅ Renode instalado com sucesso!\033[0m"
    echo ""
    echo "Versão:"
    renode --version
    echo ""
    echo -e "\033[0;32m🚀 Pronto para usar!\033[0m"
    echo "Execute: ./validate_renode.sh"
else
    echo -e "\033[0;31m❌ Erro na instalação!\033[0m"
    echo "Tente instalar manualmente ou verifique o PATH"
    exit 1
fi
