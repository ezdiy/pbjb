Use https://www.mobileread.com/forums/showthread.php?p=3921722 if you have an issue and can't narrow down proper cause/repro as other users on there may help you. Github is strictly for the technical side, not support.

по русски: http://4pda.ru/forum/index.php?s=&showtopic=886480&view=findpost&p=92768601

This tree uses both Pocketbook SDK for dynamic linking, as well as static musl libc cross comppiler
for critical services (ssh and smb). The SDK has poor portability between firmware versions, but allows
for using ncurses or openssl (those are not suitable for static linking).

For static musl cross compier: https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--musl--stable-2018.11-1.tar.bz2
For SDK cross compiler: https://github.com/ezdiy/pocketbook-sdk5/archive/master.tar.gz

Unpack, and point your $PATH to 'bin' folder in both SDKs (gcc are differentiated by cross prefix, cc and cc5 in makefile).
