/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <stdio.h>
#include <zephyr/kernel.h> /* or <zephyr/printk.h> */

int main(void) {
  printk("Hello from the %s\n", CONFIG_BOARD);
  return 0;
}
