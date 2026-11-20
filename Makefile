bare_metal: _build $(wildcard ./bare_metal/*)
	make -C ./bare_metal -s BUILD_DIR=../_build
	cp ./bare_metal/config.txt ./_build
	rm ./_build/kernel.elf

free_rtos: _build
	$(error Not Implemented)

_build:
	mkdir _build -p
	cp firmware/bcm2712-rpi-5-b.dtb ./_build/
	cp -r firmware/overlays ./_build/

clean:
	rm -r _build

.PHONY: clean free_rtos
