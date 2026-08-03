///|
let standard_interface_cache_file_magic : Bytes = b"DEW_STD_INTERFACE_CACHE_V6\x00"

///|
fn wrap_interface_cache_payload(payload : Bytes) -> Bytes {
  let output = Buffer()
  output.write_bytes(standard_interface_cache_file_magic)
  let digest = @crypto.sha256(payload)
  for byte in digest {
    output.write_byte(byte)
  }
  output.write_bytes(payload)
  output.to_bytes()
}

///|
fn unwrap_interface_cache_payload(bytes : Bytes) -> Result[Bytes, String] {
  let header_length = standard_interface_cache_file_magic.length()
  let digest_length = 32
  if bytes.length() < header_length + digest_length {
    return Err("truncated standard-interface cache envelope")
  }
  for index in 0..<header_length {
    if bytes[index] != standard_interface_cache_file_magic[index] {
      return Err("unsupported standard-interface cache envelope")
    }
  }
  let payload = Buffer()
  let mut payload_index = header_length + digest_length
  while payload_index < bytes.length() {
    payload.write_byte(bytes[payload_index])
    payload_index += 1
  }
  let payload_bytes = payload.to_bytes()
  let actual = @crypto.sha256(payload_bytes)
  for index in 0..<digest_length {
    if bytes[header_length + index] != actual[index] {
      return Err("standard-interface cache checksum mismatch")
    }
  }
  Ok(payload_bytes)
}

///|
pub enum StandardInterfaceCacheLookup {
  StandardInterfaceCacheDisabled
  StandardInterfaceCacheMiss
  StandardInterfaceCacheHit(Array[@semantic.FrozenModuleInterface?])
}

///|
pub enum StandardInterfaceCacheStatus {
  StandardInterfaceCacheWasDisabled
  StandardInterfaceCacheWasMiss
  StandardInterfaceCacheWasHit
} derive(Eq, Debug)

///|
pub fn StandardInterfaceCacheStatus::label(
  self : StandardInterfaceCacheStatus,
) -> String {
  match self {
    StandardInterfaceCacheWasDisabled => "disabled"
    StandardInterfaceCacheWasMiss => "miss"
    StandardInterfaceCacheWasHit => "hit"
  }
}

///|
pub struct StandardCachedAnalysis {
  analyzed : @semantic.AnalyzedProgramSemantics
  status : StandardInterfaceCacheStatus
}

///|
fn interface_cache_enabled(fingerprint : String) -> Bool {
  fingerprint != "" &&
  @sys.get_env_var("DEW_INTERFACE_CACHE").unwrap_or("1") != "0"
}

///|
fn interface_cache_root() -> String {
  @sys.get_env_var("DEW_CACHE_DIR").unwrap_or(".dew-cache")
}

///|
fn interface_cache_join(root : String, child : String) -> String {
  if root.has_suffix("/") {
    root + child
  } else {
    root + "/" + child
  }
}

///|
fn ensure_cache_directory(path : String) -> Result[Unit, String] {
  if @fs.path_exists(path) {
    let directory = @fs.is_dir(path) catch {
      error =>
        return Err("cannot inspect interface cache directory \{path}: \{error}")
    }
    if !directory {
      return Err("interface cache path is not a directory: \{path}")
    }
    return Ok(())
  }
  @fs.create_dir(path) catch {
    error =>
      return Err("cannot create interface cache directory \{path}: \{error}")
  }
  Ok(())
}

///|
fn interface_cache_file(fingerprint : String) -> String {
  interface_cache_join(
    interface_cache_join(interface_cache_root(), "interfaces"),
    "v6-" + fingerprint + ".dwi",
  )
}

///|
pub fn lookup_standard_interfaces(
  program : @semantic.CollectedProgram,
  fingerprint : String,
) -> Result[StandardInterfaceCacheLookup, String] {
  if !interface_cache_enabled(fingerprint) {
    return Ok(StandardInterfaceCacheDisabled)
  }
  let path = interface_cache_file(fingerprint)
  if !@fs.path_exists(path) {
    return Ok(StandardInterfaceCacheMiss)
  }
  let bytes = @fs.read_file_to_bytes(path) catch {
    error => return Err("cannot read frozen-interface cache \{path}: \{error}")
  }
  let payload = match unwrap_interface_cache_payload(bytes) {
    Ok(payload) => payload
    Err(error) => return Err("corrupt frozen-interface cache \{path}: \{error}")
  }
  let interfaces = match @semantic.deserialize_frozen_interfaces(payload) {
    Ok(interfaces) => interfaces
    Err(error) => return Err("corrupt frozen-interface cache \{path}: \{error}")
  }
  let slots : Array[@semantic.FrozenModuleInterface?] = Array::make(
    program.modules.length(),
    None,
  )
  let mut expected = 0
  for path in program.module_paths {
    if path.has_prefix("dew.std.") {
      expected += 1
    }
  }
  if interfaces.length() != expected {
    return Err("frozen-interface cache module count does not match the program")
  }
  for interface_ in interfaces {
    if !interface_.path.has_prefix("dew.std.") {
      return Err("frozen-interface cache contains a non-standard module")
    }
    let index = match program.module_index(interface_.path) {
      Some(index) => index
      None =>
        return Err(
          "frozen-interface cache contains unavailable module \{interface_.path}",
        )
    }
    if slots[index] is Some(_) {
      return Err("frozen-interface cache duplicates module \{interface_.path}")
    }
    if interface_.module_id != program.modules[index].module_id {
      return Err(
        "frozen-interface cache identity mismatch for \{interface_.path}",
      )
    }
    slots[index] = Some(interface_)
  }
  Ok(StandardInterfaceCacheHit(slots))
}

///|
pub fn store_standard_interfaces(
  program : @semantic.CollectedProgram,
  interfaces : Array[@semantic.FrozenModuleInterface],
  fingerprint : String,
) -> Result[Unit, String] {
  if !interface_cache_enabled(fingerprint) {
    return Ok(())
  }
  if interfaces.length() != program.modules.length() {
    return Err("cannot cache interfaces that do not match the program")
  }
  let standard : Array[@semantic.FrozenModuleInterface] = []
  for index, interface_ in interfaces {
    if program.module_paths[index].has_prefix("dew.std.") {
      if interface_.path != program.module_paths[index] ||
        interface_.module_id != program.modules[index].module_id {
        return Err("cannot cache a standard interface with mismatched identity")
      }
      standard.push(interface_)
    }
  }
  let bytes = match @semantic.serialize_frozen_interfaces(standard) {
    Ok(bytes) => bytes
    Err(error) =>
      return Err("cannot serialize frozen-interface cache: \{error}")
  }
  let root = interface_cache_root()
  match ensure_cache_directory(root) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let directory = interface_cache_join(root, "interfaces")
  match ensure_cache_directory(directory) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let path = interface_cache_file(fingerprint)
  let envelope = wrap_interface_cache_payload(bytes)
  @fs.write_bytes_to_file(path, envelope) catch {
    error => return Err("cannot write frozen-interface cache \{path}: \{error}")
  }
  Ok(())
}

///|
/// Resolves standard interfaces from the persistent cache when available,
/// analyzes all executable bodies normally, and stores one deterministic
/// standard-interface bundle after a miss.
pub fn analyze_program_with_standard_cache(
  program : @semantic.CollectedProgram,
  loaded : StandardLibraryLoad,
) -> Result[StandardCachedAnalysis, String] {
  let cached : Array[@semantic.FrozenModuleInterface?] = Array::make(
    program.modules.length(),
    None,
  )
  let mut status = StandardInterfaceCacheWasDisabled
  let mut miss = false
  match lookup_standard_interfaces(program, loaded.fingerprint) {
    Err(error) => return Err(error)
    Ok(StandardInterfaceCacheDisabled) => ()
    Ok(StandardInterfaceCacheMiss) => {
      status = StandardInterfaceCacheWasMiss
      miss = true
    }
    Ok(StandardInterfaceCacheHit(slots)) => {
      status = StandardInterfaceCacheWasHit
      for index, slot in slots {
        cached[index] = slot
      }
    }
  }
  let analyzed = @semantic.analyze_program_semantics_with_cached_interfaces(
    program, cached,
  )
  if miss && loaded.cacheable {
    match
      store_standard_interfaces(
        program,
        analyzed.frozen.interfaces,
        loaded.fingerprint,
      ) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  Ok({ analyzed, status })
}
