EXE=isprinkle-control
CC=gcc

# Uncomment these two lines to enable building for the Router Station Pro (MIPS AR71xx CPU)
# Also make sure mips-openwrt-linux-uclibc-gcc is in the PATH
#CC=mips-openwrt-linux-uclibc-gcc
#CROSS_COMPILE_CONFIGURE_ARGS=--host=mips-linux --target=mips-linux --build=x86_64

LIBUSB_DIRNAME=libusb-0.1.8
LIBFTDI_DIRNAME=libftdi-0.18

LIBFTDI_TARBALL=${LIBFTDI_DIRNAME}.tar.gz
LIBUSB_TARBALL=${LIBUSB_DIRNAME}.tar.gz

INCLUDES=-I${LIBFTDI_DIRNAME}/src -I${LIBUSB_DIRNAME}
LIB_DIRS=-L${LIBFTDI_DIRNAME}/src/.libs -L${LIBUSB_DIRNAME}/.libs
LIBS=-lftdi -lusb

GCC_ARGS=${INCLUDES} ${LIB_DIRS} ${LIBS}

${EXE}: src/main.c .libusb.built .libftdi.built
	${CC} -Wall -Werror src/main.c -o ${EXE} ${GCC_ARGS}

.libusb.built: ${LIBUSB_TARBALL}
	rm -rf ${LIBUSB_DIRNAME}
	tar -xvzf ${LIBUSB_TARBALL}
	(cd ${LIBUSB_DIRNAME} && ./configure CC=${CC} ${CROSS_COMPILE_CONFIGURE_ARGS} --enable-shared=no && make)
	touch .libusb.built

.libftdi.built: ${LIBFTDI_TARBALL} .libusb.built
	rm -rf ${LIBFTDI_DIRNAME}
	tar -xvzf ${LIBFTDI_TARBALL}
	(cd ${LIBFTDI_DIRNAME} && PATH=${PWD}/${LIBUSB_DIRNAME}:${PATH} \
      LDFLAGS=-L${PWD}/${LIBUSB_DIRNAME}/.libs CPPFLAGS=-I${PWD}/${LIBUSB_DIRNAME} \
      ./configure CC=${CC} ${CROSS_COMPILE_CONFIGURE_ARGS} --enable-shared=no --with-async-mode && make)
	touch .libftdi.built

clean:
	rm -v ${EXE}
	rm -v .*.built

libclean:
	rm -rf ${LIBUSB_DIRNAME}
	rm -rf ${LIBFTDI_DIRNAME}

cleanall: clean libclean

install: ${EXE}
	sudo install -m 4755 ${EXE} /usr/bin
