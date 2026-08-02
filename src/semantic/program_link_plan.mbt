///|
pub struct PlannedProgramLowering {
  graph : ModuleDependencyGraph
  modules : Array[PlannedModuleLowering]
}

///|
pub enum ProgramWasmGCLinkDiagnostic {
  MissingProgramType(ModuleId, DeclId)
  UnsupportedProgramForwardTypeReference(ModuleId, DeclId)
  UnsupportedProgramGenericType(ModuleId, DeclId)
  UnsupportedProgramGenericCall(ModuleId, DeclId, UInt64)
  MissingProgramFunction(ModuleId, DeclId, UInt64)
} derive(Eq, Debug)

///|
pub struct PlannedProgramWasmFunction {
  declaration : DeclId
  module_index : Int
  fragment_index : Int
  name : Bytes
  visibility : SemanticVisibility
  is_test : Bool
  is_test_entry : Bool
  test_name : Bytes
  kind : PlannedWasmFunctionKind
  direct_builtin : Bytes
  elided : Bool
  signature_type_index : Int
  mut function_index : Int
  parameters : HirSpan
  results : HirSpan
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedProgramExternalTypeReference {
  module_index : Int
  declaration : DeclId
} derive(Eq, Debug)

///|
pub struct PlannedProgramWasmGCFragments {
  graph : ModuleDependencyGraph
  modules : Array[PlannedModuleWasmGCFragments]
  external_type_references : Array[PlannedProgramExternalTypeReference]
}

///|
pub struct PlannedProgramWasmGCLink {
  root_module_index : Int
  graph : ModuleDependencyGraph
  modules : Array[PlannedModuleWasmGCFragments]
  module_type_bases : Array[Int]
  functions : Array[PlannedProgramWasmFunction]
  function_lookup : Map[DeclId, Int]
  type_lookup : Map[DeclId, Int]
  module_lookup : Map[ModuleId, Int]
  type_count : Int
  imported_function_count : Int
  defined_function_count : Int
  diagnostics : Array[ProgramWasmGCLinkDiagnostic]
}

///|
pub fn PlannedProgramWasmGCLink::function_of(
  self : PlannedProgramWasmGCLink,
  declaration : DeclId,
) -> PlannedProgramWasmFunction? {
  match self.function_lookup.get(declaration) {
    Some(index) => Some(self.functions[index])
    None => None
  }
}

///|
/// Runs backend-neutral module lowering jobs in dependency-SCC order. Final
/// module slots remain in manifest order.
pub fn plan_program_lowering(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
) -> PlannedProgramLowering {
  guard program.modules.length() == analyzed.modules.length() else {
    abort("program lowering inputs have different module counts")
  }
  let slots : Array[PlannedModuleLowering?] = Array::make(
    program.modules.length(),
    None,
  )
  for scc in analyzed.frozen.graph.sccs {
    for index in 0..<scc.length {
      let module_index = analyzed.frozen.graph.scc_modules[scc.start + index]
      let collected = program.modules[module_index]
      let semantic = analyzed.modules[module_index]
      let resolved = analyzed.frozen.interfaces[module_index].resolved_types
      let layouts = plan_module_type_layouts(collected, resolved)
      let initialization = plan_module_initialization(
        collected,
        semantic.inferred.module_values,
      )
      let functions = plan_module_functions(collected, resolved)
      let flows = analyze_module_flows(collected, resolved, semantic.inferred)
      slots[module_index] = Some(
        plan_module_lowering(
          collected,
          resolved,
          layouts,
          initialization,
          functions,
          semantic.names,
          semantic.inferred,
          flows,
        ),
      )
    }
  }
  let modules : Array[PlannedModuleLowering] = []
  for slot in slots {
    modules.push(slot.unwrap())
  }
  { graph: analyzed.frozen.graph, modules }
}

///|
fn program_link_validate_calls(
  lowering : PlannedProgramLowering,
  functions : Array[PlannedProgramWasmFunction],
  lookup : Map[DeclId, Int],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> Unit {
  for module_ in lowering.modules {
    for expression in module_.expressions {
      let target = match expression.kind {
        PlannedDirectCall(declaration, _, _, _)
        | PlannedOperatorCall(declaration, _, _, _, _)
        | PlannedIndexCall(declaration, _, _, _)
        | PlannedIndexSetCall(declaration, _, _, _, _) => declaration
        _ => continue
      }
      match lookup.get(target) {
        Some(function_index) => {
          let function_ = functions[function_index]
          let owner = lowering.modules[function_.module_index]
          let callable = owner.functions.callables[function_.fragment_index]
          if callable.generic_parameters.length > 0 {
            diagnostics.push(
              UnsupportedProgramGenericCall(
                module_.module_id,
                target,
                expression.offset,
              ),
            )
          }
        }
        None =>
          diagnostics.push(
            MissingProgramFunction(module_.module_id, target, expression.offset),
          )
      }
    }
  }
}

///|
fn program_link_validate_external_type(
  module_id : ModuleId,
  module_type_base : Int,
  declaration : DeclId,
  type_lookup : Map[DeclId, Int],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> Unit {
  match type_lookup.get(declaration) {
    Some(index) =>
      if index >= module_type_base {
        diagnostics.push(
          UnsupportedProgramForwardTypeReference(module_id, declaration),
        )
      }
    None => diagnostics.push(MissingProgramType(module_id, declaration))
  }
}

///|
fn program_link_validate_types(
  fragments : PlannedProgramWasmGCFragments,
  module_type_bases : Array[Int],
  type_lookup : Map[DeclId, Int],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> Unit {
  for reference in fragments.external_type_references {
    let module_ = fragments.modules[reference.module_index]
    program_link_validate_external_type(
      module_.module_id,
      module_type_bases[reference.module_index],
      reference.declaration,
      type_lookup,
      diagnostics,
    )
  }
}

///|

///|
fn program_mark_resolved_nominal_roots(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  reachable : Map[DeclId, Bool],
) -> Unit {
  let work : Array[ResolvedTypeId] = [root]
  while work.length() > 0 {
    let type_ = work.pop().unwrap()
    match resolved.types[type_] {
      NominalType(declaration) => reachable[declaration] = true
      AppliedType(base, arguments) => {
        work.push(base)
        for index in 0..<arguments.length {
          work.push(resolved.type_arguments[arguments.start + index])
        }
      }
      _ => ()
    }
  }
}

///|
fn program_variant_declaration(
  lowering : PlannedProgramLowering,
  module_lookup : Map[ModuleId, Int],
  variant : VariantId,
) -> DeclId? {
  let owner = match module_lookup.get(semantic_id_module(variant)) {
    Some(value) => value
    None => return None
  }
  for candidate in lowering.modules[owner].type_layouts.variants {
    if candidate.variant == variant {
      return Some(candidate.declaration)
    }
  }
  None
}

///|
fn program_add_named_callable_root(
  lowering : PlannedProgramLowering,
  name : Bytes,
  reachable : Map[DeclId, Bool],
) -> Bool {
  for module_ in lowering.modules {
    for callable in module_.functions.callables {
      match callable.kind {
        PlannedBuiltinCallable(candidate) =>
          if candidate == name {
            if reachable.contains(callable.declaration) {
              return false
            }
            reachable[callable.declaration] = true
            return true
          }
        _ => ()
      }
    }
  }
  false
}

///|
fn program_reachable_callable_roots(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  emit_tests : Bool,
) -> Map[DeclId, Bool] {
  let module_lookup : Map[ModuleId, Int] = Map::default()
  for module_index, module_ in lowering.modules {
    module_lookup[module_.module_id] = module_index
  }
  let reachable : Map[DeclId, Bool] = Map::default()
  let work : Array[DeclId] = []
  for module_ in lowering.modules {
    for callable in module_.functions.callables {
      if (callable.visibility == Public || !callable.compiler_owned) &&
        (!callable.is_test || emit_tests) {
        reachable[callable.declaration] = true
        work.push(callable.declaration)
      }
    }
  }
  while work.length() > 0 {
    let declaration = work.pop().unwrap()
    let module_index = match
      module_lookup.get(semantic_id_module(declaration)) {
      Some(value) => value
      None => continue
    }
    let module_ = lowering.modules[module_index]
    let callable = match module_.functions.callable_of(declaration) {
      Some(value) => value
      None => continue
    }
    let body_id = match callable.kind {
      PlannedFunctionCallable(body)
      | PlannedImplMethodCallable(_, Some(body)) => body
      _ => continue
    }
    let body_index = semantic_id_local(body_id)
    if body_index < 0 || body_index >= module_.bodies.length() {
      continue
    }
    let body = module_.bodies[body_index]
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      let (first_target, second_target) = match
        module_.expressions[expression].kind {
        PlannedDirectCall(target, _, _, _)
        | PlannedOperatorCall(target, _, _, _, _)
        | PlannedIndexCall(target, _, _, _)
        | PlannedIndexSetCall(target, _, _, _, _) => (target, 0UL)
        PlannedMapSingleton(_, _, _, _, hash, eq)
        | PlannedMapEmpty(_, _, hash, eq)
        | PlannedMapGet(_, _, _, _, hash, eq)
        | PlannedMapGetUnchecked(_, _, _, _, hash, eq) => (hash, eq)
        PlannedMapInsert(_, _, _, _, _, hash, eq)
        | PlannedMapSet(_, _, _, _, _, hash, eq) => (hash, eq)
        PlannedMapContainsKey(_, _, _, hash, eq)
        | PlannedMapRemove(_, _, _, hash, eq) => (hash, eq)
        PlannedSetEmpty(_, hash, eq)
        | PlannedSetSingleton(_, _, hash, eq)
        | PlannedSetContains(_, _, _, hash, eq)
        | PlannedSetInsert(_, _, _, hash, eq)
        | PlannedSetRemove(_, _, _, hash, eq) => (hash, eq)
        _ => continue
      }
      for target in [first_target, second_target] {
        if target == 0UL || reachable.contains(target) {
          continue
        }
        let owner = match module_lookup.get(semantic_id_module(target)) {
          Some(value) => value
          None => continue
        }
        let target_callable = match
          lowering.modules[owner].functions.callable_of(target) {
          Some(value) => value
          None => continue
        }
        if target_callable.is_test && !emit_tests {
          continue
        }
        reachable[target] = true
        work.push(target)
      }
    }
  }
  let mut runtime_changed = true
  while runtime_changed {
    runtime_changed = false
    for module_ in lowering.modules {
      for callable in module_.functions.callables {
        if !reachable.contains(callable.declaration) {
          continue
        }
        match callable.kind {
          PlannedBuiltinCallable(name) =>
            if name == b"dew_bytes_to_string" {
              runtime_changed = program_add_named_callable_root(
                  lowering, b"dew_bytes_is_valid_utf8", reachable,
                ) ||
                runtime_changed
            } else if name == b"dew_test_assert" {
              runtime_changed = program_add_named_callable_root(
                  lowering, b"dew_string_as_bytes", reachable,
                ) ||
                runtime_changed
              runtime_changed = program_add_named_callable_root(
                  lowering, b"dew_wasi_fd_write", reachable,
                ) ||
                runtime_changed
            } else if name == b"dew_wasi_fd_write" {
              runtime_changed = program_add_named_callable_root(
                  lowering, b"wasi_snapshot_preview1.fd_write", reachable,
                ) ||
                runtime_changed
            } else if name == b"dew_wasi_fd_read" {
              runtime_changed = program_add_named_callable_root(
                  lowering, b"wasi_snapshot_preview1.fd_read", reachable,
                ) ||
                runtime_changed
            }
          _ => ()
        }
      }
    }
  }
  for module_index, module_ in lowering.modules {
    let resolved = analyzed.frozen.interfaces[module_index].resolved_types
    for callable in module_.functions.callables {
      if !reachable.contains(callable.declaration) {
        continue
      }
      for index in 0..<callable.parameters.length {
        program_mark_resolved_nominal_roots(
          resolved,
          module_.functions.parameters[callable.parameters.start + index].type_,
          reachable,
        )
      }
      program_mark_resolved_nominal_roots(
        resolved,
        callable.result_type,
        reachable,
      )
      if callable.has_receiver {
        program_mark_resolved_nominal_roots(
          resolved,
          callable.self_type,
          reachable,
        )
      }
      let body_id = match callable.kind {
        PlannedFunctionCallable(body)
        | PlannedImplMethodCallable(_, Some(body)) => body
        _ => continue
      }
      let body_index = semantic_id_local(body_id)
      if body_index < 0 || body_index >= module_.bodies.length() {
        continue
      }
      let body = module_.bodies[body_index]
      for
        expression in body.expressions.start..<(body.expressions.start +
        body.expressions.length) {
        match module_.expressions[expression].kind {
          PlannedStructNew(declaration, _, _) => reachable[declaration] = true
          PlannedFixedArrayMake(_, _, _)
          | PlannedFixedArrayLength(_, _)
          | PlannedFixedArrayGet(_, _, _)
          | PlannedFixedArrayGetUnchecked(_, _, _)
          | PlannedFixedArraySet(_, _, _, _)
          | PlannedFixedArraySetUnchecked(_, _, _, _) =>
            reachable[standard_fixed_array_type_declaration()] = true
          PlannedMapSingleton(_, _, _, _, _, _)
          | PlannedMapEmpty(_, _, _, _)
          | PlannedMapLength(_)
          | PlannedMapGet(_, _, _, _, _, _)
          | PlannedMapGetUnchecked(_, _, _, _, _, _)
          | PlannedMapInsert(_, _, _, _, _, _, _)
          | PlannedMapSet(_, _, _, _, _, _, _)
          | PlannedMapContainsKey(_, _, _, _, _)
          | PlannedMapRemove(_, _, _, _, _)
          | PlannedMapClear(_) =>
            reachable[standard_map_type_declaration()] = true
          PlannedSetEmpty(_, _, _)
          | PlannedSetSingleton(_, _, _, _)
          | PlannedSetLength(_)
          | PlannedSetIsEmpty(_)
          | PlannedSetContains(_, _, _, _, _)
          | PlannedSetInsert(_, _, _, _, _)
          | PlannedSetRemove(_, _, _, _, _)
          | PlannedSetClear(_) =>
            reachable[standard_set_type_declaration()] = true
          PlannedUnitVariant(variant, _)
          | PlannedVariantTupleNew(variant, _, _)
          | PlannedVariantStructNew(variant, _, _) =>
            match
              program_variant_declaration(lowering, module_lookup, variant) {
              Some(declaration) => reachable[declaration] = true
              None => ()
            }
          _ => ()
        }
      }
      for
        pattern in body.patterns.start..<(body.patterns.start +
        body.patterns.length) {
        match module_.patterns[pattern].selected_constructor {
          StructInferredPatternConstructor(declaration, _) =>
            reachable[declaration] = true
          VariantInferredPatternConstructor(variant, _) =>
            match
              program_variant_declaration(lowering, module_lookup, variant) {
              Some(declaration) => reachable[declaration] = true
              None => ()
            }
          _ => ()
        }
      }
    }
  }
  reachable
}

///|
/// Runs module-local WasmGC fragment jobs in dependency-SCC order while
/// retaining manifest-indexed outputs.
pub fn plan_program_wasmgc_fragments_with_options(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  options : WasmGCPlanningOptions,
) -> PlannedProgramWasmGCFragments {
  guard lowering.modules.length() == analyzed.modules.length() else {
    abort("program fragment inputs have different module counts")
  }
  let slots : Array[PlannedModuleWasmGCFragments?] = Array::make(
    lowering.modules.length(),
    None,
  )
  let program_roots = program_reachable_callable_roots(
    analyzed,
    lowering,
    options.emit_tests,
  )
  for scc in lowering.graph.sccs {
    for index in 0..<scc.length {
      let module_index = lowering.graph.scc_modules[scc.start + index]
      slots[module_index] = Some(
        plan_module_wasmgc_fragments_with_options_and_roots(
          analyzed.frozen.interfaces[module_index].resolved_types,
          lowering.modules[module_index],
          options,
          program_roots,
        ),
      )
    }
  }
  let modules : Array[PlannedModuleWasmGCFragments] = []
  for slot in slots {
    modules.push(slot.unwrap())
  }
  let external_type_references : Array[PlannedProgramExternalTypeReference] = []
  for module_index, module_ in modules {
    for field in module_.fields {
      match field.storage {
        WasmExternalNominalRefStorage(declaration) =>
          external_type_references.push({ module_index, declaration })
        _ => ()
      }
    }
    for function_ in module_.functions {
      if function_.signature_type_index < 0 {
        continue
      }
      for index in 0..<function_.parameters.length {
        match module_.function_value_types[function_.parameters.start + index] {
          WasmExternalNominalRefValue(declaration) =>
            external_type_references.push({ module_index, declaration })
          _ => ()
        }
      }
      for index in 0..<function_.results.length {
        match module_.function_value_types[function_.results.start + index] {
          WasmExternalNominalRefValue(declaration) =>
            external_type_references.push({ module_index, declaration })
          _ => ()
        }
      }
    }
  }
  { graph: lowering.graph, modules, external_type_references }
}

///|
pub fn plan_program_wasmgc_fragments(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
) -> PlannedProgramWasmGCFragments {
  plan_program_wasmgc_fragments_with_options(
    analyzed,
    lowering,
    WasmGCPlanningOptions::optimized_subtype_families(),
  )
}

///|
fn program_test_export_name(ordinal : Int) -> Bytes {
  let output = Buffer(size_hint=24)
  output.write_string_utf8("__dew_test_")
  output.write_string_utf8(ordinal.to_string())
  output.to_bytes()
}

///|
/// Assigns final program-wide type and function indices without mutating any
/// module-local fragment plan. Module-local recursive groups remain intact;
/// module and imported nominal references are rebased during emission.
pub fn link_program_wasmgc_fragments(
  fragments : PlannedProgramWasmGCFragments,
  lowering : PlannedProgramLowering,
  root_module_index : Int,
) -> PlannedProgramWasmGCLink {
  guard root_module_index >= 0 && root_module_index < lowering.modules.length() else {
    abort("program root module index is outside the manifest")
  }
  guard fragments.modules.length() == lowering.modules.length() else {
    abort("program link inputs have different module counts")
  }
  let module_type_bases = Array::make(lowering.modules.length(), -1)
  let functions : Array[PlannedProgramWasmFunction] = []
  let function_lookup : Map[DeclId, Int] = Map::default()
  let type_lookup : Map[DeclId, Int] = Map::default()
  let module_lookup : Map[ModuleId, Int] = Map::default()
  let diagnostics : Array[ProgramWasmGCLinkDiagnostic] = []
  let test_ordinals : Map[DeclId, Int] = Map::default()
  let mut next_test_ordinal = 0
  for module_ in fragments.modules {
    for function_ in module_.functions {
      if function_.is_test_entry {
        test_ordinals[function_.declaration] = next_test_ordinal
        next_test_ordinal += 1
      }
    }
  }
  let mut type_count = 0
  for scc in lowering.graph.sccs {
    for index in 0..<scc.length {
      let module_index = lowering.graph.scc_modules[scc.start + index]
      let module_fragments = fragments.modules[module_index]
      module_lookup[module_fragments.module_id] = module_index
      module_type_bases[module_index] = type_count
      for physical in module_fragments.physical_types {
        match physical.kind {
          PlannedWasmStructType(declaration)
          | PlannedWasmEnumBaseType(declaration) => {
            type_lookup[declaration] = type_count + physical.type_index
            match
              lowering.modules[module_index].type_layouts.layout_of(declaration) {
              Some(layout) if layout.generic_parameters.length > 0 =>
                match layout.kind {
                  PlannedStructLayout(_) =>
                    if declaration != standard_fixed_array_type_declaration() &&
                      declaration != standard_map_type_declaration() &&
                      declaration != standard_set_type_declaration() {
                      diagnostics.push(
                        UnsupportedProgramGenericType(
                          module_fragments.module_id,
                          declaration,
                        ),
                      )
                    }
                  PlannedEnumLayout(_) => ()
                }
              _ => ()
            }
          }
          PlannedWasmEnumSubtypeType(_, _, _) => ()
        }
      }
      for fragment_index, function_ in module_fragments.functions {
        let entry = functions.length()
        function_lookup[function_.declaration] = entry
        functions.push({
          declaration: function_.declaration,
          module_index,
          fragment_index,
          name: match test_ordinals.get(function_.declaration) {
            Some(ordinal) => program_test_export_name(ordinal)
            None => function_.name
          },
          visibility: function_.visibility,
          is_test: function_.is_test,
          is_test_entry: function_.is_test_entry,
          test_name: function_.test_name,
          kind: function_.kind,
          direct_builtin: function_.direct_builtin,
          elided: function_.elided,
          signature_type_index: if function_.signature_type_index >= 0 {
            type_count + function_.signature_type_index
          } else {
            -1
          },
          function_index: -1,
          parameters: function_.parameters,
          results: function_.results,
          offset: function_.offset,
        })
      }
      type_count += module_fragments.physical_types.length() +
        module_fragments.signature_type_count
    }
  }
  let mut imported_function_count = 0
  for function_ in functions {
    match function_.kind {
      PlannedWasmImportedFunction(_) =>
        if !function_.elided {
          function_.function_index = imported_function_count
          imported_function_count += 1
        } else {
          function_.function_index = -1
        }
      PlannedWasmInlineBuiltinFunction(_)
      | PlannedWasmRuntimeFunction(_)
      | PlannedWasmDefinedFunction(_)
      | PlannedWasmSignatureOnlyFunction => ()
    }
  }
  let mut defined_function_count = 0
  for function_ in functions {
    match function_.kind {
      PlannedWasmDefinedFunction(_) | PlannedWasmRuntimeFunction(_) =>
        if !function_.elided {
          function_.function_index = imported_function_count +
            defined_function_count
          defined_function_count += 1
        }
      PlannedWasmImportedFunction(_)
      | PlannedWasmInlineBuiltinFunction(_)
      | PlannedWasmSignatureOnlyFunction => ()
    }
  }
  program_link_validate_types(
    fragments, module_type_bases, type_lookup, diagnostics,
  )
  program_link_validate_calls(lowering, functions, function_lookup, diagnostics)
  {
    root_module_index,
    graph: lowering.graph,
    modules: fragments.modules,
    module_type_bases,
    functions,
    function_lookup,
    type_lookup,
    module_lookup,
    type_count,
    imported_function_count,
    defined_function_count,
    diagnostics,
  }
}

///|
pub fn plan_program_wasmgc_link_with_options(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  root_module_index : Int,
  options : WasmGCPlanningOptions,
) -> PlannedProgramWasmGCLink {
  link_program_wasmgc_fragments(
    plan_program_wasmgc_fragments_with_options(analyzed, lowering, options),
    lowering,
    root_module_index,
  )
}

///|
pub fn plan_program_wasmgc_link(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  root_module_index : Int,
) -> PlannedProgramWasmGCLink {
  plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    root_module_index,
    WasmGCPlanningOptions::optimized_subtype_families(),
  )
}
