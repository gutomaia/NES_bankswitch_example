.PHONY: all clean

NAME = bin/bankswitch.nes

# cl65 -t nes -Oisr -c crt0.s

CFLAGS =-t nes -Oisr --include-dir neslib
CC = cl65

SRC = $(wildcard *.c)
SRC += $(wildcard *.s)
SRC += $(wildcard neslib/*.s)

OBJ = $(SRC:.c=.o)
OBJ := $(OBJ:.s=.o)


all: $(NAME)

neslib/Makefile:
	git submodule update --init --recursive

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@ --listing $<.lst

%.o: %.s
	$(CC) -c $(CFLAGS) $< -o $@ --listing $<.lst

$(NAME): $(OBJ) nes.cfg
	mkdir -p bin
	$(CC) -o $(NAME) $(CFLAGS) -C nes.cfg  $(OBJ)

$(OBJ): $(wildcard *.h *.sinc)

run: $(NAME)
	/Applications/fceux.app/Contents/MacOS/fceux $(NAME)

clean:
	rm -f $(NAME) *.o
