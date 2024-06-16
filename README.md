# Bootloader Notes

My original intention was to write a unikernel for Golang. However, learning
about bootloaders, CPU architecture and operating systems turns out to be a
rather time-consuming endeavour. While I was reading articles and tutorials the
code present in this repository helped me understand how things work.

The *first example* is based on
[Writing a Simple Operating System - from Scratch](https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf).

The *second example* uses grub to create a bootable iso. Make sure you install
`grub-mkrescue`.

The *third example* uses no existing bootloader and is based on
[How to write your own Operating System](https://alamot.github.io/os_isr/).
Interrupts are handled that allow to process keyboard inputs and timer
ticks.

The *fourth example* uses the bootloader protocol
[bootboot](https://gitlab.com/bztsrc/bootboot) that is much more accessible than
grub. I haven't explored all details but so far it's my favourite way to create
bootable images for x86-64 (BIOS and UEFI) and ARM Raspberry Pis.

## Usage

```sh
# Open folder and run
make
```

## Interesting resources

OS in your browser via WASM

- [Emulation with WASM](https://copy.sh/v86/)

Go specific

- [Bare Metal Gophers](https://github.com/achilleasa/bare-metal-gophers) with a
  really nice [talk](https://www.youtube.com/watch?v=8T3VxGrrJwc) (but kind of
  outdated)
- [Talk about Go Runtime](https://www.youtube.com/watch?v=YpRNFNFaLGY)
- [EggOS](https://github.com/icexin/eggos) (unikernel in Go)

Intel Developer Manuals with all the x86 details

- [Intel Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

Other

- [Awesome Operating System Stuff](https://github.com/jubalh/awesome-os?tab=readme-ov-file)
- [x86-64 Bootloader with UEFI Example](https://github.com/johndoe31415/toy_x64_bootloader)
- [Pure64](https://github.com/ReturnInfinity/Pure64)
- [Tutorials OS Dev](https://wiki.osdev.org/Tutorials)
