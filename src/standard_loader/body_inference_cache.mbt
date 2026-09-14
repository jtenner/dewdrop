///|
pub struct BodyInferenceCacheStatus {
  enabled : Bool
  hits : Int
  misses : Int
  family_enabled : Bool
  family_hits : Int
  family_misses : Int
}

///|
pub fn BodyInferenceCacheStatus::disabled() -> BodyInferenceCacheStatus {
  {
    enabled: false,
    hits: 0,
    misses: 0,
    family_enabled: false,
    family_hits: 0,
    family_misses: 0,
  }
}

///|
pub fn BodyInferenceCacheStatus::label(
  self : BodyInferenceCacheStatus,
) -> String {
  if !self.enabled {
    "disabled"
  } else if !self.family_enabled {
    "module hits \{self.hits}, module misses \{self.misses}, family disabled"
  } else {
    "module hits \{self.hits}, module misses \{self.misses}, family hits \{self.family_hits}, family misses \{self.family_misses}"
  }
}

///|
pub struct CachedProgramSemanticAnalysis {
  analyzed : @semantic.AnalyzedProgramSemantics
  status : BodyInferenceCacheStatus
}

///|
priv struct BodyInferenceFamilyCacheKey {
  fingerprint : String
  fingerprint_digest : FixedArray[Byte]
  context_digest : FixedArray[Byte]
}

///|
fn body_inference_cache_enabled() -> Bool {
  cache_platform_supported() &&
  (
    @sys.get_env_var("DEW_BODY_CACHE").unwrap_or("0") == "1" ||
    @sys.get_env_var("DEW_BODY_FAMILY_CACHE").unwrap_or("0") == "1"
  )
}

///|
fn body_inference_family_cache_enabled() -> Bool {
  body_inference_cache_enabled() &&
  @sys.get_env_var("DEW_BODY_FAMILY_CACHE").unwrap_or("0") == "1"
}

///|
fn body_inference_cache_directory() -> String {
  interface_cache_join(interface_cache_root(), "body-inference")
}

///|
fn body_inference_cache_file(key : String) -> String {
  interface_cache_join(body_inference_cache_directory(), "v1-" + key + ".dbi")
}

///|
fn body_inference_family_cache_directory() -> String {
  interface_cache_join(interface_cache_root(), "body-inference-families")
}

///|
fn body_inference_family_cache_file(key : String) -> String {
  interface_cache_join(
    body_inference_family_cache_directory(),
    "v1-" + key + ".dbf",
  )
}

///|
fn body_family_write_u64(output : Buffer, value : UInt64) -> Unit {
  for shift in [0, 8, 16, 24, 32, 40, 48, 56] {
    output.write_byte(((value >> shift) & 0xffUL).to_byte())
  }
}

///|
fn body_family_write_int(output : Buffer, value : Int) -> Unit {
  let encoded = value.reinterpret_as_uint().to_uint64()
  body_family_write_u64(output, encoded)
}

///|
fn body_family_declaration_sources(
  collected : @semantic.CollectedModule,
) -> Result[Array[Bytes?], String] {
  let file_indices : Map[@semantic.FileId, Int] = Map::default()
  let declarations_by_file : Array[Array[(Int, @semantic.DeclId)]] = []
  for index, file in collected.files {
    file_indices[file] = index
    declarations_by_file.push([])
  }
  for declaration in collected.declarations {
    let declaration_index = @semantic.semantic_id_local(declaration.id)
    let file = collected.declaration_files[declaration_index]
    let file_index = match file_indices.get(file) {
      Some(value) => value
      None => return Err("body-family declaration file is missing")
    }
    declarations_by_file[file_index].push(
      (declaration.offset.to_uint().reinterpret_as_int(), declaration.id),
    )
  }
  for method_declaration in collected.methods {
    let declaration_index = @semantic.semantic_id_local(method_declaration.id)
    let file = collected.declaration_files[declaration_index]
    let file_index = match file_indices.get(file) {
      Some(value) => value
      None => return Err("body-family method file is missing")
    }
    declarations_by_file[file_index].push(
      (
        method_declaration.offset.to_uint().reinterpret_as_int(),
        method_declaration.id,
      ),
    )
  }
  let sources : Array[Bytes?] = Array::make(
    collected.declaration_files.length(),
    None,
  )
  for file_index, declarations in declarations_by_file {
    declarations.sort_by(fn(left, right) { left.0.compare(right.0) })
    let source = collected.file_sources[file_index]
    for index, declaration in declarations {
      let start = declaration.0
      let end = if index + 1 < declarations.length() {
        declarations[index + 1].0
      } else {
        source.length()
      }
      if start < 0 || end < start || end > source.length() {
        return Err("body-family declaration range is invalid")
      }
      let output = Buffer(size_hint=end - start)
      for source_index in start..<end {
        output.write_byte(source[source_index])
      }
      sources[@semantic.semantic_id_local(declaration.1)] = Some(
        output.to_bytes(),
      )
    }
  }
  Ok(sources)
}

///|
fn body_inference_module_value_source_digest(
  collected : @semantic.CollectedModule,
  declaration_sources : Array[Bytes?],
) -> Result[FixedArray[Byte], String] {
  let output = Buffer()
  output.write_bytes(b"DEW_BODY_FAMILY_MODULE_VALUES_V1\x00")
  for body in collected.bodies {
    if body.kind is @semantic.ModuleLetBody {
      body_family_write_u64(output, body.declaration)
      let source = match
        declaration_sources[@semantic.semantic_id_local(body.declaration)] {
        Some(value) => value
        None => return Err("body-family module-value source is missing")
      }
      body_family_write_int(output, source.length())
      output.write_bytes(source)
    }
  }
  Ok(@crypto.sha256(output.to_bytes()))
}

///|
fn body_inference_family_context_digest(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
  module_index : Int,
  declaration_sources : Array[Bytes?],
) -> Result[FixedArray[Byte], String] {
  let collected = program.modules[module_index]
  let output = Buffer()
  output.write_bytes(b"DEW_BODY_FAMILY_CONTEXT_V1_ARRAY_LITERAL_CALLS\x00")
  let interface_digest = match
    body_inference_interface_digest(frozen, module_index) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  for byte in interface_digest {
    output.write_byte(byte)
  }
  let body_evidence = match
    @semantic.frozen_interface_body_evidence_fingerprint(
      frozen.interfaces[module_index],
    ) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  interface_cache_write_string(output, body_evidence)
  for name in collected.names {
    interface_cache_write_string(output, name)
  }
  body_family_write_int(output, collected.bodies.length())
  for body in collected.bodies {
    body_family_write_u64(output, body.id)
    body_family_write_u64(output, body.declaration)
    output.write_byte(
      match body.kind {
        @semantic.ModuleLetBody => 0
        @semantic.FunctionBody => 1
        @semantic.ImplMethodBody => 2
      },
    )
  }
  body_family_write_int(output, collected.lambdas.length())
  for lambda in collected.lambdas {
    body_family_write_int(output, lambda.id)
    body_family_write_int(output, lambda.parent)
    body_family_write_u64(output, lambda.root_body)
  }
  let module_values = match
    body_inference_module_value_source_digest(collected, declaration_sources) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  for byte in module_values {
    output.write_byte(byte)
  }
  Ok(@crypto.sha256(output.to_bytes()))
}

///|
fn body_inference_family_cache_keys(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
  module_index : Int,
) -> Result[Array[BodyInferenceFamilyCacheKey?], String] {
  if module_index < 0 || module_index >= program.modules.length() {
    return Err("body-family cache module index is out of range")
  }
  let collected = program.modules[module_index]
  if program.module_paths[module_index].has_prefix("dew.std.") {
    return Ok(Array::make(collected.bodies.length(), None))
  }
  let declaration_sources = match body_family_declaration_sources(collected) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let context = match
    body_inference_family_context_digest(
      program, frozen, module_index, declaration_sources,
    ) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let keys : Array[BodyInferenceFamilyCacheKey?] = Array::make(
    collected.bodies.length(),
    None,
  )
  for body_index, body in collected.bodies {
    if body.kind is @semantic.ModuleLetBody {
      continue
    }
    let family_source = match
      declaration_sources[@semantic.semantic_id_local(body.declaration)] {
      Some(value) => value
      None => return Err("body-family declaration source is missing")
    }
    let source = @crypto.sha256(family_source)
    let key_output = Buffer()
    key_output.write_bytes(b"DEW_BODY_FAMILY_KEY_V1_ARRAY_LITERAL_CALLS\x00")
    key_output.write_byte(if program.default_preamble { 1 } else { 0 })
    interface_cache_write_string(key_output, program.module_paths[module_index])
    body_family_write_u64(key_output, body.id)
    body_family_write_u64(key_output, body.declaration)
    for byte in source {
      key_output.write_byte(byte)
    }
    for byte in context {
      key_output.write_byte(byte)
    }
    let key = @crypto.sha256(key_output.to_bytes())
    keys[body_index] = Some({
      fingerprint: @crypto.bytes_to_hex_string(key),
      fingerprint_digest: key,
      context_digest: context,
    })
  }
  Ok(keys)
}

///|
fn body_inference_source_digest(
  program : @semantic.CollectedProgram,
  module_index : Int,
) -> FixedArray[Byte] {
  let module_ = program.modules[module_index]
  let output = Buffer()
  output.write_bytes(b"DEW_BODY_INFERENCE_SOURCE_V1\x00")
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
  @crypto.sha256(output.to_bytes())
}

///|
fn body_inference_interface_digest(
  frozen : @semantic.FrozenProgramInterfaces,
  module_index : Int,
) -> Result[FixedArray[Byte], String] {
  let output = Buffer()
  output.write_bytes(b"DEW_BODY_INFERENCE_INTERFACE_V1\x00")
  interface_cache_write_string(
    output,
    frozen.interfaces[module_index].interface_fingerprint,
  )
  let dependencies : Array[Int] = []
  for interface_index in frozen.import_scopes[module_index].imported_interfaces {
    if interface_index != module_index {
      dependencies.push(interface_index)
    }
  }
  dependencies.sort_by(fn(left, right) {
    frozen.interfaces[left].path.compare(frozen.interfaces[right].path)
  })
  for dependency_index in dependencies {
    let dependency = frozen.interfaces[dependency_index]
    interface_cache_write_string(output, dependency.path)
    let evidence = match
      @semantic.frozen_interface_body_evidence_fingerprint(dependency) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    interface_cache_write_string(output, evidence)
  }
  Ok(@crypto.sha256(output.to_bytes()))
}

///|
fn body_inference_cache_key_digest(
  program : @semantic.CollectedProgram,
  module_index : Int,
  source : FixedArray[Byte],
  interface_ : FixedArray[Byte],
) -> FixedArray[Byte] {
  let output = Buffer()
  output.write_bytes(b"DEW_BODY_INFERENCE_KEY_V1_ARRAY_LITERAL_CALLS\x00")
  output.write_byte(if program.default_preamble { 1 } else { 0 })
  interface_cache_write_string(output, program.module_paths[module_index])
  for byte in source {
    output.write_byte(byte)
  }
  for byte in interface_ {
    output.write_byte(byte)
  }
  @crypto.sha256(output.to_bytes())
}

///|
fn body_inference_cache_key(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
  module_index : Int,
) -> Result[
  (String, FixedArray[Byte], FixedArray[Byte], FixedArray[Byte]),
  String,
] {
  let source = body_inference_source_digest(program, module_index)
  let interface_ = match body_inference_interface_digest(frozen, module_index) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let key = body_inference_cache_key_digest(
    program, module_index, source, interface_,
  )
  Ok((@crypto.bytes_to_hex_string(key), key, source, interface_))
}

///|
fn validate_cached_inferred_module(
  collected : @semantic.CollectedModule,
  resolved : @semantic.ResolvedModuleTypes,
  imports : @semantic.ResolvedModuleImports,
  names : @semantic.ResolvedModuleNames,
  inferred : @semantic.InferredModuleBodies,
) -> Result[Unit, String] {
  if inferred.module_id != collected.module_id ||
    inferred.module_values.module_id != collected.module_id ||
    inferred.impl_index.module_id != collected.module_id ||
    inferred.module_values.dependencies.module_id != collected.module_id {
    return Err("body-inference cache module identity mismatch")
  }
  if inferred.bodies.length() != collected.bodies.length() ||
    inferred.lambdas.length() != collected.lambdas.length() ||
    inferred.expression_types.length() != collected.expressions.length() ||
    inferred.local_types.length() != names.locals.length() ||
    inferred.capture_types.length() != names.captures.length() ||
    inferred.block_types.length() != collected.blocks.length() ||
    inferred.pattern_types.length() != collected.patterns.length() ||
    inferred.pattern_constructors.length() != collected.patterns.length() ||
    inferred.control_state_types.length() != names.controls.length() ||
    inferred.control_result_types.length() != names.controls.length() ||
    inferred.expression_selections.length() != collected.expressions.length() ||
    inferred.object_field_targets.length() != collected.object_fields.length() ||
    inferred.trait_object_coercions.length() != collected.expressions.length() ||
    inferred.call_targets.length() != collected.expressions.length() ||
    inferred.operator_targets.length() != collected.expressions.length() ||
    (
      inferred.expression_evidence.length() != 0 &&
      inferred.expression_evidence.length() != collected.expressions.length()
    ) {
    return Err("body-inference cache arena length mismatch")
  }
  for index, body in inferred.bodies {
    if body.body != collected.bodies[index].id {
      return Err("body-inference cache body identity mismatch")
    }
  }
  for index, lambda in inferred.lambdas {
    if lambda.lambda != collected.lambdas[index].id {
      return Err("body-inference cache lambda identity mismatch")
    }
  }
  let expected_dependencies = @semantic.analyze_module_value_dependencies(
    collected, names,
  )
  if inferred.module_values.dependencies != expected_dependencies {
    return Err("body-inference cache module-value dependency mismatch")
  }
  let expected_impl_index = @semantic.build_module_impl_index_with_imports(
    collected, resolved, imports,
  )
  if inferred.impl_index != expected_impl_index {
    return Err("body-inference cache implementation evidence mismatch")
  }
  Ok(())
}

///|
fn lookup_body_inference_cache(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
  module_index : Int,
  resolved : @semantic.ResolvedModuleTypes,
  imports : @semantic.ResolvedModuleImports,
  names : @semantic.ResolvedModuleNames,
  pack? : CompilationCachePack? = None,
) -> Result[@semantic.InferredModuleBodies?, String] {
  let (key, key_digest, source_digest, interface_digest) = match
    body_inference_cache_key(program, frozen, module_index) {
    Ok(value) => value
    Err(error) =>
      return Err("cannot fingerprint body-inference cache: \{error}")
  }
  let path = body_inference_cache_file(key)
  let payload = match pack {
    Some(session) if session.enabled => {
      let context_bytes = Buffer()
      context_bytes.write_bytes(
        b"DEW_BODY_MODULE_PACK_CONTEXT_V1_ARRAY_LITERAL_CALLS\x00",
      )
      for byte in key_digest {
        context_bytes.write_byte(byte)
      }
      for byte in interface_digest {
        context_bytes.write_byte(byte)
      }
      match
        session.lookup(
          cache_pack_body_module_kind,
          2U,
          "module:" + program.module_paths[module_index],
          cache_pack_rehash_digest(source_digest),
          @cache_binary.blake3(context_bytes.to_bytes()),
        ) {
        Err(error) => return Err("corrupt compilation cache pack: \{error}")
        Ok(Some(value)) => value
        Ok(None) => return Ok(None)
      }
    }
    _ => {
      if !@fs.path_exists(path) {
        return Ok(None)
      }
      let bytes = @fs.read_file_to_bytes(path) catch {
        error =>
          return Err(
            "cannot read body-inference cache \{path}: \{standard_loader_fs_error_message(error)}",
          )
      }
      match
        unwrap_body_inference_cache_payload(
          bytes, key_digest, source_digest, interface_digest,
        ) {
        Ok(value) => value
        Err(error) =>
          return Err("corrupt body-inference cache \{path}: \{error}")
      }
    }
  }
  let inferred = match @semantic.deserialize_inferred_module_bodies(payload) {
    Ok(value) => value
    Err(error) => return Err("corrupt body-inference cache \{path}: \{error}")
  }
  match
    validate_cached_inferred_module(
      program.modules[module_index],
      resolved,
      imports,
      names,
      inferred,
    ) {
    Ok(_) => Ok(Some(inferred))
    Err(error) => Err("corrupt body-inference cache \{path}: \{error}")
  }
}

///|
fn store_body_inference_cache(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
  module_index : Int,
  inferred : @semantic.InferredModuleBodies,
  pack? : CompilationCachePack? = None,
) -> Result[Unit, String] {
  let (key, key_digest, source_digest, interface_digest) = match
    body_inference_cache_key(program, frozen, module_index) {
    Ok(value) => value
    Err(error) =>
      return Err("cannot fingerprint body-inference cache: \{error}")
  }
  let payload = match @semantic.serialize_inferred_module_bodies(inferred) {
    Ok(value) => value
    Err(error) => return Err("cannot serialize body-inference cache: \{error}")
  }
  match pack {
    Some(session) if session.enabled => {
      let context_bytes = Buffer()
      context_bytes.write_bytes(
        b"DEW_BODY_MODULE_PACK_CONTEXT_V1_ARRAY_LITERAL_CALLS\x00",
      )
      for byte in key_digest {
        context_bytes.write_byte(byte)
      }
      for byte in interface_digest {
        context_bytes.write_byte(byte)
      }
      return session.store(
        cache_pack_body_module_kind,
        2U,
        0U,
        1U,
        "module:" + program.module_paths[module_index],
        cache_pack_rehash_digest(source_digest),
        @cache_binary.blake3(context_bytes.to_bytes()),
        payload,
      )
    }
    _ => ()
  }
  let envelope = match
    wrap_body_inference_cache_payload(
      key_digest, source_digest, interface_digest, payload,
    ) {
    Ok(value) => value
    Err(error) => return Err("cannot envelope body-inference cache: \{error}")
  }
  let root = interface_cache_root()
  match ensure_interface_cache_root(root) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let directory = body_inference_cache_directory()
  match ensure_cache_directory(directory) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let path = body_inference_cache_file(key)
  let path_bytes = @utf8.encode(path)
  let result = cache_platform_atomic_write(
    path_bytes,
    path_bytes.length(),
    envelope,
  )
  if result != 0 {
    return Err(
      "cannot atomically write body-inference cache \{path}: errno \{-result}",
    )
  }
  Ok(())
}

///|
fn lookup_body_inference_family_cache(
  module_id : @semantic.ModuleId,
  module_path : String,
  context : FixedArray[Byte],
  pack? : CompilationCachePack? = None,
) -> Result[@semantic.BodyInferenceFamilyBundleIndex?, String] {
  let fingerprint = @crypto.bytes_to_hex_string(context)
  let path = body_inference_family_cache_file(fingerprint)
  let payload = match pack {
    Some(session) if session.enabled =>
      match
        session.lookup(
          cache_pack_body_family_kind,
          2U,
          "module-family:" + module_path,
          cache_pack_rehash_digest(context),
          @cache_binary.blake3(
            b"DEW_BODY_FAMILY_PACK_CONTEXT_V1_ARRAY_LITERAL_CALLS",
          ),
        ) {
        Err(error) => return Err("corrupt compilation cache pack: \{error}")
        Ok(Some(value)) => value
        Ok(None) => return Ok(None)
      }
    _ => {
      if !@fs.path_exists(path) {
        return Ok(None)
      }
      let bytes = @fs.read_file_to_bytes(path) catch {
        error =>
          return Err(
            "cannot read body-family cache \{path}: \{standard_loader_fs_error_message(error)}",
          )
      }
      match
        unwrap_body_inference_family_cache_payload(
          bytes, context, context, context,
        ) {
        Ok(value) => value
        Err(error) => return Err("corrupt body-family cache \{path}: \{error}")
      }
    }
  }
  let bundle = match @semantic.open_body_inference_family_bundle(payload) {
    Ok(value) => value
    Err(error) => return Err("corrupt body-family cache \{path}: \{error}")
  }
  if bundle.owner() != module_id {
    return Err("corrupt body-family cache \{path}: module identity mismatch")
  }
  Ok(Some(bundle))
}

///|
fn store_body_inference_family_cache(
  module_path : String,
  context : FixedArray[Byte],
  bundle : @semantic.BodyInferenceFamilyBundle,
  pack? : CompilationCachePack? = None,
) -> Result[Unit, String] {
  let payload = match @semantic.serialize_body_inference_family_bundle(bundle) {
    Ok(value) => value
    Err(error) => return Err("cannot serialize body-family cache: \{error}")
  }
  match pack {
    Some(session) if session.enabled =>
      return session.store(
        cache_pack_body_family_kind,
        2U,
        0U,
        1U,
        "module-family:" + module_path,
        cache_pack_rehash_digest(context),
        @cache_binary.blake3(
          b"DEW_BODY_FAMILY_PACK_CONTEXT_V1_ARRAY_LITERAL_CALLS",
        ),
        payload,
      )
    _ => ()
  }
  let envelope = match
    wrap_body_inference_family_cache_payload(context, context, context, payload) {
    Ok(value) => value
    Err(error) => return Err("cannot envelope body-family cache: \{error}")
  }
  let root = interface_cache_root()
  match ensure_interface_cache_root(root) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let directory = body_inference_family_cache_directory()
  match ensure_cache_directory(directory) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let path = body_inference_family_cache_file(
    @crypto.bytes_to_hex_string(context),
  )
  let path_bytes = @utf8.encode(path)
  let result = cache_platform_atomic_write(
    path_bytes,
    path_bytes.length(),
    envelope,
  )
  if result != 0 {
    return Err(
      "cannot atomically write body-family cache \{path}: errno \{-result}",
    )
  }
  Ok(())
}

///|
fn infer_module_with_body_family_cache(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
  module_index : Int,
  resolved : @semantic.ResolvedModuleTypes,
  imports : @semantic.ResolvedModuleImports,
  names : @semantic.ResolvedModuleNames,
  pack? : CompilationCachePack? = None,
) -> Result[@semantic.BodyInferenceFamilyAnalysis, String] {
  let keys = match
    body_inference_family_cache_keys(program, frozen, module_index) {
    Ok(value) => value
    Err(error) => return Err("cannot fingerprint body-family cache: \{error}")
  }
  let cached : Array[@semantic.BodyInferenceFamilyArtifact?] = Array::make(
    keys.length(),
    None,
  )
  let mut context : FixedArray[Byte]? = None
  for key in keys {
    match key {
      Some(value) => {
        context = Some(value.context_digest)
        break
      }
      None => ()
    }
  }
  let context = match context {
    Some(value) => value
    None =>
      return Ok(
        @semantic.make_uncached_body_inference_family_analysis(
          @semantic.infer_module_bodies_with_imports(
            program.modules[module_index],
            resolved,
            imports,
            names,
          ),
          cached.length(),
        ),
      )
  }
  let existing = match
    lookup_body_inference_family_cache(
      program.modules[module_index].module_id,
      program.module_paths[module_index],
      context,
      pack~,
    ) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match existing {
    Some(bundle) =>
      for index, key in keys {
        match key {
          Some(value) =>
            match bundle.lookup(value.fingerprint_digest) {
              Ok(Some(artifact)) => cached[index] = Some(artifact)
              Ok(None) => ()
              Err(error) => return Err("corrupt body-family cache: \{error}")
            }
          None => ()
        }
      }
    None => ()
  }
  let analysis = match
    @semantic.infer_module_bodies_with_imports_and_family_cache(
      program.modules[module_index],
      resolved,
      imports,
      names,
      cached,
    ) {
    Ok(value) => value
    Err(error) => return Err("corrupt body-family cache: \{error}")
  }
  if existing is None {
    let fingerprints : Array[String] = []
    let artifacts : Array[@semantic.BodyInferenceFamilyArtifact] = []
    for index, key in keys {
      match (key, analysis.families[index]) {
        (Some(value), Some(artifact)) => {
          fingerprints.push(value.fingerprint)
          artifacts.push(artifact)
        }
        _ => ()
      }
    }
    let bundle = match
      @semantic.make_body_inference_family_bundle(
        program.modules[module_index].module_id,
        fingerprints,
        artifacts,
      ) {
      Ok(value) => value
      Err(error) => return Err("cannot assemble body-family cache: \{error}")
    }
    match
      store_body_inference_family_cache(
        program.module_paths[module_index],
        context,
        bundle,
        pack~,
      ) {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
  }
  Ok(analysis)
}

///|
/// Reuses complete module-level body-inference results and falls back to
/// declaration-family artifacts when an exact module artifact misses. This first persistent
/// boundary deliberately keeps name resolution fresh so cached arenas are
/// validated against the current collected HIR before downstream lowering.
pub fn analyze_program_semantics_with_body_cache(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
  pack? : CompilationCachePack? = None,
) -> Result[CachedProgramSemanticAnalysis, String] {
  let enabled = body_inference_cache_enabled()
  let family_enabled = body_inference_family_cache_enabled()
  let slots : Array[@semantic.AnalyzedProgramModule?] = Array::make(
    program.modules.length(),
    None,
  )
  let mut hits = 0
  let mut misses = 0
  let mut family_hits = 0
  let mut family_misses = 0
  for scc in frozen.graph.sccs {
    for index in 0..<scc.length {
      let module_index = frozen.graph.scc_modules[scc.start + index]
      let collected = program.modules[module_index]
      let resolved = frozen.interfaces[module_index].resolved_types
      let scope = frozen.import_scopes[module_index]
      let imports = @semantic.resolve_module_imports(resolved, scope)
      let names = @semantic.resolve_module_names_with_imports(collected, scope)
      let inferred = if enabled {
        match
          lookup_body_inference_cache(
            program,
            frozen,
            module_index,
            resolved,
            imports,
            names,
            pack~,
          ) {
          Err(error) => return Err(error)
          Ok(Some(value)) => {
            hits += 1
            value
          }
          Ok(None) => {
            misses += 1
            let mut family_applicable = false
            let value = if family_enabled {
              let family_analysis = match
                infer_module_with_body_family_cache(
                  program,
                  frozen,
                  module_index,
                  resolved,
                  imports,
                  names,
                  pack~,
                ) {
                Ok(value) => value
                Err(error) => return Err(error)
              }
              family_hits += family_analysis.family_hits
              family_misses += family_analysis.family_misses
              family_applicable = family_analysis.family_hits +
                family_analysis.family_misses >
                0
              family_analysis.inferred
            } else {
              @semantic.infer_module_bodies_with_imports(
                collected, resolved, imports, names,
              )
            }
            if !family_applicable {
              match
                store_body_inference_cache(
                  program,
                  frozen,
                  module_index,
                  value,
                  pack~,
                ) {
                Ok(_) => ()
                Err(error) => return Err(error)
              }
            }
            value
          }
        }
      } else {
        @semantic.infer_module_bodies_with_imports(
          collected, resolved, imports, names,
        )
      }
      slots[module_index] = Some(
        @semantic.make_analyzed_program_module(
          collected.module_id,
          imports,
          names,
          inferred,
        ),
      )
    }
  }
  let modules : Array[@semantic.AnalyzedProgramModule] = []
  for slot in slots {
    modules.push(slot.unwrap())
  }
  Ok({
    analyzed: @semantic.make_analyzed_program_semantics(frozen, modules),
    status: {
      enabled,
      hits,
      misses,
      family_enabled,
      family_hits,
      family_misses,
    },
  })
}
