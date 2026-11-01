///|
test "binary bootstrap registry identity and bytes" {
  let path = "std/encoding/binary.dew"
  assert_true(standard_source_paths().contains(path))
  assert_eq(standard_source_module_name(path), "dew.std.encoding.binary")
  assert_eq(bootstrap_standard_source(path), Some(standard_binary_source()))
}
