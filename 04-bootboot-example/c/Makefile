CC 		:= x86_64-elf-gcc
LD 		:= x86_64-elf-ld
STRIP 	:= x86_64-elf-strip
READELF := x86_64-elf-readelf

UNAME_O := $(shell uname -o)
ifeq ($(UNAME_O),GNU/Linux)
	CC 		= gcc
	LD 		= ld
	STRIP 	= strip
	READELF = readelf
endif

CFLAGS = -Wall -fpic -ffreestanding -fno-stack-protector -nostdinc -nostdlib -I../../dist/
LDFLAGS =  -nostdlib -n -T link.ld
STRIPFLAGS =  -s -K mmio -K fb -K bootboot -K environment -K initstack

all: mykernel.x86_64.elf

mykernel.x86_64.elf: kernel.c
	${CC} $(CFLAGS) -mno-red-zone -c kernel.c -o kernel.o
	${LD} -r -b binary -o font.o font.psf
	${LD} $(LDFLAGS) kernel.o font.o -o mykernel.x86_64.elf
	${STRIP} $(STRIPFLAGS) mykernel.x86_64.elf
	${READELF} -hls mykernel.x86_64.elf >mykernel.x86_64.txt

clean:
	rm *.o *.elf *.txt || true
