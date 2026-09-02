///|
struct BootstrapBuildCachePlan {
  enabled : Bool
  arguments : Array[String]
  output : String
  emit : String
  report : Bool
  key : String
  artifact : String
}

///|
fn bootstrap_ensure_directory(path : String) -> Unit {
  if path == "" || path == "." || path == "/" {
    return
  }
  if @fs.path_exists(path) {
    if !(@fs.is_dir(path) catch { _ => false }) {
      bootstrap_fail("cache path is not a directory: \{path}")
    }
    return
  }
  bootstrap_ensure_directory(bootstrap_dirname(path))
  @fs.create_dir(path) catch {
    error =>
      bootstrap_fail(
        "cannot create directory \{path}: \{bootstrap_fs_error_message(error)}",
      )
  }
}

///|
fn bootstrap_cache_root(repository : String) -> String {
  match @sys.get_env_var("DEW_CACHE_DIR") {
    Some(value) =>
      if bootstrap_is_absolute(value) {
        bootstrap_normalize_path(value)
      } else {
        bootstrap_normalize_path(bootstrap_join(repository, value))
      }
    None => bootstrap_join(repository, ".dew/cache")
  }
}

///|
fn bootstrap_write_u64(output : Buffer, value : UInt64) -> Unit {
  for shift in [0, 8, 16, 24, 32, 40, 48, 56] {
    output.write_byte(((value >> shift) & 0xffUL).to_byte())
  }
}

///|
fn bootstrap_read_u64(bytes : Bytes, offset : Int) -> UInt64 {
  let mut value = 0UL
  for index in 0..<8 {
    value = value | (bytes[offset + index].to_uint64() << (index * 8))
  }
  value
}

///|
fn bootstrap_build_cache_plan(
  repository : String,
  arguments : Array[String],
  compiler_fingerprint : String,
) -> BootstrapBuildCachePlan {
  let normalized : Array[String] = []
  let key_arguments : Array[String] = []
  let sources : Array[String] = []
  let mut enabled = true
  let mut output = ""
  let mut emit = "wasm"
  let mut report = false
  let mut index = 0
  while index < arguments.length() {
    let argument = arguments[index]
    if argument == "--no-build-cache" {
      enabled = false
      index += 1
    } else if argument == "-o" || argument == "--output" {
      if index + 1 >= arguments.length() {
        bootstrap_fail("missing output path")
      }
      output = arguments[index + 1]
      normalized.push(argument)
      normalized.push(output)
      index += 2
    } else if argument == "--cache-report" {
      report = true
      normalized.push(argument)
      index += 1
    } else if argument == "--emit" {
      if index + 1 >= arguments.length() {
        bootstrap_fail("missing value for --emit")
      }
      emit = arguments[index + 1]
      normalized.push(argument)
      normalized.push(emit)
      key_arguments.push(argument)
      key_arguments.push(emit)
      index += 2
    } else {
      normalized.push(argument)
      key_arguments.push(argument)
      if argument.has_suffix(".dew") {
        sources.push(argument)
      }
      index += 1
    }
  }
  let hash = @crypto.SHA256::new()
  hash.update(b"DEW_BUILD_OUTPUT_KEY_MOONBIT_V1\x00")
  for argument in key_arguments {
    bootstrap_write_hash_string(hash, argument)
  }
  for
    name in [
      "DEW_DEPENDENCY_INTERFACE_KEY", "DEW_BOOTSTRAP_STD", "DEW_STD_ROOT",
    ] {
    bootstrap_write_hash_string(hash, name)
    bootstrap_write_hash_string(hash, @sys.get_env_var(name).unwrap_or(""))
  }
  for source in sources {
    let bytes = @fs.read_file_to_bytes(source) catch {
      error => {
        bootstrap_fail(
          "cannot read build-cache source \{source}: \{bootstrap_fs_error_message(error)}",
        )
        b""
      }
    }
    bootstrap_write_hash_string(hash, source)
    bootstrap_hash_u32(hash, bytes.length())
    hash.update(bytes)
  }
  bootstrap_write_hash_string(hash, compiler_fingerprint)
  let key = @crypto.bytes_to_hex_string(hash.finalize())
  let root = bootstrap_join(bootstrap_cache_root(repository), "builds")
  {
    enabled,
    arguments: normalized,
    output,
    emit,
    report,
    key,
    artifact: bootstrap_join(root, "v1-" + key + ".dba"),
  }
}

///|
fn bootstrap_build_emit_tag(emit : String) -> Byte {
  match emit {
    "wasm" => 0
    "hir" => 1
    "lowering" => 2
    _ => {
      bootstrap_fail("unsupported build cache emit kind: \{emit}")
      0
    }
  }
}

///|
fn bootstrap_build_cache_encode(
  plan : BootstrapBuildCachePlan,
  payload : Bytes,
) -> Bytes {
  let output = Buffer(size_hint=145 + payload.length())
  output.write_bytes(b"DEWBLD3\x00")
  output.write_byte(bootstrap_build_emit_tag(plan.emit))
  output.write_string_utf8(plan.key)
  for byte in @crypto.sha256(payload) {
    output.write_byte(byte)
  }
  bootstrap_write_u64(output, payload.length().to_uint64())
  output.write_bytes(payload)
  output.to_bytes()
}

///|
fn bootstrap_build_cache_decode(plan : BootstrapBuildCachePlan) -> Bytes? {
  if !@fs.path_exists(plan.artifact) {
    return None
  }
  let encoded = @fs.read_file_to_bytes(plan.artifact) catch {
    error => {
      bootstrap_fail(
        "cannot read build cache artifact \{plan.artifact}: \{bootstrap_fs_error_message(error)}",
      )
      b""
    }
  }
  let header = 8 + 1 + 64 + 32 + 8
  if encoded.length() < header || encoded[0:8] != b"DEWBLD3\x00" {
    bootstrap_fail("corrupt build cache artifact: \{plan.artifact}")
  }
  let key = @utf8.decode(encoded[9:73]) catch { _ => "" }
  let length = bootstrap_read_u64(encoded, 105)
  if encoded[8] != bootstrap_build_emit_tag(plan.emit) ||
    key != plan.key ||
    length > 0x10000000UL ||
    length.to_int() != encoded.length() - header {
    bootstrap_fail("corrupt build cache artifact: \{plan.artifact}")
  }
  let payload = encoded[header:].to_owned()
  let digest = @crypto.sha256(payload)
  for index in 0..<32 {
    if encoded[73 + index] != digest[index] {
      bootstrap_fail("corrupt build cache artifact: \{plan.artifact}")
    }
  }
  Some(payload)
}

///|
fn bootstrap_atomic_write(path : String, payload : Bytes) -> Unit {
  bootstrap_ensure_directory(bootstrap_dirname(path))
  match bootstrap_platform_atomic_write(path, payload) {
    Ok(_) => ()
    Err(error) => bootstrap_fail(error)
  }
}

///|
fn bootstrap_build_cache_restore(plan : BootstrapBuildCachePlan) -> Bool {
  if !plan.enabled {
    return false
  }
  match bootstrap_build_cache_decode(plan) {
    None => false
    Some(payload) => {
      bootstrap_atomic_write(plan.output, payload)
      if plan.report {
        println("build output cache: hit \{plan.key}")
      }
      println("wrote \{plan.output} (\{payload.length()} bytes)")
      true
    }
  }
}

///|
fn bootstrap_build_cache_publish(plan : BootstrapBuildCachePlan) -> Unit {
  if !plan.enabled {
    return
  }
  let payload = @fs.read_file_to_bytes(plan.output) catch {
    error => {
      bootstrap_fail(
        "compiler did not write build output \{plan.output}: \{bootstrap_fs_error_message(error)}",
      )
      b""
    }
  }
  bootstrap_atomic_write(
    plan.artifact,
    bootstrap_build_cache_encode(plan, payload),
  )
  if plan.report {
    println("build output cache: miss \{plan.key}")
  }
}
