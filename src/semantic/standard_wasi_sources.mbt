///|
fn standard_wasi_source() -> Bytes {
  b"builtin wasi_fd_write_import(fd: U32, iovs: U32, iovs_length: U32, written: U32) -> U32 = \"wasi_snapshot_preview1.fd_write\"\nbuiltin wasi_fd_read_import(fd: U32, iovs: U32, iovs_length: U32, read: U32) -> U32 = \"wasi_snapshot_preview1.fd_read\"\n\nbuiltin wasi_fd_write(fd: U32, value: Bytes) -> U32 = \"dew_wasi_fd_write\"\nbuiltin wasi_fd_read(fd: U32, limit: U32) -> Bytes = \"dew_wasi_fd_read\"\n"
}
