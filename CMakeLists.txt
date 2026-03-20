cmake_minimum_required(VERSION 3.20)
project(GPIO_InfiniteLedToggling)

# Configurações específicas para STM32F411RETx
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

# Toolchain ARM (baseado no STM32CubeIDE)
set(CROSS_COMPILE arm-none-eabi-)
set(CMAKE_C_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_CXX_COMPILER ${CROSS_COMPILE}g++)
set(CMAKE_ASM_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_OBJCOPY ${CROSS_COMPILE}objcopy)
set(CMAKE_OBJDUMP ${CROSS_COMPILE}objdump)
set(CMAKE_SIZE ${CROSS_COMPILE}size)

# Flags de compilação (baseado no .cproject)
set(CPU_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")
set(COMMON_FLAGS "${CPU_FLAGS} -Wall -Wextra -Wno-unused-parameter")

# Flags de Debug
set(CMAKE_C_FLAGS_DEBUG "${COMMON_FLAGS} -g3 -O0 -DDEBUG")
set(CMAKE_ASM_FLAGS_DEBUG "${COMMON_FLAGS} -g3 -O0 -DDEBUG")

# Flags de Release
set(CMAKE_C_FLAGS_RELEASE "${COMMON_FLAGS} -Os -DNDEBUG")
set(CMAKE_ASM_FLAGS_RELEASE "${COMMON_FLAGS} -Os -DNDEBUG")

# Definições (baseado no .cproject)
add_definitions(-DUSE_FULL_LL_DRIVER -DSTM32F411xE -DHSE_VALUE=8000000U)

# Diretórios de include (baseado no .cproject)
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

# Startup file (pode variar dependendo do dispositivo específico)
set(STARTUP_FILE
    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s
)

# Linker script
set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/linker/STM32F411RETX_FLASH.ld)

# Criar executável
add_executable(${PROJECT_NAME}.elf ${SOURCES} ${STARTUP_FILE})

# Configurar linker
target_link_options(${PROJECT_NAME}.elf PRIVATE
    -T${LINKER_SCRIPT}
    -Wl,-Map=${PROJECT_NAME}.map
    -Wl,--gc-sections
    --specs=nano.specs
    --specs=nosys.specs
    -Wl,--start-group -lc -lm -Wl,--end-group
)

# Pós-compilação: gerar arquivos adicionais
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary ${PROJECT_NAME}.elf ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_SIZE} ${PROJECT_NAME}.elf
)

# Targets para flash e debug
add_custom_target(flash
    COMMAND openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "program ${PROJECT_NAME}.elf verify reset exit"
    DEPENDS ${PROJECT_NAME}.elf
    COMMENT "Flashing the device using OpenOCD"
)

add_custom_target(debug
    COMMAND openocd -f interface/stlink.cfg -f target/stm32f4x.cfg
    COMMENT "Starting OpenOCD for GDB debugging"
)

# Target para GDB
add_custom_target(gdb
    COMMAND ${CROSS_COMPILE}gdb ${PROJECT_NAME}.elf -ex "target remote localhost:3333" -ex "monitor reset init"
    DEPENDS ${PROJECT_NAME}.elf
    COMMENT "Starting GDB debugging session"
)

# Configurações de build
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY COMPILE_OPTIONS "")

# Habilitar assembly
enable_language(ASM)
