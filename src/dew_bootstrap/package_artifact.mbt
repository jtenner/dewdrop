///|
struct BootstrapArtifactReader {
  bytes : Bytes
  mut offset : Int
  mut error : String?
}

///|
fn BootstrapArtifactReader::read_u32(self : BootstrapArtifactReader) -> Int {
  if self.offset + 4 > self.bytes.length() {
    self.error = Some("truncated package artifact")
    return 0
  }
  let value = self.bytes[self.offset].to_uint() |
    (self.bytes[self.offset + 1].to_uint() << 8) |
    (self.bytes[self.offset + 2].to_uint() << 16) |
    (self.bytes[self.offset + 3].to_uint() << 24)
  self.offset += 4
  value.reinterpret_as_int()
}

///|
fn BootstrapArtifactReader::read_bytes(self : BootstrapArtifactReader) -> Bytes {
  let length = self.read_u32()
  if length < 0 ||
    length > 0x10000000 ||
    self.offset + length > self.bytes.length() {
    self.error = Some("invalid package artifact byte length")
    return b""
  }
  let value = self.bytes[self.offset:self.offset + length].to_owned()
  self.offset += length
  value
}

///|
fn BootstrapArtifactReader::read_string(
  self : BootstrapArtifactReader,
) -> String {
  @utf8.decode(self.read_bytes()) catch {
    _ => {
      self.error = Some("invalid package artifact UTF-8")
      ""
    }
  }
}

///|
fn bootstrap_artifact_write_bytes(output : Buffer, bytes : Bytes) -> Unit {
  let length = bytes.length().reinterpret_as_uint()
  output.write_byte((length & 0xffU).to_byte())
  output.write_byte(((length >> 8) & 0xffU).to_byte())
  output.write_byte(((length >> 16) & 0xffU).to_byte())
  output.write_byte(((length >> 24) & 0xffU).to_byte())
  output.write_bytes(bytes)
}

///|
fn bootstrap_artifact_write_string(output : Buffer, value : String) -> Unit {
  bootstrap_artifact_write_bytes(output, @utf8.encode(value))
}

///|
fn bootstrap_package_artifact_key(lock : BootstrapLockedPackage) -> String {
  let hash = @crypto.SHA256::new()
  hash.update(b"DEW_PACKAGE_ARTIFACT_KEY_V1\x00")
  for
    value in [
      lock.name,
      lock.version,
      lock.source,
      lock.integrity,
      lock.interface_fingerprint,
      bootstrap_package_module_name(lock.name),
    ] {
    bootstrap_write_hash_string(hash, value)
  }
  @crypto.bytes_to_hex_string(hash.finalize())
}

///|
fn bootstrap_package_artifact_path(lock : BootstrapLockedPackage) -> String {
  bootstrap_join(
    bootstrap_join(
      bootstrap_cache_root(
        @sys.get_env_var("DEW_REPOSITORY_ROOT").unwrap_or("."),
      ),
      "packages",
    ),
    "v1-" + bootstrap_package_artifact_key(lock) + ".dpa",
  )
}

///|
fn bootstrap_store_package_artifact(
  package_ : BootstrapPackage,
  lock : BootstrapLockedPackage,
) -> Unit {
  let path = bootstrap_package_artifact_path(lock)
  if @fs.path_exists(path) {
    return
  }
  let body = Buffer()
  body.write_bytes(b"DEWPKG1\x00")
  for
    value in [
      lock.name,
      lock.version,
      lock.source,
      lock.integrity,
      lock.interface_fingerprint,
    ] {
    bootstrap_artifact_write_string(body, value)
  }
  bootstrap_hash_u32_buffer(body, package_.dependencies.length())
  for dependency in package_.dependencies {
    bootstrap_artifact_write_string(body, dependency.name)
    bootstrap_artifact_write_string(body, dependency.requirement)
  }
  let root = bootstrap_dirname(package_.manifest)
  let files = bootstrap_package_sources(package_, true)
  bootstrap_hash_u32_buffer(body, files.length())
  for file in files {
    let logical = if file.has_prefix(root + "/") {
      file[root.length() + 1:].to_owned()
    } else {
      file
    }
    bootstrap_artifact_write_string(body, logical)
    let bytes = @fs.read_file_to_bytes(file) catch {
      error => {
        bootstrap_fail(
          "cannot read package source \{file}: \{bootstrap_fs_error_message(error)}",
        )
        b""
      }
    }
    bootstrap_artifact_write_bytes(body, bytes)
  }
  let payload = body.to_bytes()
  let output = Buffer(size_hint=payload.length() + 32)
  output.write_bytes(payload)
  for byte in @crypto.sha256(payload) {
    output.write_byte(byte)
  }
  bootstrap_atomic_write(path, output.to_bytes())
}

///|
fn bootstrap_hash_u32_buffer(output : Buffer, value : Int) -> Unit {
  let bits = value.reinterpret_as_uint()
  output.write_byte((bits & 0xffU).to_byte())
  output.write_byte(((bits >> 8) & 0xffU).to_byte())
  output.write_byte(((bits >> 16) & 0xffU).to_byte())
  output.write_byte(((bits >> 24) & 0xffU).to_byte())
}

///|
fn bootstrap_restore_package_artifact(
  lock : BootstrapLockedPackage,
) -> BootstrapPackage {
  let path = bootstrap_package_artifact_path(lock)
  if !@fs.path_exists(path) {
    bootstrap_fail(
      "locked package source is unavailable and no installed artifact exists for \{lock.name}@\{lock.version}: \{path}",
    )
  }
  let encoded = @fs.read_file_to_bytes(path) catch {
    error => {
      bootstrap_fail(
        "cannot read installed package artifact \{path}: \{bootstrap_fs_error_message(error)}",
      )
      b""
    }
  }
  if encoded.length() < 40 {
    bootstrap_fail("unsupported or truncated installed package artifact")
  }
  let payload = encoded[0:encoded.length() - 32].to_owned()
  let digest = @crypto.sha256(payload)
  for index in 0..<32 {
    if encoded[encoded.length() - 32 + index] != digest[index] {
      bootstrap_fail("installed package artifact checksum mismatch")
    }
  }
  if payload[0:8] != b"DEWPKG1\x00" {
    bootstrap_fail("unsupported installed package artifact magic")
  }
  let reader : BootstrapArtifactReader = {
    bytes: payload,
    offset: 8,
    error: None,
  }
  let name = reader.read_string()
  let version = reader.read_string()
  let source = reader.read_string()
  let integrity = reader.read_string()
  let interface_ = reader.read_string()
  if name != lock.name ||
    version != lock.version ||
    source != lock.source ||
    integrity != lock.integrity ||
    interface_ != lock.interface_fingerprint {
    bootstrap_fail(
      "installed package artifact provenance mismatch for \{lock.name}",
    )
  }
  let dependencies : Array[BootstrapDependencyRequest] = []
  let dependency_count = reader.read_u32()
  for _ in 0..<dependency_count {
    dependencies.push({
      name: reader.read_string(),
      requirement: reader.read_string(),
    })
  }
  let file_count = reader.read_u32()
  let files : Array[(String, Bytes)] = []
  for _ in 0..<file_count {
    files.push((reader.read_string(), reader.read_bytes()))
  }
  if reader.error is Some(_) || reader.offset != payload.length() {
    bootstrap_fail("invalid installed package artifact")
  }
  let package_root = bootstrap_dirname(lock.manifest)
  if @fs.path_exists(package_root) {
    let entries = @fs.read_dir(package_root) catch { _ => [] }
    if entries.length() > 0 {
      bootstrap_fail(
        "cannot restore installed package artifact into nonempty path \{package_root}",
      )
    }
    @fs.remove_dir(package_root) catch {
      _ => ()
    }
  }
  let staging = bootstrap_join(
    bootstrap_dirname(package_root),
    "." +
    bootstrap_basename(package_root) +
    ".dew-artifact-" +
    bootstrap_package_artifact_key(lock),
  )
  ignore(bootstrap_remove_tree(staging))
  bootstrap_ensure_directory(staging)
  let dependency_fields : Map[String, Json] = Map([])
  for dependency in dependencies {
    dependency_fields[dependency.name] = Json::string(dependency.requirement)
  }
  let manifest_fields : Map[String, Json] = Map([])
  manifest_fields["name"] = Json::string(lock.name)
  manifest_fields["version"] = Json::string(lock.version)
  manifest_fields["dependencies"] = Json::object(dependency_fields)
  @fs.write_string_to_file(
    bootstrap_join(staging, "dew.json"),
    Json::object(manifest_fields).stringify() + "\n",
  ) catch {
    error =>
      bootstrap_fail(
        "cannot restore package manifest: \{bootstrap_fs_error_message(error)}",
      )
  }
  for file in files {
    let destination = bootstrap_join(staging, file.0)
    bootstrap_ensure_directory(bootstrap_dirname(destination))
    @fs.write_bytes_to_file(destination, file.1) catch {
      error =>
        bootstrap_fail(
          "cannot restore package source: \{bootstrap_fs_error_message(error)}",
        )
    }
  }
  match bootstrap_rename(staging, package_root) {
    Ok(_) => ()
    Err(error) => bootstrap_fail(error)
  }
  let package_ = bootstrap_load_package(lock.manifest)
  if bootstrap_package_integrity(package_) != lock.integrity {
    bootstrap_fail(
      "restored installed package artifact failed integrity for \{lock.name}",
    )
  }
  package_
}
