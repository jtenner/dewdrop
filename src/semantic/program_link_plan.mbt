///|
pub struct PlannedProgramLowering {
  graph : ModuleDependencyGraph
  modules : Array[PlannedModuleLowering]
}

///|
pub enum ProgramWasmGCLinkDiagnostic {
  MissingProgramType(ModuleId, DeclId)
  UnsupportedProgramGenericType(ModuleId, DeclId)
  UnsupportedProgramGenericCall(ModuleId, DeclId, UInt64)
  MissingProgramFunction(ModuleId, DeclId, UInt64)
  EagerProgramInitializationCycle(DeclId, DeclId)
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
  specialization_abi_key : String
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
pub struct PlannedProgramFunctionReferenceSingleton {
  module_index : Int
  declaration : DeclId
  function_index : Int
  specialization_module_index : Int
  specialization_shapes : HirSpan
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
  initializers : Array[PlannedProgramModuleInitializer]
  global_lookup : Map[DeclId, Int]
  function_reference_singletons : Array[
    PlannedProgramFunctionReferenceSingleton,
  ]
  initializer_type_index : Int
  startup_function_index : Int
  type_lookup : Map[DeclId, Int]
  module_lookup : Map[ModuleId, Int]
  type_count : Int
  imported_function_count : Int
  defined_function_count : Int
  diagnostics : Array[ProgramWasmGCLinkDiagnostic]
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
) -> Int {
  for singleton in self.function_reference_singletons {
    if singleton.declaration == declaration &&
      singleton.specialization_shapes.length > 0 &&
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
  match self.function_lookup.get(declaration) {
    Some(index) => Some(self.functions[index])
    None => None
  }
}

///|
pub fn PlannedProgramWasmGCLink::specialized_function_of(
  self : PlannedProgramWasmGCLink,
  declaration : DeclId,
  shapes : Array[PlannedValueShape],
  span : HirSpan,
) -> PlannedProgramWasmFunction? {
  for function_ in self.functions {
    if function_.declaration == declaration &&
      function_.specialization_shapes.length > 0 &&
      program_specialization_shapes_equal(
        self.modules[function_.module_index].specialization_shapes,
        function_.specialization_shapes,
        shapes,
        span,
      ) {
      return Some(function_)
    }
  }
  None
}

///|
pub fn PlannedProgramWasmGCLink::specialized_function_of_exact_shapes(
  self : PlannedProgramWasmGCLink,
  declaration : DeclId,
  shapes : Array[PlannedValueShape],
) -> PlannedProgramWasmFunction? {
  for function_ in self.functions {
    if function_.declaration != declaration ||
      function_.specialization_shapes.length != shapes.length() {
      continue
    }
    let values = self.modules[function_.module_index].specialization_shapes
    let mut equal = true
    for index in 0..<shapes.length() {
      if program_canonical_specialization_shape(
          values[function_.specialization_shapes.start + index],
        ) !=
        program_canonical_specialization_shape(shapes[index]) {
        equal = false
        break
      }
    }
    if equal {
      return Some(function_)
    }
  }
  None
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
fn transparent_callback_parameter_count(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
) -> Int {
  let mut parameter_count = 0
  for local_id in 0..<body.locals.length {
    match module_.locals[body.locals.start + local_id].kind {
      ParameterLocal => parameter_count += 1
      _ => break
    }
  }
  if parameter_count <= 0 {
    return -1
  }
  let root_expression = match body.root {
    BlockBodyRoot(block) => {
      let items = module_.blocks[block].items
      if items.length != 1 {
        return -1
      }
      match module_.block_items[items.start].kind {
        PlannedExpressionItem(expression) => expression
        _ => return -1
      }
    }
    ExpressionBodyRoot(expression) => expression
  }
  let (target, arguments) = match module_.expressions[root_expression].kind {
    PlannedFunctionValueCall(target, arguments, _) => (target, arguments)
    _ => return -1
  }
  match module_.expressions[target].kind {
    PlannedLocalGet(0) => ()
    _ => return -1
  }
  if arguments.length != parameter_count - 1 {
    return -1
  }
  for index in 0..<arguments.length {
    let argument = module_.expression_children[arguments.start + index]
    match module_.expressions[argument].kind {
      PlannedLocalGet(local_id) if local_id == index + 1 => ()
      _ => return -1
    }
  }
  parameter_count
}

///|
fn generic_parameter_selector(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
) -> Int {
  let callable = match module_.functions.callable_of(body.declaration) {
    Some(callable) => callable
    None => return -1
  }
  if callable.generic_parameters.length == 0 {
    return -1
  }
  let root_expression = match body.root {
    BlockBodyRoot(block) => {
      let items = module_.blocks[block].items
      if items.length != 1 {
        return -1
      }
      match module_.block_items[items.start].kind {
        PlannedExpressionItem(expression) => expression
        _ => return -1
      }
    }
    ExpressionBodyRoot(expression) => expression
  }
  let local_id = match module_.expressions[root_expression].kind {
    PlannedLocalGet(local_id) => local_id
    _ => return -1
  }
  let mut parameter_index = 0
  for index in 0..<body.locals.length {
    match module_.locals[body.locals.start + index].kind {
      ParameterLocal => {
        if index == local_id {
          return parameter_index
        }
        parameter_index += 1
      }
      _ => return -1
    }
  }
  -1
}

///|
fn directize_generic_parameter_selectors(
  modules : Array[PlannedModuleLowering],
) -> Unit {
  let selectors : Map[DeclId, Int] = Map::default()
  for module_ in modules {
    for body in module_.bodies {
      let selected = generic_parameter_selector(module_, body)
      if selected >= 0 {
        selectors[body.declaration] = selected
      }
    }
  }
  for module_ in modules {
    for expression in 0..<module_.expressions.length() {
      let (declaration, arguments, type_arguments) = match
        module_.expressions[expression].kind {
        PlannedDirectCall(declaration, receiver, arguments, type_arguments) if receiver <
          0 &&
          type_arguments.length > 0 => (declaration, arguments, type_arguments)
        _ => continue
      }
      ignore(type_arguments)
      let selected = match selectors.get(declaration) {
        Some(index) if index < arguments.length => index
        _ => continue
      }
      let source = module_.expressions[expression]
      module_.expressions[expression] = {
        ..source,
        kind: PlannedParameterSelect(arguments, selected),
      }
    }
  }
}

///|
fn directize_transparent_callback_calls(
  modules : Array[PlannedModuleLowering],
) -> Unit {
  let summaries : Map[DeclId, Int] = Map::default()
  for module_ in modules {
    for body in module_.bodies {
      let parameter_count = transparent_callback_parameter_count(module_, body)
      if parameter_count > 0 {
        summaries[body.declaration] = parameter_count
      }
    }
  }
  for module_ in modules {
    for expression in 0..<module_.expressions.length() {
      let (declaration, arguments) = match
        module_.expressions[expression].kind {
        PlannedDirectCall(declaration, receiver, arguments, _) if receiver < 0 =>
          (declaration, arguments)
        _ => continue
      }
      let parameter_count = match summaries.get(declaration) {
        Some(count) => count
        None => continue
      }
      if arguments.length != parameter_count {
        continue
      }
      let callback_expression = module_.expression_children[arguments.start]
      let forwarded = {
        start: arguments.start + 1,
        length: arguments.length - 1,
      }
      let replacement = match module_.expressions[callback_expression].kind {
        PlannedLambdaClosure(lambda, captures) => {
          let lambda_source = module_.lambdas[lambda]
          module_.lambdas[lambda] = { ..lambda_source, directized: true }
          PlannedDirectLambdaCall(lambda, captures, forwarded)
        }
        PlannedFunctionReference(target, type_arguments) =>
          PlannedDirectCall(target, -1, forwarded, type_arguments)
        _ => continue
      }
      let callback_source = module_.expressions[callback_expression]
      module_.expressions[callback_expression] = {
        ..callback_source,
        kind: PlannedConsumedExpression,
      }
      let call_source = module_.expressions[expression]
      module_.expressions[expression] = { ..call_source, kind: replacement }
    }
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
    modules.push(slot.unwrap())
  }
  directize_transparent_callback_calls(modules)
  directize_generic_parameter_selectors(modules)
  { graph: analyzed.frozen.graph, modules }
}

///|
fn program_link_validate_calls(
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  functions : Array[PlannedProgramWasmFunction],
  lookup : Map[DeclId, Int],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> Unit {
  for module_ in lowering.modules {
    for expression in module_.expressions {
      let (target, type_arguments) = match expression.kind {
        PlannedDirectCall(declaration, _, _, type_arguments)
        | PlannedOperatorCall(declaration, _, _, _, type_arguments)
        | PlannedIndexCall(declaration, _, _, type_arguments)
        | PlannedIndexSetCall(declaration, _, _, _, type_arguments) =>
          (declaration, type_arguments)
        _ => continue
      }
      match lookup.get(target) {
        Some(function_index) => {
          let function_ = functions[function_index]
          let owner = lowering.modules[function_.module_index]
          let callable = owner.functions.callable_of(target).unwrap()
          if callable.generic_parameters.length > 0 {
            let mut specialized = false
            for candidate in functions {
              if candidate.declaration == target &&
                candidate.specialization_shapes.length > 0 &&
                program_specialization_shapes_equal(
                  modules[candidate.module_index].specialization_shapes,
                  candidate.specialization_shapes,
                  module_.call_type_argument_shapes,
                  type_arguments,
                ) {
                specialized = true
                break
              }
            }
            if !specialized {
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
  fragments : PlannedProgramWasmGCFragments,
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

///|
fn program_mark_resolved_nominal_roots(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  reachable : Map[DeclId, Bool],
) -> Bool {
  let mut changed = false
  let work : Array[ResolvedTypeId] = [root]
  while work.length() > 0 {
    let type_ = work.pop().unwrap()
    if type_ < 0 || type_ >= resolved.types.length() {
      continue
    }
    match resolved.types[type_] {
      NominalType(declaration) =>
        if !reachable.contains(declaration) {
          reachable[declaration] = true
          changed = true
        }
      AppliedType(base, arguments) => {
        work.push(base)
        for index in 0..<arguments.length {
          work.push(resolved.type_arguments[arguments.start + index])
        }
      }
      FunctionType(parameters, result) => {
        work.push(result)
        for index in 0..<parameters.length {
          work.push(resolved.type_arguments[parameters.start + index])
        }
      }
      _ => ()
    }
  }
  changed
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
  for module_ in lowering.modules {
    for step in module_.initialization.steps {
      if step.test_only && !emit_tests {
        continue
      }
      let body_id = match step.kind {
        PlannedInitializeModuleValue(_, body, _) => body
        PlannedCyclicModuleValues(_) => continue
      }
      let body_index = semantic_id_local(body_id)
      if body_index < 0 || body_index >= module_.bodies.length() {
        continue
      }
      let body = module_.bodies[body_index]
      for
        expression in body.expressions.start..<(body.expressions.start +
        body.expressions.length) {
        let target = match module_.expressions[expression].kind {
          PlannedDirectCall(target, _, _, _)
          | PlannedOperatorCall(target, _, _, _, _)
          | PlannedIndexCall(target, _, _, _)
          | PlannedIndexSetCall(target, _, _, _, _) => target
          _ => continue
        }
        if target != 0UL && !reachable.contains(target) {
          reachable[target] = true
          work.push(target)
        }
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
        ignore(
          program_mark_resolved_nominal_roots(
            resolved,
            module_.functions.parameters[callable.parameters.start + index].type_,
            reachable,
          ),
        )
      }
      ignore(
        program_mark_resolved_nominal_roots(
          resolved,
          callable.result_type,
          reachable,
        ),
      )
      if callable.has_receiver {
        ignore(
          program_mark_resolved_nominal_roots(
            resolved,
            callable.self_type,
            reachable,
          ),
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
  let mut type_changed = true
  while type_changed {
    type_changed = false
    for module_index, module_ in lowering.modules {
      let resolved = analyzed.frozen.interfaces[module_index].resolved_types
      for layout in module_.type_layouts.layouts {
        if !reachable.contains(layout.declaration) {
          continue
        }
        match layout.kind {
          PlannedStructLayout(fields) =>
            for index in 0..<fields.length {
              type_changed = program_mark_resolved_nominal_roots(
                  resolved,
                  module_.type_layouts.fields[fields.start + index].type_,
                  reachable,
                ) ||
                type_changed
            }
          PlannedEnumLayout(variants) =>
            for index in 0..<variants.length {
              match
                module_.type_layouts.variants[variants.start + index].payload {
                PlannedUnitVariantLayout => ()
                PlannedTupleVariantLayout(types) =>
                  for payload_index in 0..<types.length {
                    type_changed = program_mark_resolved_nominal_roots(
                        resolved,
                        module_.type_layouts.payload_types[types.start +
                        payload_index],
                        reachable,
                      ) ||
                      type_changed
                  }
                PlannedStructVariantLayout(fields) =>
                  for field_index in 0..<fields.length {
                    type_changed = program_mark_resolved_nominal_roots(
                        resolved,
                        module_.type_layouts.fields[fields.start + field_index].type_,
                        reachable,
                      ) ||
                      type_changed
                  }
              }
            }
        }
      }
    }
  }
  reachable
}

///|
fn program_canonical_specialization_shape(
  shape : PlannedValueShape,
) -> PlannedValueShape {
  match shape {
    I8PlannedValueShape
    | U8PlannedValueShape
    | I16PlannedValueShape
    | U16PlannedValueShape
    | I32PlannedValueShape
    | U32PlannedValueShape
    | Swar32PlannedValueShape => I32PlannedValueShape
    I64PlannedValueShape | U64PlannedValueShape | Swar64PlannedValueShape =>
      I64PlannedValueShape
    RefPlannedValueShape | GenericPlannedValueShape | ErrorPlannedValueShape =>
      RefPlannedValueShape
    _ => shape
  }
}

///|
fn program_specialization_shape_name(shape : PlannedValueShape) -> String {
  match program_canonical_specialization_shape(shape) {
    UnitPlannedValueShape => "unit"
    NeverPlannedValueShape => "never"
    I32PlannedValueShape => "i32"
    I64PlannedValueShape => "i64"
    F32PlannedValueShape => "f32"
    F64PlannedValueShape => "f64"
    V128PlannedValueShape => "v128"
    RefPlannedValueShape => "eqref"
    _ => "error"
  }
}

///|
fn program_specialization_abi_key(
  declaration : DeclId,
  shapes : Array[PlannedValueShape],
  span : HirSpan,
) -> String {
  let output = Buffer(size_hint=32 + span.length * 8)
  output.write_string_utf8(declaration.to_string())
  output.write_string_utf8(":")
  for index in 0..<span.length {
    if index > 0 {
      output.write_string_utf8(",")
    }
    output.write_string_utf8(
      program_specialization_shape_name(shapes[span.start + index]),
    )
  }
  @utf8.decode_lossy(output.to_bytes())
}

///|
fn program_specialization_value_type(
  shape : PlannedValueShape,
) -> PlannedWasmValueType? {
  match shape {
    UnitPlannedValueShape | NeverPlannedValueShape => None
    I8PlannedValueShape
    | U8PlannedValueShape
    | I16PlannedValueShape
    | U16PlannedValueShape
    | I32PlannedValueShape
    | U32PlannedValueShape
    | Swar32PlannedValueShape => Some(WasmI32Value)
    I64PlannedValueShape | U64PlannedValueShape | Swar64PlannedValueShape =>
      Some(WasmI64Value)
    F32PlannedValueShape => Some(WasmF32Value)
    F64PlannedValueShape => Some(WasmF64Value)
    V128PlannedValueShape => Some(WasmV128Value)
    RefPlannedValueShape | GenericPlannedValueShape | ErrorPlannedValueShape =>
      Some(WasmNullableEqRefValue)
  }
}

///|
fn program_specialization_shapes_equal(
  values : Array[PlannedValueShape],
  left : HirSpan,
  right_values : Array[PlannedValueShape],
  right : HirSpan,
) -> Bool {
  if left.length != right.length {
    return false
  }
  for index in 0..<left.length {
    if program_canonical_specialization_shape(values[left.start + index]) !=
      program_canonical_specialization_shape(right_values[right.start + index]) {
      return false
    }
  }
  true
}

///|
fn program_generic_parameter_shape(
  resolved : ResolvedModuleTypes,
  type_ : ResolvedTypeId,
  generic_parameters : HirSpan,
  shapes : Array[PlannedValueShape],
  shape_span : HirSpan,
) -> PlannedValueShape? {
  match resolved.types[type_] {
    GenericParameterType(parameter) => {
      let parameter_local = semantic_id_local(parameter)
      if parameter_local >= generic_parameters.start &&
        parameter_local < generic_parameters.start + generic_parameters.length {
        let relative = parameter_local - generic_parameters.start
        if relative < shape_span.length {
          return Some(shapes[shape_span.start + relative])
        }
      }
      None
    }
    _ => None
  }
}

///|
fn program_resolve_specialized_shape(
  module_ : PlannedModuleLowering,
  generic_parameters : HirSpan,
  specialization_values : Array[PlannedValueShape],
  specialization : HirSpan,
  type_ : BodyTypeId,
  fallback : PlannedValueShape,
) -> PlannedValueShape {
  let resolved_type = if type_ < -1 {
    -type_ - 2
  } else if type_ >= 0 && type_ < module_.types.length() {
    match module_.types[type_] {
      BodyResolvedType(value) => value
      _ => -1
    }
  } else {
    -1
  }
  if resolved_type >= 0 && resolved_type < module_.resolved_types.length() {
    match module_.resolved_types[resolved_type] {
      GenericParameterType(parameter) => {
        let parameter_local = semantic_id_local(parameter)
        if parameter_local >= generic_parameters.start &&
          parameter_local < generic_parameters.start + generic_parameters.length {
          let relative = parameter_local - generic_parameters.start
          if relative < specialization.length {
            return specialization_values[specialization.start + relative]
          }
        }
      }
      _ => ()
    }
  }
  if specialization.length == 1 {
    match fallback {
      GenericPlannedValueShape | ErrorPlannedValueShape =>
        return specialization_values[specialization.start]
      _ => ()
    }
  }
  fallback
}

///|
fn materialize_program_generic_specialization(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  module_lookup : Map[ModuleId, Int],
  declaration : DeclId,
  request_shapes : Array[PlannedValueShape],
  request : HirSpan,
) -> Unit {
  let owner_index = match module_lookup.get(semantic_id_module(declaration)) {
    Some(index) => index
    None => return
  }
  let module_ = modules[owner_index]
  for function_ in module_.functions {
    if function_.declaration == declaration &&
      function_.specialization_shapes.length > 0 &&
      program_specialization_shapes_equal(
        module_.specialization_shapes,
        function_.specialization_shapes,
        request_shapes,
        request,
      ) {
      return
    }
  }
  let base_index = module_.function_by_declaration[semantic_id_local(
      declaration,
    )]
  if base_index < 0 || base_index >= module_.functions.length() {
    return
  }
  let base = module_.functions[base_index]
  match base.kind {
    PlannedWasmDefinedFunction(_) => ()
    _ => return
  }
  let callable = match
    lowering.modules[owner_index].functions.callable_of(declaration) {
    Some(callable) => callable
    None => return
  }
  if callable.generic_parameters.length != request.length {
    return
  }
  let shape_start = module_.specialization_shapes.length()
  for index in 0..<request.length {
    module_.specialization_shapes.push(
      program_canonical_specialization_shape(
        request_shapes[request.start + index],
      ),
    )
  }
  let specialization_shapes = { start: shape_start, length: request.length }
  let resolved = analyzed.frozen.interfaces[owner_index].resolved_types
  let parameter_start = module_.function_value_types.length()
  let mut base_parameter_index = 0
  for index in 0..<callable.parameters.length {
    let parameter = lowering.modules[owner_index].functions.parameters[callable.parameters.start +
      index]
    let specialized = program_generic_parameter_shape(
      resolved,
      parameter.type_,
      callable.generic_parameters,
      module_.specialization_shapes,
      specialization_shapes,
    )
    if parameter.shape != UnitPlannedValueShape &&
      parameter.shape != NeverPlannedValueShape {
      match specialized {
        Some(shape) =>
          match program_specialization_value_type(shape) {
            Some(value) => module_.function_value_types.push(value)
            None => ()
          }
        None =>
          module_.function_value_types.push(
            module_.function_value_types[base.parameters.start +
            base_parameter_index],
          )
      }
      base_parameter_index += 1
    }
  }
  let result_start = module_.function_value_types.length()
  let specialized_result = program_generic_parameter_shape(
    resolved,
    callable.result_type,
    callable.generic_parameters,
    module_.specialization_shapes,
    specialization_shapes,
  )
  match specialized_result {
    Some(shape) =>
      match program_specialization_value_type(shape) {
        Some(value) => module_.function_value_types.push(value)
        None => ()
      }
    None =>
      for index in 0..<base.results.length {
        module_.function_value_types.push(
          module_.function_value_types[base.results.start + index],
        )
      }
  }
  module_.functions[base_index] = { ..base, elided: true }
  module_.functions.push({
    ..base,
    visibility: ModuleVisible,
    is_test: false,
    is_test_entry: false,
    test_name: b"",
    elided: false,
    signature_type_index: module_.physical_types.length() +
    module_.signature_type_count,
    function_index: -1,
    parameters: {
      start: parameter_start,
      length: result_start - parameter_start,
    },
    results: {
      start: result_start,
      length: module_.function_value_types.length() - result_start,
    },
    specialization_shapes,
    specialization_abi_key: program_specialization_abi_key(
      declaration,
      module_.specialization_shapes,
      specialization_shapes,
    ),
  })
  modules[owner_index] = {
    ..module_,
    signature_type_count: module_.signature_type_count + 1,
  }
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
  let program_function_value_roots : Map[DeclId, Bool] = Map::default()
  for module_ in lowering.modules {
    for expression in module_.expressions {
      match expression.kind {
        PlannedFunctionReference(declaration, _) =>
          program_function_value_roots[declaration] = true
        _ => ()
      }
    }
  }
  for scc in lowering.graph.sccs {
    for index in 0..<scc.length {
      let module_index = lowering.graph.scc_modules[scc.start + index]
      slots[module_index] = Some(
        plan_module_wasmgc_fragments_with_options_and_roots(
          analyzed.frozen.interfaces[module_index].resolved_types,
          lowering.modules[module_index],
          options,
          program_roots,
          program_function_value_roots,
        ),
      )
    }
  }
  let modules : Array[PlannedModuleWasmGCFragments] = []
  for slot in slots {
    modules.push(slot.unwrap())
  }
  let specialization_module_lookup : Map[ModuleId, Int] = Map::default()
  for module_index, module_ in modules {
    specialization_module_lookup[module_.module_id] = module_index
  }
  for module_index, module_ in lowering.modules {
    for expression in module_.expressions {
      match expression.kind {
        PlannedDirectCall(declaration, _, _, arguments) if arguments.length > 0 =>
          materialize_program_generic_specialization(
            analyzed,
            lowering,
            modules,
            specialization_module_lookup,
            declaration,
            module_.call_type_argument_shapes,
            arguments,
          )
        PlannedFunctionReference(declaration, arguments) if arguments.length > 0 =>
          materialize_program_generic_specialization(
            analyzed,
            lowering,
            modules,
            specialization_module_lookup,
            declaration,
            module_.expression_type_argument_shapes,
            arguments,
          )
        _ => ()
      }
    }
    ignore(module_index)
  }
  let mut specialization_changed = true
  while specialization_changed {
    let mut before = 0
    for module_ in modules {
      before += module_.functions.length()
    }
    for owner_index, fragments_ in modules {
      let function_count = fragments_.functions.length()
      for function_index in 0..<function_count {
        let function_ = fragments_.functions[function_index]
        if function_.specialization_shapes.length == 0 {
          continue
        }
        let body_id = match function_.kind {
          PlannedWasmDefinedFunction(body) => body
          _ => continue
        }
        let owner = lowering.modules[owner_index]
        let callable = match
          owner.functions.callable_of(function_.declaration) {
          Some(value) => value
          None => continue
        }
        let body_index = semantic_id_local(body_id)
        if body_index < 0 || body_index >= owner.bodies.length() {
          continue
        }
        let body = owner.bodies[body_index]
        for
          expression_index in body.expressions.start..<(body.expressions.start +
          body.expressions.length) {
          let (target, arguments) = match
            owner.expressions[expression_index].kind {
            PlannedDirectCall(target, _, _, arguments) if arguments.length > 0 =>
              (target, arguments)
            _ => continue
          }
          let resolved_shapes : Array[PlannedValueShape] = []
          for argument_index in 0..<arguments.length {
            let source_index = arguments.start + argument_index
            resolved_shapes.push(
              program_resolve_specialized_shape(
                owner,
                callable.generic_parameters,
                fragments_.specialization_shapes,
                function_.specialization_shapes,
                owner.call_type_arguments[source_index],
                owner.call_type_argument_shapes[source_index],
              ),
            )
          }
          materialize_program_generic_specialization(
            analyzed,
            lowering,
            modules,
            specialization_module_lookup,
            target,
            resolved_shapes,
            { start: 0, length: resolved_shapes.length() },
          )
        }
      }
    }
    let mut after = 0
    for module_ in modules {
      after += module_.functions.length()
    }
    specialization_changed = after > before
  }
  for module_index, fragments_ in modules {
    for function_index in 0..<fragments_.functions.length() {
      let function_ = fragments_.functions[function_index]
      if function_.specialization_shapes.length > 0 {
        continue
      }
      match
        lowering.modules[module_index].functions.callable_of(
          function_.declaration,
        ) {
        Some(callable) if callable.generic_parameters.length > 0 =>
          fragments_.functions[function_index] = { ..function_, elided: true }
        _ => ()
      }
    }
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
fn program_initializer_dependencies(
  lowering : PlannedProgramLowering,
  initializer : PlannedProgramModuleInitializer,
  initializer_lookup : Map[DeclId, Int],
) -> Array[Int] {
  let module_lookup : Map[ModuleId, Int] = Map::default()
  for module_index, module_ in lowering.modules {
    module_lookup[module_.module_id] = module_index
  }
  let dependencies : Array[Int] = []
  let seen_dependencies : Map[Int, Bool] = Map::default()
  let seen_bodies : Map[BodyId, Bool] = Map::default()
  let body_modules : Array[Int] = [initializer.module_index]
  let body_tasks : Array[BodyId] = [initializer.body]
  while body_tasks.length() > 0 {
    let body_id = body_tasks.pop().unwrap()
    let module_index = body_modules.pop().unwrap()
    if seen_bodies.contains(body_id) {
      continue
    }
    seen_bodies[body_id] = true
    let module_ = lowering.modules[module_index]
    let body_index = semantic_id_local(body_id)
    if body_index < 0 || body_index >= module_.bodies.length() {
      continue
    }
    let body = module_.bodies[body_index]
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      match module_.expressions[expression].kind {
        PlannedModuleValueGet(declaration, _) =>
          match initializer_lookup.get(declaration) {
            Some(dependency) if !seen_dependencies.contains(dependency) => {
              seen_dependencies[dependency] = true
              dependencies.push(dependency)
            }
            _ => ()
          }
        PlannedDirectCall(target, _, _, _)
        | PlannedOperatorCall(target, _, _, _, _)
        | PlannedIndexCall(target, _, _, _)
        | PlannedIndexSetCall(target, _, _, _, _) => {
          let owner = match module_lookup.get(semantic_id_module(target)) {
            Some(value) => value
            None => continue
          }
          let callable = match
            lowering.modules[owner].functions.callable_of(target) {
            Some(value) => value
            None => continue
          }
          let target_body = match callable.kind {
            PlannedFunctionCallable(body)
            | PlannedImplMethodCallable(_, Some(body)) => body
            _ => continue
          }
          if !seen_bodies.contains(target_body) {
            body_modules.push(owner)
            body_tasks.push(target_body)
          }
        }
        _ => ()
      }
    }
  }
  dependencies
}

///|
fn program_schedule_initializers(
  lowering : PlannedProgramLowering,
  candidates : Array[PlannedProgramModuleInitializer],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> Array[PlannedProgramModuleInitializer] {
  let lookup : Map[DeclId, Int] = Map::default()
  for index, initializer in candidates {
    lookup[initializer.declaration] = index
  }
  let dependencies : Array[Array[Int]] = []
  let remaining_dependencies = Array::make(candidates.length(), 0)
  for index, initializer in candidates {
    let values = program_initializer_dependencies(lowering, initializer, lookup)
    dependencies.push(values)
    remaining_dependencies[index] = values.length()
  }
  let scheduled = Array::make(candidates.length(), false)
  let output : Array[PlannedProgramModuleInitializer] = []
  while output.length() < candidates.length() {
    let mut selected = -1
    for index in 0..<candidates.length() {
      if !scheduled[index] && remaining_dependencies[index] == 0 {
        selected = index
        break
      }
    }
    if selected < 0 {
      let mut first = -1
      for index in 0..<candidates.length() {
        if !scheduled[index] {
          first = index
          break
        }
      }
      if first >= 0 {
        let mut second = first
        for dependency in dependencies[first] {
          if !scheduled[dependency] {
            second = dependency
            break
          }
        }
        diagnostics.push(
          EagerProgramInitializationCycle(
            candidates[first].declaration,
            candidates[second].declaration,
          ),
        )
      }
      for index in 0..<candidates.length() {
        if !scheduled[index] {
          scheduled[index] = true
          output.push(candidates[index])
        }
      }
      break
    }
    scheduled[selected] = true
    output.push(candidates[selected])
    for dependent in 0..<candidates.length() {
      if scheduled[dependent] {
        continue
      }
      for dependency in dependencies[dependent] {
        if dependency == selected {
          remaining_dependencies[dependent] -= 1
          break
        }
      }
    }
  }
  output
}

///|
fn program_physical_type_sccs(
  dependencies : Array[Array[Int]],
) -> (Array[HirSpan], Array[Int]) {
  let count = dependencies.length()
  if count == 0 {
    return ([], [])
  }
  let visited = Array::make(count, false)
  let work : Array[Int] = []
  let finish_order : Array[Int] = []
  for start in 0..<count {
    if visited[start] {
      continue
    }
    work.push(start)
    while work.length() > 0 {
      let item = work.pop().unwrap()
      if item < 0 {
        finish_order.push(-item - 1)
        continue
      }
      if visited[item] {
        continue
      }
      visited[item] = true
      work.push(-item - 1)
      let edges = dependencies[item]
      let mut edge = edges.length()
      while edge > 0 {
        edge -= 1
        let dependency = edges[edge]
        if !visited[dependency] {
          work.push(dependency)
        }
      }
    }
  }
  let reverse_counts = Array::make(count, 0)
  for source in 0..<count {
    for dependency in dependencies[source] {
      reverse_counts[dependency] += 1
    }
  }
  let reverse_offsets = Array::make(count + 1, 0)
  for index in 0..<count {
    reverse_offsets[index + 1] = reverse_offsets[index] + reverse_counts[index]
  }
  let reverse_cursor = Array::make(count, 0)
  for index in 0..<count {
    reverse_cursor[index] = reverse_offsets[index]
  }
  let reverse_edges = Array::make(reverse_offsets[count], 0)
  for source in 0..<count {
    for dependency in dependencies[source] {
      let destination = reverse_cursor[dependency]
      reverse_edges[destination] = source
      reverse_cursor[dependency] += 1
    }
  }
  let finish_rank = Array::make(count, 0)
  for rank, entity in finish_order {
    finish_rank[entity] = rank
  }
  let assigned = Array::make(count, false)
  let component : Array[Int] = []
  let raw_spans : Array[HirSpan] = []
  let raw_members : Array[Int] = []
  let raw_ranks : Array[Int] = []
  let mut order_index = finish_order.length()
  while order_index > 0 {
    order_index -= 1
    let start = finish_order[order_index]
    if assigned[start] {
      continue
    }
    component.clear()
    work.clear()
    work.push(start)
    assigned[start] = true
    let mut rank = finish_rank[start]
    while work.length() > 0 {
      let entity = work.pop().unwrap()
      component.push(entity)
      if finish_rank[entity] < rank {
        rank = finish_rank[entity]
      }
      for edge in reverse_offsets[entity]..<reverse_offsets[entity + 1] {
        let dependent = reverse_edges[edge]
        if !assigned[dependent] {
          assigned[dependent] = true
          work.push(dependent)
        }
      }
    }
    component.sort()
    let start = raw_members.length()
    for entity in component {
      raw_members.push(entity)
    }
    raw_spans.push({ start, length: raw_members.length() - start })
    raw_ranks.push(rank)
  }
  let order : Array[Int] = []
  for index in 0..<raw_spans.length() {
    order.push(index)
  }
  order.sort_by(fn(left, right) {
    let rank = raw_ranks[left] - raw_ranks[right]
    if rank != 0 {
      rank
    } else {
      raw_members[raw_spans[left].start] - raw_members[raw_spans[right].start]
    }
  })
  let spans : Array[HirSpan] = []
  let members : Array[Int] = []
  for component_index in order {
    let source = raw_spans[component_index]
    let start = members.length()
    for index in 0..<source.length {
      members.push(raw_members[source.start + index])
    }
    spans.push({ start, length: members.length() - start })
  }
  (spans, members)
}

///|
fn program_cross_module_type_groups(
  fragments : PlannedProgramWasmGCFragments,
  module_lookup : Map[ModuleId, Int],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> (
  Array[Array[Int]],
  Array[PlannedProgramWasmRecursiveGroup],
  Array[PlannedProgramWasmPhysicalType],
  Map[DeclId, Int],
) {
  let node_by_module_type : Array[Array[Int]] = []
  for module_ in fragments.modules {
    node_by_module_type.push(Array::make(module_.physical_types.length(), -1))
  }
  let nodes : Array[PlannedProgramWasmPhysicalType] = []
  let mut canonical_closure_node = -1
  for scc in fragments.graph.sccs {
    for member_index in 0..<scc.length {
      let module_index = fragments.graph.scc_modules[scc.start + member_index]
      let module_ = fragments.modules[module_index]
      for fragment_index, physical in module_.physical_types {
        match physical.kind {
          PlannedWasmClosureType if canonical_closure_node >= 0 =>
            node_by_module_type[module_index][fragment_index] = canonical_closure_node
          PlannedWasmClosureType => {
            canonical_closure_node = nodes.length()
            node_by_module_type[module_index][fragment_index] = canonical_closure_node
            nodes.push({ module_index, fragment_index })
          }
          _ => {
            node_by_module_type[module_index][fragment_index] = nodes.length()
            nodes.push({ module_index, fragment_index })
          }
        }
      }
    }
  }
  let dependencies : Array[Array[Int]] = []
  for node in nodes {
    let module_ = fragments.modules[node.module_index]
    let physical = module_.physical_types[node.fragment_index]
    let values : Array[Int] = []
    let marks : Map[Int, Bool] = Map::default()
    let add_local = fn(local_type_index : Int) {
      if local_type_index < 0 ||
        local_type_index >= node_by_module_type[node.module_index].length() {
        return
      }
      let dependency = node_by_module_type[node.module_index][local_type_index]
      if dependency >= 0 && !marks.contains(dependency) {
        marks[dependency] = true
        values.push(dependency)
      }
    }
    let add_external = fn(declaration : DeclId) {
      let owner = match module_lookup.get(semantic_id_module(declaration)) {
        Some(value) => value
        None => {
          diagnostics.push(MissingProgramType(module_.module_id, declaration))
          return
        }
      }
      let local_type_index = match
        fragments.modules[owner].type_index_of(declaration) {
        Some(value) => value
        None => {
          diagnostics.push(MissingProgramType(module_.module_id, declaration))
          return
        }
      }
      let dependency = node_by_module_type[owner][local_type_index]
      if dependency >= 0 && !marks.contains(dependency) {
        marks[dependency] = true
        values.push(dependency)
      }
    }
    match physical.kind {
      PlannedWasmEnumSubtypeType(declaration, _, _) => add_external(declaration)
      PlannedWasmLambdaClosureType(_) => add_local(module_.closure_type_index)
      _ => ()
    }
    for index in 0..<physical.fields.length {
      match module_.fields[physical.fields.start + index].storage {
        WasmNominalRefStorage(WasmModuleTypeReference(local_type_index)) =>
          add_local(local_type_index)
        WasmNominalRefStorage(WasmRecursiveTypeReference(group_member)) => {
          let group = module_.type_groups[physical.group_index]
          add_local(group.first_type_index + group_member)
        }
        WasmExternalNominalRefStorage(declaration) => add_external(declaration)
        _ => ()
      }
    }
    values.sort()
    dependencies.push(values)
  }
  let (component_spans, component_members) = program_physical_type_sccs(
    dependencies,
  )
  let module_type_indices : Array[Array[Int]] = []
  for module_ in fragments.modules {
    module_type_indices.push(Array::make(module_.physical_types.length(), -1))
  }
  let groups : Array[PlannedProgramWasmRecursiveGroup] = []
  let physical_types : Array[PlannedProgramWasmPhysicalType] = []
  let type_lookup : Map[DeclId, Int] = Map::default()
  let final_index_by_node = Array::make(nodes.length(), -1)
  for component in component_spans {
    let first_type_index = physical_types.length()
    let start = physical_types.length()
    for index in 0..<component.length {
      let node = nodes[component_members[component.start + index]]
      let final_type_index = physical_types.length()
      final_index_by_node[component_members[component.start + index]] = final_type_index
      module_type_indices[node.module_index][node.fragment_index] = final_type_index
      let physical = fragments.modules[node.module_index].physical_types[node.fragment_index]
      match physical.kind {
        PlannedWasmStructType(declaration)
        | PlannedWasmEnumBaseType(declaration) =>
          type_lookup[declaration] = final_type_index
        PlannedWasmEnumSubtypeType(_, _, _)
        | PlannedWasmClosureType
        | PlannedWasmCaptureCellType(_)
        | PlannedWasmLambdaClosureType(_) => ()
      }
      physical_types.push(node)
    }
    groups.push({
      types: { start, length: physical_types.length() - start },
      first_type_index,
    })
  }
  for module_index, indices in node_by_module_type {
    for fragment_index, node in indices {
      if node >= 0 {
        module_type_indices[module_index][fragment_index] = final_index_by_node[node]
      }
    }
  }
  (module_type_indices, groups, physical_types, type_lookup)
}

///|
priv struct PlannedProgramValueTypePair {
  left_module : Int
  left : PlannedWasmValueType
  right_module : Int
  right : PlannedWasmValueType
}

///|
fn planned_program_function_type_fragment(
  modules : Array[PlannedModuleWasmGCFragments],
  module_index : Int,
  signature_type_index : Int,
) -> PlannedWasmFunctionTypeFragment? {
  for function_type in modules[module_index].function_types {
    if function_type.signature_type_index == signature_type_index {
      return Some(function_type)
    }
  }
  None
}

///|
fn planned_program_local_nominal_declaration(
  modules : Array[PlannedModuleWasmGCFragments],
  module_index : Int,
  type_index : Int,
) -> DeclId? {
  if type_index < 0 ||
    type_index >= modules[module_index].physical_types.length() {
    return None
  }
  match modules[module_index].physical_types[type_index].kind {
    PlannedWasmStructType(declaration) | PlannedWasmEnumBaseType(declaration) =>
      Some(declaration)
    PlannedWasmEnumSubtypeType(_, _, _)
    | PlannedWasmClosureType
    | PlannedWasmCaptureCellType(_)
    | PlannedWasmLambdaClosureType(_) => None
  }
}

///|
fn planned_program_function_types_equal(
  modules : Array[PlannedModuleWasmGCFragments],
  left_module : Int,
  left : PlannedWasmFunctionTypeFragment,
  right_module : Int,
  right : PlannedWasmFunctionTypeFragment,
) -> Bool {
  if left.parameters.length != right.parameters.length ||
    left.results.length != right.results.length {
    return false
  }
  let work : Array[PlannedProgramValueTypePair] = []
  for index in 0..<left.parameters.length {
    work.push({
      left_module,
      left: modules[left_module].function_value_types[left.parameters.start +
      index],
      right_module,
      right: modules[right_module].function_value_types[right.parameters.start +
      index],
    })
  }
  for index in 0..<left.results.length {
    work.push({
      left_module,
      left: modules[left_module].function_value_types[left.results.start + index],
      right_module,
      right: modules[right_module].function_value_types[right.results.start +
      index],
    })
  }
  while work.length() > 0 {
    let pair = work.pop().unwrap()
    match (pair.left, pair.right) {
      (WasmI32Value, WasmI32Value)
      | (WasmI64Value, WasmI64Value)
      | (WasmF32Value, WasmF32Value)
      | (WasmF64Value, WasmF64Value)
      | (WasmV128Value, WasmV128Value)
      | (WasmStringRefValue, WasmStringRefValue)
      | (WasmNullableEqRefValue, WasmNullableEqRefValue) => ()
      (WasmExternalNominalRefValue(left), WasmExternalNominalRefValue(right)) =>
        if left != right {
          return false
        }
      (WasmNominalRefValue(left), WasmNominalRefValue(right)) => {
        let left_declaration = match
          planned_program_local_nominal_declaration(
            modules,
            pair.left_module,
            left,
          ) {
          Some(value) => value
          None => return false
        }
        let right_declaration = match
          planned_program_local_nominal_declaration(
            modules,
            pair.right_module,
            right,
          ) {
          Some(value) => value
          None => return false
        }
        if left_declaration != right_declaration {
          return false
        }
      }
      (WasmNominalRefValue(left), WasmExternalNominalRefValue(right)) =>
        if planned_program_local_nominal_declaration(
            modules,
            pair.left_module,
            left,
          ) !=
          Some(right) {
          return false
        }
      (WasmExternalNominalRefValue(left), WasmNominalRefValue(right)) =>
        if Some(left) !=
          planned_program_local_nominal_declaration(
            modules,
            pair.right_module,
            right,
          ) {
          return false
        }
      (WasmFunctionRefValue(left), WasmFunctionRefValue(right)) => {
        let left_type = match
          planned_program_function_type_fragment(
            modules,
            pair.left_module,
            left,
          ) {
          Some(value) => value
          None => return false
        }
        let right_type = match
          planned_program_function_type_fragment(
            modules,
            pair.right_module,
            right,
          ) {
          Some(value) => value
          None => return false
        }
        if left_type.parameters.length != right_type.parameters.length ||
          left_type.results.length != right_type.results.length {
          return false
        }
        for index in 0..<left_type.parameters.length {
          work.push({
            left_module: pair.left_module,
            left: modules[pair.left_module].function_value_types[left_type.parameters.start +
            index],
            right_module: pair.right_module,
            right: modules[pair.right_module].function_value_types[right_type.parameters.start +
            index],
          })
        }
        for index in 0..<left_type.results.length {
          work.push({
            left_module: pair.left_module,
            left: modules[pair.left_module].function_value_types[left_type.results.start +
            index],
            right_module: pair.right_module,
            right: modules[pair.right_module].function_value_types[right_type.results.start +
            index],
          })
        }
      }
      _ => return false
    }
  }
  true
}

///|
/// Assigns final program-wide type and function indices without mutating any
/// module-local fragment plan. Module-local recursive groups remain intact
/// unless physical dependencies form an SCC across module boundaries.
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
  let module_type_indices : Array[Array[Int]] = []
  for module_ in fragments.modules {
    module_type_indices.push(Array::make(module_.physical_types.length(), -1))
  }
  let functions : Array[PlannedProgramWasmFunction] = []
  let function_lookup : Map[DeclId, Int] = Map::default()
  let type_lookup : Map[DeclId, Int] = Map::default()
  let module_lookup : Map[ModuleId, Int] = Map::default()
  let diagnostics : Array[ProgramWasmGCLinkDiagnostic] = []
  let test_ordinals : Map[DeclId, Int] = Map::default()
  let mut next_test_ordinal = 0
  for module_index, module_ in fragments.modules {
    module_lookup[module_.module_id] = module_index
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
      module_type_bases[module_index] = type_count
      for physical in module_fragments.physical_types {
        module_type_indices[module_index][physical.type_index] = type_count +
          physical.type_index
        match physical.kind {
          PlannedWasmStructType(declaration)
          | PlannedWasmEnumBaseType(declaration) =>
            type_lookup[declaration] = type_count + physical.type_index
          PlannedWasmEnumSubtypeType(_, _, _)
          | PlannedWasmClosureType
          | PlannedWasmCaptureCellType(_)
          | PlannedWasmLambdaClosureType(_) => ()
        }
      }
      type_count += module_fragments.physical_types.length()
    }
  }
  let mut closure_base_count = 0
  for module_ in fragments.modules {
    if module_.closure_type_index >= 0 {
      closure_base_count += 1
    }
  }
  let mut cross_module_type_scc = closure_base_count > 1
  for reference in fragments.external_type_references {
    match type_lookup.get(reference.declaration) {
      Some(index) =>
        if index >= module_type_bases[reference.module_index] {
          cross_module_type_scc = true
        }
      None => ()
    }
  }
  let program_type_groups : Array[PlannedProgramWasmRecursiveGroup] = []
  let program_physical_types : Array[PlannedProgramWasmPhysicalType] = []
  if cross_module_type_scc {
    let (cross_indices, cross_groups, cross_types, cross_lookup) = program_cross_module_type_groups(
      fragments, module_lookup, diagnostics,
    )
    for module_index in 0..<module_type_indices.length() {
      module_type_indices[module_index] = cross_indices[module_index]
    }
    for group in cross_groups {
      program_type_groups.push(group)
    }
    for physical in cross_types {
      program_physical_types.push(physical)
    }
    for declaration, index in cross_lookup {
      type_lookup[declaration] = index
    }
    type_count = program_physical_types.length()
  } else {
    program_link_validate_types(fragments, type_lookup, diagnostics)
    type_count = 0
  }
  let module_signature_indices : Array[Array[Int]] = []
  for module_ in fragments.modules {
    module_signature_indices.push(Array::make(module_.signature_type_count, -1))
  }
  let program_signature_types : Array[PlannedProgramWasmSignatureType] = []
  for scc in lowering.graph.sccs {
    for index in 0..<scc.length {
      let module_index = lowering.graph.scc_modules[scc.start + index]
      let module_ = fragments.modules[module_index]
      if !cross_module_type_scc {
        module_type_bases[module_index] = type_count
        for physical in module_.physical_types {
          module_type_indices[module_index][physical.type_index] = type_count +
            physical.type_index
          match physical.kind {
            PlannedWasmStructType(declaration)
            | PlannedWasmEnumBaseType(declaration) =>
              type_lookup[declaration] = type_count + physical.type_index
            PlannedWasmEnumSubtypeType(_, _, _)
            | PlannedWasmClosureType
            | PlannedWasmCaptureCellType(_)
            | PlannedWasmLambdaClosureType(_) => ()
          }
        }
        type_count += module_.physical_types.length()
      }
      for function_type_index, function_type in module_.function_types {
        let local_signature = function_type.signature_type_index -
          module_.physical_types.length()
        let mut representative_type_index = -1
        for candidate in program_signature_types {
          match candidate.kind {
            PlannedProgramFunctionType(candidate_function_type_index) => {
              let candidate_type = fragments.modules[candidate.module_index].function_types[candidate_function_type_index]
              if planned_program_function_types_equal(
                  fragments.modules,
                  module_index,
                  function_type,
                  candidate.module_index,
                  candidate_type,
                ) {
                representative_type_index = candidate.type_index
                break
              }
            }
            PlannedProgramFunctionSignature(_) => ()
          }
        }
        if representative_type_index < 0 {
          representative_type_index = type_count
          program_signature_types.push({
            module_index,
            type_index: representative_type_index,
            kind: PlannedProgramFunctionType(function_type_index),
          })
          type_count += 1
        }
        module_signature_indices[module_index][local_signature] = representative_type_index
      }
      for function_index, function_ in module_.functions {
        if function_.signature_type_index < 0 {
          continue
        }
        let local_signature = function_.signature_type_index -
          module_.physical_types.length()
        if module_signature_indices[module_index][local_signature] < 0 {
          module_signature_indices[module_index][local_signature] = type_count
          program_signature_types.push({
            module_index,
            type_index: type_count,
            kind: PlannedProgramFunctionSignature(function_index),
          })
          type_count += 1
        }
      }
    }
  }
  for scc in lowering.graph.sccs {
    for index in 0..<scc.length {
      let module_index = lowering.graph.scc_modules[scc.start + index]
      let module_fragments = fragments.modules[module_index]
      for physical in module_fragments.physical_types {
        match physical.kind {
          PlannedWasmStructType(declaration)
          | PlannedWasmEnumBaseType(declaration) =>
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
          PlannedWasmEnumSubtypeType(_, _, _)
          | PlannedWasmClosureType
          | PlannedWasmCaptureCellType(_)
          | PlannedWasmLambdaClosureType(_) => ()
        }
      }
      for fragment_index, function_ in module_fragments.functions {
        let entry = functions.length()
        if function_.specialization_shapes.length == 0 {
          function_lookup[function_.declaration] = entry
        }
        functions.push({
          declaration: function_.declaration,
          lambda: function_.lambda,
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
            module_signature_indices[module_index][function_.signature_type_index -
            module_fragments.physical_types.length()]
          } else {
            -1
          },
          function_index: -1,
          parameters: function_.parameters,
          results: function_.results,
          specialization_shapes: function_.specialization_shapes,
          specialization_abi_key: function_.specialization_abi_key,
          offset: function_.offset,
        })
      }
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
      | PlannedWasmDefinedLambdaFunction(_)
      | PlannedWasmSignatureOnlyFunction => ()
    }
  }
  let mut defined_function_count = 0
  for function_ in functions {
    match function_.kind {
      PlannedWasmDefinedFunction(_)
      | PlannedWasmDefinedLambdaFunction(_)
      | PlannedWasmRuntimeFunction(_) =>
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
  let initializer_candidates : Array[PlannedProgramModuleInitializer] = []
  let global_lookup : Map[DeclId, Int] = Map::default()
  let mut global_index = 0
  for scc in lowering.graph.sccs {
    for member_index in 0..<scc.length {
      let module_index = lowering.graph.scc_modules[scc.start + member_index]
      let module_ = lowering.modules[module_index]
      for step in module_.initialization.steps {
        match step.kind {
          PlannedInitializeModuleValue(declaration, body, _) => {
            if step.test_only && !fragments.modules[module_index].emit_tests {
              continue
            }
            let body_index = semantic_id_local(body)
            if body_index < 0 || body_index >= module_.bodies.length() {
              continue
            }
            let shape = module_.bodies[body_index].root_shape
            let value_global = match shape {
              UnitPlannedValueShape | NeverPlannedValueShape => -1
              _ => {
                let index = global_index
                global_lookup[declaration] = index
                global_index += 1
                index
              }
            }
            let constant = match module_.bodies[body_index].root {
              ExpressionBodyRoot(expression) =>
                match module_.expressions[expression].kind {
                  PlannedI8Const(_)
                  | PlannedI16Const(_)
                  | PlannedI32Const(_)
                  | PlannedI64Const(_)
                  | PlannedU8Const(_)
                  | PlannedU16Const(_)
                  | PlannedU32Const(_)
                  | PlannedU64Const(_)
                  | PlannedF32Const(_)
                  | PlannedF64Const(_)
                  | PlannedBoolConst(_) => true
                  _ => false
                }
              BlockBodyRoot(_) => false
            }
            initializer_candidates.push({
              declaration,
              module_index,
              body,
              shape,
              test_only: step.test_only,
              constant,
              global_index: value_global,
              function_index: -1,
            })
          }
          PlannedCyclicModuleValues(_) => ()
        }
      }
    }
  }
  let function_reference_singletons : Array[
    PlannedProgramFunctionReferenceSingleton,
  ] = []
  let singleton_functions : Map[Int, Bool] = Map::default()
  for module_index, module_ in lowering.modules {
    for expression in module_.expressions {
      match expression.kind {
        PlannedFunctionReference(declaration, arguments) => {
          let target = if arguments.length > 0 {
            let mut selected = None
            for function_ in functions {
              if function_.declaration == declaration &&
                function_.specialization_shapes.length > 0 &&
                program_specialization_shapes_equal(
                  fragments.modules[function_.module_index].specialization_shapes,
                  function_.specialization_shapes,
                  module_.expression_type_argument_shapes,
                  arguments,
                ) {
                selected = Some(function_)
                break
              }
            }
            selected
          } else {
            match function_lookup.get(declaration) {
              Some(index) => Some(functions[index])
              None => None
            }
          }
          match target {
            Some(function_) if function_.function_index >= 0 &&
              !singleton_functions.contains(function_.function_index) => {
              singleton_functions[function_.function_index] = true
              function_reference_singletons.push({
                module_index,
                declaration,
                function_index: function_.function_index,
                specialization_module_index: function_.module_index,
                specialization_shapes: function_.specialization_shapes,
                global_index,
              })
              global_index += 1
            }
            _ => ()
          }
        }
        _ => ()
      }
    }
  }
  let scheduled_initializers = program_schedule_initializers(
    lowering, initializer_candidates, diagnostics,
  )
  let initializers : Array[PlannedProgramModuleInitializer] = []
  let mut runtime_initializer_count = 0
  for initializer in scheduled_initializers {
    if initializer.constant {
      initializers.push(initializer)
    } else {
      initializers.push({
        ..initializer,
        function_index: imported_function_count + defined_function_count,
      })
      defined_function_count += 1
      runtime_initializer_count += 1
    }
  }
  let needs_startup = runtime_initializer_count > 0 ||
    function_reference_singletons.length() > 0
  let initializer_type_index = if needs_startup {
    let index = type_count
    type_count += 1
    index
  } else {
    -1
  }
  let startup_function_index = if needs_startup {
    let index = imported_function_count + defined_function_count
    defined_function_count += 1
    index
  } else {
    -1
  }
  program_link_validate_calls(
    lowering,
    fragments.modules,
    functions,
    function_lookup,
    diagnostics,
  )
  {
    root_module_index,
    graph: lowering.graph,
    modules: fragments.modules,
    module_type_bases,
    module_signature_indices,
    module_type_indices,
    program_type_groups,
    program_signature_types,
    program_physical_types,
    functions,
    function_lookup,
    initializers,
    global_lookup,
    function_reference_singletons,
    initializer_type_index,
    startup_function_index,
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
