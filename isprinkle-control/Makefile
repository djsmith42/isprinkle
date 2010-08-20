EXE=isprinkle-control

all: ${EXE}

clean:
	rm -v ${EXE}

${EXE}: main.c
	gcc main.c -o ${EXE} -lftdi

install: ${EXE}
	sudo install -m 755 ${EXE} /usr/bin
