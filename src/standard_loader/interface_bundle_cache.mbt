///|
pub enum InterfaceBundleCacheLookup {
  InterfaceBundleCacheDisabled
  InterfaceBundleCacheMiss
  InterfaceBundleCacheHit(Array[@semantic.FrozenModuleInterface?])
}

///|
pub struct InterfaceBundleCacheStatus {
  enabled : Bool
  hits : Int
  misses : Int
}

///|
pub fn InterfaceBundleCacheStatus::label(
  self : InterfaceBundleCacheStatus,
) -> String {
  if !self.enabled {
    "disabled"
  } else {
    "hits \{self.hits}, misses \{self.misses}"
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
  @sys.get_env_var("DEW_CACHE_DIR").unwrap_or(".dew/cache")
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
fn ensure_interface_cache_root(path : String) -> Result[Unit, String] {
  if path == ".dew/cache" {
    match ensure_cache_directory(".dew") {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  ensure_cache_directory(path)
}

///|
fn interface_cache_file(key : InterfaceBundleCacheKey) -> String {
  interface_cache_join(
    interface_cache_join(interface_cache_root(), "interfaces"),
    "v11-" + key.fingerprint + ".dwi",
  )
}

///|
fn workspace_interface_cache_directory() -> String {
  interface_cache_join(interface_cache_root(), "workspace-interfaces")
}

///|
fn workspace_interface_cache_file(key : String) -> String {
  interface_cache_join(
    workspace_interface_cache_directory(),
    "v1-" + key + ".dwi",
  )
}

///|
fn interface_cache_write_string(output : Buffer, value : String) -> Unit {
  let bytes = @utf8.encode(value)
  let length = bytes.length().reinterpret_as_uint()
  output.write_byte((length & 0xffU).to_byte())
  output.write_byte(((length >> 8) & 0xffU).to_byte())
  output.write_byte(((length >> 16) & 0xffU).to_byte())
  output.write_byte(((length >> 24) & 0xffU).to_byte())
  output.write_bytes(bytes)
}

///|
fn workspace_interface_source_fingerprint(
  program : @semantic.CollectedProgram,
  module_index : Int,
) -> String {
  let module_ = program.modules[module_index]
  let output = Buffer()
  output.write_bytes(b"DEW_WORKSPACE_INTERFACE_SOURCE_V1\x00")
  interface_cache_write_string(output, program.module_paths[module_index])
  let module_id = module_.module_id
  for shift in [0, 8, 16, 24, 32, 40, 48, 56] {
    output.write_byte(((module_id >> shift) & 0xffUL).to_byte())
  }
  for index in 0..<module_.files.length() {
    interface_cache_write_string(output, module_.file_paths[index])
    let source = module_.file_sources[index]
    let length = source.length().reinterpret_as_uint()
    output.write_byte((length & 0xffU).to_byte())
    output.write_byte(((length >> 8) & 0xffU).to_byte())
    output.write_byte(((length >> 16) & 0xffU).to_byte())
    output.write_byte(((length >> 24) & 0xffU).to_byte())
    output.write_bytes(source)
  }
  @crypto.bytes_to_hex_string(@crypto.sha256(output.to_bytes()))
}

///|
fn workspace_interface_cache_key_from_dependency_records(
  source_fingerprint : String,
  dependency_records : Array[String],
) -> String {
  dependency_records.sort()
  let output = Buffer()
  output.write_bytes(b"DEW_WORKSPACE_INTERFACE_KEY_V1\x00")
  interface_cache_write_string(output, source_fingerprint)
  for record in dependency_records {
    interface_cache_write_string(output, record)
  }
  @crypto.bytes_to_hex_string(@crypto.sha256(output.to_bytes()))
}

///|
fn workspace_interface_cache_key(
  program : @semantic.CollectedProgram,
  graph : @semantic.ModuleDependencyGraph,
  module_index : Int,
  cached : Array[@semantic.FrozenModuleInterface?],
) -> String? {
  let dependency_records : Array[String] = []
  let dependencies = graph.dependencies[module_index]
  for edge in 0..<dependencies.length {
    let dependency_index = graph.dependency_modules[dependencies.start + edge]
    let dependency = match cached[dependency_index] {
      Some(value) => value
      None => return None
    }
    dependency_records.push(
      dependency.path + "\u0000" + dependency.content_fingerprint,
    )
  }
  Some(
    workspace_interface_cache_key_from_dependency_records(
      workspace_interface_source_fingerprint(program, module_index),
      dependency_records,
    ),
  )
}

///|
fn validate_workspace_interface_cache_hit(
  program : @semantic.CollectedProgram,
  graph : @semantic.ModuleDependencyGraph,
  module_index : Int,
  cached : Array[@semantic.FrozenModuleInterface?],
  interface_ : @semantic.FrozenModuleInterface,
) -> Result[Bool, String] {
  if interface_.module_id != program.modules[module_index].module_id ||
    interface_.path != program.module_paths[module_index] {
    return Err("workspace frozen-interface cache identity mismatch")
  }
  let dependencies = graph.dependencies[module_index]
  let expected : Array[String] = []
  for edge in 0..<dependencies.length {
    let dependency_index = graph.dependency_modules[dependencies.start + edge]
    let dependency = match cached[dependency_index] {
      Some(value) => value
      None => return Ok(false)
    }
    expected.push(dependency.path + "\u0000" + dependency.content_fingerprint)
  }
  let actual : Array[String] = []
  for dependency in interface_.dependencies {
    actual.push(dependency.path + "\u0000" + dependency.content_fingerprint)
  }
  expected.sort()
  actual.sort()
  Ok(expected == actual)
}

///|
fn lookup_workspace_interface(
  program : @semantic.CollectedProgram,
  graph : @semantic.ModuleDependencyGraph,
  module_index : Int,
  cached : Array[@semantic.FrozenModuleInterface?],
  key : String,
) -> Result[@semantic.FrozenModuleInterface?, String] {
  let path = workspace_interface_cache_file(key)
  if !@fs.path_exists(path) {
    return Ok(None)
  }
  let bytes = @fs.read_file_to_bytes(path) catch {
    error =>
      return Err(
        "cannot read workspace frozen-interface cache \{path}: \{error}",
      )
  }
  let payload = match unwrap_interface_cache_payload(bytes) {
    Ok(value) => value
    Err(error) =>
      return Err("corrupt workspace frozen-interface cache \{path}: \{error}")
  }
  let interfaces = match @semantic.deserialize_frozen_interfaces(payload) {
    Ok(value) => value
    Err(error) =>
      return Err("corrupt workspace frozen-interface cache \{path}: \{error}")
  }
  if interfaces.length() != 1 {
    return Err("workspace frozen-interface cache must contain one module")
  }
  let interface_ = interfaces[0]
  match
    validate_workspace_interface_cache_hit(
      program, graph, module_index, cached, interface_,
    ) {
    Ok(true) => Ok(Some(interface_))
    Ok(false) => Ok(None)
    Err(error) =>
      Err("corrupt workspace frozen-interface cache \{path}: \{error}")
  }
}

///|
fn store_workspace_interface(
  key : String,
  interface_ : @semantic.FrozenModuleInterface,
) -> Result[Unit, String] {
  let payload = match @semantic.serialize_frozen_interfaces([interface_]) {
    Ok(value) => value
    Err(error) =>
      return Err("cannot serialize workspace frozen-interface cache: \{error}")
  }
  let root = interface_cache_root()
  match ensure_interface_cache_root(root) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let directory = workspace_interface_cache_directory()
  match ensure_cache_directory(directory) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let path = workspace_interface_cache_file(key)
  let path_bytes = @utf8.encode(path)
  let result = cache_platform_atomic_write(
    path_bytes,
    path_bytes.length(),
    wrap_interface_cache_payload(payload),
  )
  if result != 0 {
    return Err(
      "cannot atomically write workspace frozen-interface cache \{path}: errno \{-result}",
    )
  }
  Ok(())
}

///|
fn workspace_module_is_cacheable(
  program : @semantic.CollectedProgram,
  index : Int,
  policy : InterfaceBundlePolicy,
) -> Bool {
  index != policy.root_module_index &&
  !interface_bundle_module_is_cacheable(program, index, policy)
}

///|
fn workspace_module_cache_is_eligible(
  program : @semantic.CollectedProgram,
  graph : @semantic.ModuleDependencyGraph,
  module_index : Int,
  policy : InterfaceBundlePolicy,
) -> Bool {
  if !policy.enabled ||
    !policy.store_on_miss ||
    !workspace_module_is_cacheable(program, module_index, policy) {
    return false
  }
  for scc in graph.sccs {
    let mut contains = false
    for item in 0..<scc.length {
      if graph.scc_modules[scc.start + item] == module_index {
        contains = true
        break
      }
    }
    if !contains {
      continue
    }
    if scc.length != 1 {
      return false
    }
    let dependencies = graph.dependencies[module_index]
    for edge in 0..<dependencies.length {
      if graph.dependency_modules[dependencies.start + edge] == module_index {
        return false
      }
    }
    return true
  }
  false
}

///|
fn workspace_scc_contains(
  scc : @semantic.HirSpan,
  members : Array[Int],
  module_index : Int,
) -> Bool {
  for item in 0..<scc.length {
    if members[scc.start + item] == module_index {
      return true
    }
  }
  false
}

///|
fn workspace_interface_scc_cache_is_eligible(
  program : @semantic.CollectedProgram,
  scc : @semantic.HirSpan,
  members : Array[Int],
  policy : InterfaceBundlePolicy,
) -> Bool {
  if !policy.enabled || !policy.store_on_miss || scc.length < 1 {
    return false
  }
  for item in 0..<scc.length {
    if !workspace_module_is_cacheable(
        program,
        members[scc.start + item],
        policy,
      ) {
      return false
    }
  }
  true
}

///|
fn workspace_interface_scc_cache_key(
  program : @semantic.CollectedProgram,
  graph : @semantic.ModuleDependencyGraph,
  scc : @semantic.HirSpan,
  members : Array[Int],
  cached : Array[@semantic.FrozenModuleInterface?],
) -> String? {
  let source_records : Array[String] = []
  let dependency_records : Array[String] = []
  for item in 0..<scc.length {
    let module_index = members[scc.start + item]
    source_records.push(
      program.module_paths[module_index] +
      "\u0000" +
      workspace_interface_source_fingerprint(program, module_index),
    )
    let dependencies = graph.dependencies[module_index]
    for edge in 0..<dependencies.length {
      let dependency_index = graph.dependency_modules[dependencies.start + edge]
      if workspace_scc_contains(scc, members, dependency_index) {
        continue
      }
      let dependency = match cached[dependency_index] {
        Some(value) => value
        None => return None
      }
      dependency_records.push(
        dependency.path + "\u0000" + dependency.content_fingerprint,
      )
    }
  }
  source_records.sort()
  dependency_records.sort()
  let output = Buffer()
  output.write_bytes(b"DEW_WORKSPACE_INTERFACE_SCC_KEY_V1\x00")
  for record in source_records {
    interface_cache_write_string(output, record)
  }
  for record in dependency_records {
    interface_cache_write_string(output, record)
  }
  Some(@crypto.bytes_to_hex_string(@crypto.sha256(output.to_bytes())))
}

///|
fn lookup_workspace_interface_scc(
  program : @semantic.CollectedProgram,
  graph : @semantic.ModuleDependencyGraph,
  scc : @semantic.HirSpan,
  members : Array[Int],
  cached : Array[@semantic.FrozenModuleInterface?],
  key : String,
) -> Result[Bool, String] {
  let path = workspace_interface_cache_file(key)
  if !@fs.path_exists(path) {
    return Ok(false)
  }
  let bytes = @fs.read_file_to_bytes(path) catch {
    error =>
      return Err(
        "cannot read workspace frozen-interface SCC cache \{path}: \{error}",
      )
  }
  let payload = match unwrap_interface_cache_payload(bytes) {
    Ok(value) => value
    Err(error) =>
      return Err(
        "corrupt workspace frozen-interface SCC cache \{path}: \{error}",
      )
  }
  let interfaces = match @semantic.deserialize_frozen_interfaces(payload) {
    Ok(value) => value
    Err(error) =>
      return Err(
        "corrupt workspace frozen-interface SCC cache \{path}: \{error}",
      )
  }
  if interfaces.length() != scc.length {
    return Err(
      "corrupt workspace frozen-interface SCC cache \{path}: module count mismatch",
    )
  }
  let decoded : Array[@semantic.FrozenModuleInterface?] = Array::make(
    program.modules.length(),
    None,
  )
  for interface_ in interfaces {
    let module_index = match program.module_index(interface_.path) {
      Some(value) => value
      None =>
        return Err(
          "corrupt workspace frozen-interface SCC cache \{path}: unavailable module",
        )
    }
    if !workspace_scc_contains(scc, members, module_index) ||
      decoded[module_index] is Some(_) ||
      interface_.module_id != program.modules[module_index].module_id {
      return Err(
        "corrupt workspace frozen-interface SCC cache \{path}: identity mismatch",
      )
    }
    decoded[module_index] = Some(interface_)
  }
  for item in 0..<scc.length {
    let module_index = members[scc.start + item]
    let interface_ = match decoded[module_index] {
      Some(value) => value
      None =>
        return Err(
          "corrupt workspace frozen-interface SCC cache \{path}: missing module",
        )
    }
    let expected : Array[String] = []
    let dependencies = graph.dependencies[module_index]
    for edge in 0..<dependencies.length {
      let dependency_index = graph.dependency_modules[dependencies.start + edge]
      let dependency = if workspace_scc_contains(scc, members, dependency_index) {
        decoded[dependency_index]
      } else {
        cached[dependency_index]
      }
      match dependency {
        Some(value) =>
          expected.push(value.path + "\u0000" + value.content_fingerprint)
        None => return Ok(false)
      }
    }
    let actual : Array[String] = []
    for dependency in interface_.dependencies {
      actual.push(dependency.path + "\u0000" + dependency.content_fingerprint)
    }
    expected.sort()
    actual.sort()
    if expected != actual {
      return Ok(false)
    }
  }
  for item in 0..<scc.length {
    let module_index = members[scc.start + item]
    cached[module_index] = decoded[module_index]
  }
  Ok(true)
}

///|
fn store_workspace_interface_scc(
  key : String,
  scc : @semantic.HirSpan,
  members : Array[Int],
  interfaces : Array[@semantic.FrozenModuleInterface?],
) -> Result[Unit, String] {
  let stored : Array[@semantic.FrozenModuleInterface] = []
  for item in 0..<scc.length {
    let module_index = members[scc.start + item]
    match interfaces[module_index] {
      Some(value) => stored.push(value)
      None => return Err("cannot cache an incomplete workspace interface SCC")
    }
  }
  let payload = match @semantic.serialize_frozen_interfaces(stored) {
    Ok(value) => value
    Err(error) =>
      return Err(
        "cannot serialize workspace frozen-interface SCC cache: \{error}",
      )
  }
  let root = interface_cache_root()
  match ensure_interface_cache_root(root) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let directory = workspace_interface_cache_directory()
  match ensure_cache_directory(directory) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let path = workspace_interface_cache_file(key)
  let path_bytes = @utf8.encode(path)
  let result = cache_platform_atomic_write(
    path_bytes,
    path_bytes.length(),
    wrap_interface_cache_payload(payload),
  )
  if result != 0 {
    return Err(
      "cannot atomically write workspace frozen-interface SCC cache \{path}: errno \{-result}",
    )
  }
  Ok(())
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
  match ensure_interface_cache_root(root) {
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
