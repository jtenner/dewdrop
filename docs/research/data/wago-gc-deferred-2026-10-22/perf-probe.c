#include <linux/perf_event.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
int main(void) {
 struct perf_event_attr attr;
 memset(&attr,0,sizeof(attr));
 attr.type=PERF_TYPE_HARDWARE;attr.size=sizeof(attr);attr.config=PERF_COUNT_HW_CPU_CYCLES;
 attr.disabled=1;attr.inherit=1;attr.exclude_kernel=1;attr.exclude_hv=1;
 int fd=syscall(SYS_perf_event_open,&attr,0,-1,-1,0);
 if(fd<0){int e=errno;fprintf(stderr,"perf_event_open: errno=%d (%s)\n",e,strerror(e));return 1;}
 close(fd);puts("perf_event_open available");return 0;
}
