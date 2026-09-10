///|
pub struct ProgramIndex {
  module_lookup : Map[ModuleId, Int]
  indexed_modules : Array[PlannedModuleLowering]
}

///|
fn build_program_index(modules : Array[PlannedModuleLowering]) -> ProgramIndex {
  let module_lookup : Map[ModuleId, Int] = Map::default()
  for module_index, module_ in modules {
    if module_lookup.contains(module_.module_id) {
      abort("duplicate module identity in program index")
    }
    module_lookup[module_.module_id] = module_index
  }
  { module_lookup, indexed_modules: modules, }
}

///|
pub fn ProgramIndex::module_index(
  self : ProgramIndex,
  module_id : ModuleId,
) -> Int? {
  match check_program_module_index(self, module_id) {
    Ok(selected) => selected
    Err(failure) => abort(@debug.to_string(failure))
  }
}

///|
pub fn ProgramIndex::declaration_owner(
  self : ProgramIndex,
  declaration : DeclId,
) -> Int? {
  self.module_index(semantic_id_module(declaration))
}

///|
pub fn ProgramIndex::body_owner(self : ProgramIndex, body : BodyId) -> Int? {
  self.module_index(semantic_id_module(body))
}

///|
pub fn ProgramIndex::implementation_owner(
  self : ProgramIndex,
  implementation : DeclId,
) -> Int? {
  self.declaration_owner(implementation)
}

///|
pub fn ProgramIndex::type_owner(
  self : ProgramIndex,
  declaration : DeclId,
) -> Int? {
  self.declaration_owner(declaration)
}

///|
pub fn ProgramIndex::variant_owner(
  self : ProgramIndex,
  variant : VariantId,
) -> Int? {
  self.module_index(semantic_id_module(variant))
}

///|
pub struct PlannedProgramLowering {
  graph : ModuleDependencyGraph
  modules : Array[PlannedModuleLowering]
  index : ProgramIndex
  elided_trait_wrappers : Array[DeclId]
  compile_time : CompileTimeProgramContext?
}

///|
pub enum ProgramWasmGCLinkDiagnostic {
  MissingProgramType(ModuleId, DeclId)
  UnsupportedProgramGenericCall(ModuleId, DeclId, UInt64)
  MissingProgramFunction(ModuleId, DeclId, UInt64)
  ProgramCompileTimeFailure(ModuleId, DeclId, String, ExprId, String, UInt64)
  EagerProgramInitializationCycle(DeclId, DeclId)
} derive(Eq, Debug)

///|
pub struct ProgramSpecializedCallKey {
  body : BodyId
  specialization_abi_key : String
  expression : ExprId
} derive(Eq, Hash, Debug)

///|
pub struct PlannedProgramSpecializedCall {
  caller_body : BodyId
  caller_specialization_abi_key : String
  expression : ExprId
  target : DeclId
  target_specialization_abi_key : String
  runtime_evidence_parameters : HirSpan
} derive(Eq, Debug)

///|
pub struct PlannedProgramWasmFunction {
  declaration : DeclId
  lambda : LambdaId
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
  specialization_shapes : HirSpan
  specialization_evidence : HirSpan
  specialization_abi_key : String
  erased_adapter_target : Int
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedProgramExternalTypeReference {
  module_index : Int
  declaration : DeclId
} derive(Eq, Debug)

///|
pub struct PlannedProgramEvidenceFunctionReference {
  caller_body : BodyId
  caller_specialization_abi_key : String
  expression : ExprId
  target : DeclId
  target_specialization_abi_key : String
  runtime_evidence_parameters : HirSpan
} derive(Eq, Debug)

///|
pub struct PlannedProgramSpecializationPlan {
  graph : ModuleDependencyGraph
  modules : Array[PlannedModuleWasmGCFragments]
  external_type_references : Array[PlannedProgramExternalTypeReference]
  specialized_calls : Array[PlannedProgramSpecializedCall]
  specialized_call_runtime_evidence_parameters : Array[Int]
  evidence_function_references : Array[PlannedProgramEvidenceFunctionReference]
  evidence_function_reference_runtime_evidence_parameters : Array[Int]
}

///|
pub struct PlannedProgramModuleInitializer {
  declaration : DeclId
  module_index : Int
  body : BodyId
  shape : PlannedValueShape
  test_only : Bool
  constant : Bool
  global_index : Int
  function_index : Int
} derive(Eq, Debug)

///|
pub struct PlannedProgramWasmPhysicalType {
  module_index : Int
  fragment_index : Int
} derive(Eq, Debug)

///|
pub struct PlannedProgramWasmRecursiveGroup {
  types : HirSpan
  first_type_index : Int
} derive(Eq, Debug)

///|
pub enum PlannedProgramWasmSignatureTypeKind {
  PlannedProgramFunctionType(Int)
  PlannedProgramFunctionSignature(Int)
} derive(Eq, Debug)

///|
pub struct PlannedProgramWasmSignatureType {
  module_index : Int
  type_index : Int
  kind : PlannedProgramWasmSignatureTypeKind
} derive(Eq, Debug)

///|
pub struct PlannedProgramTraitDictionaryGlobal {
  module_index : Int
  dictionary_index : Int
  global_index : Int
} derive(Eq, Debug)

///|
pub struct PlannedProgramFunctionReferenceSingleton {
  module_index : Int
  declaration : DeclId
  function_index : Int
  specialization_module_index : Int
  specialization_shapes : HirSpan
  signature_type_index : Int
  global_index : Int
} derive(Eq, Debug)

///|
pub struct PlannedProgramWasmGCLink {
  root_module_index : Int
  graph : ModuleDependencyGraph
  modules : Array[PlannedModuleWasmGCFragments]
  module_type_bases : Array[Int]
  module_signature_indices : Array[Array[Int]]
  module_type_indices : Array[Array[Int]]
  program_type_groups : Array[PlannedProgramWasmRecursiveGroup]
  program_signature_types : Array[PlannedProgramWasmSignatureType]
  program_physical_types : Array[PlannedProgramWasmPhysicalType]
  functions : Array[PlannedProgramWasmFunction]
  function_lookup : Map[DeclId, Int]
  specialized_call_lookup : Map[ProgramSpecializedCallKey, Int]
  specialized_call_targets : Map[
    ProgramSpecializedCallKey,
    PlannedProgramPhysicalCallTarget,
  ]
  specialized_call_runtime_evidence_lookup : Map[
    ProgramSpecializedCallKey,
    HirSpan,
  ]
  specialized_call_runtime_evidence_parameters : Array[Int]
  evidence_function_references : Array[PlannedProgramEvidenceFunctionReference]
  evidence_function_reference_runtime_evidence_parameters : Array[Int]
  initializers : Array[PlannedProgramModuleInitializer]
  global_lookup : Map[DeclId, Int]
  function_reference_singletons : Array[
    PlannedProgramFunctionReferenceSingleton,
  ]
  trait_dictionary_globals : Array[PlannedProgramTraitDictionaryGlobal]
  initializer_type_index : Int
  startup_function_index : Int
  type_lookup : Map[DeclId, Int]
  module_lookup : Map[ModuleId, Int]
  erased_box_type_indices : Array[Int]
  fixed_array_type_base : Int
  type_count : Int
  imported_function_count : Int
  defined_function_count : Int
  imported_function_indices : Map[Bytes, Int]
  diagnostics : Array[ProgramWasmGCLinkDiagnostic]
}

///|
pub fn program_specialized_call_key(
  body : BodyId,
  specialization_abi_key : String,
  expression : ExprId,
) -> ProgramSpecializedCallKey {
  { body, specialization_abi_key, expression, }
}

///|
pub fn PlannedProgramWasmGCLink::imported_function_index(
  self : PlannedProgramWasmGCLink,
  name : Bytes,
) -> Int {
  self.imported_function_indices.get(name).unwrap_or(-1)
}

///|
pub fn PlannedProgramWasmGCLink::specialized_call_function(
  self : PlannedProgramWasmGCLink,
  body : BodyId,
  specialization_abi_key : String,
  expression : ExprId,
) -> PlannedProgramWasmFunction? {
  match
    check_program_specialized_call_lookup(
      self, body, specialization_abi_key, expression,
    ) {
    Ok(value) => value
    Err(failure) => abort(@debug.to_string(failure))
  }
}

///|
pub fn PlannedProgramWasmGCLink::specialized_call_runtime_evidence(
  self : PlannedProgramWasmGCLink,
  body : BodyId,
  specialization_abi_key : String,
  expression : ExprId,
) -> HirSpan? {
  match
    check_program_specialized_call_runtime_evidence(
      self, body, specialization_abi_key, expression,
    ) {
    Ok(value) => value
    Err(failure) => abort(@debug.to_string(failure))
  }
}

///|
/// An adapter needs one emitted target, not another spelling-based fallback.
/// Missing, duplicate, self-referential, and non-emitted targets return None.
pub fn PlannedProgramWasmGCLink::erased_adapter_target_function(
  self : PlannedProgramWasmGCLink,
  adapter : PlannedProgramWasmFunction,
) -> PlannedProgramWasmFunction? {
  if !(adapter.kind is PlannedWasmErasedAdapterFunction) ||
    adapter.erased_adapter_target < 0 ||
    adapter.erased_adapter_target == adapter.function_index {
    return None
  }
  let mut target = None
  for candidate in self.functions {
    if candidate.function_index == adapter.erased_adapter_target && !candidate.elided {
      if candidate.kind is PlannedWasmInlineBuiltinFunction(_) ||
        candidate.kind is PlannedWasmInlineHeapFunction(_) ||
        candidate.kind is PlannedWasmSignatureOnlyFunction {
        return None
      }
      if target is Some(_) {
        return None
      }
      target = Some(candidate)
    }
  }
  target
}

///|
pub fn PlannedProgramWasmGCLink::materialized_specialization_count(
  self : PlannedProgramWasmGCLink,
) -> Int {
  let mut count = 0
  for function_ in self.functions {
    if function_.specialization_shapes.length > 0 &&
      function_.erased_adapter_target < 0 &&
      function_.function_index >= 0 &&
      !function_.elided {
      count += 1
    }
  }
  count
}

///|
pub fn PlannedProgramWasmGCLink::trait_dictionary_global(
  self : PlannedProgramWasmGCLink,
  module_index : Int,
  dictionary_index : Int,
) -> Int {
  for dictionary in self.trait_dictionary_globals {
    if dictionary.module_index == module_index &&
      dictionary.dictionary_index == dictionary_index {
      return dictionary.global_index
    }
  }
  -1
}

///|
pub fn PlannedProgramWasmGCLink::function_reference_singleton_global(
  self : PlannedProgramWasmGCLink,
  module_index : Int,
  declaration : DeclId,
) -> Int {
  ignore(module_index)
  for singleton in self.function_reference_singletons {
    if singleton.declaration == declaration &&
      singleton.specialization_shapes.length == 0 {
      return singleton.global_index
    }
  }
  -1
}

///|
pub fn PlannedProgramWasmGCLink::specialized_function_reference_singleton_global(
  self : PlannedProgramWasmGCLink,
  declaration : DeclId,
  shapes : Array[PlannedValueShape],
  span : HirSpan,
  signature_type_index : Int,
) -> Int {
  for singleton in self.function_reference_singletons {
    if singleton.declaration == declaration &&
      singleton.specialization_shapes.length > 0 &&
      (
        signature_type_index < 0 ||
        singleton.signature_type_index == signature_type_index
      ) &&
      program_specialization_shapes_equal(
        self.modules[singleton.specialization_module_index].specialization_shapes,
        singleton.specialization_shapes,
        shapes,
        span,
      ) {
      return singleton.global_index
    }
  }
  -1
}

///|
pub fn PlannedProgramWasmGCLink::function_of(
  self : PlannedProgramWasmGCLink,
  declaration : DeclId,
) -> PlannedProgramWasmFunction? {
  match check_program_named_function_lookup(self, declaration) {
    Ok(value) => value
    Err(failure) => abort(@debug.to_string(failure))
  }
}

///|
pub fn PlannedProgramWasmGCLink::specialized_function_of(
  self : PlannedProgramWasmGCLink,
  declaration : DeclId,
  shapes : Array[PlannedValueShape],
  span : HirSpan,
) -> PlannedProgramWasmFunction? {
  match
    check_program_specialized_function_lookup(self, declaration, shapes, span) {
    Ok(value) => value
    Err(failure) => abort(@debug.to_string(failure))
  }
}

///|
pub fn PlannedProgramWasmGCLink::specialized_function_of_exact_shapes(
  self : PlannedProgramWasmGCLink,
  declaration : DeclId,
  shapes : Array[PlannedValueShape],
) -> PlannedProgramWasmFunction? {
  self.specialized_function_of(declaration, shapes, {
    start: 0,
    length: shapes.length(),
  })
}

///|
pub fn PlannedProgramWasmGCLink::signature_type_index(
  self : PlannedProgramWasmGCLink,
  module_index : Int,
  local_type_index : Int,
) -> Int {
  if module_index < 0 || module_index >= self.module_signature_indices.length() {
    return -1
  }
  let physical_count = self.modules[module_index].physical_types.length()
  if local_type_index < physical_count {
    return self.physical_type_index(module_index, local_type_index)
  }
  let signature_index = local_type_index - physical_count
  if signature_index < 0 ||
    signature_index >= self.module_signature_indices[module_index].length() {
    return -1
  }
  self.module_signature_indices[module_index][signature_index]
}

///|
pub fn PlannedProgramWasmGCLink::physical_type_index(
  self : PlannedProgramWasmGCLink,
  module_index : Int,
  local_type_index : Int,
) -> Int {
  if module_index < 0 || module_index >= self.module_type_indices.length() {
    return -1
  }
  let indices = self.module_type_indices[module_index]
  if local_type_index < 0 || local_type_index >= indices.length() {
    return -1
  }
  indices[local_type_index]
}

///|
/// Runs backend-neutral module lowering jobs with caller-supplied deterministic
/// type layouts. Final module slots remain in manifest order.
pub fn plan_unoptimized_program_lowering_with_type_layouts(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
  type_layouts : Array[PlannedModuleTypeLayouts],
) -> PlannedProgramLowering {
  guard program.modules.length() == analyzed.modules.length() &&
    program.modules.length() == type_layouts.length() else {
    abort("program lowering inputs have different module counts")
  }
  let raw_arrays = bind_program_raw_array_contracts(program, analyzed)
  let raw_references = collect_raw_reference_operations(program.modules)
  let slots : Array[PlannedModuleLowering?] = Array::make(
    program.modules.length(),
    None,
  )
  for scc in analyzed.frozen.graph.sccs {
    for index in 0..<scc.length {
      let module_index = analyzed.frozen.graph.scc_modules[scc.start + index]
      let collected = program.modules[module_index]
      let semantic = analyzed.modules[module_index]
      let resolved = {
        ..analyzed.frozen.interfaces[module_index].resolved_types,
        raw_array_declarations: raw_arrays.declarations,
        raw_array_operations: raw_arrays.operations,
        raw_reference_operations: raw_references,
      }
      let layouts = type_layouts[module_index]
      guard layouts.module_id == collected.module_id else {
        abort("program type layout belongs to another module")
      }
      let initialization = plan_module_initialization(
        collected,
        semantic.inferred.module_values,
      )
      let functions = plan_module_functions(collected, resolved)
      let flows = analyze_module_flows_with_imports(
        collected,
        resolved,
        semantic.inferred,
        semantic.imports,
      )
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
    let module_ = slot.unwrap()
    for diagnostic in raw_arrays.diagnostics[module_.module_id] {
      module_.diagnostics.push(diagnostic)
    }
    match validate_planned_module_lowering_arenas(module_) {
      Ok(_) => ()
      Err(error) => abort(error)
    }
    modules.push(module_)
  }
  fold_program_compile_time_queries(program, analyzed, {
    graph: analyzed.frozen.graph,
    index: build_program_index(modules),
    modules,
    elided_trait_wrappers: [],
    compile_time: None,
  })
}

///|
/// Runs backend-neutral module lowering jobs in dependency-SCC order without
/// whole-program rewrites. Final module slots remain in manifest order.
pub fn plan_unoptimized_program_lowering(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
) -> PlannedProgramLowering {
  guard program.modules.length() == analyzed.modules.length() else {
    abort("program lowering inputs have different module counts")
  }
  let layouts : Array[PlannedModuleTypeLayouts] = []
  for module_index, collected in program.modules {
    layouts.push(
      plan_module_type_layouts(
        collected,
        analyzed.frozen.interfaces[module_index].resolved_types,
      ),
    )
  }
  plan_unoptimized_program_lowering_with_type_layouts(
    program, analyzed, layouts,
  )
}

///|
/// Runs module lowering followed by backend-neutral whole-program optimization.
pub fn plan_program_lowering_with_type_layouts(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
  type_layouts : Array[PlannedModuleTypeLayouts],
) -> PlannedProgramLowering {
  optimize_program_lowering(
    plan_unoptimized_program_lowering_with_type_layouts(
      program, analyzed, type_layouts,
    ),
  )
}

///|
pub fn plan_program_lowering(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
) -> PlannedProgramLowering {
  optimize_program_lowering(
    plan_unoptimized_program_lowering(program, analyzed),
  )
}

///|
fn program_link_type_is_symbolic(
  module_ : PlannedModuleLowering,
  type_ : BodyTypeId,
) -> Bool {
  let body_pending : Array[BodyTypeId] = [type_]
  let resolved_pending : Array[ResolvedTypeId] = []
  let mut visited = 0
  let limit = module_.types.length() + module_.resolved_types.length() + 1
  while (body_pending.length() > 0 || resolved_pending.length() > 0) &&
        visited <= limit {
    visited += 1
    if body_pending.length() > 0 {
      let current = body_pending.pop().unwrap()
      if current < -1 {
        resolved_pending.push(-current - 2)
        continue
      }
      if current < 0 || current >= module_.types.length() {
        return true
      }
      match module_.types[current] {
        BodyResolvedType(value) => resolved_pending.push(value)
        BodyVariableType(_)
        | BodyErrorType
        | BodyMemberTypeProjection(_, _, _) => return true
        BodyProductType(fields) =>
          for index in 0..<fields.length {
            body_pending.push(module_.type_arguments[fields.start + index])
          }
        BodyAppliedType(base, arguments) => {
          body_pending.push(base)
          for index in 0..<arguments.length {
            body_pending.push(module_.type_arguments[arguments.start + index])
          }
        }
        BodyFunctionType(parameters, result) => {
          body_pending.push(result)
          for index in 0..<parameters.length {
            body_pending.push(module_.type_arguments[parameters.start + index])
          }
        }
      }
      continue
    }
    let current = resolved_pending.pop().unwrap()
    if current < 0 || current >= module_.resolved_types.length() {
      return true
    }
    match module_.resolved_types[current] {
      GenericParameterType(_) => return true
      MemberTypeProjection(_, _, _) => return true
      ProductType(fields) =>
        for index in 0..<fields.length {
          resolved_pending.push(
            module_.resolved_type_arguments[fields.start + index],
          )
        }
      AppliedType(base, arguments) => {
        resolved_pending.push(base)
        for index in 0..<arguments.length {
          resolved_pending.push(
            module_.resolved_type_arguments[arguments.start + index],
          )
        }
      }
      FunctionType(parameters, result) => {
        resolved_pending.push(result)
        for index in 0..<parameters.length {
          resolved_pending.push(
            module_.resolved_type_arguments[parameters.start + index],
          )
        }
      }
      ErrorType => return true
      PrimitiveType(_) | NominalType(_) | TraitType(_) | SelfType(_) => ()
    }
  }
  false
}

///|
fn program_link_validate_calls(
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  functions : Array[PlannedProgramWasmFunction],
  lookup : Map[DeclId, Int],
  specialized_calls : Array[PlannedProgramSpecializedCall],
  evidence_function_references : Array[PlannedProgramEvidenceFunctionReference],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> Unit {
  for caller in functions {
    if caller.elided {
      continue
    }
    let module_ = program_function_lowering(
      lowering,
      caller.module_index,
      caller.specialization_abi_key,
    )
    let body = match caller.kind {
      PlannedWasmDefinedFunction(body) =>
        module_.bodies[semantic_id_local(body)]
      PlannedWasmDefinedLambdaFunction(lambda) =>
        match module_.lambda_body(lambda) {
          Some(body) => body
          None => abort("BOD-610 call verification lambda body is missing")
        }
      _ => continue
    }
    guard program_specialization_span_is_valid(
      body.expressions,
      module_.expressions.length(),
    ) else {
      abort("ARN-101 call verification body expressions")
    }
    for relative in 0..<body.expressions.length {
      let expression_index = body.expressions.start + relative
      let expression = module_.expressions[expression_index]
      let (target, type_arguments, function_reference) = match expression.kind {
        PlannedDirectCall(declaration, _, _, type_arguments)
        | PlannedTailCall(declaration, _, _, type_arguments)
        | PlannedOperatorCall(declaration, _, _, _, type_arguments)
        | PlannedIndexCall(declaration, _, _, type_arguments)
        | PlannedIndexSetCall(declaration, _, _, _, type_arguments) =>
          (declaration, type_arguments, false)
        PlannedFunctionReference(declaration, type_arguments) =>
          (declaration, type_arguments, true)
        _ => continue
      }
      let type_argument_shapes = if function_reference {
        module_.expression_type_argument_shapes
      } else {
        module_.call_type_argument_shapes
      }
      let type_argument_types = if function_reference {
        module_.expression_type_arguments
      } else {
        module_.call_type_arguments
      }
      if type_arguments.start < 0 ||
        type_arguments.start + type_arguments.length >
        type_argument_shapes.length() {
        diagnostics.push(
          UnsupportedProgramGenericCall(
            module_.module_id,
            target,
            expression.offset,
          ),
        )
        continue
      }
      match lookup.get(target) {
        Some(function_index) => {
          let function_ = functions[function_index]
          let owner = lowering.modules[function_.module_index]
          let callable = owner.functions.callable_of(target).unwrap()
          if program_callable_generic_parameters(callable).length > 0 {
            if function_reference &&
              expression_index >= 0 &&
              expression_index < module_.expression_evidence.length() {
              // The template may use a runtime witness while this exact
              // caller supplies a concrete implementation. Verify the same
              // substituted evidence used to materialize the function value.
              let fragments = modules[caller.module_index]
              guard caller.fragment_index >= 0 &&
                caller.fragment_index < fragments.functions.length() else {
                abort("LNK-504 function reference caller fragment is missing")
              }
              let caller_fragment = fragments.functions[caller.fragment_index]
              guard caller_fragment.declaration == caller.declaration &&
                caller_fragment.specialization_abi_key ==
                caller.specialization_abi_key else {
                abort(
                  "LNK-504 function reference caller fragment identity differs",
                )
              }
              let evidence = match
                resolve_program_expression_evidence(
                  module_,
                  fragments,
                  Some(caller_fragment),
                  expression_index,
                ) {
                Some(value) => value
                None => {
                  diagnostics.push(
                    UnsupportedProgramGenericCall(
                      module_.module_id,
                      target,
                      expression.offset,
                    ),
                  )
                  continue
                }
              }
              let runtime_evidence = evidence.evidence.any(node => {
                node.kind is PlannedRuntimeTraitEvidence(_, _)
              })
              if runtime_evidence {
                let mut captured = false
                for reference in evidence_function_references {
                  if reference.caller_body == body.body &&
                    reference.caller_specialization_abi_key ==
                    caller.specialization_abi_key &&
                    reference.expression == expression_index &&
                    reference.target == target &&
                    reference.runtime_evidence_parameters.length > 0 {
                    captured = true
                    break
                  }
                }
                if !captured {
                  diagnostics.push(
                    UnsupportedProgramGenericCall(
                      module_.module_id,
                      target,
                      expression.offset,
                    ),
                  )
                  continue
                }
              }
            }
            let mut specialized = false
            for call in specialized_calls {
              if call.caller_body == body.body &&
                call.caller_specialization_abi_key ==
                caller.specialization_abi_key &&
                call.expression == expression_index &&
                call.target == target {
                specialized = true
                break
              }
            }
            for candidate in functions {
              if candidate.declaration == target &&
                candidate.specialization_shapes.length > 0 &&
                program_specialization_shapes_equal(
                  modules[candidate.module_index].specialization_shapes,
                  candidate.specialization_shapes,
                  type_argument_shapes,
                  type_arguments,
                ) {
                specialized = true
                break
              }
            }
            if !specialized {
              let mut symbolic_source = false
              for index in 0..<type_arguments.length {
                let source_index = type_arguments.start + index
                match type_argument_shapes[source_index] {
                  GenericPlannedValueShape | ErrorPlannedValueShape =>
                    symbolic_source = true
                  _ =>
                    if source_index < type_argument_types.length() &&
                      program_link_type_is_symbolic(
                        module_,
                        type_argument_types[source_index],
                      ) {
                      symbolic_source = true
                    }
                }
              }
              if !symbolic_source {
                diagnostics.push(
                  UnsupportedProgramGenericCall(
                    module_.module_id,
                    target,
                    expression.offset,
                  ),
                )
              }
            }
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
  declaration : DeclId,
  type_lookup : Map[DeclId, Int],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> Unit {
  if !type_lookup.contains(declaration) {
    diagnostics.push(MissingProgramType(module_id, declaration))
  }
}

///|
fn program_link_validate_types(
  fragments : PlannedProgramSpecializationPlan,
  type_lookup : Map[DeclId, Int],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> Unit {
  for reference in fragments.external_type_references {
    let module_ = fragments.modules[reference.module_index]
    program_link_validate_external_type(
      module_.module_id,
      reference.declaration,
      type_lookup,
      diagnostics,
    )
  }
}

///|
