///|
pub enum InterfaceBundleCacheLookup {
  InterfaceBundleCacheDisabled
  InterfaceBundleCacheMiss
  InterfaceBundleCacheHit(Array[@semantic.FrozenModuleInterface?])
}

///|
pub enum InterfaceBundleCacheStatus {
  InterfaceBundleCacheWasDisabled
  InterfaceBundleCacheWasMiss
  InterfaceBundleCacheWasHit
} derive(Eq, Debug)

///|
pub fn InterfaceBundleCacheStatus::label(
  self : InterfaceBundleCacheStatus,
) -> String {
  match self {
    InterfaceBundleCacheWasDisabled => "disabled"
    InterfaceBundleCacheWasMiss => "miss"
    InterfaceBundleCacheWasHit => "hit"
  }
}

///|
pub struct CachedInterfaceBundleAnalysis {
  analyzed : @semantic.AnalyzedProgramSemantics
  status : InterfaceBundleCacheStatus
}

///|
pub struct InterfaceBundleCacheKey {
  fingerprint : String
}

///|
pub struct InterfaceBundlePolicy {
  enabled : Bool
  store_on_miss : Bool
  root_module_index : Int
  include_dependencies : Bool
}

///|
pub fn InterfaceBundlePolicy::for_compilation(
  loaded : StandardLibraryLoad,
  root_module_index : Int,
) -> InterfaceBundlePolicy {
  {
    enabled: @sys.get_env_var("DEW_INTERFACE_CACHE").unwrap_or("1") != "0",
    store_on_miss: loaded.cacheable,
    root_module_index,
    include_dependencies: loaded.dependency_fingerprint != "",
  }
}

///|
fn interface_bundle_cache_key(
  loaded : StandardLibraryLoad,
) -> InterfaceBundleCacheKey {
  if loaded.dependency_fingerprint == "" {
    return { fingerprint: loaded.fingerprint }
  }
  let output = Buffer()
  output.write_bytes(b"DEW_INTERFACE_BUNDLE_KEY_V1\x00")
  output.write_string_utf8(loaded.fingerprint)
  output.write_byte(0)
  output.write_string_utf8(loaded.dependency_fingerprint)
  {
    fingerprint: @crypto.bytes_to_hex_string(@crypto.sha256(output.to_bytes())),
  }
}

///|
fn interface_bundle_cache_enabled(
  key : InterfaceBundleCacheKey,
  policy : InterfaceBundlePolicy,
) -> Bool {
  key.fingerprint != "" && policy.enabled
}

///|
fn interface_bundle_module_is_cacheable(
  program : @semantic.CollectedProgram,
  index : Int,
  policy : InterfaceBundlePolicy,
) -> Bool {
  program.module_paths[index].has_prefix("dew.std.") ||
  (policy.include_dependencies && index != policy.root_module_index)
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
fn interface_cache_file(key : InterfaceBundleCacheKey) -> String {
  interface_cache_join(
    interface_cache_join(interface_cache_root(), "interfaces"),
    "v11-" + key.fingerprint + ".dwi",
  )
}

///|
pub fn lookup_interface_bundle(
  program : @semantic.CollectedProgram,
  key : InterfaceBundleCacheKey,
  policy : InterfaceBundlePolicy,
) -> Result[InterfaceBundleCacheLookup, String] {
  if !interface_bundle_cache_enabled(key, policy) {
    return Ok(InterfaceBundleCacheDisabled)
  }
  let path = interface_cache_file(key)
  if !@fs.path_exists(path) {
    return Ok(InterfaceBundleCacheMiss)
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
  for index, _ in program.module_paths {
    if interface_bundle_module_is_cacheable(program, index, policy) {
      expected += 1
    }
  }
  if interfaces.length() != expected {
    return Err("frozen-interface cache module count does not match the program")
  }
  for interface_ in interfaces {
    let index = match program.module_index(interface_.path) {
      Some(index) => index
      None =>
        return Err(
          "frozen-interface cache contains unavailable module \{interface_.path}",
        )
    }
    if !interface_bundle_module_is_cacheable(program, index, policy) {
      return Err(
        "frozen-interface cache contains an unavailable dependency module",
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
  Ok(InterfaceBundleCacheHit(slots))
}

///|
pub fn store_interface_bundle(
  program : @semantic.CollectedProgram,
  interfaces : Array[@semantic.FrozenModuleInterface],
  key : InterfaceBundleCacheKey,
  policy : InterfaceBundlePolicy,
) -> Result[Unit, String] {
  if !interface_bundle_cache_enabled(key, policy) {
    return Ok(())
  }
  if interfaces.length() != program.modules.length() {
    return Err("cannot cache interfaces that do not match the program")
  }
  let standard : Array[@semantic.FrozenModuleInterface] = []
  for index, interface_ in interfaces {
    if interface_bundle_module_is_cacheable(program, index, policy) {
      if interface_.path != program.module_paths[index] ||
        interface_.module_id != program.modules[index].module_id {
        return Err("cannot cache an interface with mismatched identity")
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
  let path = interface_cache_file(key)
  let envelope = wrap_interface_cache_payload(bytes)
  @fs.write_bytes_to_file(path, envelope) catch {
    error => return Err("cannot write frozen-interface cache \{path}: \{error}")
  }
  Ok(())
}
