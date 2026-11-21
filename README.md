# Raspberry Pi 5 Firmware and Operating System repo

Just an exploration of bare metal and operating system programming for the Raspberry Pi 5.
I'm doing this to find the amount of time it takes between power-on and first I/O operation
using LEDs and a Saleae usb oscilloscope.

## How to Build

1. `make [bare_metal|free_rtos]`
2. Copy the `_build` folder contents to your SD card for the raspberry pi to boot from

Note:
I would work by initializing the SD Card with Raspberry Pi OS, and then replacing all the boot up code with my own contents of `_build` while keeping all the device trees.
I may have forgotten some device trees and overlays in my firmware folder.

## AI Disclosure
Some of this code has been written with the help of AI (specifically Claude).
While I prefer to write the code myself, and even in the worst case scenario copy it line by line from the AI,
I cannot guarantee that the code in this project is 100% human generated.

Nor can I say that it 100% works, but theoretically everything should be fine. :skull:

## Nice Links:
1. [GPIO Pinout and Config Variables](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html)
2. [config.txt documentation](https://www.raspberrypi.com/documentation/computers/config_txt.html)
