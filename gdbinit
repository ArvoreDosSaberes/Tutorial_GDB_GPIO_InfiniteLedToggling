# Arquivo de inicialização do GDB para STM32F411RETx
# Use com: gdb-multiarch -x gdbinit GPIO_InfiniteLedToggling.elf

# Conectar ao OpenOCD
target remote localhost:3333

# Configurar monitor
monitor reset init
monitor halt

# Carregar símbolos
file GPIO_InfiniteLedToggling.elf

# Configurar decodificação de instruções ARM
set architecture arm
set disassembly-flavor intel

# Configurar pretty print
set print pretty on
set print array on
set print array-indexes on

# Configurações de depuração para Cortex-M4
set arm force-mode thumb
set mem inaccessible-by-default off

# Mostrar registradores importantes
info registers

# Definir breakpoints úteis
break main
break Toggle_Leds_Asynchronously
break SystemClock_Config

# Continuar até o main
continue
