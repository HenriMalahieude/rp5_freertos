TRPL := aarch64-linux-gnu-

FLAGS := -nostdlib -nostartfiles -Wl,--build-id=none -Wl,-Ttext=0x80000 -static -no-pie
BUILD_DIR ?= .

kernel_2712.img: main.S
	$(TRPL)gcc $(FLAGS) -o $(BUILD_DIR)/kernel.elf main.S
	$(TRPL)objcopy -O binary $(BUILD_DIR)/kernel.elf $(BUILD_DIR)/kernel_2712.img

#assuming build_dir = .
clean:
	rm -f kernel.elf kernel_2712.img

.PHONY: clean
