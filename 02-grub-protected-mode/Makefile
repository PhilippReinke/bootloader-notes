LD 		:= x86_64-elf-ld
UNAME_O := $(shell uname -o)
ifeq ($(UNAME_O),GNU/Linux)
	LD = ld
endif

.PHONY: build

qemu: build/os.iso
	qemu-system-x86_64 -cdrom build/os.iso

build/os.iso: build/kernel.bin
	mkdir -p build/isofiles/boot/grub
	cp grub.cfg build/isofiles/boot/grub
	cp build/kernel.bin build/isofiles/boot/
	grub-mkrescue -o build/os.iso build/isofiles

build/kernel.bin: build/multiboot_header.o build/boot.o linker.ld
	${LD} -n -o build/kernel.bin -T linker.ld build/multiboot_header.o build/boot.o

build/multiboot_header.o: multiboot_header.asm
	mkdir -p build
	nasm -f elf64 multiboot_header.asm -o build/multiboot_header.o

build/boot.o: boot.asm
	mkdir -p build
	nasm -f elf64 boot.asm -o build/boot.o

clean:
	rm -rf build
