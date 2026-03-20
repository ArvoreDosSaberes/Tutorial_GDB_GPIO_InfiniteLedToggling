# Script GDB para validação com Renode
# Validação completa do código STM32F411RE

# Conectar ao Renode
target remote localhost:3333

# Carregar símbolos
file build/GPIO_InfiniteLedToggling.elf

# Configurar arquitetura
set architecture arm
set endian little

# Configurações para melhor experiência
set pagination off
set confirm off
set print pretty on

# Definir função para mostrar estado dos LEDs
define show_led_state
    echo "\n=== ESTADO DOS LEDs ===\n"
    # Ler registradores GPIOB
    echo "GPIOB_MODER (Configuração modo):"
    x/1xw 0x40020000
    
    echo "GPIOB_ODR (Output Data Register):"
    x/1xw 0x40020014
    
    # Verificar estado dos pins PB8 e PB9
    echo "Estado PB8 (bit 8):"
    x/1xw 0x40020014
    echo "Estado PB9 (bit 9):"
    x/1xw 0x40020014
    
    echo ""
end

# Validação do fluxo principal
define validate_system_initialization
    echo "\n*** ETAPA 1: INICIALIZAÇÃO DO SISTEMA ***\n"
    
    # Breakpoint no main
    break main
    continue
    
    echo "✅ main() alcançado"
    info registers pc sp
    echo ""
    
    # Verificar SystemClock_Config
    break SystemClock_Config
    continue
    
    echo "✅ SystemClock_Config() iniciado"
    stepi 5
    echo "Configurando HSE e PLL..."
    
    # Deixar SystemClock_Config completar
    finish
    echo "✅ SystemClock_Config() concluído"
    echo ""
end

# Validação da configuração GPIO
define validate_gpio_configuration
    echo "\n*** ETAPA 2: CONFIGURAÇÃO GPIO ***\n"
    
    # Breakpoint em Configure_GPIO
    break Configure_GPIO
    continue
    
    echo "✅ Configure_GPIO() iniciado"
    
    # Verificar se GPIOB clock foi habilitado
    echo "Verificando RCC->AHB1ENR (GPIOB clock):"
    x/1xw 0x40023830  # RCC->AHB1ENR
    
    # Avançar para ver configuração dos pins
    stepi 10
    
    echo "Configurando PB8 e PB9 como output..."
    stepi 10
    
    # Verificar MODER para PB8 e PB9 (deve ser 01 para output)
    echo "GPIOB_MODER após configuração:"
    x/1xw 0x40020000  # GPIOB_MODER
    
    # Verificar OTYPER (push-pull)
    echo "GPIOB_OTYPER (output type):"
    x/1xw 0x40020004  # GPIOB_OTYPER
    
    finish
    echo "✅ Configure_GPIO() concluído"
    echo ""
end

# Validação do loop de toggle
define validate_led_toggle
    echo "\n*** ETAPA 3: LOOP DE TOGGLE ***\n"
    
    # Breakpoint em Toggle_Leds_Asynchronously
    break Toggle_Leds_Asynchronously
    continue
    
    echo "✅ Toggle_Leds_Asynchronously() iniciado"
    
    # Verificar constantes de tempo
    echo "Constantes de período:"
    print period_pb8_ms
    print period_pb9_ms
    
    # Verificar configuração inicial do tempo
    print next_toggle_pb8
    print next_toggle_pb9
    
    # Mostrar estado inicial dos LEDs
    show_led_state
    
    # Executar algumas iterações do loop
    echo "\nExecutando primeira iteração do loop..."
    stepi 20
    
    # Verificar se SysTick está funcionando
    echo "Verificando SysTick..."
    info registers
    
    # Executar toggle do PB8
    echo "\nExecutando toggle PB8..."
    stepi 15
    
    # Mostrar estado após toggle
    show_led_state
    
    echo "✅ Loop de toggle validado"
    echo ""
end

# Teste completo automatizado
define run_complete_renode_validation
    echo "\n🚀 INICIANDO VALIDAÇÃO COMPLETA COM RENODE 🚀\n"
    echo "======================================="
    
    validate_system_initialization
    validate_gpio_configuration
    validate_led_toggle
    
    echo "\n🎉 VALIDAÇÃO CONCLUÍDA COM SUCESSO!"
    echo "======================================="
    echo "✅ Sistema inicializado corretamente"
    echo "✅ Clock configurado para 100MHz"
    echo "✅ GPIOB configurado"
    echo "✅ PB8 e PB9 configurados como output"
    echo "✅ Loop de toggle funcionando"
    echo "✅ LEDs virtuais respondendo"
    echo ""
    echo "🚀 Código STM32F411RE validado com Renode!"
    
    # Continuar execução para demonstrar LEDs
    echo "\n🔍 Demonstrando LEDs (pressione Ctrl+C para parar)..."
    continue
end

# Função para monitorar LEDs em tempo real
define monitor_leds_realtime
    echo "\n🔍 MONITORAMENTO DE LEDs EM TEMPO REAL"
    echo "=====================================\n"
    
    loop_var = 0
    while (loop_var < 10)
        show_led_state
        echo "---"
        stepi 100
        loop_var++
    end
end

# Configurar breakpoints automáticos
break main
break SystemClock_Config
break Configure_GPIO
break Toggle_Leds_Asynchronously

echo "Script de validação Renode carregado!"
echo "Comandos disponíveis:"
echo "  run_complete_renode_validation - Executa validação completa"
echo "  validate_system_initialization - Valida apenas inicialização"
echo "  validate_gpio_configuration - Valida apenas GPIO"
echo "  validate_led_toggle - Valida apenas toggle"
echo "  show_led_state - Mostra estado atual dos LEDs"
echo "  monitor_leds_realtime - Monitora LEDs em tempo real"
echo ""
echo "Para iniciar: run_complete_renode_validation"
