rm *.o
as print.s -o print.o -g
gcc -g -c main.c -o main.o
gcc -static main.o print.o -o print
./print