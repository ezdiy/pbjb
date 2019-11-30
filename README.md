https://www.mobileread.com/forums/showthread.php?p=3921722

You need to be root for tar to pick up correct permissions (or fix Makefile to use fakeroot).
For cross compiling, grab arm-musl toolchain from https://toolchains.bootlin.com and point
your $PATH at its /bin.
