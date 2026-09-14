///|
pub(all) enum ParseEventCacheStatus {
  ParseEventCacheWasDisabled(Int)
  ParseEventCacheWasUsed(Int, Int)
} derive(Eq, Debug)

///|
pub fn ParseEventCacheStatus::label(self : ParseEventCacheStatus) -> String {
  match self {
    ParseEventCacheWasDisabled(files) => "disabled (parsed \{files})"
    ParseEventCacheWasUsed(hits, misses) => "hits \{hits}, misses \{misses}"
  }
}

///|
pub struct PreparedParseEventManifest {
  manifest : @semantic.ProgramManifest
  status : ParseEventCacheStatus
}

///|
pub struct PreparedParseEventInputs {
  manifest : @semantic.ProgramManifest
  standard_sources : @semantic.StandardLibrarySources
  status : ParseEventCacheStatus
}

///|
priv enum ParseEventFilePreparation {
  ParseEventAlreadyPrepared
  ParseEventCacheHit
  ParseEventCacheMiss
}

///|
fn parse_event_cache_enabled() -> Bool {
  cache_platform_supported() &&
  @sys.get_env_var("DEW_PARSE_EVENT_CACHE").unwrap_or("1") != "0"
}

///|
fn parse_event_cache_write_string(output : Buffer, value : String) -> Unit {
  let bytes = @utf8.encode(value)
  let length = bytes.length().reinterpret_as_uint()
  output.write_byte((length & 0xffU).to_byte())
  output.write_byte(((length >> 8) & 0xffU).to_byte())
  output.write_byte(((length >> 16) & 0xffU).to_byte())
  output.write_byte(((length >> 24) & 0xffU).to_byte())
  output.write_bytes(bytes)
}

///|
fn parse_event_cache_key_digest(
  owner_path : String,
  file : @semantic.ManifestFile,
  source_digest : FixedArray[Byte],
) -> FixedArray[Byte] {
  let output = Buffer()
  output.write_bytes(b"DEW_PARSE_EVENT_KEY_V1_ARRAY_LITERAL_CALLS\x00")
  parse_event_cache_write_string(output, owner_path)
  parse_event_cache_write_string(output, file.path)
  for byte in source_digest {
    output.write_byte(byte)
  }
  @crypto.sha256(output.to_bytes())
}

///|
fn parse_event_cache_root() -> String {
  @sys.get_env_var("DEW_CACHE_DIR").unwrap_or(".dew/cache")
}

///|
fn parse_event_cache_join(root : String, child : String) -> String {
  if root.has_suffix("/") {
    root + child
  } else {
    root + "/" + child
  }
}

///|
fn ensure_parse_event_cache_directory(path : String) -> Result[Unit, String] {
  if @fs.path_exists(path) {
    let directory = @fs.is_dir(path) catch {
      error =>
        return Err(
          "cannot inspect parse-event cache directory \{path}: \{standard_loader_fs_error_message(error)}",
        )
    }
    if !directory {
      return Err("parse-event cache path is not a directory: \{path}")
    }
    return Ok(())
  }
  @fs.create_dir(path) catch {
    error =>
      return Err(
        "cannot create parse-event cache directory \{path}: \{standard_loader_fs_error_message(error)}",
      )
  }
  Ok(())
}

///|
fn ensure_parse_event_cache_root(path : String) -> Result[Unit, String] {
  if path == ".dew/cache" {
    match ensure_parse_event_cache_directory(".dew") {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  ensure_parse_event_cache_directory(path)
}

///|
fn parse_event_cache_file(key_digest : FixedArray[Byte]) -> String {
  parse_event_cache_join(
    parse_event_cache_join(parse_event_cache_root(), "parse-events"),
    "v1-" + @crypto.bytes_to_hex_string(key_digest) + ".dpe",
  )
}

///|
fn parse_event_pack_owner(owner_path : String, file_path : String) -> String {
  "file:" + owner_path + ":" + file_path
}

///|
fn parse_event_pack_context(
  owner_path : String,
  file : @semantic.ManifestFile,
) -> FixedArray[Byte] {
  let output = Buffer()
  output.write_bytes(b"DEW_PARSE_EVENT_PACK_CONTEXT_V1_ARRAY_LITERAL_CALLS\x00")
  parse_event_cache_write_string(output, owner_path)
  parse_event_cache_write_string(output, file.path)
  @cache_binary.blake3(output.to_bytes())
}

///|
fn lookup_parse_event_cache(
  owner_path : String,
  file : @semantic.ManifestFile,
  pack? : CompilationCachePack? = None,
) -> Result[Array[@parser.ParseEvent]?, String] {
  match pack {
    Some(session) if session.enabled => {
      let payload = session.lookup(
        cache_pack_parse_event_kind,
        1U,
        parse_event_pack_owner(owner_path, file.path),
        @cache_binary.blake3(file.source),
        parse_event_pack_context(owner_path, file),
      )
      match payload {
        Err(error) => return Err("corrupt compilation cache pack: \{error}")
        Ok(None) => return Ok(None)
        Ok(Some(bytes)) =>
          match @parser.deserialize_parse_events(bytes) {
            Ok(value) => return Ok(Some(value))
            Err(error) =>
              return Err("corrupt parse-event cache pack entry: \{error}")
          }
      }
    }
    _ => ()
  }
  let source_digest = @crypto.sha256(file.source)
  let key_digest = parse_event_cache_key_digest(owner_path, file, source_digest)
  let path = parse_event_cache_file(key_digest)
  if !@fs.path_exists(path) {
    return Ok(None)
  }
  let bytes = @fs.read_file_to_bytes(path) catch {
    error =>
      return Err(
        "cannot read parse-event cache \{path}: \{standard_loader_fs_error_message(error)}",
      )
  }
  let payload = match
    unwrap_parse_event_cache_payload(bytes, key_digest, source_digest) {
    Ok(value) => value
    Err(error) => return Err("corrupt parse-event cache \{path}: \{error}")
  }
  let events = match @parser.deserialize_parse_events(payload) {
    Ok(value) => value
    Err(error) => return Err("corrupt parse-event cache \{path}: \{error}")
  }
  Ok(Some(events))
}

///|
fn store_parse_event_cache(
  owner_path : String,
  file : @semantic.ManifestFile,
  events : Array[@parser.ParseEvent],
  pack? : CompilationCachePack? = None,
) -> Result[Unit, String] {
  let payload = match @parser.serialize_parse_events(events) {
    Ok(value) => value
    Err(error) => return Err("cannot serialize parse-event cache: \{error}")
  }
  match pack {
    Some(session) if session.enabled =>
      return session.store(
        cache_pack_parse_event_kind,
        1U,
        0U,
        0U,
        parse_event_pack_owner(owner_path, file.path),
        @cache_binary.blake3(file.source),
        parse_event_pack_context(owner_path, file),
        payload,
      )
    _ => ()
  }
  let source_digest = @crypto.sha256(file.source)
  let key_digest = parse_event_cache_key_digest(owner_path, file, source_digest)
  let envelope = match
    wrap_parse_event_cache_payload(key_digest, source_digest, payload) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let root = parse_event_cache_root()
  match ensure_parse_event_cache_root(root) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let directory = parse_event_cache_join(root, "parse-events")
  match ensure_parse_event_cache_directory(directory) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let path = parse_event_cache_file(key_digest)
  let path_bytes = @utf8.encode(path)
  let result = cache_platform_atomic_write(
    path_bytes,
    path_bytes.length(),
    envelope,
  )
  if result != 0 {
    return Err(
      "cannot atomically write parse-event cache \{path}: errno \{-result}",
    )
  }
  Ok(())
}

///|
fn prepare_manifest_file_parse_events(
  owner_path : String,
  file : @semantic.ManifestFile,
  enabled : Bool,
  pack? : CompilationCachePack? = None,
) -> Result[(@semantic.ManifestFile, ParseEventFilePreparation), String] {
  match file.parse_events {
    Some(_) => return Ok((file, ParseEventAlreadyPrepared))
    None => ()
  }
  if enabled {
    match lookup_parse_event_cache(owner_path, file, pack~) {
      Err(error) => return Err(error)
      Ok(Some(events)) =>
        return Ok((file.with_parse_events(events), ParseEventCacheHit))
      Ok(None) => ()
    }
  }
  let events = @parser.parse_bytes(file.source).to_array()
  if enabled {
    match store_parse_event_cache(owner_path, file, events, pack~) {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
  }
  Ok((file.with_parse_events(events), ParseEventCacheMiss))
}

///|
fn parse_event_cache_status_counts(
  status : ParseEventCacheStatus,
) -> (Int, Int) {
  match status {
    ParseEventCacheWasUsed(hits, misses) => (hits, misses)
    ParseEventCacheWasDisabled(parsed) => (0, parsed)
  }
}

///|
fn record_parse_event_preparation(
  preparation : ParseEventFilePreparation,
  hits : Ref[Int],
  misses : Ref[Int],
) -> Unit {
  match preparation {
    ParseEventAlreadyPrepared => ()
    ParseEventCacheHit => hits.val += 1
    ParseEventCacheMiss => misses.val += 1
  }
}

///|
/// Prepares workspace files before standard-library selection so leading import
/// scans and semantic collection consume the same event arrays.
pub fn prepare_manifest_parse_event_cache(
  manifest : @semantic.ProgramManifest,
  pack? : CompilationCachePack? = None,
) -> Result[PreparedParseEventManifest, String] {
  let enabled = parse_event_cache_enabled()
  let modules : Array[@semantic.ManifestModule] = []
  let hits = Ref(0)
  let misses = Ref(0)
  for module_ in manifest.modules {
    let files : Array[@semantic.ManifestFile] = []
    for file in module_.files {
      let prepared = match
        prepare_manifest_file_parse_events(module_.path, file, enabled, pack~) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      files.push(prepared.0)
      record_parse_event_preparation(prepared.1, hits, misses)
    }
    modules.push(@semantic.ManifestModule::new(module_.path, files))
  }
  Ok({
    manifest: @semantic.ProgramManifest::new(modules),
    status: if enabled {
      ParseEventCacheWasUsed(hits.val, misses.val)
    } else {
      ParseEventCacheWasDisabled(misses.val)
    },
  })
}

///|
/// Parses every selected workspace and standard-library source at most once in
/// one compiler process and reuses or publishes versioned content artifacts.
pub fn prepare_program_parse_event_cache(
  manifest : @semantic.ProgramManifest,
  loaded : StandardLibraryLoad,
  default_preamble : Bool,
  prior_status? : ParseEventCacheStatus = ParseEventCacheWasUsed(0, 0),
  pack? : CompilationCachePack? = None,
) -> Result[PreparedParseEventInputs, String] {
  let enabled = parse_event_cache_enabled()
  let (prior_hits, prior_misses) = parse_event_cache_status_counts(prior_status)
  let hits = Ref(prior_hits)
  let misses = Ref(prior_misses)
  let modules : Array[@semantic.ManifestModule] = []
  for module_ in manifest.modules {
    let files : Array[@semantic.ManifestFile] = []
    for file in module_.files {
      let prepared = match
        prepare_manifest_file_parse_events(module_.path, file, enabled, pack~) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      files.push(prepared.0)
      record_parse_event_preparation(prepared.1, hits, misses)
    }
    modules.push(@semantic.ManifestModule::new(module_.path, files))
  }
  let prepared_manifest = @semantic.ProgramManifest::new(modules)
  let required = @semantic.required_standard_library_source_paths(
    prepared_manifest,
    default_preamble,
    sources=Some(loaded.sources),
  )
  let required_lookup : Map[String, Bool] = Map::default()
  for path in required {
    required_lookup[path] = true
  }
  let standard_events : Array[Array[@parser.ParseEvent]?] = []
  for index, path in loaded.sources.paths {
    if required_lookup.contains(path) {
      let file = @semantic.ManifestFile::new(
        path,
        loaded.sources.sources[index],
      )
      let prepared = match
        prepare_manifest_file_parse_events("dew.std", file, enabled, pack~) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      standard_events.push(prepared.0.parse_events)
      record_parse_event_preparation(prepared.1, hits, misses)
    } else {
      standard_events.push(None)
    }
  }
  Ok({
    manifest: prepared_manifest,
    standard_sources: loaded.sources.with_parse_events(standard_events),
    status: if enabled {
      ParseEventCacheWasUsed(hits.val, misses.val)
    } else {
      ParseEventCacheWasDisabled(misses.val)
    },
  })
}
