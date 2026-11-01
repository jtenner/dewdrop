///|
test "hex source registry has stable module metadata and embedded bytes" {
  assert_true(standard_source_paths().contains("std/encoding/hex.dew"))
  assert_eq(standard_source_module_name("std/encoding/hex.dew"), "dew.std.encoding.hex")
  assert_eq(bootstrap_standard_source("std/encoding/hex.dew"), Some(standard_hex_source()))
}
