.PHONY: all clean

NAME = bin/bankswitch.nes

# cl65 -t nes -Oisr -c crt0.s

CFLAGS =-t nes -Oisr --lib neslib2.lib --lib-path neslib --include-dir neslib
CC = cl65

SRC = $(wildcard *.c)
SRC += $(wildcard *.s)
SRC += $(wildcard neslib/*.s)

OBJ = $(SRC:.c=.o)
OBJ := $(OBJ:.s=.o)


all: $(NAME)

neslib/Makefile:
	git submodule update --init --recursive

neslib/neslib2.lib: neslib/Makefile
	cd neslib && sed 's/$$(CC65DIR)\/bin\///g' Makefile > Makefile.out
	$(MAKE) -C neslib -f Makefile.out neslib2.lib

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@ --listing $<.lst

%.o: %.s
	$(CC) -c $(CFLAGS) $< -o $@ --listing $<.lst --lib neslib2.lib

$(NAME): $(OBJ) nes.cfg neslib/neslib2.lib
	mkdir -p bin
	$(CC) -o $(NAME) $(CFLAGS) -C nes.cfg  $(OBJ)

$(OBJ): $(wildcard *.h *.sinc)

run: $(NAME)
	/Applications/fceux.app/Contents/MacOS/fceux $(NAME)

clean:
	rm -f $(NAME) *.o
