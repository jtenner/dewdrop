///|
pub let cache_pack_parse_event_kind = 0x54564550U

///|
pub let cache_pack_interface_kind = 0x45434649U

///|
pub let cache_pack_body_module_kind = 0x444f4d42U

///|
pub let cache_pack_body_family_kind = 0x4d414642U

///|
pub let cache_pack_layout_kind = 0x5459414cU

///|
pub let cache_pack_fragment_kind = 0x30475246U

///|
pub struct CompilationCachePack {
  enabled : Bool
  path : String
  pack : @cache_binary.ArtifactPack
  mut dirty : Bool
  mut hits : Int
  mut misses : Int
  reads : Int
}

///|
pub fn CompilationCachePack::status(self : CompilationCachePack) -> String {
  if !self.enabled {
    "disabled"
  } else {
    "reads \{self.reads}, hits \{self.hits}, misses \{self.misses}"
  }
}

///|
fn cache_pack_bound_context(
  context_digest : FixedArray[Byte],
) -> FixedArray[Byte] {
  let output = Buffer(size_hint=96)
  output.write_bytes(b"DEW_CACHE_PACK_PRODUCER_CONTEXT_V1\x00")
  cache_pack_write_string(
    output,
    @sys.get_env_var("DEW_COMPILER_FINGERPRINT").unwrap_or("compiler-schema-v1"),
  )
  for byte in context_digest {
    output.write_byte(byte)
  }
  @cache_binary.blake3(output.to_bytes())
}

///|
fn cache_pack_rehash_digest(digest : FixedArray[Byte]) -> FixedArray[Byte] {
  let output = Buffer(size_hint=32)
  for byte in digest {
    output.write_byte(byte)
  }
  @cache_binary.blake3(output.to_bytes())
}

///|
fn cache_pack_write_string(output : Buffer, value : String) -> Unit {
  let bytes = @utf8.encode(value)
  let length = bytes.length().reinterpret_as_uint()
  output.write_byte((length & 0xffU).to_byte())
  output.write_byte(((length >> 8) & 0xffU).to_byte())
  output.write_byte(((length >> 16) & 0xffU).to_byte())
  output.write_byte(((length >> 24) & 0xffU).to_byte())
  output.write_bytes(bytes)
}

///|
fn cache_pack_default_key(
  manifest : @semantic.ProgramManifest,
  root_module_index : Int,
  default_preamble : Bool,
  planning_mode : Int,
) -> String {
  let output = Buffer()
  output.write_bytes(b"DEW_COMPILATION_CACHE_PACK_KEY_V1\x00")
  output.write_byte(if default_preamble { 1 } else { 0 })
  for shift in [0, 8, 16, 24] {
    output.write_byte(
      ((root_module_index.reinterpret_as_uint() >> shift) & 0xffU).to_byte(),
    )
  }
  output.write_byte(planning_mode.to_byte())
  for module_ in manifest.modules {
    cache_pack_write_string(output, module_.path)
    for file in module_.files {
      cache_pack_write_string(output, file.path)
    }
  }
  @crypto.bytes_to_hex_string(@cache_binary.blake3(output.to_bytes()))
}

///|
fn cache_pack_directory() -> String {
  interface_cache_join(interface_cache_root(), "packs")
}

///|
fn cache_pack_path(key : String) -> String {
  interface_cache_join(cache_pack_directory(), "v1-" + key + ".dwp")
}

///|
pub fn open_compilation_cache_pack(
  manifest : @semantic.ProgramManifest,
  root_module_index : Int,
  default_preamble : Bool,
  planning_mode : Int,
) -> Result[CompilationCachePack, String] {
  let any_layer_enabled = @sys.get_env_var("DEW_PARSE_EVENT_CACHE").unwrap_or(
      "1",
    ) !=
    "0" ||
    @sys.get_env_var("DEW_INTERFACE_CACHE").unwrap_or("1") != "0" ||
    @sys.get_env_var("DEW_BODY_CACHE").unwrap_or("0") == "1" ||
    @sys.get_env_var("DEW_BODY_FAMILY_CACHE").unwrap_or("0") == "1" ||
    @sys.get_env_var("DEW_PLAN_CACHE").unwrap_or("0") == "1" ||
    (
      @sys.get_env_var("DEW_PROGRAM_CACHE").unwrap_or("1") != "0" &&
      @sys.get_env_var("DEW_COMPILER_FINGERPRINT").unwrap_or("") != ""
    )
  let enabled = cache_platform_supported() &&
    any_layer_enabled &&
    @sys.get_env_var("DEW_CACHE_PACK").unwrap_or("1") != "0"
  if !enabled {
    return Ok({
      enabled: false,
      path: "",
      pack: @cache_binary.ArtifactPack::empty(),
      dirty: false,
      hits: 0,
      misses: 0,
      reads: 0,
    })
  }
  let key = @sys.get_env_var("DEW_CACHE_PACK_KEY").unwrap_or(
    cache_pack_default_key(
      manifest, root_module_index, default_preamble, planning_mode,
    ),
  )
  let path = cache_pack_path(key)
  if !@fs.path_exists(path) {
    return Ok({
      enabled: true,
      path,
      pack: @cache_binary.ArtifactPack::empty(),
      dirty: false,
      hits: 0,
      misses: 0,
      reads: 0,
    })
  }
  let bytes = @fs.read_file_to_bytes(path) catch {
    error =>
      return Err(
        "cannot read compilation cache pack \{path}: \{standard_loader_fs_error_message(error)}",
      )
  }
  let pack = match @cache_binary.open_artifact_pack(bytes) {
    Ok(value) => value
    Err(error) => return Err("corrupt compilation cache pack \{path}: \{error}")
  }
  Ok({ enabled: true, path, pack, dirty: false, hits: 0, misses: 0, reads: 1, })
}

///|
pub fn CompilationCachePack::lookup(
  self : CompilationCachePack,
  kind : UInt,
  schema_version : UInt,
  owner : String,
  content_digest : FixedArray[Byte],
  context_digest : FixedArray[Byte],
) -> Result[Bytes?, String] {
  if !self.enabled {
    return Ok(None)
  }
  match
    self.pack.lookup_checked(
      kind,
      schema_version,
      owner,
      content_digest,
      cache_pack_bound_context(context_digest),
    ) {
    Err(error) => Err(error)
    Ok(Some(payload)) => {
      self.hits += 1
      Ok(Some(payload))
    }
    Ok(None) => {
      self.misses += 1
      Ok(None)
    }
  }
}

///|
pub fn CompilationCachePack::store(
  self : CompilationCachePack,
  kind : UInt,
  schema_version : UInt,
  flags : UInt,
  owner_kind : UInt,
  owner : String,
  content_digest : FixedArray[Byte],
  context_digest : FixedArray[Byte],
  payload : Bytes,
) -> Result[Unit, String] {
  if !self.enabled {
    return Ok(())
  }
  match
    self.pack.upsert(
      @cache_binary.ArtifactPackEntry::new(
        kind,
        schema_version,
        flags,
        owner_kind,
        owner,
        content_digest,
        cache_pack_bound_context(context_digest),
        payload,
      ),
    ) {
    Err(error) => Err(error)
    Ok(_) => {
      self.dirty = true
      Ok(())
    }
  }
}

///|
pub fn CompilationCachePack::commit(
  self : CompilationCachePack,
) -> Result[Unit, String] {
  if !self.enabled || !self.dirty {
    return Ok(())
  }
  let root = interface_cache_root()
  match ensure_interface_cache_root(root) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  match ensure_cache_directory(cache_pack_directory()) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let encoded = match self.pack.encode() {
    Err(error) => return Err("cannot encode compilation cache pack: \{error}")
    Ok(value) => value
  }
  let path_bytes = @utf8.encode(self.path)
  let result = cache_platform_atomic_write(
    path_bytes,
    path_bytes.length(),
    encoded,
  )
  if result != 0 {
    return Err(
      "cannot atomically write compilation cache pack \{self.path}: errno \{-result}",
    )
  }
  self.dirty = false
  Ok(())
}
