# ----------------------------------------------------------------- #
# Declaration of targets and compiling options
CFLAGS = -Wall -g
CC = gcc
ASM= as
OBJ = main.o meuAlocador.o
EXEC=meuAlocador

# ----------------------------------------------------------------- #
# Compilation directives
all: $(EXEC)

$(EXEC): $(OBJ)
	$(CC) -static -o $(EXEC) $(OBJ)

run: all
	./$(EXEC)

main.o: main.c
	$(CC) -c main.c $(CFLAGS)

meuAlocador.o: meuAlocador.s meuAlocador.h
	$(ASM) meuAlocador.s -o meuAlocador.o -g

# ----------------------------------------------------------------- #
# Cleaning directives
clean:
	$(RM) *.o

purge: clean
	$(RM) $(EXEC)