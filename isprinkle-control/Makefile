EXE=isprinkle-control

LIBUSB_DIRNAME=libusb-0.1.8
LIBFTDI_DIRNAME=libftdi-0.18

LIBFTDI_TARBALL=${LIBFTDI_DIRNAME}.tar.gz
LIBUSB_TARBALL=${LIBUSB_DIRNAME}.tar.gz

INCLUDES=-I${LIBFTDI_DIRNAME}/src -I${LIBUSB_DIRNAME}
LIB_DIRS=-L${LIBFTDI_DIRNAME}/src/.libs -L${LIBUSB_DIRNAME}/.libs
LIBS=-lftdi -lusb

GCC_ARGS=${INCLUDES} ${LIB_DIRS} ${LIBS}

${EXE}: src/main.c .libusb.built .libftdi.built
	gcc src/main.c -o ${EXE} ${GCC_ARGS}

.libusb.built: ${LIBUSB_TARBALL}
	rm -rf ${LIBUSB_DIRNAME}
	tar -xvzf ${LIBUSB_TARBALL}
	(cd ${LIBUSB_DIRNAME} && ./configure --enable-shared=no && make)
	touch .libusb.built

.libftdi.built: ${LIBFTDI_TARBALL} .libusb.built
	rm -rf ${LIBFTDI_DIRNAME}
	tar -xvzf ${LIBFTDI_TARBALL}
	(cd ${LIBFTDI_DIRNAME} && PATH=${PWD}/${LIBUSB_DIRNAME}:${PATH} LDFLAGS=-L${PWD}/${LIBUSB_DIRNAME}/.libs CPPFLAGS=-I${PWD}/${LIBUSB_DIRNAME} ./configure --enable-shared=no --with-async-mode && make)
	touch .libftdi.built

clean:
	rm -v ${EXE}

distclean: clean
	rm -rf ${LIBUSB_DIRNAME}
	rm -rf ${LIBFTDI_DIRNAME}

install: ${EXE}
	sudo install -m 755 ${EXE} /usr/bin
	sudo chmod u+s /usr/bin/${EXE}
