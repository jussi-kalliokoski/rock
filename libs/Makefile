
# try to determine the OS and architecture
MYOS := $(shell uname -s)
MACHINE := $(shell uname -m)
ifeq ($(MYOS), Linux)
    ARCH=linux
else ifeq ($(MYOS), FreeBSD)
    ARCH=freebsd
else ifeq ($(MYOS), Darwin)
    ARCH=osx
else ifeq ($(MYOS), CYGWIN_NT-5.1)
    ARCH=win
else ifeq ($(MYOS), MINGW32_NT-5.1)
    ARCH=win
else ifeq ($(MYOS), MINGW32_NT-6.1)
    ARCH=win
else ifeq ($(MYOS),)
  ifeq (${OS}, Windows_NT)
    ARCH=win
  else
    $(error "OS ${OS} unrecognized - please open an issue at https://github.com/nddrylliog/rock/issues")
  endif
endif
ifneq ($(ARCH), osx)
  ifeq ($(MACHINE), x86_64)
    ARCH:=${ARCH}64
  else ifeq (${PROCESSOR_ARCHITECTURE}, AMD64)
    ARCH:=${ARCH}64
  else
    ARCH:=${ARCH}32
  endif
endif
# this folder must contains libs/
ROCK_DIST?=.

# uncomment to link dynamically with the gc instead (e.g. -lgc)
GC_PATH?=${ROCK_DIST}/${ARCH}/

all:
	mkdir -p ${GC_PATH}
	cd sources && ./configure --enable-threads=posix --enable-thread-local-alloc && make # Note: see http://www.hpl.hp.com/personal/Hans_Boehm/gc/simple_example.html
	cp sources/.libs/libgc.a ${GC_PATH}