TRPL=aarch64-linux-gnu-

FLAGS=-nostdlib -nostartfiles -Wl,--build-id=none -Wl,-Ttext=0x80000 -static -no-pie

kernel_2712.img: main.S
	$(TRPL)gcc $(FLAGS) -o kernel.elf main.S
	$(TRPL)objcopy -O binary kernel.elf kernel_2712.img

clean:
	rm -f kernel.elf kernel_2712.img

.PHONY: clean
