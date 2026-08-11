///|
fn emit_starshine_program_type_section(
  planned : @semantic.PlannedProgramWasmGCLink,
  helper_plan : StarshineProgramAdapterHelperPlan,
) -> @lib.TypeSec {
  let rec_types : Array[@lib.RecType] = []
  if planned.program_type_groups.length() > 0 {
    for group in planned.program_type_groups {
      let subtypes : Array[@lib.SubType] = []
      for index in 0..<group.types.length {
        let node = planned.program_physical_types[group.types.start + index]
        subtypes.push(
          starshine_program_group_physical_subtype(planned, node, group),
        )
      }
      rec_types.push(@lib.RecType::group(subtypes))
    }
    for signature in planned.program_signature_types {
      rec_types.push(starshine_program_signature_rec_type(planned, signature))
    }
  } else {
    for scc in planned.graph.sccs {
      for member_index in 0..<scc.length {
        let module_index = planned.graph.scc_modules[scc.start + member_index]
        let module_ = planned.modules[module_index]
        for group in module_.type_groups {
          let subtypes : Array[@lib.SubType] = []
          let mut has_recursive_reference = false
          for index in 0..<group.types.length {
            let (subtype, recursive) = starshine_program_physical_subtype(
              planned,
              module_index,
              module_.physical_types[group.types.start + index],
            )
            subtypes.push(subtype)
            has_recursive_reference = has_recursive_reference || recursive
          }
          if subtypes.length() == 1 && !has_recursive_reference {
            rec_types.push(@lib.RecType::new(subtypes[0]))
          } else {
            rec_types.push(@lib.RecType::group(subtypes))
          }
        }
        for signature in planned.program_signature_types {
          if signature.module_index == module_index {
            rec_types.push(
              starshine_program_signature_rec_type(planned, signature),
            )
          }
        }
      }
    }
  }
  for slot in 0..<planned.erased_box_type_indices.length() {
    if planned.erased_box_type_indices[slot] >= 0 {
      rec_types.push(starshine_program_erased_box_rec_type(slot))
    }
  }
  if planned.initializer_type_index >= 0 {
    rec_types.push(
      @lib.RecType::new(@lib.SubType::comp_type(@lib.CompType::func([], []))),
    )
  }
  let mut uses_text = false
  for function_ in planned.functions {
    if function_.elided {
      continue
    }
    match function_.kind {
      @semantic.PlannedWasmRuntimeFunction(name) =>
        if name.length() > 0 {
          uses_text = true
          break
        }
      _ => ()
    }
  }
  if !uses_text {
    for module_ in planned.modules {
      if starshine_plan_uses_text(module_) {
        uses_text = true
        break
      }
    }
  }
  if uses_text {
    for runtime_type in starshine_text_runtime_types(planned.type_count) {
      rec_types.push(runtime_type)
    }
  }
  let mut uses_fixed_array = false
  for module_ in planned.modules {
    if module_.uses_fixed_array_runtime {
      uses_fixed_array = true
      break
    }
  }
  if uses_fixed_array {
    for runtime_type in starshine_fixed_array_runtime_types() {
      rec_types.push(runtime_type)
    }
  }
  let mut uses_map = false
  for module_ in planned.modules {
    if module_.uses_map_runtime {
      uses_map = true
      break
    }
  }
  if uses_map {
    for runtime_type in starshine_map_runtime_types() {
      rec_types.push(runtime_type)
    }
  }
  for helper_index in 0..<helper_plan.helpers.length() {
    let helper = helper_plan.helpers[helper_index]
    let mut signature_type_index = -1
    for previous in 0..<helper_index {
      let candidate = helper_plan.helpers[previous]
      if candidate.module_index == helper.module_index &&
        candidate.declaration == helper.declaration {
        signature_type_index = candidate.signature_type_index
        break
      }
    }
    if signature_type_index < 0 {
      let nominal_type = match planned.type_lookup.get(helper.declaration) {
        Some(value) => value
        None => continue
      }
      signature_type_index = rec_types.length()
      let nominal = starshine_nominal_ref(
        @lib.TypeIdx::new(nominal_type.reinterpret_as_uint()),
      )
      rec_types.push(
        @lib.RecType::new(
          @lib.SubType::comp_type(@lib.CompType::func([nominal], [nominal])),
        ),
      )
    }
    helper_plan.helpers[helper_index] = { ..helper, signature_type_index, }
  }
  for wrapper_index in 0..<helper_plan.wrappers.length() {
    let wrapper = helper_plan.wrappers[wrapper_index]
    let source_direct_type = starshine_program_callback_signature_index(
      helper_plan,
      wrapper_index,
      wrapper.source_parameter_codes,
      wrapper.source_result_code,
      false,
      wrapper.source_direct_type,
      rec_types,
    )
    let source_entry_type = starshine_program_callback_signature_index(
      helper_plan,
      wrapper_index,
      wrapper.source_parameter_codes,
      wrapper.source_result_code,
      true,
      wrapper.source_entry_type,
      rec_types,
    )
    let target_direct_type = starshine_program_callback_signature_index(
      helper_plan,
      wrapper_index,
      wrapper.target_parameter_codes,
      wrapper.target_result_code,
      false,
      wrapper.target_direct_type,
      rec_types,
    )
    let target_entry_type = starshine_program_callback_signature_index(
      helper_plan,
      wrapper_index,
      wrapper.target_parameter_codes,
      wrapper.target_result_code,
      true,
      wrapper.target_entry_type,
      rec_types,
    )
    helper_plan.wrappers[wrapper_index] = {
      ..wrapper,
      source_direct_type,
      source_entry_type,
      target_direct_type,
      target_entry_type,
    }
    let wrapper = helper_plan.wrappers[wrapper_index]
    let mut wrapper_type_index = -1
    for previous in 0..<wrapper_index {
      let candidate = helper_plan.wrappers[previous]
      if candidate.adapter_function == wrapper.adapter_function &&
        candidate.function_type == wrapper.function_type {
        wrapper_type_index = candidate.wrapper_type_index
        break
      }
    }
    if wrapper_type_index < 0 {
      let module_ = planned.modules[wrapper.module_index]
      let closure_type = planned.physical_type_index(
        wrapper.module_index,
        module_.closure_type_index,
      )
      if closure_type < 0 {
        continue
      }
      wrapper_type_index = rec_types.length()
      rec_types.push(
        @lib.RecType::new(
          @lib.SubType::new(
            true,
            [@lib.TypeIdx::new(closure_type.reinterpret_as_uint())],
            @lib.CompType::struct_([
              @lib.FieldType::new(
                @lib.StorageType::val_type(@lib.ValType::funcref()),
                @lib.Mut::const_(),
              ),
              @lib.FieldType::new(
                @lib.StorageType::val_type(@lib.ValType::eqref_null()),
                @lib.Mut::const_(),
              ),
            ]),
          ),
        ),
      )
    }
    helper_plan.wrappers[wrapper_index] = { ..wrapper, wrapper_type_index, }
  }
  for captured_index in 0..<helper_plan.captured_trait_dictionaries.length() {
    let captured = helper_plan.captured_trait_dictionaries[captured_index]
    if captured.module_index < 0 ||
      captured.module_index >= planned.modules.length() ||
      captured.dictionary_index < 0 ||
      captured.dictionary_index >=
      planned.modules[captured.module_index].trait_dictionaries.length() {
      continue
    }
    let dictionary = planned.modules[captured.module_index].trait_dictionaries[captured.dictionary_index]
    let fields : Array[@lib.FieldType] = []
    for _ in 0..<(dictionary.runtime_evidence_parameters.length + 1) {
      fields.push(
        @lib.FieldType::new(
          @lib.StorageType::val_type(@lib.ValType::eqref_null()),
          @lib.Mut::const_(),
        ),
      )
    }
    let capture_type_index = rec_types.length()
    rec_types.push(
      @lib.RecType::new(
        @lib.SubType::new(true, [], @lib.CompType::struct_(fields)),
      ),
    )
    helper_plan.captured_trait_dictionaries[captured_index] = {
      ..captured,
      capture_type_index,
    }
  }
  for closure_index in 0..<helper_plan.evidence_closures.length() {
    let closure = helper_plan.evidence_closures[closure_index]
    let module_ = planned.modules[closure.module_index]
    let closure_base = planned.physical_type_index(
      closure.module_index,
      module_.closure_type_index,
    )
    if closure_base < 0 ||
      closure.reference_index < 0 ||
      closure.reference_index >= planned.evidence_function_references.length() {
      continue
    }
    let reference = planned.evidence_function_references[closure.reference_index]
    let fields : Array[@lib.FieldType] = [
      @lib.FieldType::new(
        @lib.StorageType::val_type(@lib.ValType::funcref()),
        @lib.Mut::const_(),
      ),
    ]
    for _ in 0..<reference.runtime_evidence_parameters.length {
      fields.push(
        @lib.FieldType::new(
          @lib.StorageType::val_type(@lib.ValType::eqref_null()),
          @lib.Mut::const_(),
        ),
      )
    }
    let closure_type_index = rec_types.length()
    rec_types.push(
      @lib.RecType::new(
        @lib.SubType::new(
          true,
          [@lib.TypeIdx::new(closure_base.reinterpret_as_uint())],
          @lib.CompType::struct_(fields),
        ),
      ),
    )
    helper_plan.evidence_closures[closure_index] = {
      ..closure,
      closure_type_index,
    }
  }
  @lib.TypeSec::new(rec_types)
}

///|
fn starshine_import_module(name : Bytes) -> String {
  if name == b"wasi_snapshot_preview1.fd_write" ||
    name == b"wasi_snapshot_preview1.fd_read" {
    "wasi_snapshot_preview1"
  } else {
    "dew"
  }
}

///|
fn starshine_import_field(name : Bytes) -> String {
  if name == b"wasi_snapshot_preview1.fd_write" {
    "fd_write"
  } else if name == b"wasi_snapshot_preview1.fd_read" {
    "fd_read"
  } else {
    @utf8.decode_lossy(name)
  }
}

///|
fn emit_starshine_program_import_section(
  planned : @semantic.PlannedProgramWasmGCLink,
) -> @lib.ImportSec {
  let imports : Array[@lib.Import] = []
  for function_ in planned.functions {
    match function_.kind {
      @semantic.PlannedWasmImportedFunction(name) =>
        if !function_.elided {
          imports.push(
            @lib.Import::new(
              @lib.Name::from_string(starshine_import_module(name)),
              @lib.Name::from_string(starshine_import_field(name)),
              @lib.ExternType::func(
                @lib.TypeIdx::new(
                  function_.signature_type_index.reinterpret_as_uint(),
                ),
              ),
            ),
          )
        }
      @semantic.PlannedWasmInlineBuiltinFunction(_)
      | @semantic.PlannedWasmRuntimeFunction(_)
      | @semantic.PlannedWasmDefinedFunction(_)
      | @semantic.PlannedWasmDefinedLambdaFunction(_)
      | @semantic.PlannedWasmTraitAdapterFunction(_, _)
      | @semantic.PlannedWasmSignatureOnlyFunction => ()
    }
  }
  @lib.ImportSec::new(imports)
}

///|
fn emit_starshine_program_function_section(
  planned : @semantic.PlannedProgramWasmGCLink,
  helper_plan : StarshineProgramAdapterHelperPlan,
) -> @lib.FuncSec {
  let signatures : Array[@lib.TypeIdx] = []
  for function_ in planned.functions {
    match function_.kind {
      @semantic.PlannedWasmDefinedFunction(_)
      | @semantic.PlannedWasmDefinedLambdaFunction(_)
      | @semantic.PlannedWasmRuntimeFunction(_)
      | @semantic.PlannedWasmTraitAdapterFunction(_, _) =>
        if !function_.elided {
          signatures.push(
            @lib.TypeIdx::new(
              function_.signature_type_index.reinterpret_as_uint(),
            ),
          )
        }
      @semantic.PlannedWasmImportedFunction(_)
      | @semantic.PlannedWasmInlineBuiltinFunction(_)
      | @semantic.PlannedWasmSignatureOnlyFunction => ()
    }
  }
  if planned.initializer_type_index >= 0 {
    let signature = @lib.TypeIdx::new(
      planned.initializer_type_index.reinterpret_as_uint(),
    )
    for initializer in planned.initializers {
      if initializer.function_index >= 0 {
        signatures.push(signature)
      }
    }
    signatures.push(signature)
  }
  for helper in helper_plan.helpers {
    signatures.push(
      @lib.TypeIdx::new(helper.signature_type_index.reinterpret_as_uint()),
    )
  }
  for wrapper in helper_plan.wrappers {
    let entry_type = if wrapper.to_erased {
      wrapper.target_entry_type
    } else {
      wrapper.source_entry_type
    }
    signatures.push(@lib.TypeIdx::new(entry_type.reinterpret_as_uint()))
  }
  for closure in helper_plan.evidence_closures {
    signatures.push(
      @lib.TypeIdx::new(closure.entry_type_index.reinterpret_as_uint()),
    )
  }
  @lib.FuncSec::new(signatures)
}

///|
fn starshine_program_uses_wasi(
  planned : @semantic.PlannedProgramWasmGCLink,
) -> Bool {
  for function_ in planned.functions {
    if function_.elided {
      continue
    }
    match function_.kind {
      @semantic.PlannedWasmRuntimeFunction(name) =>
        if name == b"dew_wasi_fd_write" ||
          name == b"dew_wasi_fd_read" ||
          name == b"dew_test_assert" {
          return true
        }
      _ => ()
    }
  }
  false
}

///|
fn emit_starshine_program_export_section(
  planned : @semantic.PlannedProgramWasmGCLink,
) -> @lib.ExportSec {
  let exports : Array[@lib.Export] = []
  for function_ in planned.functions {
    let is_public = match function_.visibility {
      @semantic.Public => true
      @semantic.ModuleVisible => false
    }
    if (
        (function_.module_index == planned.root_module_index && is_public) ||
        function_.is_test_entry
      ) &&
      function_.function_index >= 0 {
      exports.push(
        @lib.Export::new(
          @lib.Name::from_string(@utf8.decode_lossy(function_.name)),
          @lib.ExternIdx::func(
            @lib.FuncIdx::new(function_.function_index.reinterpret_as_uint()),
          ),
        ),
      )
    }
  }
  if planned.startup_function_index >= 0 {
    exports.push(
      @lib.Export::new(
        @lib.Name::from_string("__dew_init"),
        @lib.ExternIdx::func(
          @lib.FuncIdx::new(
            planned.startup_function_index.reinterpret_as_uint(),
          ),
        ),
      ),
    )
  }
  if starshine_program_uses_wasi(planned) {
    exports.push(
      @lib.Export::new(
        @lib.Name::from_string("memory"),
        @lib.ExternIdx::mem(@lib.MemIdx::new(0U)),
      ),
    )
  }
  @lib.ExportSec::new(exports)
}

///|
fn emit_starshine_program_function_body(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  function_ : @semantic.PlannedProgramWasmFunction,
  body_id : @semantic.BodyId,
  helper_plan : StarshineProgramAdapterHelperPlan,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  let module_lowering = lowering.modules[function_.module_index]
  let module_fragments = planned.modules[function_.module_index]
  let body_index = @semantic.semantic_id_local(body_id)
  if body_index < 0 || body_index >= module_lowering.bodies.length() {
    return Err(MissingBody(body_id))
  }
  let body = module_lowering.bodies[body_index]
  let generic_specialization = if function_.specialization_shapes.length > 0 {
    let callable = module_lowering.functions
      .callable_of(function_.declaration)
      .unwrap()
    Some({
      generic_parameters: starshine_callable_generic_parameters(callable),
      shapes: module_fragments.specialization_shapes,
      specialization_shapes: function_.specialization_shapes,
      specialization_evidence: function_.specialization_evidence,
      specialization_abi_key: function_.specialization_abi_key,
    })
  } else {
    None
  }
  let (
    local_indices,
    body_local_types,
    match_local_indices,
    match_result_local_indices,
    conversion_scratch_index,
    fixed_array_ref_scratch_index,
    fixed_array_i32_scratch_index,
    map_key_local_indices,
    map_value_local_indices,
    map_ref_scratch_index,
    map_bucket_scratch_index,
    map_hash_scratch_index,
    map_entry_scratch_index,
    map_previous_scratch_index,
    map_growth_index_scratch_index,
    control_state_local_indices,
    control_result_local_indices,
  ) = starshine_body_locals(
    module_lowering,
    module_fragments,
    Some(planned),
    generic_specialization,
    body,
    0,
  )
  match generic_specialization {
    Some(specialization) =>
      for local_id in 0..<body.locals.length {
        let planned_local = module_lowering.locals[body.locals.start + local_id]
        let shape = starshine_specialized_shape(
          module_lowering,
          Some(specialization),
          planned_local.type_,
          planned_local.shape,
        )
        if shape != planned_local.shape {
          let wasm_index = local_indices[local_id]
          let body_index = wasm_index - function_.parameters.length
          if body_index >= 0 && body_index < body_local_types.length() {
            match starshine_shape_value_type(shape) {
              Some(value) => body_local_types[body_index] = value
              None => ()
            }
          }
        }
      }
    None => ()
  }
  let (function_reference_cache_indices, cache_count) = starshine_function_reference_cache_indices(
    module_lowering,
    Some(planned),
    function_.module_index,
    body,
    function_.parameters.length + body_local_types.length(),
  )
  for _ in 0..<cache_count {
    body_local_types.push(@lib.ValType::eqref_null())
  }
  match
    starshine_emit_body_instructions(
      module_lowering,
      module_fragments,
      {
        program: Some(planned),
        module_index: function_.module_index,
        helper_plan: Some(helper_plan),
      },
      body,
      -1,
      local_indices,
      match_local_indices,
      match_result_local_indices,
      function_reference_cache_indices,
      conversion_scratch_index,
      fixed_array_ref_scratch_index,
      fixed_array_i32_scratch_index,
      map_key_local_indices,
      map_value_local_indices,
      map_ref_scratch_index,
      map_bucket_scratch_index,
      map_hash_scratch_index,
      map_entry_scratch_index,
      map_previous_scratch_index,
      map_growth_index_scratch_index,
      control_state_local_indices,
      control_result_local_indices,
      generic_specialization,
    ) {
    Ok(instructions) => {
      starshine_append_program_result_cast(planned, function_, instructions)
      let prefixed = match
        starshine_function_reference_cache_prefix(
          module_lowering,
          module_fragments,
          Some(planned),
          function_.module_index,
          body,
          function_reference_cache_indices,
        ) {
        Ok(prefix) => prefix
        Err(error) => return Err(error)
      }
      append_starshine_instructions(prefixed, instructions)
      Ok(
        @lib.Func::new(
          @lib.Locals::from_types(body_local_types),
          @lib.Expr::new(prefixed),
        ),
      )
    }
    Err(error) => Err(error)
  }
}

///|
fn starshine_program_global_function_type_index(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  initializer : @semantic.PlannedProgramModuleInitializer,
) -> Int {
  let module_ = lowering.modules[initializer.module_index]
  let body = module_.bodies[@semantic.semantic_id_local(initializer.body)]
  if body.root_type >= -1 {
    return -1
  }
  let resolved_type = -body.root_type - 2
  let fragments = planned.modules[initializer.module_index]
  if fragments.closure_type_index >= 0 {
    return -1
  }
  if resolved_type < 0 ||
    resolved_type >= fragments.function_type_by_resolved.length() {
    return -1
  }
  let local_type = fragments.function_type_by_resolved[resolved_type]
  if local_type < 0 {
    return -1
  }
  planned.signature_type_index(initializer.module_index, local_type)
}

///|
fn starshine_program_global_value_type(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  initializer : @semantic.PlannedProgramModuleInitializer,
) -> @lib.ValType {
  let function_type = starshine_program_global_function_type_index(
    lowering, planned, initializer,
  )
  if function_type >= 0 {
    return starshine_function_ref(
      @lib.TypeIdx::new(function_type.reinterpret_as_uint()),
    )
  }
  match initializer.shape {
    @semantic.I8PlannedValueShape
    | @semantic.I16PlannedValueShape
    | @semantic.I32PlannedValueShape
    | @semantic.U8PlannedValueShape
    | @semantic.U16PlannedValueShape
    | @semantic.U32PlannedValueShape
    | @semantic.Swar32PlannedValueShape => @lib.ValType::i32()
    @semantic.I64PlannedValueShape
    | @semantic.U64PlannedValueShape
    | @semantic.Swar64PlannedValueShape => @lib.ValType::i64()
    @semantic.F32PlannedValueShape => @lib.ValType::f32()
    @semantic.F64PlannedValueShape => @lib.ValType::f64()
    @semantic.V128PlannedValueShape => @lib.ValType::v128()
    @semantic.RefPlannedValueShape
    | @semantic.GenericPlannedValueShape
    | @semantic.ErrorPlannedValueShape => @lib.ValType::eqref_null()
    @semantic.UnitPlannedValueShape | @semantic.NeverPlannedValueShape =>
      @lib.ValType::bottom()
  }
}

///|
fn starshine_program_global_default(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  initializer : @semantic.PlannedProgramModuleInitializer,
) -> @lib.Expr {
  let function_type = starshine_program_global_function_type_index(
    lowering, planned, initializer,
  )
  if function_type >= 0 {
    return @lib.Expr::new([
      @lib.Instruction::ref_null(
        @lib.HeapType::new(
          @lib.TypeIdx::new(function_type.reinterpret_as_uint()),
        ),
      ),
    ])
  }
  let instructions = match initializer.shape {
    @semantic.I8PlannedValueShape
    | @semantic.I16PlannedValueShape
    | @semantic.I32PlannedValueShape
    | @semantic.U8PlannedValueShape
    | @semantic.U16PlannedValueShape
    | @semantic.U32PlannedValueShape
    | @semantic.Swar32PlannedValueShape =>
      [@lib.Instruction::i32_const(@lib.I32::new(0))]
    @semantic.I64PlannedValueShape
    | @semantic.U64PlannedValueShape
    | @semantic.Swar64PlannedValueShape =>
      [@lib.Instruction::i64_const(@lib.I64::new(0L))]
    @semantic.F32PlannedValueShape =>
      [@lib.Instruction::f32_const(@lib.F32::new(0.0))]
    @semantic.F64PlannedValueShape =>
      [@lib.Instruction::f64_const(@lib.F64::new(0.0))]
    @semantic.V128PlannedValueShape =>
      [
        @lib.Instruction::v128_const(
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ),
      ]
    @semantic.RefPlannedValueShape
    | @semantic.GenericPlannedValueShape
    | @semantic.ErrorPlannedValueShape =>
      [@lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::none()))]
    @semantic.UnitPlannedValueShape | @semantic.NeverPlannedValueShape => []
  }
  @lib.Expr::new(instructions)
}

///|
fn starshine_program_constant_global_initializer(
  lowering : @semantic.PlannedProgramLowering,
  initializer : @semantic.PlannedProgramModuleInitializer,
) -> @lib.Expr? {
  if !initializer.constant {
    return None
  }
  let body = lowering.modules[initializer.module_index].bodies[@semantic.semantic_id_local(
      initializer.body,
    )]
  let expression = match body.root {
    @semantic.ExpressionBodyRoot(expression) => expression
    @semantic.BlockBodyRoot(_) => return None
  }
  let kind = lowering.modules[initializer.module_index].expressions[expression].kind
  let instruction = match kind {
    @semantic.PlannedI8Const(value) =>
      @lib.Instruction::i32_const(
        @lib.I32::new(starshine_signed_i8_constant(value)),
      )
    @semantic.PlannedI16Const(value) =>
      @lib.Instruction::i32_const(
        @lib.I32::new(starshine_signed_i16_constant(value)),
      )
    @semantic.PlannedU8Const(value) =>
      @lib.Instruction::i32_const(@lib.I32::new((value & 0xFFUL).to_int()))
    @semantic.PlannedU16Const(value) =>
      @lib.Instruction::i32_const(@lib.I32::new((value & 0xFFFFUL).to_int()))
    @semantic.PlannedI32Const(value) | @semantic.PlannedU32Const(value) =>
      @lib.Instruction::i32_const(@lib.I32::new(value.to_int()))
    @semantic.PlannedI64Const(value) | @semantic.PlannedU64Const(value) =>
      @lib.Instruction::i64_const(@lib.I64::new(value.reinterpret_as_int64()))
    @semantic.PlannedF32Const(value) =>
      @lib.Instruction::f32_const(@lib.F32::new(value))
    @semantic.PlannedF64Const(value) =>
      @lib.Instruction::f64_const(@lib.F64::new(value))
    @semantic.PlannedBoolConst(value) =>
      @lib.Instruction::i32_const(@lib.I32::new(if value { 1 } else { 0 }))
    _ => return None
  }
  Some(@lib.Expr::new([instruction]))
}

///|
fn emit_starshine_program_global_section(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
) -> @lib.GlobalSec {
  let globals : Array[@lib.Global] = []
  for initializer in planned.initializers {
    if initializer.global_index < 0 {
      continue
    }
    globals.push(
      @lib.Global::new(
        @lib.GlobalType::new(
          starshine_program_global_value_type(lowering, planned, initializer),
          !initializer.constant,
        ),
        match
          starshine_program_constant_global_initializer(lowering, initializer) {
          Some(value) => value
          None =>
            starshine_program_global_default(lowering, planned, initializer)
        },
      ),
    )
  }
  for _ in planned.function_reference_singletons {
    globals.push(
      @lib.Global::new(
        @lib.GlobalType::new(@lib.ValType::eqref_null(), true),
        @lib.Expr::new([
          @lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::eq())),
        ]),
      ),
    )
  }
  for dictionary_global in planned.trait_dictionary_globals {
    let dictionary = planned.modules[dictionary_global.module_index].trait_dictionaries[dictionary_global.dictionary_index]
    let vtable_type = planned.physical_type_index(
      dictionary_global.module_index,
      dictionary.vtable_type_index,
    )
    globals.push(
      @lib.Global::new(
        @lib.GlobalType::new(
          @lib.ValType::ref_type(
            @lib.RefType::new(
              true,
              @lib.HeapType::new(
                @lib.TypeIdx::new(vtable_type.reinterpret_as_uint()),
              ),
            ),
          ),
          true,
        ),
        @lib.Expr::new([
          @lib.Instruction::ref_null(
            @lib.HeapType::new(
              @lib.TypeIdx::new(vtable_type.reinterpret_as_uint()),
            ),
          ),
        ]),
      ),
    )
  }
  @lib.GlobalSec::new(globals)
}

///|
fn emit_starshine_program_initializer_body(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  initializer : @semantic.PlannedProgramModuleInitializer,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  let module_lowering = lowering.modules[initializer.module_index]
  let module_fragments = planned.modules[initializer.module_index]
  let body_index = @semantic.semantic_id_local(initializer.body)
  if body_index < 0 || body_index >= module_lowering.bodies.length() {
    return Err(MissingBody(initializer.body))
  }
  let body = module_lowering.bodies[body_index]
  let (
    local_indices,
    body_local_types,
    match_local_indices,
    match_result_local_indices,
    conversion_scratch_index,
    fixed_array_ref_scratch_index,
    fixed_array_i32_scratch_index,
    map_key_local_indices,
    map_value_local_indices,
    map_ref_scratch_index,
    map_bucket_scratch_index,
    map_hash_scratch_index,
    map_entry_scratch_index,
    map_previous_scratch_index,
    map_growth_index_scratch_index,
    control_state_local_indices,
    control_result_local_indices,
  ) = starshine_body_locals(
    module_lowering,
    module_fragments,
    Some(planned),
    None,
    body,
    0,
  )
  let (function_reference_cache_indices, cache_count) = starshine_function_reference_cache_indices(
    module_lowering,
    Some(planned),
    initializer.module_index,
    body,
    body_local_types.length(),
  )
  for _ in 0..<cache_count {
    body_local_types.push(@lib.ValType::eqref_null())
  }
  match
    starshine_emit_body_instructions(
      module_lowering,
      module_fragments,
      {
        program: Some(planned),
        module_index: initializer.module_index,
        helper_plan: None,
      },
      body,
      -1,
      local_indices,
      match_local_indices,
      match_result_local_indices,
      function_reference_cache_indices,
      conversion_scratch_index,
      fixed_array_ref_scratch_index,
      fixed_array_i32_scratch_index,
      map_key_local_indices,
      map_value_local_indices,
      map_ref_scratch_index,
      map_bucket_scratch_index,
      map_hash_scratch_index,
      map_entry_scratch_index,
      map_previous_scratch_index,
      map_growth_index_scratch_index,
      control_state_local_indices,
      control_result_local_indices,
      None,
    ) {
    Ok(instructions) => {
      if initializer.global_index >= 0 {
        instructions.push(
          @lib.Instruction::global_set(
            @lib.GlobalIdx::new(initializer.global_index.reinterpret_as_uint()),
          ),
        )
      }
      let prefixed = match
        starshine_function_reference_cache_prefix(
          module_lowering,
          module_fragments,
          Some(planned),
          initializer.module_index,
          body,
          function_reference_cache_indices,
        ) {
        Ok(prefix) => prefix
        Err(error) => return Err(error)
      }
      append_starshine_instructions(prefixed, instructions)
      Ok(
        @lib.Func::new(
          @lib.Locals::from_types(body_local_types),
          @lib.Expr::new(prefixed),
        ),
      )
    }
    Err(error) => Err(error)
  }
}

///|
fn starshine_program_startup_body(
  planned : @semantic.PlannedProgramWasmGCLink,
) -> @lib.Func {
  let instructions : Array[@lib.Instruction] = []
  for singleton in planned.function_reference_singletons {
    if singleton.function_index >= 0 {
      instructions.push(
        @lib.Instruction::ref_func(
          @lib.FuncIdx::new(singleton.function_index.reinterpret_as_uint()),
        ),
      )
      let module_ = planned.modules[singleton.module_index]
      let closure_type = starshine_local_physical_type_index(
        Some(planned),
        singleton.module_index,
        module_.closure_type_index,
      )
      instructions.push(
        @lib.Instruction::struct_new(
          @lib.TypeIdx::new(closure_type.reinterpret_as_uint()),
        ),
      )
      instructions.push(
        @lib.Instruction::global_set(
          @lib.GlobalIdx::new(singleton.global_index.reinterpret_as_uint()),
        ),
      )
    }
  }
  for dictionary_global in planned.trait_dictionary_globals {
    let module_ = planned.modules[dictionary_global.module_index]
    let dictionary = module_.trait_dictionaries[dictionary_global.dictionary_index]
    for index in 0..<dictionary.methods.length {
      let method_info = module_.trait_methods[dictionary.methods.start + index]
      let adapter = module_.functions[method_info.adapter_function]
      match planned.function_of(adapter.declaration) {
        Some(function_) if function_.function_index >= 0 =>
          instructions.push(
            @lib.Instruction::ref_func(
              @lib.FuncIdx::new(function_.function_index.reinterpret_as_uint()),
            ),
          )
        _ => ()
      }
    }
    let vtable_type = planned.physical_type_index(
      dictionary_global.module_index,
      dictionary.vtable_type_index,
    )
    instructions.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(vtable_type.reinterpret_as_uint()),
      ),
    )
    instructions.push(
      @lib.Instruction::global_set(
        @lib.GlobalIdx::new(
          dictionary_global.global_index.reinterpret_as_uint(),
        ),
      ),
    )
  }
  for initializer in planned.initializers {
    if initializer.function_index >= 0 {
      instructions.push(
        @lib.Instruction::call(
          @lib.FuncIdx::new(initializer.function_index.reinterpret_as_uint()),
        ),
      )
    }
  }
  @lib.Func::new(@lib.Locals::from_types([]), @lib.Expr::new(instructions))
}

///|
fn emit_starshine_program_code_section(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  helper_plan : StarshineProgramAdapterHelperPlan,
) -> Result[@lib.CodeSec, StarshineCodeEmissionError] {
  let functions : Array[@lib.Func] = []
  for function_ in planned.functions {
    match function_.kind {
      @semantic.PlannedWasmDefinedFunction(body) =>
        if !function_.elided {
          match
            emit_starshine_program_function_body(
              lowering, planned, function_, body, helper_plan,
            ) {
            Ok(function_body) => functions.push(function_body)
            Err(error) => return Err(error)
          }
        }
      @semantic.PlannedWasmDefinedLambdaFunction(lambda) =>
        if !function_.elided {
          match
            emit_starshine_lambda_body(
              lowering.modules[function_.module_index],
              planned.modules[function_.module_index],
              Some(planned),
              function_.module_index,
              lambda,
            ) {
            Ok(function_body) => functions.push(function_body)
            Err(error) => return Err(error)
          }
        }
      @semantic.PlannedWasmTraitAdapterFunction(implementation_method, _) =>
        if !function_.elided {
          match
            emit_starshine_program_trait_adapter_body(
              planned, function_, implementation_method, helper_plan,
            ) {
            Ok(function_body) => functions.push(function_body)
            Err(error) => return Err(error)
          }
        }
      @semantic.PlannedWasmRuntimeFunction(name) =>
        if !function_.elided {
          if function_.erased_adapter_target >= 0 {
            match
              starshine_program_erased_adapter_body(
                lowering, planned, function_, helper_plan,
              ) {
              Ok(function_body) => functions.push(function_body)
              Err(error) => return Err(error)
            }
          } else if name == b"dew_test_assert" {
            functions.push(
              starshine_test_assert_body(
                planned.runtime_function_index(b"dew_string_as_bytes"),
                planned.runtime_function_index(b"dew_wasi_fd_write"),
              ),
            )
          } else {
            match
              emit_starshine_text_runtime_function(
                name,
                planned.type_count,
                planned.runtime_function_index(b"dew_bytes_is_valid_utf8"),
                planned.imported_function_index(
                  b"wasi_snapshot_preview1.fd_write",
                ),
                planned.imported_function_index(
                  b"wasi_snapshot_preview1.fd_read",
                ),
              ) {
              Some(function_body) => functions.push(function_body)
              None => return Err(UnsupportedBuiltin(name))
            }
          }
        }
      @semantic.PlannedWasmImportedFunction(_)
      | @semantic.PlannedWasmInlineBuiltinFunction(_)
      | @semantic.PlannedWasmSignatureOnlyFunction => ()
    }
  }
  for initializer in planned.initializers {
    if initializer.function_index >= 0 {
      match
        emit_starshine_program_initializer_body(lowering, planned, initializer) {
        Ok(function_body) => functions.push(function_body)
        Err(error) => return Err(error)
      }
    }
  }
  if planned.startup_function_index >= 0 {
    functions.push(starshine_program_startup_body(planned))
  }
  for helper in helper_plan.helpers {
    match
      emit_starshine_program_adapter_helper_body(
        lowering, planned, helper_plan, helper,
      ) {
      Ok(body) => functions.push(body)
      Err(error) => return Err(error)
    }
  }
  for wrapper in helper_plan.wrappers {
    match
      emit_starshine_program_callback_wrapper_body(
        planned, helper_plan, wrapper,
      ) {
      Ok(body) => functions.push(body)
      Err(error) => return Err(error)
    }
  }
  for closure in helper_plan.evidence_closures {
    match emit_starshine_program_evidence_closure_body(planned, closure) {
      Ok(body) => functions.push(body)
      Err(error) => return Err(error)
    }
  }
  Ok(@lib.CodeSec::new(functions))
}

///|
fn starshine_program_function_reference_element_section(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  helper_plan : StarshineProgramAdapterHelperPlan,
) -> @lib.ElemSec? {
  let referenced : Map[Int, Bool] = Map::default()
  for singleton in planned.function_reference_singletons {
    if singleton.function_index >= 0 {
      referenced[singleton.function_index] = true
    }
  }
  for wrapper in helper_plan.wrappers {
    referenced[wrapper.function_index] = true
  }
  for closure in helper_plan.evidence_closures {
    referenced[closure.function_index] = true
  }
  for function_ in planned.functions {
    match function_.kind {
      @semantic.PlannedWasmTraitAdapterFunction(_, _) if function_.function_index >=
        0 => referenced[function_.function_index] = true
      _ => ()
    }
  }
  for module_index, module_ in lowering.modules {
    for expression in module_.expressions {
      match expression.kind {
        @semantic.PlannedFunctionReference(_, _) => ()
        @semantic.PlannedLambdaClosure(lambda, _) => {
          let module_fragments = planned.modules[module_index]
          let fragment = module_fragments.functions[module_fragments.lambda_function_indices[lambda]]
          match planned.function_of(fragment.declaration) {
            Some(function_) if function_.function_index >= 0 =>
              referenced[function_.function_index] = true
            _ => ()
          }
        }
        _ => ()
      }
    }
  }
  if referenced.length() == 0 {
    return None
  }
  let functions : Array[@lib.FuncIdx] = []
  for function_ in planned.functions {
    if referenced.contains(function_.function_index) {
      functions.push(
        @lib.FuncIdx::new(function_.function_index.reinterpret_as_uint()),
      )
    }
  }
  for wrapper in helper_plan.wrappers {
    functions.push(
      @lib.FuncIdx::new(wrapper.function_index.reinterpret_as_uint()),
    )
  }
  for closure in helper_plan.evidence_closures {
    functions.push(
      @lib.FuncIdx::new(closure.function_index.reinterpret_as_uint()),
    )
  }
  Some(
    @lib.ElemSec::new([
      @lib.Elem::new(
        @lib.ElemMode::declarative(),
        @lib.ElemKind::funcs(functions),
      ),
    ]),
  )
}

///|
pub fn emit_starshine_program_module(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
) -> Result[@lib.Module, StarshineCodeEmissionError] {
  if planned.diagnostics.length() > 0 {
    return Err(ProgramLinkDiagnostics(planned.diagnostics.length()))
  }
  let helper_plan = starshine_program_adapter_helper_plan(lowering, planned)
  match helper_plan.evidence_error {
    Some(error) => return Err(error)
    None => ()
  }
  let type_section = emit_starshine_program_type_section(planned, helper_plan)
  match emit_starshine_program_code_section(lowering, planned, helper_plan) {
    Ok(code) => {
      let mut module_ = @lib.Module::new()
        .with_type_sec(type_section)
        .with_import_sec(emit_starshine_program_import_section(planned))
        .with_func_sec(
          emit_starshine_program_function_section(planned, helper_plan),
        )
        .with_export_sec(emit_starshine_program_export_section(planned))
        .with_code_sec(code)
      match
        starshine_program_function_reference_element_section(
          lowering, planned, helper_plan,
        ) {
        Some(elements) => module_ = module_.with_elem_sec(elements)
        None => ()
      }
      if planned.global_lookup.length() > 0 ||
        planned.function_reference_singletons.length() > 0 ||
        planned.trait_dictionary_globals.length() > 0 {
        module_ = module_.with_global_sec(
          emit_starshine_program_global_section(lowering, planned),
        )
      }
      let mut uses_linear_memory = false
      for module_plan in planned.modules {
        if module_plan.uses_linear_memory {
          uses_linear_memory = true
          break
        }
      }
      Ok(
        if uses_linear_memory {
          module_.with_mem_sec(starshine_default_memory_section())
        } else {
          module_
        },
      )
    }
    Err(error) => Err(error)
  }
}

///|
pub fn emit_starshine_program_binary(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
) -> Result[Bytes, StarshineProgramBinaryEmissionError] {
  let module_ = match emit_starshine_program_module(lowering, planned) {
    Ok(module_) => module_
    Err(error) => return Err(StarshineProgramCodeError(error))
  }
  match @validate.validate_module(module_) {
    Ok(_) => ()
    Err(error) => return Err(StarshineProgramValidationError(error))
  }
  match @binary.encode_module(module_) {
    Ok(bytes) => Ok(bytes)
    Err(error) => Err(StarshineProgramEncodingError(error))
  }
}
