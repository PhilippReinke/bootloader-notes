CC 		:= x86_64-elf-gcc
LD 		:= x86_64-elf-ld
UNAME_O := $(shell uname -o)
ifeq ($(UNAME_O),GNU/Linux)
	CC = gcc
	LD = ld
endif

.PHONY: build

qemu: build
	@qemu-system-x86_64 -drive format=raw,file=build/os-imag

build:
	@mkdir -p build
	@nasm boot.asm -f bin -o build/boot.bin
	@nasm kernel_entry.asm -f elf64 -o build/kernel_entry.o
	@${CC} --freestanding -fno-pie -c kernel.c -o build/kernel.o
	@${LD} -o build/kernel.bin -Ttext 0x1000 --oformat binary build/kernel_entry.o build/kernel.o
	@cat build/boot.bin build/kernel.bin > build/os-imag

clean:
	@rm -rf build/
