///|
test "directory registry preserves identities and bootstrap sources" {
  assert_true(standard_source_paths().contains("std/fs/directory.dew"))
  assert_true(standard_source_paths().contains("std/fs/wasi_directory.dew"))
  assert_eq(standard_source_module_name("std/fs/directory.dew"), "dew.std.fs.directory")
  assert_eq(standard_source_module_name("std/fs/wasi_directory.dew"), "dew.std.fs.wasi_directory")
  assert_eq(bootstrap_standard_source("std/fs/directory.dew"), Some(standard_directory_source()))
  assert_eq(bootstrap_standard_source("std/fs/wasi_directory.dew"), Some(standard_wasi_directory_source()))
}
