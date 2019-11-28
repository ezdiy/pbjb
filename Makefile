Jailbreak.app: hax.c
	arm-buildroot-linux-musleabihf-gcc -s -static $< -o $@
