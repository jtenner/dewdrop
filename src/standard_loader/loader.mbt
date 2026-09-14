///|
fn standard_loader_fs_error_message(error : @fs.IOError) -> String {
  match error {
    @fs.IOError(message) => message
  }
}

///|
fn join_standard_path(root : String, logical : String) -> String {
  if root == "" || root == "." {
    logical
  } else if root.has_suffix("/") {
    root + logical
  } else {
    root + "/" + logical
  }
}

///|
fn bootstrap_standard_library_sources() -> @semantic.StandardLibrarySources {
  let files : Array[@semantic.ManifestFile] = []
  for path in @standard_sources.standard_source_paths() {
    let source = match @standard_sources.bootstrap_standard_source(path) {
      Some(value) => value
      None => abort("bootstrap standard source registry is incomplete")
    }
    files.push(@semantic.ManifestFile::new(path, source))
  }
  @semantic.StandardLibrarySources::new(files)
}

///|
pub struct StandardLibraryLoad {
  sources : @semantic.StandardLibrarySources
  fingerprint : String
  dependency_fingerprint : String
  cacheable : Bool
}

///|
pub fn StandardLibraryLoad::bootstrap() -> StandardLibraryLoad {
  {
    sources: bootstrap_standard_library_sources(),
    fingerprint: "",
    dependency_fingerprint: @sys.get_env_var("DEW_DEPENDENCY_INTERFACE_KEY").unwrap_or(
      "",
    ),
    cacheable: false,
  }
}

///|
fn fingerprint_write_u32(output : Buffer, value : UInt) -> Unit {
  output.write_byte((value & 0xffU).to_byte())
  output.write_byte(((value >> 8) & 0xffU).to_byte())
  output.write_byte(((value >> 16) & 0xffU).to_byte())
  output.write_byte(((value >> 24) & 0xffU).to_byte())
}

///|
fn fingerprint_write_bytes(output : Buffer, value : Bytes) -> Unit {
  fingerprint_write_u32(output, value.length().reinterpret_as_uint())
  output.write_bytes(value)
}

///|
fn fingerprint_write_string(output : Buffer, value : String) -> Unit {
  let bytes = Buffer()
  bytes.write_string_utf8(value)
  fingerprint_write_bytes(output, bytes.to_bytes())
}

///|
fn load_paths_with_fingerprint(
  root : String,
  paths : Array[String],
) -> Result[StandardLibraryLoad, String] {
  load_standard_source_closure(paths, fn(logical) {
    let physical = join_standard_path(root, logical)
    let source = @fs.read_file_to_bytes(physical) catch {
      error =>
        return Err(
          "cannot read standard source \{physical}: \{standard_loader_fs_error_message(error)}",
        )
    }
    Ok(source)
  })
}

///|
fn load_standard_source_closure(
  paths : Array[String],
  read : (String) -> Result[Bytes, String],
) -> Result[StandardLibraryLoad, String] {
  let files : Array[@semantic.ManifestFile] = []
  let fingerprint = Buffer()
  fingerprint.write_bytes(
    b"DEW_STD_FROZEN_INTERFACE_KEY_V1_ARRAY_LITERAL_CALLS\x00",
  )
  let work : Array[String] = []
  let seen : Map[String, Bool] = Map([])
  for path in paths {
    if !seen.contains(path) {
      seen[path] = true
      work.push(path)
    }
  }
  let mut cursor = 0
  while cursor < work.length() {
    let logical = work[cursor]
    cursor += 1
    let source = match read(logical) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    let file = @semantic.ManifestFile::new(logical, source)
    files.push(file)
    fingerprint_write_string(fingerprint, logical)
    fingerprint_write_bytes(fingerprint, source)
    let dependency = @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("dependency", [file]),
    ])
    for
      child in @semantic.direct_standard_library_source_paths(dependency, false) {
      if !seen.contains(child) {
        seen[child] = true
        work.push(child)
      }
    }
  }
  Ok({
    sources: @semantic.StandardLibrarySources::new(files),
    fingerprint: @crypto.bytes_to_hex_string(
      @crypto.sha256(fingerprint.to_bytes()),
    ),
    dependency_fingerprint: @sys.get_env_var("DEW_DEPENDENCY_INTERFACE_KEY").unwrap_or(
      "",
    ),
    cacheable: true,
  })
}

///|
fn load_paths(
  root : String,
  paths : Array[String],
) -> Result[@semantic.StandardLibrarySources, String] {
  match load_paths_with_fingerprint(root, paths) {
    Ok(loaded) => Ok(loaded.sources)
    Err(error) => Err(error)
  }
}

///|
/// Loads every path in Dew's fixed standard-package registry. The registry is
/// compiler-owned and ordered; this function never enumerates a directory.
pub fn load(root : String) -> Result[@semantic.StandardLibrarySources, String] {
  load_paths(root, @semantic.standard_library_source_paths())
}

///|
/// Loads only the deterministic standard source subset selected by a manifest's
/// leading import preambles and implicit default-preamble policy.
pub fn load_for_manifest(
  root : String,
  manifest : @semantic.ProgramManifest,
  default_preamble : Bool,
) -> Result[@semantic.StandardLibrarySources, String] {
  load_paths(
    root,
    @semantic.direct_standard_library_source_paths(manifest, default_preamble),
  )
}

///|
pub fn load_for_manifest_with_fingerprint(
  root : String,
  manifest : @semantic.ProgramManifest,
  default_preamble : Bool,
) -> Result[StandardLibraryLoad, String] {
  load_paths_with_fingerprint(
    root,
    @semantic.direct_standard_library_source_paths(manifest, default_preamble),
  )
}

///|
/// Uses `DEW_STD_ROOT` when present and otherwise resolves the repository or
/// installation root as the current directory. `DEW_BOOTSTRAP_STD=1` selects
/// generated bootstrap providers for compiler/bootstrap tests.
pub fn load_default() -> Result[@semantic.StandardLibrarySources, String] {
  if @sys.get_env_var("DEW_BOOTSTRAP_STD") == Some("1") {
    return Ok(bootstrap_standard_library_sources())
  }
  load(@sys.get_env_var("DEW_STD_ROOT").unwrap_or("."))
}

///|
pub fn load_default_for_manifest(
  manifest : @semantic.ProgramManifest,
  default_preamble : Bool,
) -> Result[@semantic.StandardLibrarySources, String] {
  if @sys.get_env_var("DEW_BOOTSTRAP_STD") == Some("1") {
    return Ok(bootstrap_standard_library_sources())
  }
  load_for_manifest(
    @sys.get_env_var("DEW_STD_ROOT").unwrap_or("."),
    manifest,
    default_preamble,
  )
}

///|
pub fn load_default_for_manifest_with_fingerprint(
  manifest : @semantic.ProgramManifest,
  default_preamble : Bool,
) -> Result[StandardLibraryLoad, String] {
  if @sys.get_env_var("DEW_BOOTSTRAP_STD") == Some("1") {
    return Ok({
      sources: bootstrap_standard_library_sources(),
      fingerprint: "",
      dependency_fingerprint: @sys.get_env_var("DEW_DEPENDENCY_INTERFACE_KEY").unwrap_or(
        "",
      ),
      cacheable: false,
    })
  }
  load_for_manifest_with_fingerprint(
    @sys.get_env_var("DEW_STD_ROOT").unwrap_or("."),
    manifest,
    default_preamble,
  )
}
