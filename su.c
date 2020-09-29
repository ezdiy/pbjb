#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {
	char *us = argv[0];
	gid_t groups[128];
	setresuid(0,0,0);
	setresgid(0,0,0);
	setgroups(getgroups(128, groups)+1, groups);
    if (argc < 2) {
        puts("usage: su [program] [args...]");
        return 0;
    }
    return execvp(argv[1], argv + 1);
}

