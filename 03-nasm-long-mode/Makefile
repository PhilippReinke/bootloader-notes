.PHONY: build

default: qemu

build/boot.bin:
	mkdir -p build
	nasm boot/boot.asm -f bin -o build/boot.bin

qemu: build/boot.bin
	qemu-system-x86_64 -drive format=raw,file=build/boot.bin

clean:
	rm -rf build
