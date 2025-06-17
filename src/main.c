/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <stdio.h>
#include <zephyr/kernel.h> /* or <zephyr/printk.h> */
#include <zephyr/drivers/gpio.h>
#include <zephyr/devicetree.h>

// https://github.com/zephyrproject-rtos/zephyr/blob/main/boards/nxp/imx93_evk/imx93_evk_mimx9352_m33.dts
#define LED_R_NODE DT_NODELABEL(led_r)
static const struct gpio_dt_spec led = GPIO_DT_SPEC_GET(LED_R_NODE, gpios);

int main(void)
{
  printk("Hello from the %s\n", CONFIG_BOARD);

  gpio_pin_configure_dt(&led, GPIO_OUTPUT_ACTIVE);
  while (1) {
    gpio_pin_set_dt(&led, 1);  // on
    k_sleep(K_MSEC(500));
    gpio_pin_set_dt(&led, 0);  // off
    k_sleep(K_MSEC(500));
  }

  return 0;
}
