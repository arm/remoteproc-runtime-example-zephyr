#include <stdio.h>
#include <zephyr/devicetree.h>
#include <zephyr/kernel.h> /* or <zephyr/printk.h> */

int main(void) {
  for (int i = 0; i < 50; i++) {
    printf("Hello World %d from the %s\n", i, CONFIG_BOARD);
    k_msleep(500); // Sleep for 500 milliseconds
  }
  return 0;
}
