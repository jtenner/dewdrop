///|
/// One portable expansion artifact. A new session can use snapshot() from an
/// earlier process. No interpreter values, cells or checked handles are saved.
pub struct CompilerTransformCache {
  identity : String
  mut saved : Bytes
  mut pending : (FixedArray[Byte], Bytes)?
  mut state : String
} derive(Eq, Debug)

///|
pub fn CompilerTransformCache::new(
  compiler_identity : String,
  prior_bytes~ : Bytes = b"",
) -> CompilerTransformCache {
  {
    identity: compiler_identity,
    saved: prior_bytes,
    pending: None,
    state: "unused",
  }
}

///|
pub fn CompilerTransformCache::snapshot(self : CompilerTransformCache) -> Bytes {
  self.saved
}

///|
pub fn CompilerTransformCache::status(self : CompilerTransformCache) -> String {
  self.state
}

///|
pub fn CompilerPipelineOptions::with_transform_cache(
  self : CompilerPipelineOptions,
  cache : CompilerTransformCache,
) -> CompilerPipelineOptions {
  { ..self, transform_cache: Some(cache), }
}

///|
fn compiler_accept_transform_cache(options : CompilerPipelineOptions) -> Unit {
  if options.transform_cache is Some(cache) && cache.pending is Some((_, bytes)) {
    cache.saved = bytes
    cache.pending = None
  }
}

///|
fn compiler_validate_pending_transform_cache(
  options : CompilerPipelineOptions,
  program : @semantic.CollectedProgram,
  analyzed : @semantic.AnalyzedProgramSemantics,
  lowering : @semantic.PlannedProgramLowering,
  link : @semantic.PlannedProgramWasmGCLink,
) -> Unit {
  if options.transform_cache is Some(cache) && cache.pending is Some(_) {
    if @semantic.collect_compiler_source_diagnostics(
        program, analyzed, lowering, link,
      ).any(diagnostic => diagnostic.severity is @semantic.CompilerError) {
      cache.pending = None
    }
  }
}

///|
fn compiler_transform_cache_status(options : CompilerPipelineOptions) -> String {
  match options.transform_cache {
    Some(cache) => cache.status()
    None => "disabled"
  }
}

///|
fn compiler_open_transform_cache(
  manifest : @semantic.ProgramManifest,
  sources : @semantic.StandardLibrarySources,
  options : CompilerPipelineOptions,
  pack : @standard_loader.CompilationCachePack?,
) -> (CompilerPipelineOptions, FixedArray[Byte]?) {
  if options.transform_cache is Some(_) ||
    @sys.get_env_var("DEW_TRANSFORM_CACHE").unwrap_or("1") == "0" {
    return (options, None)
  }
  let pack = match pack {
    Some(value) if value.enabled => value
    _ => return (options, None)
  }
  let identity = @sys.get_env_var("DEW_COMPILER_FINGERPRINT").unwrap_or("")
  if !transform_cache_inputs_eligible(
      manifest,
      @semantic.ProgramManifest::new([]),
      sources,
      identity,
    ) {
    return (options, None)
  }
  let key = compiler_transform_cache_key(
    manifest,
    @semantic.ProgramManifest::new([]),
    sources,
    options,
    identity,
  )
  let prior = match
    pack.lookup(
      @standard_loader.cache_pack_transform_kind, 1U, "transform-result", key, key,
    ) {
    Ok(Some(bytes)) => bytes
    // A broken transform entry is a miss. It never supplies partial output.
    Ok(None) | Err(_) => b""
  }
  (
    options.with_transform_cache(
      CompilerTransformCache::new(identity, prior_bytes=prior),
    ),
    Some(key),
  )
}

///|
fn compiler_store_transform_cache(
  options : CompilerPipelineOptions,
  pack : @standard_loader.CompilationCachePack?,
) -> Result[Unit, String] {
  match (options.transform_cache, pack) {
    (Some(cache), Some(pack)) =>
      match cache.pending {
        Some((key, bytes)) =>
          pack.store(
            @standard_loader.cache_pack_transform_kind, 1U, 0U, 3U, "transform-result",
            key, key, bytes,
          )
        None => Ok(())
      }
    _ => Ok(())
  }
}

///|
fn transform_cache_u32(out : Buffer, value : UInt32) -> Unit {
  for shift in [0, 8, 16, 24] {
    out.write_byte(((value >> shift) & 255U).to_byte())
  }
}

///|
fn transform_cache_string(out : Buffer, value : String) -> Unit {
  let bytes = @utf8.encode(value)
  transform_cache_u32(out, bytes.length().reinterpret_as_uint())
  out.write_bytes(bytes)
}

///|
fn transform_cache_digest(out : Buffer, digest : FixedArray[Byte]) -> Unit {
  for byte in digest {
    out.write_byte(byte)
  }
}

///|
fn transform_cache_file_digest(
  path : String,
  source : Bytes,
) -> FixedArray[Byte] {
  let out = Buffer()
  out.write_bytes(b"DEW_TRANSFORM_FILE_V1\x00")
  transform_cache_string(out, path)
  transform_cache_u32(out, source.length().reinterpret_as_uint())
  transform_cache_digest(out, @cache_binary.blake3(source))
  @cache_binary.blake3(out.to_bytes())
}

///|
fn transform_cache_manifest_digest(
  manifest : @semantic.ProgramManifest,
) -> FixedArray[Byte] {
  let graph = Buffer()
  graph.write_bytes(b"DEW_TRANSFORM_GRAPH_V1\x00")
  transform_cache_u32(graph, manifest.modules.length().reinterpret_as_uint())
  for module_ in manifest.modules {
    let node = Buffer()
    transform_cache_string(node, module_.path)
    transform_cache_u32(node, module_.files.length().reinterpret_as_uint())
    for file in module_.files {
      transform_cache_digest(
        node,
        transform_cache_file_digest(file.path, file.source),
      )
    }
    transform_cache_digest(graph, @cache_binary.blake3(node.to_bytes()))
  }
  @cache_binary.blake3(graph.to_bytes())
}

///|
fn compiler_transform_cache_key(
  manifest : @semantic.ProgramManifest,
  pool : @semantic.ProgramManifest,
  sources : @semantic.StandardLibrarySources,
  options : CompilerPipelineOptions,
  identity : String,
) -> FixedArray[Byte] {
  let key = Buffer()
  key.write_bytes(b"DEW_TRANSFORM_NATIVE_RESULT_V1\x00")
  transform_cache_string(key, identity)
  for shift in [0, 8, 16, 24, 32, 40, 48, 56] {
    key.write_byte(((options.module_id_base >> shift) & 255UL).to_byte())
  }
  transform_cache_u32(key, options.root_module_index.reinterpret_as_uint())
  transform_cache_u32(key, if options.default_preamble { 1U } else { 0U })
  transform_cache_u32(
    key,
    if options.planning_mode is CompilerTestPlanning {
      1U
    } else {
      0U
    },
  )
  transform_cache_digest(key, transform_cache_manifest_digest(manifest))
  transform_cache_digest(key, transform_cache_manifest_digest(pool))
  transform_cache_u32(key, sources.paths.length().reinterpret_as_uint())
  if sources.paths.length() != sources.sources.length() {
    abort("transform cache invariant: standard source arrays must agree")
  }
  for index, path in sources.paths {
    transform_cache_digest(
      key,
      transform_cache_file_digest(path, sources.sources[index]),
    )
  }
  let api = Buffer()
  for module_ in @transforms.transform_library_sources() {
    transform_cache_string(api, module_.path)
    transform_cache_u32(api, module_.files.length().reinterpret_as_uint())
    for file in module_.files {
      transform_cache_digest(
        api,
        transform_cache_file_digest(file.path, file.source),
      )
    }
  }
  transform_cache_digest(key, @cache_binary.blake3(api.to_bytes()))
  @cache_binary.blake3(key.to_bytes())
}

///|
/// The artifact is bounded independently of the compiler's source request.
/// Large results compile normally and simply do not replace the saved entry.
fn transform_cache_encode(
  key : FixedArray[Byte],
  manifest : @semantic.ProgramManifest,
  reports : Array[@transforms.TransformReport],
) -> Bytes? {
  if manifest.modules.length() > 1024 || reports.length() > 65536 {
    return None
  }
  let mut size = 8UL
  let mut files = 0
  for module_ in manifest.modules {
    let name = @utf8.encode(module_.path)
    if name.length() == 0 ||
      name.length() > 255 ||
      module_.files.is_empty() ||
      module_.files.length() > 4096 {
      return None
    }
    size += 8UL + name.length().to_uint64()
    files += module_.files.length()
    if files > 65536 {
      return None
    }
    for file in module_.files {
      let path = @utf8.encode(file.path)
      if path.length() == 0 ||
        path.length() > 4096 ||
        file.source.length() > 16777216 {
        return None
      }
      size += 12UL +
        path.length().to_uint64() +
        file.source.length().to_uint64()
    }
  }
  for report in reports {
    for
      text in [
        report.module_name,
        report.file_name,
        report.function_name,
        report.transform_name,
      ] {
      let length = @utf8.encode(text).length()
      if length > 4096 {
        return None
      }
      size += 4UL + length.to_uint64()
    }
    size += 12UL
  }
  if size + 76UL > 16777216UL {
    return None
  }
  let payload = Buffer(size_hint=size.to_int())
  transform_cache_u32(payload, manifest.modules.length().reinterpret_as_uint())
  for module_ in manifest.modules {
    transform_cache_string(payload, module_.path)
    transform_cache_u32(payload, module_.files.length().reinterpret_as_uint())
    for file in module_.files {
      transform_cache_string(payload, file.path)
      transform_cache_u32(payload, file.source.length().reinterpret_as_uint())
      payload.write_bytes(file.source)
      transform_cache_u32(payload, 0U)
    }
  }
  transform_cache_u32(payload, reports.length().reinterpret_as_uint())
  for report in reports {
    for
      text in [
        report.module_name,
        report.file_name,
        report.function_name,
        report.transform_name,
      ] {
      transform_cache_string(payload, text)
    }
    transform_cache_u32(payload, report.offset)
    transform_cache_u32(payload, report.work)
    transform_cache_u32(payload, report.allocation_work)
  }
  let bytes = payload.to_bytes()
  if bytes.length().to_uint64() != size {
    abort("transform cache invariant: encoded size must match its checked size")
  }
  let out = Buffer(size_hint=bytes.length() + 76)
  out.write_bytes(b"DWTC")
  transform_cache_u32(out, 1U)
  transform_cache_digest(out, key)
  transform_cache_digest(out, @cache_binary.blake3(bytes))
  transform_cache_u32(out, bytes.length().reinterpret_as_uint())
  out.write_bytes(bytes)
  Some(out.to_bytes())
}

///|
priv struct TransformCacheReader {
  bytes : Bytes
  mut offset : Int32
  mut failed : Bool
}

///|
fn TransformCacheReader::u32(self : TransformCacheReader) -> UInt32 {
  if self.failed || self.offset > self.bytes.length() - 4 {
    self.failed = true
    return 0U
  }
  let i = self.offset
  self.offset += 4
  self.bytes[i].to_uint() |
  (self.bytes[i + 1].to_uint() << 8) |
  (self.bytes[i + 2].to_uint() << 16) |
  (self.bytes[i + 3].to_uint() << 24)
}

///|
fn TransformCacheReader::count(
  self : TransformCacheReader,
  limit : Int32,
) -> Int32 {
  let count = self.u32().reinterpret_as_int()
  if count < 0 || count > limit {
    self.failed = true
    0
  } else {
    count
  }
}

///|
fn TransformCacheReader::blob(
  self : TransformCacheReader,
  limit : Int32,
) -> Bytes {
  let length = self.count(limit)
  if self.failed || length > self.bytes.length() - self.offset {
    self.failed = true
    return b""
  }
  let out = Buffer(size_hint=length)
  for i in self.offset..<(self.offset + length) {
    out.write_byte(self.bytes[i])
  }
  self.offset += length
  out.to_bytes()
}

///|
fn TransformCacheReader::text(
  self : TransformCacheReader,
  limit : Int32,
) -> String {
  @utf8.decode(self.blob(limit)) catch {
    _ => {
      self.failed = true
      ""
    }
  }
}

///|
fn transform_cache_decode(
  bytes : Bytes,
  key : FixedArray[Byte],
) -> (@semantic.ProgramManifest, Array[@transforms.TransformReport])? {
  if bytes.length() < 76 || bytes.length() > 16777216 {
    return None
  }
  let reader = { bytes, offset: 0, failed: false, }
  if reader.u32() != 0x43545744U || reader.u32() != 1U {
    return None
  }
  for i in 0..<32 {
    if bytes[8 + i] != key[i] {
      return None
    }
  }
  reader.offset = 72
  let length = reader.count(bytes.length() - 76)
  if reader.failed || length != bytes.length() - 76 {
    return None
  }
  let digest = match @cache_binary.blake3_range(bytes, 76, length) {
    Ok(value) => value
    Err(error) =>
      abort("transform cache invariant: checked payload hash range: " + error)
  }
  for i in 0..<32 {
    if bytes[40 + i] != digest[i] {
      return None
    }
  }
  let module_count = reader.count(1024)
  if module_count == 0 || module_count > (bytes.length() - reader.offset) / 22 {
    return None
  }
  let modules : Array[@semantic.ManifestModule] = []
  let module_names : Map[String, Bool] = Map::default()
  let mut total_files = 0
  for _ in 0..<module_count {
    let name = reader.text(255)
    let count = reader.count(4096)
    if reader.failed ||
      name == "" ||
      module_names.contains(name) ||
      count == 0 ||
      count > (bytes.length() - reader.offset) / 13 ||
      total_files > 65536 - count {
      return None
    }
    module_names[name] = true
    total_files += count
    let files : Array[@semantic.ManifestFile] = []
    let file_names : Map[String, Bool] = Map::default()
    for _ in 0..<count {
      let path = reader.text(4096)
      let source = reader.blob(16777216)
      let test_only = reader.u32()
      if reader.failed ||
        path == "" ||
        file_names.contains(path) ||
        test_only != 0U {
        return None
      }
      file_names[path] = true
      files.push(@semantic.ManifestFile::new(path, source))
    }
    modules.push(@semantic.ManifestModule::new(name, files))
  }
  let report_count = reader.count(65536)
  if reader.failed || report_count > (bytes.length() - reader.offset) / 28 {
    return None
  }
  let reports : Array[@transforms.TransformReport] = []
  for _ in 0..<report_count {
    let module_name = reader.text(4096)
    let file_name = reader.text(4096)
    let function_name = reader.text(4096)
    let transform_name = reader.text(4096)
    let offset = reader.u32()
    let work = reader.u32()
    let allocation_work = reader.u32()
    if reader.failed || work > 100000U || allocation_work > 4194304U {
      return None
    }
    reports.push({
      module_name,
      file_name,
      function_name,
      transform_name,
      offset,
      work,
      allocation_work,
    })
  }
  if reader.offset != bytes.length() {
    return None
  }
  Some((@semantic.ProgramManifest::new(modules), reports))
}

///|
fn transform_cache_manifest_bounded(
  manifest : @semantic.ProgramManifest,
) -> Bool {
  if manifest.modules.length() > 1024 {
    return false
  }
  let mut files = 0
  for module_ in manifest.modules {
    if module_.path.length() > 255 ||
      @utf8.encode(module_.path).length() > 255 ||
      module_.files.length() > 4096 {
      return false
    }
    files += module_.files.length()
    if files > 65536 {
      return false
    }
    for file in module_.files {
      if file.path.length() > 4096 ||
        @utf8.encode(file.path).length() > 4096 ||
        file.source.length() > 16777216 {
        return false
      }
    }
  }
  true
}

///|
fn transform_cache_inputs_eligible(
  manifest : @semantic.ProgramManifest,
  pool : @semantic.ProgramManifest,
  sources : @semantic.StandardLibrarySources,
  identity : String,
) -> Bool {
  !(identity == "" ||
  identity.length() > 4096 ||
  @utf8.encode(identity).length() > 4096 ||
  !transform_cache_manifest_bounded(manifest) ||
  !transform_cache_manifest_bounded(pool) ||
  sources.paths.length() > 65536 ||
  !sources.paths.all(path => {
    path.length() <= 4096 && @utf8.encode(path).length() <= 4096
  }) ||
  !sources.sources.all(source => source.length() <= 16777216) ||
  !(manifest.modules.any(module_ => {
    module_.files.any(file => @transforms.contains_transform_syntax(file.source))
  }) ||
  pool.modules.any(module_ => {
    module_.files.any(file => @transforms.contains_transform_syntax(file.source))
  })))
}

///|
fn compiler_expand_transform_import_closure_cached(
  manifest : @semantic.ProgramManifest,
  pool : @semantic.ProgramManifest,
  sources : @semantic.StandardLibrarySources,
  options : CompilerPipelineOptions,
  prepared_key~ : FixedArray[Byte]? = None,
) -> Result[@semantic.ProgramManifest, CompilerCompilationError] {
  let cache = match options.transform_cache {
    Some(value) => value
    None =>
      return compiler_expand_transform_import_closure(
        manifest, pool, sources, options,
      )
  }
  cache.pending = None
  if prepared_key is None &&
    !transform_cache_inputs_eligible(manifest, pool, sources, cache.identity) {
    cache.state = "disabled"
    return compiler_expand_transform_import_closure(
      manifest, pool, sources, options,
    )
  }
  let key = match prepared_key {
    Some(value) => value
    None =>
      compiler_transform_cache_key(
        manifest,
        pool,
        sources,
        options,
        cache.identity,
      )
  }
  if transform_cache_decode(cache.saved, key) is Some((expanded, reports)) {
    cache.state = "hit"
    for report in reports {
      options.transform_reports.push(report)
    }
    return Ok(expanded)
  }
  cache.state = "miss"
  let start = options.transform_reports.length()
  let expanded = match
    compiler_expand_transform_import_closure(manifest, pool, sources, options) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let reports : Array[@transforms.TransformReport] = []
  for index in start..<options.transform_reports.length() {
    reports.push(options.transform_reports[index])
  }
  cache.pending = transform_cache_encode(key, expanded, reports).map(bytes => {
    (key, bytes)
  })
  Ok(expanded)
}
