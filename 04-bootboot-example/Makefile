qemu: boot.img
	qemu-system-x86_64 -drive format=raw,file=disk.img

boot.img: boot/mykernel.x86_64.elf
	mkbootimg myos.json disk.img

boot/mykernel.x86_64.elf:
	(cd c && make)
	cp c/mykernel.x86_64.elf boot/mykernel.x86_64.elf

clean:
	cd c && make clean
	rm -f disk.img boot/mykernel.x86_64.elf
