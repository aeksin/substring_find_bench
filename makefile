CC=gcc
all: clean libasm.so

libasm.so: prefix_function.o asm.o
	$(CC) -o3 -shared -o libasm.so prefix_function.o asm.o

prefix_function.o: prefix_function.c
	$(CC) -o3 -fPIC -c prefix_function.c  -o prefix_function.o
asm.o: asm_file.s
	$(CC) -fPIC -c asm_file.s -o asm.o
clean:
	rm -f *.o *.so
