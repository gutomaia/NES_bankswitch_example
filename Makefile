.PHONY: all clean
PLATFORM = $(shell uname -s)

NAME = bin/bankswitch.nes

# cl65 -t nes -Oisr -c crt0.s

CFLAGS =-t nes -Oisr --include-dir neslib
CC = cc65/bin/cl65

SRC = $(wildcard *.c)
SRC += $(wildcard *.s)
SRC += $(wildcard neslib/*.s)

OBJ = $(SRC:.c=.o)
OBJ := $(OBJ:.s=.o)

ifeq ($(PLATFORM), Linux)
    SEDFLAGS = -i
endif
ifeq ($(PLATFORM),Darwin)
    SEDFLAGS = -i ''
endif

all: $(NAME)

cc65/Makefile:
	git submodule update --init --recursive

cc65/lib/nes.lib: cc65/Makefile cc65/bin/ar65 cc65/bin/cc65 cc65/bin/ld65 cc65/bin/ca65
	$(MAKE) -C cc65 nes
	cc65/bin/ar65 d $@ condes.o
	touch $@

cc65/bin/ar65: cc65/Makefile
	$(MAKE) -C cc65 ar65 && touch $@

cc65/bin/cc65: cc65/Makefile
	$(MAKE) -C cc65 cc65 && touch $@

cc65/bin/ld65: cc65/Makefile
	$(MAKE) -C cc65 ld65 && touch $@

cc65/bin/ca65: cc65/Makefile
	$(MAKE) -C cc65 ca65 && touch $@

cc65/bin/cl65: cc65/lib/nes.lib cc65/bin/ar65 cc65/bin/cc65 cc65/bin/ld65 cc65/bin/ca65
	$(MAKE) -C cc65 cl65 && touch $@

neslib/Makefile:
	git submodule update --init --recursive

neslib/neslib2.lib: neslib/Makefile cc65/bin/cl65
	cd neslib && sed 's/$$(CC65DIR)\/bin\//..\/cc65\/bin\//g' Makefile > Makefile.out
	cd neslib && sed $(SEDFLAGS) 's/initlib,//g' crt0.s
	cd neslib && sed $(SEDFLAGS) -E 's/jsr.+initlib//g' crt0.s
	$(MAKE) -C neslib -f Makefile.out neslib2.lib

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@ --listing $<.lst

%.o: %.s
	$(CC) -c $(CFLAGS) $< -o $@ --listing $<.lst

$(NAME): nes.cfg neslib/neslib2.lib cc65/bin/cl65 $(OBJ)
	mkdir -p bin
	$(CC) -o $(NAME) $(CFLAGS) -C nes.cfg  $(OBJ)

$(OBJ): $(wildcard *.h *.sinc)

run: $(NAME)
	/Applications/fceux.app/Contents/MacOS/fceux $(NAME)

clean:
	rm -f $(NAME) *.o
