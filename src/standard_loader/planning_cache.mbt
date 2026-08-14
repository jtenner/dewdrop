///|
pub struct PlanningCacheStatus {
  enabled : Bool
  layout_hits : Int
  layout_misses : Int
  fragment_hits : Int
  fragment_misses : Int
} derive(Eq, Debug)

///|
pub fn PlanningCacheStatus::label(self : PlanningCacheStatus) -> String {
  if !self.enabled {
    "disabled"
  } else {
    "layout hits \{self.layout_hits}, layout misses \{self.layout_misses}, fragment hits \{self.fragment_hits}, fragment misses \{self.fragment_misses}"
  }
}

///|
pub fn combine_planning_cache_status(
  layouts : PlanningCacheStatus,
  fragments : PlanningCacheStatus,
) -> PlanningCacheStatus {
  {
    enabled: layouts.enabled || fragments.enabled,
    layout_hits: layouts.layout_hits,
    layout_misses: layouts.layout_misses,
    fragment_hits: fragments.fragment_hits,
    fragment_misses: fragments.fragment_misses,
  }
}

///|
pub struct CachedProgramLowering {
  lowering : @semantic.PlannedProgramLowering
  status : PlanningCacheStatus
}

///|
pub struct CachedProgramWasmGCLink {
  link : @semantic.PlannedProgramWasmGCLink
  status : PlanningCacheStatus
}

///|
fn planning_cache_enabled() -> Bool {
  cache_platform_supported() &&
  @sys.get_env_var("DEW_PLAN_CACHE").unwrap_or("0") == "1"
}

///|
fn type_layout_cache_directory() -> String {
  interface_cache_join(interface_cache_root(), "type-layouts")
}

///|
fn type_layout_cache_file(key : String) -> String {
  interface_cache_join(type_layout_cache_directory(), "v1-" + key + ".dtl")
}

///|
fn wasmgc_fragment_cache_directory() -> String {
  interface_cache_join(interface_cache_root(), "wasmgc-fragments")
}

///|
fn wasmgc_fragment_cache_file(key : String) -> String {
  interface_cache_join(wasmgc_fragment_cache_directory(), "v1-" + key + ".dwf")
}

///|
fn planning_write_digest(output : Buffer, digest : FixedArray[Byte]) -> Unit {
  for byte in digest {
    output.write_byte(byte)
  }
}

///|
fn planning_write_int(output : Buffer, value : Int) -> Unit {
  let encoded = value.reinterpret_as_uint()
  output.write_byte((encoded & 0xffU).to_byte())
  output.write_byte(((encoded >> 8) & 0xffU).to_byte())
  output.write_byte(((encoded >> 16) & 0xffU).to_byte())
  output.write_byte(((encoded >> 24) & 0xffU).to_byte())
}

///|
fn planning_write_id(output : Buffer, value : UInt64) -> Unit {
  for shift in [0, 8, 16, 24, 32, 40, 48, 56] {
    output.write_byte(((value >> shift) & 0xffUL).to_byte())
  }
}

///|
fn type_layout_cache_key(
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
  let output = Buffer()
  output.write_bytes(b"DEW_TYPE_LAYOUT_CACHE_KEY_V1\x00")
  output.write_byte(if program.default_preamble { 1 } else { 0 })
  interface_cache_write_string(output, program.module_paths[module_index])
  planning_write_id(output, program.modules[module_index].module_id)
  planning_write_digest(output, source)
  planning_write_digest(output, interface_)
  let key = @crypto.sha256(output.to_bytes())
  Ok((@crypto.bytes_to_hex_string(key), key, source, interface_))
}

///|
fn wasmgc_planning_options_bytes(
  options : @semantic.WasmGCPlanningOptions,
) -> Bytes {
  let output = Buffer(size_hint=4)
  output.write_byte(
    match options.enum_shape_sharing {
      @semantic.DistinctEnumShapes => 0
      @semantic.ShareExactEnumShapes => 1
    },
  )
  output.write_byte(if options.reuse_unit_subtype_base { 1 } else { 0 })
  output.write_byte(if options.dense_enum_dispatch { 1 } else { 0 })
  output.write_byte(if options.emit_tests { 1 } else { 0 })
  output.to_bytes()
}

///|
fn wasmgc_fragment_program_context(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
  root_module_index : Int,
  options : @semantic.WasmGCPlanningOptions,
) -> Result[FixedArray[Byte], String] {
  let output = Buffer()
  output.write_bytes(b"DEW_WASMGC_FRAGMENT_PROGRAM_CONTEXT_V1\x00")
  output.write_byte(if program.default_preamble { 1 } else { 0 })
  planning_write_int(output, root_module_index)
  output.write_bytes(wasmgc_planning_options_bytes(options))
  planning_write_int(output, program.modules.length())
  for module_index, module_ in program.modules {
    interface_cache_write_string(output, program.module_paths[module_index])
    planning_write_id(output, module_.module_id)
    planning_write_digest(
      output,
      body_inference_source_digest(program, module_index),
    )
    let interface_ = match
      body_inference_interface_digest(frozen, module_index) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    planning_write_digest(output, interface_)
    let evidence = match
      @semantic.frozen_interface_body_evidence_fingerprint(
        frozen.interfaces[module_index],
      ) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    interface_cache_write_string(output, evidence)
  }
  Ok(@crypto.sha256(output.to_bytes()))
}

///|
fn wasmgc_fragment_cache_key(
  program : @semantic.CollectedProgram,
  module_index : Int,
  program_context : FixedArray[Byte],
) -> (String, FixedArray[Byte], FixedArray[Byte]) {
  let source = body_inference_source_digest(program, module_index)
  let output = Buffer()
  output.write_bytes(b"DEW_WASMGC_FRAGMENT_CACHE_KEY_V1\x00")
  interface_cache_write_string(output, program.module_paths[module_index])
  planning_write_id(output, program.modules[module_index].module_id)
  planning_write_digest(output, source)
  planning_write_digest(output, program_context)
  let key = @crypto.sha256(output.to_bytes())
  (@crypto.bytes_to_hex_string(key), key, source)
}

///|
fn validate_cached_type_layouts(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
  module_index : Int,
  value : @semantic.PlannedModuleTypeLayouts,
) -> Result[Unit, String] {
  let collected = program.modules[module_index]
  if value.module_id != collected.module_id {
    return Err("cached type-layout module identity mismatch")
  }
  let lookup_length_is_valid = value.layout_by_declaration.length() ==
    collected.declaration_locations.length() ||
    (value.layouts.length() == 0 && value.layout_by_declaration.length() == 0)
  if !lookup_length_is_valid ||
    value.fields.length() != collected.fields.length() ||
    value.variants.length() != collected.variants.length() {
    return Err("cached type-layout arena length mismatch")
  }
  let resolved_count = frozen.interfaces[module_index].resolved_types.types.length()
  for field in value.fields {
    if field.type_ < 0 || field.type_ >= resolved_count {
      return Err("cached type-layout field type is out of range")
    }
  }
  for type_ in value.payload_types {
    if type_ < 0 || type_ >= resolved_count {
      return Err("cached type-layout payload type is out of range")
    }
  }
  @semantic.validate_planned_module_type_layouts(value)
}

///|
fn lookup_type_layout_cache(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
  module_index : Int,
) -> Result[@semantic.PlannedModuleTypeLayouts?, String] {
  let (fingerprint, key, source, interface_) = match
    type_layout_cache_key(program, frozen, module_index) {
    Ok(value) => value
    Err(error) => return Err("cannot fingerprint type-layout cache: \{error}")
  }
  let path = type_layout_cache_file(fingerprint)
  if !@fs.path_exists(path) {
    return Ok(None)
  }
  let bytes = @fs.read_file_to_bytes(path) catch {
    error => return Err("cannot read type-layout cache \{path}: \{error}")
  }
  let payload = match
    unwrap_type_layout_cache_payload(bytes, key, source, interface_) {
    Ok(value) => value
    Err(error) => return Err("corrupt type-layout cache \{path}: \{error}")
  }
  let layouts = match
    @semantic.deserialize_planned_module_type_layouts(payload) {
    Ok(value) => value
    Err(error) => return Err("corrupt type-layout cache \{path}: \{error}")
  }
  match validate_cached_type_layouts(program, frozen, module_index, layouts) {
    Ok(_) => Ok(Some(layouts))
    Err(error) => Err("corrupt type-layout cache \{path}: \{error}")
  }
}

///|
fn store_type_layout_cache(
  program : @semantic.CollectedProgram,
  frozen : @semantic.FrozenProgramInterfaces,
  module_index : Int,
  layouts : @semantic.PlannedModuleTypeLayouts,
) -> Result[Unit, String] {
  let (fingerprint, key, source, interface_) = match
    type_layout_cache_key(program, frozen, module_index) {
    Ok(value) => value
    Err(error) => return Err("cannot fingerprint type-layout cache: \{error}")
  }
  let payload = match @semantic.serialize_planned_module_type_layouts(layouts) {
    Ok(value) => value
    Err(error) => return Err("cannot serialize type-layout cache: \{error}")
  }
  let envelope = match
    wrap_type_layout_cache_payload(key, source, interface_, payload) {
    Ok(value) => value
    Err(error) => return Err("cannot envelope type-layout cache: \{error}")
  }
  let root = interface_cache_root()
  match ensure_interface_cache_root(root) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let directory = type_layout_cache_directory()
  match ensure_cache_directory(directory) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let path = type_layout_cache_file(fingerprint)
  let path_bytes = @utf8.encode(path)
  let result = cache_platform_atomic_write(
    path_bytes,
    path_bytes.length(),
    envelope,
  )
  if result != 0 {
    return Err(
      "cannot atomically write type-layout cache \{path}: errno \{-result}",
    )
  }
  Ok(())
}

///|
fn validate_cached_wasmgc_fragments(
  lowering : @semantic.PlannedProgramLowering,
  module_index : Int,
  options : @semantic.WasmGCPlanningOptions,
  value : @semantic.PlannedModuleWasmGCFragments,
) -> Result[Unit, String] {
  let module_ = lowering.modules[module_index]
  match
    @semantic.validate_cached_module_wasmgc_fragments(
      value,
      module_.module_id,
      options,
    ) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  if value.type_index_by_declaration.length() !=
    module_.type_layouts.layout_by_declaration.length() ||
    value.payload_type_index_by_variant.length() !=
    module_.type_layouts.variants.length() ||
    value.field_names.length() != module_.type_layouts.fields.length() ||
    value.lambda_closure_type_indices.length() != module_.lambdas.length() ||
    value.lambda_entry_signature_indices.length() != module_.lambdas.length() ||
    value.lambda_capture_field_indices.length() != module_.captures.length() ||
    value.lambda_capture_parameter_indices.length() != module_.captures.length() ||
    value.function_by_declaration.length() !=
    module_.functions.callable_by_declaration.length() ||
    value.function_type_by_resolved.length() != module_.resolved_types.length() ||
    value.closure_entry_type_by_resolved.length() !=
    module_.resolved_types.length() {
    return Err("cached WasmGC fragment arena length mismatch")
  }
  Ok(())
}

///|
fn lookup_wasmgc_fragment_cache(
  program : @semantic.CollectedProgram,
  lowering : @semantic.PlannedProgramLowering,
  module_index : Int,
  program_context : FixedArray[Byte],
  options : @semantic.WasmGCPlanningOptions,
) -> Result[@semantic.PlannedModuleWasmGCFragments?, String] {
  let (fingerprint, key, source) = wasmgc_fragment_cache_key(
    program, module_index, program_context,
  )
  let path = wasmgc_fragment_cache_file(fingerprint)
  if !@fs.path_exists(path) {
    return Ok(None)
  }
  let bytes = @fs.read_file_to_bytes(path) catch {
    error => return Err("cannot read WasmGC fragment cache \{path}: \{error}")
  }
  let payload = match
    unwrap_wasmgc_fragment_cache_payload(bytes, key, source, program_context) {
    Ok(value) => value
    Err(error) => return Err("corrupt WasmGC fragment cache \{path}: \{error}")
  }
  let fragments = match
    @semantic.deserialize_planned_module_wasmgc_fragments(payload) {
    Ok(value) => value
    Err(error) => return Err("corrupt WasmGC fragment cache \{path}: \{error}")
  }
  match
    validate_cached_wasmgc_fragments(lowering, module_index, options, fragments) {
    Ok(_) => Ok(Some(fragments))
    Err(error) => Err("corrupt WasmGC fragment cache \{path}: \{error}")
  }
}

///|
fn store_wasmgc_fragment_cache(
  program : @semantic.CollectedProgram,
  lowering : @semantic.PlannedProgramLowering,
  module_index : Int,
  program_context : FixedArray[Byte],
  options : @semantic.WasmGCPlanningOptions,
  fragments : @semantic.PlannedModuleWasmGCFragments,
) -> Result[Unit, String] {
  match
    validate_cached_wasmgc_fragments(lowering, module_index, options, fragments) {
    Ok(_) => ()
    Err(error) => return Err("cannot store WasmGC fragment cache: \{error}")
  }
  let source = body_inference_source_digest(program, module_index)
  let output = Buffer()
  output.write_bytes(b"DEW_WASMGC_FRAGMENT_CACHE_KEY_V1\x00")
  interface_cache_write_string(output, program.module_paths[module_index])
  planning_write_id(output, program.modules[module_index].module_id)
  planning_write_digest(output, source)
  planning_write_digest(output, program_context)
  let key = @crypto.sha256(output.to_bytes())
  let fingerprint = @crypto.bytes_to_hex_string(key)
  let payload = match
    @semantic.serialize_planned_module_wasmgc_fragments(fragments) {
    Ok(value) => value
    Err(error) => return Err("cannot serialize WasmGC fragment cache: \{error}")
  }
  let envelope = match
    wrap_wasmgc_fragment_cache_payload(key, source, program_context, payload) {
    Ok(value) => value
    Err(error) => return Err("cannot envelope WasmGC fragment cache: \{error}")
  }
  let root = interface_cache_root()
  match ensure_interface_cache_root(root) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let directory = wasmgc_fragment_cache_directory()
  match ensure_cache_directory(directory) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let path = wasmgc_fragment_cache_file(fingerprint)
  let path_bytes = @utf8.encode(path)
  let result = cache_platform_atomic_write(
    path_bytes,
    path_bytes.length(),
    envelope,
  )
  if result != 0 {
    return Err(
      "cannot atomically write WasmGC fragment cache \{path}: errno \{-result}",
    )
  }
  Ok(())
}

///|
pub fn plan_program_lowering_with_cache(
  program : @semantic.CollectedProgram,
  analyzed : @semantic.AnalyzedProgramSemantics,
) -> Result[CachedProgramLowering, String] {
  let enabled = planning_cache_enabled()
  if !enabled {
    return Ok({
      lowering: @semantic.plan_program_lowering(program, analyzed),
      status: {
        enabled: false,
        layout_hits: 0,
        layout_misses: 0,
        fragment_hits: 0,
        fragment_misses: 0,
      },
    })
  }
  let layouts : Array[@semantic.PlannedModuleTypeLayouts] = []
  let mut hits = 0
  let mut misses = 0
  for module_index, collected in program.modules {
    match lookup_type_layout_cache(program, analyzed.frozen, module_index) {
      Err(error) => return Err(error)
      Ok(Some(value)) => {
        hits += 1
        layouts.push(value)
      }
      Ok(None) => {
        misses += 1
        let value = @semantic.plan_module_type_layouts(
          collected,
          analyzed.frozen.interfaces[module_index].resolved_types,
        )
        match
          store_type_layout_cache(program, analyzed.frozen, module_index, value) {
          Ok(_) => ()
          Err(error) => return Err(error)
        }
        layouts.push(value)
      }
    }
  }
  Ok({
    lowering: @semantic.plan_program_lowering_with_type_layouts(
      program, analyzed, layouts,
    ),
    status: {
      enabled: true,
      layout_hits: hits,
      layout_misses: misses,
      fragment_hits: 0,
      fragment_misses: 0,
    },
  })
}

///|
pub fn plan_program_wasmgc_link_with_cache(
  program : @semantic.CollectedProgram,
  analyzed : @semantic.AnalyzedProgramSemantics,
  lowering : @semantic.PlannedProgramLowering,
  root_module_index : Int,
  options : @semantic.WasmGCPlanningOptions,
) -> Result[CachedProgramWasmGCLink, String] {
  let enabled = planning_cache_enabled()
  if !enabled {
    let fragments = @semantic.plan_program_wasmgc_fragments_with_options_and_cache_hooks(
      analyzed,
      lowering,
      options,
      root_module_index,
      Array::make(lowering.modules.length(), None),
      fn(_, _) { () },
    )
    return Ok({
      link: @semantic.link_program_wasmgc_fragments(
        fragments, lowering, root_module_index,
      ),
      status: {
        enabled: false,
        layout_hits: 0,
        layout_misses: 0,
        fragment_hits: 0,
        fragment_misses: 0,
      },
    })
  }
  let context = match
    wasmgc_fragment_program_context(
      program,
      analyzed.frozen,
      root_module_index,
      options,
    ) {
    Ok(value) => value
    Err(error) =>
      return Err("cannot fingerprint WasmGC fragment cache: \{error}")
  }
  let cached : Array[@semantic.PlannedModuleWasmGCFragments?] = Array::make(
    lowering.modules.length(),
    None,
  )
  let mut hits = 0
  let mut misses = 0
  for module_index, _ in lowering.modules {
    match
      lookup_wasmgc_fragment_cache(
        program, lowering, module_index, context, options,
      ) {
      Err(error) => return Err(error)
      Ok(Some(value)) => {
        cached[module_index] = Some(value)
        hits += 1
      }
      Ok(None) => misses += 1
    }
  }
  let mut cache_error : String? = None
  let fragments = @semantic.plan_program_wasmgc_fragments_with_options_and_cache_hooks(
    analyzed,
    lowering,
    options,
    root_module_index,
    cached,
    fn(module_index, fresh) {
      if cache_error is Some(_) {
        return
      }
      match
        store_wasmgc_fragment_cache(
          program, lowering, module_index, context, options, fresh,
        ) {
        Ok(_) => ()
        Err(error) => cache_error = Some(error)
      }
    },
  )
  match cache_error {
    Some(error) => return Err(error)
    None => ()
  }
  Ok({
    link: @semantic.link_program_wasmgc_fragments(
      fragments, lowering, root_module_index,
    ),
    status: {
      enabled: true,
      layout_hits: 0,
      layout_misses: 0,
      fragment_hits: hits,
      fragment_misses: misses,
    },
  })
}
