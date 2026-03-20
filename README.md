# GPIO Infinite Led Toggling - Projeto STM32F411RETx

Este projeto demonstra como configurar e usar GPIOs no STM32F411RETx para piscar LEDs, baseado no exemplo oficial STMicroelectronics com enhancements modernos. O projeto usa a LL API para otimização de performance e tamanho, e inclui suporte completo para compilação, gravação e depuração usando CMake, OpenOCD e GDB.

## Características

- **Microcontrolador**: STM32F411RETx (Cortex-M4, 100MHz)
- **GPIO**: PA.05 (LED2) configurado em output push-pull
- **Timing**: Toggle a cada 250ms (loop infinito)
- **API**: STM32F4xx LL API para otimização de performance e tamanho
- **Build System**: CMake (compatível com STM32CubeIDE)
- **Debug**: GDB + OpenOCD com scripts automatizados
- **Tutorial**: Documentação completa de depuração

## Palavras-chave

System, GPIO, Output, Alternate function, Push-pull, Toggle

## Estrutura do Projeto

```text
GPIO_InfiniteLedToggling/
├── CMakeLists.txt          # Configuração CMake
├── build.sh               # Script de build automatizado
├── flash.sh               # Script de gravação via OpenOCD
├── debug.sh               # Script de debug via GDB
├── openocd.cfg            # Configuração OpenOCD
├── gdbinit                # Configuração inicial do GDB
├── TUTORIAL.md            # Tutorial completo de debug
├── README.md              # Este arquivo
├── Src/                   # Código fonte
│   ├── main.c             # Aplicação principal
│   ├── stm32f4xx_it.c     # Handlers de interrupção
│   └── system_stm32f4xx.c # Configuração do sistema
├── Inc/                   # Headers
│   ├── main.h             # Header para main.c module
│   ├── stm32f4xx_it.h     # Header de handlers de interrupção
│   └── stm32_assert.h     # Template para assert_failed function
├── Drivers/               # Drivers STM32
│   ├── CMSIS/             # CMSIS
│   └── STM32F4xx_HAL_Driver/ # HAL/LL drivers
└── STM32CubeIDE/          # Configurações originais
    └── STM32F411RETX_FLASH.ld # Linker script
```

## Conteúdo dos Diretórios

### Headers (Inc/)
- `stm32f4xx_it.h` - Header file dos interrupt handlers
- `main.h` - Header para main.c module  
- `stm32_assert.h` - Template file para incluir assert_failed function

### Código Fonte (Src/)
- `stm32f4xx_it.c` - Interrupt handlers
- `main.c` - Main program
- `system_stm32f4xx.c` - STM32F4xx system source file

## Pré-requisitos

### Hardware
- STM32F411RETx (Nucleo-F411RE ou compatível)
- ST-Link V2/V3 (integrado ou externo)
- Cabo USB

### Software (Linux)
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

## Compilação e Uso

### 1. Compilar o Projeto
```bash
./build.sh
```

### 2. Gravar no Dispositivo
```bash
./flash.sh
```

### 3. Iniciar Sessão de Debug
```bash
./debug.sh
```

## Comandos CMake Alternativos

```bash
# Build manual
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)

# Flash via CMake target
make flash

# Debug via CMake target
make debug
```

## Descrição do Exemplo

Este exemplo descreve como configurar e usar GPIOs para toggle a cada 250ms os LEDs disponíveis na placa. Este exemplo é baseado na STM32F4xx LL API. A inicialização de periféricos é feita usando funções unitárias LL para propósito de otimização (performance e tamanho).

**PA.05 IO** (configurado em output pushpull mode) toggle em um loop infinito. Na placa NUCLEO-F411RE este IO está conectado ao LED2.

Neste exemplo, HCLK é configurado em 100 MHz.

## Ambiente de Hardware e Software

### Hardware
- Este exemplo roda em dispositivos STM32F411xE
- Este exemplo foi testado com placa NUCLEO-F411RE e pode ser facilmente adaptado para qualquer outro dispositivo e placa de desenvolvimento suportados

### Software

- Toolchain ARM GCC
- OpenOCD para gravação e debug
- GDB para depuração
- CMake para sistema de build

## Como Usar

Para fazer o programa funcionar, você deve fazer o seguinte:

1. Abrir sua toolchain preferida
2. Reconstruir todos os arquivos e carregar sua imagem na memória do target
3. Executar o exemplo

### Com Scripts Automatizados

```bash
# Compilar
./build.sh

# Gravar no dispositivo
./flash.sh

# Iniciar debug
./debug.sh
```

### Com CMake Manual

```bash
# Build manual
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)

# Flash via CMake target
make flash

# Debug via CMake target
make debug
```

## Visão Geral do Código

### Função Principal

```c
int main(void)
{
    SystemClock_Config();    // Configura clock para 100MHz
    Configure_GPIO();        // Configura PA.05 como saída
    Toggle_Leds_Asynchronously(); // Loop infinito
}
```

### Timing do LED
- **PA.05 (LED2)**: 250ms período
- **Base de tempo**: SysTick @ 1ms

### Configuração GPIO
- **Modo**: Output push-pull
- **Speed**: Low frequency  
- **Pull**: No pull-up/pull-down

## Depuração

### Sessão Rápida de Debug
```bash
# Iniciar debug automático
./debug.sh

# Ou manualmente
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg &
arm-none-eabi-gdb -x gdbinit build/GPIO_InfiniteLedToggling.elf
```

### Breakpoints Úteis
```gdb
break main
break Toggle_Leds_Asynchronously
break SystemClock_Config
break Configure_GPIO
```

### Comandos de Monitoramento
```gdb
# Monitorar LEDs
watch GPIOB->ODR
display/x GPIOB->ODR

# Monitorar tempo
info locals
print now = LL_GetTick()
```

## Cenários de Debug

O tutorial `TUTORIAL.md` cobre em detalhes:

1. **Debug do Startup**: Análise do processo de inicialização
2. **Configuração GPIO**: Verificação dos registradores GPIO
3. **Loop Principal**: Monitoramento do timing assíncrono
4. **SysTick**: Análise do sistema de tempo
5. **Problemas de Timing**: Detecção de assimetrias
6. **Memória e Stack**: Análise de uso de memória
7. **Periféricos**: Inspeção de registradores
8. **Interrupções**: Debug de handlers

## Configuração Baseada no STM32CubeIDE

Este projeto usa as mesmas configurações do STM32CubeIDE:

- **CPU**: Cortex-M4 com FPU
- **FPU**: FPv4-SP-D16 (hardware)
- **Float ABI**: Hard
- **Clock**: 100MHz via PLL (HSE 8MHz)
- **Defines**: `USE_FULL_LL_DRIVER`, `STM32F411xE`, `HSE_VALUE=8000000U`

## Personalização

### Modificar Períodos dos LEDs
Edite `main.c`, função `Toggle_Leds_Asynchronously()`:
```c
const uint32_t period_pb8_ms = 200; // Alterar aqui
const uint32_t period_pb9_ms = 350; // Alterar aqui
```

### Adicionar LEDs Extras
1. Configure os pinos desejados em `Configure_GPIO()`
2. Adicione as variáveis de timing
3. Implemente o toggle no loop principal

### Mudar Clock do Sistema
Edite `SystemClock_Config()` ou use STM32CubeMX para gerar nova configuração.

## Troubleshooting

### Problemas Comuns

**Build falha**:
```bash
# Verificar toolchain
arm-none-eabi-gcc --version

# Limpar e recompilar
rm -rf build
./build.sh
```

**Flash falha**:
```bash
# Verificar conexão ST-Link
lsusb | grep -i stlink

# Verificar permissões
sudo usermod -a -G dialout $USER
# Reboot necessário
```

**Debug não conecta**:
```bash
# Verificar OpenOCD
ps aux | grep openocd

# Tentar manualmente
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg
```

### Logs e Debug

- **OpenOCD log**: `openocd.log` (gerado pelo debug.sh)
- **Build artifacts**: Diretório `build/`
- **Map file**: `build/GPIO_InfiniteLedToggling.map`

## Integração com IDEs

### VS Code
Instale extensões:
- Cortex-Debug
- C/C++
- CMake Tools

Use a configuração `launch.json` do tutorial.

### CLion
Configure toolchain ARM GCC e use CMake integration.

### Outros
Qualquer IDE com suporte a GDB pode ser usado com os scripts fornecidos.

## Referências

- [STM32F411 Datasheet](https://www.st.com/resource/en/datasheet/stm32f411re.pdf)
- [STM32F411 Reference Manual](https://www.st.com/resource/en/reference_manual/dm00119316.pdf)
- [CMake Documentation](https://cmake.org/documentation/)
- [OpenOCD Documentation](http://openocd.org/)
- [GDB Manual](https://sourceware.org/gdb/documentation/)

## Licença

Este projeto é baseado nos exemplos STMicroelectronics e mantém a mesma licença.

## Contribuições

Contribuições são bem-vindas! Por favor:
1. Faça fork do projeto
2. Crie branch para sua feature
3. Faça commit das mudanças
4. Abra Pull Request

---

**Desenvolvido para comunidade mcu.tec.br**
