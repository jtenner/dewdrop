///|
pub let cache_pack_check_kind = 0x4b434843U

///|
pub let cache_pack_wasm_kind = 0x4d534157U

///|
pub let cache_pack_hir_kind = 0x30524948U

///|
pub let cache_pack_lowering_kind = 0x3052574cU

///|
fn program_output_cache_enabled() -> Bool {
  @sys.get_env_var("DEW_PROGRAM_CACHE").unwrap_or("1") != "0" &&
  @sys.get_env_var("DEW_COMPILER_FINGERPRINT").unwrap_or("") != ""
}

///|
fn program_output_cache_kind(command : Int, emit : Int) -> UInt {
  if command == 0 {
    cache_pack_check_kind
  } else {
    match emit {
      1 => cache_pack_hir_kind
      2 => cache_pack_lowering_kind
      _ => cache_pack_wasm_kind
    }
  }
}

///|
fn program_output_write_int(output : Buffer, value : Int) -> Unit {
  let bits = value.reinterpret_as_uint()
  output.write_byte((bits & 0xffU).to_byte())
  output.write_byte(((bits >> 8) & 0xffU).to_byte())
  output.write_byte(((bits >> 16) & 0xffU).to_byte())
  output.write_byte(((bits >> 24) & 0xffU).to_byte())
}

///|
fn program_output_content_digest(
  manifest : @semantic.ProgramManifest,
) -> FixedArray[Byte] {
  let output = Buffer()
  output.write_bytes(b"DEW_PROGRAM_OUTPUT_CONTENT_V1\x00")
  for module_ in manifest.modules {
    cache_pack_write_string(output, module_.path)
    for file in module_.files {
      cache_pack_write_string(output, file.path)
      program_output_write_int(output, file.source.length())
      output.write_bytes(file.source)
    }
  }
  @cache_binary.blake3(output.to_bytes())
}

///|
fn program_output_context_digest(
  root_module_index : Int,
  default_preamble : Bool,
  command : Int,
  emit : Int,
  dependency_modules : Array[String],
  dependency_fingerprints : Array[String],
  static_link_providers : Array[String],
  static_link_modules : Array[Bytes],
) -> FixedArray[Byte] {
  let output = Buffer()
  output.write_bytes(b"DEW_PROGRAM_OUTPUT_CONTEXT_V1\x00")
  cache_pack_write_string(
    output,
    @sys.get_env_var("DEW_COMPILER_FINGERPRINT").unwrap_or(""),
  )
  cache_pack_write_string(
    output,
    @sys.get_env_var("DEW_BOOTSTRAP_STD").unwrap_or("0"),
  )
  cache_pack_write_string(
    output,
    @sys.get_env_var("DEW_STD_ROOT").unwrap_or(""),
  )
  cache_pack_write_string(
    output,
    @sys.get_env_var("DEW_DEPENDENCY_INTERFACE_KEY").unwrap_or(""),
  )
  program_output_write_int(output, root_module_index)
  output.write_byte(if default_preamble { 1 } else { 0 })
  program_output_write_int(output, command)
  program_output_write_int(output, emit)
  for index, module_ in dependency_modules {
    cache_pack_write_string(output, module_)
    if index < dependency_fingerprints.length() {
      cache_pack_write_string(output, dependency_fingerprints[index])
    } else {
      cache_pack_write_string(output, "")
    }
  }
  for index, provider in static_link_providers {
    cache_pack_write_string(output, provider)
    if index < static_link_modules.length() {
      let bytes = static_link_modules[index]
      program_output_write_int(output, bytes.length())
      for byte in @cache_binary.blake3(bytes) {
        output.write_byte(byte)
      }
    } else {
      program_output_write_int(output, 0)
    }
  }
  @cache_binary.blake3(output.to_bytes())
}

///|
fn program_output_owner(
  manifest : @semantic.ProgramManifest,
  root_module_index : Int,
) -> String {
  if root_module_index >= 0 && root_module_index < manifest.modules.length() {
    "program:" + manifest.modules[root_module_index].path
  } else {
    "program:invalid-root"
  }
}

///|
pub fn lookup_program_output_cache(
  pack : CompilationCachePack,
  manifest : @semantic.ProgramManifest,
  root_module_index : Int,
  default_preamble : Bool,
  command : Int,
  emit : Int,
  dependency_modules : Array[String],
  dependency_fingerprints : Array[String],
  static_link_providers? : Array[String] = [],
  static_link_modules? : Array[Bytes] = [],
) -> Result[Bytes?, String] {
  if !pack.enabled || !program_output_cache_enabled() {
    return Ok(None)
  }
  pack.lookup(
    program_output_cache_kind(command, emit),
    1U,
    program_output_owner(manifest, root_module_index),
    program_output_content_digest(manifest),
    program_output_context_digest(
      root_module_index, default_preamble, command, emit, dependency_modules, dependency_fingerprints,
      static_link_providers, static_link_modules,
    ),
  )
}

///|
pub fn store_program_output_cache(
  pack : CompilationCachePack,
  manifest : @semantic.ProgramManifest,
  root_module_index : Int,
  default_preamble : Bool,
  command : Int,
  emit : Int,
  dependency_modules : Array[String],
  dependency_fingerprints : Array[String],
  payload : Bytes,
  static_link_providers? : Array[String] = [],
  static_link_modules? : Array[Bytes] = [],
) -> Result[Unit, String] {
  if !pack.enabled || !program_output_cache_enabled() {
    return Ok(())
  }
  pack.store(
    program_output_cache_kind(command, emit),
    1U,
    0U,
    3U,
    program_output_owner(manifest, root_module_index),
    program_output_content_digest(manifest),
    program_output_context_digest(
      root_module_index, default_preamble, command, emit, dependency_modules, dependency_fingerprints,
      static_link_providers, static_link_modules,
    ),
    payload,
  )
}
