# GPIO_InfiniteLedToggling - STM32F411RE

![visitors](https://visitor-badge.laobi.icu/badge?page_id=ArvoreDosSaberes.Tutorial_GDB_GPIO_InfiniteLedToggling)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC_BY--SA_4.0-blue.svg)](https://creativecommons.org/licenses/by-sa/4.0/)
![Language: Portuguese](https://img.shields.io/badge/Language-Portuguese-brightgreen.svg)
![STM32](https://img.shields.io/badge/STM32-F411RE-blue)
![Renode](https://img.shields.io/badge/Renode-Emulation-green)
![Status](https://img.shields.io/badge/Status-Production-brightgreen)

Projeto STM32F411RE que implementa toggle assíncrono de LEDs nos pins PB8 e PB9 usando Low-Level Library (LL) com validação completa via **Renode**.

## 🚀 Validação e Depuração com Renode

Este projeto usa **Renode** para emulação e depuração completa do STM32F411RE, substituindo o QEMU com uma solução superior.

### Scripts Disponíveis

#### Instalação
- **`install_renode.sh`** - Instalação automática do Renode

#### Configuração Renode  
- **`stm32f411_simple.repl`** - Configuração Renode funcional
- **`stm32f411.repl`** - Configuração completa (experimental)

#### Validação
- **`validate_renode_simple.sh`** ⭐ - **Validação recomendada**
- **`validate_renode.sh`** - Validação completa

#### Depuração
- **`renode_debug.gdb`** - Script GDB completo
- **`RENODE_GUIDE.md`** - Guia completo de uso

## 📋 Como Usar

### 1. Compilar o Projeto
```bash
cmake -B build
cmake --build build
```

### 2. Instalar Renode (se necessário)
```bash
./install_renode.sh
```

### 3. Validar o Código
```bash
./validate_renode_simple.sh
```

### 4. Depuração Manual (opcional)
```bash
# Terminal 1: Iniciar Renode
renode --hide --console -x stm32f411_simple.repl

# Terminal 2: Conectar GDB
gdb-multiarch build/GPIO_InfiniteLedToggling.elf -x renode_debug.gdb
```

## ✅ Validação Automatizada

O script `validate_renode_simple.sh` verifica automaticamente:

- ✅ `main()` - Função principal alcançada
- ✅ `SystemClock_Config()` - Clock configurado para 100MHz  
- ✅ `Configure_GPIO()` - PB8 e PB9 configurados como output
- ✅ `Toggle_Leds_Asynchronously()` - Loop de toggle iniciado
- ✅ **Constantes** - period_pb8_ms=200ms, period_pb9_ms=350ms

## 🎯 Descrição do Projeto

### Funcionalidade
- **LED PB8**: Toggle a cada 200ms
- **LED PB9**: Toggle a cada 350ms  
- **Clock**: 100MHz (HSE 8MHz + PLL)
- **GPIO**: Low-Level Library (LL)

### Hardware
- **Microcontrolador**: STM32F411RE (Cortex-M4)
- **Clock Externo**: 8MHz HSE
- **LEDs**: Conectados aos pins PB8 e PB9

## 📖 Documentação

Para informações detalhadas sobre Renode e depuração:
- Veja **`RENODE_GUIDE.md`** - Guia completo

## 🔧 Dependências

### Build
- CMake 3.20+
- ARM GCC Toolchain
- STM32Cube HAL/LL Drivers

### Depuração
- Renode 1.16.1+
- ARM GDB
- Mono Framework (para Renode)

## 📁 Estrutura do Projeto

```
├── Src/
│   ├── main.c                 # Aplicação principal
│   ├── stm32f4xx_it.c        # Handlers de interrupção
│   └── system_stm32f4xx.c    # Sistema
├── Inc/
│   └── main.h                 # Headers da aplicação
├── Drivers/                   # STM32 HAL/LL Drivers
├── build/                     # Binários compilados
├── *.repl                     # Scripts Renode
├── *.sh                       # Scripts de automação
└── *.gdb                      # Scripts GDB
```

## 🚀 Por que Renode?

**Renode vs QEMU:**
- ✅ **Suporte completo STM32** - GPIO, timers, periféricos reais
- ✅ **Emulação precisa** - Hardware funciona como esperado
- ✅ **Sem bloqueios** - Loop infinito não causa problemas
- ✅ **Integração GDB** - Depuração nativa completa
- ✅ **Facilidade** - Scripts simples e poderosos

## 🎉 Resultado

A solução com Renode proporciona validação completa e robusta do código STM32F411RE, muito superior à emulação com QEMU.
