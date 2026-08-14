#ifdef __cplusplus
extern "C" {
#endif

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#include "moonbit.h"

MOONBIT_FFI_EXPORT int dewdrop_bootstrap_system(moonbit_bytes_t command) {
  int result = system((const char *)command);
  if (result < 0) {
    return 127;
  }
  if (WIFEXITED(result)) {
    return WEXITSTATUS(result);
  }
  if (WIFSIGNALED(result)) {
    return 128 + WTERMSIG(result);
  }
  return 127;
}

MOONBIT_FFI_EXPORT int dewdrop_bootstrap_getpid(void) {
  return (int)getpid();
}

MOONBIT_FFI_EXPORT int dewdrop_bootstrap_atomic_write(
    moonbit_bytes_t path,
    int path_length,
    moonbit_bytes_t content) {
  if (path_length < 0) return -EINVAL;
  char *destination = malloc((size_t)path_length + 1);
  if (destination == NULL) return -ENOMEM;
  memcpy(destination, path, (size_t)path_length);
  destination[path_length] = '\0';
  size_t temporary_length = (size_t)path_length + 48;
  char *temporary = malloc(temporary_length);
  if (temporary == NULL) { free(destination); return -ENOMEM; }
  snprintf(temporary, temporary_length, "%s.tmp-%ld", destination, (long)getpid());
  FILE *file = fopen(temporary, "wb");
  if (file == NULL) { int saved = errno; free(temporary); free(destination); return -saved; }
  size_t length = Moonbit_array_length(content);
  if (fwrite(content, 1, length, file) != length || fflush(file) != 0 || fsync(fileno(file)) != 0) {
    int saved = errno == 0 ? EIO : errno;
    fclose(file); unlink(temporary); free(temporary); free(destination); return -saved;
  }
  if (fclose(file) != 0 || rename(temporary, destination) != 0) {
    int saved = errno;
    unlink(temporary); free(temporary); free(destination); return -saved;
  }
  free(temporary);
  free(destination);
  return 0;
}

MOONBIT_FFI_EXPORT int dewdrop_bootstrap_rename(
    moonbit_bytes_t source,
    moonbit_bytes_t destination) {
  if (rename((const char *)source, (const char *)destination) == 0) {
    return 0;
  }
  return -errno;
}

#ifdef __cplusplus
}
#endif
