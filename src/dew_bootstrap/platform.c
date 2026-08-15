#ifdef __cplusplus
extern "C" {
#endif

#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
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

static int dewdrop_bootstrap_remove_tree_impl(const char *path) {
  struct stat status;
  if (lstat(path, &status) != 0) {
    return errno == ENOENT ? 0 : -errno;
  }
  if (!S_ISDIR(status.st_mode) || S_ISLNK(status.st_mode)) {
    return unlink(path) == 0 ? 0 : -errno;
  }
  DIR *directory = opendir(path);
  if (directory == NULL) return -errno;
  int result = 0;
  struct dirent *entry;
  while ((entry = readdir(directory)) != NULL) {
    if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) continue;
    size_t path_length = strlen(path);
    size_t name_length = strlen(entry->d_name);
    char *child = malloc(path_length + name_length + 2);
    if (child == NULL) { result = -ENOMEM; break; }
    memcpy(child, path, path_length);
    child[path_length] = '/';
    memcpy(child + path_length + 1, entry->d_name, name_length + 1);
    result = dewdrop_bootstrap_remove_tree_impl(child);
    free(child);
    if (result != 0) break;
  }
  if (closedir(directory) != 0 && result == 0) result = -errno;
  if (result != 0) return result;
  return rmdir(path) == 0 ? 0 : -errno;
}

MOONBIT_FFI_EXPORT int dewdrop_bootstrap_remove_tree(
    moonbit_bytes_t path,
    int path_length) {
  if (path_length < 0) return -EINVAL;
  char *native_path = malloc((size_t)path_length + 1);
  if (native_path == NULL) return -ENOMEM;
  memcpy(native_path, path, (size_t)path_length);
  native_path[path_length] = '\0';
  struct stat status;
  if (lstat(native_path, &status) != 0) {
    int result = errno == ENOENT ? 0 : -errno;
    free(native_path);
    return result;
  }
  int result = dewdrop_bootstrap_remove_tree_impl(native_path);
  free(native_path);
  return result == 0 ? 1 : result;
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
