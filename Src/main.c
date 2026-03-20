/**
  ******************************************************************************
  * @file    Examples_LL/GPIO/GPIO_InfiniteLedToggling/Src/main.c
  * @author  MCD Application Team
  * @brief   This example describes how to configure and use GPIOs through
  *          the STM32F4xx  GPIO LL API.
  *          Peripheral initialization done using LL unitary services functions.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2017 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include "main.h"

/** @addtogroup STM32F4xx_LL_Examples
  * @{
  */

/** @addtogroup GPIO_InfiniteLedToggling
  * @{
  */

/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/

/* Private function prototypes -----------------------------------------------*/
void     SystemClock_Config(void);
void     Configure_GPIO(void);
void     Toggle_Leds_Asynchronously(void);

/* Private functions ---------------------------------------------------------*/

/**
  * @brief  Main program
  * @param  None
  * @retval None
  */
int main(void)
{
  /* Configure the system clock to 100 MHz */
  SystemClock_Config();
  
  /* Configure IO in output push-pull mode to drive external LEDs */
  Configure_GPIO();

  /* Toggle PB8 and PB9 independently */
  Toggle_Leds_Asynchronously();
}

/**
  * @brief  This function configures GPIO
  * @note   Peripheral configuration is minimal configuration from reset values.
  *         Thus, some useless LL unitary functions calls below are provided as
  *         commented examples - setting is default configuration from reset.
  * @param  None
  * @retval None
  */
void Configure_GPIO(void)
{
  /* Enable the GPIOB Clock */
  LED_GPIO_CLK_ENABLE();

  /* Configure PB8 and PB9 in output push-pull mode */
  LL_GPIO_SetPinMode(LED_GPIO_PORT, LED_PB8_PIN, LL_GPIO_MODE_OUTPUT);
  LL_GPIO_SetPinMode(LED_GPIO_PORT, LED_PB9_PIN, LL_GPIO_MODE_OUTPUT);

  LL_GPIO_SetPinOutputType(LED_GPIO_PORT, LED_PB8_PIN, LL_GPIO_OUTPUT_PUSHPULL);
  LL_GPIO_SetPinOutputType(LED_GPIO_PORT, LED_PB9_PIN, LL_GPIO_OUTPUT_PUSHPULL);

  LL_GPIO_SetPinSpeed(LED_GPIO_PORT, LED_PB8_PIN, LL_GPIO_SPEED_FREQ_LOW);
  LL_GPIO_SetPinSpeed(LED_GPIO_PORT, LED_PB9_PIN, LL_GPIO_SPEED_FREQ_LOW);

  LL_GPIO_SetPinPull(LED_GPIO_PORT, LED_PB8_PIN, LL_GPIO_PULL_NO);
  LL_GPIO_SetPinPull(LED_GPIO_PORT, LED_PB9_PIN, LL_GPIO_PULL_NO);
}

/**
  * @brief  Toggle PB8 and PB9 with independent cadences
  * @retval None
  */
void Toggle_Leds_Asynchronously(void)
{
  const uint32_t period_pb8_ms = 200U;
  const uint32_t period_pb9_ms = 350U;
  uint32_t next_toggle_pb8 = LL_GetTick() + period_pb8_ms;
  uint32_t next_toggle_pb9 = LL_GetTick() + period_pb9_ms;

  while (1)
  {
    uint32_t now = LL_GetTick();

    if ((int32_t)(now - next_toggle_pb8) >= 0)
    {
      LL_GPIO_TogglePin(LED_GPIO_PORT, LED_PB8_PIN);
      next_toggle_pb8 += period_pb8_ms;
    }

    if ((int32_t)(now - next_toggle_pb9) >= 0)
    {
      LL_GPIO_TogglePin(LED_GPIO_PORT, LED_PB9_PIN);
      next_toggle_pb9 += period_pb9_ms;
    }
  }
}

/**
  * @brief  System Clock Configuration
  *         The system Clock is configured as follow :
  *            System Clock source            = PLL (HSE)
  *            SYSCLK(Hz)                     = 100000000
  *            HCLK(Hz)                       = 100000000
  *            AHB Prescaler                  = 1
  *            APB1 Prescaler                 = 2
  *            APB2 Prescaler                 = 1
  *            HSE Frequency(Hz)              = 8000000
  *            PLL_M                          = 8
  *            PLL_N                          = 400
  *            PLL_P                          = 4
  *            VDD(V)                         = 3.3
  *            Main regulator output voltage  = Scale1 mode
  *            Flash Latency(WS)              = 3
  * @param  None
  * @retval None
  */
void SystemClock_Config(void)
{
  /* Enable HSE oscillator */
  LL_RCC_HSE_EnableBypass();
  LL_RCC_HSE_Enable();
  while(LL_RCC_HSE_IsReady() != 1)
  {
  };

  /* Set FLASH latency */
  LL_FLASH_SetLatency(LL_FLASH_LATENCY_3);

  /* Main PLL configuration and activation */
  LL_RCC_PLL_ConfigDomain_SYS(LL_RCC_PLLSOURCE_HSE, LL_RCC_PLLM_DIV_8, 400, LL_RCC_PLLP_DIV_4);
  LL_RCC_PLL_Enable();
  while(LL_RCC_PLL_IsReady() != 1)
  {
  };

  /* Sysclk activation on the main PLL */
  LL_RCC_SetAHBPrescaler(LL_RCC_SYSCLK_DIV_1);
  LL_RCC_SetSysClkSource(LL_RCC_SYS_CLKSOURCE_PLL);
  while(LL_RCC_GetSysClkSource() != LL_RCC_SYS_CLKSOURCE_STATUS_PLL)
  {
  };

  /* Set APB1 & APB2 prescaler */
  LL_RCC_SetAPB1Prescaler(LL_RCC_APB1_DIV_2);
  LL_RCC_SetAPB2Prescaler(LL_RCC_APB2_DIV_1);

  /* Set systick to 1ms */
  SysTick_Config(100000000 / 1000);

  /* Update CMSIS variable (which can be updated also through SystemCoreClockUpdate function) */
  SystemCoreClock = 100000000;
}

#ifdef  USE_FULL_ASSERT

/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d", file, line) */

  /* Infinite loop */
  while (1)
  {
  }
}
#endif

/**
  * @}
  */

/**
  * @}
  */
