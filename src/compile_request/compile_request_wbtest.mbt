///|
fn compile_request_test_request() -> CompilerRequest {
  {
    command: CompilerBuild,
    output_kind: CompilerWasmOutput,
    response: CompilerOutputFile("out/compiler.wasm"),
    root_module: "app.main",
    modules: [
      {
        name: "dep.value",
        files: [
          {
            logical_path: "dep/value.dew",
            source: b"pub fn value() -> I32 { 41 }\n",
          },
        ],
      },
      {
        name: "app.main",
        files: [
          {
            logical_path: "src/b.dew",
            source: b"\xff\x00arbitrary source bytes",
          },
          {
            logical_path: "src/a.dew",
            source: b"open dep.value\npub fn main() -> I32 { value() + 1 }\n",
          },
        ],
      },
    ],
    source_pool: [],
    dependency_interfaces: [
      {
        module_name: "dep.value",
        fingerprint: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      },
    ],
    static_providers: [
      { name: "starshine", wasm: b"\x00asm\xff\x00provider", },
      { name: "facet", wasm: b"\x00asm\x01\x00\x00\x00", },
    ],
    standard_library: CompilerBootstrapStandard(
      bootstrap_standard_library_identity(),
    ),
    config: {
      optimization: CompilerOptimized,
      diagnostics: CompilerTextDiagnostics,
      test_mode: false,
      default_preamble: true,
      cache_policy: CompilerCachesDisabled,
      cache_report: true,
    },
    compiler_fingerprint: b"compiler\xfffingerprint",
  }
}

///|
fn compile_request_test_mutate(
  bytes : Bytes,
  offset : Int32,
  value : Byte,
) -> Bytes {
  let output = Buffer(size_hint=bytes.length())
  for index in 0..<bytes.length() {
    output.write_byte(if index == offset { value } else { bytes[index] })
  }
  output.to_bytes()
}

///|
test "source-Bytes compiler request round trips deterministically and preserves order" {
  let request = compile_request_test_request()
  let first = request.encode().unwrap()
  let decoded = decode(first).unwrap()
  let second = decoded.encode().unwrap()
  assert_eq(first, second)
  assert_eq(decoded.modules.length(), 2)
  assert_eq(decoded.modules[0].name, "dep.value")
  assert_eq(decoded.modules[1].files[0].logical_path, "src/b.dew")
  assert_eq(
    decoded.modules[1].files[0].source,
    b"\xff\x00arbitrary source bytes",
  )
  assert_eq(decoded.static_providers[0].name, "starshine")
  assert_eq(decoded.static_providers[0].wasm, b"\x00asm\xff\x00provider")
  assert_eq(decoded.compiler_fingerprint, b"compiler\xfffingerprint")
}

///|
test "compiler request rejects unknown version tags truncation and trailing data" {
  let encoded = compile_request_test_request().encode().unwrap()
  assert_eq(
    decode(compile_request_test_mutate(encoded, 4, 0)).unwrap_err(),
    "unsupported compile request version",
  )
  assert_true(decode(compile_request_test_mutate(encoded, 8, 2)) is Err(_))
  for cut in [0, 1, 4, 8, 20, encoded.length() - 1] {
    let truncated = Buffer(size_hint=cut)
    for index in 0..<cut {
      truncated.write_byte(encoded[index])
    }
    assert_true(decode(truncated.to_bytes()) is Err(_))
  }
  let trailing = Buffer(size_hint=encoded.length() + 1)
  trailing.write_bytes(encoded)
  trailing.write_byte(0)
  assert_eq(
    decode(trailing.to_bytes()).unwrap_err(),
    "trailing bytes in compile request",
  )
}

///|
test "compiler request rejects invalid UTF-8 and oversized counts before allocation" {
  let request : CompilerRequest = {
    ..compile_request_test_request(),
    command: CompilerCheck,
    response: CompilerStatusOnly,
    output_kind: CompilerWasmOutput,
    root_module: "app.main",
    modules: [
      {
        name: "app.main",
        files: [
          { logical_path: "main.dew", source: b"pub fn main() -> I32 { 0 }\n", },
        ],
      },
    ],
    dependency_interfaces: [],
    static_providers: [],
  }
  let encoded = request.encode().unwrap()
  // The status-only header is 20 bytes. The root string starts after its u32 length.
  assert_true(decode(compile_request_test_mutate(encoded, 24, 0xff)) is Err(_))
  let oversized_modules = Buffer(size_hint=encoded.length())
  for index in 0..<encoded.length() {
    if index == 32 {
      oversized_modules.write_byte(0x01)
    } else if index == 33 {
      oversized_modules.write_byte(0x04)
    } else if index == 34 || index == 35 {
      oversized_modules.write_byte(0)
    } else {
      oversized_modules.write_byte(encoded[index])
    }
  }
  assert_true(decode(oversized_modules.to_bytes()) is Err(_))
}

///|
test "compiler request validation rejects duplicates unsafe paths and malformed fingerprints" {
  let duplicate : CompilerRequest = {
    ..compile_request_test_request(),
    modules: [
      {
        name: "app.main",
        files: [
          { logical_path: "main.dew", source: b"a", },
          { logical_path: "main.dew", source: b"b", },
        ],
      },
    ],
    root_module: "app.main",
  }
  assert_true(duplicate.encode() is Err(_))
  let unsafe_path : CompilerRequest = {
    ..compile_request_test_request(),
    modules: [
      {
        name: "app.main",
        files: [{ logical_path: "../main.dew", source: b"a", }],
      },
    ],
    root_module: "app.main",
  }
  assert_true(unsafe_path.encode() is Err(_))
  let malformed : CompilerRequest = {
    ..compile_request_test_request(),
    dependency_interfaces: [
      { module_name: "dep.value", fingerprint: "ABC123", },
    ],
  }
  assert_true(malformed.encode() is Err(_))
}

///|
test "bootstrap standard identity is exact and stable within one compiler" {
  let first = bootstrap_standard_library_identity()
  let second = bootstrap_standard_library_identity()
  assert_eq(first.length(), 32)
  assert_true(bytes_equal(first, second))
  assert_eq(first, second)
}

///|
test "compiler request source pools round trip opaque bytes and reject duplicate names" {
  let request = {
    ..compile_request_test_request(),
    source_pool: [
      {
        name: "unused.invalid",
        files: [{ logical_path: "unused.dew", source: b"\xffinvalid syntax", }],
      },
    ],
  }
  let encoded = request.encode().unwrap()
  let decoded = decode(encoded).unwrap()
  assert_eq(decoded, request)
  assert_eq(decoded.encode().unwrap(), encoded)
  let duplicate = { ..request, source_pool: [request.modules[0]], }
  assert_true(duplicate.encode() is Err(_))
  let missing_root = { ..request, modules: [request.modules[0]], }
  assert_eq(
    missing_root.encode().unwrap_err(),
    "compile request root module is not present",
  )
}

///|
test "compiler requests without an optional pool decode with an empty pool" {
  let encoded = compile_request_test_request().encode().unwrap()
  let legacy = Buffer(size_hint=encoded.length() - 4)
  for index in 0..<(encoded.length() - 4) {
    legacy.write_byte(encoded[index])
  }
  let request = decode(legacy.to_bytes()).unwrap()
  assert_eq(request.source_pool.length(), 0)
}

///|
test "request pool count uses the remaining combined module bound" {
  let request = compile_request_test_request()
  let encoded = request.encode().unwrap()
  let malformed = Buffer(size_hint=encoded.length())
  for index in 0..<(encoded.length() - 4) {
    malformed.write_byte(encoded[index])
  }
  compiler_request_write_u32(
    malformed,
    (max_module_count() - request.modules.length() + 1).reinterpret_as_uint(),
  )
  assert_eq(
    decode(malformed.to_bytes()).unwrap_err(),
    "invalid source pool module count in compile request",
  )
}

///|
test "request module reader rejects total file overflow before file data" {
  let reader : CompilerRequestReader = {
    bytes: b"\x04\x00\x00\x00test\x02\x00\x00\x00unread file data",
    offset: 0,
    error: None,
    total_files: max_total_files() - 1,
  }
  let modules = reader.read_modules(1)
  assert_eq(reader.error, Some("invalid total file count in compile request"))
  assert_eq(modules.length(), 0)
  assert_eq(reader.offset, 12)
  assert_eq(reader.total_files, max_total_files() - 1)
}

///|
test "request module reader stops before adding truncated file records" {
  let reader : CompilerRequestReader = {
    bytes: b"\x04\x00\x00\x00test\x02\x00\x00\x00",
    offset: 0,
    error: None,
    total_files: 0,
  }
  assert_eq(reader.read_modules(1).length(), 0)
  assert_eq(reader.error, Some("truncated compile request"))
  assert_eq(reader.offset, 12)
}
