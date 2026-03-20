# Tutorial Completo de Depuração com GDB para STM32F411RETx

![visitors](https://visitor-badge.laobi.icu/badge?page_id=ArvoreDosSaberes.Tutorial_GDB_GPIO_InfiniteLedToggling.TUTORIAL)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC_BY--SA_4.0-blue.svg)](https://creativecommons.org/licenses/by-sa/4.0/)
![Language: Portuguese](https://img.shields.io/badge/Language-Portuguese-brightgreen.svg)
![STM32](https://img.shields.io/badge/STM32-F411RETx-blue)
![GDB](https://img.shields.io/badge/GDB-Debug-orange)
![Status](https://img.shields.io/badge/Status-Tutorial-brightgreen)

*Publicado em mcu.tec.br*

**Repositório**: https://github.com/ArvoreDosSaberes/Tutorial_GDB_GPIO_InfiniteLedToggling

> **Nota**: Este tutorial faz parte de um artigo completo sobre depuração com GDB para sistemas embarcados STM32. O link específico do artigo será disponibilizado em breve no site https://mcu.tec.br.

## Introdução

Este tutorial aborda em detalhes o uso do GDB (GNU Debugger) para depuração de microcontroladores STM32, especificamente o STM32F411RETx. A depuração é uma habilidade essencial para desenvolvimento de firmware embarcado, e o GDB oferece ferramentas poderosas quando combinado com OpenOCD.

O código-fonte completo e os exemplos práticos estão disponíveis no repositório GitHub, servindo como material de apoio para o aprendizado das técnicas apresentadas.

## Pré-requisitos

### Hardware
- **Placa de teste**: STM32F411RETx (Nucleo-F411RE)
- **Compatibilidade**: Qualquer placa STM32F4xx (F401, F405, F407, F410, F411, F412, F413, F429, F446, etc.)
- ST-Link V2/V3 (integrado no Nucleo ou externo)
- Cabo USB

> **Importante**: O código é compatível com qualquer placa da família STM32F4xx, mas você deve observar e ajustar os pinos dos LEDs conforme sua placa específica. O exemplo usa PA.05 (LED2) da Nucleo-F411RE.

### Software
- Toolchain ARM GCC (arm-none-eabi-gcc)
- OpenOCD
- GDB ARM (arm-none-eabi-gdb)
- CMake (opcional, para build)

### Instalação no Linux

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install gcc-arm-none-eabi gdb-arm-none-eabi openocd cmake

# Arch Linux
sudo pacman -S arm-none-eabi-gcc arm-none-eabi-gdb openocd cmake

# Verificar instalação
arm-none-eabi-gcc --version
arm-none-eabi-gdb --version
openocd --version
```

## Configuração do Projeto

### Estrutura de Arquivos

O projeto está configurado com os seguintes arquivos principais:

```
GPIO_InfiniteLedToggling/
├── CMakeLists.txt          # Configuração CMake
├── build.sh               # Script de build
├── flash.sh               # Script de gravação
├── debug.sh               # Script de debug
├── openocd.cfg            # Configuração OpenOCD
├── gdbinit                # Configuração GDB
├── Src/
│   ├── main.c             # Código principal
│   ├── stm32f4xx_it.c     # Handlers de interrupção
│   └── system_stm32f4xx.c # Configuração do sistema
├── Inc/
│   └── main.h             # Headers
└── Drivers/               # Drivers STM32
```

### Compilando o Projeto

```bash
# Compilar
./build.sh

# Verificar arquivos gerados
ls -la build/*.elf build/*.hex build/*.bin
```

## Conceitos Fundamentais do GDB

### Modos de Operação

O GDB opera em dois modos principais:

1. **Modo Local**: Debug de programas no mesmo sistema
2. **Modo Remoto**: Debug via protocolo remoto (usado com OpenOCD)

### Comandos Básicos

- `file <arquivo>`: Carrega símbolos de debug
- `target remote <host:port>`: Conecta ao servidor remoto
- `break <local>`: Define breakpoint
- `continue`: Continua execução
- `next`: Próxima linha (step over)
- `step`: Próxima linha (step into)
- `finish`: Executa até o final da função
- `info registers`: Mostra registradores
- `print <variável>`: Mostra valor de variável
- `backtrace`: Mostra pilha de chamadas

## Scripts de Automação - Explicação Detalhada

> **Importante**: Os scripts foram criados para facilitar o desenvolvimento, mas é fundamental entender cada comando individualmente. Esta seção explica detalhadamente o que cada script faz e quais comandos estão sendo executados.

### Script build.sh - Compilação do Projeto

**Objetivo**: Automatizar o processo de compilação usando CMake

```bash
#!/bin/bash
set -e  # Para em caso de erro

# Verificação de ferramentas
if ! command -v arm-none-eabi-gcc &> /dev/null; then
    echo "ERRO: arm-none-eabi-gcc não encontrado!"
    exit 1
fi

# Criação do diretório de build
BUILD_DIR="build"
rm -rf "$BUILD_DIR"  # Limpa build anterior
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configuração CMake
cmake .. -DCMAKE_BUILD_TYPE=Debug

# Compilação
make -j$(nproc)  # Usa todos os cores do CPU
```

**Comandos explicados:**
- `set -e`: Interrompe o script se qualquer comando falhar
- `command -v`: Verifica se um programa está instalado
- `rm -rf "$BUILD_DIR"`: Remove completamente o diretório de build anterior
- `mkdir -p "$BUILD_DIR"`: Cria o diretório de build
- `cmake .. -DCMAKE_BUILD_TYPE=Debug`: Configura o projeto com informações de debug
- `make -j$(nproc)`: Compila usando paralelismo (nproc = número de CPUs)

**Equivalente manual:**
```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j4  # Se tiver 4 CPUs
```

### Script flash.sh - Gravação no Dispositivo

**Objetivo**: Gravar o firmware no STM32 usando OpenOCD

```bash
#!/bin/bash
set -e

# Verificação do OpenOCD
if ! command -v openocd &> /dev/null; then
    echo "ERRO: openocd não encontrado!"
    exit 1
fi

# Verificação do arquivo ELF
if [ ! -f "build/GPIO_InfiniteLedToggling.elf" ]; then
    echo "ERRO: GPIO_InfiniteLedToggling.elf não encontrado!"
    exit 1
fi

# Comando principal do OpenOCD
openocd \
    -f interface/stlink.cfg \
    -f target/stm32f4x.cfg \
    -c "program build/GPIO_InfiniteLedToggling.elf verify reset exit"
```

**Comandos explicados:**
- `openocd`: Ferramenta de debug para microcontroladores
- `-f interface/stlink.cfg`: Especifica o adaptador de debug (ST-Link)
- `-f target/stm32f4x.cfg`: Especifica o microcontrolador alvo
- `-c "program ..."`: Executa comandos OpenOCD
  - `program build/GPIO_InfiniteLedToggling.elf`: Grava o arquivo ELF
  - `verify`: Verifica se a gravação foi bem-sucedida
  - `reset`: Reseta o microcontrolador
  - `exit`: Encerra o OpenOCD

**Equivalente manual:**
```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg \
  -c "program build/GPIO_InfiniteLedToggling.elf verify reset exit"
```

### Script debug.sh - Sessão de Debug Completa

**Objetivo**: Iniciar OpenOCD e GDB automaticamente para depuração

```bash
#!/bin/bash
set -e

# Função de limpeza
cleanup() {
    if [ ! -z "$OPENOCD_PID" ]; then
        kill $OPENOCD_PID 2>/dev/null || true
    fi
}
trap cleanup SIGINT SIGTERM  # Executa cleanup ao sair

# Iniciar OpenOCD em background
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg > openocd.log 2>&1 &
OPENOCD_PID=$!

# Aguardar inicialização
sleep 3

# Verificar conexão
if ! nc -z localhost 3333 2>/dev/null; then
    echo "ERRO: OpenOCD não está escutando na porta 3333!"
    exit 1
fi

# Iniciar GDB
cd build
arm-none-eabi-gdb GPIO_InfiniteLedToggling.elf \
    -ex "target remote localhost:3333" \
    -ex "monitor reset init"
```

**Comandos explicados:**
- `trap cleanup SIGINT SIGTERM`: Configura limpeza automática ao sair (Ctrl+C)
- `openocd ... > openocd.log 2>&1 &`: Inicia OpenOCD em background, redirecionando output para log
- `OPENOCD_PID=$!`: Salva o PID do processo OpenOCD
- `sleep 3`: Aguarda 3 segundos para OpenOCD inicializar
- `nc -z localhost 3333`: Verifica se a porta 3333 está aberta (conexão GDB)
- `arm-none-eabi-gdb ... -ex "..."`: Inicia GDB com comandos automáticos
  - `-ex "target remote localhost:3333"`: Conecta ao servidor GDB remoto
  - `-ex "monitor reset init"`: Reseta e inicializa o microcontrolador

**Equivalente manual (2 terminais):**
```bash
# Terminal 1
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg

# Terminal 2
cd build
arm-none-eabi-gdb GPIO_InfiniteLedToggling.elf
(gdb) target remote localhost:3333
(gdb) monitor reset init
```

### CMakeLists.txt - Configuração do Build

**Objetivo**: Definir como o projeto deve ser compilado

```cmake
# Configuração básica
cmake_minimum_required(VERSION 3.20)
project(GPIO_InfiniteLedToggling)

# Sistema e processador
set(CMAKE_SYSTEM_NAME Generic)  # Sistema genérico (sem OS)
set(CMAKE_SYSTEM_PROCESSOR ARM)  # Processador ARM

# Toolchain ARM
set(CROSS_COMPILE arm-none-eabi-)
set(CMAKE_C_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_ASM_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_OBJCOPY ${CROSS_COMPILE}objcopy)
```

**Comandos explicados:**
- `cmake_minimum_required(VERSION 3.20)`: Requer CMake versão 3.20 ou superior
- `project(GPIO_InfiniteLedToggling)`: Define o nome do projeto
- `set(CMAKE_SYSTEM_NAME Generic)`: Indica que é um sistema embarcado (sem OS)
- `set(CMAKE_SYSTEM_PROCESSOR ARM)`: Define a arquitetura do processador
- `set(CROSS_COMPILE arm-none-eabi-)`: Prefixo das ferramentas ARM

**Flags de compilação:**
```cmake
# Flags específicas do Cortex-M4
set(CPU_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")
set(COMMON_FLAGS "${CPU_FLAGS} -Wall -Wextra -Wno-unused-parameter")

# Flags de Debug
set(CMAKE_C_FLAGS_DEBUG "${COMMON_FLAGS} -g3 -O0 -DDEBUG")
```

**Flags explicadas:**
- `-mcpu=cortex-m4`: Especifica o processador Cortex-M4
- `-mthumb`: Usa instruction set Thumb (mais eficiente)
- `-mfpu=fpv4-sp-d16`: Habilita FPU de precisão simples
- `-mfloat-abi=hard`: Usa hardware FPU para operações de ponto flutuante
- `-Wall -Wextra`: Habilita todos os warnings
- `-g3`: Informações de debug máximas
- `-O0`: Sem otimização (melhor para debug)
- `-DDEBUG`: Define macro DEBUG

**Definições do STM32:**
```cmake
add_definitions(-DUSE_FULL_LL_DRIVER -DSTM32F411xE -DHSE_VALUE=8000000U)
```

**Definições explicadas:**
- `-DUSE_FULL_LL_DRIVER`: Usa drivers LL (Low Layer) completos
- `-DSTM32F411xE`: Define o modelo específico do STM32
- `-DHSE_VALUE=8000000U`: Define valor do cristal externo (8MHz)

**Arquivos e diretórios:**
```cmake
# Diretórios de include
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/Device/ST/STM32F4xx/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32F4xx_HAL_Driver/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/Include
)

# Arquivos fonte
set(SOURCES
    Src/main.c
    Src/stm32f4xx_it.c
    Src/system_stm32f4xx.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_ll_gpio.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_ll_utils.c
)
```

**Linker e pós-compilação:**
```cmake
# Linker script (mapa de memória)
target_link_options(${PROJECT_NAME}.elf PRIVATE
    -T${LINKER_SCRIPT}
    -Wl,-Map=${PROJECT_NAME}.map
    -Wl,--gc-sections
    --specs=nano.specs
    --specs=nosys.specs
)

# Geração de arquivos adicionais
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary ${PROJECT_NAME}.elf ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_SIZE} ${PROJECT_NAME}.elf
)
```

**Comandos explicados:**
- `-T${LINKER_SCRIPT}`: Usa o script de linker específico do STM32
- `-Wl,-Map=${PROJECT_NAME}.map`: Gera arquivo de mapa de memória
- `-Wl,--gc-sections`: Remove código não utilizado
- `--specs=nano.specs`: Usa biblioteca Newlib Nano (menor)
- `--specs=nosys.specs`: Sem syscalls (sem sistema operacional)
- `objcopy -O ihex`: Converte ELF para formato Intel HEX
- `objcopy -O binary`: Converte ELF para binário puro
- `size`: Mostra tamanho das seções do programa

**Targets customizados CMake:**
```cmake
# Target para flash
add_custom_target(flash
    COMMAND openocd -f interface/stlink.cfg -f target/stm32f4x.cfg \
            -c "program ${PROJECT_NAME}.elf verify reset exit"
    DEPENDS ${PROJECT_NAME}.elf
)

# Target para debug
add_custom_target(debug
    COMMAND openocd -f interface/stlink.cfg -f target/stm32f4x.cfg
)

# Target para GDB
add_custom_target(gdb
    COMMAND ${CROSS_COMPILE}gdb ${PROJECT_NAME}.elf \
            -ex "target remote localhost:3333" \
            -ex "monitor reset init"
    DEPENDS ${PROJECT_NAME}.elf
)
```

**Uso dos targets CMake:**
```bash
# Build manual com CMake
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)

# Usar targets customizados
make flash    # Equivalente a ./flash.sh
make debug    # Inicia OpenOCD
make gdb      # Inicia GDB com conexão automática
```

## Iniciando a Sessão de Debug

### Método 1: Script Automático (Recomendado para Iniciantes)

```bash
# Inicia OpenOCD e GDB automaticamente
./debug.sh
```

**O que acontece:**
1. Verifica se OpenOCD e GDB estão instalados
2. Inicia OpenOCD em background na porta 3333
3. Conecta GDB automaticamente ao OpenOCD
4. Reseta o microcontrolador
5. Deixa pronto para debug

### Método 2: Manual (Para Entender o Processo)

```bash
# Terminal 1: Iniciar OpenOCD
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg

# Terminal 2: Iniciar GDB
cd build
arm-none-eabi-gdb GPIO_InfiniteLedToggling.elf
(gdb) target remote localhost:3333
(gdb) monitor reset init
(gdb) load
```

**Comandos explicados:**
- `openocd -f interface/stlink.cfg -f target/stm32f4x.cfg`: Inicia servidor de debug
- `target remote localhost:3333`: Conecta GDB ao servidor OpenOCD
- `monitor reset init`: Reseta e inicializa o microcontrolador
- `load`: Grava o programa no microcontrolador

### Método 3: Usando gdbinit

```bash
cd build
arm-none-eabi-gdb -x ../gdbinit GPIO_InfiniteLedToggling.elf
```

**O que acontece:**
- `-x ../gdbinit`: Carrega comandos automáticos do arquivo gdbinit
- Útil para configurações personalizadas de debug

## Cenários de Depuração Detalhados

### Cenário 1: Debug do Startup e Clock Configuration

**Objetivo**: Entender o processo de inicialização do STM32

```gdb
# Definir breakpoints no startup
(gdb) break Reset_Handler
(gdb) break SystemClock_Config

# Reiniciar e executar
(gdb) monitor reset init
(gdb) continue

# Quando parar em SystemClock_Config:
(gdb) info registers
(gdb) print RCC->CR
(gdb) print RCC->CFGR

# Step-by-step pela configuração de clock
(gdb) next
(gdb) print RCC->CR
(gdb) next
(gdb) print RCC->PLLCFGR
```

**Análise**: Este cenário permite entender como o STM32 configura seus clocks, importante para timing e periféricos.

### Cenário 2: Debug de Configuração GPIO

**Objetivo**: Verificar configuração dos pinos PB8 e PB9

```gdb
# Breakpoint na função de configuração
(gdb) break Configure_GPIO
(gdb) continue

# Dentro da função:
(gdb) print *GPIOB
(gdb) print/x GPIOB->MODER
(gdb) print/x GPIOB->OTYPER
(gdb) print/x GPIOB->OSPEEDR
(gdb) print/x GPIOB->PUPDR

# Após cada configuração:
(gdb) next
(gdb) print/x GPIOB->MODER
```

**Análise**: Verifica se os GPIOs estão configurados corretamente como saída push-pull.

### Cenário 3: Debug do Loop Principal

**Objetivo**: Analisar o comportamento do loop infinito

```gdb
# Breakpoint no loop principal
(gdb) break Toggle_Leds_Asynchronously
(gdb) continue

# Verificar variáveis locais
(gdb) info locals
(gdb) print period_pb8_ms
(gdb) print period_pb9_ms
(gdb) print next_toggle_pb8
(gdb) print next_toggle_pb9

# Configurar watchpoint para variáveis
(gdb) watch next_toggle_pb8
(gdb) watch next_toggle_pb9

# Executar loop
(gdb) continue

# Verificar estado dos LEDs
(gdb) print/x GPIOB->ODR
(gdb) print/x GPIOB->IDR
```

**Análise**: Monitora as variáveis de tempo e o estado dos GPIOs durante a execução.

### Cenário 4: Debug de Timing e SysTick

**Objetivo**: Analisar o funcionamento do SysTick

```gdb
# Breakpoint no SysTick_Config
(gdb) break SysTick_Config
(gdb) continue

# Verificar registradores do SysTick
(gdb) print SysTick->CTRL
(gdb) print SysTick->LOAD
(gdb) print SysTick->VAL

# Monitorar o tick
(gdb) break LL_GetTick
(gdb) continue
(gdb) info registers
(gdb) print *SysTick
```

**Análise**: Entende como o sistema de tempo funciona e como o LL_GetTick retorna o tempo.

### Cenário 5: Debug de Problemas de Timing

**Objetivo**: Identificar problemas de sincronização

```gdb
# Adicionar delay artificial para simular problemas
# No código: adicionar um delay em um dos toggles

# Monitorar assimetria no timing
(gdb) break Toggle_Leds_Asynchronously
(gdb) commands
> print now = LL_GetTick()
> print next_toggle_pb8 - now
> print next_toggle_pb9 - now
> print/x GPIOB->ODR
> continue
> end

(gdb) continue
```

**Análise**: Detecta quando um LED está atrasado em relação ao outro.

### Cenário 6: Debug de Memória e Stack

**Objetivo**: Verificar uso de memória e stack

```gdb
# Verificar uso de memória
(gdb) info proc mappings
(gdb) info stack

# Monitorar stack pointer
(gdb) info registers sp
(gdb) print $sp

# Verificar se há stack overflow
(gdb) break main
(gdb) commands
> print "Stack pointer: ", $sp
> print "Stack base: ", 0x20020000
> print "Stack used: ", 0x20020000 - $sp
> continue
> end
```

**Análise**: Monitora o uso de stack para detectar possíveis overflows.

### Cenário 7: Debug de Periféricos

**Objetário**: Analisar registradores de periféricos

```gdb
# Verificar todos os clocks habilitados
(gdb) print/x RCC->AHB1ENR
(gdb) print/x RCC->APB1ENR
(gdb) print/x RCC->APB2ENR

# Verificar estado dos GPIOs
(gdb) print/x GPIOA->MODER
(gdb) print/x GPIOB->MODER
(gdb) print/x GPIOC->MODER

# Monitorar mudanças nos GPIOs
(gdb) display/x GPIOB->ODR
(gdb) display/x GPIOB->BSRR
(gdb) step
```

**Análise**: Verifica se os periféricos estão configurados e funcionando corretamente.

### Cenário 8: Debug de Interrupções

**Objetivo**: Analisar handlers de interrupção

```gdb
# Verificar vetor de interrupções
(gdb) info address Reset_Handler
(gdb) info address HardFault_Handler
(gdb) info address SysTick_Handler

# Breakpoint em handlers
(gdb) break SysTick_Handler
(gdb) break HardFault_Handler

# Forçar uma interrupção
(gdb) signal SIGINT
```

**Análise**: Entende como as interrupções são tratadas no sistema.

## Técnicas Avançadas

### Watchpoints

Monitorar variáveis automaticamente:

```gdb
# Watchpoint em variável global
(gdb) watch global_variable

# Watchpoint em endereço de memória
(gdb) watch *0x20000000

# Watchpoint condicional
(gdb) watch my_counter if my_counter > 100
```

### Breakpoints Condicionais

```gdb
# Breakpoint condicional
(gdb) break main.c:92 if now > 1000

# Breakpoint com contador
(gdb) break main.c:105
(gdb) ignore 1 10  # Ignorar as primeiras 10 vezes
```

### Macros de GDB

Criar macros para operações repetitivas:

```gdb
# Macro para mostrar estado dos LEDs
define show_leds
  print/x GPIOB->ODR
  print/x GPIOB->MODER
  print/x GPIOB->OTYPER
end

# Macro para resetar e continuar
define reset_continue
  monitor reset init
  load
  continue
end
```

### Análise de Performance

```gdb
# Medir tempo entre eventos
(gdb) python
import time
start = time.time()
gdb.execute('continue')
end

# Contar ciclos de clock
(gdb) print DWT->CYCCNT
(gdb) print DWT->CYCCNT
```

## Resolução de Problemas Comuns

### Problema: GDB não conecta

**Sintomas**: "Connection refused" ou timeout

**Solução**:
```bash
# Verificar se OpenOCD está rodando
ps aux | grep openocd

# Verificar porta
netstat -an | grep 3333

# Reiniciar OpenOCD
pkill openocd
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg
```

### Problema: Símbolos não carregados

**Sintomas**: "No symbol table is loaded"

**Solução**:
```gdb
# Carregar símbolos explicitamente
(gdb) file build/GPIO_InfiniteLedToggling.elf

# Verificar se foi compilado com debug
file build/GPIO_InfiniteLedToggling.elf
```

### Problema: Breakpoints não funcionam

**Sintomas**: Breakpoints são ignorados

**Solução**:
```gdb
# Verificar se o código foi otimizado
(gdb) info break

# Recompilar sem otimização
# Editar CMakeLists.txt: set(CMAKE_C_FLAGS_DEBUG "... -O0")
./build.sh
```

### Problema: Hard Fault

**Sintomas**: O programa entra em HardFault_Handler

**Solução**:
```gdb
# Breakpoint em HardFault_Handler
(gdb) break HardFault_Handler
(gdb) continue

# Quando parar:
(gdb) info registers
(gdb) print/x SCB->HFSR
(gdb) print/x SCB->CFSR
(gdb) print/x SCB->BFAR
(gdb) print/x SCB->MMFAR
(gdb) backtrace
```

## Dicas e Truques

### 1. Usar .gdbinit

Crie um arquivo `.gdbinit` no seu home:

```gdb
set history save on
set history size 1000
set print pretty on
set print array on
set print array-indexes on
set print static-members on
set print vtbl on
set print demangle on
set demangle-style gnu-v3
set charset ASCII
set arm force-mode thumb
```

### 2. Scripts de Debug Automatizados

```python
# Script Python para GDB
import gdb

class LedMonitor(gdb.Command):
    def __init__(self):
        super().__init__("monitor_leds", gdb.COMMAND_USER)
    
    def invoke(self, arg, from_tty):
        gpio_odr = gdb.parse_and_eval("GPIOB->ODR")
        print(f"GPIOB ODR: {hex(gpio_odr)}")
        pb8 = (gpio_odr >> 8) & 1
        pb9 = (gpio_odr >> 9) & 1
        print(f"PB8 (LED1): {'ON' if pb8 else 'OFF'}")
        print(f"PB9 (LED2): {'ON' if pb9 else 'OFF'}")

LedMonitor()
```

### 3. Debug Gráfico

Use ferramentas como:
- `gdbgui`: Interface web para GDB
- `gdb-dashboard`: Dashboard no terminal
- `VS Code` com extensão Cortex-Debug

### 4. Análise de Memória

```gdb
# Examinar memória
(gdb) x/10x 0x20000000
(gdb) x/32b 0x20000000

# Verificar seção .data
(gdb) info variables
(gdb) p &_sidata
(gdb) p &_sdata
(gdb) p &_edata
```

## Integração com IDEs

### VS Code

Instale as extensões:
- Cortex-Debug
- C/C++
- CMake Tools

Configuração `launch.json`:

```json
{
    "name": "STM32 Debug",
    "cwd": "${workspaceRoot}",
    "executable": "./build/GPIO_InfiniteLedToggling.elf",
    "request": "launch",
    "type": "cortex-debug",
    "servertype": "openocd",
    "configFiles": [
        "interface/stlink.cfg",
        "target/stm32f4x.cfg"
    ],
    "device": "STM32F411RETx",
    "svdFile": "./STM32F411.svd"
}
```

### CLion

Configurar Toolchain:
- File → Settings → Build, Execution, Deployment → Toolchains
- Adicionar "Embedded" com ARM GCC

Configurar CMake:
- Toolchain: ARM GCC
- Build Type: Debug

## Conclusão

A depuração com GDB é uma habilidade fundamental para desenvolvimento embarcado. Com as técnicas apresentadas neste tutorial, você pode:

1. **Diagnosticar problemas complexos** de timing e lógica
2. **Entender o funcionamento interno** do STM32
3. **Otimizar performance** através de análise detalhada
4. **Desenvolver firmware mais robusto** e confiável

Pratique os cenários apresentados e adapte-os às suas necessidades específicas. A depuração eficiente economiza tempo de desenvolvimento e resulta em produtos de maior qualidade.

## Referências

- [GDB Manual](https://sourceware.org/gdb/documentation/)
- [OpenOCD Documentation](http://openocd.org/)
- [STM32F411 Reference Manual](https://www.st.com/resource/en/reference_manual/dm00119316.pdf)
- [ARM Cortex-M4 Technical Reference Manual](https://developer.arm.com/documentation/100166/0001)

---

**Repositório do Projeto**: https://github.com/ArvoreDosSaberes/Tutorial_GDB_GPIO_InfiniteLedToggling

*Este tutorial foi desenvolvido para a comunidade mcu.tec.br. Contribuições e sugestões são bem-vindas através do repositório no GitHub!*
