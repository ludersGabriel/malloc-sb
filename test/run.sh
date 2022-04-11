as print.s -o print.o
gcc -g -c main.c -o main.o
gcc -static main.o print.o -o print
./print