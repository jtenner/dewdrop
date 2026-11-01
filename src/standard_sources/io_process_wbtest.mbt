///|
test "io_process source registry has stable module metadata and embedded bytes" {
  assert_true(standard_source_paths().contains("std/io/process.dew"))
  assert_eq(standard_source_module_name("std/io/process.dew"), "dew.std.io.process")
  assert_eq(bootstrap_standard_source("std/io/process.dew"), Some(standard_io_process_source()))
}
