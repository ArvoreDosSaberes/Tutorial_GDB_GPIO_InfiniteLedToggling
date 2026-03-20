# Depuração STM32F411RE com Renode

Este guia explica como usar Renode para depuração completa do código STM32F411RE, substituindo o QEMU com uma solução mais robusta.

## Por que Renode?

**Renode vs QEMU:**
- ✅ **Melhor suporte para microcontroladores** - Emulação mais precisa
- ✅ **Periféricos reais** - GPIO, timers, UART funcionam corretamente  
- ✅ **Interface amigável** - Scripts .repl poderosos
- ✅ **Integração GDB** - Depuração nativa
- ✅ **Multi-plataforma** - Windows, Linux, macOS

## Scripts Criados

### 1. Scripts de Instalação
- **`install_renode.sh`** - Instalação automática do Renode

### 2. Scripts de Configuração  
- **`stm32f411.repl`** - Configuração completa (experimental)
- **`stm32f411_simple.repl`** - Configuração simplificada (recomendado)

### 3. Scripts de Validação
- **`validate_renode.sh`** - Validação completa
- **`validate_renode_simple.sh`** - Validação simplificada (recomendado)

### 4. Scripts GDB
- **`renode_debug.gdb`** - Script GDB completo para Renode

## Instalação

### Instalação Automática
```bash
./install_renode.sh
```

### Instalação Manual
```bash
# 1. Instalar dependências
sudo apt install mono-complete

# 2. Baixar Renode
wget https://github.com/renode/renode/releases/latest/download/renode-1.13.0-linux-x64.tar.gz

# 3. Extrair e instalar
tar -xzf renode-1.13.0-linux-x64.tar.gz
sudo cp renode-1.13.0-linux-x64/renode /usr/local/bin/
```

## Como Usar

### Validação Rápida (Recomendado)
```bash
./validate_renode_simple.sh
```

### Validação Completa
```bash
./validate_renode.sh
```

### Depuração
- Renode 1.16.1+
- ARM GDB
- Mono Framework (para Renode)
renode --hide --console -x stm32f411_simple.repl

# Terminal 2: Conectar GDB
gdb-multiarch build/GPIO_InfiniteLedToggling.elf -x renode_debug.gdb

## Configuração Renode (.repl)

### Estrutura Básica
```renode
# Incluir plataforma STM32F4
using sysbus
using mach.st.stm32f4

# Criar instância
stm32: STM32F411 @ sysbus

# Mapear memória
sysbus:
    map 0x08000000, 0x00080000  # Flash 512KB
    map 0x20000000, 0x00020000  # RAM 128KB

# Carregar binário
sysbus LoadBinary @build/GPIO_InfiniteLedToggling.bin 0x08000000

# Configurar CPU
cpu:
    PC: 0x08000000
    GdbPort: 3333
    IsHalted: true
```

## O que a Validação Verifica

### ✅ Etapas Validadas

1. **main()** - Função principal alcançada
2. **SystemClock_Config()** - Configuração de clock para 100MHz
3. **Configure_GPIO()** - Configuração dos pins PB8 e PB9
4. **Toggle_Leds_Asynchronously()** - Loop de toggle iniciado
5. **Constantes de tempo** - period_pb8_ms=200ms, period_pb9_ms=350ms

### 📊 Saída Esperada
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

=== RESUMO ===
✅ main() - Função principal alcançada
✅ SystemClock_Config() - Configuração de clock
✅ Configure_GPIO() - Configuração GPIO
✅ Toggle_Leds_Asynchronously() - Loop de toggle
✅ Constantes - period_pb8_ms=200ms, period_pb9_ms=350ms

🚀 Código validado com sucesso usando Renode!
```

## Comandos GDB Úteis

### Durante Depuração
```gdb
# Conectar ao Renode
target remote localhost:3333

# Breakpoints
break main
break SystemClock_Config
break Configure_GPIO
break Toggle_Leds_Asynchronously

# Execução
continue
next
step

# Verificar estado
info registers
info locals
x/4x 0x40020000  # GPIOB_MODER
```

### Scripts Personalizados
```gdb
# Carregar script
source renode_debug.gdb

# Executar funções
run_complete_renode_validation
show_led_state
monitor_leds_realtime
```

## Vantagens do Renode

### 🎯 Emulação Precisa
- **GPIO real** - Pins funcionam como no hardware
- **Clock system** - Configuração de clock precisa
- **Memória** - Mapeamento correto de Flash/RAM
- **Periféricos** - UART, SPI, I2C disponíveis

### 🛠️ Ferramentas Avançadas
- **Logging** - Registro detalhado de eventos
- **Hooks** - Monitoramento de registradores
- **Virtualização** - LEDs, botões, displays virtuais
- **Python API** - Automação avançada

### 🔧 Depuração Nativa
- **GDB integration** - Depuração completa
- **Breakpoints** - Em hardware e software
- **Watchpoints** - Monitoramento de memória
- **Step execution** - Execução linha a linha

## Troubleshooting

### Problemas Comuns

#### Renode não inicia
```bash
# Verificar instalação
renode --version

# Verificar dependências
which mono
```

#### Porta GDB não disponível
```bash
# Verificar se está em uso
netstat -ln | grep 3333

# Mudar porta no script .repl
cpu:
    GdbPort: 3334
```

#### Script .repl com erro
```bash
# Testar configuração
renode --hide --console
(monitor) include stm32f411_simple.repl
```

### Dicas
- Use a versão simplificada primeiro
- Verifique se os arquivos existem
- Mantenha o Renode atualizado
- Use logging para debug

## Comparação: QEMU vs Renode

| Característica | QEMU | Renode |
|----------------|------|--------|
| **Suporte STM32** | Limitado | Completo |
| **GPIO** | Não funciona | Funciona |
| **Clock system** | Simulado | Preciso |
| **Periféricos** | Básicos | Completos |
| **Facilidade** | Média | Fácil |
| **Documentação** | Boa | Excelente |
| **Comunidade** | Grande | Ativa |

## Conclusão

Renode proporciona uma **solução superior** para depuração de microcontroladores STM32:

1. **Emulação precisa** - Hardware real funciona como esperado
2. **Integração completa** - GDB, logging, automação
3. **Facilidade de uso** - Scripts simples e poderosos
4. **Validação robusta** - Teste completo do código

A migração de QEMU para Renode resolve os problemas de bloqueio e proporciona uma experiência de depuração muito mais próxima do hardware real.
