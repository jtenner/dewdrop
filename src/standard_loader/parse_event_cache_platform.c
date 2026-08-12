#ifdef __cplusplus
extern "C" {
#endif

#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <io.h>
#include <process.h>
#include <windows.h>
#define DEW_GETPID _getpid
#define DEW_UNLINK _unlink
#else
#include <unistd.h>
#define DEW_GETPID getpid
#define DEW_UNLINK unlink
#endif

#include "moonbit.h"

MOONBIT_FFI_EXPORT int dewdrop_parse_event_cache_atomic_write(
    moonbit_bytes_t path,
    int path_length,
    moonbit_bytes_t content) {
  if (path_length < 0) {
    return -EINVAL;
  }
  size_t destination_length = (size_t)path_length;
  char *destination = (char *)malloc(destination_length + 1);
  if (destination == NULL) {
    return -ENOMEM;
  }
  memcpy(destination, path, destination_length);
  destination[destination_length] = '\0';

  char suffix[64];
  int suffix_length = snprintf(
      suffix,
      sizeof(suffix),
      ".tmp-%ld",
      (long)DEW_GETPID());
  if (suffix_length <= 0 || (size_t)suffix_length >= sizeof(suffix)) {
    free(destination);
    return -EINVAL;
  }
  char *temporary = (char *)malloc(
      destination_length + (size_t)suffix_length + 1);
  if (temporary == NULL) {
    free(destination);
    return -ENOMEM;
  }
  memcpy(temporary, destination, destination_length);
  memcpy(
      temporary + destination_length,
      suffix,
      (size_t)suffix_length + 1);

  FILE *file = fopen(temporary, "wb");
  if (file == NULL) {
    int saved = errno;
    free(temporary);
    free(destination);
    return -saved;
  }
  size_t content_length = Moonbit_array_length(content);
  size_t written = fwrite(content, 1, content_length, file);
  if (written != content_length) {
    int saved = errno == 0 ? EIO : errno;
    fclose(file);
    DEW_UNLINK(temporary);
    free(temporary);
    free(destination);
    return -saved;
  }
  if (fflush(file) != 0) {
    int saved = errno;
    fclose(file);
    DEW_UNLINK(temporary);
    free(temporary);
    free(destination);
    return -saved;
  }
#ifndef _WIN32
  if (fsync(fileno(file)) != 0) {
    int saved = errno;
    fclose(file);
    DEW_UNLINK(temporary);
    free(temporary);
    free(destination);
    return -saved;
  }
#endif
  if (fclose(file) != 0) {
    int saved = errno;
    DEW_UNLINK(temporary);
    free(temporary);
    free(destination);
    return -saved;
  }
#ifdef _WIN32
  if (!MoveFileExA(
          temporary,
          destination,
          MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH)) {
    int saved = (int)GetLastError();
    DEW_UNLINK(temporary);
    free(temporary);
    free(destination);
    return saved == 0 ? -EIO : -saved;
  }
#else
  if (rename(temporary, destination) != 0) {
    int saved = errno;
    DEW_UNLINK(temporary);
    free(temporary);
    free(destination);
    return -saved;
  }
#endif
  free(temporary);
  free(destination);
  return 0;
}

#ifdef __cplusplus
}
#endif
