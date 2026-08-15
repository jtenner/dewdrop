///|
test "Preview 1 schemas are bounded deep-marshalling trees" {
  let write = wasi_preview1_fd_write_schema()
  let read = wasi_preview1_fd_read_schema()
  assert_eq(write.module_name, "wasi_snapshot_preview1")
  assert_eq(write.field, "fd_write")
  assert_eq(read.field, "fd_read")
  assert_eq(validate_wasi_preview1_schema(write), Ok(()))
  assert_eq(validate_wasi_preview1_schema(read), Ok(()))
}

///|
test "Preview 1 schemas reject unbounded byte windows" {
  let invalid : WasiPreview1Schema = {
    module_name: "wasi_snapshot_preview1",
    field: "bad",
    parameters: [WasiPointer([WasiInputBytes(70000)])],
    maximum_depth: 2,
    maximum_nodes: 4,
  }
  assert_true(validate_wasi_preview1_schema(invalid) is Err(_))
}
