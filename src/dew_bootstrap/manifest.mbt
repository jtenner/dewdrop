///|
struct BootstrapDependencyRequest {
  name : String
  requirement : String
}

///|
struct BootstrapPackage {
  manifest : String
  name : String
  version : String
  dependencies : Array[BootstrapDependencyRequest]
}

///|
struct BootstrapLockedPackage {
  name : String
  version : String
  source : String
  manifest : String
  integrity : String
  interface_fingerprint : String
}

///|
struct BootstrapManifest {
  root : String
  modules : Array[(String, Array[String])]
  dependency_key : String
  expectations : Array[(String, String)]
}

///|
fn bootstrap_dirname(path : String) -> String {
  let parts = path.split("/").map(part => part.to_owned()).to_array()
  if parts.length() <= 1 {
    return "."
  }
  ignore(parts.pop())
  let joined = parts.join("/")
  if path.has_prefix("/") {
    "/" + joined
  } else {
    joined
  }
}

///|
fn bootstrap_basename(path : String) -> String {
  let parts = path.split("/").map(part => part.to_owned()).to_array()
  if parts.length() == 0 {
    path
  } else {
    parts[parts.length() - 1]
  }
}

///|
fn bootstrap_json_object(value : Json, context : String) -> Map[String, Json] {
  match value {
    Object(fields) => fields
    _ => {
      bootstrap_fail("\{context} root must be an object")
      Map([])
    }
  }
}

///|
fn bootstrap_read_json(path : String, context : String) -> Map[String, Json] {
  let text = @fs.read_file_to_string(path) catch {
    error => {
      bootstrap_fail(
        "cannot read \{context} \{path}: \{bootstrap_fs_error_message(error)}",
      )
      ""
    }
  }
  let value = @json.parse(text) catch {
    error => {
      bootstrap_fail("invalid \{context} \{path}: \{error}")
      Json::null()
    }
  }
  bootstrap_json_object(value, context)
}

///|
fn bootstrap_json_string(value : Json?, field : String) -> String {
  match value {
    Some(String(value)) => value
    _ => {
      bootstrap_fail("\{field} must be a string")
      ""
    }
  }
}

///|
fn bootstrap_package_module_name(name : String) -> String {
  let value = if name.has_prefix("@") { name[1:].to_owned() } else { name }
  let parts = value.split("/").map(part => part.to_owned()).to_array()
  if parts.length() != 2 {
    bootstrap_fail("package name must use @scope/name")
  }
  parts[0].replace_all(old="-", new="_") +
  "." +
  parts[1].replace_all(old="-", new="_")
}

///|
fn bootstrap_valid_package_name(name : String) -> Bool {
  if !name.has_prefix("@") {
    return false
  }
  let parts = name[1:].to_owned().split("/").to_array()
  parts.length() == 2 && parts[0].length() > 0 && parts[1].length() > 0
}

///|
fn bootstrap_load_package(path : String) -> BootstrapPackage {
  let manifest = if @fs.path_exists(path) &&
    (@fs.is_dir(path) catch { _ => false }) {
    bootstrap_join(path, "dew.json")
  } else {
    path
  }
  let fields = bootstrap_read_json(manifest, "package definition")
  let name = bootstrap_json_string(fields.get("name"), "package name")
  let version = bootstrap_json_string(fields.get("version"), "package version")
  if !bootstrap_valid_package_name(name) {
    bootstrap_fail("package name must use @scope/name")
  }
  let dependencies : Array[BootstrapDependencyRequest] = []
  match fields.get("dependencies") {
    None => ()
    Some(Object(values)) => {
      let names = values.keys().to_array()
      names.sort()
      for dependency_name in names {
        if !bootstrap_valid_package_name(dependency_name) {
          bootstrap_fail(
            "dependency name must use @scope/name: \{dependency_name}",
          )
        }
        dependencies.push({
          name: dependency_name,
          requirement: bootstrap_json_string(
            values.get(dependency_name),
            "dependency \{dependency_name} requirement",
          ),
        })
      }
    }
    _ => bootstrap_fail("package dependencies must be an object")
  }
  { manifest, name, version, dependencies, }
}

///|
fn bootstrap_collect_dew_sources(root : String, output : Array[String]) -> Unit {
  if !@fs.path_exists(root) {
    return
  }
  let entries = @fs.read_dir(root) catch { _ => [] }
  entries.sort()
  for entry in entries {
    let path = bootstrap_join(root, entry)
    if (@fs.is_dir(path) catch { _ => false }) {
      bootstrap_collect_dew_sources(path, output)
    } else if entry.has_suffix(".dew") {
      output.push(path)
    }
  }
}

///|
fn bootstrap_package_sources(
  package_ : BootstrapPackage,
  include_tests : Bool,
) -> Array[String] {
  let root = bootstrap_dirname(package_.manifest)
  let source_root = bootstrap_join(root, "src")
  let files : Array[String] = []
  if @fs.path_exists(source_root) &&
    (@fs.is_dir(source_root) catch { _ => false }) {
    bootstrap_collect_dew_sources(source_root, files)
  } else {
    let entries = @fs.read_dir(root) catch { _ => [] }
    entries.sort()
    for entry in entries {
      if entry.has_suffix(".dew") {
        files.push(bootstrap_join(root, entry))
      }
    }
  }
  let selected : Array[String] = []
  for file in files {
    if include_tests || !file.has_suffix("_test.dew") {
      selected.push(file)
    }
  }
  if selected.length() == 0 {
    bootstrap_fail("package \{package_.name} has no conventional .dew sources")
  }
  selected
}

///|
fn bootstrap_hash_u32(hash : @crypto.SHA256, value : Int) -> Unit {
  let bits = value.reinterpret_as_uint()
  let output = Buffer(size_hint=4)
  output.write_byte((bits & 0xffU).to_byte())
  output.write_byte(((bits >> 8) & 0xffU).to_byte())
  output.write_byte(((bits >> 16) & 0xffU).to_byte())
  output.write_byte(((bits >> 24) & 0xffU).to_byte())
  hash.update(output.to_bytes())
}

///|
fn bootstrap_package_integrity(package_ : BootstrapPackage) -> String {
  let hash = @crypto.SHA256::new()
  hash.update(b"DEW_PACKAGE_INTEGRITY_V1\x00")
  bootstrap_write_hash_string(hash, package_.name)
  bootstrap_write_hash_string(hash, package_.version)
  bootstrap_write_hash_string(
    hash,
    bootstrap_package_module_name(package_.name),
  )
  let root = bootstrap_dirname(package_.manifest)
  let files = bootstrap_package_sources(package_, true)
  for file in files {
    let logical = if file.has_prefix(root + "/") {
      file[root.length() + 1:].to_owned()
    } else {
      file
    }
    let bytes = @fs.read_file_to_bytes(file) catch {
      error => {
        bootstrap_fail(
          "cannot read package source \{file}: \{bootstrap_fs_error_message(error)}",
        )
        b""
      }
    }
    bootstrap_write_hash_string(hash, logical)
    bootstrap_hash_u32(hash, bytes.length())
    hash.update(bytes)
  }
  for dependency in package_.dependencies {
    bootstrap_write_hash_string(hash, dependency.name)
    bootstrap_write_hash_string(hash, dependency.requirement)
  }
  "sha256-" + @crypto.bytes_to_hex_string(hash.finalize())
}

///|
fn bootstrap_load_lockfile(
  path : String,
  package_root : String,
) -> Map[String, BootstrapLockedPackage] {
  let fields = bootstrap_read_json(path, "lockfile")
  match fields.get("lockfileVersion") {
    Some(Number(value, ..)) if value == 1.0 => ()
    _ => bootstrap_fail("lockfileVersion must be 1")
  }
  let result : Map[String, BootstrapLockedPackage] = Map([])
  match fields.get("packages") {
    Some(Array(entries)) =>
      for index, entry in entries {
        let package_fields = bootstrap_json_object(
          entry,
          "locked package \{index}",
        )
        let name = bootstrap_json_string(
          package_fields.get("name"),
          "locked package name",
        )
        let logical = bootstrap_json_string(
          package_fields.get("path"),
          "locked package path",
        )
        if result.contains(name) {
          bootstrap_fail("duplicate locked package: \{name}")
        }
        let manifest_path = bootstrap_normalize_path(
          bootstrap_join(package_root, logical),
        )
        let manifest = if manifest_path.has_suffix("dew.json") {
          manifest_path
        } else {
          bootstrap_join(manifest_path, "dew.json")
        }
        result[name] = {
          name,
          version: bootstrap_json_string(
            package_fields.get("version"),
            "locked package version",
          ),
          source: bootstrap_json_string(
            package_fields.get("source"),
            "locked package source",
          ),
          manifest,
          integrity: bootstrap_json_string(
            package_fields.get("integrity"),
            "locked package integrity",
          ),
          interface_fingerprint: bootstrap_json_string(
            package_fields.get("interface"),
            "locked package interface",
          ),
        }
      }
    _ => bootstrap_fail("lockfile packages must be an array")
  }
  result
}

///|
fn bootstrap_load_legacy_manifest(path : String) -> BootstrapManifest {
  let fields = bootstrap_read_json(path, "module manifest")
  let root = bootstrap_json_string(fields.get("root"), "module manifest root")
  let modules : Array[(String, Array[String])] = []
  match fields.get("modules") {
    Some(Array(entries)) =>
      for index, entry in entries {
        let module_fields = bootstrap_json_object(entry, "module \{index}")
        let name = bootstrap_json_string(
          module_fields.get("name"),
          "module name",
        )
        let files : Array[String] = []
        match module_fields.get("files") {
          Some(Array(values)) =>
            for value in values {
              let logical = bootstrap_json_string(Some(value), "module source")
              let source = bootstrap_normalize_path(
                bootstrap_join(bootstrap_dirname(path), logical),
              )
              if !@fs.path_exists(source) {
                bootstrap_fail(
                  "module manifest source does not exist: \{logical}",
                )
              }
              files.push(source)
            }
          _ => bootstrap_fail("module \{name} files must be an array")
        }
        modules.push((name, files))
      }
    _ => bootstrap_fail("module manifest modules must be an array")
  }
  { root, modules, dependency_key: "", expectations: [], }
}

///|
fn bootstrap_load_package_manifest(
  path : String,
  include_tests : Bool,
) -> BootstrapManifest {
  let root_package = bootstrap_load_package(path)
  let lock_path = bootstrap_join(
    bootstrap_dirname(root_package.manifest),
    "dew.lock",
  )
  let locked = if @fs.path_exists(lock_path) {
    bootstrap_load_lockfile(lock_path, bootstrap_dirname(root_package.manifest))
  } else {
    Map([])
  }
  let ordered : Array[(BootstrapPackage, BootstrapLockedPackage?)] = []
  let visiting : Map[String, Bool] = Map([])
  let visited : Map[String, Bool] = Map([])
  fn visit(
    package_ : BootstrapPackage,
    lock : BootstrapLockedPackage?,
    locked : Map[String, BootstrapLockedPackage],
    visiting : Map[String, Bool],
    visited : Map[String, Bool],
    ordered : Array[(BootstrapPackage, BootstrapLockedPackage?)],
  ) -> Unit {
    if visiting.contains(package_.name) {
      bootstrap_fail("dependency cycle at \{package_.name}")
    }
    if visited.contains(package_.name) {
      return
    }
    visiting[package_.name] = true
    for dependency in package_.dependencies {
      let dependency_lock = match locked.get(dependency.name) {
        Some(value) => value
        None => {
          bootstrap_fail(
            "dependency \{dependency.name} is missing from dew.lock",
          )
          abort("missing lock")
        }
      }
      let dependency_package = if @fs.path_exists(dependency_lock.manifest) {
        bootstrap_load_package(dependency_lock.manifest)
      } else {
        bootstrap_restore_package_artifact(dependency_lock)
      }
      let actual = bootstrap_package_integrity(dependency_package)
      if actual != dependency_lock.integrity {
        bootstrap_fail(
          "dependency integrity mismatch for \{dependency_lock.name}@\{dependency_lock.version}: expected \{dependency_lock.integrity}, got \{actual}",
        )
      }
      bootstrap_store_package_artifact(dependency_package, dependency_lock)
      visit(
        dependency_package,
        Some(dependency_lock),
        locked,
        visiting,
        visited,
        ordered,
      )
    }
    visiting.remove(package_.name)
    visited[package_.name] = true
    ordered.push((package_, lock))
  }
  visit(root_package, None, locked, visiting, visited, ordered)
  let modules : Array[(String, Array[String])] = []
  let expectations : Array[(String, String)] = []
  let dependency_hash = @crypto.SHA256::new()
  dependency_hash.update(b"DEW_DEPENDENCY_INTERFACE_KEY_V1\x00")
  for entry in ordered {
    let package_ = entry.0
    let lock = entry.1
    let module_name = bootstrap_package_module_name(package_.name)
    modules.push(
      (
        module_name,
        bootstrap_package_sources(
          package_,
          include_tests && package_.name == root_package.name,
        ),
      ),
    )
    match lock {
      Some(value) => {
        expectations.push((module_name, value.interface_fingerprint))
        for
          item in [
            value.name,
            value.version,
            value.source,
            value.integrity,
            value.interface_fingerprint,
          ] {
          bootstrap_write_hash_string(dependency_hash, item)
        }
      }
      None => ()
    }
  }
  expectations.sort_by(fn(left, right) { left.0.compare(right.0) })
  {
    root: bootstrap_package_module_name(root_package.name),
    modules,
    dependency_key: if root_package.dependencies.length() == 0 {
      ""
    } else {
      @crypto.bytes_to_hex_string(dependency_hash.finalize())
    },
    expectations,
  }
}

///|
fn bootstrap_load_manifest(
  path : String,
  include_tests : Bool,
) -> BootstrapManifest {
  let fields = bootstrap_read_json(path, "manifest")
  if fields.contains("name") ||
    fields.contains("version") ||
    fields.contains("dependencies") {
    bootstrap_load_package_manifest(path, include_tests)
  } else {
    bootstrap_load_legacy_manifest(path)
  }
}
