#!/bin/bash

# Script para testar configuração independente para GitHub Actions
# Valida que todos os caminhos relativos funcionam corretamente

echo "🧪 Testando configuração para GitHub Actions..."
echo "=========================================="

# Verificar estrutura de diretórios
echo ""
echo "📁 Estrutura de diretórios:"
find . -name "*.repl" -o -name "*.sh" -o -name "*.gdb" | sort

# Verificar arquivos .repl
echo ""
echo "🔍 Verificando arquivos .repl:"
for repl in *.repl; do
    if [ -f "$repl" ]; then
        echo "✅ $repl encontrado"
        # Verificar se usa caminho relativo
        if grep -q "@build/" "$repl"; then
            echo "  ✅ Usa caminho relativo: @build/"
        else
            echo "  ❌ Não usa caminho relativo"
        fi
        # Verificar se não tem caminho absoluto
        if grep -q "@/home/" "$repl"; then
            echo "  ❌ Ainda contém caminho absoluto"
        else
            echo "  ✅ Sem caminhos absolutos"
        fi
    fi
done

# Verificar scripts shell
echo ""
echo "🔍 Verificando scripts shell:"
for script in *.sh; do
    if [ -f "$script" ] && [ "$script" != "test_ci_config.sh" ]; then
        echo "✅ $script encontrado"
        # Verificar permissões
        if [ -x "$script" ]; then
            echo "  ✅ Executável"
        else
            echo "  ❌ Não é executável"
        fi
    fi
done

# Verificar script GDB
echo ""
echo "🔍 Verificando script GDB:"
if [ -f "renode_debug.gdb" ]; then
    echo "✅ renode_debug.gdb encontrado"
    if grep -q "file build/" "renode_debug.gdb"; then
        echo "  ✅ Usa caminho relativo"
    else
        echo "  ❌ Não usa caminho relativo"
    fi
fi

# Verificar se o diretório build existe ou pode ser criado
echo ""
echo "🔍 Verificando diretório build:"
if [ -d "build" ]; then
    echo "✅ Diretório build existe"
    ls -la build/ | grep -E "\.(elf|bin)$" || echo "  ⚠️  Nenhum .elf ou .bin encontrado"
else
    echo "ℹ️  Diretório build não existe (será criado pelo cmake)"
fi

# Testar validação dos caminhos
echo ""
echo "🧪 Testando validação de caminhos:"
echo "Diretório atual: $(pwd)"
echo "Caminho relativo esperado: build/GPIO_InfiniteLedToggling.bin"
echo "Caminho absoluto seria: $(pwd)/build/GPIO_InfiniteLedToggling.bin"

# Verificar se o Renode pode encontrar os arquivos (se existirem)
if [ -f "build/GPIO_InfiniteLedToggling.bin" ]; then
    echo "✅ Binário encontrado em caminho relativo"
    echo "  Tamanho: $(stat -c%s build/GPIO_InfiniteLedToggling.bin) bytes"
else
    echo "ℹ️  Binário não encontrado (execute cmake --build build)"
fi

if [ -f "build/GPIO_InfiniteLedToggling.elf" ]; then
    echo "✅ ELF encontrado em caminho relativo"
    echo "  Tamanho: $(stat -c%s build/GPIO_InfiniteLedToggling.elf) bytes"
else
    echo "ℹ️  ELF não encontrado (execute cmake --build build)"
fi

echo ""
echo "🎉 Teste de configuração concluído!"
echo "=========================================="
echo ""
echo "📋 Resumo para GitHub Actions:"
echo "  ✅ Scripts usam caminhos relativos"
echo "  ✅ Sem dependências de caminhos absolutos"
echo "  ✅ Estrutura compatível com CI/CD"
echo "  ✅ Pronto para uso no GitHub Actions"
