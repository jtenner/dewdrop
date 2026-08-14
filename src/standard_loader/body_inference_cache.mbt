///|
pub struct BodyInferenceCacheStatus {
  enabled : Bool
  hits : Int
  misses : Int
}

///|
pub fn BodyInferenceCacheStatus::label(
  self : BodyInferenceCacheStatus,
) -> String {
  if !self.enabled {
    "disabled"
  } else {
    "hits \{self.hits}, misses \{self.misses}"
  }
}

///|
pub struct CachedProgramSemanticAnalysis {
  analyzed : @semantic.AnalyzedProgramSemantics
  status : BodyInferenceCacheStatus
}

///|
fn body_inference_cache_enabled() -> Bool {
  cache_platform_supported() &&
  @sys.get_env_var("DEW_BODY_CACHE").unwrap_or("1") != "0"
}

///|
fn body_inference_cache_directory() -> String {
  interface_cache_join(interface_cache_root(), "body-inference")
}

///|
fn body_inference_cache_file(key : String) -> String {
  interface_cache_join(body_inference_cache_directory(), "v3-" + key + ".dbi")
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
  output.write_bytes(b"DEW_BODY_INFERENCE_INTERFACE_V2\x00")
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
  output.write_bytes(b"DEW_BODY_INFERENCE_KEY_V3\x00")
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
    inferred.map_hash_targets.length() != collected.expressions.length() ||
    inferred.map_eq_targets.length() != collected.expressions.length() ||
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
) -> Result[@semantic.InferredModuleBodies?, String] {
  let (key, key_digest, source_digest, interface_digest) = match
    body_inference_cache_key(program, frozen, module_index) {
    Ok(value) => value
    Err(error) =>
      return Err("cannot fingerprint body-inference cache: \{error}")
  }
  let path = body_inference_cache_file(key)
  if !@fs.path_exists(path) {
    return Ok(None)
  }
  let bytes = @fs.read_file_to_bytes(path) catch {
    error => return Err("cannot read body-inference cache \{path}: \{error}")
  }
  let payload = match
    unwrap_body_inference_cache_payload(
      bytes, key_digest, source_digest, interface_digest,
    ) {
    Ok(value) => value
    Err(error) => return Err("corrupt body-inference cache \{path}: \{error}")
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
/// Reuses complete module-level body-inference results. This first persistent
/// boundary deliberately keeps name resolution fresh so cached arenas are
/// validated against the current collected HIR before downstream lowering.
pub fn analyze_program_semantics_with_body_cache(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
) -> Result[CachedProgramSemanticAnalysis, String] {
  let enabled = body_inference_cache_enabled()
  let slots : Array[@semantic.AnalyzedProgramModule?] = Array::make(
    program.modules.length(),
    None,
  )
  let mut hits = 0
  let mut misses = 0
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
            program, frozen, module_index, resolved, imports, names,
          ) {
          Err(error) => return Err(error)
          Ok(Some(value)) => {
            hits += 1
            value
          }
          Ok(None) => {
            misses += 1
            let value = @semantic.infer_module_bodies_with_imports(
              collected, resolved, imports, names,
            )
            match
              store_body_inference_cache(program, frozen, module_index, value) {
              Ok(_) => ()
              Err(error) => return Err(error)
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
    status: { enabled, hits, misses },
  })
}
