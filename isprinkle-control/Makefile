all: isprinkle-control

isprinkle-control: main.c
	gcc main.c -o isprinkle-control -lftdi

install: isprinkle-control
	sudo install -m 755 isprinkle-control /usr/bin
