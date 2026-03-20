# GitHub Actions Integration

Este guia explica como usar a validação STM32F411RE com Renode no GitHub Actions.

> **Última atualização**: Configuração unificada com Renode 1.16.1

## 🚀 Workflow Automatizado

O projeto inclui um workflow completo para validação automatizada no GitHub Actions:

### Arquivo: `.github/workflows/validate.yml`

O workflow executa automaticamente:

1. **Setup do Ambiente**
   - Instala Mono (requerido pelo Renode)
   - Instala ARM Toolchain
   - Baixa e instala Renode 1.13.0

2. **Build do Projeto**
   - Compila com CMake
   - Gera .elf e .bin

3. **Validação com Renode**
   - Executa `validate_renode_simple.sh`
   - Verifica todas as etapas críticas

4. **Upload de Artefatos** (em caso de falha)
   - Build artifacts
   - Logs de depuração

## 📋 Estrutura para CI/CD

### Caminhos Relativos
Todos os arquivos usam caminhos relativos para serem independentes da instalação:

```renode
# Antes (caminho absoluto)
sysbus LoadBinary @/home/user/project/build/binary.bin 0x08000000

# Agora (caminho relativo)
sysbus LoadBinary @build/GPIO_InfiniteLedToggling.bin 0x08000000
```

### Scripts Portáveis
- **`stm32f411_simple.repl`** - Configuração Renode portável
- **`validate_renode_simple.sh`** - Validação independente
- **`renode_debug.gdb`** - Script GDB com caminhos relativos

## 🔧 Uso Local vs CI

### Desenvolvimento Local
```bash
# Instalar Renode (uma vez)
./install_renode.sh

# Validar
./validate_renode_simple.sh
```

### GitHub Actions
O workflow roda automaticamente em:
- Push para `main` ou `develop`
- Pull requests para `main`
- Execução manual (workflow_dispatch)

## 📊 Saída Esperada no CI

```
🚀 Validação STM32F411RE com Renode (Simplificado)
==============================================

✅ Dependências OK

🎮 Iniciando Renode...
✅ Renode iniciado (PID: XXXX)

🔧 Executando validação...

📍 Etapa 1: Verificando main()
✅ main() alcançado

📍 Etapa 2: Verificando SystemClock_Config()
✅ SystemClock_Config() alcançado

📍 Etapa 3: Verificando Configure_GPIO()
✅ Configure_GPIO() alcançado

📍 Etapa 4: Verificando Toggle_Leds_Asynchronously()
✅ Toggle_Leds_Asynchronously() alcançado
✅ Constantes verificadas

🎉 VALIDAÇÃO CONCLUÍDA COM RENODE!
```

## 🛠️ Configuração do Workflow

### Triggers
```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:  # Execução manual
```

### Variáveis de Ambiente
O workflow usa variáveis fixas para compatibilidade:
- `RENODE_VERSION="1.16.1"`
- Porta GDB: `3333`
- Diretório build: `build/`

### Timeout e Recursos
- **Timeout**: 15 minutos (padrão GitHub Actions)
- **OS**: ubuntu-latest
- **Recursos**: 2 CPU, 7GB RAM

## 🧪 Teste Local da Configuração

Use o script de teste para validar a configuração:

```bash
./test_ci_config.sh
```

Este script verifica:
- ✅ Arquivos .repl usam caminhos relativos
- ✅ Scripts são executáveis
- ✅ Estrutura compatível com CI/CD
- ✅ Sem dependências de caminhos absolutos

## 🔍 Troubleshooting no CI

### Problemas Comuns

#### Renode não inicia
```bash
# Verificar instalação
renode --version

# Verificar Mono
mono --version
```

#### Build falha
```bash
# Verificar toolchain
arm-none-eabi-gcc --version

# Limpar e recompilar
rm -rf build
cmake -B build
cmake --build build
```

#### Validação falha
- Verificar logs no workflow
- Baixar artefatos em caso de falha
- Testar localmente com `./validate_renode_simple.sh`

### Logs e Debug

O workflow coleta automaticamente:
- **Build artifacts**: Diretório `build/`
- **Logs**: Qualquer arquivo `.log` gerado
- **Scripts**: Todos os arquivos de configuração

## 📈 Benefícios do CI com Renode

### ✅ Validação Automática
- Teste consistente em ambiente limpo
- Detecção precoce de problemas
- Histórico de validações

### ✅ Portabilidade
- Funciona em qualquer máquina
- Sem dependências de hardware real
- Reprodutibilidade garantida

### ✅ Integração
- Integrado com GitHub
- Notificações automáticas
- Artefatos disponíveis

## 🎯 Casos de Uso

### Pull Requests
- Validação automática de mudanças
- Prevenção de regressões
- Feedback rápido para desenvolvedores

### Branch Protection
- Obrigatório passar na validação
- Merge apenas com código validado
- Qualidade garantida

### Releases
- Validação final antes de release
- Confiança no código publicado
- Documentação de testes

## 🔮 Futuras Melhorias

### Possíveis Extensões
- Testes de regressão automatizados
- Validação de performance
- Integração com outros CI/CD
- Testes multi-plataforma

### Monitoramento
- Métricas de tempo de validação
- Taxa de sucesso
- Histórico de falhas

---

A configuração atual garante validação robusta e consistente do código STM32F411RE usando Renode no GitHub Actions.
