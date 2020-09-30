Use https://www.mobileread.com/forums/showthread.php?p=3921722 if you have an issue and can't narrow down proper cause/repro as other users on there may help you. Github is strictly for the technical side, not support.

по русски: http://4pda.ru/forum/index.php?s=&showtopic=886480&view=findpost&p=92768601

This tree uses both Pocketbook SDK for dynamic linking, as well as static musl libc cross compiler
for critical services (ssh and smb). The SDK has poor portability between firmware versions, but allows
for using ncurses or openssl (those are not suitable for static linking).

For static musl cross compiler: https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--musl--stable-2018.11-1.tar.bz2
For SDK cross compiler: https://github.com/ezdiy/pocketbook-sdk5/archive/master.tar.gz

Unpack, and point your $PATH to 'bin' folder in both SDKs (gcc are differentiated by cross prefix, cc and cc5 in makefile).

Alternatively you can use a Docker image for compiling and linking, it contains the necessary (i386) packages and the above compilers/toolchains.

Requirements: [installed Docker environment](https://docs.docker.com/get-docker) 

To prepare the Docker image, clone this repository with its submodule(s), if you haven't yet:

```console
git clone https://github.com/ezdiy/pbjb.git --recurse-submodules --shallow-submodules
```

build the image:
```console
cd pbjb
docker build -t pbjb .
```

To build pbjb, run the image (from within the same pbjb directory), this runs 'make':
```console
./rundocker.sh
```

You can also specify a command to run, e.g. to run a 'make clean':
```console
./rundocker.sh make clean
```
