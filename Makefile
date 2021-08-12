.PHONY: all clean

NAME = bin/bankswitch.nes
MAP = bin/bankswitch.map

# cl65 -t nes -Oisr -c crt0.s

CFLAGS =-t nes -Oisr -g --include-dir neslib
CC = cl65
LD = ld65

SRC = $(wildcard *.c)
SRC += $(wildcard *.s)
SRC += $(wildcard neslib/*.s)

OBJ = $(SRC:.c=.o)
OBJ := $(OBJ:.s=.o)


all: $(NAME)

neslib/Makefile:
	git submodule update --init --recursive

%.o: %.c
	$(CC) -c $(CFLAGS) -l $<.lst $< -o $@

%.o: %.s
	$(CC) -c $(CFLAGS) $< -o $@

$(NAME): $(OBJ) nes.cfg
	mkdir -p bin
	$(LD) -o $(NAME) -m $(MAP) -C nes.cfg  $(OBJ) nes.lib --dbgfile $(basename $(NAME)).dbg

$(OBJ): $(wildcard *.h *.sinc)

run: $(NAME)
	/Applications/fceux.app/Contents/MacOS/fceux $(NAME)

clean:
	rm -f $(NAME) $(MAP) *.o
