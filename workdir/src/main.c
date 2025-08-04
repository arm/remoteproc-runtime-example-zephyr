/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <stdio.h>
#include <zephyr/devicetree.h>
#include <zephyr/kernel.h> /* or <zephyr/printk.h> */

// https://github.com/zephyrproject-rtos/zephyr/blob/main/boards/nxp/imx93_evk/imx93_evk_mimx9352_m33.dts

int main(void) {
  for (int i = 0; i < 50; i++) {
    printf("Hello World %d from the %s\n", i, CONFIG_BOARD);
    k_msleep(500); // Sleep for 500 milliseconds
  }
  return 0;
}
