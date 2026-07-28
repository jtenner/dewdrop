#ifdef __cplusplus
extern "C" {
#endif

#include <errno.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#ifdef _WIN32
#include <io.h>
#else
#include <unistd.h>
#endif

#include "moonbit.h"

MOONBIT_FFI_EXPORT int dewdrop_tokenizer_read(
    int fd,
    moonbit_bytes_t buffer,
    int offset,
    int length) {
  if (offset < 0 || length < 0) {
    return -EINVAL;
  }

  for (;;) {
#ifdef _WIN32
    int result = _read(fd, buffer + offset, (unsigned int)length);
#else
    ssize_t result = read(fd, buffer + offset, (size_t)length);
#endif
    if (result >= 0) {
      return (int)result;
    }
    if (errno != EINTR) {
      return -errno;
    }
  }
}

MOONBIT_FFI_EXPORT void dewdrop_tokenizer_move(
    moonbit_bytes_t buffer,
    int destination,
    int source,
    int length) {
  if (destination < 0 || source < 0 || length <= 0) {
    return;
  }
  memmove(buffer + destination, buffer + source, (size_t)length);
}

MOONBIT_FFI_EXPORT int dewdrop_tokenizer_page_size(void) {
#ifdef _WIN32
  return 4096;
#else
  long result = sysconf(_SC_PAGESIZE);
  if (result < 4 || result > INT32_MAX) {
    return 4096;
  }
  return (int)result;
#endif
}

MOONBIT_FFI_EXPORT int dewdrop_tokenizer_close(int fd) {
#ifdef _WIN32
  return _close(fd);
#else
  return close(fd);
#endif
}

MOONBIT_FFI_EXPORT int dewdrop_tokenizer_test_open_bytes(
    moonbit_bytes_t bytes,
    int length) {
  if (length < 0) {
    return -EINVAL;
  }

  int descriptors[2];
#ifdef _WIN32
  if (_pipe(descriptors, 4096, 0) != 0) {
    return -errno;
  }
#else
  if (pipe(descriptors) != 0) {
    return -errno;
  }
#endif

  int written = 0;
  while (written < length) {
#ifdef _WIN32
    int count = _write(
        descriptors[1],
        bytes + written,
        (unsigned int)(length - written));
#else
    ssize_t count = write(
        descriptors[1],
        bytes + written,
        (size_t)(length - written));
#endif
    if (count > 0) {
      written += (int)count;
      continue;
    }
    if (count < 0 && errno == EINTR) {
      continue;
    }
    int saved_errno = count < 0 ? errno : EIO;
#ifdef _WIN32
    _close(descriptors[0]);
    _close(descriptors[1]);
#else
    close(descriptors[0]);
    close(descriptors[1]);
#endif
    return -saved_errno;
  }

#ifdef _WIN32
  _close(descriptors[1]);
#else
  close(descriptors[1]);
#endif
  return descriptors[0];
}

#ifdef __cplusplus
}
#endif
