///|
pub struct PlannedProgramLowering {
  graph : ModuleDependencyGraph
  modules : Array[PlannedModuleLowering]
  elided_trait_wrappers : Array[DeclId]
}

///|
pub enum ProgramWasmGCLinkDiagnostic {
  MissingProgramType(ModuleId, DeclId)
  UnsupportedProgramGenericCall(ModuleId, DeclId, UInt64)
  MissingProgramFunction(ModuleId, DeclId, UInt64)
  EagerProgramInitializationCycle(DeclId, DeclId)
} derive(Eq, Debug)

///|
pub struct PlannedProgramSpecializedCall {
  caller_body : BodyId
  caller_specialization_abi_key : String
  expression : ExprId
  target : DeclId
  target_specialization_abi_key : String
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
pub struct PlannedProgramWasmGCFragments {
  graph : ModuleDependencyGraph
  modules : Array[PlannedModuleWasmGCFragments]
  external_type_references : Array[PlannedProgramExternalTypeReference]
  specialized_calls : Array[PlannedProgramSpecializedCall]
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
  specialized_call_lookup : Map[String, Int]
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
  type_count : Int
  imported_function_count : Int
  defined_function_count : Int
  diagnostics : Array[ProgramWasmGCLinkDiagnostic]
}

///|
fn program_specialized_call_key(
  body : BodyId,
  specialization_abi_key : String,
  expression : ExprId,
) -> String {
  body.to_string() + ":" + specialization_abi_key + ":" + expression.to_string()
}

///|
pub fn PlannedProgramWasmGCLink::specialized_call_function(
  self : PlannedProgramWasmGCLink,
  body : BodyId,
  specialization_abi_key : String,
  expression : ExprId,
) -> PlannedProgramWasmFunction? {
  match
    self.specialized_call_lookup.get(
      program_specialized_call_key(body, specialization_abi_key, expression),
    ) {
    Some(index) => Some(self.functions[index])
    None => None
  }
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
fn transparent_callback_root_expression(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
) -> ExprId {
  match body.root {
    ExpressionBodyRoot(expression) => expression
    BlockBodyRoot(block) => {
      let items = module_.blocks[block].items
      if items.length == 1 {
        return match module_.block_items[items.start].kind {
          PlannedExpressionItem(expression) | PlannedReturnItem(expression) =>
            expression
          _ => -1
        }
      }
      if items.length != 2 {
        return -1
      }
      let (local_id, initializer) = match
        module_.block_items[items.start].kind {
        PlannedLetItem(local_id, false, initializer) => (local_id, initializer)
        _ => return -1
      }
      let tail = match module_.block_items[items.start + 1].kind {
        PlannedExpressionItem(expression) | PlannedReturnItem(expression) =>
          expression
        _ => return -1
      }
      match module_.expressions[tail].kind {
        PlannedLocalGet(tail_local_id) if tail_local_id == local_id =>
          initializer
        _ => -1
      }
    }
  }
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
  let root_expression = transparent_callback_root_expression(module_, body)
  if root_expression < 0 {
    return -1
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
fn program_callable_generic_parameters(callable : PlannedCallable) -> HirSpan {
  if callable.owner_generic_parameters.length > 0 {
    callable.owner_generic_parameters
  } else {
    callable.generic_parameters
  }
}

///|
priv struct GenericParameterSelector {
  parameter : Int
  trait_declaration : DeclId
  evidence_slot : Int
}

///|
fn generic_parameter_selector_root_expression(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
) -> ExprId {
  match body.root {
    BlockBodyRoot(block) => {
      if block < 0 || block >= module_.blocks.length() {
        return -1
      }
      let items = module_.blocks[block].items
      if items.length != 1 ||
        items.start < 0 ||
        items.start >= module_.block_items.length() {
        return -1
      }
      match module_.block_items[items.start].kind {
        PlannedExpressionItem(expression) | PlannedReturnItem(expression) =>
          expression
        _ => -1
      }
    }
    ExpressionBodyRoot(expression) => expression
  }
}

///|
fn generic_parameter_selector(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
) -> GenericParameterSelector? {
  let callable = match module_.functions.callable_of(body.declaration) {
    Some(callable) => callable
    None => return None
  }
  if program_callable_generic_parameters(callable).length == 0 {
    return None
  }
  let root_expression = generic_parameter_selector_root_expression(
    module_, body,
  )
  if root_expression < 0 || root_expression >= module_.expressions.length() {
    return None
  }
  let (trait_declaration, evidence_slot) = match
    module_.expressions[root_expression].trait_object_coercion {
    NoInferredTraitObjectCoercion => (0UL, -1)
    SelectedInferredTraitObjectCoercion(trait_, evidence) =>
      if evidence >= 0 && evidence < module_.trait_evidence.length() {
        match module_.trait_evidence[evidence].kind {
          BoundInferredTraitEvidence(slot) => (trait_, slot)
          _ => return None
        }
      } else {
        return None
      }
    ErrorInferredTraitObjectCoercion => return None
  }
  let local_id = match module_.expressions[root_expression].kind {
    PlannedLocalGet(local_id) => local_id
    PlannedParameterSelect(arguments, selected) if selected >= 0 &&
      selected < arguments.length => {
      let selected_expression = module_.expression_children[arguments.start +
        selected]
      match module_.expressions[selected_expression].kind {
        PlannedLocalGet(value) => value
        _ => return None
      }
    }
    _ => return None
  }
  let mut parameter_index = 0
  for index in 0..<body.locals.length {
    match module_.locals[body.locals.start + index].kind {
      ParameterLocal => {
        if index == local_id {
          return Some({
            parameter: parameter_index,
            trait_declaration,
            evidence_slot,
          })
        }
        parameter_index += 1
      }
      _ => return None
    }
  }
  None
}

///|
priv struct GenericParameterSelectorCallSite {
  module_index : Int
  expression : ExprId
  root_body : Int
}

///|
fn rewrite_generic_parameter_selector_call(
  module_ : PlannedModuleLowering,
  expression : ExprId,
  selector : GenericParameterSelector,
) -> Bool {
  if expression < 0 || expression >= module_.expressions.length() {
    return false
  }
  let arguments = match module_.expressions[expression].kind {
    PlannedDirectCall(_, receiver, arguments, type_arguments) if receiver < 0 &&
      type_arguments.length > 0 => arguments
    _ => return false
  }
  if selector.parameter < 0 ||
    selector.parameter >= arguments.length ||
    arguments.start < 0 ||
    arguments.start + selector.parameter >= module_.expression_children.length() {
    return false
  }
  let trait_object_coercion = if selector.evidence_slot >= 0 {
    if expression >= module_.expression_evidence.length() {
      return false
    }
    let roots = module_.expression_evidence[expression]
    if selector.evidence_slot >= roots.length ||
      roots.start < 0 ||
      roots.start + selector.evidence_slot >=
      module_.trait_evidence_roots.length() {
      return false
    }
    SelectedInferredTraitObjectCoercion(
      selector.trait_declaration,
      module_.trait_evidence_roots[roots.start + selector.evidence_slot],
    )
  } else {
    NoInferredTraitObjectCoercion
  }
  let selected_expression = module_.expression_children[arguments.start +
    selector.parameter]
  if selected_expression < 0 ||
    selected_expression >= module_.expressions.length() {
    return false
  }
  let selected = module_.expressions[selected_expression]
  let source = module_.expressions[expression]
  module_.expressions[expression] = {
    ..source,
    type_: selected.type_,
    shape: selected.shape,
    trait_object_coercion,
    kind: PlannedParameterSelect(arguments, selector.parameter),
  }
  true
}

///|
fn directize_generic_parameter_selectors(
  modules : Array[PlannedModuleLowering],
) -> Unit {
  let selectors : Map[DeclId, GenericParameterSelector] = Map::default()
  let uses : Map[DeclId, Array[GenericParameterSelectorCallSite]] = Map::default()
  let pending : Array[DeclId] = []
  for module_index, module_ in modules {
    let roots : Map[ExprId, Int] = Map::default()
    for body_index, body in module_.bodies {
      let root = generic_parameter_selector_root_expression(module_, body)
      if root >= 0 && root < module_.expressions.length() {
        roots[root] = body_index
      }
      match generic_parameter_selector(module_, body) {
        Some(selected) => {
          selectors[body.declaration] = selected
          pending.push(body.declaration)
        }
        None => ()
      }
    }
    for expression in 0..<module_.expressions.length() {
      let declaration = match module_.expressions[expression].kind {
        PlannedDirectCall(declaration, receiver, _, type_arguments) if receiver <
          0 &&
          type_arguments.length > 0 => declaration
        _ => continue
      }
      let site = {
        module_index,
        expression,
        root_body: match roots.get(expression) {
          Some(value) => value
          None => -1
        },
      }
      match uses.get(declaration) {
        Some(sites) => sites.push(site)
        None => uses[declaration] = [site]
      }
    }
  }
  let mut next = 0
  while next < pending.length() {
    let declaration = pending[next]
    next += 1
    let selector = match selectors.get(declaration) {
      Some(value) => value
      None => continue
    }
    let sites = match uses.get(declaration) {
      Some(value) => value
      None => continue
    }
    for site in sites {
      if site.module_index < 0 || site.module_index >= modules.length() {
        continue
      }
      let module_ = modules[site.module_index]
      if !rewrite_generic_parameter_selector_call(
          module_,
          site.expression,
          selector,
        ) {
        continue
      }
      let body_index = site.root_body
      if body_index < 0 || body_index >= module_.bodies.length() {
        continue
      }
      let body = module_.bodies[body_index]
      if selectors.contains(body.declaration) {
        continue
      }
      match generic_parameter_selector(module_, body) {
        Some(selected) => {
          selectors[body.declaration] = selected
          pending.push(body.declaration)
        }
        None => ()
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
priv enum RuntimeTraitFlow {
  PendingRuntimeTraitFlow
  UnknownRuntimeTraitFlow
  ParameterRuntimeTraitFlow(Int)
  ExactRuntimeTraitFlow(
    DeclId,
    Int,
    String,
    BodyTypeId,
    PlannedValueShape,
    DeclId
  )
} derive(Eq)

///|
priv struct RuntimeTraitBodyAnalysis {
  expression_start : Int
  flows : Array[RuntimeTraitFlow]
  locals : Array[RuntimeTraitFlow]
  assignments : Array[Array[ExprId]]
}

///|
priv struct TransparentTraitCallSummary {
  requirement : DeclId
  parameter_count : Int
  root_expression : ExprId
}

///|
priv struct RuntimeTraitDirectCallCandidate {
  expression : ExprId
  receiver : ExprId
  method_arguments : HirSpan
  evidence : Int
  implementation_method : DeclId
}

///|
fn runtime_trait_block_result_expression(
  module_ : PlannedModuleLowering,
  block : BlockId,
) -> ExprId {
  if block < 0 || block >= module_.blocks.length() {
    return -1
  }
  let items = module_.blocks[block].items
  if items.length == 0 {
    return -1
  }
  match module_.block_items[items.start + items.length - 1].kind {
    PlannedExpressionItem(expression) | PlannedReturnItem(expression) =>
      expression
    _ => -1
  }
}

///|
fn runtime_trait_body_root_expression(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
) -> ExprId {
  match body.root {
    ExpressionBodyRoot(expression) => expression
    BlockBodyRoot(block) =>
      runtime_trait_block_result_expression(module_, block)
  }
}

///|
fn runtime_trait_expression_nominal(
  module_ : PlannedModuleLowering,
  root : BodyTypeId,
) -> DeclId {
  let mut body_type = root
  let mut remaining = module_.types.length() +
    module_.resolved_types.length() +
    1
  while remaining > 0 {
    remaining -= 1
    if body_type < -1 {
      let mut resolved_type = -body_type - 2
      while remaining > 0 {
        remaining -= 1
        if resolved_type < 0 || resolved_type >= module_.resolved_types.length() {
          return 0UL
        }
        match module_.resolved_types[resolved_type] {
          NominalType(declaration) => return declaration
          AppliedType(base, _) => resolved_type = base
          _ => return 0UL
        }
      }
      return 0UL
    }
    if body_type < 0 || body_type >= module_.types.length() {
      return 0UL
    }
    match module_.types[body_type] {
      BodyAppliedType(base, _) => body_type = base
      BodyResolvedType(resolved_type) => body_type = -resolved_type - 2
      _ => return 0UL
    }
  }
  0UL
}

///|
fn runtime_trait_flow_join(
  left : RuntimeTraitFlow,
  right : RuntimeTraitFlow,
) -> RuntimeTraitFlow {
  match (left, right) {
    (UnknownRuntimeTraitFlow, _) | (_, UnknownRuntimeTraitFlow) =>
      UnknownRuntimeTraitFlow
    (PendingRuntimeTraitFlow, _) | (_, PendingRuntimeTraitFlow) =>
      PendingRuntimeTraitFlow
    (ParameterRuntimeTraitFlow(left), ParameterRuntimeTraitFlow(right)) =>
      if left == right {
        ParameterRuntimeTraitFlow(left)
      } else {
        UnknownRuntimeTraitFlow
      }
    (
      ExactRuntimeTraitFlow(
        left_trait,
        left_evidence,
        left_key,
        left_type,
        left_shape,
        left_nominal
      ),
      ExactRuntimeTraitFlow(
        right_trait,
        _,
        right_key,
        _,
        right_shape,
        right_nominal
      ),
    ) =>
      if left_trait == right_trait &&
        left_key == right_key &&
        left_shape == right_shape &&
        left_nominal == right_nominal {
        ExactRuntimeTraitFlow(
          left_trait, left_evidence, left_key, left_type, left_shape, left_nominal,
        )
      } else {
        UnknownRuntimeTraitFlow
      }
    _ => UnknownRuntimeTraitFlow
  }
}

///|
fn RuntimeTraitBodyAnalysis::expression_flow(
  self : RuntimeTraitBodyAnalysis,
  expression : ExprId,
) -> RuntimeTraitFlow {
  let index = expression - self.expression_start
  if index < 0 || index >= self.flows.length() {
    UnknownRuntimeTraitFlow
  } else {
    self.flows[index]
  }
}

///|
fn runtime_trait_block_flow(
  module_ : PlannedModuleLowering,
  analysis : RuntimeTraitBodyAnalysis,
  block : BlockId,
) -> RuntimeTraitFlow {
  let expression = runtime_trait_block_result_expression(module_, block)
  if expression < 0 {
    UnknownRuntimeTraitFlow
  } else {
    analysis.expression_flow(expression)
  }
}

///|
fn runtime_trait_derived_expression_flow(
  module_ : PlannedModuleLowering,
  analysis : RuntimeTraitBodyAnalysis,
  expression : ExprId,
) -> RuntimeTraitFlow {
  match module_.expressions[expression].kind {
    PlannedLocalGet(local_id) =>
      if local_id >= 0 && local_id < analysis.locals.length() {
        analysis.locals[local_id]
      } else {
        UnknownRuntimeTraitFlow
      }
    PlannedBlockExpression(block) =>
      runtime_trait_block_flow(module_, analysis, block)
    PlannedIfExpression(_, then_block, alternative) =>
      runtime_trait_flow_join(
        runtime_trait_block_flow(module_, analysis, then_block),
        analysis.expression_flow(alternative),
      )
    PlannedMatchExpression(_, arms) => {
      if arms.length == 0 {
        return UnknownRuntimeTraitFlow
      }
      let mut joined = PendingRuntimeTraitFlow
      let mut first = true
      for index in 0..<arms.length {
        let arm = module_.pattern_arms[arms.start + index]
        let flow = analysis.expression_flow(arm.body)
        if first {
          joined = flow
          first = false
        } else {
          joined = runtime_trait_flow_join(joined, flow)
        }
      }
      joined
    }
    PlannedParameterSelect(arguments, selected) =>
      if selected >= 0 && selected < arguments.length {
        analysis.expression_flow(
          module_.expression_children[arguments.start + selected],
        )
      } else {
        UnknownRuntimeTraitFlow
      }
    _ => UnknownRuntimeTraitFlow
  }
}

///|
fn analyze_runtime_trait_body_flows(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
) -> RuntimeTraitBodyAnalysis {
  let flows = Array::make(body.expressions.length, PendingRuntimeTraitFlow)
  let assignments : Array[Array[ExprId]] = []
  for _ in 0..<body.locals.length {
    assignments.push([])
  }
  for
    block_index in body.blocks.start..<(body.blocks.start + body.blocks.length) {
    let items = module_.blocks[block_index].items
    for item_index in items.start..<(items.start + items.length) {
      match module_.block_items[item_index].kind {
        PlannedLetItem(local_id, _, initializer) if local_id >= 0 &&
          local_id < assignments.length() =>
          assignments[local_id].push(initializer)
        _ => ()
      }
    }
  }
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match module_.expressions[expression].kind {
      PlannedLocalSet(local_id, value) if local_id >= 0 &&
        local_id < assignments.length() => assignments[local_id].push(value)
      _ => ()
    }
  }
  let locals = Array::make(body.locals.length, PendingRuntimeTraitFlow)
  let mut parameter_index = 0
  for local_id in 0..<body.locals.length {
    match module_.locals[body.locals.start + local_id].kind {
      ParameterLocal => {
        locals[local_id] = ParameterRuntimeTraitFlow(parameter_index)
        parameter_index += 1
      }
      _ =>
        if assignments[local_id].length() == 0 {
          locals[local_id] = UnknownRuntimeTraitFlow
        }
    }
  }
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    let local_index = expression - body.expressions.start
    flows[local_index] = match
      module_.expressions[expression].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(trait_, evidence) =>
        if evidence >= 0 && evidence < module_.trait_evidence.length() {
          ExactRuntimeTraitFlow(
            trait_,
            evidence,
            wasmgc_trait_evidence_key(module_, evidence),
            module_.expressions[expression].type_,
            module_.expressions[expression].shape,
            runtime_trait_expression_nominal(
              module_,
              module_.expressions[expression].type_,
            ),
          )
        } else {
          UnknownRuntimeTraitFlow
        }
      ErrorInferredTraitObjectCoercion => UnknownRuntimeTraitFlow
      NoInferredTraitObjectCoercion =>
        match module_.expressions[expression].kind {
          PlannedLocalGet(_)
          | PlannedBlockExpression(_)
          | PlannedIfExpression(_, _, _)
          | PlannedMatchExpression(_, _)
          | PlannedParameterSelect(_, _) => PendingRuntimeTraitFlow
          _ => UnknownRuntimeTraitFlow
        }
    }
  }
  let analysis : RuntimeTraitBodyAnalysis = {
    expression_start: body.expressions.start,
    flows,
    locals,
    assignments,
  }
  let max_passes = body.expressions.length + body.locals.length + 1
  for _ in 0..<max_passes {
    let mut changed = false
    for local_id in 0..<analysis.locals.length() {
      match module_.locals[body.locals.start + local_id].kind {
        ParameterLocal => continue
        _ => ()
      }
      let values = analysis.assignments[local_id]
      let mut flow = if values.length() == 0 {
        UnknownRuntimeTraitFlow
      } else {
        analysis.expression_flow(values[0])
      }
      for index in 1..<values.length() {
        flow = runtime_trait_flow_join(
          flow,
          analysis.expression_flow(values[index]),
        )
      }
      if flow != analysis.locals[local_id] {
        analysis.locals[local_id] = flow
        changed = true
      }
    }
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      match module_.expressions[expression].trait_object_coercion {
        SelectedInferredTraitObjectCoercion(_, _)
        | ErrorInferredTraitObjectCoercion => continue
        NoInferredTraitObjectCoercion => ()
      }
      let index = expression - body.expressions.start
      let flow = runtime_trait_derived_expression_flow(
        module_, analysis, expression,
      )
      if flow != analysis.flows[index] {
        analysis.flows[index] = flow
        changed = true
      }
    }
    if !changed {
      break
    }
  }
  for index, flow in analysis.flows {
    if flow == PendingRuntimeTraitFlow {
      analysis.flows[index] = UnknownRuntimeTraitFlow
    }
  }
  for index, flow in analysis.locals {
    if flow == PendingRuntimeTraitFlow {
      analysis.locals[index] = UnknownRuntimeTraitFlow
    }
  }
  analysis
}

///|
fn runtime_trait_body_analyses(
  modules : Array[PlannedModuleLowering],
) -> Map[BodyId, RuntimeTraitBodyAnalysis] {
  let analyses : Map[BodyId, RuntimeTraitBodyAnalysis] = Map::default()
  for module_ in modules {
    for body in module_.bodies {
      let mut relevant = false
      for
        local_index in body.locals.start..<(body.locals.start +
        body.locals.length) {
        if runtime_trait_type_is_trait(
            module_,
            module_.locals[local_index].type_,
          ) {
          relevant = true
          break
        }
      }
      for
        expression in body.expressions.start..<(body.expressions.start +
        body.expressions.length) {
        if module_.expressions[expression].trait_object_coercion !=
          NoInferredTraitObjectCoercion {
          relevant = true
          break
        }
        match module_.expressions[expression].kind {
          PlannedDynamicTraitCall(_, _, _, _, _, _) => {
            relevant = true
            break
          }
          _ => ()
        }
      }
      if relevant {
        analyses[body.body] = analyze_runtime_trait_body_flows(module_, body)
      }
    }
  }
  analyses
}

///|
fn runtime_trait_summary_body_is_transparent(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  root : ExprId,
) -> Bool {
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match module_.expressions[expression].kind {
      PlannedPoisonExpression
      | PlannedFunctionValueCall(_, _, _)
      | PlannedLambdaClosure(_, _)
      | PlannedDirectLambdaCall(_, _, _)
      | PlannedCaptureSet(_, _)
      | PlannedWhileExpression(_, _, _)
      | PlannedBreakExpression(_, _)
      | PlannedContinueExpression(_, _)
      | PlannedOperatorCall(_, _, _, _, _)
      | PlannedBoundOperatorCall(_, _, _, _, _, _)
      | PlannedIndexCall(_, _, _, _)
      | PlannedIndexSetCall(_, _, _, _, _)
      | PlannedFixedArraySet(_, _, _, _)
      | PlannedFixedArraySetUnchecked(_, _, _, _)
      | PlannedMapInsert(_, _, _, _, _, _, _)
      | PlannedMapSet(_, _, _, _, _, _, _)
      | PlannedMapRemove(_, _, _, _, _)
      | PlannedMapClear(_)
      | PlannedSetInsert(_, _, _, _, _)
      | PlannedSetRemove(_, _, _, _, _)
      | PlannedSetClear(_) => return false
      PlannedDirectCall(_, _, _, _)
      | PlannedBoundDirectCall(_, _, _, _, _)
      | PlannedDynamicTraitCall(_, _, _, _, _, _) =>
        if expression != root {
          return false
        }
      _ => ()
    }
  }
  true
}

///|
fn transparent_trait_call_summaries(
  modules : Array[PlannedModuleLowering],
  analyses : Map[BodyId, RuntimeTraitBodyAnalysis],
) -> Map[DeclId, TransparentTraitCallSummary] {
  let summaries : Map[DeclId, TransparentTraitCallSummary] = Map::default()
  let mut changed = true
  while changed {
    changed = false
    for module_ in modules {
      for callable in module_.functions.callables {
        if summaries.contains(callable.declaration) {
          continue
        }
        let body_id = match callable.kind {
          PlannedFunctionCallable(body) => body
          _ => continue
        }
        let analysis = match analyses.get(body_id) {
          Some(value) => value
          None => continue
        }
        let body_index = semantic_id_local(body_id)
        if body_index < 0 || body_index >= module_.bodies.length() {
          continue
        }
        let body = module_.bodies[body_index]
        let expression = runtime_trait_body_root_expression(module_, body)
        if expression < 0 {
          continue
        }
        if !runtime_trait_summary_body_is_transparent(module_, body, expression) {
          continue
        }
        let (requirement, parameter_count) = match
          module_.expressions[expression].kind {
          PlannedDynamicTraitCall(_, requirement, _, receiver, arguments, _) => {
            if callable.parameters.length != arguments.length + 1 ||
              analysis.expression_flow(receiver) != ParameterRuntimeTraitFlow(0) {
              continue
            }
            let mut forwarded = true
            for index in 0..<arguments.length {
              let argument = module_.expression_children[arguments.start + index]
              if analysis.expression_flow(argument) !=
                ParameterRuntimeTraitFlow(index + 1) {
                forwarded = false
                break
              }
            }
            if !forwarded {
              continue
            }
            (requirement, callable.parameters.length)
          }
          PlannedDirectCall(target, -1, arguments, _) => {
            let target_summary = match summaries.get(target) {
              Some(value) => value
              None => continue
            }
            if callable.parameters.length != arguments.length ||
              arguments.length != target_summary.parameter_count {
              continue
            }
            let mut forwarded = true
            for index in 0..<arguments.length {
              let argument = module_.expression_children[arguments.start + index]
              if analysis.expression_flow(argument) !=
                ParameterRuntimeTraitFlow(index) {
                forwarded = false
                break
              }
            }
            if !forwarded {
              continue
            }
            (target_summary.requirement, callable.parameters.length)
          }
          _ => continue
        }
        summaries[callable.declaration] = {
          requirement,
          parameter_count,
          root_expression: expression,
        }
        changed = true
      }
    }
  }
  summaries
}

///|
fn runtime_trait_evidence_is_concrete(
  module_ : PlannedModuleLowering,
  evidence : Int,
  depth : Int,
) -> Bool {
  if depth >= 64 || evidence < 0 || evidence >= module_.trait_evidence.length() {
    return false
  }
  match module_.trait_evidence[evidence].kind {
    BoundInferredTraitEvidence(_) => false
    ConcreteInferredTraitEvidence(_, arguments) => {
      for index in 0..<arguments.length {
        match module_.trait_evidence_arguments[arguments.start + index] {
          ShapeInferredTraitEvidenceArgument(_) => ()
          GenericInferredTraitEvidenceArgument(_) => return false
        }
      }
      let prerequisites = module_.trait_evidence[evidence].prerequisites
      for index in 0..<prerequisites.length {
        if !runtime_trait_evidence_is_concrete(
            module_,
            module_.trait_evidence_children[prerequisites.start + index],
            depth + 1,
          ) {
          return false
        }
      }
      true
    }
  }
}

///|
fn runtime_trait_implementation_method(
  modules : Array[PlannedModuleLowering],
  module_lookup : Map[ModuleId, Int],
  implementation : DeclId,
  requirement : DeclId,
) -> DeclId {
  let requirement_module = match
    module_lookup.get(semantic_id_module(requirement)) {
    Some(value) => value
    None => return 0UL
  }
  let requirement_callable = match
    modules[requirement_module].functions.callable_of(requirement) {
    Some(value) => value
    None => return 0UL
  }
  let implementation_module = match
    module_lookup.get(semantic_id_module(implementation)) {
    Some(value) => value
    None => return 0UL
  }
  for callable in modules[implementation_module].functions.callables {
    match callable.kind {
      PlannedImplMethodCallable(owner, _) if owner == implementation &&
        callable.name == requirement_callable.name =>
        return callable.declaration
      _ => ()
    }
  }
  0UL
}

///|
fn runtime_trait_owner_type_arguments(
  module_ : PlannedModuleLowering,
  root : BodyTypeId,
  expected : Int,
) -> Array[BodyTypeId]? {
  if expected == 0 {
    return Some([])
  }
  if root < -1 {
    let resolved_type = -root - 2
    if resolved_type < 0 || resolved_type >= module_.resolved_types.length() {
      return None
    }
    return match module_.resolved_types[resolved_type] {
      AppliedType(_, arguments) if arguments.length == expected => {
        let values : Array[BodyTypeId] = []
        for index in 0..<arguments.length {
          values.push(
            -module_.resolved_type_arguments[arguments.start + index] - 2,
          )
        }
        Some(values)
      }
      _ => None
    }
  }
  if root < 0 || root >= module_.types.length() {
    return None
  }
  match module_.types[root] {
    BodyAppliedType(_, arguments) if arguments.length == expected => {
      let values : Array[BodyTypeId] = []
      for index in 0..<arguments.length {
        values.push(module_.type_arguments[arguments.start + index])
      }
      Some(values)
    }
    BodyResolvedType(resolved_type) =>
      runtime_trait_owner_type_arguments(module_, -resolved_type - 2, expected)
    _ => None
  }
}

///|
fn runtime_trait_direct_call_candidate(
  modules : Array[PlannedModuleLowering],
  module_lookup : Map[ModuleId, Int],
  module_ : PlannedModuleLowering,
  analysis : RuntimeTraitBodyAnalysis,
  summaries : Map[DeclId, TransparentTraitCallSummary],
  expression : ExprId,
) -> RuntimeTraitDirectCallCandidate? {
  let (requirement, receiver, method_arguments) = match
    module_.expressions[expression].kind {
    PlannedDynamicTraitCall(_, requirement, _, receiver, arguments, _) =>
      (requirement, receiver, arguments)
    PlannedDirectCall(target, -1, arguments, _) => {
      let summary = match summaries.get(target) {
        Some(value) => value
        None => return None
      }
      if arguments.length != summary.parameter_count || arguments.length == 0 {
        return None
      }
      (
        summary.requirement,
        module_.expression_children[arguments.start],
        { start: arguments.start + 1, length: arguments.length - 1 },
      )
    }
    _ => return None
  }
  let (evidence, receiver_type) = match analysis.expression_flow(receiver) {
    ExactRuntimeTraitFlow(_, evidence, _, type_, _, _) => (evidence, type_)
    _ => return None
  }
  if !runtime_trait_evidence_is_concrete(module_, evidence, 0) {
    return None
  }
  let (implementation, owner_arguments) = match
    module_.trait_evidence[evidence].kind {
    ConcreteInferredTraitEvidence(implementation, arguments) =>
      (implementation, arguments)
    BoundInferredTraitEvidence(_) => return None
  }
  if runtime_trait_owner_type_arguments(
      module_,
      receiver_type,
      owner_arguments.length,
    )
    is None {
    return None
  }
  let implementation_method = runtime_trait_implementation_method(
    modules, module_lookup, implementation, requirement,
  )
  if implementation_method == 0UL {
    return None
  }
  Some({
    expression,
    receiver,
    method_arguments,
    evidence,
    implementation_method,
  })
}

///|
fn runtime_trait_mark_flow_demand(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  analysis : RuntimeTraitBodyAnalysis,
  candidates : Array[RuntimeTraitDirectCallCandidate],
  active : Array[Bool],
  demanded_expressions : Array[Bool],
  demanded_locals : Array[Bool],
) -> Unit {
  for index in 0..<demanded_expressions.length() {
    demanded_expressions[index] = false
  }
  for index in 0..<demanded_locals.length() {
    demanded_locals[index] = false
  }
  let pending : Array[ExprId] = []
  for index, candidate in candidates {
    if active[index] {
      pending.push(candidate.receiver)
    }
  }
  while pending.length() > 0 {
    let expression = pending.pop().unwrap()
    let local_index = expression - body.expressions.start
    if local_index < 0 ||
      local_index >= demanded_expressions.length() ||
      demanded_expressions[local_index] {
      continue
    }
    demanded_expressions[local_index] = true
    match module_.expressions[expression].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(_, _) => continue
      _ => ()
    }
    match module_.expressions[expression].kind {
      PlannedLocalGet(local_id) if local_id >= 0 &&
        local_id < demanded_locals.length() => {
        demanded_locals[local_id] = true
        for assignment in analysis.assignments[local_id] {
          pending.push(assignment)
        }
      }
      PlannedBlockExpression(block) => {
        let result = runtime_trait_block_result_expression(module_, block)
        if result >= 0 {
          pending.push(result)
        }
      }
      PlannedIfExpression(_, then_block, alternative) => {
        let result = runtime_trait_block_result_expression(module_, then_block)
        if result >= 0 {
          pending.push(result)
        }
        pending.push(alternative)
      }
      PlannedMatchExpression(_, arms) =>
        for index in 0..<arms.length {
          pending.push(module_.pattern_arms[arms.start + index].body)
        }
      PlannedParameterSelect(arguments, selected) if selected >= 0 &&
        selected < arguments.length =>
        pending.push(module_.expression_children[arguments.start + selected])
      _ => ()
    }
  }
}

///|
fn runtime_trait_local_is_captured(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  local_id : LocalId,
) -> Bool {
  for capture in module_.captures {
    match capture.source {
      BodyLocalCapture(owner, captured) if owner == body.body &&
        captured == local_id => return true
      _ => ()
    }
  }
  false
}

///|
fn runtime_trait_safe_locals(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  analysis : RuntimeTraitBodyAnalysis,
  demanded_expressions : Array[Bool],
  demanded_locals : Array[Bool],
) -> Array[Bool] {
  let total_gets = Array::make(body.locals.length, 0)
  let demanded_gets = Array::make(body.locals.length, 0)
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match module_.expressions[expression].kind {
      PlannedLocalGet(local_id) if local_id >= 0 &&
        local_id < body.locals.length => {
        total_gets[local_id] += 1
        if demanded_expressions[expression - body.expressions.start] {
          demanded_gets[local_id] += 1
        }
      }
      _ => ()
    }
  }
  let safe = Array::make(body.locals.length, false)
  for local_id in 0..<body.locals.length {
    if demanded_locals[local_id] &&
      total_gets[local_id] == demanded_gets[local_id] &&
      total_gets[local_id] > 0 &&
      !runtime_trait_local_is_captured(module_, body, local_id) {
      match analysis.locals[local_id] {
        ExactRuntimeTraitFlow(_, _, _, _, _, _) => safe[local_id] = true
        _ => ()
      }
    }
  }
  safe
}

///|
fn runtime_trait_flow_path_is_safe(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  expression : ExprId,
  safe_locals : Array[Bool],
) -> Bool {
  let pending : Array[ExprId] = [expression]
  let visited = Array::make(body.expressions.length, false)
  while pending.length() > 0 {
    let current = pending.pop().unwrap()
    let index = current - body.expressions.start
    if index < 0 || index >= visited.length() {
      return false
    }
    if visited[index] {
      continue
    }
    visited[index] = true
    match module_.expressions[current].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(_, _) => continue
      _ => ()
    }
    match module_.expressions[current].kind {
      PlannedLocalGet(local_id) =>
        if local_id < 0 ||
          local_id >= safe_locals.length() ||
          !safe_locals[local_id] {
          return false
        }
      PlannedBlockExpression(block) => {
        let result = runtime_trait_block_result_expression(module_, block)
        if result < 0 {
          return false
        }
        pending.push(result)
      }
      PlannedIfExpression(_, then_block, alternative) => {
        let result = runtime_trait_block_result_expression(module_, then_block)
        if result < 0 {
          return false
        }
        pending.push(result)
        pending.push(alternative)
      }
      PlannedMatchExpression(_, arms) => {
        if arms.length == 0 {
          return false
        }
        for arm_index in 0..<arms.length {
          pending.push(module_.pattern_arms[arms.start + arm_index].body)
        }
      }
      PlannedParameterSelect(arguments, selected) => {
        if selected < 0 || selected >= arguments.length {
          return false
        }
        pending.push(module_.expression_children[arguments.start + selected])
      }
      _ => return false
    }
  }
  true
}

///|
fn runtime_trait_rewrite_flow_expression(
  module_ : PlannedModuleLowering,
  analysis : RuntimeTraitBodyAnalysis,
  expression : ExprId,
) -> Unit {
  match analysis.expression_flow(expression) {
    ExactRuntimeTraitFlow(_, _, _, type_, shape, _) => {
      let source = module_.expressions[expression]
      module_.expressions[expression] = {
        ..source,
        type_,
        shape,
        trait_object_coercion: NoInferredTraitObjectCoercion,
      }
    }
    _ => ()
  }
}

///|
fn runtime_trait_directize_candidate(
  module_ : PlannedModuleLowering,
  analysis : RuntimeTraitBodyAnalysis,
  candidate : RuntimeTraitDirectCallCandidate,
) -> Unit {
  let receiver_type = match analysis.expression_flow(candidate.receiver) {
    ExactRuntimeTraitFlow(_, _, _, type_, _, _) => type_
    _ => return
  }
  let owner_arguments = match module_.trait_evidence[candidate.evidence].kind {
    ConcreteInferredTraitEvidence(_, arguments) => arguments
    BoundInferredTraitEvidence(_) => return
  }
  let concrete_type_arguments = match
    runtime_trait_owner_type_arguments(
      module_,
      receiver_type,
      owner_arguments.length,
    ) {
    Some(value) => value
    None => return
  }
  let type_argument_start = module_.call_type_arguments.length()
  for index in 0..<owner_arguments.length {
    match module_.trait_evidence_arguments[owner_arguments.start + index] {
      ShapeInferredTraitEvidenceArgument(shape) => {
        module_.call_type_arguments.push(concrete_type_arguments[index])
        module_.call_type_argument_shapes.push(shape)
      }
      GenericInferredTraitEvidenceArgument(_) => return
    }
  }
  while module_.expression_evidence.length() < module_.expressions.length() {
    module_.expression_evidence.push({ start: 0, length: 0 })
  }
  let evidence_start = module_.trait_evidence_roots.length()
  let prerequisites = module_.trait_evidence[candidate.evidence].prerequisites
  for index in 0..<prerequisites.length {
    module_.trait_evidence_roots.push(
      module_.trait_evidence_children[prerequisites.start + index],
    )
  }
  module_.expression_evidence[candidate.expression] = {
    start: evidence_start,
    length: prerequisites.length,
  }
  let source = module_.expressions[candidate.expression]
  module_.expressions[candidate.expression] = {
    ..source,
    kind: PlannedDirectCall(
      candidate.implementation_method,
      candidate.receiver,
      candidate.method_arguments,
      { start: type_argument_start, length: owner_arguments.length },
    ),
  }
}

///|
fn directize_exact_runtime_trait_body(
  modules : Array[PlannedModuleLowering],
  module_lookup : Map[ModuleId, Int],
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  analysis : RuntimeTraitBodyAnalysis,
  summaries : Map[DeclId, TransparentTraitCallSummary],
) -> Unit {
  let candidates : Array[RuntimeTraitDirectCallCandidate] = []
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match
      runtime_trait_direct_call_candidate(
        modules, module_lookup, module_, analysis, summaries, expression,
      ) {
      Some(candidate) => candidates.push(candidate)
      None => ()
    }
  }
  if candidates.length() == 0 {
    return
  }
  let active = Array::make(candidates.length(), true)
  let demanded_expressions = Array::make(body.expressions.length, false)
  let demanded_locals = Array::make(body.locals.length, false)
  let mut changed = true
  while changed {
    changed = false
    runtime_trait_mark_flow_demand(
      module_, body, analysis, candidates, active, demanded_expressions, demanded_locals,
    )
    let safe_locals = runtime_trait_safe_locals(
      module_, body, analysis, demanded_expressions, demanded_locals,
    )
    for index, candidate in candidates {
      if active[index] &&
        !runtime_trait_flow_path_is_safe(
          module_,
          body,
          candidate.receiver,
          safe_locals,
        ) {
        active[index] = false
        changed = true
      }
    }
  }
  runtime_trait_mark_flow_demand(
    module_, body, analysis, candidates, active, demanded_expressions, demanded_locals,
  )
  let safe_locals = runtime_trait_safe_locals(
    module_, body, analysis, demanded_expressions, demanded_locals,
  )
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if demanded_expressions[expression - body.expressions.start] {
      runtime_trait_rewrite_flow_expression(module_, analysis, expression)
    }
  }
  for local_id in 0..<body.locals.length {
    if !safe_locals[local_id] {
      continue
    }
    match analysis.locals[local_id] {
      ExactRuntimeTraitFlow(_, _, _, type_, shape, nominal) => {
        let index = body.locals.start + local_id
        let source = module_.locals[index]
        module_.locals[index] = { ..source, type_, shape, nominal }
      }
      _ => ()
    }
  }
  for index, candidate in candidates {
    if active[index] {
      runtime_trait_directize_candidate(module_, analysis, candidate)
    }
  }
}

///|
fn runtime_trait_type_is_trait(
  module_ : PlannedModuleLowering,
  root : BodyTypeId,
) -> Bool {
  let mut body_type = root
  let mut remaining = module_.types.length() +
    module_.resolved_types.length() +
    1
  while remaining > 0 {
    remaining -= 1
    if body_type < -1 {
      let resolved_type = -body_type - 2
      if resolved_type < 0 || resolved_type >= module_.resolved_types.length() {
        return false
      }
      return match module_.resolved_types[resolved_type] {
        TraitType(_) => true
        AppliedType(base, _) => {
          body_type = -base - 2
          continue
        }
        _ => false
      }
    }
    if body_type < 0 || body_type >= module_.types.length() {
      return false
    }
    match module_.types[body_type] {
      BodyAppliedType(base, _) => body_type = base
      BodyResolvedType(resolved_type) => body_type = -resolved_type - 2
      _ => return false
    }
  }
  false
}

///|
fn trait_parameter_selector(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
) -> Int {
  let root_expression = transparent_callback_root_expression(module_, body)
  if root_expression < 0 {
    return -1
  }
  let local_id = match module_.expressions[root_expression].kind {
    PlannedLocalGet(value) => value
    _ => return -1
  }
  if local_id < 0 ||
    local_id >= body.locals.length ||
    !runtime_trait_type_is_trait(
      module_,
      module_.locals[body.locals.start + local_id].type_,
    ) {
    return -1
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
fn directize_trait_parameter_selectors(
  modules : Array[PlannedModuleLowering],
) -> Array[DeclId] {
  let selectors : Map[DeclId, Int] = Map::default()
  for module_ in modules {
    for body in module_.bodies {
      let selected = trait_parameter_selector(module_, body)
      if selected >= 0 {
        selectors[body.declaration] = selected
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
  let declarations : Array[DeclId] = []
  for declaration, _ in selectors {
    declarations.push(declaration)
  }
  declarations
}

///|
fn runtime_trait_callable_is_referenced(
  modules : Array[PlannedModuleLowering],
  ignored_callers : Map[DeclId, Bool],
  declaration : DeclId,
) -> Bool {
  for module_ in modules {
    for body in module_.bodies {
      if ignored_callers.contains(body.declaration) {
        continue
      }
      for
        expression_index in body.expressions.start..<(body.expressions.start +
        body.expressions.length) {
        match module_.expressions[expression_index].kind {
          PlannedDirectCall(target, _, _, _)
          | PlannedFunctionReference(target, _) if target == declaration =>
            return true
          _ => ()
        }
      }
    }
    for lambda in module_.lambdas {
      for
        expression_index in lambda.expressions.start..<(lambda.expressions.start +
        lambda.expressions.length) {
        match module_.expressions[expression_index].kind {
          PlannedDirectCall(target, _, _, _)
          | PlannedFunctionReference(target, _) if target == declaration =>
            return true
          _ => ()
        }
      }
    }
  }
  false
}

///|
fn runtime_trait_elidable_wrappers(
  modules : Array[PlannedModuleLowering],
  summaries : Map[DeclId, TransparentTraitCallSummary],
  selectors : Array[DeclId],
) -> Array[DeclId] {
  let candidates : Map[DeclId, ExprId] = Map::default()
  for declaration, summary in summaries {
    candidates[declaration] = summary.root_expression
  }
  for declaration in selectors {
    let owner = semantic_id_module(declaration)
    for module_ in modules {
      if module_.module_id != owner {
        continue
      }
      match module_.functions.callable_of(declaration) {
        Some({ kind: PlannedFunctionCallable(body), .. }) => {
          let body_index = semantic_id_local(body)
          if body_index >= 0 && body_index < module_.bodies.length() {
            candidates[declaration] = runtime_trait_body_root_expression(
              module_,
              module_.bodies[body_index],
            )
          }
        }
        _ => ()
      }
    }
  }
  let ignored_callers : Map[DeclId, Bool] = Map::default()
  for declaration, _ in candidates {
    let owner = semantic_id_module(declaration)
    for module_ in modules {
      if module_.module_id != owner {
        continue
      }
      match module_.functions.callable_of(declaration) {
        Some(callable) if callable.visibility != Public &&
          !callable.is_test_entry => ignored_callers[declaration] = true
        _ => ()
      }
    }
  }
  let elided : Array[DeclId] = []
  for declaration, root in candidates {
    let owner = semantic_id_module(declaration)
    let mut selected_module = -1
    for module_index, module_ in modules {
      if module_.module_id == owner {
        selected_module = module_index
        break
      }
    }
    if selected_module < 0 ||
      runtime_trait_callable_is_referenced(
        modules, ignored_callers, declaration,
      ) {
      continue
    }
    let module_ = modules[selected_module]
    let callable = match module_.functions.callable_of(declaration) {
      Some(value) => value
      None => continue
    }
    if callable.visibility == Public || callable.is_test_entry || root < 0 {
      continue
    }
    let source = module_.expressions[root]
    module_.expressions[root] = { ..source, kind: PlannedConsumedExpression }
    elided.push(declaration)
  }
  elided
}

///|
fn prepare_program_runtime_trait_mutation(
  modules : Array[PlannedModuleLowering],
) -> Unit {
  for module_index, module_ in modules {
    let evidence = Array::make(module_.expressions.length(), {
      start: 0,
      length: 0,
    })
    for index in 0..<module_.expression_evidence.length() {
      if index >= evidence.length() {
        break
      }
      evidence[index] = module_.expression_evidence[index]
    }
    modules[module_index] = {
      ..module_,
      call_type_arguments: module_.call_type_arguments.copy(),
      call_type_argument_shapes: module_.call_type_argument_shapes.copy(),
      expression_evidence: evidence,
      trait_evidence_roots: module_.trait_evidence_roots.copy(),
    }
  }
}

///|
fn directize_exact_runtime_trait_flows(
  modules : Array[PlannedModuleLowering],
) -> Array[DeclId] {
  prepare_program_runtime_trait_mutation(modules)
  let selectors = directize_trait_parameter_selectors(modules)
  let analyses = runtime_trait_body_analyses(modules)
  let summaries = transparent_trait_call_summaries(modules, analyses)
  let module_lookup : Map[ModuleId, Int] = Map::default()
  for module_index, module_ in modules {
    module_lookup[module_.module_id] = module_index
  }
  for module_ in modules {
    for body in module_.bodies {
      match analyses.get(body.body) {
        Some(analysis) =>
          directize_exact_runtime_trait_body(
            modules, module_lookup, module_, body, analysis, summaries,
          )
        None => ()
      }
    }
  }
  runtime_trait_elidable_wrappers(modules, summaries, selectors)
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
  let elided_trait_wrappers = directize_exact_runtime_trait_flows(modules)
  { graph: analyzed.frozen.graph, modules, elided_trait_wrappers }
}

///|
fn program_link_validate_calls(
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  functions : Array[PlannedProgramWasmFunction],
  lookup : Map[DeclId, Int],
  specialized_calls : Array[PlannedProgramSpecializedCall],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> Unit {
  for module_ in lowering.modules {
    for expression_index, expression in module_.expressions {
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
          if program_callable_generic_parameters(callable).length > 0 {
            let mut specialized = false
            for call in specialized_calls {
              if semantic_id_module(call.caller_body) == module_.module_id &&
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
                  module_.call_type_argument_shapes,
                  type_arguments,
                ) {
                specialized = true
                break
              }
            }
            if !specialized {
              let mut symbolic_source = false
              for index in 0..<type_arguments.length {
                match
                  module_.call_type_argument_shapes[type_arguments.start + index] {
                  GenericPlannedValueShape | ErrorPlannedValueShape =>
                    symbolic_source = true
                  _ => ()
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
      let elided_trait_wrapper = lowering.elided_trait_wrappers.contains(
        callable.declaration,
      )
      if (callable.visibility == Public || !callable.compiler_owned) &&
        !elided_trait_wrapper &&
        (!callable.is_test || emit_tests) {
        reachable[callable.declaration] = true
        work.push(callable.declaration)
      }
    }
  }
  for module_ in lowering.modules {
    for evidence in module_.trait_evidence {
      let implementation = match evidence.kind {
        ConcreteInferredTraitEvidence(implementation, _) => implementation
        BoundInferredTraitEvidence(_) => continue
      }
      let owner_index = match
        module_lookup.get(semantic_id_module(implementation)) {
        Some(value) => value
        None => continue
      }
      for callable in lowering.modules[owner_index].functions.callables {
        match callable.kind {
          PlannedImplMethodCallable(owner, _) if owner == implementation =>
            if !reachable.contains(callable.declaration) {
              reachable[callable.declaration] = true
              work.push(callable.declaration)
            }
          _ => ()
        }
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
            } else if wasmgc_builtin_is_debug_runtime(name) {
              runtime_changed = program_add_named_callable_root(
                  lowering, b"wasi_snapshot_preview1.fd_write", reachable,
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
priv struct ProgramTraitEvidenceRequest {
  roots : Array[Int]
  evidence : Array[PlannedSpecializationTraitEvidence]
  children : Array[Int]
  arguments : Array[PlannedValueShape]
}

///|
fn empty_program_trait_evidence_request() -> ProgramTraitEvidenceRequest {
  { roots: [], evidence: [], children: [], arguments: [] }
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
fn write_program_trait_evidence_key(
  output : Buffer,
  request : ProgramTraitEvidenceRequest,
  node : Int,
) -> Unit {
  guard node >= 0 && node < request.evidence.length() else {
    output.write_string_utf8("invalid")
    return
  }
  let evidence = request.evidence[node]
  match evidence.kind {
    PlannedConcreteTraitEvidence(implementation, arguments) => {
      output.write_string_utf8(implementation.to_string())
      output.write_string_utf8("<")
      for index in 0..<arguments.length {
        if index > 0 {
          output.write_string_utf8(",")
        }
        output.write_string_utf8(
          program_specialization_shape_name(
            request.arguments[arguments.start + index],
          ),
        )
      }
      output.write_string_utf8(">")
    }
  }
  output.write_string_utf8("[")
  for index in 0..<evidence.prerequisites.length {
    if index > 0 {
      output.write_string_utf8(",")
    }
    write_program_trait_evidence_key(
      output,
      request,
      request.children[evidence.prerequisites.start + index],
    )
  }
  output.write_string_utf8("]")
}

///|
fn program_specialization_abi_key(
  declaration : DeclId,
  shapes : Array[PlannedValueShape],
  span : HirSpan,
  evidence : ProgramTraitEvidenceRequest,
) -> String {
  let output = Buffer(
    size_hint=32 + span.length * 8 + evidence.evidence.length() * 24,
  )
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
  if evidence.roots.length() > 0 {
    output.write_string_utf8("|e=")
    for index, root in evidence.roots {
      if index > 0 {
        output.write_string_utf8(";")
      }
      write_program_trait_evidence_key(output, evidence, root)
    }
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
fn copy_program_specialization_evidence_node(
  source : PlannedModuleWasmGCFragments,
  source_node : Int,
  request : ProgramTraitEvidenceRequest,
) -> Int {
  guard source_node >= 0 &&
    source_node < source.specialization_trait_evidence.length() else {
    return -1
  }
  let source_evidence = source.specialization_trait_evidence[source_node]
  let kind = match source_evidence.kind {
    PlannedConcreteTraitEvidence(implementation, arguments) => {
      let argument_start = request.arguments.length()
      for index in 0..<arguments.length {
        request.arguments.push(
          source.specialization_evidence_arguments[arguments.start + index],
        )
      }
      PlannedConcreteTraitEvidence(implementation, {
        start: argument_start,
        length: arguments.length,
      })
    }
  }
  let child_start = request.children.length()
  for index in 0..<source_evidence.prerequisites.length {
    let child = copy_program_specialization_evidence_node(
      source,
      source.specialization_evidence_children[source_evidence.prerequisites.start +
      index],
      request,
    )
    if child < 0 {
      return -1
    }
    request.children.push(child)
  }
  let node = request.evidence.length()
  request.evidence.push({
    kind,
    prerequisites: {
      start: child_start,
      length: source_evidence.prerequisites.length,
    },
  })
  node
}

///|
fn resolve_program_lowering_evidence_node_with_specialization(
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  specialization_shapes : HirSpan,
  specialization_evidence : HirSpan,
  has_specialization : Bool,
  source_node : Int,
  request : ProgramTraitEvidenceRequest,
) -> Int {
  guard source_node >= 0 && source_node < lowering.trait_evidence.length() else {
    return -1
  }
  let source = lowering.trait_evidence[source_node]
  match source.kind {
    BoundInferredTraitEvidence(slot) => {
      if !has_specialization ||
        slot < 0 ||
        slot >= specialization_evidence.length {
        return -1
      }
      copy_program_specialization_evidence_node(
        fragments,
        fragments.specialization_evidence_roots[specialization_evidence.start +
        slot],
        request,
      )
    }
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      let argument_start = request.arguments.length()
      for index in 0..<arguments.length {
        match lowering.trait_evidence_arguments[arguments.start + index] {
          ShapeInferredTraitEvidenceArgument(shape) =>
            request.arguments.push(
              program_canonical_specialization_shape(shape),
            )
          GenericInferredTraitEvidenceArgument(parameter) => {
            if !has_specialization ||
              parameter < 0 ||
              parameter >= specialization_shapes.length {
              return -1
            }
            request.arguments.push(
              program_canonical_specialization_shape(
                fragments.specialization_shapes[specialization_shapes.start +
                parameter],
              ),
            )
          }
        }
      }
      let child_start = request.children.length()
      for index in 0..<source.prerequisites.length {
        let child = resolve_program_lowering_evidence_node_with_specialization(
          lowering,
          fragments,
          specialization_shapes,
          specialization_evidence,
          has_specialization,
          lowering.trait_evidence_children[source.prerequisites.start + index],
          request,
        )
        if child < 0 {
          return -1
        }
        request.children.push(child)
      }
      let node = request.evidence.length()
      request.evidence.push({
        kind: PlannedConcreteTraitEvidence(implementation, {
          start: argument_start,
          length: arguments.length,
        }),
        prerequisites: {
          start: child_start,
          length: source.prerequisites.length,
        },
      })
      node
    }
  }
}

///|
fn resolve_program_lowering_evidence_node(
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  caller : PlannedWasmFunctionFragment?,
  source_node : Int,
  request : ProgramTraitEvidenceRequest,
) -> Int {
  match caller {
    Some(value) =>
      resolve_program_lowering_evidence_node_with_specialization(
        lowering,
        fragments,
        value.specialization_shapes,
        value.specialization_evidence,
        true,
        source_node,
        request,
      )
    None =>
      resolve_program_lowering_evidence_node_with_specialization(
        lowering,
        fragments,
        { start: 0, length: 0 },
        { start: 0, length: 0 },
        false,
        source_node,
        request,
      )
  }
}

///|
fn append_program_trait_evidence_request_key(
  request : ProgramTraitEvidenceRequest,
  node : Int,
  depth : Int,
  output : Buffer,
) -> Unit {
  if depth >= 64 || node < 0 || node >= request.evidence.length() {
    output.write_string_utf8("!")
    return
  }
  match request.evidence[node].kind {
    PlannedConcreteTraitEvidence(implementation, arguments) => {
      output.write_string_utf8("i")
      output.write_string_utf8(implementation.to_string())
      output.write_string_utf8("[")
      for index in 0..<arguments.length {
        if index > 0 {
          output.write_string_utf8(",")
        }
        output.write_string_utf8("s")
        output.write_string_utf8(
          wasmgc_trait_evidence_shape_code(
            request.arguments[arguments.start + index],
          ).to_string(),
        )
      }
      output.write_string_utf8("]{")
      let prerequisites = request.evidence[node].prerequisites
      for index in 0..<prerequisites.length {
        if index > 0 {
          output.write_string_utf8(",")
        }
        append_program_trait_evidence_request_key(
          request,
          request.children[prerequisites.start + index],
          depth + 1,
          output,
        )
      }
      output.write_string_utf8("}")
    }
  }
}

///|
fn program_trait_evidence_request_identity(
  request : ProgramTraitEvidenceRequest,
  root : Int,
) -> (DeclId, String)? {
  guard root >= 0 && root < request.evidence.length() else { return None }
  let implementation = match request.evidence[root].kind {
    PlannedConcreteTraitEvidence(value, _) => value
  }
  let output = Buffer()
  append_program_trait_evidence_request_key(request, root, 0, output)
  Some((implementation, @utf8.decode_lossy(output.to_bytes())))
}

///|
pub fn program_resolved_trait_evidence_identity(
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  specialization_shapes : HirSpan,
  specialization_evidence : HirSpan,
  source_node : Int,
) -> (DeclId, String)? {
  let request = empty_program_trait_evidence_request()
  let root = resolve_program_lowering_evidence_node_with_specialization(
    lowering, fragments, specialization_shapes, specialization_evidence, true, source_node,
    request,
  )
  program_trait_evidence_request_identity(request, root)
}

///|
fn resolve_program_expression_evidence(
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  caller : PlannedWasmFunctionFragment?,
  expression : ExprId,
) -> ProgramTraitEvidenceRequest? {
  let request = empty_program_trait_evidence_request()
  if expression < 0 || expression >= lowering.expression_evidence.length() {
    return Some(request)
  }
  let roots = lowering.expression_evidence[expression]
  for index in 0..<roots.length {
    let root = resolve_program_lowering_evidence_node(
      lowering,
      fragments,
      caller,
      lowering.trait_evidence_roots[roots.start + index],
      request,
    )
    if root < 0 {
      return None
    }
    request.roots.push(root)
  }
  Some(request)
}

///|
fn copy_program_evidence_prerequisites(
  fragments : PlannedModuleWasmGCFragments,
  root : Int,
) -> ProgramTraitEvidenceRequest? {
  guard root >= 0 && root < fragments.specialization_trait_evidence.length() else {
    return None
  }
  let request = empty_program_trait_evidence_request()
  let evidence = fragments.specialization_trait_evidence[root]
  for index in 0..<evidence.prerequisites.length {
    let child = copy_program_specialization_evidence_node(
      fragments,
      fragments.specialization_evidence_children[evidence.prerequisites.start +
      index],
      request,
    )
    if child < 0 {
      return None
    }
    request.roots.push(child)
  }
  Some(request)
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
  evidence : ProgramTraitEvidenceRequest,
  erased_fallback : Bool,
) -> String? {
  let owner_index = match module_lookup.get(semantic_id_module(declaration)) {
    Some(index) => index
    None => return None
  }
  let module_ = modules[owner_index]
  let specialization_abi_key = program_specialization_abi_key(
    declaration, request_shapes, request, evidence,
  )
  for function_index, function_ in module_.functions {
    if function_.declaration == declaration &&
      function_.specialization_shapes.length > 0 &&
      function_.specialization_abi_key == specialization_abi_key {
      if erased_fallback && function_.visibility != Public {
        module_.functions[function_index] = { ..function_, visibility: Public }
        modules[owner_index] = module_
      }
      return Some(specialization_abi_key)
    }
  }
  let base_index = module_.function_by_declaration[semantic_id_local(
      declaration,
    )]
  if base_index < 0 || base_index >= module_.functions.length() {
    return None
  }
  let base = module_.functions[base_index]
  match base.kind {
    PlannedWasmDefinedFunction(_) => ()
    _ => return None
  }
  let callable = match
    lowering.modules[owner_index].functions.callable_of(declaration) {
    Some(callable) => callable
    None => return None
  }
  if program_callable_generic_parameters(callable).length != request.length {
    return None
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
  let evidence_argument_start = module_.specialization_evidence_arguments.length()
  for argument in evidence.arguments {
    module_.specialization_evidence_arguments.push(
      program_canonical_specialization_shape(argument),
    )
  }
  let evidence_child_start = module_.specialization_evidence_children.length()
  let evidence_node_start = module_.specialization_trait_evidence.length()
  for child in evidence.children {
    module_.specialization_evidence_children.push(evidence_node_start + child)
  }
  for node in evidence.evidence {
    let kind = match node.kind {
      PlannedConcreteTraitEvidence(implementation, arguments) =>
        PlannedConcreteTraitEvidence(implementation, {
          start: evidence_argument_start + arguments.start,
          length: arguments.length,
        })
    }
    module_.specialization_trait_evidence.push({
      kind,
      prerequisites: {
        start: evidence_child_start + node.prerequisites.start,
        length: node.prerequisites.length,
      },
    })
  }
  let evidence_root_start = module_.specialization_evidence_roots.length()
  for root in evidence.roots {
    module_.specialization_evidence_roots.push(evidence_node_start + root)
  }
  let specialization_evidence = {
    start: evidence_root_start,
    length: evidence.roots.length(),
  }
  let resolved = analyzed.frozen.interfaces[owner_index].resolved_types
  let parameter_start = module_.function_value_types.length()
  let mut base_parameter_index = 0
  for index in 0..<callable.parameters.length {
    let parameter = lowering.modules[owner_index].functions.parameters[callable.parameters.start +
      index]
    let specialized = program_generic_parameter_shape(
      resolved,
      parameter.type_,
      program_callable_generic_parameters(callable),
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
    program_callable_generic_parameters(callable),
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
    visibility: if erased_fallback {
      Public
    } else {
      ModuleVisible
    },
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
    specialization_evidence,
    specialization_abi_key,
  })
  modules[owner_index] = {
    ..module_,
    signature_type_count: module_.signature_type_count + 1,
  }
  Some(specialization_abi_key)
}

///|
fn record_program_specialized_call(
  calls : Array[PlannedProgramSpecializedCall],
  call : PlannedProgramSpecializedCall,
) -> Unit {
  for existing in calls {
    if existing.caller_body == call.caller_body &&
      existing.caller_specialization_abi_key ==
      call.caller_specialization_abi_key &&
      existing.expression == call.expression {
      return
    }
  }
  calls.push(call)
}

///|
fn program_impl_method_for_requirement(
  lowering : PlannedProgramLowering,
  module_lookup : Map[ModuleId, Int],
  implementation : DeclId,
  requirement : DeclId,
) -> DeclId? {
  let requirement_module = match
    module_lookup.get(semantic_id_module(requirement)) {
    Some(index) => index
    None => return None
  }
  let requirement_callable = match
    lowering.modules[requirement_module].functions.callable_of(requirement) {
    Some(value) => value
    None => return None
  }
  let implementation_module = match
    module_lookup.get(semantic_id_module(implementation)) {
    Some(index) => index
    None => return None
  }
  for callable in lowering.modules[implementation_module].functions.callables {
    match callable.kind {
      PlannedImplMethodCallable(owner, _) if owner == implementation &&
        callable.name == requirement_callable.name =>
        return Some(callable.declaration)
      _ => ()
    }
  }
  None
}

///|
fn program_call_target_and_arguments(
  expression : PlannedExpression,
) -> (DeclId, HirSpan)? {
  match expression.kind {
    PlannedDirectCall(target, _, _, arguments)
    | PlannedOperatorCall(target, _, _, _, arguments)
    | PlannedIndexCall(target, _, _, arguments)
    | PlannedIndexSetCall(target, _, _, _, arguments) =>
      Some((target, arguments))
    _ => None
  }
}

///|
fn materialize_program_expression_call(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  module_lookup : Map[ModuleId, Int],
  caller_module_index : Int,
  caller : PlannedWasmFunctionFragment?,
  caller_callable : PlannedCallable?,
  body : BodyId,
  expression : ExprId,
  specialized_calls : Array[PlannedProgramSpecializedCall],
) -> Unit {
  let owner = lowering.modules[caller_module_index]
  let source = owner.expressions[expression]
  match program_call_target_and_arguments(source) {
    Some((target, arguments)) if arguments.length > 0 => {
      let request_evidence = match
        resolve_program_expression_evidence(
          owner,
          modules[caller_module_index],
          caller,
          expression,
        ) {
        Some(value) => value
        None => return
      }
      let request_shapes : Array[PlannedValueShape] = []
      for argument_index in 0..<arguments.length {
        let source_index = arguments.start + argument_index
        let shape = match (caller, caller_callable) {
          (Some(function_), Some(callable)) =>
            program_resolve_specialized_shape(
              owner,
              program_callable_generic_parameters(callable),
              modules[caller_module_index].specialization_shapes,
              function_.specialization_shapes,
              owner.call_type_arguments[source_index],
              owner.call_type_argument_shapes[source_index],
            )
          _ => owner.call_type_argument_shapes[source_index]
        }
        request_shapes.push(shape)
      }
      match
        materialize_program_generic_specialization(
          analyzed,
          lowering,
          modules,
          module_lookup,
          target,
          request_shapes,
          { start: 0, length: request_shapes.length() },
          request_evidence,
          false,
        ) {
        Some(target_key) =>
          record_program_specialized_call(specialized_calls, {
            caller_body: body,
            caller_specialization_abi_key: match caller {
              Some(value) => value.specialization_abi_key
              None => ""
            },
            expression,
            target,
            target_specialization_abi_key: target_key,
          })
        None => ()
      }
    }
    _ =>
      match source.kind {
        PlannedBoundDirectCall(requirement, slot, _, _, _)
        | PlannedBoundOperatorCall(requirement, slot, _, _, _, _) => {
          let caller = match caller {
            Some(value) => value
            None => return
          }
          if slot < 0 || slot >= caller.specialization_evidence.length {
            return
          }
          let fragments = modules[caller_module_index]
          let root = fragments.specialization_evidence_roots[caller.specialization_evidence.start +
            slot]
          if root < 0 ||
            root >= fragments.specialization_trait_evidence.length() {
            return
          }
          let root_evidence = fragments.specialization_trait_evidence[root]
          let (implementation, arguments) = match root_evidence.kind {
            PlannedConcreteTraitEvidence(implementation, arguments) =>
              (implementation, arguments)
          }
          let target = match
            program_impl_method_for_requirement(
              lowering, module_lookup, implementation, requirement,
            ) {
            Some(value) => value
            None => return
          }
          let request_evidence = match
            copy_program_evidence_prerequisites(fragments, root) {
            Some(value) => value
            None => return
          }
          let request_shapes : Array[PlannedValueShape] = []
          for index in 0..<arguments.length {
            request_shapes.push(
              fragments.specialization_evidence_arguments[arguments.start +
              index],
            )
          }
          let target_key = if arguments.length > 0 {
            match
              materialize_program_generic_specialization(
                analyzed,
                lowering,
                modules,
                module_lookup,
                target,
                request_shapes,
                { start: 0, length: request_shapes.length() },
                request_evidence,
                false,
              ) {
              Some(value) => value
              None => return
            }
          } else {
            ""
          }
          record_program_specialized_call(specialized_calls, {
            caller_body: body,
            caller_specialization_abi_key: caller.specialization_abi_key,
            expression,
            target,
            target_specialization_abi_key: target_key,
          })
        }
        _ => ()
      }
  }
}

///|
fn program_trait_dictionary_evidence_request(
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  root : Int,
) -> ProgramTraitEvidenceRequest? {
  guard root >= 0 && root < lowering.trait_evidence.length() else {
    return None
  }
  let request = empty_program_trait_evidence_request()
  let prerequisites = lowering.trait_evidence[root].prerequisites
  for index in 0..<prerequisites.length {
    let node = resolve_program_lowering_evidence_node(
      lowering,
      fragments,
      None,
      lowering.trait_evidence_children[prerequisites.start + index],
      request,
    )
    if node < 0 {
      return None
    }
    request.roots.push(node)
  }
  Some(request)
}

///|
fn materialize_program_trait_dictionary_methods(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  module_lookup : Map[ModuleId, Int],
) -> Unit {
  for module_index, module_ in modules {
    let owner = lowering.modules[module_index]
    for dictionary in module_.trait_dictionaries {
      if dictionary.evidence < 0 ||
        dictionary.evidence >= owner.trait_evidence.length() {
        continue
      }
      let arguments = match owner.trait_evidence[dictionary.evidence].kind {
        ConcreteInferredTraitEvidence(_, arguments) => arguments
        BoundInferredTraitEvidence(_) => continue
      }
      if arguments.length == 0 {
        continue
      }
      let shapes : Array[PlannedValueShape] = []
      let mut concrete = true
      for index in 0..<arguments.length {
        match owner.trait_evidence_arguments[arguments.start + index] {
          ShapeInferredTraitEvidenceArgument(shape) =>
            shapes.push(program_canonical_specialization_shape(shape))
          GenericInferredTraitEvidenceArgument(_) => {
            concrete = false
            break
          }
        }
      }
      if !concrete {
        continue
      }
      let evidence = match
        program_trait_dictionary_evidence_request(
          owner,
          module_,
          dictionary.evidence,
        ) {
        Some(value) => value
        None => continue
      }
      for index in 0..<dictionary.methods.length {
        let method_index = dictionary.methods.start + index
        let method_info = module_.trait_methods[method_index]
        let key = match
          materialize_program_generic_specialization(
            analyzed,
            lowering,
            modules,
            module_lookup,
            method_info.implementation_method,
            shapes,
            { start: 0, length: shapes.length() },
            evidence,
            false,
          ) {
          Some(value) => value
          None => continue
        }
        module_.trait_methods[method_index] = {
          ..method_info,
          implementation_specialization_abi_key: key,
        }
      }
    }
  }
}

///|
fn copy_program_trait_evidence_request_node(
  source : ProgramTraitEvidenceRequest,
  source_node : Int,
  target : ProgramTraitEvidenceRequest,
) -> Int {
  guard source_node >= 0 && source_node < source.evidence.length() else {
    return -1
  }
  let source_evidence = source.evidence[source_node]
  let kind = match source_evidence.kind {
    PlannedConcreteTraitEvidence(implementation, arguments) => {
      let argument_start = target.arguments.length()
      for index in 0..<arguments.length {
        target.arguments.push(source.arguments[arguments.start + index])
      }
      PlannedConcreteTraitEvidence(implementation, {
        start: argument_start,
        length: arguments.length,
      })
    }
  }
  let child_start = target.children.length()
  for index in 0..<source_evidence.prerequisites.length {
    let child = copy_program_trait_evidence_request_node(
      source,
      source.children[source_evidence.prerequisites.start + index],
      target,
    )
    if child < 0 {
      return -1
    }
    target.children.push(child)
  }
  let node = target.evidence.length()
  target.evidence.push({
    kind,
    prerequisites: {
      start: child_start,
      length: source_evidence.prerequisites.length,
    },
  })
  node
}

///|
fn program_trait_evidence_prerequisite_request(
  source : ProgramTraitEvidenceRequest,
  root : Int,
) -> ProgramTraitEvidenceRequest? {
  guard root >= 0 && root < source.evidence.length() else { return None }
  let target = empty_program_trait_evidence_request()
  let prerequisites = source.evidence[root].prerequisites
  for index in 0..<prerequisites.length {
    let child = copy_program_trait_evidence_request_node(
      source,
      source.children[prerequisites.start + index],
      target,
    )
    if child < 0 {
      return None
    }
    target.roots.push(child)
  }
  Some(target)
}

///|
fn materialize_program_specialization_trait_dictionaries(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  module_lookup : Map[ModuleId, Int],
  owner_index : Int,
  caller : PlannedWasmFunctionFragment,
  body : PlannedBodyLowering,
) -> Unit {
  let owner = lowering.modules[owner_index]
  let module_ = modules[owner_index]
  let mut added_defined_function_count = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    let (trait_declaration, source_evidence) = match
      owner.expressions[expression].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(trait_, evidence) =>
        (trait_, evidence)
      _ => continue
    }
    let evidence = empty_program_trait_evidence_request()
    let root = resolve_program_lowering_evidence_node_with_specialization(
      owner,
      module_,
      caller.specialization_shapes,
      caller.specialization_evidence,
      true,
      source_evidence,
      evidence,
    )
    let (implementation, evidence_key) = match
      program_trait_evidence_request_identity(evidence, root) {
      Some(value) => value
      None => continue
    }
    let mut present = false
    for dictionary in module_.trait_dictionaries {
      if dictionary.trait_declaration == trait_declaration &&
        dictionary.implementation == implementation &&
        dictionary.evidence_key == evidence_key {
        present = true
        break
      }
    }
    if present {
      continue
    }
    let mut selected_layout = None
    for layout in module_.trait_layouts {
      if layout.trait_declaration == trait_declaration {
        selected_layout = Some(layout)
        break
      }
    }
    let layout = match selected_layout {
      Some(value) => value
      None => continue
    }
    let implementation_module_index = match
      module_lookup.get(semantic_id_module(implementation)) {
      Some(value) => value
      None => continue
    }
    let implementation_owner = lowering.modules[implementation_module_index]
    let implementation_imports = analyzed.modules[implementation_module_index].imports
    let implementation_resolved = analyzed.frozen.interfaces[implementation_module_index].resolved_types
    let root_evidence = evidence.evidence[root]
    let owner_arguments = match root_evidence.kind {
      PlannedConcreteTraitEvidence(_, arguments) => arguments
    }
    let method_evidence = match
      program_trait_evidence_prerequisite_request(evidence, root) {
      Some(value) => value
      None => continue
    }
    let function_start = module_.functions.length()
    let method_start = module_.trait_methods.length()
    let defined_start = added_defined_function_count
    let mut complete = true
    for slot in 0..<layout.methods.length {
      let requirement = module_.trait_layout_methods[layout.methods.start + slot]
      let implementation_method = match
        program_impl_method_for_requirement(
          lowering, module_lookup, implementation, requirement,
        ) {
        Some(value) => value
        None => {
          complete = false
          break
        }
      }
      let mut requirement_index = -1
      for index, function_ in module_.functions {
        if function_.declaration == requirement &&
          function_.specialization_shapes.length == 0 {
          requirement_index = index
          break
        }
      }
      if requirement_index < 0 {
        complete = false
        break
      }
      let requirement_fragment = module_.functions[requirement_index]
      let request_shapes : Array[PlannedValueShape] = []
      for index in 0..<owner_arguments.length {
        request_shapes.push(evidence.arguments[owner_arguments.start + index])
      }
      let implementation_specialization_abi_key = if request_shapes.length() > 0 {
        match
          materialize_program_generic_specialization(
            analyzed,
            lowering,
            modules,
            module_lookup,
            implementation_method,
            request_shapes,
            { start: 0, length: request_shapes.length() },
            method_evidence,
            false,
          ) {
          Some(value) => value
          None => {
            complete = false
            break
          }
        }
      } else {
        ""
      }
      let (receiver_shape, receiver_nominal) = wasmgc_trait_implementation_receiver(
        implementation_resolved,
        implementation_owner.functions,
        Some(implementation_imports),
        implementation,
        implementation_method,
      )
      if (receiver_shape == RefPlannedValueShape && receiver_nominal == 0UL) ||
        (
          receiver_shape != RefPlannedValueShape &&
          wasmgc_trait_receiver_box_slot(receiver_shape) < 0
        ) {
        complete = false
        break
      }
      let adapter_fragment = module_.functions.length()
      module_.functions.push({
        declaration: wasmgc_trait_adapter_declaration(
          module_.module_id,
          module_.trait_methods.length(),
        ),
        lambda: -1,
        name: b"",
        visibility: ModuleVisible,
        is_test: false,
        is_test_entry: false,
        test_name: b"",
        kind: PlannedWasmTraitAdapterFunction(
          implementation_method, requirement,
        ),
        direct_builtin: b"",
        elided: false,
        signature_type_index: requirement_fragment.signature_type_index,
        function_index: -1,
        parameters: requirement_fragment.parameters,
        results: requirement_fragment.results,
        specialization_shapes: { start: 0, length: 0 },
        specialization_evidence: { start: 0, length: 0 },
        specialization_abi_key: "",
        offset: owner.expressions[expression].offset,
      })
      added_defined_function_count += 1
      module_.trait_methods.push({
        trait_declaration,
        requirement,
        implementation_method,
        receiver_shape,
        receiver_nominal,
        implementation_specialization_abi_key,
        slot,
        signature_type_index: requirement_fragment.signature_type_index,
        adapter_function: adapter_fragment,
      })
    }
    if complete {
      module_.trait_dictionaries.push({
        trait_declaration,
        implementation,
        evidence: source_evidence,
        evidence_key,
        vtable_type_index: layout.vtable_type_index,
        object_type_index: layout.object_type_index,
        methods: {
          start: method_start,
          length: module_.trait_methods.length() - method_start,
        },
      })
    } else {
      module_.functions.truncate(function_start)
      module_.trait_methods.truncate(method_start)
      added_defined_function_count = defined_start
    }
  }
  let latest = modules[owner_index]
  modules[owner_index] = {
    ..latest,
    defined_function_count: latest.defined_function_count +
    added_defined_function_count,
  }
}

///|
fn program_callable_has_symbolic_trait_coercion(
  module_ : PlannedModuleLowering,
  callable : PlannedCallable,
) -> Bool {
  let body_id = match callable.kind {
    PlannedFunctionCallable(body) | PlannedImplMethodCallable(_, Some(body)) =>
      body
    _ => return false
  }
  let body_index = semantic_id_local(body_id)
  if body_index < 0 || body_index >= module_.bodies.length() {
    return false
  }
  let body = module_.bodies[body_index]
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match module_.expressions[expression].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(_, evidence) =>
        if !runtime_trait_evidence_is_concrete(module_, evidence, 0) {
          return true
        }
      _ => ()
    }
  }
  false
}

///|
/// Runs module-local WasmGC fragment jobs in dependency-SCC order while
/// retaining manifest-indexed outputs.
fn plan_program_wasmgc_fragments_for_root(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  options : WasmGCPlanningOptions,
  erased_fallback_module_index : Int,
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
          Some(analyzed.modules[module_index].imports),
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
  let specialized_calls : Array[PlannedProgramSpecializedCall] = []
  for module_index, module_ in lowering.modules {
    if module_index != erased_fallback_module_index {
      continue
    }
    for callable in module_.functions.callables {
      if callable.visibility != Public ||
        program_callable_generic_parameters(callable).length == 0 ||
        program_callable_has_symbolic_trait_coercion(module_, callable) {
        continue
      }
      let erased_shapes = Array::make(
        program_callable_generic_parameters(callable).length,
        RefPlannedValueShape,
      )
      ignore(
        materialize_program_generic_specialization(
          analyzed,
          lowering,
          modules,
          specialization_module_lookup,
          callable.declaration,
          erased_shapes,
          { start: 0, length: erased_shapes.length() },
          empty_program_trait_evidence_request(),
          true,
        ),
      )
    }
  }
  for module_index, module_ in lowering.modules {
    let generic_bodies : Map[BodyId, Bool] = Map::default()
    for callable in module_.functions.callables {
      if program_callable_generic_parameters(callable).length == 0 {
        continue
      }
      match callable.kind {
        PlannedFunctionCallable(body)
        | PlannedImplMethodCallable(_, Some(body)) =>
          generic_bodies[body] = true
        _ => ()
      }
    }
    for body in module_.bodies {
      if generic_bodies.contains(body.body) {
        continue
      }
      for
        expression in body.expressions.start..<(body.expressions.start +
        body.expressions.length) {
        materialize_program_expression_call(
          analyzed,
          lowering,
          modules,
          specialization_module_lookup,
          module_index,
          None,
          None,
          body.body,
          expression,
          specialized_calls,
        )
      }
    }
    for expression in module_.expressions {
      match expression.kind {
        PlannedFunctionReference(declaration, arguments) if arguments.length > 0 =>
          ignore(
            materialize_program_generic_specialization(
              analyzed,
              lowering,
              modules,
              specialization_module_lookup,
              declaration,
              module_.expression_type_argument_shapes,
              arguments,
              empty_program_trait_evidence_request(),
              false,
            ),
          )
        _ => ()
      }
    }
  }
  materialize_program_trait_dictionary_methods(
    analyzed, lowering, modules, specialization_module_lookup,
  )
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
        materialize_program_specialization_trait_dictionaries(
          analyzed, lowering, modules, specialization_module_lookup, owner_index,
          function_, body,
        )
        for
          expression in body.expressions.start..<(body.expressions.start +
          body.expressions.length) {
          materialize_program_expression_call(
            analyzed,
            lowering,
            modules,
            specialization_module_lookup,
            owner_index,
            Some(function_),
            Some(callable),
            body_id,
            expression,
            specialized_calls,
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
        Some(callable) if program_callable_generic_parameters(callable).length >
          0 =>
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
  {
    graph: lowering.graph,
    modules,
    external_type_references,
    specialized_calls,
  }
}

///|
pub fn plan_program_wasmgc_fragments_with_options(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  options : WasmGCPlanningOptions,
) -> PlannedProgramWasmGCFragments {
  plan_program_wasmgc_fragments_for_root(analyzed, lowering, options, 0)
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
fn program_body_resolved_type(
  module_ : PlannedModuleLowering,
  type_ : BodyTypeId,
) -> ResolvedTypeId {
  if type_ < -1 {
    return -type_ - 2
  }
  if type_ >= 0 && type_ < module_.types.length() {
    match module_.types[type_] {
      BodyResolvedType(value) => return value
      _ => ()
    }
  }
  -1
}

///|
fn program_erased_adapter_reference_type(type_ : PlannedWasmValueType) -> Bool {
  match type_ {
    WasmNullableEqRefValue
    | WasmFunctionRefValue(_)
    | WasmNominalRefValue(_)
    | WasmExternalNominalRefValue(_) => true
    _ => false
  }
}

///|
fn program_erased_adapter_value_type(type_ : PlannedWasmValueType) -> Bool {
  program_erased_adapter_reference_type(type_) ||
  program_erased_box_slot_for_value(type_) >= 0
}

///|
fn program_erased_adapter_compatible(
  source_module : PlannedModuleWasmGCFragments,
  source : PlannedWasmFunctionTypeFragment,
  target_module : PlannedModuleWasmGCFragments,
  target : PlannedProgramWasmFunction,
) -> Bool {
  if source.parameters.length != target.parameters.length ||
    source.results.length != target.results.length {
    return false
  }
  for index in 0..<source.parameters.length {
    let source_type = source_module.function_value_types[source.parameters.start +
      index]
    let target_type = target_module.function_value_types[target.parameters.start +
      index]
    if source_type != target_type &&
      !(target_type == WasmNullableEqRefValue &&
      program_erased_adapter_value_type(source_type)) &&
      !(program_erased_adapter_reference_type(source_type) &&
      program_erased_adapter_reference_type(target_type)) {
      return false
    }
  }
  for index in 0..<source.results.length {
    let source_type = source_module.function_value_types[source.results.start +
      index]
    let target_type = target_module.function_value_types[target.results.start +
      index]
    if source_type != target_type &&
      !(target_type == WasmNullableEqRefValue &&
      program_erased_adapter_value_type(source_type)) &&
      !(program_erased_adapter_reference_type(source_type) &&
      program_erased_adapter_reference_type(target_type)) {
      return false
    }
  }
  true
}

///|
fn program_erased_box_slot_for_shape(shape : PlannedValueShape) -> Int {
  match program_canonical_specialization_shape(shape) {
    I32PlannedValueShape => 0
    I64PlannedValueShape => 1
    F32PlannedValueShape => 2
    F64PlannedValueShape => 3
    V128PlannedValueShape => 4
    _ => -1
  }
}

///|
fn program_erased_box_slot_for_value(type_ : PlannedWasmValueType) -> Int {
  match type_ {
    WasmI32Value => 0
    WasmI64Value => 1
    WasmF32Value => 2
    WasmF64Value => 3
    WasmV128Value => 4
    _ => -1
  }
}

///|
fn program_erased_adapter_export_name(
  name : Bytes,
  shapes : Array[PlannedValueShape],
  span : HirSpan,
) -> Bytes {
  let output = Buffer(size_hint=name.length() + 16 + span.length * 8)
  output.write_bytes(name)
  output.write_string_utf8("$dew$")
  for index in 0..<span.length {
    if index > 0 {
      output.write_string_utf8("_")
    }
    output.write_string_utf8(
      program_specialization_shape_name(shapes[span.start + index]),
    )
  }
  output.to_bytes()
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
  let trait_method_nodes : Map[DeclId, Int] = Map::default()
  let trait_vtable_nodes : Map[DeclId, Int] = Map::default()
  let trait_object_nodes : Map[DeclId, Int] = Map::default()
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
          PlannedWasmTraitMethodSignatureType(requirement) =>
            match trait_method_nodes.get(requirement) {
              Some(node) =>
                node_by_module_type[module_index][fragment_index] = node
              None => {
                let node = nodes.length()
                trait_method_nodes[requirement] = node
                node_by_module_type[module_index][fragment_index] = node
                nodes.push({ module_index, fragment_index })
              }
            }
          PlannedWasmTraitVTableType(trait_) =>
            match trait_vtable_nodes.get(trait_) {
              Some(node) =>
                node_by_module_type[module_index][fragment_index] = node
              None => {
                let node = nodes.length()
                trait_vtable_nodes[trait_] = node
                node_by_module_type[module_index][fragment_index] = node
                nodes.push({ module_index, fragment_index })
              }
            }
          PlannedWasmTraitObjectType(trait_) =>
            match trait_object_nodes.get(trait_) {
              Some(node) =>
                node_by_module_type[module_index][fragment_index] = node
              None => {
                let node = nodes.length()
                trait_object_nodes[trait_] = node
                node_by_module_type[module_index][fragment_index] = node
                nodes.push({ module_index, fragment_index })
              }
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
        | PlannedWasmLambdaClosureType(_)
        | PlannedWasmTraitMethodSignatureType(_)
        | PlannedWasmTraitVTableType(_)
        | PlannedWasmTraitObjectType(_) => ()
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
    | PlannedWasmLambdaClosureType(_)
    | PlannedWasmTraitMethodSignatureType(_)
    | PlannedWasmTraitVTableType(_)
    | PlannedWasmTraitObjectType(_) => None
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
          | PlannedWasmLambdaClosureType(_)
          | PlannedWasmTraitMethodSignatureType(_)
          | PlannedWasmTraitVTableType(_)
          | PlannedWasmTraitObjectType(_) => ()
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
  let trait_method_owners : Map[DeclId, Int] = Map::default()
  let trait_vtable_owners : Map[DeclId, Int] = Map::default()
  let trait_object_owners : Map[DeclId, Int] = Map::default()
  for module_index, module_ in fragments.modules {
    for physical in module_.physical_types {
      let owners = match physical.kind {
        PlannedWasmTraitMethodSignatureType(_) => trait_method_owners
        PlannedWasmTraitVTableType(_) => trait_vtable_owners
        PlannedWasmTraitObjectType(_) => trait_object_owners
        _ => continue
      }
      let declaration = match physical.kind {
        PlannedWasmTraitMethodSignatureType(value)
        | PlannedWasmTraitVTableType(value)
        | PlannedWasmTraitObjectType(value) => value
        _ => continue
      }
      match owners.get(declaration) {
        Some(owner) if owner != module_index => cross_module_type_scc = true
        Some(_) => ()
        None => owners[declaration] = module_index
      }
    }
  }
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
            | PlannedWasmLambdaClosureType(_)
            | PlannedWasmTraitMethodSignatureType(_)
            | PlannedWasmTraitVTableType(_)
            | PlannedWasmTraitObjectType(_) => ()
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
        if function_.signature_type_index < module_.physical_types.length() {
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
  let erased_box_used = Array::make(5, false)
  for module_ in fragments.modules {
    for method_info in module_.trait_methods {
      let slot = wasmgc_trait_receiver_box_slot(method_info.receiver_shape)
      if slot >= 0 {
        erased_box_used[slot] = true
      }
    }
  }
  let root_lowering = lowering.modules[root_module_index]
  let root_fragments = fragments.modules[root_module_index]
  for function_ in root_fragments.functions {
    if function_.specialization_shapes.length == 0 {
      continue
    }
    let callable = match
      root_lowering.functions.callable_of(function_.declaration) {
      Some(value) => value
      None => continue
    }
    if callable.visibility != Public {
      continue
    }
    for index in 0..<function_.specialization_shapes.length {
      let slot = program_erased_box_slot_for_shape(
        root_fragments.specialization_shapes[function_.specialization_shapes.start +
        index],
      )
      if slot >= 0 {
        erased_box_used[slot] = true
      }
    }
  }
  let erased_box_type_indices = Array::make(5, -1)
  for slot in 0..<erased_box_used.length() {
    if erased_box_used[slot] {
      erased_box_type_indices[slot] = type_count
      type_count += 1
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
              Some(layout) if layout.generic_parameters.length > 0 => ()
              _ => ()
            }
          PlannedWasmEnumSubtypeType(_, _, _)
          | PlannedWasmClosureType
          | PlannedWasmCaptureCellType(_)
          | PlannedWasmLambdaClosureType(_)
          | PlannedWasmTraitMethodSignatureType(_)
          | PlannedWasmTraitVTableType(_)
          | PlannedWasmTraitObjectType(_) => ()
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
          signature_type_index: if function_.signature_type_index >=
            module_fragments.physical_types.length() {
            module_signature_indices[module_index][function_.signature_type_index -
            module_fragments.physical_types.length()]
          } else if function_.signature_type_index >= 0 {
            module_type_indices[module_index][function_.signature_type_index]
          } else {
            -1
          },
          function_index: -1,
          parameters: function_.parameters,
          results: function_.results,
          specialization_shapes: function_.specialization_shapes,
          specialization_evidence: function_.specialization_evidence,
          specialization_abi_key: function_.specialization_abi_key,
          erased_adapter_target: -1,
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
      | PlannedWasmTraitAdapterFunction(_, _)
      | PlannedWasmSignatureOnlyFunction => ()
    }
  }
  let mut defined_function_count = 0
  for function_ in functions {
    match function_.kind {
      PlannedWasmDefinedFunction(_)
      | PlannedWasmDefinedLambdaFunction(_)
      | PlannedWasmRuntimeFunction(_)
      | PlannedWasmTraitAdapterFunction(_, _) =>
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
  let root_function_count = functions.length()
  for callable in root_lowering.functions.callables {
    if callable.visibility != Public ||
      program_callable_generic_parameters(callable).length == 0 {
      continue
    }
    let mut fallback_index = -1
    for index in 0..<root_function_count {
      let candidate = functions[index]
      if candidate.declaration != callable.declaration ||
        candidate.specialization_shapes.length !=
        program_callable_generic_parameters(callable).length {
        continue
      }
      let candidate_module = fragments.modules[candidate.module_index]
      let mut all_ref = true
      for shape_index in 0..<candidate.specialization_shapes.length {
        if program_canonical_specialization_shape(
            candidate_module.specialization_shapes[candidate.specialization_shapes.start +
            shape_index],
          ) !=
          RefPlannedValueShape {
          all_ref = false
          break
        }
      }
      if all_ref {
        fallback_index = index
        break
      }
    }
    if fallback_index < 0 || functions[fallback_index].function_index < 0 {
      continue
    }
    let fallback = functions[fallback_index]
    for specialization_index in 0..<root_function_count {
      let specialization = functions[specialization_index]
      if specialization.declaration != callable.declaration ||
        specialization.specialization_shapes.length == 0 ||
        specialization.function_index < 0 ||
        specialization_index == fallback_index {
        continue
      }
      let specialization_module = fragments.modules[specialization.module_index]
      let mut has_scalar = false
      for shape_index in 0..<specialization.specialization_shapes.length {
        if program_erased_box_slot_for_shape(
            specialization_module.specialization_shapes[specialization.specialization_shapes.start +
            shape_index],
          ) >=
          0 {
          has_scalar = true
          break
        }
      }
      if !has_scalar {
        continue
      }
      let source = {
        resolved_type: -1,
        signature_type_index: specialization.signature_type_index,
        parameters: specialization.parameters,
        results: specialization.results,
      }
      if !program_erased_adapter_compatible(
          specialization_module,
          source,
          fragments.modules[fallback.module_index],
          fallback,
        ) {
        continue
      }
      functions.push({
        declaration: callable.declaration,
        lambda: -1,
        module_index: root_module_index,
        fragment_index: -1,
        name: program_erased_adapter_export_name(
          callable.name,
          specialization_module.specialization_shapes,
          specialization.specialization_shapes,
        ),
        visibility: Public,
        is_test: false,
        is_test_entry: false,
        test_name: b"",
        kind: PlannedWasmRuntimeFunction(b""),
        direct_builtin: b"",
        elided: false,
        signature_type_index: specialization.signature_type_index,
        function_index: imported_function_count + defined_function_count,
        parameters: specialization.parameters,
        results: specialization.results,
        specialization_shapes: specialization.specialization_shapes,
        specialization_evidence: specialization.specialization_evidence,
        specialization_abi_key: specialization.specialization_abi_key,
        erased_adapter_target: fallback.function_index,
        offset: callable.offset,
      })
      defined_function_count += 1
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
    for expression_index, expression in module_.expressions {
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
          let resolved_type = program_body_resolved_type(
            module_,
            expression.type_,
          )
          let local_signature = if resolved_type >= 0 &&
            resolved_type <
            fragments.modules[module_index].function_type_by_resolved.length() {
            fragments.modules[module_index].function_type_by_resolved[resolved_type]
          } else {
            -1
          }
          let signature_type_index = if local_signature >=
            fragments.modules[module_index].physical_types.length() {
            module_signature_indices[module_index][local_signature -
            fragments.modules[module_index].physical_types.length()]
          } else {
            -1
          }
          match target {
            Some(function_) if function_.function_index >= 0 => {
              let mut reference_function = function_
              if signature_type_index >= 0 &&
                signature_type_index != function_.signature_type_index {
                let mut source_signature = None
                for candidate in fragments.modules[module_index].function_types {
                  if candidate.signature_type_index == local_signature {
                    source_signature = Some(candidate)
                    break
                  }
                }
                match source_signature {
                  Some(source) if !planned_program_function_types_equal(
                      fragments.modules,
                      module_index,
                      source,
                      function_.module_index,
                      {
                        resolved_type: -1,
                        signature_type_index: function_.signature_type_index,
                        parameters: function_.parameters,
                        results: function_.results,
                      },
                    ) &&
                    program_erased_adapter_compatible(
                      fragments.modules[module_index],
                      source,
                      fragments.modules[function_.module_index],
                      function_,
                    ) => {
                    let mut adapter_index = -1
                    for index, candidate in functions {
                      if candidate.erased_adapter_target ==
                        function_.function_index &&
                        candidate.signature_type_index == signature_type_index {
                        adapter_index = index
                        break
                      }
                    }
                    if adapter_index < 0 {
                      adapter_index = functions.length()
                      functions.push({
                        declaration,
                        lambda: -1,
                        module_index,
                        fragment_index: -1,
                        name: b"",
                        visibility: ModuleVisible,
                        is_test: false,
                        is_test_entry: false,
                        test_name: b"",
                        kind: PlannedWasmRuntimeFunction(b""),
                        direct_builtin: b"",
                        elided: false,
                        signature_type_index,
                        function_index: imported_function_count +
                        defined_function_count,
                        parameters: source.parameters,
                        results: source.results,
                        specialization_shapes: { start: 0, length: 0 },
                        specialization_evidence: { start: 0, length: 0 },
                        specialization_abi_key: "",
                        erased_adapter_target: function_.function_index,
                        offset: expression.offset,
                      })
                      defined_function_count += 1
                    }
                    reference_function = functions[adapter_index]
                  }
                  _ => ()
                }
              }
              if !singleton_functions.contains(
                  reference_function.function_index,
                ) {
                singleton_functions[reference_function.function_index] = true
                function_reference_singletons.push({
                  module_index,
                  declaration,
                  function_index: reference_function.function_index,
                  specialization_module_index: function_.module_index,
                  specialization_shapes: function_.specialization_shapes,
                  signature_type_index,
                  global_index,
                })
                global_index += 1
              }
            }
            _ => ()
          }
        }
        _ => ()
      }
      ignore(expression_index)
    }
  }
  let trait_dictionary_globals : Array[PlannedProgramTraitDictionaryGlobal] = []
  for module_index, module_ in fragments.modules {
    for dictionary_index in 0..<module_.trait_dictionaries.length() {
      trait_dictionary_globals.push({
        module_index,
        dictionary_index,
        global_index,
      })
      global_index += 1
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
    function_reference_singletons.length() > 0 ||
    trait_dictionary_globals.length() > 0
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
    fragments.specialized_calls,
    diagnostics,
  )
  let specialized_call_lookup : Map[String, Int] = Map::default()
  for call in fragments.specialized_calls {
    let mut target_index = -1
    if call.target_specialization_abi_key.length() == 0 {
      match function_lookup.get(call.target) {
        Some(index) => target_index = index
        None => ()
      }
    } else {
      for index, function_ in functions {
        if function_.declaration == call.target &&
          function_.specialization_abi_key == call.target_specialization_abi_key {
          target_index = index
          break
        }
      }
    }
    if target_index >= 0 {
      specialized_call_lookup[program_specialized_call_key(
        call.caller_body,
        call.caller_specialization_abi_key,
        call.expression,
      )] = target_index
    }
  }
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
    specialized_call_lookup,
    initializers,
    global_lookup,
    function_reference_singletons,
    trait_dictionary_globals,
    initializer_type_index,
    startup_function_index,
    type_lookup,
    module_lookup,
    erased_box_type_indices,
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
    plan_program_wasmgc_fragments_for_root(
      analyzed, lowering, options, root_module_index,
    ),
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
