.PHONY: build

run: build/hello
	./build/hello

build/hello:
	mkdir -p build
	nasm -o build/hello.o -f elf64 hello.asm
	ld -o build/hello build/hello.o

clean:
	rm -rf build
