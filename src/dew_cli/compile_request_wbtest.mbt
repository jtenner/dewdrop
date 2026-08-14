///|
fn compile_request_test_write_u32(output : Buffer, value : UInt) -> Unit {
  output.write_byte((value & 0xFFU).to_byte())
  output.write_byte(((value >> 8) & 0xFFU).to_byte())
  output.write_byte(((value >> 16) & 0xFFU).to_byte())
  output.write_byte(((value >> 24) & 0xFFU).to_byte())
}

///|
fn compile_request_test_write_string(output : Buffer, value : String) -> Unit {
  let bytes = @utf8.encode(value)
  compile_request_test_write_u32(output, bytes.length().reinterpret_as_uint())
  output.write_bytes(bytes)
}

///|
fn compile_request_test_bytes(
  version? : UInt = COMPILE_REQUEST_VERSION,
) -> Bytes {
  let output = Buffer()
  compile_request_test_write_u32(output, COMPILE_REQUEST_MAGIC)
  compile_request_test_write_u32(output, version)
  compile_request_test_write_u32(output, 1U)
  compile_request_test_write_u32(output, 0U)
  compile_request_test_write_string(output, "/tmp/app.wasm")
  compile_request_test_write_string(output, "app.main")
  compile_request_test_write_u32(output, 1U)
  compile_request_test_write_string(output, "app.main")
  compile_request_test_write_u32(output, 1U)
  compile_request_test_write_string(output, "main.dew")
  compile_request_test_write_u32(output, 1U)
  compile_request_test_write_string(output, "dep.value")
  compile_request_test_write_string(output, "abc123")
  compile_request_test_write_u32(output, 0U)
  compile_request_test_write_string(output, "/workspace/dew.std")
  compile_request_test_write_u32(output, 1U)
  compile_request_test_write_u32(output, 0U)
  compile_request_test_write_u32(output, 0U)
  compile_request_test_write_u32(output, 1U)
  compile_request_test_write_u32(output, 1U)
  compile_request_test_write_u32(output, 1U)
  compile_request_test_write_u32(output, 0U)
  compile_request_test_write_string(output, "dependency-key")
  output.to_bytes()
}

///|
test "versioned compile request preserves host policy and ordered inputs" {
  let request = parse_compile_request(compile_request_test_bytes()).unwrap()
  assert_eq(request.command, 1)
  assert_eq(request.root_module, "app.main")
  assert_eq(request.modules.length(), 1)
  assert_eq(request.modules[0].files, ["main.dew"])
  assert_eq(request.dependency_interfaces[0].module_name, "dep.value")
  assert_eq(request.standard_root, "/workspace/dew.std")
  assert_false(request.parse_event_cache)
  assert_false(request.interface_cache)
  assert_true(request.body_cache)
  assert_true(request.body_family_cache)
  assert_true(request.cache_report)
  assert_eq(request.dependency_cache_key, "dependency-key")
  assert_eq(request.cli_arguments(), [
    "build", "--root", "app.main", "--std-root", "/workspace/dew.std", "--no-parse-event-cache",
    "--no-interface-cache", "--body-cache", "--body-family-cache", "--cache-report",
    "--dependency-interface", "dep.value", "abc123", "--module", "app.main", "main.dew",
    "--output", "/tmp/app.wasm",
  ])
}

///|
test "compile request rejects incompatible versions" {
  match parse_compile_request(compile_request_test_bytes(version=5U)) {
    Err(error) => assert_eq(error, "unsupported compile request version")
    Ok(_) => fail("expected incompatible compile request version")
  }
}
