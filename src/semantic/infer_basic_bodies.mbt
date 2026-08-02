///|
let instantiate_visit = 0

///|
let instantiate_finish_application = 1

///|
let import_value_visit = 0

///|
let import_value_finish_application = 1

///|
let empty_body_type_array : Array[BodyTypeId] = []

///|
let empty_pattern_constructor_array : Array[InferredPatternConstructor] = []

///|
let empty_expression_selection_array : Array[InferredExpressionSelection] = []

///|
let empty_object_field_target_array : Array[InferredObjectFieldTarget] = []

///|
let empty_inference_bool_array : Array[Bool] = []

///|
priv struct BodyInferenceJobResult {
  result_type : BodyTypeId
  types : Array[BodyTypeTerm]
  type_arguments : Array[BodyTypeId]
  expression_types : Array[BodyTypeId]
  local_types : Array[BodyTypeId]
  block_types : Array[BodyTypeId]
  pattern_types : Array[BodyTypeId]
  pattern_constructors : Array[InferredPatternConstructor]
  pattern_type_arguments : Array[BodyTypeId]
  control_state_types : Array[BodyTypeId]
  control_result_types : Array[BodyTypeId]
  expression_selections : Array[InferredExpressionSelection]
  expression_type_arguments : Array[BodyTypeId]
  object_field_targets : Array[InferredObjectFieldTarget]
  call_expressions : Array[ExprId]
  call_targets : Array[InferredCallTarget]
  operator_targets : Array[InferredCallTarget]
  map_hash_targets : Array[InferredCallTarget]
  map_eq_targets : Array[InferredCallTarget]
  call_type_arguments : Array[BodyTypeId]
  diagnostics : Array[BodyInferenceDiagnostic]
}

///|
priv struct CallInferenceScratch {
  pending_calls : Array[ExprId]
  deferred_calls : Array[ExprId]
  overload_candidates : Array[DeclId]
  pending_methods : Array[ExprId]
  deferred_methods : Array[ExprId]
  pending_operators : Array[ExprId]
  deferred_operators : Array[ExprId]
  method_candidates : Array[DeclId]
  method_candidate_impls : Array[Int]
  member_expressions : Array[ExprId]
  deferred_members : Array[ExprId]
  candidate_type_arguments : Array[BodyTypeId]
  nominal_arguments : Array[BodyTypeId]
  mut nominal_declaration : DeclId
  pattern_tasks : Array[PatternId]
  pattern_task_types : Array[BodyTypeId]
  pattern_field_indices : Array[Int]
  pattern_field_matched : Array[Bool]
  pattern_field_lookup : Map[NameId, Int]
  instantiation_task_types : Array[ResolvedTypeId]
  instantiation_task_states : Array[Int]
  instantiation_result_starts : Array[Int]
  instantiation_results : Array[BodyTypeId]
  instantiation_arguments : Array[BodyTypeId]
  instantiation_marks : Array[Int]
  instantiation_values : Array[BodyTypeId]
  mut instantiation_generation : Int
  mut instantiation_generics : HirSpan
  mut instantiation_method_generics : HirSpan
  mut instantiation_self_owner : DeclId
  mut instantiation_self_type : BodyTypeId
  mut trial_viable_count : Int
  mut trial_first_declaration : DeclId
  mut trial_second_declaration : DeclId
}

///|
fn CallInferenceScratch::new() -> CallInferenceScratch {
  {
    pending_calls: [],
    deferred_calls: [],
    overload_candidates: [],
    pending_methods: [],
    deferred_methods: [],
    pending_operators: [],
    deferred_operators: [],
    method_candidates: [],
    method_candidate_impls: [],
    member_expressions: [],
    deferred_members: [],
    candidate_type_arguments: [],
    nominal_arguments: [],
    nominal_declaration: 0UL,
    pattern_tasks: [],
    pattern_task_types: [],
    pattern_field_indices: [],
    pattern_field_matched: [],
    pattern_field_lookup: Map::default(),
    instantiation_task_types: [],
    instantiation_task_states: [],
    instantiation_result_starts: [],
    instantiation_results: [],
    instantiation_arguments: [],
    instantiation_marks: [],
    instantiation_values: [],
    instantiation_generation: 0,
    instantiation_generics: { start: 0, length: 0 },
    instantiation_method_generics: { start: 0, length: 0 },
    instantiation_self_owner: 0UL,
    instantiation_self_type: -1,
    trial_viable_count: 0,
    trial_first_declaration: 0UL,
    trial_second_declaration: 0UL,
  }
}

///|
fn CallInferenceScratch::begin_body(self : CallInferenceScratch) -> Unit {
  self.pending_calls.clear()
  self.deferred_calls.clear()
  self.overload_candidates.clear()
  self.pending_methods.clear()
  self.deferred_methods.clear()
  self.pending_operators.clear()
  self.deferred_operators.clear()
  self.method_candidates.clear()
  self.method_candidate_impls.clear()
  self.member_expressions.clear()
  self.deferred_members.clear()
  self.candidate_type_arguments.clear()
  self.nominal_arguments.clear()
  self.pattern_tasks.clear()
  self.pattern_task_types.clear()
  self.pattern_field_indices.clear()
  self.pattern_field_matched.clear()
  self.pattern_field_lookup.clear()
  self.instantiation_task_types.clear()
  self.instantiation_task_states.clear()
  self.instantiation_result_starts.clear()
  self.instantiation_results.clear()
  self.instantiation_arguments.clear()
}

///|
priv struct ModuleValueImporter {
  values : InferredModuleValues
  solver : LocalTypeSolver
  task_types : Array[BodyTypeId]
  task_states : Array[Int]
  result_starts : Array[Int]
  results : Array[BodyTypeId]
  arguments : Array[BodyTypeId]
  marks : Array[Int]
  cached : Array[BodyTypeId]
  mut generation : Int
}

///|
fn ModuleValueImporter::new(
  values : InferredModuleValues,
  solver : LocalTypeSolver,
) -> ModuleValueImporter {
  {
    values,
    solver,
    task_types: [],
    task_states: [],
    result_starts: [],
    results: [],
    arguments: [],
    marks: [0],
    cached: [0],
    generation: 0,
  }
}

///|
fn ModuleValueImporter::begin_solver(self : ModuleValueImporter) -> Unit {
  self.generation += 1
  if self.generation == 0 {
    self.marks.fill(0)
    self.generation = 1
  }
}

///|
fn ModuleValueImporter::ensure_cache(self : ModuleValueImporter) -> Unit {
  while self.marks.length() < self.values.types.length() {
    self.marks.push(0)
    self.cached.push(0)
  }
}

///|
fn ModuleValueImporter::push_task(
  self : ModuleValueImporter,
  type_ : BodyTypeId,
  state : Int,
  result_start : Int,
) -> Unit {
  self.task_types.push(type_)
  self.task_states.push(state)
  self.result_starts.push(result_start)
}

///|
fn ModuleValueImporter::import_type(
  self : ModuleValueImporter,
  root : BodyTypeId,
) -> BodyTypeId {
  if root <= 0 {
    return root
  }
  self.ensure_cache()
  self.task_types.clear()
  self.task_states.clear()
  self.result_starts.clear()
  self.results.clear()
  self.push_task(root, import_value_visit, 0)
  while self.task_types.length() > 0 {
    let source = self.task_types.pop().unwrap()
    let state = self.task_states.pop().unwrap()
    let result_start = self.result_starts.pop().unwrap()
    if source <= 0 {
      self.results.push(source)
      continue
    }
    if state == import_value_visit {
      if self.marks[source] == self.generation {
        self.results.push(self.cached[source])
        continue
      }
      match self.values.types[source] {
        BodyAppliedType(base, arguments) => {
          self.push_task(
            source,
            import_value_finish_application,
            self.results.length(),
          )
          let mut index = arguments.length
          while index > 0 {
            index -= 1
            self.push_task(
              self.values.type_arguments[arguments.start + index],
              import_value_visit,
              0,
            )
          }
          self.push_task(base, import_value_visit, 0)
        }
        BodyVariableType(_) => {
          self.marks[source] = self.generation
          self.cached[source] = self.solver.error_type()
          self.results.push(self.solver.error_type())
        }
        BodyErrorType => self.results.push(self.solver.error_type())
        BodyResolvedType(type_) =>
          self.results.push(self.solver.resolved_type(type_))
      }
    } else {
      let arguments = match self.values.types[source] {
        BodyAppliedType(_, arguments) => arguments
        _ => abort("module value import expected an applied type")
      }
      let base = self.results[result_start]
      self.arguments.clear()
      for index in 0..<arguments.length {
        self.arguments.push(self.results[result_start + index + 1])
      }
      let result = self.solver.applied_type(base, self.arguments)
      self.marks[source] = self.generation
      self.cached[source] = result
      self.results.truncate(result_start)
      self.results.push(result)
    }
  }
  guard self.results.length() == 1 else {
    abort("invalid imported module value type")
  }
  self.results[0]
}

///|
priv struct ModuleValueInferenceContext {
  values : InferredModuleValues
  let_indices : Array[Int]
  slots : Array[BodyTypeId]
  importer : ModuleValueImporter
}

///|
fn ModuleValueInferenceContext::new(
  values : InferredModuleValues,
  let_indices : Array[Int],
  solver : LocalTypeSolver,
) -> ModuleValueInferenceContext {
  {
    values,
    let_indices,
    slots: Array::make(values.let_types.length(), -1),
    importer: ModuleValueImporter::new(values, solver),
  }
}

///|
fn ModuleValueInferenceContext::begin_solver(
  self : ModuleValueInferenceContext,
) -> Unit {
  self.slots.fill(-1)
  self.importer.begin_solver()
}

///|
fn ModuleValueInferenceContext::let_index(
  self : ModuleValueInferenceContext,
  declaration : DeclId,
) -> Int {
  let local_index = semantic_id_local(declaration)
  if local_index < 0 || local_index >= self.let_indices.length() {
    -1
  } else {
    self.let_indices[local_index]
  }
}

///|
fn ModuleValueInferenceContext::type_of(
  self : ModuleValueInferenceContext,
  declaration : DeclId,
) -> BodyTypeId {
  let index = self.let_index(declaration)
  guard index >= 0 else { return self.importer.solver.error_type() }
  let slot = self.slots[index]
  if slot != -1 {
    slot
  } else {
    self.importer.import_type(self.values.let_types[index])
  }
}

///|
priv struct BasicBodyInferencer {
  collected : CollectedModule
  resolved : ResolvedModuleTypes
  imports : ResolvedModuleImports?
  impl_index : ModuleImplIndex
  names : ResolvedModuleNames
  body : HirBody
  name_info : ResolvedBodyNames
  callable_index : Int
  callable_indices : Array[Int]
  variant_spans : Array[HirSpan]
  field_spans : Array[HirSpan]
  solver : LocalTypeSolver
  expression_types : Array[BodyTypeId]
  local_types : Array[BodyTypeId]
  block_types : Array[BodyTypeId]
  pattern_types : Array[BodyTypeId]
  pattern_constructors : Array[InferredPatternConstructor]
  pattern_type_arguments : Array[BodyTypeId]
  control_state_types : Array[BodyTypeId]
  control_result_types : Array[BodyTypeId]
  mut expression_selections : Array[InferredExpressionSelection]
  expression_type_arguments : Array[BodyTypeId]
  object_field_targets : Array[InferredObjectFieldTarget]
  mut consumed_member_roots : Array[Bool]
  mut has_member_expressions : Bool
  call_expressions : Array[ExprId]
  call_targets : Array[InferredCallTarget]
  operator_targets : Array[InferredCallTarget]
  map_hash_targets : Array[InferredCallTarget]
  map_eq_targets : Array[InferredCallTarget]
  call_type_arguments : Array[BodyTypeId]
  call_scratch : CallInferenceScratch
  module_values : ModuleValueInferenceContext?
  unsupported_expressions : Array[Bool]
  diagnostics : Array[BodyInferenceDiagnostic]
  mut solver_diagnostic_start : Int
  mut solver_diagnostic_end : Int
  mut declared_return_type : BodyTypeId
  mut result_type : BodyTypeId
  mut compact_marks : Array[Bool]
  compact_stack : Array[BodyTypeId]
  mut compact_mapping : Array[BodyTypeId]
  compact_types : Array[BodyTypeTerm]
  compact_arguments : Array[BodyTypeId]
}

///|
fn BasicBodyInferencer::declaration_visible(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Bool {
  self.collected.declaration_is_test_only(self.body.declaration) ||
  !self.collected.declaration_is_test_only(declaration)
}

///|
fn BasicBodyInferencer::implementation_visible(
  self : BasicBodyInferencer,
  implementation : Int,
) -> Bool {
  self.declaration_visible(
    self.impl_index.implementations[implementation].declaration,
  )
}

///|
fn BasicBodyInferencer::new(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports?,
  impl_index : ModuleImplIndex,
  names : ResolvedModuleNames,
  body : HirBody,
  callable_index : Int,
  callable_indices : Array[Int],
  variant_spans : Array[HirSpan],
  field_spans : Array[HirSpan],
  solver : LocalTypeSolver,
  call_scratch : CallInferenceScratch,
  module_values : ModuleValueInferenceContext?,
) -> BasicBodyInferencer {
  let name_info = names.body(body.id).unwrap()
  {
    collected,
    resolved,
    imports,
    impl_index,
    names,
    body,
    name_info,
    callable_index,
    callable_indices,
    variant_spans,
    field_spans,
    solver,
    expression_types: Array::make(body.expressions.length, 0),
    local_types: Array::make(name_info.locals.length, 0),
    block_types: Array::make(body.blocks.length, 0),
    pattern_types: if body.patterns.length == 0 {
      empty_body_type_array
    } else {
      Array::make(body.patterns.length, 0)
    },
    pattern_constructors: if body.patterns.length == 0 {
      empty_pattern_constructor_array
    } else {
      Array::make(body.patterns.length, NoInferredPatternConstructor)
    },
    pattern_type_arguments: if body.patterns.length == 0 {
      empty_body_type_array
    } else {
      []
    },
    control_state_types: if name_info.controls.length == 0 {
      empty_body_type_array
    } else {
      Array::make(name_info.controls.length, 0)
    },
    control_result_types: if name_info.controls.length == 0 {
      empty_body_type_array
    } else {
      Array::make(name_info.controls.length, 0)
    },
    expression_selections: empty_expression_selection_array,
    expression_type_arguments: [],
    object_field_targets: if body.object_fields.length == 0 {
      empty_object_field_target_array
    } else {
      Array::make(body.object_fields.length, NoObjectFieldTarget)
    },
    consumed_member_roots: empty_inference_bool_array,
    has_member_expressions: false,
    call_expressions: [],
    call_targets: [],
    operator_targets: Array::make(body.expressions.length, NoInferredCallTarget),
    map_hash_targets: Array::make(body.expressions.length, NoInferredCallTarget),
    map_eq_targets: Array::make(body.expressions.length, NoInferredCallTarget),
    call_type_arguments: [],
    call_scratch,
    module_values,
    unsupported_expressions: Array::make(body.expressions.length, false),
    diagnostics: [],
    solver_diagnostic_start: 0,
    solver_diagnostic_end: 0,
    declared_return_type: 0,
    result_type: 0,
    compact_marks: [],
    compact_stack: [],
    compact_mapping: [],
    compact_types: [],
    compact_arguments: [],
  }
}

///|
fn BasicBodyInferencer::expression_index(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Int {
  expression - self.body.expressions.start
}

///|
fn BasicBodyInferencer::block_index(
  self : BasicBodyInferencer,
  block : BlockId,
) -> Int {
  block - self.body.blocks.start
}

///|
fn BasicBodyInferencer::expression_type(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> BodyTypeId {
  self.expression_types[self.expression_index(expression)]
}

///|
fn BasicBodyInferencer::block_type(
  self : BasicBodyInferencer,
  block : BlockId,
) -> BodyTypeId {
  self.block_types[self.block_index(block)]
}

///|
fn BasicBodyInferencer::primitive(
  self : BasicBodyInferencer,
  primitive : PrimitiveType,
) -> BodyTypeId {
  self.solver.resolved_type(self.resolved.primitive(primitive))
}

///|
fn BasicBodyInferencer::diagnose(
  self : BasicBodyInferencer,
  diagnostic : BodyInferenceDiagnostic,
) -> Unit {
  self.diagnostics.push(diagnostic)
}

///|
fn BasicBodyInferencer::constrain(
  self : BasicBodyInferencer,
  left : BodyTypeId,
  right : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> Unit {
  ignore(self.solver.unify(left, right, origin))
}

///|
fn BasicBodyInferencer::is_never_type(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> Bool {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyResolvedType(resolved_type) =>
      resolved_type == self.resolved.primitive(NeverType)
    _ => false
  }
}

///|
fn BasicBodyInferencer::constrain_assignable(
  self : BasicBodyInferencer,
  actual : BodyTypeId,
  expected : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> Unit {
  if !self.is_never_type(actual) {
    self.constrain(actual, expected, origin)
  }
}

///|
fn BasicBodyInferencer::module_value_type(
  self : BasicBodyInferencer,
  name : NameId,
) -> BodyTypeId? {
  match self.module_values {
    Some(module_values) =>
      match module_value_declaration(self.collected, name) {
        Some(declaration) => {
          let let_index = module_values.let_index(declaration)
          if let_index >= 0 {
            Some(module_values.type_of(declaration))
          } else {
            None
          }
        }
        None => None
      }
    None => None
  }
}

///|
fn BasicBodyInferencer::local_function_reference(
  self : BasicBodyInferencer,
  name : NameId,
) -> (DeclId, ResolvedTypeId)? {
  let binding = match self.collected.value_bindings.get(name) {
    Some(binding) => binding
    None => return None
  }
  let mut cursor = binding.head
  let mut selected_declaration = 0UL
  let mut selected_type = -1
  while cursor >= 0 {
    let candidate = self.collected.value_binding_candidates[cursor]
    if self.declaration_visible(candidate.declaration) {
      let local_index = semantic_id_local(candidate.declaration)
      if local_index >= 0 && local_index < self.callable_indices.length() {
        let callable_index = self.callable_indices[local_index]
        if callable_index >= 0 &&
          self.collected.generic_parameters_of(candidate.declaration).length ==
          0 {
          if selected_type >= 0 {
            return None
          }
          selected_declaration = candidate.declaration
          selected_type = self.resolved.callable_function_types[callable_index]
        }
      }
    }
    cursor = candidate.next
  }
  if selected_type >= 0 {
    Some((selected_declaration, selected_type))
  } else {
    None
  }
}

///|
fn BasicBodyInferencer::imported_function_reference(
  self : BasicBodyInferencer,
  head : Int,
) -> (DeclId, ResolvedTypeId)? {
  let imports = match self.imports {
    Some(imports) => imports
    None => return None
  }
  let mut cursor = head
  let mut selected_declaration = 0UL
  let mut selected_type = -1
  while cursor >= 0 {
    let reference = imports.scope.callable_references[cursor]
    let interface_ = imports.scope.interfaces[reference.interface_index].unwrap()
    let declaration = interface_.callables[reference.callable_index].declaration
    match imports.callable(declaration) {
      Some(callable) if callable.generic_parameters.length == 0 => {
        if selected_type >= 0 {
          return None
        }
        selected_declaration = declaration
        selected_type = callable.function_type
      }
      _ => ()
    }
    cursor = reference.next
  }
  if selected_type >= 0 {
    Some((selected_declaration, selected_type))
  } else {
    None
  }
}

///|
fn BasicBodyInferencer::initialize_control_types(
  self : BasicBodyInferencer,
) -> Unit {
  for control in 0..<self.name_info.controls.length {
    self.control_state_types[control] = self.solver.fresh_variable()
    self.control_result_types[control] = self.solver.fresh_variable()
  }
}

///|
fn BasicBodyInferencer::ensure_member_storage(
  self : BasicBodyInferencer,
) -> Unit {
  if self.has_member_expressions {
    return
  }
  self.has_member_expressions = true
  self.expression_selections = Array::make(
    self.body.expressions.length,
    NoExpressionSelection,
  )
  self.consumed_member_roots = Array::make(self.body.expressions.length, false)
}

///|
fn BasicBodyInferencer::initialize_expression_types(
  self : BasicBodyInferencer,
) -> Unit {
  let negated_boundary_literals = Array::make(
    self.collected.expressions.length(),
    false,
  )
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    match self.collected.expressions[expression] {
      HirPrefixExpr(HirNegative, operand, _) =>
        negated_boundary_literals[operand] = true
      _ => ()
    }
  }
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    let type_ = match self.collected.expressions[expression] {
      HirI8Expr(value, offset) =>
        if value <= 0x7FUL ||
          (value == 0x80UL && negated_boundary_literals[expression]) {
          self.primitive(I8Type)
        } else {
          self.diagnose(NumericLiteralOutOfRange(expression, I8Type, offset))
          self.solver.error_type()
        }
      HirI16Expr(value, offset) =>
        if value <= 0x7FFFUL ||
          (value == 0x8000UL && negated_boundary_literals[expression]) {
          self.primitive(I16Type)
        } else {
          self.diagnose(NumericLiteralOutOfRange(expression, I16Type, offset))
          self.solver.error_type()
        }
      HirI32Expr(value, offset) =>
        if value <= 0x7FFFFFFFUL ||
          (value == 0x80000000UL && negated_boundary_literals[expression]) {
          self.primitive(I32Type)
        } else {
          self.diagnose(NumericLiteralOutOfRange(expression, I32Type, offset))
          self.solver.error_type()
        }
      HirI64Expr(value, offset) =>
        if value <= 0x7FFFFFFFFFFFFFFFUL ||
          (
            value == 0x8000000000000000UL &&
            negated_boundary_literals[expression]
          ) {
          self.primitive(I64Type)
        } else {
          self.diagnose(NumericLiteralOutOfRange(expression, I64Type, offset))
          self.solver.error_type()
        }
      HirU8Expr(_, _) => self.primitive(U8Type)
      HirU16Expr(_, _) => self.primitive(U16Type)
      HirU32Expr(_, _) => self.primitive(U32Type)
      HirU64Expr(_, _) => self.primitive(U64Type)
      HirF32Expr(_, _) => self.primitive(F32Type)
      HirF64Expr(_, _) => self.primitive(F64Type)
      HirBoolExpr(_, _) => self.primitive(BoolType)
      HirStringExpr(_, _) => self.primitive(StringType)
      HirBytesExpr(_, _) => self.primitive(BytesType)
      HirNameExpr(name, _) =>
        match self.names.expression_references[expression] {
          LocalNameReference(local_id) => self.local_types[local_id]
          ModuleValueNameReference(_) =>
            match self.module_value_type(name) {
              Some(type_) => type_
              None =>
                match self.local_function_reference(name) {
                  Some((declaration, type_)) => {
                    self.ensure_member_storage()
                    self.expression_selections[self.expression_index(expression)] = FunctionReferenceSelection(
                      declaration,
                    )
                    self.solver.resolved_type(type_)
                  }
                  None => self.solver.fresh_variable()
                }
            }
          ImportedValueNameReference(head) =>
            match self.imported_function_reference(head) {
              Some((declaration, type_)) => {
                self.ensure_member_storage()
                self.expression_selections[self.expression_index(expression)] = FunctionReferenceSelection(
                  declaration,
                )
                self.solver.resolved_type(type_)
              }
              None => self.solver.fresh_variable()
            }
          ImportedModuleValueNameReference(declaration) =>
            match self.imports {
              Some(imports) =>
                match imports.module_value_type(declaration) {
                  Some(type_) => self.solver.resolved_type(type_)
                  None => self.solver.error_type()
                }
              None => self.solver.error_type()
            }
          ErrorNameReference => self.solver.error_type()
          VariantNameReference(_) => {
            self.ensure_member_storage()
            self.solver.fresh_variable()
          }
          _ => self.solver.fresh_variable()
        }
      HirIfExpr(_, _, alternative, _) if alternative < 0 =>
        self.primitive(UnitType)
      HirPrefixExpr(HirLogicalNot, _, _) => self.primitive(BoolType)
      HirBinaryExpr(operator, _, _, _) =>
        match operator {
          HirLogicalOr
          | HirLogicalAnd
          | HirEqual
          | HirNotEqual
          | HirLess
          | HirLessEqual
          | HirGreater
          | HirGreaterEqual => self.primitive(BoolType)
          _ => self.solver.fresh_variable()
        }
      HirWhileExpr(_, _, _) => {
        let control = self.names.expression_controls[expression]
        if control >= 0 {
          self.control_result_types[control]
        } else {
          self.solver.error_type()
        }
      }
      HirBreakExpr(_, _) | HirContinueExpr(_, _) => self.primitive(NeverType)
      HirCallExpr(_, _, _) => {
        self.call_expressions.push(expression)
        self.call_targets.push(NoInferredCallTarget)
        self.solver.fresh_variable()
      }
      HirObjectExpr(_, _)
      | HirConstructExpr(_, _, _)
      | HirFieldExpr(_, _, _)
      | HirQualifiedExpr(_, _, _) => {
        self.ensure_member_storage()
        self.solver.fresh_variable()
      }
      _ => self.solver.fresh_variable()
    }
    self.expression_types[self.expression_index(expression)] = type_
  }
}

///|
fn BasicBodyInferencer::body_signature_type(
  self : BasicBodyInferencer,
  root : ResolvedTypeId,
) -> BodyTypeId {
  if self.body.kind != ImplMethodBody {
    return self.solver.resolved_type(root)
  }
  let parent = match self.collected.declaration(self.body.declaration) {
    Some(MethodReference(method_info)) => method_info.parent
    _ => return self.solver.resolved_type(root)
  }
  let mut implementation_index = -1
  for index, implementation in self.collected.impls {
    if implementation.declaration == parent {
      implementation_index = index
      break
    }
  }
  if implementation_index < 0 {
    return self.solver.resolved_type(root)
  }
  self.call_scratch.instantiation_generics = { start: 0, length: 0 }
  self.call_scratch.instantiation_method_generics = { start: 0, length: 0 }
  self.call_scratch.candidate_type_arguments.clear()
  self.call_scratch.instantiation_self_owner = parent
  self.call_scratch.instantiation_self_type = self.solver.resolved_type(
    self.resolved.impl_target_types[implementation_index],
  )
  self.next_instantiation_generation()
  self.instantiate_signature_type(root)
}

///|
fn BasicBodyInferencer::initialize_local_types(
  self : BasicBodyInferencer,
) -> Unit {
  for local_id in 0..<self.name_info.locals.length {
    let local_info = self.names.locals[self.name_info.locals.start + local_id]
    self.local_types[local_id] = match local_info.kind {
      ParameterLocal =>
        self.body_signature_type(
          self.resolved.parameter_types[local_info.source],
        )
      LetLocal | PatternLocal => self.solver.fresh_variable()
    }
  }
}

///|
fn BasicBodyInferencer::initialize_block_types(
  self : BasicBodyInferencer,
) -> Unit {
  let unit = self.primitive(UnitType)
  let never = self.primitive(NeverType)
  for
    block in self.body.blocks.start..<(self.body.blocks.start +
    self.body.blocks.length) {
    let block_data = self.collected.blocks[block]
    let type_ = if block_data.items.length == 0 {
      unit
    } else {
      let item = self.collected.block_items[block_data.items.start +
        block_data.items.length -
        1]
      match item {
        HirLetItem(_, _, _, _, _) => unit
        HirReturnItem(_, _) => never
        HirExpressionItem(expression, _) => self.expression_type(expression)
      }
    }
    self.block_types[self.block_index(block)] = type_
  }
}

///|
fn BasicBodyInferencer::reuse_block_expression_types(
  self : BasicBodyInferencer,
) -> Unit {
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    match self.collected.expressions[expression] {
      HirBlockExpr(block, _) =>
        self.expression_types[self.expression_index(expression)] = self.block_type(
          block,
        )
      _ => ()
    }
  }
}

///|
fn BasicBodyInferencer::initialize_return_type(
  self : BasicBodyInferencer,
) -> Unit {
  self.declared_return_type = if self.callable_index >= 0 {
    self.body_signature_type(
      self.resolved.callable_return_types[self.callable_index],
    )
  } else {
    self.solver.error_type()
  }
}

///|
fn BasicBodyInferencer::poison_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Unit {
  self.solver.poison_type(self.expression_type(expression))
}

///|
fn BasicBodyInferencer::mark_unsupported(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Unit {
  let index = self.expression_index(expression)
  if self.unsupported_expressions[index] {
    return
  }
  self.unsupported_expressions[index] = true
  self.poison_expression(expression)
}

///|
fn BasicBodyInferencer::consume_unsupported_root(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Unit {
  let index = self.expression_index(expression)
  self.unsupported_expressions[index] = false
  match self.collected.expressions[expression] {
    HirQualifiedExpr(base, _, _) | HirFieldExpr(base, _, _) =>
      self.consume_unsupported_root(base)
    _ => ()
  }
}

///|
fn BasicBodyInferencer::ensure_instantiation_cache(
  self : BasicBodyInferencer,
) -> Unit {
  while self.call_scratch.instantiation_marks.length() <
        self.resolved.types.length() {
    self.call_scratch.instantiation_marks.push(0)
    self.call_scratch.instantiation_values.push(0)
  }
}

///|
fn BasicBodyInferencer::next_instantiation_generation(
  self : BasicBodyInferencer,
) -> Unit {
  self.ensure_instantiation_cache()
  self.call_scratch.instantiation_generation += 1
  if self.call_scratch.instantiation_generation == 0 {
    self.call_scratch.instantiation_marks.fill(0)
    self.call_scratch.instantiation_generation = 1
  }
}

///|
fn BasicBodyInferencer::begin_call_candidate(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Unit {
  self.call_scratch.instantiation_self_owner = 0UL
  self.call_scratch.instantiation_self_type = -1
  self.call_scratch.instantiation_generics = if semantic_id_module(declaration) ==
    self.collected.module_id {
    self.collected.generic_parameters_of(declaration)
  } else {
    match self.imports {
      Some(imports) =>
        match imports.callable(declaration) {
          Some(callable) => callable.generic_parameters
          None => { start: 0, length: 0 }
        }
      None => { start: 0, length: 0 }
    }
  }
  self.call_scratch.instantiation_method_generics = { start: 0, length: 0 }
  self.call_scratch.candidate_type_arguments.clear()
  for _ in 0..<self.call_scratch.instantiation_generics.length {
    self.call_scratch.candidate_type_arguments.push(
      self.solver.fresh_variable(),
    )
  }
  self.next_instantiation_generation()
}

///|
fn BasicBodyInferencer::push_instantiation_task(
  self : BasicBodyInferencer,
  type_ : ResolvedTypeId,
  state : Int,
  result_start : Int,
) -> Unit {
  self.call_scratch.instantiation_task_types.push(type_)
  self.call_scratch.instantiation_task_states.push(state)
  self.call_scratch.instantiation_result_starts.push(result_start)
}

///|
fn BasicBodyInferencer::instantiate_signature_type(
  self : BasicBodyInferencer,
  root : ResolvedTypeId,
) -> BodyTypeId {
  self.call_scratch.instantiation_task_types.clear()
  self.call_scratch.instantiation_task_states.clear()
  self.call_scratch.instantiation_result_starts.clear()
  self.call_scratch.instantiation_results.clear()
  self.push_instantiation_task(root, instantiate_visit, 0)
  while self.call_scratch.instantiation_task_types.length() > 0 {
    let source = self.call_scratch.instantiation_task_types.pop().unwrap()
    let state = self.call_scratch.instantiation_task_states.pop().unwrap()
    let result_start = self.call_scratch.instantiation_result_starts
      .pop()
      .unwrap()
    if state == instantiate_visit {
      if self.call_scratch.instantiation_marks[source] ==
        self.call_scratch.instantiation_generation {
        self.call_scratch.instantiation_results.push(
          self.call_scratch.instantiation_values[source],
        )
        continue
      }
      match self.resolved.types[source] {
        GenericParameterType(parameter) => {
          let generic_index = semantic_id_local(parameter)
          let result = if generic_index >=
            self.call_scratch.instantiation_generics.start &&
            generic_index <
            self.call_scratch.instantiation_generics.start +
            self.call_scratch.instantiation_generics.length {
            self.call_scratch.candidate_type_arguments[generic_index -
            self.call_scratch.instantiation_generics.start]
          } else if generic_index >=
            self.call_scratch.instantiation_method_generics.start &&
            generic_index <
            self.call_scratch.instantiation_method_generics.start +
            self.call_scratch.instantiation_method_generics.length {
            self.call_scratch.candidate_type_arguments[self.call_scratch.instantiation_generics.length +
            generic_index -
            self.call_scratch.instantiation_method_generics.start]
          } else {
            self.solver.resolved_type(source)
          }
          self.call_scratch.instantiation_marks[source] = self.call_scratch.instantiation_generation
          self.call_scratch.instantiation_values[source] = result
          self.call_scratch.instantiation_results.push(result)
        }
        AppliedType(base, arguments) => {
          self.push_instantiation_task(
            source,
            instantiate_finish_application,
            self.call_scratch.instantiation_results.length(),
          )
          let mut index = arguments.length
          while index > 0 {
            index -= 1
            self.push_instantiation_task(
              self.resolved.type_arguments[arguments.start + index],
              instantiate_visit,
              0,
            )
          }
          self.push_instantiation_task(base, instantiate_visit, 0)
        }
        SelfType(owner) => {
          let result = if owner == self.call_scratch.instantiation_self_owner &&
            self.call_scratch.instantiation_self_type != -1 {
            self.call_scratch.instantiation_self_type
          } else {
            self.solver.resolved_type(source)
          }
          self.call_scratch.instantiation_marks[source] = self.call_scratch.instantiation_generation
          self.call_scratch.instantiation_values[source] = result
          self.call_scratch.instantiation_results.push(result)
        }
        ErrorType
        | PrimitiveType(_)
        | NominalType(_)
        | TraitType(_)
        | FunctionType(_, _) => {
          let result = self.solver.resolved_type(source)
          self.call_scratch.instantiation_marks[source] = self.call_scratch.instantiation_generation
          self.call_scratch.instantiation_values[source] = result
          self.call_scratch.instantiation_results.push(result)
        }
      }
    } else {
      let (base, arguments) = match self.resolved.types[source] {
        AppliedType(base, arguments) => (base, arguments)
        _ => abort("signature instantiation expected an applied type")
      }
      let instantiated_base = self.call_scratch.instantiation_results[result_start]
      self.call_scratch.instantiation_arguments.clear()
      let mut unchanged = instantiated_base == self.solver.resolved_type(base)
      for index in 0..<arguments.length {
        let argument = self.call_scratch.instantiation_results[result_start +
          index +
          1]
        if argument !=
          self.solver.resolved_type(
            self.resolved.type_arguments[arguments.start + index],
          ) {
          unchanged = false
        }
        self.call_scratch.instantiation_arguments.push(argument)
      }
      let result = if unchanged {
        self.solver.resolved_type(source)
      } else {
        self.solver.applied_type(
          instantiated_base,
          self.call_scratch.instantiation_arguments,
        )
      }
      self.call_scratch.instantiation_marks[source] = self.call_scratch.instantiation_generation
      self.call_scratch.instantiation_values[source] = result
      self.call_scratch.instantiation_results.truncate(result_start)
      self.call_scratch.instantiation_results.push(result)
    }
  }
  guard self.call_scratch.instantiation_results.length() == 1 else {
    abort("invalid signature instantiation result")
  }
  self.call_scratch.instantiation_results[0]
}

///|
fn BasicBodyInferencer::inspect_nominal_type(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> Bool {
  self.call_scratch.nominal_arguments.clear()
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyResolvedType(resolved_type) =>
      match self.resolved.types[resolved_type] {
        NominalType(declaration) => {
          self.call_scratch.nominal_declaration = declaration
          true
        }
        AppliedType(base, arguments) =>
          match self.resolved.types[base] {
            NominalType(declaration) => {
              self.call_scratch.nominal_declaration = declaration
              for index in 0..<arguments.length {
                self.call_scratch.nominal_arguments.push(
                  self.solver.resolved_type(
                    self.resolved.type_arguments[arguments.start + index],
                  ),
                )
              }
              true
            }
            _ => false
          }
        _ => false
      }
    BodyAppliedType(base, arguments) =>
      match self.solver.type_term(self.solver.representative_type(base)) {
        BodyResolvedType(resolved_base) =>
          match self.resolved.types[resolved_base] {
            NominalType(declaration) => {
              self.call_scratch.nominal_declaration = declaration
              for index in 0..<arguments.length {
                self.call_scratch.nominal_arguments.push(
                  self.solver.type_arguments[arguments.start + index],
                )
              }
              true
            }
            _ => false
          }
        _ => false
      }
    _ => false
  }
}

///|
fn BasicBodyInferencer::begin_pattern_instantiation(
  self : BasicBodyInferencer,
  declaration : DeclId,
  expected : BodyTypeId,
  pattern : PatternId,
  offset : UInt64,
) -> Unit {
  self.call_scratch.instantiation_self_owner = 0UL
  self.call_scratch.instantiation_self_type = -1
  self.call_scratch.instantiation_generics = self.declaration_generic_parameters(
    declaration,
  )
  self.call_scratch.instantiation_method_generics = { start: 0, length: 0 }
  let has_expected = self.inspect_nominal_type(expected) &&
    self.call_scratch.nominal_declaration == declaration &&
    self.call_scratch.nominal_arguments.length() ==
    self.call_scratch.instantiation_generics.length
  self.call_scratch.candidate_type_arguments.clear()
  if has_expected {
    for type_ in self.call_scratch.nominal_arguments {
      self.call_scratch.candidate_type_arguments.push(type_)
    }
  } else {
    for _ in 0..<self.call_scratch.instantiation_generics.length {
      self.call_scratch.candidate_type_arguments.push(
        self.solver.fresh_variable(),
      )
    }
  }
  self.next_instantiation_generation()
  if has_expected {
    return
  }
  let base = self.solver.resolved_type(self.resolved_nominal_type(declaration))
  let instance = if self.call_scratch.candidate_type_arguments.length() == 0 {
    base
  } else {
    self.solver.applied_type(base, self.call_scratch.candidate_type_arguments)
  }
  self.constrain(expected, instance, pattern_type_origin(pattern, offset))
}

///|
fn BasicBodyInferencer::record_pattern_constructor(
  self : BasicBodyInferencer,
  pattern : PatternId,
  constructor_id : UInt64,
  variant : Bool,
) -> Unit {
  let start = self.pattern_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.pattern_type_arguments.push(type_)
  }
  let arguments = {
    start,
    length: self.call_scratch.candidate_type_arguments.length(),
  }
  self.pattern_constructors[pattern - self.body.patterns.start] = if variant {
    VariantInferredPatternConstructor(constructor_id, arguments)
  } else {
    StructInferredPatternConstructor(constructor_id, arguments)
  }
}

///|
fn BasicBodyInferencer::resolved_nominal_type(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> ResolvedTypeId {
  if semantic_id_module(declaration) == self.collected.module_id {
    return self.resolved.declaration_type(declaration)
  }
  for index, type_ in self.resolved.types {
    match type_ {
      NominalType(candidate) if candidate == declaration => return index
      _ => ()
    }
  }
  self.resolved.error_type
}

///|
fn BasicBodyInferencer::declaration_generic_parameters(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> HirSpan {
  if semantic_id_module(declaration) == self.collected.module_id {
    self.collected.generic_parameters_of(declaration)
  } else {
    match self.imports {
      Some(imports) => imports.generic_parameters_of(declaration)
      None => { start: 0, length: 0 }
    }
  }
}

///|
fn BasicBodyInferencer::begin_expression_instantiation(
  self : BasicBodyInferencer,
  declaration : DeclId,
  expected : BodyTypeId,
  expression : ExprId,
  offset : UInt64,
) -> Unit {
  self.call_scratch.instantiation_self_owner = 0UL
  self.call_scratch.instantiation_self_type = -1
  self.call_scratch.instantiation_generics = self.declaration_generic_parameters(
    declaration,
  )
  self.call_scratch.instantiation_method_generics = { start: 0, length: 0 }
  let has_expected = self.inspect_nominal_type(expected) &&
    self.call_scratch.nominal_declaration == declaration &&
    self.call_scratch.nominal_arguments.length() ==
    self.call_scratch.instantiation_generics.length
  self.call_scratch.candidate_type_arguments.clear()
  if has_expected {
    for type_ in self.call_scratch.nominal_arguments {
      self.call_scratch.candidate_type_arguments.push(type_)
    }
  } else {
    for _ in 0..<self.call_scratch.instantiation_generics.length {
      self.call_scratch.candidate_type_arguments.push(
        self.solver.fresh_variable(),
      )
    }
  }
  self.next_instantiation_generation()
  if has_expected {
    return
  }
  let base = self.solver.resolved_type(self.resolved_nominal_type(declaration))
  let instance = if self.call_scratch.candidate_type_arguments.length() == 0 {
    base
  } else {
    self.solver.applied_type(base, self.call_scratch.candidate_type_arguments)
  }
  self.constrain(expected, instance, expression_type_origin(expression, offset))
}

///|
fn BasicBodyInferencer::record_expression_selection(
  self : BasicBodyInferencer,
  expression : ExprId,
  selected_id : UInt64,
  kind : Int,
) -> Unit {
  let start = self.expression_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.expression_type_arguments.push(type_)
  }
  let arguments = {
    start,
    length: self.call_scratch.candidate_type_arguments.length(),
  }
  self.expression_selections[self.expression_index(expression)] = match kind {
    0 => StructConstructionSelection(selected_id, arguments)
    1 => VariantConstructionSelection(selected_id, arguments)
    _ => UnitVariantValueSelection(selected_id, arguments)
  }
}

///|
fn BasicBodyInferencer::consume_member_root(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Unit {
  let index = self.expression_index(expression)
  self.consumed_member_roots[index] = true
  self.unsupported_expressions[index] = false
  match self.collected.expressions[expression] {
    HirQualifiedExpr(base, _, _) => self.consume_member_root(base)
    _ => ()
  }
}

///|
fn BasicBodyInferencer::type_is_error(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> Bool {
  match self.solver.type_term(self.solver.representative_type(type_)) {
    BodyErrorType => true
    _ => false
  }
}

///|
fn BasicBodyInferencer::type_is_variable(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> Bool {
  match self.solver.type_term(self.solver.representative_type(type_)) {
    BodyVariableType(_) => true
    _ => false
  }
}

///|
fn BasicBodyInferencer::object_field_index(
  self : BasicBodyInferencer,
  field : Int,
) -> Int {
  field - self.body.object_fields.start
}

///|
fn BasicBodyInferencer::collect_owned_fields(
  self : BasicBodyInferencer,
  declaration : DeclId,
  variant : VariantId?,
) -> Unit {
  self.call_scratch.pattern_field_indices.clear()
  self.call_scratch.pattern_field_matched.clear()
  self.call_scratch.pattern_field_lookup.clear()
  let declaration_index = semantic_id_local(declaration)
  let span = if declaration_index < 0 ||
    declaration_index >= self.field_spans.length() {
    { start: 0, length: 0 }
  } else {
    self.field_spans[declaration_index]
  }
  for index in span.start..<(span.start + span.length) {
    let field = self.collected.fields[index]
    if field.variant == variant {
      let slot = self.call_scratch.pattern_field_indices.length()
      self.call_scratch.pattern_field_indices.push(index)
      self.call_scratch.pattern_field_matched.push(false)
      if slot >= 8 {
        self.call_scratch.pattern_field_lookup[field.name] = slot
      }
    }
  }
  if self.call_scratch.pattern_field_indices.length() > 8 {
    for slot in 0..<8 {
      let field_index = self.call_scratch.pattern_field_indices[slot]
      self.call_scratch.pattern_field_lookup[self.collected.fields[field_index].name] = slot
    }
  }
}

///|
fn BasicBodyInferencer::owned_field_slot(
  self : BasicBodyInferencer,
  name : NameId,
) -> Int {
  if self.call_scratch.pattern_field_indices.length() > 8 {
    return self.call_scratch.pattern_field_lookup.get(name).unwrap_or(-1)
  }
  for slot, field_index in self.call_scratch.pattern_field_indices {
    if self.collected.fields[field_index].name == name {
      return slot
    }
  }
  -1
}

///|
fn BasicBodyInferencer::constrain_imported_object_fields(
  self : BasicBodyInferencer,
  expression : ExprId,
  fields : HirSpan,
  declaration : DeclId,
  variant : VariantId?,
  offset : UInt64,
) -> Unit {
  let imports = self.imports.unwrap()
  let declared = imports.fields_of(declaration)
  let matched = Array::make(declared.length(), false)
  for index in 0..<fields.length {
    let object_field_index = fields.start + index
    let object_field = self.collected.object_fields[object_field_index]
    let spelling = self.collected.name(object_field.name)
    let mut selected = -1
    for candidate in 0..<declared.length() {
      if declared[candidate].variant == variant &&
        declared[candidate].name == spelling {
        selected = candidate
        break
      }
    }
    if selected < 0 {
      self.object_field_targets[self.object_field_index(object_field_index)] = ErrorObjectFieldTarget
      self.diagnose(
        UnknownConstructionField(
          object_field.name,
          expression,
          object_field.offset,
        ),
      )
      continue
    }
    if matched[selected] {
      let mut first_offset = object_field.offset
      for previous in 0..<index {
        let previous_field = self.collected.object_fields[fields.start +
          previous]
        if previous_field.name == object_field.name {
          first_offset = previous_field.offset
          break
        }
      }
      self.object_field_targets[self.object_field_index(object_field_index)] = ErrorObjectFieldTarget
      self.diagnose(
        DuplicateConstructionField(
          object_field.name,
          first_offset,
          object_field.offset,
        ),
      )
      continue
    }
    matched[selected] = true
    self.object_field_targets[self.object_field_index(object_field_index)] = SelectedObjectFieldTarget(
      declared[selected].field,
    )
    let expected = self.instantiate_signature_type(declared[selected].type_)
    self.constrain_assignable(
      self.expression_type(object_field.value),
      expected,
      expression_type_origin(object_field.value, object_field.offset),
    )
  }
  for candidate in 0..<declared.length() {
    if declared[candidate].variant != variant || matched[candidate] {
      continue
    }
    self.diagnose(
      MissingConstructionField(
        self.collected.find_name(declared[candidate].name).unwrap_or(-1),
        expression,
        offset,
      ),
    )
  }
}

///|
fn BasicBodyInferencer::constrain_object_fields(
  self : BasicBodyInferencer,
  expression : ExprId,
  fields : HirSpan,
  declaration : DeclId,
  variant : VariantId?,
  offset : UInt64,
) -> Unit {
  if semantic_id_module(declaration) != self.collected.module_id {
    self.constrain_imported_object_fields(
      expression, fields, declaration, variant, offset,
    )
    return
  }
  self.collect_owned_fields(declaration, variant)
  for index in 0..<fields.length {
    let object_field_index = fields.start + index
    let object_field = self.collected.object_fields[object_field_index]
    let slot = self.owned_field_slot(object_field.name)
    if slot < 0 {
      self.object_field_targets[self.object_field_index(object_field_index)] = ErrorObjectFieldTarget
      self.diagnose(
        UnknownConstructionField(
          object_field.name,
          expression,
          object_field.offset,
        ),
      )
      continue
    }
    let field_index = self.call_scratch.pattern_field_indices[slot]
    let selected_field = self.collected.fields[field_index]
    if self.call_scratch.pattern_field_matched[slot] {
      let mut first_offset = object_field.offset
      for previous in 0..<index {
        let previous_field = self.collected.object_fields[fields.start +
          previous]
        if previous_field.name == object_field.name {
          first_offset = previous_field.offset
          break
        }
      }
      self.object_field_targets[self.object_field_index(object_field_index)] = ErrorObjectFieldTarget
      self.diagnose(
        DuplicateConstructionField(
          object_field.name,
          first_offset,
          object_field.offset,
        ),
      )
      continue
    }
    self.call_scratch.pattern_field_matched[slot] = true
    self.object_field_targets[self.object_field_index(object_field_index)] = SelectedObjectFieldTarget(
      selected_field.id,
    )
    let expected = self.instantiate_signature_type(
      self.resolved.field_types[field_index],
    )
    self.constrain_assignable(
      self.expression_type(object_field.value),
      expected,
      expression_type_origin(object_field.value, object_field.offset),
    )
  }
  for slot in 0..<self.call_scratch.pattern_field_indices.length() {
    if !self.call_scratch.pattern_field_matched[slot] {
      let field_index = self.call_scratch.pattern_field_indices[slot]
      self.diagnose(
        MissingConstructionField(
          self.collected.fields[field_index].name,
          expression,
          offset,
        ),
      )
    }
  }
}

///|
fn BasicBodyInferencer::variant_index_in_declaration(
  self : BasicBodyInferencer,
  declaration : DeclId,
  name : NameId,
) -> Int {
  let local_index = semantic_id_local(declaration)
  if local_index < 0 || local_index >= self.variant_spans.length() {
    return -1
  }
  let span = self.variant_spans[local_index]
  for index in span.start..<(span.start + span.length) {
    if self.collected.variants[index].name == name {
      return index
    }
  }
  -1
}

///|
fn BasicBodyInferencer::variant_kind(
  self : BasicBodyInferencer,
  variant : VariantId,
) -> CollectedVariantKind? {
  if semantic_id_module(variant) == self.collected.module_id {
    let index = semantic_id_local(variant)
    if index >= 0 && index < self.collected.variants.length() {
      return Some(self.collected.variants[index].kind)
    }
  } else {
    match self.imports {
      Some(imports) =>
        match imports.variant(variant) {
          Some(imported) => return Some(imported.kind)
          None => ()
        }
      None => ()
    }
  }
  None
}

///|
fn BasicBodyInferencer::variant_declaration(
  self : BasicBodyInferencer,
  variant : VariantId,
) -> DeclId? {
  if semantic_id_module(variant) == self.collected.module_id {
    let index = semantic_id_local(variant)
    if index >= 0 && index < self.collected.variants.length() {
      return Some(self.collected.variants[index].declaration)
    }
  } else {
    match self.imports {
      Some(imports) =>
        match imports.variant(variant) {
          Some(imported) => return Some(imported.declaration)
          None => ()
        }
      None => ()
    }
  }
  None
}

///|
fn BasicBodyInferencer::variant_payload_length(
  self : BasicBodyInferencer,
  variant : VariantId,
) -> Int {
  if semantic_id_module(variant) == self.collected.module_id {
    let index = semantic_id_local(variant)
    if index >= 0 && index < self.resolved.variant_payloads.length() {
      return self.resolved.variant_payloads[index].length
    }
  } else {
    match self.imports {
      Some(imports) =>
        match imports.variant(variant) {
          Some(imported) => return imported.payload_types.length
          None => ()
        }
      None => ()
    }
  }
  0
}

///|
fn BasicBodyInferencer::variant_payload_type(
  self : BasicBodyInferencer,
  variant : VariantId,
  index : Int,
) -> ResolvedTypeId {
  if semantic_id_module(variant) == self.collected.module_id {
    let local_index = semantic_id_local(variant)
    let payload = self.resolved.variant_payloads[local_index]
    return self.resolved.signature_type_lists[payload.start + index]
  }
  match self.imports {
    Some(imports) => {
      let imported = imports.variant(variant).unwrap()
      imports.variant_payload_types[imported.payload_types.start + index]
    }
    None => self.resolved.error_type
  }
}

///|
fn BasicBodyInferencer::select_value_variant(
  self : BasicBodyInferencer,
  name : NameId,
  expected : BodyTypeId,
  expression : ExprId,
  offset : UInt64,
) -> Int {
  if self.inspect_nominal_type(expected) {
    let selected = self.variant_index_in_declaration(
      self.call_scratch.nominal_declaration,
      name,
    )
    if selected < 0 {
      self.diagnose(UnknownVariantValue(name, expression, offset))
    }
    return selected
  }
  let mut first = -1
  let mut second = -1
  let mut count = 0
  for index, variant in self.collected.variants {
    if variant.name == name {
      count += 1
      if first < 0 {
        first = index
      } else if second < 0 {
        second = index
      }
    }
  }
  if count == 1 {
    first
  } else if count == 0 {
    self.diagnose(UnknownVariantValue(name, expression, offset))
    -1
  } else {
    self.diagnose(
      AmbiguousVariantValue(
        name,
        expression,
        self.collected.variants[first].id,
        self.collected.variants[second].id,
        count,
        offset,
      ),
    )
    -1
  }
}

///|
fn BasicBodyInferencer::select_bare_variant(
  self : BasicBodyInferencer,
  name : NameId,
  expected : BodyTypeId,
  pattern : PatternId,
  offset : UInt64,
) -> Int {
  if self.inspect_nominal_type(expected) {
    let declaration = self.call_scratch.nominal_declaration
    let selected = self.variant_index_in_declaration(declaration, name)
    if selected < 0 {
      self.diagnose(UnknownVariantForType(name, declaration, pattern, offset))
    }
    return selected
  }
  let mut selected = -1
  let mut count = 0
  let mut first = 0UL
  let mut second = 0UL
  for index, variant in self.collected.variants {
    if variant.name == name {
      count += 1
      if count == 1 {
        selected = index
        first = variant.id
      } else if count == 2 {
        second = variant.id
      }
    }
  }
  if count == 1 {
    selected
  } else {
    if count > 1 {
      self.diagnose(
        AmbiguousPatternVariant(name, pattern, first, second, count, offset),
      )
    } else {
      self.diagnose(InvalidPatternConstructor(pattern, offset))
    }
    -1
  }
}

///|
fn BasicBodyInferencer::select_variant_base(
  self : BasicBodyInferencer,
  base : PatternId,
  expected : BodyTypeId,
  owner_pattern : PatternId,
  offset : UInt64,
) -> VariantId? {
  self.pattern_types[base - self.body.patterns.start] = expected
  match self.collected.patterns[base] {
    HirBindingPattern(name, _) =>
      match self.names.pattern_references[base] {
        PatternVariantReference(_) => {
          let selected = self.select_bare_variant(
            name, expected, owner_pattern, offset,
          )
          if selected >= 0 {
            Some(self.collected.variants[selected].id)
          } else {
            None
          }
        }
        _ => {
          self.diagnose(InvalidPatternConstructor(owner_pattern, offset))
          None
        }
      }
    HirQualifiedPattern(root, property, _) => {
      self.pattern_types[root - self.body.patterns.start] = expected
      match self.names.pattern_references[root] {
        PatternTypeReference(declaration) =>
          if semantic_id_module(declaration) == self.collected.module_id {
            let selected = self.variant_index_in_declaration(
              declaration, property,
            )
            if selected < 0 {
              self.diagnose(
                UnknownVariantForType(
                  property, declaration, owner_pattern, offset,
                ),
              )
              None
            } else {
              Some(self.collected.variants[selected].id)
            }
          } else {
            match self.imported_variant_named(declaration, property) {
              Some(variant) => Some(variant.variant)
              None => {
                self.diagnose(
                  UnknownVariantForType(
                    property, declaration, owner_pattern, offset,
                  ),
                )
                None
              }
            }
          }
        _ => {
          self.diagnose(InvalidPatternConstructor(owner_pattern, offset))
          None
        }
      }
    }
    _ => {
      self.diagnose(InvalidPatternConstructor(owner_pattern, offset))
      None
    }
  }
}

///|
fn BasicBodyInferencer::push_pattern_task(
  self : BasicBodyInferencer,
  pattern : PatternId,
  expected : BodyTypeId,
) -> Unit {
  self.call_scratch.pattern_tasks.push(pattern)
  self.call_scratch.pattern_task_types.push(expected)
}

///|
fn BasicBodyInferencer::infer_tuple_variant_pattern(
  self : BasicBodyInferencer,
  pattern : PatternId,
  base : PatternId,
  arguments : HirSpan,
  expected : BodyTypeId,
  offset : UInt64,
) -> Unit {
  let variant = match
    self.select_variant_base(base, expected, pattern, offset) {
    Some(variant) => variant
    None => {
      self.pattern_constructors[pattern - self.body.patterns.start] = ErrorInferredPatternConstructor
      return
    }
  }
  if self.variant_kind(variant) != Some(TupleVariantDecl) {
    self.diagnose(PatternPayloadKindMismatch(pattern, variant, offset))
    self.pattern_constructors[pattern - self.body.patterns.start] = ErrorInferredPatternConstructor
    return
  }
  let declaration = self.variant_declaration(variant).unwrap()
  self.begin_pattern_instantiation(declaration, expected, pattern, offset)
  self.record_pattern_constructor(pattern, variant, true)
  let payload_length = self.variant_payload_length(variant)
  let mut rest_index = -1
  let mut explicit_count = 0
  for index in 0..<arguments.length {
    let child = self.collected.pattern_children[arguments.start + index]
    match self.collected.patterns[child] {
      HirRestPattern(_) => rest_index = index
      _ => explicit_count += 1
    }
  }
  if (rest_index < 0 && explicit_count != payload_length) ||
    (rest_index >= 0 && explicit_count > payload_length) {
    self.diagnose(
      PatternPayloadArityMismatch(
        pattern, payload_length, explicit_count, offset,
      ),
    )
  }
  let mut before = 0
  let mut after = 0
  for index in 0..<arguments.length {
    let child = self.collected.pattern_children[arguments.start + index]
    match self.collected.patterns[child] {
      HirRestPattern(_) =>
        self.pattern_types[child - self.body.patterns.start] = self.solver.error_type()
      _ => {
        let payload_index = if rest_index < 0 || index < rest_index {
          let result = before
          before += 1
          result
        } else {
          let result = payload_length - (explicit_count - before) + after
          after += 1
          result
        }
        if payload_index >= 0 && payload_index < payload_length {
          self.push_pattern_task(
            child,
            self.instantiate_signature_type(
              self.variant_payload_type(variant, payload_index),
            ),
          )
        } else {
          self.push_pattern_task(child, self.solver.error_type())
        }
      }
    }
  }
}

///|
fn BasicBodyInferencer::field_matches_owner(
  _self : BasicBodyInferencer,
  field : CollectedField,
  declaration : DeclId,
  variant : VariantId?,
) -> Bool {
  field.declaration == declaration && field.variant == variant
}

///|
fn BasicBodyInferencer::infer_imported_struct_payload_pattern(
  self : BasicBodyInferencer,
  pattern : PatternId,
  declaration : DeclId,
  variant : VariantId?,
  fields : HirSpan,
  has_rest : Bool,
  expected : BodyTypeId,
  offset : UInt64,
) -> Unit {
  let imports = match self.imports {
    Some(imports) => imports
    None => {
      self.pattern_constructors[pattern - self.body.patterns.start] = ErrorInferredPatternConstructor
      return
    }
  }
  self.begin_pattern_instantiation(declaration, expected, pattern, offset)
  match variant {
    Some(variant_id) =>
      self.record_pattern_constructor(pattern, variant_id, true)
    None => self.record_pattern_constructor(pattern, declaration, false)
  }
  let imported_fields = imports.fields_of(declaration)
  let candidate_indices : Array[Int] = []
  for index, field in imported_fields {
    if field.variant == variant {
      candidate_indices.push(index)
    }
  }
  let matched = Array::make(candidate_indices.length(), false)
  for index in 0..<fields.length {
    let pattern_field = self.collected.pattern_fields[fields.start + index]
    let name = self.collected.name(pattern_field.name)
    let mut selected = -1
    for candidate in 0..<candidate_indices.length() {
      if imported_fields[candidate_indices[candidate]].name == name {
        selected = candidate
        break
      }
    }
    if selected < 0 {
      self.diagnose(
        UnknownPatternField(pattern_field.name, pattern, pattern_field.offset),
      )
      self.push_pattern_task(pattern_field.pattern, self.solver.error_type())
    } else {
      matched[selected] = true
      self.push_pattern_task(
        pattern_field.pattern,
        self.instantiate_signature_type(
          imported_fields[candidate_indices[selected]].type_,
        ),
      )
    }
  }
  if !has_rest {
    for index in 0..<candidate_indices.length() {
      if !matched[index] {
        let field = imported_fields[candidate_indices[index]]
        self.diagnose(MissingImportedPatternField(field.name, pattern, offset))
      }
    }
  }
}

///|
fn BasicBodyInferencer::infer_struct_payload_pattern(
  self : BasicBodyInferencer,
  pattern : PatternId,
  declaration : DeclId,
  variant : VariantId?,
  fields : HirSpan,
  has_rest : Bool,
  expected : BodyTypeId,
  offset : UInt64,
) -> Unit {
  if semantic_id_module(declaration) != self.collected.module_id {
    self.infer_imported_struct_payload_pattern(
      pattern, declaration, variant, fields, has_rest, expected, offset,
    )
    return
  }
  self.begin_pattern_instantiation(declaration, expected, pattern, offset)
  match variant {
    Some(variant_id) =>
      self.record_pattern_constructor(pattern, variant_id, true)
    None => self.record_pattern_constructor(pattern, declaration, false)
  }
  self.call_scratch.pattern_field_indices.clear()
  self.call_scratch.pattern_field_matched.clear()
  self.call_scratch.pattern_field_lookup.clear()
  for index, field in self.collected.fields {
    if self.field_matches_owner(field, declaration, variant) {
      self.call_scratch.pattern_field_indices.push(index)
      self.call_scratch.pattern_field_matched.push(false)
    }
  }
  if self.call_scratch.pattern_field_indices.length() > 8 {
    for candidate in 0..<self.call_scratch.pattern_field_indices.length() {
      let field_index = self.call_scratch.pattern_field_indices[candidate]
      self.call_scratch.pattern_field_lookup[self.collected.fields[field_index].name] = candidate
    }
  }
  for index in 0..<fields.length {
    let pattern_field = self.collected.pattern_fields[fields.start + index]
    let mut selected = if self.call_scratch.pattern_field_indices.length() > 8 {
      self.call_scratch.pattern_field_lookup
      .get(pattern_field.name)
      .unwrap_or(-1)
    } else {
      -1
    }
    if self.call_scratch.pattern_field_indices.length() <= 8 {
      for candidate in 0..<self.call_scratch.pattern_field_indices.length() {
        if self.collected.fields[self.call_scratch.pattern_field_indices[candidate]].name ==
          pattern_field.name {
          selected = candidate
          break
        }
      }
    }
    if selected < 0 {
      self.diagnose(
        UnknownPatternField(pattern_field.name, pattern, pattern_field.offset),
      )
      self.push_pattern_task(pattern_field.pattern, self.solver.error_type())
    } else {
      self.call_scratch.pattern_field_matched[selected] = true
      self.push_pattern_task(
        pattern_field.pattern,
        self.instantiate_signature_type(
          self.resolved.field_types[self.call_scratch.pattern_field_indices[selected]],
        ),
      )
    }
  }
  if !has_rest {
    for index in 0..<self.call_scratch.pattern_field_indices.length() {
      if !self.call_scratch.pattern_field_matched[index] {
        let field = self.collected.fields[self.call_scratch.pattern_field_indices[index]]
        self.diagnose(MissingPatternField(field.name, pattern, offset))
      }
    }
  }
}

///|
fn BasicBodyInferencer::infer_struct_pattern(
  self : BasicBodyInferencer,
  pattern : PatternId,
  base : PatternId,
  fields : HirSpan,
  has_rest : Bool,
  expected : BodyTypeId,
  offset : UInt64,
) -> Unit {
  self.pattern_types[base - self.body.patterns.start] = expected
  match self.names.pattern_references[base] {
    PatternTypeReference(declaration) => {
      let is_struct = if semantic_id_module(declaration) ==
        self.collected.module_id {
        match self.collected.declaration(declaration) {
          Some(TopLevelReference({ kind: StructDecl, .. })) => true
          _ => false
        }
      } else {
        match self.imports {
          Some(imports) => imports.is_struct(declaration)
          None => false
        }
      }
      if is_struct {
        self.infer_struct_payload_pattern(
          pattern,
          declaration,
          None,
          fields,
          has_rest,
          expected,
          offset,
        )
      } else {
        self.diagnose(InvalidPatternConstructor(pattern, offset))
        self.pattern_constructors[pattern - self.body.patterns.start] = ErrorInferredPatternConstructor
      }
    }
    _ => {
      let variant = match
        self.select_variant_base(base, expected, pattern, offset) {
        Some(variant) => variant
        None => {
          self.pattern_constructors[pattern - self.body.patterns.start] = ErrorInferredPatternConstructor
          return
        }
      }
      if self.variant_kind(variant) != Some(StructVariantDecl) {
        self.diagnose(PatternPayloadKindMismatch(pattern, variant, offset))
        self.pattern_constructors[pattern - self.body.patterns.start] = ErrorInferredPatternConstructor
        return
      }
      self.infer_struct_payload_pattern(
        pattern,
        self.variant_declaration(variant).unwrap(),
        Some(variant),
        fields,
        has_rest,
        expected,
        offset,
      )
    }
  }
}

///|
fn BasicBodyInferencer::infer_unit_constructor_pattern(
  self : BasicBodyInferencer,
  pattern : PatternId,
  expected : BodyTypeId,
  offset : UInt64,
) -> Unit {
  let variant = match
    self.select_variant_base(pattern, expected, pattern, offset) {
    Some(variant) => variant
    None => {
      self.pattern_constructors[pattern - self.body.patterns.start] = ErrorInferredPatternConstructor
      return
    }
  }
  if self.variant_kind(variant) != Some(UnitVariantDecl) {
    self.diagnose(PatternPayloadKindMismatch(pattern, variant, offset))
    self.pattern_constructors[pattern - self.body.patterns.start] = ErrorInferredPatternConstructor
    return
  }
  self.begin_pattern_instantiation(
    self.variant_declaration(variant).unwrap(),
    expected,
    pattern,
    offset,
  )
  self.record_pattern_constructor(pattern, variant, true)
}

///|
fn BasicBodyInferencer::infer_pattern(
  self : BasicBodyInferencer,
  root : PatternId,
  expected : BodyTypeId,
) -> Unit {
  self.call_scratch.pattern_tasks.clear()
  self.call_scratch.pattern_task_types.clear()
  self.push_pattern_task(root, expected)
  while self.call_scratch.pattern_tasks.length() > 0 {
    let pattern = self.call_scratch.pattern_tasks.pop().unwrap()
    let expected = self.call_scratch.pattern_task_types.pop().unwrap()
    self.pattern_types[pattern - self.body.patterns.start] = expected
    match self.collected.patterns[pattern] {
      HirWildcardPattern(_) => ()
      HirRestPattern(_) =>
        self.pattern_types[pattern - self.body.patterns.start] = self.solver.error_type()
      HirBindingPattern(_, offset) =>
        match self.names.pattern_references[pattern] {
          PatternBindingReference(local_id) =>
            self.constrain(
              self.local_types[local_id],
              expected,
              pattern_type_origin(pattern, offset),
            )
          PatternVariantReference(_) =>
            self.infer_unit_constructor_pattern(pattern, expected, offset)
          ErrorPatternReference =>
            self.pattern_types[pattern - self.body.patterns.start] = self.solver.error_type()
          _ => self.diagnose(InvalidPatternConstructor(pattern, offset))
        }
      HirLiteralPattern(expression, offset) =>
        self.constrain(
          self.expression_type(expression),
          expected,
          pattern_type_origin(pattern, offset),
        )
      HirQualifiedPattern(_, _, offset) =>
        self.infer_unit_constructor_pattern(pattern, expected, offset)
      HirTuplePattern(base, arguments, offset) =>
        self.infer_tuple_variant_pattern(
          pattern, base, arguments, expected, offset,
        )
      HirStructPattern(base, fields, has_rest, _, offset) =>
        self.infer_struct_pattern(
          pattern, base, fields, has_rest, expected, offset,
        )
      HirAlternativePattern(first, remaining, _) => {
        let mut index = remaining.length
        while index > 0 {
          index -= 1
          self.push_pattern_task(
            self.collected.pattern_children[remaining.start + index],
            expected,
          )
        }
        self.push_pattern_task(first, expected)
      }
    }
  }
}

///|
fn BasicBodyInferencer::fail_expression_selection(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Unit {
  self.expression_selections[self.expression_index(expression)] = ErrorExpressionSelection
  self.poison_expression(expression)
}

///|
fn BasicBodyInferencer::declaration_is_struct(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Bool {
  if semantic_id_module(declaration) == self.collected.module_id {
    match self.collected.declaration(declaration) {
      Some(TopLevelReference({ kind: StructDecl, .. })) => true
      _ => false
    }
  } else {
    match self.imports {
      Some(imports) => imports.is_struct(declaration)
      None => false
    }
  }
}

///|
fn BasicBodyInferencer::select_struct_construction(
  self : BasicBodyInferencer,
  expression : ExprId,
  fields : HirSpan,
  declaration : DeclId,
  offset : UInt64,
) -> Unit {
  self.begin_expression_instantiation(
    declaration,
    self.expression_type(expression),
    expression,
    offset,
  )
  self.constrain_object_fields(expression, fields, declaration, None, offset)
  self.record_expression_selection(expression, declaration, 0)
}

///|
fn BasicBodyInferencer::select_variant_construction(
  self : BasicBodyInferencer,
  expression : ExprId,
  fields : HirSpan,
  variant_index : Int,
  offset : UInt64,
) -> Unit {
  let variant = self.collected.variants[variant_index]
  if variant.kind != StructVariantDecl {
    self.diagnose(
      ConstructionPayloadKindMismatch(expression, variant.id, offset),
    )
    self.fail_expression_selection(expression)
    return
  }
  self.begin_expression_instantiation(
    variant.declaration,
    self.expression_type(expression),
    expression,
    offset,
  )
  self.constrain_object_fields(
    expression,
    fields,
    variant.declaration,
    Some(variant.id),
    offset,
  )
  self.record_expression_selection(expression, variant.id, 1)
}

///|
fn BasicBodyInferencer::infer_tuple_variant_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  variant_index : Int,
  offset : UInt64,
) -> Unit {
  let variant = self.collected.variants[variant_index]
  if variant.kind != TupleVariantDecl {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.diagnose(
      ConstructionPayloadKindMismatch(expression, variant.id, offset),
    )
    self.fail_expression_selection(expression)
    return
  }
  let payload = self.resolved.variant_payloads[variant_index]
  if payload.length != arguments.length {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.diagnose(
      ConstructionPayloadArityMismatch(
        expression,
        variant.id,
        payload.length,
        arguments.length,
        offset,
      ),
    )
    self.fail_expression_selection(expression)
    return
  }
  self.begin_expression_instantiation(
    variant.declaration,
    self.expression_type(expression),
    expression,
    offset,
  )
  for index in 0..<arguments.length {
    let expected = self.instantiate_signature_type(
      self.resolved.signature_type_lists[payload.start + index],
    )
    let argument = self.collected.expression_children[arguments.start + index]
    self.constrain_assignable(
      self.expression_type(argument),
      expected,
      expression_type_origin(argument, offset),
    )
  }
  self.record_expression_selection(expression, variant.id, 1)
}

///|
fn BasicBodyInferencer::infer_unit_variant_value(
  self : BasicBodyInferencer,
  expression : ExprId,
  variant_index : Int,
  offset : UInt64,
) -> Unit {
  let variant = self.collected.variants[variant_index]
  if variant.kind != UnitVariantDecl {
    self.diagnose(
      ConstructionPayloadKindMismatch(expression, variant.id, offset),
    )
    self.fail_expression_selection(expression)
    return
  }
  self.begin_expression_instantiation(
    variant.declaration,
    self.expression_type(expression),
    expression,
    offset,
  )
  self.record_expression_selection(expression, variant.id, 2)
}

///|
fn BasicBodyInferencer::imported_variant_named(
  self : BasicBodyInferencer,
  declaration : DeclId,
  name : NameId,
) -> ResolvedImportedVariant? {
  match self.imports {
    Some(imports) =>
      imports.variant_named(declaration, self.collected.name(name))
    None => None
  }
}

///|
fn BasicBodyInferencer::select_imported_variant_construction(
  self : BasicBodyInferencer,
  expression : ExprId,
  fields : HirSpan,
  variant : ResolvedImportedVariant,
  offset : UInt64,
) -> Unit {
  if variant.kind != StructVariantDecl {
    self.diagnose(
      ConstructionPayloadKindMismatch(expression, variant.variant, offset),
    )
    self.fail_expression_selection(expression)
    return
  }
  self.begin_expression_instantiation(
    variant.declaration,
    self.expression_type(expression),
    expression,
    offset,
  )
  self.constrain_object_fields(
    expression,
    fields,
    variant.declaration,
    Some(variant.variant),
    offset,
  )
  self.record_expression_selection(expression, variant.variant, 1)
}

///|
fn BasicBodyInferencer::infer_imported_tuple_variant_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  variant : ResolvedImportedVariant,
  offset : UInt64,
) -> Unit {
  if variant.kind != TupleVariantDecl {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.diagnose(
      ConstructionPayloadKindMismatch(expression, variant.variant, offset),
    )
    self.fail_expression_selection(expression)
    return
  }
  let payload = match self.imports {
    Some(imports) => imports.variant_payload(variant)
    None => return
  }
  if payload.length() != arguments.length {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.diagnose(
      ConstructionPayloadArityMismatch(
        expression,
        variant.variant,
        payload.length(),
        arguments.length,
        offset,
      ),
    )
    self.fail_expression_selection(expression)
    return
  }
  self.begin_expression_instantiation(
    variant.declaration,
    self.expression_type(expression),
    expression,
    offset,
  )
  for index in 0..<arguments.length {
    let expected = self.instantiate_signature_type(payload[index])
    let argument = self.collected.expression_children[arguments.start + index]
    self.constrain_assignable(
      self.expression_type(argument),
      expected,
      expression_type_origin(argument, offset),
    )
  }
  self.record_expression_selection(expression, variant.variant, 1)
}

///|
fn BasicBodyInferencer::infer_imported_unit_variant_value(
  self : BasicBodyInferencer,
  expression : ExprId,
  variant : ResolvedImportedVariant,
  offset : UInt64,
) -> Unit {
  if variant.kind != UnitVariantDecl {
    self.diagnose(
      ConstructionPayloadKindMismatch(expression, variant.variant, offset),
    )
    self.fail_expression_selection(expression)
    return
  }
  self.begin_expression_instantiation(
    variant.declaration,
    self.expression_type(expression),
    expression,
    offset,
  )
  self.record_expression_selection(expression, variant.variant, 2)
}

///|
fn BasicBodyInferencer::infer_construct_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
  target : ExprId,
  fields : HirSpan,
  offset : UInt64,
) -> Unit {
  self.consume_member_root(target)
  match self.collected.expressions[target] {
    HirNameExpr(_, _) =>
      match self.names.expression_references[target] {
        ModuleTypeNameReference(declaration) =>
          if self.declaration_is_struct(declaration) {
            self.select_struct_construction(
              expression, fields, declaration, offset,
            )
          } else {
            self.diagnose(InvalidConstructionTarget(expression, offset))
            self.fail_expression_selection(expression)
          }
        _ => {
          self.diagnose(InvalidConstructionTarget(expression, offset))
          self.fail_expression_selection(expression)
        }
      }
    HirQualifiedExpr(base, property, _) =>
      match self.collected.expressions[base] {
        HirNameExpr(_, _) =>
          match self.names.expression_references[base] {
            ModuleTypeNameReference(declaration) =>
              if semantic_id_module(declaration) == self.collected.module_id {
                let variant_index = self.variant_index_in_declaration(
                  declaration, property,
                )
                if variant_index < 0 {
                  self.diagnose(
                    UnknownQualifiedMember(
                      property, declaration, expression, offset,
                    ),
                  )
                  self.fail_expression_selection(expression)
                } else {
                  self.select_variant_construction(
                    expression, fields, variant_index, offset,
                  )
                }
              } else {
                match self.imported_variant_named(declaration, property) {
                  Some(variant) =>
                    self.select_imported_variant_construction(
                      expression, fields, variant, offset,
                    )
                  None => {
                    self.diagnose(
                      UnknownQualifiedMember(
                        property, declaration, expression, offset,
                      ),
                    )
                    self.fail_expression_selection(expression)
                  }
                }
              }
            _ => {
              self.diagnose(InvalidConstructionTarget(expression, offset))
              self.fail_expression_selection(expression)
            }
          }
        _ => {
          self.diagnose(InvalidConstructionTarget(expression, offset))
          self.fail_expression_selection(expression)
        }
      }
    _ => {
      self.diagnose(InvalidConstructionTarget(expression, offset))
      self.fail_expression_selection(expression)
    }
  }
}

///|
fn BasicBodyInferencer::infer_qualified_value(
  self : BasicBodyInferencer,
  expression : ExprId,
  base : ExprId,
  property : NameId,
  offset : UInt64,
) -> Unit {
  if self.consumed_member_roots[self.expression_index(expression)] {
    return
  }
  match self.collected.expressions[base] {
    HirImportAliasExpr(_, _) =>
      match self.names.expression_references[base] {
        ImportedModuleNameReference(interface_index) => {
          self.consume_member_root(base)
          let declaration = match self.imports {
            Some(imports) =>
              imports.scope.lookup_module_value(
                interface_index,
                self.collected.name(property),
              )
            None => None
          }
          match declaration {
            Some(value) =>
              match self.imports.unwrap().module_value_type(value) {
                Some(type_) => {
                  self.constrain(
                    self.expression_type(expression),
                    self.solver.resolved_type(type_),
                    expression_type_origin(expression, offset),
                  )
                  self.expression_selections[self.expression_index(expression)] = ImportedModuleValueSelection(
                    value,
                  )
                }
                None => self.mark_unsupported(expression)
              }
            None => self.mark_unsupported(expression)
          }
        }
        _ => self.mark_unsupported(expression)
      }
    HirNameExpr(_, _) =>
      match self.names.expression_references[base] {
        ModuleTypeNameReference(declaration) => {
          self.consume_member_root(base)
          if semantic_id_module(declaration) == self.collected.module_id {
            let variant_index = self.variant_index_in_declaration(
              declaration, property,
            )
            if variant_index < 0 {
              self.diagnose(
                UnknownQualifiedMember(
                  property, declaration, expression, offset,
                ),
              )
              self.fail_expression_selection(expression)
              return
            }
            self.infer_unit_variant_value(expression, variant_index, offset)
          } else {
            match self.imported_variant_named(declaration, property) {
              Some(variant) =>
                self.infer_imported_unit_variant_value(
                  expression, variant, offset,
                )
              None => {
                self.diagnose(
                  UnknownQualifiedMember(
                    property, declaration, expression, offset,
                  ),
                )
                self.fail_expression_selection(expression)
              }
            }
          }
        }
        _ => {
          self.mark_unsupported(expression)
          self.consume_member_root(base)
        }
      }
    _ => self.mark_unsupported(expression)
  }
}

///|
fn BasicBodyInferencer::try_infer_object_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
  fields : HirSpan,
  offset : UInt64,
) -> Bool {
  let expected = self.expression_type(expression)
  if self.type_is_error(expected) {
    self.fail_expression_selection(expression)
    return true
  }
  if !self.inspect_nominal_type(expected) {
    if self.type_is_variable(expected) {
      return false
    }
    self.diagnose(ObjectTypeRequired(expression, offset))
    self.fail_expression_selection(expression)
    return true
  }
  let declaration = self.call_scratch.nominal_declaration
  if self.declaration_is_struct(declaration) {
    self.select_struct_construction(expression, fields, declaration, offset)
    true
  } else {
    self.diagnose(ObjectTypeRequired(expression, offset))
    self.fail_expression_selection(expression)
    true
  }
}

///|
fn BasicBodyInferencer::try_infer_field_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
  base : ExprId,
  name : NameId,
  offset : UInt64,
) -> Bool {
  let base_type = self.expression_type(base)
  if self.type_is_error(base_type) {
    self.fail_expression_selection(expression)
    return true
  }
  if !self.inspect_nominal_type(base_type) {
    if self.type_is_variable(base_type) {
      return false
    }
    self.diagnose(FieldAccessRequiresNominal(expression, offset))
    self.fail_expression_selection(expression)
    return true
  }
  let declaration = self.call_scratch.nominal_declaration
  if !self.declaration_is_struct(declaration) {
    self.diagnose(FieldAccessRequiresNominal(expression, offset))
    self.fail_expression_selection(expression)
    return true
  }
  if semantic_id_module(declaration) != self.collected.module_id {
    let imports = self.imports.unwrap()
    let spelling = self.collected.name(name)
    for field in imports.fields_of(declaration) {
      if field.variant is None && field.name == spelling {
        self.begin_expression_instantiation(
          declaration, base_type, expression, offset,
        )
        self.constrain(
          self.expression_type(expression),
          self.instantiate_signature_type(field.type_),
          expression_type_origin(expression, offset),
        )
        self.expression_selections[self.expression_index(expression)] = FieldAccessSelection(
          field.field,
        )
        return true
      }
    }
    self.diagnose(UnknownFieldForType(name, declaration, expression, offset))
    self.fail_expression_selection(expression)
    return true
  }
  let mut field_index = -1
  let declaration_index = semantic_id_local(declaration)
  let span = if declaration_index < 0 ||
    declaration_index >= self.field_spans.length() {
    { start: 0, length: 0 }
  } else {
    self.field_spans[declaration_index]
  }
  for index in span.start..<(span.start + span.length) {
    let field = self.collected.fields[index]
    if field.variant is None && field.name == name {
      field_index = index
      break
    }
  }
  if field_index < 0 {
    self.diagnose(UnknownFieldForType(name, declaration, expression, offset))
    self.fail_expression_selection(expression)
    return true
  }
  self.begin_expression_instantiation(
    declaration, base_type, expression, offset,
  )
  let field_type = self.instantiate_signature_type(
    self.resolved.field_types[field_index],
  )
  self.constrain(
    self.expression_type(expression),
    field_type,
    expression_type_origin(expression, offset),
  )
  self.expression_selections[self.expression_index(expression)] = FieldAccessSelection(
    self.collected.fields[field_index].id,
  )
  true
}

///|
fn BasicBodyInferencer::constrain_members(
  self : BasicBodyInferencer,
  final_ : Bool,
) -> Unit {
  if !self.has_member_expressions {
    return
  }
  let mut expression = self.body.expressions.start +
    self.body.expressions.length
  while expression > self.body.expressions.start {
    expression -= 1
    if self.expression_selections[self.expression_index(expression)] ==
      NoExpressionSelection {
      match self.collected.expressions[expression] {
        HirConstructExpr(target, fields, offset) =>
          self.infer_construct_expression(expression, target, fields, offset)
        _ => ()
      }
    }
  }
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    match self.collected.expressions[expression] {
      HirNameExpr(name, offset) =>
        if self.expression_selections[self.expression_index(expression)] ==
          NoExpressionSelection &&
          !self.consumed_member_roots[self.expression_index(expression)] {
          match self.names.expression_references[expression] {
            VariantNameReference(_) => {
              let variant_index = self.select_value_variant(
                name,
                self.expression_type(expression),
                expression,
                offset,
              )
              if variant_index < 0 {
                self.fail_expression_selection(expression)
              } else {
                self.infer_unit_variant_value(expression, variant_index, offset)
              }
            }
            _ => ()
          }
        }
      HirQualifiedExpr(base, property, offset) =>
        if self.expression_selections[self.expression_index(expression)] ==
          NoExpressionSelection {
          self.infer_qualified_value(expression, base, property, offset)
        }
      _ => ()
    }
  }
  self.call_scratch.member_expressions.clear()
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    if self.expression_selections[self.expression_index(expression)] ==
      NoExpressionSelection &&
      !self.consumed_member_roots[self.expression_index(expression)] {
      match self.collected.expressions[expression] {
        HirFieldExpr(_, _, _) =>
          self.call_scratch.member_expressions.push(expression)
        _ => ()
      }
    }
  }
  expression = self.body.expressions.start + self.body.expressions.length
  while expression > self.body.expressions.start {
    expression -= 1
    if self.expression_selections[self.expression_index(expression)] ==
      NoExpressionSelection &&
      !self.consumed_member_roots[self.expression_index(expression)] {
      match self.collected.expressions[expression] {
        HirObjectExpr(_, _) =>
          self.call_scratch.member_expressions.push(expression)
        _ => ()
      }
    }
  }
  while self.call_scratch.member_expressions.length() > 0 {
    self.call_scratch.deferred_members.clear()
    let mut progress = false
    for selected_expression in self.call_scratch.member_expressions {
      let completed = match self.collected.expressions[selected_expression] {
        HirObjectExpr(fields, offset) =>
          self.try_infer_object_expression(selected_expression, fields, offset)
        HirFieldExpr(base, name, offset) =>
          self.try_infer_field_expression(
            selected_expression, base, name, offset,
          )
        _ => true
      }
      if completed {
        progress = true
      } else {
        self.call_scratch.deferred_members.push(selected_expression)
      }
    }
    self.call_scratch.member_expressions.clear()
    for selected_expression in self.call_scratch.deferred_members {
      self.call_scratch.member_expressions.push(selected_expression)
    }
    if !progress {
      if !final_ {
        return
      }
      for selected_expression in self.call_scratch.member_expressions {
        match self.collected.expressions[selected_expression] {
          HirObjectExpr(_, offset) =>
            self.diagnose(ObjectTypeRequired(selected_expression, offset))
          HirFieldExpr(_, _, offset) =>
            self.diagnose(
              FieldAccessRequiresNominal(selected_expression, offset),
            )
          _ => ()
        }
        self.fail_expression_selection(selected_expression)
      }
      self.call_scratch.member_expressions.clear()
    }
  }
}

///|
fn BasicBodyInferencer::trait_declaration_named(
  self : BasicBodyInferencer,
  name : String,
) -> DeclId? {
  match self.collected.lookup_trait(name) {
    Some(declaration) => Some(declaration)
    None =>
      match self.imports {
        Some(imports) =>
          match imports.scope.lookup_trait(name) {
            Some(binding) => Some(binding.declaration)
            None => None
          }
        None => None
      }
  }
}

///|
fn BasicBodyInferencer::callable_index_of(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Int {
  if semantic_id_module(declaration) != self.collected.module_id {
    -1
  } else {
    let local_index = semantic_id_local(declaration)
    if local_index < 0 || local_index >= self.callable_indices.length() {
      -1
    } else {
      self.callable_indices[local_index]
    }
  }
}

///|
fn BasicBodyInferencer::imported_callable_of(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> ResolvedImportedCallable? {
  match self.imports {
    Some(imports) => imports.callable(declaration)
    None => None
  }
}

///|
fn BasicBodyInferencer::callable_exists(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Bool {
  self.callable_index_of(declaration) >= 0 ||
  self.imported_callable_of(declaration) is Some(_)
}

///|
fn BasicBodyInferencer::call_parameter_count(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Int {
  if semantic_id_module(declaration) == self.collected.module_id {
    self.collected.parameters_of(declaration).length
  } else {
    match self.imported_callable_of(declaration) {
      Some(callable) => callable.parameters.length
      None => -1
    }
  }
}

///|
fn BasicBodyInferencer::call_parameter_is_receiver(
  self : BasicBodyInferencer,
  declaration : DeclId,
  index : Int,
) -> Bool {
  if semantic_id_module(declaration) == self.collected.module_id {
    let parameters = self.collected.parameters_of(declaration)
    self.collected.parameters[parameters.start + index].kind ==
    ReceiverParameterDecl
  } else {
    let callable = self.imported_callable_of(declaration).unwrap()
    let imports = self.imports.unwrap()
    imports.parameter_receivers[callable.parameters.start + index]
  }
}

///|
fn BasicBodyInferencer::call_parameter_type(
  self : BasicBodyInferencer,
  declaration : DeclId,
  index : Int,
) -> ResolvedTypeId {
  if semantic_id_module(declaration) == self.collected.module_id {
    let parameters = self.collected.parameters_of(declaration)
    self.resolved.parameter_types[parameters.start + index]
  } else {
    let callable = self.imported_callable_of(declaration).unwrap()
    let imports = self.imports.unwrap()
    imports.parameter_types[callable.parameters.start + index]
  }
}

///|
fn BasicBodyInferencer::call_result_type(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> ResolvedTypeId {
  let local_index = self.callable_index_of(declaration)
  if local_index >= 0 {
    self.resolved.callable_return_types[local_index]
  } else {
    self.imported_callable_of(declaration).unwrap().result_type
  }
}

///|
fn BasicBodyInferencer::call_generic_count(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Int {
  if semantic_id_module(declaration) == self.collected.module_id {
    self.collected.generic_parameters_of(declaration).length
  } else {
    match self.imported_callable_of(declaration) {
      Some(callable) => callable.generic_parameters.length
      None => -1
    }
  }
}

///|
fn BasicBodyInferencer::call_arity_matches(
  self : BasicBodyInferencer,
  declaration : DeclId,
  arguments : HirSpan,
) -> Bool {
  self.call_parameter_count(declaration) == arguments.length
}

///|
fn BasicBodyInferencer::object_argument_matches_nominal_shape(
  self : BasicBodyInferencer,
  argument : ExprId,
  expected : BodyTypeId,
) -> Bool {
  let fields = match self.collected.expressions[argument] {
    HirObjectExpr(fields, _) => fields
    _ => return true
  }
  if !self.inspect_nominal_type(expected) {
    return false
  }
  let declaration = self.call_scratch.nominal_declaration
  match self.collected.declaration(declaration) {
    Some(TopLevelReference({ kind: StructDecl, .. })) => ()
    _ => return false
  }
  let mut declared_count = 0
  for field in self.collected.fields {
    if field.declaration == declaration && field.variant is None {
      declared_count += 1
      let mut matches = 0
      for index in 0..<fields.length {
        if self.collected.object_fields[fields.start + index].name == field.name {
          matches += 1
        }
      }
      if matches != 1 {
        return false
      }
    }
  }
  if declared_count != fields.length {
    return false
  }
  true
}

///|
fn BasicBodyInferencer::call_has_object_argument(
  self : BasicBodyInferencer,
  arguments : HirSpan,
) -> Bool {
  for index in 0..<arguments.length {
    let argument = self.collected.expression_children[arguments.start + index]
    match self.collected.expressions[argument] {
      HirObjectExpr(_, _) => return true
      _ => ()
    }
  }
  false
}

///|
fn BasicBodyInferencer::body_impl_target_head(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> ImplTargetHead? {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyErrorType => Some(ErrorImplTargetHead)
    BodyVariableType(_) => None
    BodyResolvedType(resolved_type) => {
      let (head, _) = resolved_impl_target_head(self.resolved, resolved_type)
      Some(head)
    }
    BodyAppliedType(base, _) =>
      match self.solver.type_term(self.solver.representative_type(base)) {
        BodyResolvedType(resolved_base) => {
          let (head, _) = resolved_impl_target_head(
            self.resolved,
            resolved_base,
          )
          Some(head)
        }
        BodyErrorType => Some(ErrorImplTargetHead)
        _ => None
      }
  }
}

///|
fn BasicBodyInferencer::collect_method_candidates(
  self : BasicBodyInferencer,
  receiver_type : BodyTypeId,
  name : NameId,
) -> Bool {
  self.call_scratch.method_candidates.clear()
  self.call_scratch.method_candidate_impls.clear()
  let head = match self.body_impl_target_head(receiver_type) {
    Some(head) => head
    None => return false
  }
  if head == ErrorImplTargetHead {
    return true
  }
  let inherent = self.impl_index.method_dispatch_span(head, name, true, true)
  let candidates = if inherent.length > 0 {
    inherent
  } else {
    self.impl_index.method_dispatch_span(head, name, false, true)
  }
  for offset in candidates.start..<(candidates.start + candidates.length) {
    let candidate = self.impl_index.method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
  true
}

///|
fn BasicBodyInferencer::begin_method_candidate(
  self : BasicBodyInferencer,
  implementation_index : Int,
  declaration : DeclId,
) -> BodyTypeId {
  let implementation = self.impl_index.implementations[implementation_index]
  self.call_scratch.instantiation_generics = if semantic_id_module(
      implementation.declaration,
    ) ==
    self.collected.module_id {
    self.collected.generic_parameters_of(implementation.declaration)
  } else {
    { start: 0, length: 0 }
  }
  self.call_scratch.instantiation_method_generics = if semantic_id_module(
      declaration,
    ) ==
    self.collected.module_id {
    self.collected.generic_parameters_of(declaration)
  } else {
    { start: 0, length: self.call_generic_count(declaration) }
  }
  self.call_scratch.candidate_type_arguments.clear()
  for
    _ in 0..<(self.call_scratch.instantiation_generics.length +
    self.call_scratch.instantiation_method_generics.length) {
    self.call_scratch.candidate_type_arguments.push(
      self.solver.fresh_variable(),
    )
  }
  self.call_scratch.instantiation_self_owner = implementation.declaration
  self.call_scratch.instantiation_self_type = -1
  self.next_instantiation_generation()
  let target = self.instantiate_signature_type(implementation.target_type)
  self.call_scratch.instantiation_self_type = target
  target
}

///|
fn BasicBodyInferencer::try_method_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  receiver : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Bool {
  if !self.callable_exists(declaration) {
    return false
  }
  let parameter_count = self.call_parameter_count(declaration)
  if parameter_count == 0 ||
    !self.call_parameter_is_receiver(declaration, 0) ||
    parameter_count - 1 != arguments.length {
    return false
  }
  let snapshot = self.solver.snapshot()
  let target = self.begin_method_candidate(implementation_index, declaration)
  let origin = call_type_origin(expression, offset)
  let mut viable = self.solver.unify(
    self.expression_type(receiver),
    target,
    origin,
  )
  if viable {
    viable = self.solver.unify(
      self.expression_type(receiver),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
      origin,
    )
  }
  let mut index = 0
  while viable && index < arguments.length {
    viable = self.solver.unify(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index + 1),
      ),
      origin,
    )
    index += 1
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(expression),
      self.instantiate_signature_type(self.call_result_type(declaration)),
      origin,
    )
  }
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::select_method_candidate(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  receiver : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Unit {
  let target = self.begin_method_candidate(implementation_index, declaration)
  let origin = call_type_origin(expression, offset)
  self.constrain(self.expression_type(receiver), target, origin)
  self.constrain(
    self.expression_type(receiver),
    self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
    origin,
  )
  for index in 0..<arguments.length {
    self.constrain_assignable(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index + 1),
      ),
      origin,
    )
  }
  self.constrain_assignable(
    self.instantiate_signature_type(self.call_result_type(declaration)),
    self.expression_type(expression),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  self.call_targets[call_slot] = SelectedInferredCallTarget(declaration, {
    start,
    length: self.call_scratch.candidate_type_arguments.length(),
  })
}

///|
fn BasicBodyInferencer::collect_operator_candidates(
  self : BasicBodyInferencer,
  trait_declaration : DeclId,
  method_name : NameId,
) -> Unit {
  self.call_scratch.method_candidates.clear()
  self.call_scratch.method_candidate_impls.clear()
  let candidates = self.impl_index.trait_method_dispatch_span(
    trait_declaration, method_name, true,
  )
  for offset in candidates.start..<(candidates.start + candidates.length) {
    let candidate = self.impl_index.trait_method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
}

///|
fn BasicBodyInferencer::try_operator_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  left : ExprId,
  right : ExprId,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Bool {
  if !self.callable_exists(declaration) ||
    self.call_parameter_count(declaration) != 2 ||
    !self.call_parameter_is_receiver(declaration, 0) {
    return false
  }
  let snapshot = self.solver.snapshot()
  let target = self.begin_method_candidate(implementation_index, declaration)
  let origin = operator_type_origin(expression, offset)
  let mut viable = self.solver.unify(self.expression_type(left), target, origin)
  if viable {
    viable = self.solver.unify(
      self.expression_type(left),
      self.expression_type(right),
      origin,
    )
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(left),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
      origin,
    )
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(right),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 1)),
      origin,
    )
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(expression),
      self.instantiate_signature_type(self.call_result_type(declaration)),
      origin,
    )
  }
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::select_operator_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  left : ExprId,
  right : ExprId,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Unit {
  let target = self.begin_method_candidate(implementation_index, declaration)
  let origin = operator_type_origin(expression, offset)
  self.constrain(self.expression_type(left), target, origin)
  self.constrain(
    self.expression_type(left),
    self.expression_type(right),
    origin,
  )
  self.constrain(
    self.expression_type(left),
    self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
    origin,
  )
  self.constrain_assignable(
    self.expression_type(right),
    self.instantiate_signature_type(self.call_parameter_type(declaration, 1)),
    origin,
  )
  self.constrain_assignable(
    self.instantiate_signature_type(self.call_result_type(declaration)),
    self.expression_type(expression),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  self.operator_targets[self.expression_index(expression)] = SelectedInferredCallTarget(
    declaration,
    { start, length: self.call_scratch.candidate_type_arguments.length() },
  )
}

///|
fn BasicBodyInferencer::try_index_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Bool {
  let (base, index, value) = match self.collected.expressions[expression] {
    HirIndexExpr(base, index, _) => (base, index, -1)
    HirIndexSetExpr(base, index, value, _) => (base, index, value)
    _ => abort("index work item is not an index expression")
  }
  let expected_parameters = if value >= 0 { 3 } else { 2 }
  if !self.callable_exists(declaration) ||
    self.call_parameter_count(declaration) != expected_parameters ||
    !self.call_parameter_is_receiver(declaration, 0) {
    return false
  }
  let snapshot = self.solver.snapshot()
  let target = self.begin_method_candidate(implementation_index, declaration)
  let origin = operator_type_origin(expression, offset)
  let mut viable = self.solver.unify(self.expression_type(base), target, origin)
  if viable {
    viable = self.solver.unify(
      self.expression_type(base),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
      origin,
    )
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(index),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 1)),
      origin,
    )
  }
  if viable && value >= 0 {
    viable = self.solver.unify(
      self.expression_type(value),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 2)),
      origin,
    )
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(expression),
      self.instantiate_signature_type(self.call_result_type(declaration)),
      origin,
    )
  }
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::select_index_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Unit {
  let (base, index, value) = match self.collected.expressions[expression] {
    HirIndexExpr(base, index, _) => (base, index, -1)
    HirIndexSetExpr(base, index, value, _) => (base, index, value)
    _ => abort("index work item is not an index expression")
  }
  let target = self.begin_method_candidate(implementation_index, declaration)
  let origin = operator_type_origin(expression, offset)
  self.constrain(self.expression_type(base), target, origin)
  self.constrain(
    self.expression_type(base),
    self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
    origin,
  )
  self.constrain_assignable(
    self.expression_type(index),
    self.instantiate_signature_type(self.call_parameter_type(declaration, 1)),
    origin,
  )
  if value >= 0 {
    self.constrain_assignable(
      self.expression_type(value),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 2)),
      origin,
    )
  }
  self.constrain_assignable(
    self.instantiate_signature_type(self.call_result_type(declaration)),
    self.expression_type(expression),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  self.operator_targets[self.expression_index(expression)] = SelectedInferredCallTarget(
    declaration,
    { start, length: self.call_scratch.candidate_type_arguments.length() },
  )
}

///|
fn BasicBodyInferencer::fixed_array_element_type(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> BodyTypeId? {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyAppliedType(base, arguments) if arguments.length == 1 =>
      match self.solver.type_term(self.solver.representative_type(base)) {
        BodyResolvedType(resolved_base) =>
          match self.resolved.types[resolved_base] {
            NominalType(declaration) =>
              if declaration == standard_fixed_array_type_declaration() {
                Some(self.solver.type_arguments[arguments.start])
              } else {
                None
              }
            _ => None
          }
        _ => None
      }
    _ => None
  }
}

///|
fn BasicBodyInferencer::map_key_value_types(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> (BodyTypeId, BodyTypeId)? {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyAppliedType(base, arguments) if arguments.length == 2 =>
      match self.solver.type_term(self.solver.representative_type(base)) {
        BodyResolvedType(resolved_base) =>
          match self.resolved.types[resolved_base] {
            NominalType(declaration) =>
              if declaration == standard_map_type_declaration() {
                Some(
                  (
                    self.solver.type_arguments[arguments.start],
                    self.solver.type_arguments[arguments.start + 1],
                  ),
                )
              } else {
                None
              }
            _ => None
          }
        _ => None
      }
    BodyResolvedType(resolved_type) =>
      match self.resolved.types[resolved_type] {
        AppliedType(resolved_base, arguments) if arguments.length == 2 =>
          match self.resolved.types[resolved_base] {
            NominalType(declaration) =>
              if declaration == standard_map_type_declaration() {
                Some(
                  (
                    self.solver.resolved_type(
                      self.resolved.type_arguments[arguments.start],
                    ),
                    self.solver.resolved_type(
                      self.resolved.type_arguments[arguments.start + 1],
                    ),
                  ),
                )
              } else {
                None
              }
            _ => None
          }
        _ => None
      }
    _ => None
  }
}

///|
fn BasicBodyInferencer::set_key_type(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> BodyTypeId? {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyAppliedType(base, arguments) if arguments.length == 1 =>
      match self.solver.type_term(self.solver.representative_type(base)) {
        BodyResolvedType(resolved_base) =>
          match self.resolved.types[resolved_base] {
            NominalType(declaration) =>
              if declaration == standard_set_type_declaration() {
                Some(self.solver.type_arguments[arguments.start])
              } else {
                None
              }
            _ => None
          }
        _ => None
      }
    BodyResolvedType(resolved_type) =>
      match self.resolved.types[resolved_type] {
        AppliedType(resolved_base, arguments) if arguments.length == 1 =>
          match self.resolved.types[resolved_base] {
            NominalType(declaration) =>
              if declaration == standard_set_type_declaration() {
                Some(
                  self.solver.resolved_type(
                    self.resolved.type_arguments[arguments.start],
                  ),
                )
              } else {
                None
              }
            _ => None
          }
        _ => None
      }
    _ => None
  }
}

///|
fn BasicBodyInferencer::select_map_trait_evidence(
  self : BasicBodyInferencer,
  expression : ExprId,
  target_type : BodyTypeId,
  trait_name : String,
  method_name_string : String,
  parameter_count : Int,
  result_type : BodyTypeId,
  offset : UInt64,
) -> InferredCallTarget {
  let trait_declaration = match self.trait_declaration_named(trait_name) {
    Some(value) => value
    None => return ErrorInferredCallTarget
  }
  let method_name = match self.collected.find_name(method_name_string) {
    Some(value) => value
    None => return ErrorInferredCallTarget
  }
  self.collect_operator_candidates(trait_declaration, method_name)
  let mut viable_count = 0
  let mut selected_declaration = 0UL
  let mut selected_impl = -1
  let mut selected_specificity = -1
  let mut second_declaration = 0UL
  let origin = call_type_origin(expression, offset)
  for candidate_index in 0..<self.call_scratch.method_candidates.length() {
    let declaration = self.call_scratch.method_candidates[candidate_index]
    let implementation_index = self.call_scratch.method_candidate_impls[candidate_index]
    if !self.callable_exists(declaration) ||
      self.call_parameter_count(declaration) != parameter_count ||
      !self.call_parameter_is_receiver(declaration, 0) {
      continue
    }
    let snapshot = self.solver.snapshot()
    let candidate_target = self.begin_method_candidate(
      implementation_index, declaration,
    )
    let mut viable = self.solver.unify(target_type, candidate_target, origin)
    for parameter in 0..<parameter_count {
      if viable {
        viable = self.solver.unify(
          target_type,
          self.instantiate_signature_type(
            self.call_parameter_type(declaration, parameter),
          ),
          origin,
        )
      }
    }
    if viable {
      viable = self.solver.unify(
        result_type,
        self.instantiate_signature_type(self.call_result_type(declaration)),
        origin,
      )
    }
    self.solver.rollback(snapshot)
    if viable {
      let specificity = self.impl_index.implementations[implementation_index].specificity
      if specificity > selected_specificity {
        selected_specificity = specificity
        viable_count = 1
        selected_declaration = declaration
        selected_impl = implementation_index
        second_declaration = 0UL
      } else if specificity == selected_specificity {
        viable_count += 1
        if viable_count == 2 {
          second_declaration = declaration
        }
      }
    }
  }
  if viable_count != 1 {
    self.poison_expression(expression)
    if viable_count > 1 {
      self.diagnose(
        AmbiguousMethod(
          method_name, expression, selected_declaration, second_declaration, viable_count,
          offset,
        ),
      )
    } else {
      self.diagnose(NoMatchingMethod(method_name, expression, offset))
    }
    return ErrorInferredCallTarget
  }
  let candidate_target = self.begin_method_candidate(
    selected_impl, selected_declaration,
  )
  self.constrain(target_type, candidate_target, origin)
  for parameter in 0..<parameter_count {
    self.constrain(
      target_type,
      self.instantiate_signature_type(
        self.call_parameter_type(selected_declaration, parameter),
      ),
      origin,
    )
  }
  self.constrain(
    result_type,
    self.instantiate_signature_type(self.call_result_type(selected_declaration)),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  SelectedInferredCallTarget(selected_declaration, {
    start,
    length: self.call_scratch.candidate_type_arguments.length(),
  })
}

///|
fn BasicBodyInferencer::select_map_evidence(
  self : BasicBodyInferencer,
  expression : ExprId,
  key_type : BodyTypeId,
  offset : UInt64,
) -> Unit {
  let expression_index = self.expression_index(expression)
  self.map_hash_targets[expression_index] = self.select_map_trait_evidence(
    expression,
    key_type,
    "Hash",
    "hash",
    1,
    self.primitive(U64Type),
    offset,
  )
  self.map_eq_targets[expression_index] = self.select_map_trait_evidence(
    expression,
    key_type,
    "Hash",
    "hash_eq",
    2,
    self.primitive(BoolType),
    offset,
  )
}

///|
fn BasicBodyInferencer::select_fixed_array_index(
  self : BasicBodyInferencer,
  expression : ExprId,
  index : ExprId,
  value : ExprId,
  element : BodyTypeId,
  offset : UInt64,
) -> Unit {
  let origin = operator_type_origin(expression, offset)
  self.constrain_assignable(
    self.expression_type(index),
    self.primitive(U32Type),
    origin,
  )
  let declaration = if value >= 0 {
    self.constrain_assignable(self.expression_type(value), element, origin)
    self.constrain(
      self.expression_type(expression),
      self.primitive(UnitType),
      origin,
    )
    standard_fixed_array_index_set_declaration()
  } else {
    self.constrain(element, self.expression_type(expression), origin)
    standard_fixed_array_index_declaration()
  }
  let start = self.call_type_arguments.length()
  self.call_type_arguments.push(element)
  self.operator_targets[self.expression_index(expression)] = SelectedInferredCallTarget(
    declaration,
    { start, length: 1 },
  )
}

///|
fn BasicBodyInferencer::select_map_index(
  self : BasicBodyInferencer,
  expression : ExprId,
  index : ExprId,
  value : ExprId,
  key_type : BodyTypeId,
  value_type : BodyTypeId,
  offset : UInt64,
) -> Unit {
  let origin = operator_type_origin(expression, offset)
  self.constrain_assignable(self.expression_type(index), key_type, origin)
  let declaration = if value >= 0 {
    self.constrain_assignable(self.expression_type(value), value_type, origin)
    self.constrain(
      self.expression_type(expression),
      self.primitive(UnitType),
      origin,
    )
    standard_map_index_set_declaration()
  } else {
    self.constrain(value_type, self.expression_type(expression), origin)
    standard_map_index_declaration()
  }
  self.select_map_evidence(expression, key_type, offset)
  let start = self.call_type_arguments.length()
  self.call_type_arguments.push(key_type)
  self.call_type_arguments.push(value_type)
  self.operator_targets[self.expression_index(expression)] = SelectedInferredCallTarget(
    declaration,
    { start, length: 2 },
  )
}

///|
fn index_trait(expression : HirExpr) -> (String, String)? {
  match expression {
    HirIndexExpr(_, _, _) => Some(("Index", "index"))
    HirIndexSetExpr(_, _, _, _) => Some(("IndexSet", "index_set"))
    _ => None
  }
}

///|
fn BasicBodyInferencer::try_resolve_operator(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Bool {
  let source = self.collected.expressions[expression]
  let (trait_name, method_name_string, target_expression, offset) = match
    source {
    HirBinaryExpr(operator, left, _, offset) => {
      let (trait_name, method_name) = binary_operator_trait(operator).unwrap()
      (trait_name, method_name, left, offset)
    }
    HirIndexExpr(base, _, offset) | HirIndexSetExpr(base, _, _, offset) => {
      let (trait_name, method_name) = index_trait(source).unwrap()
      (trait_name, method_name, base, offset)
    }
    _ => abort("operator work item is not operator-backed syntax")
  }
  let (left, right) = match source {
    HirBinaryExpr(_, left, right, _) => (left, right)
    _ => (-1, -1)
  }
  match source {
    HirIndexExpr(base, index, offset) => {
      match self.fixed_array_element_type(self.expression_type(base)) {
        Some(element) => {
          self.select_fixed_array_index(expression, index, -1, element, offset)
          return true
        }
        None => ()
      }
      match self.map_key_value_types(self.expression_type(base)) {
        Some((key_type, value_type)) => {
          self.select_map_index(
            expression, index, -1, key_type, value_type, offset,
          )
          return true
        }
        None => ()
      }
    }
    HirIndexSetExpr(base, index, value, offset) => {
      match self.fixed_array_element_type(self.expression_type(base)) {
        Some(element) => {
          self.select_fixed_array_index(
            expression, index, value, element, offset,
          )
          return true
        }
        None => ()
      }
      match self.map_key_value_types(self.expression_type(base)) {
        Some((key_type, value_type)) => {
          self.select_map_index(
            expression, index, value, key_type, value_type, offset,
          )
          return true
        }
        None => ()
      }
    }
    _ => ()
  }
  let trait_declaration = self.trait_declaration_named(trait_name).unwrap()
  let method_name = self.collected.find_name(method_name_string).unwrap()
  if self.body_impl_target_head(self.expression_type(target_expression)) is None {
    return false
  }
  if self.type_is_error(self.expression_type(target_expression)) ||
    (right >= 0 && self.type_is_error(self.expression_type(right))) {
    self.operator_targets[self.expression_index(expression)] = ErrorInferredCallTarget
    self.poison_expression(expression)
    return true
  }
  self.collect_operator_candidates(trait_declaration, method_name)
  self.call_scratch.trial_viable_count = 0
  self.call_scratch.trial_first_declaration = 0UL
  self.call_scratch.trial_second_declaration = 0UL
  let mut first_impl = -1
  let mut best_specificity = -1
  for candidate_index in 0..<self.call_scratch.method_candidates.length() {
    let declaration = self.call_scratch.method_candidates[candidate_index]
    let implementation_index = self.call_scratch.method_candidate_impls[candidate_index]
    let viable = match source {
      HirBinaryExpr(_, _, _, _) =>
        self.try_operator_candidate(
          expression, left, right, declaration, implementation_index, offset,
        )
      HirIndexExpr(_, _, _) | HirIndexSetExpr(_, _, _, _) =>
        self.try_index_candidate(
          expression, declaration, implementation_index, offset,
        )
      _ => false
    }
    if viable {
      let specificity = self.impl_index.implementations[implementation_index].specificity
      if specificity > best_specificity {
        best_specificity = specificity
        self.call_scratch.trial_viable_count = 1
        self.call_scratch.trial_first_declaration = declaration
        self.call_scratch.trial_second_declaration = 0UL
        first_impl = implementation_index
      } else if specificity == best_specificity {
        self.call_scratch.trial_viable_count += 1
        if self.call_scratch.trial_viable_count == 2 {
          self.call_scratch.trial_second_declaration = declaration
        }
      }
    }
  }
  if self.call_scratch.trial_viable_count == 1 {
    match source {
      HirBinaryExpr(_, _, _, _) =>
        self.select_operator_candidate(
          expression,
          left,
          right,
          self.call_scratch.trial_first_declaration,
          first_impl,
          offset,
        )
      HirIndexExpr(_, _, _) | HirIndexSetExpr(_, _, _, _) =>
        self.select_index_candidate(
          expression,
          self.call_scratch.trial_first_declaration,
          first_impl,
          offset,
        )
      _ => ()
    }
  } else if self.call_scratch.trial_viable_count > 1 {
    self.operator_targets[self.expression_index(expression)] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(
      AmbiguousMethod(
        method_name,
        expression,
        self.call_scratch.trial_first_declaration,
        self.call_scratch.trial_second_declaration,
        self.call_scratch.trial_viable_count,
        offset,
      ),
    )
  } else {
    self.operator_targets[self.expression_index(expression)] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(NoMatchingMethod(method_name, expression, offset))
  }
  true
}

///|
fn BasicBodyInferencer::constrain_operator_calls(
  self : BasicBodyInferencer,
) -> Unit {
  while self.call_scratch.pending_operators.length() > 0 {
    self.call_scratch.deferred_operators.clear()
    let mut progress = false
    for expression in self.call_scratch.pending_operators {
      if self.try_resolve_operator(expression) {
        progress = true
      } else {
        self.call_scratch.deferred_operators.push(expression)
      }
    }
    self.call_scratch.pending_operators.clear()
    for expression in self.call_scratch.deferred_operators {
      self.call_scratch.pending_operators.push(expression)
    }
    if !progress {
      break
    }
  }
  for expression in self.call_scratch.pending_operators {
    let method_name_string = match self.collected.expressions[expression] {
      HirBinaryExpr(operator, _, _, _) =>
        binary_operator_trait(operator).unwrap().1
      source => index_trait(source).unwrap().1
    }
    let method_name = self.collected.find_name(method_name_string).unwrap()
    self.operator_targets[self.expression_index(expression)] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(
      NoMatchingMethod(
        method_name,
        expression,
        self.collected.expressions[expression].offset(),
      ),
    )
  }
}

///|
fn BasicBodyInferencer::collect_type_qualified_candidates(
  self : BasicBodyInferencer,
  head : ImplTargetHead,
  name : NameId,
) -> Unit {
  self.call_scratch.method_candidates.clear()
  self.call_scratch.method_candidate_impls.clear()
  let static_methods = self.impl_index.method_dispatch_span(
    head, name, true, false,
  )
  for
    offset in static_methods.start..<(static_methods.start +
    static_methods.length) {
    let candidate = self.impl_index.method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
  let instance_methods = self.impl_index.method_dispatch_span(
    head, name, true, true,
  )
  for
    offset in instance_methods.start..<(instance_methods.start +
    instance_methods.length) {
    let candidate = self.impl_index.method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
}

///|
fn BasicBodyInferencer::try_qualified_method_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Bool {
  if !self.callable_exists(declaration) ||
    self.call_parameter_count(declaration) != arguments.length {
    return false
  }
  let snapshot = self.solver.snapshot()
  self.begin_method_candidate(implementation_index, declaration) |> ignore
  let origin = call_type_origin(expression, offset)
  let mut viable = true
  let mut index = 0
  while viable && index < arguments.length {
    viable = self.solver.unify(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index),
      ),
      origin,
    )
    index += 1
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(expression),
      self.instantiate_signature_type(self.call_result_type(declaration)),
      origin,
    )
  }
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::select_qualified_method_candidate(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Unit {
  self.begin_method_candidate(implementation_index, declaration) |> ignore
  let origin = call_type_origin(expression, offset)
  for index in 0..<arguments.length {
    self.constrain_assignable(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index),
      ),
      origin,
    )
  }
  self.constrain_assignable(
    self.instantiate_signature_type(self.call_result_type(declaration)),
    self.expression_type(expression),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  self.call_targets[call_slot] = SelectedInferredCallTarget(declaration, {
    start,
    length: self.call_scratch.candidate_type_arguments.length(),
  })
}

///|
fn BasicBodyInferencer::collect_trait_qualified_candidates(
  self : BasicBodyInferencer,
  trait_declaration : DeclId,
  name : NameId,
) -> Unit {
  self.call_scratch.method_candidates.clear()
  self.call_scratch.method_candidate_impls.clear()
  let static_methods = self.impl_index.trait_method_dispatch_span(
    trait_declaration, name, false,
  )
  for
    offset in static_methods.start..<(static_methods.start +
    static_methods.length) {
    let candidate = self.impl_index.trait_method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
  let instance_methods = self.impl_index.trait_method_dispatch_span(
    trait_declaration, name, true,
  )
  for
    offset in instance_methods.start..<(instance_methods.start +
    instance_methods.length) {
    let candidate = self.impl_index.trait_method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
}

///|
fn BasicBodyInferencer::resolve_type_qualified_method_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  target_head : ImplTargetHead,
  name : NameId,
  offset : UInt64,
) -> Bool {
  match target_head {
    NominalImplTargetHead(declaration) =>
      if declaration == standard_fixed_array_type_declaration() &&
        self.collected.name(name) == "make" &&
        arguments.length == 2 {
        let length = self.collected.expression_children[arguments.start]
        let value = self.collected.expression_children[arguments.start + 1]
        let element = self.expression_type(value)
        let origin = call_type_origin(expression, offset)
        self.constrain_assignable(
          self.expression_type(length),
          self.primitive(U32Type),
          origin,
        )
        let base = match self.body_nominal_type(declaration) {
          Some(value) => value
          None => return false
        }
        let result = self.solver.applied_type(base, [element])
        self.constrain_assignable(
          result,
          self.expression_type(expression),
          origin,
        )
        let start = self.call_type_arguments.length()
        self.call_type_arguments.push(element)
        self.call_targets[call_slot] = SelectedInferredCallTarget(
          standard_fixed_array_method_declaration("make"),
          { start, length: 1 },
        )
        return true
      } else if declaration == standard_map_type_declaration() &&
        self.collected.name(name) == "singleton" &&
        arguments.length == 2 {
        let key = self.collected.expression_children[arguments.start]
        let value = self.collected.expression_children[arguments.start + 1]
        let key_type = self.expression_type(key)
        let value_type = self.expression_type(value)
        let base = match self.body_nominal_type(declaration) {
          Some(found) => found
          None => return false
        }
        let result = self.solver.applied_type(base, [key_type, value_type])
        self.constrain_assignable(
          result,
          self.expression_type(expression),
          call_type_origin(expression, offset),
        )
        self.select_map_evidence(expression, key_type, offset)
        let start = self.call_type_arguments.length()
        self.call_type_arguments.push(key_type)
        self.call_type_arguments.push(value_type)
        self.call_targets[call_slot] = SelectedInferredCallTarget(
          standard_map_method_declaration("singleton"),
          { start, length: 2 },
        )
        return true
      } else if declaration == standard_map_type_declaration() &&
        self.collected.name(name) == "empty" &&
        arguments.length == 0 {
        let (key_type, value_type) = match
          self.map_key_value_types(self.expression_type(expression)) {
          Some(value) => value
          None => return false
        }
        self.select_map_evidence(expression, key_type, offset)
        let start = self.call_type_arguments.length()
        self.call_type_arguments.push(key_type)
        self.call_type_arguments.push(value_type)
        self.call_targets[call_slot] = SelectedInferredCallTarget(
          standard_map_method_declaration("empty"),
          { start, length: 2 },
        )
        return true
      } else if declaration == standard_set_type_declaration() &&
        self.collected.name(name) == "singleton" &&
        arguments.length == 1 {
        let key = self.collected.expression_children[arguments.start]
        let key_type = self.expression_type(key)
        let base = match self.body_nominal_type(declaration) {
          Some(found) => found
          None => return false
        }
        let result = self.solver.applied_type(base, [key_type])
        self.constrain_assignable(
          result,
          self.expression_type(expression),
          call_type_origin(expression, offset),
        )
        self.select_map_evidence(expression, key_type, offset)
        let start = self.call_type_arguments.length()
        self.call_type_arguments.push(key_type)
        self.call_targets[call_slot] = SelectedInferredCallTarget(
          standard_set_method_declaration("singleton"),
          { start, length: 1 },
        )
        return true
      } else if declaration == standard_set_type_declaration() &&
        self.collected.name(name) == "empty" &&
        arguments.length == 0 {
        let key_type = self.solver.fresh_variable()
        let base = match self.body_nominal_type(declaration) {
          Some(found) => found
          None => return false
        }
        let result = self.solver.applied_type(base, [key_type])
        self.constrain_assignable(
          result,
          self.expression_type(expression),
          call_type_origin(expression, offset),
        )
        let start = self.call_type_arguments.length()
        self.call_type_arguments.push(key_type)
        self.call_targets[call_slot] = SelectedInferredCallTarget(
          standard_set_method_declaration("empty"),
          { start, length: 1 },
        )
        return true
      }
    _ => ()
  }
  self.collect_type_qualified_candidates(target_head, name)
  self.resolve_qualified_method_candidates(
    call_slot, expression, arguments, name, offset,
  )
}

///|
fn BasicBodyInferencer::resolve_trait_qualified_method_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  trait_declaration : DeclId,
  name : NameId,
  offset : UInt64,
) -> Bool {
  self.collect_trait_qualified_candidates(trait_declaration, name)
  self.resolve_qualified_method_candidates(
    call_slot, expression, arguments, name, offset,
  )
}

///|
fn BasicBodyInferencer::resolve_qualified_method_candidates(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  name : NameId,
  offset : UInt64,
) -> Bool {
  if self.call_scratch.method_candidates.length() == 0 {
    return false
  }
  self.call_scratch.trial_viable_count = 0
  self.call_scratch.trial_first_declaration = 0UL
  self.call_scratch.trial_second_declaration = 0UL
  let mut first_impl = -1
  let mut best_specificity = -1
  for candidate_index in 0..<self.call_scratch.method_candidates.length() {
    let declaration = self.call_scratch.method_candidates[candidate_index]
    let implementation_index = self.call_scratch.method_candidate_impls[candidate_index]
    if self.try_qualified_method_candidate(
        expression, arguments, declaration, implementation_index, offset,
      ) {
      let candidate_specificity = self.impl_index.implementations[implementation_index].specificity
      if candidate_specificity > best_specificity {
        best_specificity = candidate_specificity
        self.call_scratch.trial_viable_count = 1
        self.call_scratch.trial_first_declaration = declaration
        self.call_scratch.trial_second_declaration = 0UL
        first_impl = implementation_index
      } else if candidate_specificity == best_specificity {
        self.call_scratch.trial_viable_count += 1
        if self.call_scratch.trial_viable_count == 2 {
          self.call_scratch.trial_second_declaration = declaration
        }
      }
    }
  }
  if self.call_scratch.trial_viable_count == 1 {
    self.select_qualified_method_candidate(
      call_slot,
      expression,
      arguments,
      self.call_scratch.trial_first_declaration,
      first_impl,
      offset,
    )
  } else if self.call_scratch.trial_viable_count > 1 {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(
      AmbiguousMethod(
        name,
        expression,
        self.call_scratch.trial_first_declaration,
        self.call_scratch.trial_second_declaration,
        self.call_scratch.trial_viable_count,
        offset,
      ),
    )
  } else {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(NoMatchingMethod(name, expression, offset))
  }
  true
}

///|
fn BasicBodyInferencer::body_nominal_type(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> BodyTypeId? {
  for index, type_ in self.resolved.types {
    match type_ {
      NominalType(candidate) if candidate == declaration =>
        return Some(self.solver.resolved_type(index))
      _ => ()
    }
  }
  None
}

///|
fn BasicBodyInferencer::try_fixed_array_method_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  receiver : ExprId,
  name : NameId,
  arguments : HirSpan,
  offset : UInt64,
) -> Bool {
  let element = match
    self.fixed_array_element_type(self.expression_type(receiver)) {
    Some(value) => value
    None => return false
  }
  let method_name = self.collected.name(name)
  let declaration = standard_fixed_array_method_declaration(method_name)
  if declaration == 0UL || method_name == "make" {
    return false
  }
  let expected_arguments = match method_name {
    "length" => 0
    "get" | "get_unchecked" => 1
    "set" | "set_unchecked" => 2
    _ => return false
  }
  if arguments.length != expected_arguments {
    return false
  }
  let origin = call_type_origin(expression, offset)
  if expected_arguments > 0 {
    self.constrain_assignable(
      self.expression_type(self.collected.expression_children[arguments.start]),
      self.primitive(U32Type),
      origin,
    )
  }
  if expected_arguments > 1 {
    self.constrain_assignable(
      self.expression_type(
        self.collected.expression_children[arguments.start + 1],
      ),
      element,
      origin,
    )
  }
  let result = match method_name {
    "length" => self.primitive(U32Type)
    "get_unchecked" => element
    "set" | "set_unchecked" => self.primitive(UnitType)
    "get" => {
      let option_base = match
        self.body_nominal_type(standard_option_type_declaration()) {
        Some(value) => value
        None => {
          self.call_targets[call_slot] = ErrorInferredCallTarget
          self.poison_expression(expression)
          return true
        }
      }
      self.solver.applied_type(option_base, [element])
    }
    _ => self.solver.error_type()
  }
  self.constrain_assignable(result, self.expression_type(expression), origin)
  let start = self.call_type_arguments.length()
  self.call_type_arguments.push(element)
  self.call_targets[call_slot] = SelectedInferredCallTarget(declaration, {
    start,
    length: 1,
  })
  true
}

///|
fn BasicBodyInferencer::try_map_method_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  receiver : ExprId,
  name : NameId,
  arguments : HirSpan,
  offset : UInt64,
) -> Bool {
  let (key_type, value_type) = match
    self.map_key_value_types(self.expression_type(receiver)) {
    Some(value) => value
    None => return false
  }
  let method_name = self.collected.name(name)
  let declaration = standard_map_method_declaration(method_name)
  if declaration == 0UL || method_name == "singleton" {
    return false
  }
  let expected_arguments = match method_name {
    "length" | "clear" => 0
    "get" | "get_unchecked" | "contains_key" | "remove" => 1
    "insert" | "set" => 2
    _ => return false
  }
  if arguments.length != expected_arguments {
    return false
  }
  let origin = call_type_origin(expression, offset)
  if expected_arguments > 0 {
    self.constrain_assignable(
      self.expression_type(self.collected.expression_children[arguments.start]),
      key_type,
      origin,
    )
  }
  if expected_arguments > 1 {
    self.constrain_assignable(
      self.expression_type(
        self.collected.expression_children[arguments.start + 1],
      ),
      value_type,
      origin,
    )
  }
  let result = match method_name {
    "length" => self.primitive(U32Type)
    "contains_key" | "remove" => self.primitive(BoolType)
    "get_unchecked" => value_type
    "set" | "insert" | "clear" => self.primitive(UnitType)
    "get" => {
      let option_base = match
        self.body_nominal_type(standard_option_type_declaration()) {
        Some(value) => value
        None => {
          self.call_targets[call_slot] = ErrorInferredCallTarget
          self.poison_expression(expression)
          return true
        }
      }
      self.solver.applied_type(option_base, [value_type])
    }
    _ => self.solver.error_type()
  }
  self.constrain_assignable(result, self.expression_type(expression), origin)
  if method_name != "clear" {
    self.select_map_evidence(expression, key_type, offset)
  }
  let start = self.call_type_arguments.length()
  self.call_type_arguments.push(key_type)
  self.call_type_arguments.push(value_type)
  self.call_targets[call_slot] = SelectedInferredCallTarget(declaration, {
    start,
    length: 2,
  })
  true
}

///|
fn BasicBodyInferencer::try_set_method_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  receiver : ExprId,
  name : NameId,
  arguments : HirSpan,
  offset : UInt64,
) -> Bool {
  let key_type = match self.set_key_type(self.expression_type(receiver)) {
    Some(value) => value
    None => return false
  }
  let method_name = self.collected.name(name)
  let declaration = standard_set_method_declaration(method_name)
  if declaration == 0UL || method_name == "empty" || method_name == "singleton" {
    return false
  }
  let expected_arguments = match method_name {
    "length" | "is_empty" | "clear" => 0
    "contains" | "insert" | "remove" => 1
    _ => return false
  }
  if arguments.length != expected_arguments {
    return false
  }
  let origin = call_type_origin(expression, offset)
  if expected_arguments == 1 {
    self.constrain_assignable(
      self.expression_type(self.collected.expression_children[arguments.start]),
      key_type,
      origin,
    )
    self.select_map_evidence(expression, key_type, offset)
  }
  let result = match method_name {
    "length" => self.primitive(U32Type)
    "is_empty" | "contains" | "insert" | "remove" => self.primitive(BoolType)
    "clear" => self.primitive(UnitType)
    _ => self.solver.error_type()
  }
  self.constrain_assignable(result, self.expression_type(expression), origin)
  let start = self.call_type_arguments.length()
  self.call_type_arguments.push(key_type)
  self.call_targets[call_slot] = SelectedInferredCallTarget(declaration, {
    start,
    length: 1,
  })
  true
}

///|
fn BasicBodyInferencer::try_resolve_method_call(
  self : BasicBodyInferencer,
  call_slot : Int,
) -> Bool {
  let expression = self.call_expressions[call_slot]
  let (target, arguments, offset) = match
    self.collected.expressions[expression] {
    HirCallExpr(target, arguments, offset) => (target, arguments, offset)
    _ => abort("method call slot is not a call")
  }
  let (receiver, name) = match self.collected.expressions[target] {
    HirFieldExpr(receiver, name, _) => (receiver, name)
    _ => abort("method call target is not a field expression")
  }
  if self.try_fixed_array_method_call(
      call_slot, expression, receiver, name, arguments, offset,
    ) {
    return true
  }
  if self.try_map_method_call(
      call_slot, expression, receiver, name, arguments, offset,
    ) {
    return true
  }
  if self.try_set_method_call(
      call_slot, expression, receiver, name, arguments, offset,
    ) {
    return true
  }
  if !self.collect_method_candidates(self.expression_type(receiver), name) {
    return false
  }
  if self.type_is_error(self.expression_type(receiver)) {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    return true
  }
  let mut tier = 0
  while tier < 2 {
    self.call_scratch.trial_viable_count = 0
    self.call_scratch.trial_first_declaration = 0UL
    self.call_scratch.trial_second_declaration = 0UL
    let mut first_impl = -1
    let mut best_specificity = -1
    for candidate_index in 0..<self.call_scratch.method_candidates.length() {
      let implementation_index = self.call_scratch.method_candidate_impls[candidate_index]
      let implementation = self.impl_index.implementations[implementation_index]
      let candidate_tier = match implementation.kind {
        InherentIndexedImpl => 0
        TraitIndexedImpl(_) => 1
      }
      if candidate_tier != tier {
        continue
      }
      let declaration = self.call_scratch.method_candidates[candidate_index]
      if self.try_method_candidate(
          expression, receiver, arguments, declaration, implementation_index, offset,
        ) {
        if implementation.specificity > best_specificity {
          best_specificity = implementation.specificity
          self.call_scratch.trial_viable_count = 1
          self.call_scratch.trial_first_declaration = declaration
          self.call_scratch.trial_second_declaration = 0UL
          first_impl = implementation_index
        } else if implementation.specificity == best_specificity {
          self.call_scratch.trial_viable_count += 1
          if self.call_scratch.trial_viable_count == 2 {
            self.call_scratch.trial_second_declaration = declaration
          }
        }
      }
    }
    if self.call_scratch.trial_viable_count == 1 {
      self.select_method_candidate(
        call_slot,
        expression,
        receiver,
        arguments,
        self.call_scratch.trial_first_declaration,
        first_impl,
        offset,
      )
      return true
    }
    if self.call_scratch.trial_viable_count > 1 {
      self.call_targets[call_slot] = ErrorInferredCallTarget
      self.poison_expression(expression)
      self.diagnose(
        AmbiguousMethod(
          name,
          expression,
          self.call_scratch.trial_first_declaration,
          self.call_scratch.trial_second_declaration,
          self.call_scratch.trial_viable_count,
          offset,
        ),
      )
      return true
    }
    tier += 1
  }
  self.call_targets[call_slot] = ErrorInferredCallTarget
  self.poison_expression(expression)
  self.diagnose(NoMatchingMethod(name, expression, offset))
  true
}

///|
fn BasicBodyInferencer::constrain_method_calls(
  self : BasicBodyInferencer,
) -> Unit {
  while self.call_scratch.pending_methods.length() > 0 {
    self.call_scratch.deferred_methods.clear()
    let mut progress = false
    for call_slot in self.call_scratch.pending_methods {
      if self.try_resolve_method_call(call_slot) {
        progress = true
      } else {
        self.call_scratch.deferred_methods.push(call_slot)
      }
    }
    self.call_scratch.pending_methods.clear()
    for call_slot in self.call_scratch.deferred_methods {
      self.call_scratch.pending_methods.push(call_slot)
    }
    if !progress {
      break
    }
  }
  for call_slot in self.call_scratch.pending_methods {
    let expression = self.call_expressions[call_slot]
    let target = match self.collected.expressions[expression] {
      HirCallExpr(target, _, _) => target
      _ => abort("pending method is not a call")
    }
    let receiver = match self.collected.expressions[target] {
      HirFieldExpr(receiver, _, _) => receiver
      _ => abort("pending method target is not a field")
    }
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    match self.collected.expressions[receiver] {
      HirObjectExpr(_, _) => ()
      _ =>
        if !self.type_is_error(self.expression_type(receiver)) {
          let name = match self.collected.expressions[target] {
            HirFieldExpr(_, name, _) => name
            _ => abort("pending method target is not a field")
          }
          self.diagnose(
            NoMatchingMethod(
              name,
              expression,
              self.collected.expressions[expression].offset(),
            ),
          )
        }
    }
  }
  self.call_scratch.pending_methods.clear()
}

///|
fn BasicBodyInferencer::try_call_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  offset : UInt64,
) -> Bool {
  if !self.callable_exists(declaration) ||
    !self.call_arity_matches(declaration, arguments) {
    return false
  }
  let snapshot = self.solver.snapshot()
  self.begin_call_candidate(declaration)
  let origin = call_type_origin(expression, offset)
  let mut viable = true
  for index in 0..<arguments.length {
    let parameter_type = self.instantiate_signature_type(
      self.call_parameter_type(declaration, index),
    )
    let argument = self.collected.expression_children[arguments.start + index]
    if !self.object_argument_matches_nominal_shape(argument, parameter_type) ||
      !self.solver.unify(self.expression_type(argument), parameter_type, origin) {
      viable = false
      break
    }
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(expression),
      self.instantiate_signature_type(self.call_result_type(declaration)),
      origin,
    )
  }
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::select_call_candidate(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  offset : UInt64,
) -> Unit {
  guard self.callable_exists(declaration) else {
    abort("selected call is not callable")
  }
  self.begin_call_candidate(declaration)
  let origin = call_type_origin(expression, offset)
  for index in 0..<arguments.length {
    self.constrain(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index),
      ),
      origin,
    )
  }
  self.constrain(
    self.expression_type(expression),
    self.instantiate_signature_type(self.call_result_type(declaration)),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  self.call_targets[call_slot] = SelectedInferredCallTarget(declaration, {
    start,
    length: self.call_scratch.candidate_type_arguments.length(),
  })
}

///|
fn BasicBodyInferencer::resolved_function_signature(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> (HirSpan, ResolvedTypeId)? {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyResolvedType(resolved_type) =>
      match self.resolved.types[resolved_type] {
        FunctionType(parameters, result) => Some((parameters, result))
        _ => None
      }
    _ => None
  }
}

///|
fn BasicBodyInferencer::select_function_value_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  target : ExprId,
  arguments : HirSpan,
  offset : UInt64,
) -> Bool {
  let (parameters, result) = match
    self.resolved_function_signature(self.expression_type(target)) {
    Some(signature) => signature
    None => return false
  }
  if parameters.length != arguments.length {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(
      FunctionCallArgumentCountMismatch(
        expression,
        parameters.length,
        arguments.length,
        offset,
      ),
    )
    return true
  }
  let origin = call_type_origin(expression, offset)
  for index in 0..<arguments.length {
    self.constrain(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      self.solver.resolved_type(
        self.resolved.type_arguments[parameters.start + index],
      ),
      origin,
    )
  }
  self.constrain(
    self.expression_type(expression),
    self.solver.resolved_type(result),
    origin,
  )
  self.call_targets[call_slot] = SelectedFunctionValueCallTarget(target)
  true
}

///|
fn BasicBodyInferencer::record_invalid_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  offset : UInt64,
) -> Unit {
  self.call_targets[call_slot] = ErrorInferredCallTarget
  self.poison_expression(expression)
  self.diagnose(InvalidCallTarget(expression, offset))
}

///|
fn BasicBodyInferencer::prepare_imported_value_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  target : ExprId,
  arguments : HirSpan,
  offset : UInt64,
  head : Int,
) -> Unit {
  match self.imports {
    Some(imports) => {
      self.names.expression_references[target] = ImportedValueNameReference(
        head,
      )
      let first = imports.scope.callable_references[head]
      if first.next < 0 {
        let declaration = imports.callables[head].declaration
        if !self.call_arity_matches(declaration, arguments) {
          self.call_targets[call_slot] = ErrorInferredCallTarget
          self.poison_expression(expression)
          self.diagnose(
            CallArgumentCountMismatch(
              expression,
              declaration,
              self.call_parameter_count(declaration),
              arguments.length,
              offset,
            ),
          )
        } else {
          self.select_call_candidate(
            call_slot, expression, arguments, declaration, offset,
          )
        }
      } else {
        self.call_scratch.pending_calls.push(call_slot)
      }
    }
    None => self.record_invalid_call(call_slot, expression, offset)
  }
}

///|
fn BasicBodyInferencer::prepare_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  target : ExprId,
  arguments : HirSpan,
  offset : UInt64,
) -> Unit {
  match self.collected.expressions[target] {
    HirNameExpr(name, _) => {
      self.consume_unsupported_root(target)
      match self.names.expression_references[target] {
        ModuleValueNameReference(name) =>
          match self.collected.value_bindings.get(name) {
            Some(binding) => {
              let first = self.collected.value_binding_candidates[binding.head]
              if first.next < 0 {
                let declaration = first.declaration
                let callable_index = self.callable_index_of(declaration)
                if callable_index < 0 {
                  if !self.select_function_value_call(
                      call_slot, expression, target, arguments, offset,
                    ) {
                    self.record_invalid_call(call_slot, expression, offset)
                  }
                } else if !self.call_arity_matches(declaration, arguments) {
                  self.call_targets[call_slot] = ErrorInferredCallTarget
                  self.poison_expression(expression)
                  self.diagnose(
                    CallArgumentCountMismatch(
                      expression,
                      declaration,
                      self.collected.parameters_of(declaration).length,
                      arguments.length,
                      offset,
                    ),
                  )
                } else {
                  self.select_call_candidate(
                    call_slot, expression, arguments, declaration, offset,
                  )
                }
              } else {
                self.call_scratch.pending_calls.push(call_slot)
              }
            }
            None => self.record_invalid_call(call_slot, expression, offset)
          }
        ImportedValueNameReference(head) =>
          self.prepare_imported_value_call(
            call_slot, expression, target, arguments, offset, head,
          )
        LocalNameReference(_) | ImportedModuleValueNameReference(_) =>
          if !self.select_function_value_call(
              call_slot, expression, target, arguments, offset,
            ) {
            self.record_invalid_call(call_slot, expression, offset)
          }
        VariantNameReference(_) => {
          self.consume_member_root(target)
          let variant_index = self.select_value_variant(
            name,
            self.expression_type(expression),
            expression,
            offset,
          )
          if variant_index < 0 {
            self.call_targets[call_slot] = ErrorInferredCallTarget
            self.fail_expression_selection(expression)
          } else {
            self.infer_tuple_variant_call(
              call_slot, expression, arguments, variant_index, offset,
            )
          }
        }
        _ => self.record_invalid_call(call_slot, expression, offset)
      }
    }
    HirFieldExpr(_, _, _) => {
      self.call_scratch.pending_methods.push(call_slot)
      self.consume_member_root(target)
    }
    HirQualifiedExpr(base, property, _) =>
      match self.collected.expressions[base] {
        HirImportAliasExpr(_, _) =>
          match self.names.expression_references[base] {
            ImportedModuleNameReference(interface_index) => {
              self.consume_member_root(target)
              match self.imports {
                Some(imports) =>
                  match
                    imports.scope.lookup_module_callable(
                      interface_index,
                      self.collected.name(property),
                    ) {
                    Some(head) =>
                      self.prepare_imported_value_call(
                        call_slot, expression, target, arguments, offset, head,
                      )
                    None => {
                      self.call_targets[call_slot] = ErrorInferredCallTarget
                      self.poison_expression(expression)
                      self.diagnose(
                        UnknownImportedModuleMember(
                          property, expression, offset,
                        ),
                      )
                    }
                  }
                None => self.record_invalid_call(call_slot, expression, offset)
              }
            }
            _ => self.record_invalid_call(call_slot, expression, offset)
          }
        HirNameExpr(_, _) =>
          match self.names.expression_references[base] {
            ModuleTypeNameReference(declaration) => {
              self.consume_member_root(target)
              if semantic_id_module(declaration) == self.collected.module_id {
                let variant_index = self.variant_index_in_declaration(
                  declaration, property,
                )
                if variant_index >= 0 {
                  self.infer_tuple_variant_call(
                    call_slot, expression, arguments, variant_index, offset,
                  )
                } else if !self.resolve_type_qualified_method_call(
                    call_slot,
                    expression,
                    arguments,
                    NominalImplTargetHead(declaration),
                    property,
                    offset,
                  ) {
                  self.call_targets[call_slot] = ErrorInferredCallTarget
                  self.diagnose(
                    UnknownQualifiedMember(
                      property, declaration, expression, offset,
                    ),
                  )
                  self.fail_expression_selection(expression)
                }
              } else {
                match self.imported_variant_named(declaration, property) {
                  Some(variant) =>
                    self.infer_imported_tuple_variant_call(
                      call_slot, expression, arguments, variant, offset,
                    )
                  None =>
                    if !self.resolve_type_qualified_method_call(
                        call_slot,
                        expression,
                        arguments,
                        NominalImplTargetHead(declaration),
                        property,
                        offset,
                      ) {
                      self.call_targets[call_slot] = ErrorInferredCallTarget
                      self.diagnose(
                        UnknownQualifiedMember(
                          property, declaration, expression, offset,
                        ),
                      )
                      self.fail_expression_selection(expression)
                    }
                }
              }
            }
            PrimitiveTypeNameReference(primitive) => {
              self.consume_member_root(target)
              if !self.resolve_type_qualified_method_call(
                  call_slot,
                  expression,
                  arguments,
                  PrimitiveImplTargetHead(primitive),
                  property,
                  offset,
                ) {
                self.call_targets[call_slot] = ErrorInferredCallTarget
                self.diagnose(NoMatchingMethod(property, expression, offset))
                self.fail_expression_selection(expression)
              }
            }
            ModuleTraitNameReference(declaration) => {
              self.consume_member_root(target)
              if !self.resolve_trait_qualified_method_call(
                  call_slot, expression, arguments, declaration, property, offset,
                ) {
                self.call_targets[call_slot] = ErrorInferredCallTarget
                self.diagnose(
                  UnknownQualifiedMember(
                    property, declaration, expression, offset,
                  ),
                )
                self.fail_expression_selection(expression)
              }
            }
            _ => {
              self.mark_unsupported(expression)
              self.consume_member_root(target)
            }
          }
        _ => {
          self.mark_unsupported(expression)
          self.consume_member_root(target)
        }
      }
    _ =>
      if !self.select_function_value_call(
          call_slot, expression, target, arguments, offset,
        ) {
        self.mark_unsupported(expression)
        self.consume_member_root(target)
      }
  }
}

///|
fn BasicBodyInferencer::trial_overload(
  self : BasicBodyInferencer,
  expression : ExprId,
  reference : BodyNameReference,
  arguments : HirSpan,
  offset : UInt64,
) -> Unit {
  self.call_scratch.trial_viable_count = 0
  self.call_scratch.trial_first_declaration = 0UL
  self.call_scratch.trial_second_declaration = 0UL
  self.call_scratch.overload_candidates.clear()
  match reference {
    ModuleValueNameReference(name) => {
      let binding = self.collected.value_bindings.get(name).unwrap()
      let mut cursor = binding.head
      while cursor >= 0 {
        let candidate = self.collected.value_binding_candidates[cursor]
        if self.declaration_visible(candidate.declaration) {
          self.call_scratch.overload_candidates.push(candidate.declaration)
        }
        cursor = candidate.next
      }
    }
    ImportedValueNameReference(head) =>
      match self.imports {
        Some(imports) => {
          let mut cursor = head
          while cursor >= 0 {
            self.call_scratch.overload_candidates.push(
              imports.callables[cursor].declaration,
            )
            cursor = imports.scope.callable_references[cursor].next
          }
        }
        None => ()
      }
    _ => abort("overload trial reference is not a value binding")
  }
  let mut previous_generic_count = -1
  while true {
    let mut next_generic_count = 0x7fffffff
    for declaration in self.call_scratch.overload_candidates {
      let generic_count = self.call_generic_count(declaration)
      if generic_count > previous_generic_count &&
        generic_count < next_generic_count {
        next_generic_count = generic_count
      }
    }
    if next_generic_count == 0x7fffffff {
      return
    }
    for declaration in self.call_scratch.overload_candidates {
      if self.call_generic_count(declaration) == next_generic_count &&
        self.try_call_candidate(expression, arguments, declaration, offset) {
        self.call_scratch.trial_viable_count += 1
        if self.call_scratch.trial_viable_count == 1 {
          self.call_scratch.trial_first_declaration = declaration
        } else if self.call_scratch.trial_viable_count == 2 {
          self.call_scratch.trial_second_declaration = declaration
        }
      }
    }
    if self.call_scratch.trial_viable_count > 0 {
      return
    }
    previous_generic_count = next_generic_count
  }
}

///|
fn BasicBodyInferencer::call_has_poison(
  self : BasicBodyInferencer,
  expression : ExprId,
  arguments : HirSpan,
) -> Bool {
  if self.solver.representative_type(self.expression_type(expression)) ==
    self.solver.error_type() {
    return true
  }
  for index in 0..<arguments.length {
    if self.solver.representative_type(
        self.expression_type(
          self.collected.expression_children[arguments.start + index],
        ),
      ) ==
      self.solver.error_type() {
      return true
    }
  }
  false
}

///|
fn BasicBodyInferencer::constrain_pending_calls(
  self : BasicBodyInferencer,
) -> Unit {
  while self.call_scratch.pending_calls.length() > 0 {
    self.call_scratch.deferred_calls.clear()
    let mut progress = false
    for call_slot in self.call_scratch.pending_calls {
      let expression = self.call_expressions[call_slot]
      let (target, arguments, offset) = match
        self.collected.expressions[expression] {
        HirCallExpr(target, arguments, offset) => (target, arguments, offset)
        _ => abort("pending call does not reference a call expression")
      }
      let reference = self.names.expression_references[target]
      self.trial_overload(expression, reference, arguments, offset)
      if self.call_scratch.trial_viable_count == 1 {
        self.select_call_candidate(
          call_slot,
          expression,
          arguments,
          self.call_scratch.trial_first_declaration,
          offset,
        )
        progress = true
      } else {
        self.call_scratch.deferred_calls.push(call_slot)
      }
    }
    self.call_scratch.pending_calls.clear()
    for call_slot in self.call_scratch.deferred_calls {
      self.call_scratch.pending_calls.push(call_slot)
    }
    if !progress {
      break
    }
  }
  for call_slot in self.call_scratch.pending_calls {
    let expression = self.call_expressions[call_slot]
    let (target, arguments, offset) = match
      self.collected.expressions[expression] {
      HirCallExpr(target, arguments, offset) => (target, arguments, offset)
      _ => abort("pending call does not reference a call expression")
    }
    let name = match self.collected.expressions[target] {
      HirNameExpr(name, _) => name
      _ => abort("pending overload target is not a name")
    }
    let reference = self.names.expression_references[target]
    self.call_targets[call_slot] = ErrorInferredCallTarget
    if self.call_has_poison(expression, arguments) {
      self.poison_expression(expression)
      continue
    }
    self.trial_overload(expression, reference, arguments, offset)
    self.poison_expression(expression)
    if self.call_scratch.trial_viable_count == 0 {
      if !self.call_has_object_argument(arguments) {
        self.diagnose(NoMatchingCallOverload(name, expression, offset))
      }
    } else {
      self.diagnose(
        AmbiguousCallOverload(
          name,
          expression,
          self.call_scratch.trial_first_declaration,
          self.call_scratch.trial_second_declaration,
          self.call_scratch.trial_viable_count,
          offset,
        ),
      )
    }
  }
}

///|
fn BasicBodyInferencer::constrain_calls(self : BasicBodyInferencer) -> Unit {
  let mut call_slot = self.call_expressions.length()
  while call_slot > 0 {
    call_slot -= 1
    let expression = self.call_expressions[call_slot]
    match self.collected.expressions[expression] {
      HirCallExpr(target, arguments, offset) =>
        self.prepare_call(call_slot, expression, target, arguments, offset)
      _ => abort("recorded call does not reference a call expression")
    }
  }
  self.constrain_pending_calls()
}

///|
fn BasicBodyInferencer::is_function_reference(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Bool {
  if !self.has_member_expressions {
    return false
  }
  match self.expression_selections[self.expression_index(expression)] {
    FunctionReferenceSelection(_) => true
    _ => false
  }
}

///|
fn BasicBodyInferencer::constrain_name_expressions(
  self : BasicBodyInferencer,
) -> Unit {
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    match self.collected.expressions[expression] {
      HirNameExpr(_, _) =>
        match self.names.expression_references[expression] {
          LocalNameReference(_) | ErrorNameReference => ()
          ModuleValueNameReference(name) =>
            if self.module_value_type(name) is None &&
              !self.is_function_reference(expression) {
              self.mark_unsupported(expression)
            }
          ImportedValueNameReference(_) =>
            if !self.is_function_reference(expression) {
              self.mark_unsupported(expression)
            }
          ImportedModuleNameReference(_) => self.mark_unsupported(expression)
          ImportedModuleValueNameReference(_) => ()
          VariantNameReference(_) => ()
          PrimitiveTypeNameReference(_)
          | ModuleTypeNameReference(_)
          | ModuleTraitNameReference(_)
          | NoNameReference => self.mark_unsupported(expression)
        }
      HirImportAliasExpr(_, _) => self.mark_unsupported(expression)
      _ => ()
    }
  }
}

///|
fn BasicBodyInferencer::constrain_block_items(
  self : BasicBodyInferencer,
) -> Unit {
  let unit = self.primitive(UnitType)
  for
    item in self.body.block_items.start..<(self.body.block_items.start +
    self.body.block_items.length) {
    match self.collected.block_items[item] {
      HirLetItem(_, _, name_offset, value, _) => {
        let local_id = self.names.block_item_locals[item]
        self.constrain(
          self.local_types[local_id],
          self.expression_type(value),
          local_type_origin(local_id, name_offset),
        )
      }
      HirReturnItem(value, offset) =>
        if self.callable_index < 0 {
          self.diagnose(ReturnOutsideCallable(offset))
        } else if value >= 0 {
          self.constrain_assignable(
            self.expression_type(value),
            self.declared_return_type,
            return_type_origin(value, offset),
          )
        } else {
          self.constrain(
            unit,
            self.declared_return_type,
            return_type_origin(-1, offset),
          )
        }
      HirExpressionItem(_, _) => ()
    }
  }
}

///|
fn BasicBodyInferencer::constrain_if_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
  condition : ExprId,
  block : BlockId,
  alternative : ExprId,
  offset : UInt64,
) -> Unit {
  let result = self.expression_type(expression)
  self.constrain(
    self.expression_type(condition),
    self.primitive(BoolType),
    expression_type_origin(condition, offset),
  )
  if alternative < 0 {
    self.constrain(
      result,
      self.primitive(UnitType),
      expression_type_origin(expression, offset),
    )
    return
  }
  let then_type = self.block_type(block)
  let else_type = self.expression_type(alternative)
  if self.is_never_type(then_type) && self.is_never_type(else_type) {
    self.constrain(
      result,
      self.primitive(NeverType),
      expression_type_origin(expression, offset),
    )
  } else {
    self.constrain_assignable(
      then_type,
      result,
      expression_type_origin(expression, offset),
    )
    self.constrain_assignable(
      else_type,
      result,
      expression_type_origin(expression, offset),
    )
  }
}

///|
fn BasicBodyInferencer::constrain_prefix_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
  operator : HirPrefixOperator,
  value : ExprId,
  offset : UInt64,
) -> Unit {
  let result = self.expression_type(expression)
  let operand = self.expression_type(value)
  match operator {
    HirLogicalNot => {
      let bool_type = self.primitive(BoolType)
      self.constrain(
        operand,
        bool_type,
        operator_type_origin(expression, offset),
      )
      self.constrain(
        result,
        bool_type,
        operator_type_origin(expression, offset),
      )
    }
    HirPositive | HirNegative =>
      self.constrain(result, operand, operator_type_origin(expression, offset))
  }
}

///|
fn binary_operator_trait(operator : HirBinaryOperator) -> (String, String)? {
  match operator {
    HirLogicalOr | HirLogicalAnd => None
    HirBitOr => Some(("BitOr", "bit_or"))
    HirBitXor => Some(("BitXor", "bit_xor"))
    HirBitAnd => Some(("BitAnd", "bit_and"))
    HirEqual => Some(("Eq", "eq"))
    HirNotEqual => Some(("Ne", "ne"))
    HirLess => Some(("Lt", "lt"))
    HirLessEqual => Some(("Lte", "lte"))
    HirGreater => Some(("Gt", "gt"))
    HirGreaterEqual => Some(("Gte", "gte"))
    HirShiftLeft => Some(("Shl", "shl"))
    HirShiftRight => Some(("Shr", "shr"))
    HirAdd => Some(("Add", "add"))
    HirSubtract => Some(("Sub", "sub"))
    HirMultiply => Some(("Mul", "mul"))
    HirDivide => Some(("Div", "div"))
    HirRemainder => Some(("Rem", "rem"))
    HirExponentiate => Some(("Pow", "pow"))
  }
}

///|
fn BasicBodyInferencer::constrain_binary_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
  operator : HirBinaryOperator,
  left : ExprId,
  right : ExprId,
  offset : UInt64,
) -> Unit {
  let result = self.expression_type(expression)
  let left_type = self.expression_type(left)
  let right_type = self.expression_type(right)
  let origin = operator_type_origin(expression, offset)
  match binary_operator_trait(operator) {
    Some((trait_name, method_name)) =>
      match
        (
          self.trait_declaration_named(trait_name),
          self.collected.find_name(method_name),
        ) {
        (Some(_), Some(_)) => {
          self.call_scratch.pending_operators.push(expression)
          return
        }
        _ => ()
      }
    None => ()
  }
  match operator {
    HirLogicalOr | HirLogicalAnd => {
      let bool_type = self.primitive(BoolType)
      self.constrain_assignable(left_type, bool_type, origin)
      self.constrain_assignable(right_type, bool_type, origin)
      self.constrain(result, bool_type, origin)
    }
    HirEqual
    | HirNotEqual
    | HirLess
    | HirLessEqual
    | HirGreater
    | HirGreaterEqual => {
      self.constrain(left_type, right_type, origin)
      self.constrain(result, self.primitive(BoolType), origin)
    }
    HirBitOr
    | HirBitXor
    | HirBitAnd
    | HirShiftLeft
    | HirShiftRight
    | HirAdd
    | HirSubtract
    | HirMultiply
    | HirDivide
    | HirRemainder
    | HirExponentiate => {
      self.constrain(left_type, right_type, origin)
      self.constrain(result, left_type, origin)
    }
  }
}

///|
fn BasicBodyInferencer::constrain_match_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
  scrutinee : ExprId,
  arms : HirSpan,
  offset : UInt64,
) -> Unit {
  let expected = self.expression_type(scrutinee)
  let result = self.expression_type(expression)
  let mut all_never = arms.length > 0
  for index in 0..<arms.length {
    let arm_id = self.collected.arm_children[arms.start + index]
    let arm = self.collected.pattern_arms[arm_id]
    self.infer_pattern(arm.pattern, expected)
    if arm.guard_condition >= 0 {
      self.constrain(
        self.expression_type(arm.guard_condition),
        self.primitive(BoolType),
        expression_type_origin(arm.guard_condition, arm.offset),
      )
    }
    let body_type = self.expression_type(arm.body)
    if !self.is_never_type(body_type) {
      all_never = false
      self.constrain_assignable(
        body_type,
        result,
        expression_type_origin(expression, offset),
      )
    }
  }
  if all_never {
    self.constrain(
      result,
      self.primitive(NeverType),
      expression_type_origin(expression, offset),
    )
  }
}

///|
fn BasicBodyInferencer::constrain_while_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
  initial : ExprId,
  arms : HirSpan,
  offset : UInt64,
) -> Unit {
  let control = self.names.expression_controls[expression]
  if control < 0 {
    self.poison_expression(expression)
    return
  }
  let state = self.control_state_types[control]
  self.constrain(
    self.expression_type(initial),
    state,
    expression_type_origin(expression, offset),
  )
  for index in 0..<arms.length {
    let arm_id = self.collected.arm_children[arms.start + index]
    let arm = self.collected.pattern_arms[arm_id]
    self.infer_pattern(arm.pattern, state)
    if arm.guard_condition >= 0 {
      self.constrain(
        self.expression_type(arm.guard_condition),
        self.primitive(BoolType),
        expression_type_origin(arm.guard_condition, arm.offset),
      )
    }
  }
}

///|
fn BasicBodyInferencer::constrain_transfer_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
  value : ExprId,
  break_ : Bool,
  offset : UInt64,
) -> Unit {
  let control = self.names.transfer_targets[expression]
  if control < 0 {
    return
  }
  let expected = if break_ {
    self.control_result_types[control]
  } else {
    self.control_state_types[control]
  }
  self.constrain_assignable(
    self.expression_type(value),
    expected,
    expression_type_origin(expression, offset),
  )
}

///|
fn BasicBodyInferencer::constrain_control_results(
  self : BasicBodyInferencer,
) -> Unit {
  let has_break = Array::make(self.name_info.controls.length, false)
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    match self.collected.expressions[expression] {
      HirBreakExpr(_, _) => {
        let control = self.names.transfer_targets[expression]
        if control >= 0 {
          has_break[control] = true
        }
      }
      _ => ()
    }
  }
  for control in 0..<has_break.length() {
    if !has_break[control] {
      self.constrain(
        self.control_result_types[control],
        self.primitive(NeverType),
        synthetic_type_origin(control, self.body.offset),
      )
    }
  }
}

///|
fn BasicBodyInferencer::constrain_expressions(
  self : BasicBodyInferencer,
) -> Unit {
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    match self.collected.expressions[expression] {
      HirI8Expr(_, _)
      | HirI16Expr(_, _)
      | HirI32Expr(_, _)
      | HirI64Expr(_, _)
      | HirU8Expr(_, _)
      | HirU16Expr(_, _)
      | HirU32Expr(_, _)
      | HirU64Expr(_, _)
      | HirF32Expr(_, _)
      | HirF64Expr(_, _)
      | HirBoolExpr(_, _)
      | HirStringExpr(_, _)
      | HirBytesExpr(_, _)
      | HirNameExpr(_, _)
      | HirImportAliasExpr(_, _) => ()
      HirLambdaExpr(_, _) => self.mark_unsupported(expression)
      HirBreakExpr(value, offset) =>
        self.constrain_transfer_expression(expression, value, true, offset)
      HirContinueExpr(value, offset) =>
        self.constrain_transfer_expression(expression, value, false, offset)
      HirBlockExpr(_, _) => ()
      HirIfExpr(condition, block, alternative, offset) =>
        self.constrain_if_expression(
          expression, condition, block, alternative, offset,
        )
      HirPrefixExpr(operator, value, offset) =>
        self.constrain_prefix_expression(expression, operator, value, offset)
      HirBinaryExpr(operator, left, right, offset) =>
        self.constrain_binary_expression(
          expression, operator, left, right, offset,
        )
      HirConstructExpr(_, _, _)
      | HirQualifiedExpr(_, _, _)
      | HirFieldExpr(_, _, _) => ()
      HirCallExpr(_, _, _) => ()
      HirMatchExpr(scrutinee, arms, offset) =>
        self.constrain_match_expression(expression, scrutinee, arms, offset)
      HirWhileExpr(initial, arms, offset) =>
        self.constrain_while_expression(expression, initial, arms, offset)
      HirObjectExpr(_, _) => ()
      HirIndexExpr(_, _, _) | HirIndexSetExpr(_, _, _, _) =>
        match index_trait(self.collected.expressions[expression]) {
          Some((trait_name, method_name)) =>
            match
              (
                self.trait_declaration_named(trait_name),
                self.collected.find_name(method_name),
              ) {
              (Some(_), Some(_)) =>
                self.call_scratch.pending_operators.push(expression)
              _ => self.mark_unsupported(expression)
            }
          None => self.mark_unsupported(expression)
        }
    }
  }
}

///|
fn BasicBodyInferencer::constrain_root(self : BasicBodyInferencer) -> Unit {
  self.result_type = match self.body.root {
    ExpressionBodyRoot(expression) => self.expression_type(expression)
    BlockBodyRoot(block) => self.block_type(block)
  }
  if self.callable_index >= 0 {
    self.constrain_assignable(
      self.result_type,
      self.declared_return_type,
      return_type_origin(semantic_id_local(self.body.id), self.body.offset),
    )
  } else if self.body.kind == ModuleLetBody {
    match self.module_values {
      Some(module_values) => {
        let let_index = module_values.let_index(self.body.declaration)
        if let_index >= 0 && module_values.slots[let_index] != -1 {
          self.constrain(
            self.result_type,
            module_values.slots[let_index],
            synthetic_type_origin(let_index, self.body.offset),
          )
        }
      }
      None => abort("module let inference has no module value context")
    }
  }
}

///|
fn BodyInferenceDiagnostic::rank(self : BodyInferenceDiagnostic) -> Int {
  match self {
    BodyConstraintDiagnostic(_) => 0
    ReturnOutsideCallable(_) => 1
    InvalidCallTarget(_, _) => 2
    FunctionCallArgumentCountMismatch(_, _, _, _) => 3
    CallArgumentCountMismatch(_, _, _, _, _) => 4
    NoMatchingCallOverload(_, _, _) => 5
    AmbiguousCallOverload(_, _, _, _, _, _) => 6
    UnresolvedCallTypeArgument(_, _, _) => 7
    UnresolvedModuleValue(_, _) => 8
    InvalidPatternConstructor(_, _) => 9
    UnknownVariantForType(_, _, _, _) => 10
    AmbiguousPatternVariant(_, _, _, _, _, _) => 11
    PatternPayloadKindMismatch(_, _, _) => 12
    PatternPayloadArityMismatch(_, _, _, _) => 13
    UnknownPatternField(_, _, _) => 14
    MissingPatternField(_, _, _) => 15
    MissingImportedPatternField(_, _, _) => 16
    UnresolvedPatternTypeArgument(_, _, _) => 17
    InvalidConstructionTarget(_, _) => 18
    ObjectTypeRequired(_, _) => 19
    ConstructionPayloadKindMismatch(_, _, _) => 20
    ConstructionPayloadArityMismatch(_, _, _, _, _) => 21
    UnknownVariantValue(_, _, _) => 22
    AmbiguousVariantValue(_, _, _, _, _, _) => 23
    DuplicateConstructionField(_, _, _) => 24
    UnknownConstructionField(_, _, _) => 25
    MissingConstructionField(_, _, _) => 26
    FieldAccessRequiresNominal(_, _) => 27
    UnknownFieldForType(_, _, _, _) => 28
    UnknownQualifiedMember(_, _, _, _) => 29
    UnknownImportedModuleMember(_, _, _) => 30
    NoMatchingMethod(_, _, _) => 31
    AmbiguousMethod(_, _, _, _, _, _) => 32
    UnresolvedExpressionTypeArgument(_, _, _) => 33
    UnsupportedExpressionInference(_, _) => 34
    UnresolvedExpressionType(_, _) => 35
    UnresolvedLocalType(_, _, _) => 36
    NumericLiteralOutOfRange(_, _, _) => 37
  }
}

///|
fn BasicBodyInferencer::sort_diagnostics(self : BasicBodyInferencer) -> Unit {
  self.diagnostics.sort_by(fn(left, right) {
    let offset_order = left.offset().compare(right.offset())
    if offset_order != 0 {
      offset_order
    } else {
      left.rank() - right.rank()
    }
  })
}

///|
fn BasicBodyInferencer::finalize_types(self : BasicBodyInferencer) -> Unit {
  for index in self.solver_diagnostic_start..<self.solver_diagnostic_end {
    self.diagnostics.push(
      BodyConstraintDiagnostic(self.solver.diagnostics[index]),
    )
  }
  for index in 0..<self.unsupported_expressions.length() {
    if self.unsupported_expressions[index] {
      let expression = self.body.expressions.start + index
      self.diagnose(
        UnsupportedExpressionInference(
          expression,
          self.collected.expressions[expression].offset(),
        ),
      )
    }
  }
  for call_slot in 0..<self.call_targets.length() {
    match self.call_targets[call_slot] {
      SelectedInferredCallTarget(_, arguments) =>
        for argument_index in 0..<arguments.length {
          let slot = arguments.start + argument_index
          let frozen = self.solver.zonk_type(self.call_type_arguments[slot])
          self.call_type_arguments[slot] = frozen
          if self.solver.has_unresolved_variable(frozen) {
            let expression = self.call_expressions[call_slot]
            self.diagnose(
              UnresolvedCallTypeArgument(
                expression,
                argument_index,
                self.collected.expressions[expression].offset(),
              ),
            )
          }
        }
      NoInferredCallTarget
      | ErrorInferredCallTarget
      | SelectedFunctionValueCallTarget(_) => ()
    }
  }
  for expression_index in 0..<self.operator_targets.length() {
    match self.operator_targets[expression_index] {
      SelectedInferredCallTarget(_, arguments) =>
        for argument_index in 0..<arguments.length {
          let slot = arguments.start + argument_index
          let frozen = self.solver.zonk_type(self.call_type_arguments[slot])
          self.call_type_arguments[slot] = frozen
          if self.solver.has_unresolved_variable(frozen) {
            let expression = self.body.expressions.start + expression_index
            self.diagnose(
              UnresolvedCallTypeArgument(
                expression,
                argument_index,
                self.collected.expressions[expression].offset(),
              ),
            )
          }
        }
      NoInferredCallTarget
      | ErrorInferredCallTarget
      | SelectedFunctionValueCallTarget(_) => ()
    }
  }
  for targets in [self.map_hash_targets, self.map_eq_targets] {
    for expression_index in 0..<targets.length() {
      match targets[expression_index] {
        SelectedInferredCallTarget(_, arguments) =>
          for argument_index in 0..<arguments.length {
            let slot = arguments.start + argument_index
            let frozen = self.solver.zonk_type(self.call_type_arguments[slot])
            self.call_type_arguments[slot] = frozen
            if self.solver.has_unresolved_variable(frozen) {
              let expression = self.body.expressions.start + expression_index
              self.diagnose(
                UnresolvedCallTypeArgument(
                  expression,
                  argument_index,
                  self.collected.expressions[expression].offset(),
                ),
              )
            }
          }
        NoInferredCallTarget
        | ErrorInferredCallTarget
        | SelectedFunctionValueCallTarget(_) => ()
      }
    }
  }
  for expression_index in 0..<self.expression_selections.length() {
    match self.expression_selections[expression_index] {
      StructConstructionSelection(_, arguments)
      | VariantConstructionSelection(_, arguments)
      | UnitVariantValueSelection(_, arguments) =>
        for argument_index in 0..<arguments.length {
          let slot = arguments.start + argument_index
          let frozen = self.solver.zonk_type(
            self.expression_type_arguments[slot],
          )
          self.expression_type_arguments[slot] = frozen
          if self.solver.has_unresolved_variable(frozen) {
            let expression = self.body.expressions.start + expression_index
            self.diagnose(
              UnresolvedExpressionTypeArgument(
                expression,
                argument_index,
                self.collected.expressions[expression].offset(),
              ),
            )
          }
        }
      NoExpressionSelection
      | ErrorExpressionSelection
      | FieldAccessSelection(_)
      | ImportedModuleValueSelection(_)
      | FunctionReferenceSelection(_) => ()
    }
  }
  for pattern_index in 0..<self.pattern_constructors.length() {
    match self.pattern_constructors[pattern_index] {
      StructInferredPatternConstructor(_, arguments)
      | VariantInferredPatternConstructor(_, arguments) =>
        for argument_index in 0..<arguments.length {
          let slot = arguments.start + argument_index
          let frozen = self.solver.zonk_type(self.pattern_type_arguments[slot])
          self.pattern_type_arguments[slot] = frozen
          if self.solver.has_unresolved_variable(frozen) {
            let pattern = self.body.patterns.start + pattern_index
            self.diagnose(
              UnresolvedPatternTypeArgument(
                pattern,
                argument_index,
                self.collected.patterns[pattern].offset(),
              ),
            )
          }
        }
      NoInferredPatternConstructor | ErrorInferredPatternConstructor => ()
    }
  }
  for index in 0..<self.expression_types.length() {
    let expression = self.body.expressions.start + index
    let frozen = self.solver.zonk_type(self.expression_types[index])
    self.expression_types[index] = frozen
    if !self.unsupported_expressions[index] &&
      (
        self.consumed_member_roots.length() == 0 ||
        !self.consumed_member_roots[index]
      ) &&
      self.solver.has_unresolved_variable(frozen) {
      self.diagnose(
        UnresolvedExpressionType(
          expression,
          self.collected.expressions[expression].offset(),
        ),
      )
    }
  }
  for local_id in 0..<self.local_types.length() {
    let frozen = self.solver.zonk_type(self.local_types[local_id])
    self.local_types[local_id] = frozen
    if self.solver.has_unresolved_variable(frozen) {
      let local_info = self.names.locals[self.name_info.locals.start + local_id]
      self.diagnose(
        UnresolvedLocalType(self.body.id, local_id, local_info.offset),
      )
    }
  }
  for index in 0..<self.block_types.length() {
    self.block_types[index] = self.solver.zonk_type(self.block_types[index])
  }
  for index in 0..<self.pattern_types.length() {
    self.pattern_types[index] = self.solver.zonk_type(self.pattern_types[index])
  }
  for index in 0..<self.control_state_types.length() {
    self.control_state_types[index] = self.solver.zonk_type(
      self.control_state_types[index],
    )
    self.control_result_types[index] = self.solver.zonk_type(
      self.control_result_types[index],
    )
  }
  self.result_type = self.solver.zonk_type(self.result_type)
  self.sort_diagnostics()
}

///|
fn BasicBodyInferencer::mark_compact_type(
  self : BasicBodyInferencer,
  root : BodyTypeId,
) -> Unit {
  self.compact_stack.push(root)
  while self.compact_stack.length() > 0 {
    let type_ = self.compact_stack.pop().unwrap()
    if type_ <= 0 || self.compact_marks[type_] {
      continue
    }
    self.compact_marks[type_] = true
    match self.solver.types[type_] {
      BodyAppliedType(base, arguments) => {
        let mut index = arguments.length
        while index > 0 {
          index -= 1
          self.compact_stack.push(
            self.solver.type_arguments[arguments.start + index],
          )
        }
        self.compact_stack.push(base)
      }
      _ => ()
    }
  }
}

///|
fn BasicBodyInferencer::mark_compact_roots(self : BasicBodyInferencer) -> Unit {
  self.mark_compact_type(self.result_type)
  for type_ in self.expression_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.local_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.block_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.pattern_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.pattern_type_arguments {
    self.mark_compact_type(type_)
  }
  for type_ in self.expression_type_arguments {
    self.mark_compact_type(type_)
  }
  for type_ in self.control_state_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.control_result_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.call_type_arguments {
    self.mark_compact_type(type_)
  }
  for diagnostic in self.diagnostics {
    match diagnostic {
      BodyConstraintDiagnostic(LocalTypeMismatch(left, right, _)) => {
        self.mark_compact_type(left)
        self.mark_compact_type(right)
      }
      BodyConstraintDiagnostic(InfiniteLocalType(_, type_, _)) =>
        self.mark_compact_type(type_)
      _ => ()
    }
  }
}

///|
fn BasicBodyInferencer::compact_type_id(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> BodyTypeId {
  if type_ <= 0 {
    type_
  } else {
    self.compact_mapping[type_]
  }
}

///|
fn BasicBodyInferencer::has_positive_compact_root(
  self : BasicBodyInferencer,
) -> Bool {
  if self.result_type > 0 {
    return true
  }
  for type_ in self.expression_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.local_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.block_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.pattern_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.pattern_type_arguments {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.expression_type_arguments {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.control_state_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.control_result_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.call_type_arguments {
    if type_ > 0 {
      return true
    }
  }
  for diagnostic in self.diagnostics {
    match diagnostic {
      BodyConstraintDiagnostic(LocalTypeMismatch(left, right, _)) =>
        if left > 0 || right > 0 {
          return true
        }
      BodyConstraintDiagnostic(InfiniteLocalType(_, type_, _)) =>
        if type_ > 0 {
          return true
        }
      _ => ()
    }
  }
  false
}

///|
fn BasicBodyInferencer::build_compact_types(self : BasicBodyInferencer) -> Unit {
  self.compact_types.clear()
  self.compact_arguments.clear()
  self.compact_types.push(BodyErrorType)
  if !self.has_positive_compact_root() {
    self.compact_marks = []
    self.compact_mapping = []
    return
  }
  self.compact_marks = Array::make(self.solver.types.length(), false)
  self.compact_mapping = Array::make(self.solver.types.length(), -1)
  self.compact_mapping[0] = 0
  self.mark_compact_roots()
  for old_id in 1..<self.solver.types.length() {
    if !self.compact_marks[old_id] {
      continue
    }
    let new_id = self.compact_types.length()
    self.compact_mapping[old_id] = new_id
    match self.solver.types[old_id] {
      BodyVariableType(variable) =>
        self.compact_types.push(BodyVariableType(variable))
      BodyAppliedType(base, arguments) => {
        let start = self.compact_arguments.length()
        for index in 0..<arguments.length {
          self.compact_arguments.push(
            self.compact_type_id(
              self.solver.type_arguments[arguments.start + index],
            ),
          )
        }
        self.compact_types.push(
          BodyAppliedType(self.compact_type_id(base), {
            start,
            length: arguments.length,
          }),
        )
      }
      BodyErrorType | BodyResolvedType(_) =>
        abort("unexpected stored body type during compaction")
    }
  }
}

///|
fn BasicBodyInferencer::remap_diagnostics(self : BasicBodyInferencer) -> Unit {
  for index in 0..<self.diagnostics.length() {
    self.diagnostics[index] = match self.diagnostics[index] {
      BodyConstraintDiagnostic(LocalTypeMismatch(left, right, origin)) =>
        BodyConstraintDiagnostic(
          LocalTypeMismatch(
            self.compact_type_id(left),
            self.compact_type_id(right),
            origin,
          ),
        )
      BodyConstraintDiagnostic(InfiniteLocalType(variable, type_, origin)) =>
        BodyConstraintDiagnostic(
          InfiniteLocalType(variable, self.compact_type_id(type_), origin),
        )
      other => other
    }
  }
}

///|
fn BasicBodyInferencer::compact_results(self : BasicBodyInferencer) -> Unit {
  self.build_compact_types()
  self.result_type = self.compact_type_id(self.result_type)
  for index in 0..<self.expression_types.length() {
    self.expression_types[index] = self.compact_type_id(
      self.expression_types[index],
    )
  }
  for index in 0..<self.local_types.length() {
    self.local_types[index] = self.compact_type_id(self.local_types[index])
  }
  for index in 0..<self.block_types.length() {
    self.block_types[index] = self.compact_type_id(self.block_types[index])
  }
  for index in 0..<self.pattern_types.length() {
    self.pattern_types[index] = self.compact_type_id(self.pattern_types[index])
  }
  for index in 0..<self.pattern_type_arguments.length() {
    self.pattern_type_arguments[index] = self.compact_type_id(
      self.pattern_type_arguments[index],
    )
  }
  for index in 0..<self.expression_type_arguments.length() {
    self.expression_type_arguments[index] = self.compact_type_id(
      self.expression_type_arguments[index],
    )
  }
  for index in 0..<self.control_state_types.length() {
    self.control_state_types[index] = self.compact_type_id(
      self.control_state_types[index],
    )
    self.control_result_types[index] = self.compact_type_id(
      self.control_result_types[index],
    )
  }
  for index in 0..<self.call_type_arguments.length() {
    self.call_type_arguments[index] = self.compact_type_id(
      self.call_type_arguments[index],
    )
  }
  self.remap_diagnostics()
}

///|
fn BasicBodyInferencer::constrain_body(self : BasicBodyInferencer) -> Unit {
  self.solver_diagnostic_start = self.solver.diagnostics.length()
  self.initialize_local_types()
  if self.name_info.controls.length > 0 {
    self.initialize_control_types()
  }
  self.initialize_expression_types()
  self.initialize_block_types()
  self.reuse_block_expression_types()
  self.initialize_return_type()
  self.constrain_name_expressions()
  self.constrain_block_items()
  self.constrain_expressions()
  if self.name_info.controls.length > 0 {
    self.constrain_control_results()
  }
  self.constrain_root()
  self.constrain_calls()
  self.constrain_members(false)
  self.constrain_method_calls()
  self.constrain_operator_calls()
  self.constrain_members(true)
  self.solver_diagnostic_end = self.solver.diagnostics.length()
}

///|
fn BasicBodyInferencer::finish(
  self : BasicBodyInferencer,
) -> BodyInferenceJobResult {
  self.finalize_types()
  self.compact_results()
  {
    result_type: self.result_type,
    types: self.compact_types,
    type_arguments: self.compact_arguments,
    expression_types: self.expression_types,
    local_types: self.local_types,
    block_types: self.block_types,
    pattern_types: self.pattern_types,
    pattern_constructors: self.pattern_constructors,
    pattern_type_arguments: self.pattern_type_arguments,
    control_state_types: self.control_state_types,
    control_result_types: self.control_result_types,
    expression_selections: self.expression_selections,
    expression_type_arguments: self.expression_type_arguments,
    object_field_targets: self.object_field_targets,
    call_expressions: self.call_expressions,
    call_targets: self.call_targets,
    operator_targets: self.operator_targets,
    map_hash_targets: self.map_hash_targets,
    map_eq_targets: self.map_eq_targets,
    call_type_arguments: self.call_type_arguments,
    diagnostics: self.diagnostics,
  }
}

///|
fn BasicBodyInferencer::run(
  self : BasicBodyInferencer,
) -> BodyInferenceJobResult {
  self.constrain_body()
  self.finish()
}

///|
fn callable_indices_by_declaration(collected : CollectedModule) -> Array[Int] {
  let indices = Array::make(collected.declaration_locations.length(), -1)
  for index, callable in collected.callables {
    indices[semantic_id_local(callable.declaration)] = index
  }
  indices
}

///|
fn field_spans_by_declaration(collected : CollectedModule) -> Array[HirSpan] {
  if collected.fields.length() == 0 {
    return []
  }
  let spans = Array::make(collected.declaration_locations.length(), {
    start: 0,
    length: 0,
  })
  for index, field in collected.fields {
    let declaration_index = semantic_id_local(field.declaration)
    if spans[declaration_index].length == 0 {
      spans[declaration_index] = { start: index, length: 1 }
    } else {
      spans[declaration_index] = {
        start: spans[declaration_index].start,
        length: spans[declaration_index].length + 1,
      }
    }
  }
  spans
}

///|
fn variant_spans_by_declaration(collected : CollectedModule) -> Array[HirSpan] {
  if collected.variants.length() == 0 {
    return []
  }
  let spans = Array::make(collected.declaration_locations.length(), {
    start: 0,
    length: 0,
  })
  for index, variant in collected.variants {
    let local_index = semantic_id_local(variant.declaration)
    if spans[local_index].length == 0 {
      spans[local_index] = { start: index, length: 1 }
    } else {
      spans[local_index] = {
        start: spans[local_index].start,
        length: spans[local_index].length + 1,
      }
    }
  }
  spans
}

///|
fn remap_job_type(type_ : BodyTypeId, type_start : Int) -> BodyTypeId {
  if type_ <= 0 {
    type_
  } else {
    type_start + type_ - 1
  }
}

///|
fn remap_job_diagnostic(
  diagnostic : BodyInferenceDiagnostic,
  type_start : Int,
) -> BodyInferenceDiagnostic {
  match diagnostic {
    BodyConstraintDiagnostic(LocalTypeMismatch(left, right, origin)) =>
      BodyConstraintDiagnostic(
        LocalTypeMismatch(
          remap_job_type(left, type_start),
          remap_job_type(right, type_start),
          origin,
        ),
      )
    BodyConstraintDiagnostic(InfiniteLocalType(variable, type_, origin)) =>
      BodyConstraintDiagnostic(
        InfiniteLocalType(variable, remap_job_type(type_, type_start), origin),
      )
    other => other
  }
}

///|
priv struct ModuleValueInferenceResult {
  values : InferredModuleValues
  jobs : Array[BodyInferenceJobResult?]
}

///|
fn append_module_value_job(
  values : InferredModuleValues,
  let_index : Int,
  job : BodyInferenceJobResult,
) -> Unit {
  let type_start = values.types.length()
  for local_type_id in 1..<job.types.length() {
    match job.types[local_type_id] {
      BodyVariableType(variable) =>
        values.types.push(BodyVariableType(variable))
      BodyAppliedType(base, arguments) => {
        let start = values.type_arguments.length()
        for index in 0..<arguments.length {
          values.type_arguments.push(
            remap_job_type(
              job.type_arguments[arguments.start + index],
              type_start,
            ),
          )
        }
        values.types.push(
          BodyAppliedType(remap_job_type(base, type_start), {
            start,
            length: arguments.length,
          }),
        )
      }
      BodyErrorType | BodyResolvedType(_) =>
        abort("unexpected compact module value type")
    }
  }
  values.let_types[let_index] = remap_job_type(job.result_type, type_start)
  for diagnostic in job.diagnostics {
    values.diagnostics.push(remap_job_diagnostic(diagnostic, type_start))
  }
}

///|
fn infer_module_values_internal(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports?,
  impl_index : ModuleImplIndex,
  names : ResolvedModuleNames,
  callable_indices : Array[Int],
  variant_spans : Array[HirSpan],
  field_spans : Array[HirSpan],
) -> ModuleValueInferenceResult {
  let dependencies = if collected.lets.length() == 0 {
    {
      module_id: collected.module_id,
      let_dependencies: [],
      dependency_declarations: [],
      sccs: [],
      scc_declarations: [],
    }
  } else {
    analyze_module_value_dependencies(collected, names)
  }
  let let_declarations : Array[DeclId] = []
  for value in collected.lets {
    let_declarations.push(value.declaration)
  }
  let values : InferredModuleValues = {
    module_id: collected.module_id,
    dependencies,
    let_declarations,
    let_types: Array::make(collected.lets.length(), 0),
    types: [BodyErrorType],
    type_arguments: [],
    diagnostics: [],
  }
  let jobs : Array[BodyInferenceJobResult?] = Array::make(
    collected.bodies.length(),
    None,
  )
  if collected.lets.length() == 0 {
    return { values, jobs }
  }
  let let_indices = module_let_indices_by_declaration(collected)
  let solver = LocalTypeSolver::new(resolved)
  let call_scratch = CallInferenceScratch::new()
  let module_values = ModuleValueInferenceContext::new(
    values, let_indices, solver,
  )
  let mut first_scc = true
  for scc in dependencies.sccs {
    if first_scc {
      first_scc = false
    } else {
      solver.reset()
    }
    module_values.begin_solver()
    for index in 0..<scc.length {
      let declaration = dependencies.scc_declarations[scc.start + index]
      let let_index = module_values.let_index(declaration)
      module_values.slots[let_index] = solver.fresh_variable()
    }
    if scc.length == 1 {
      let declaration = dependencies.scc_declarations[scc.start]
      let let_index = module_values.let_index(declaration)
      let body = collected.body_of(declaration).unwrap()
      call_scratch.begin_body()
      let inferencer = BasicBodyInferencer::new(
        collected,
        resolved,
        imports,
        impl_index,
        names,
        body,
        -1,
        callable_indices,
        variant_spans,
        field_spans,
        solver,
        call_scratch,
        Some(module_values),
      )
      inferencer.constrain_body()
      let slot = module_values.slots[let_index]
      if solver.has_unresolved_variable(solver.zonk_type(slot)) {
        solver.poison_type(slot)
        let offset = match collected.declaration(declaration) {
          Some(TopLevelReference(value)) => value.offset
          _ => 0UL
        }
        inferencer.diagnose(UnresolvedModuleValue(declaration, offset))
      }
      let job = inferencer.finish()
      append_module_value_job(values, let_index, job)
      jobs[semantic_id_local(body.id)] = Some(job)
      continue
    }
    let inferencers : Array[BasicBodyInferencer] = []
    for index in 0..<scc.length {
      let declaration = dependencies.scc_declarations[scc.start + index]
      let body = collected.body_of(declaration).unwrap()
      call_scratch.begin_body()
      let inferencer = BasicBodyInferencer::new(
        collected,
        resolved,
        imports,
        impl_index,
        names,
        body,
        -1,
        callable_indices,
        variant_spans,
        field_spans,
        solver,
        call_scratch,
        Some(module_values),
      )
      inferencer.constrain_body()
      inferencers.push(inferencer)
    }
    let unresolved = Array::make(scc.length, false)
    for index in 0..<scc.length {
      let declaration = dependencies.scc_declarations[scc.start + index]
      let let_index = module_values.let_index(declaration)
      unresolved[index] = solver.has_unresolved_variable(
        solver.zonk_type(module_values.slots[let_index]),
      )
    }
    for index in 0..<scc.length {
      if !unresolved[index] {
        continue
      }
      let declaration = dependencies.scc_declarations[scc.start + index]
      let let_index = module_values.let_index(declaration)
      solver.poison_type(module_values.slots[let_index])
      let offset = match collected.declaration(declaration) {
        Some(TopLevelReference(value)) => value.offset
        _ => 0UL
      }
      inferencers[index].diagnose(UnresolvedModuleValue(declaration, offset))
    }
    for index in 0..<scc.length {
      let declaration = dependencies.scc_declarations[scc.start + index]
      let let_index = module_values.let_index(declaration)
      let body = collected.body_of(declaration).unwrap()
      let job = inferencers[index].finish()
      append_module_value_job(values, let_index, job)
      jobs[semantic_id_local(body.id)] = Some(job)
    }
  }
  values.diagnostics.sort_by(fn(left, right) {
    let offset_order = left.offset().compare(right.offset())
    if offset_order != 0 {
      offset_order
    } else {
      left.rank() - right.rank()
    }
  })
  { values, jobs }
}

///|
/// Infers module lets in deterministic dependency-SCC order. The returned
/// value types are frozen before independent function body jobs begin.
pub fn infer_module_values(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  names : ResolvedModuleNames,
) -> InferredModuleValues {
  guard collected.module_id == resolved.module_id &&
    collected.module_id == names.module_id else {
    abort("module value inference inputs belong to different modules")
  }
  let variant_spans = variant_spans_by_declaration(collected)
  let field_spans = field_spans_by_declaration(collected)
  let impl_index = build_module_impl_index(collected, resolved)
  infer_module_values_internal(
    collected,
    resolved,
    None,
    impl_index,
    names,
    callable_indices_by_declaration(collected),
    variant_spans,
    field_spans,
  ).values
}

///|
pub fn infer_module_values_with_imports(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports,
  names : ResolvedModuleNames,
) -> InferredModuleValues {
  guard collected.module_id == resolved.module_id &&
    collected.module_id == imports.module_id &&
    collected.module_id == names.module_id else {
    abort("imported module value inference inputs belong to different modules")
  }
  let variant_spans = variant_spans_by_declaration(collected)
  let field_spans = field_spans_by_declaration(collected)
  let impl_index = build_module_impl_index_with_imports(
    collected, resolved, imports,
  )
  infer_module_values_internal(
    collected,
    resolved,
    Some(imports),
    impl_index,
    names,
    callable_indices_by_declaration(collected),
    variant_spans,
    field_spans,
  ).values
}

///|
fn merge_body_inference_jobs(
  collected : CollectedModule,
  names : ResolvedModuleNames,
  module_values : InferredModuleValues,
  impl_index : ModuleImplIndex,
  jobs : Array[BodyInferenceJobResult?],
) -> InferredModuleBodies {
  let bodies : Array[InferredBody] = []
  let types : Array[BodyTypeTerm] = [BodyErrorType]
  let type_arguments : Array[BodyTypeId] = []
  let expression_types = Array::make(collected.expressions.length(), 0)
  let local_types = Array::make(names.locals.length(), 0)
  let block_types = Array::make(collected.blocks.length(), 0)
  let pattern_types = Array::make(collected.patterns.length(), 0)
  let pattern_constructors = Array::make(
    collected.patterns.length(),
    NoInferredPatternConstructor,
  )
  let pattern_type_arguments : Array[BodyTypeId] = []
  let control_state_types = Array::make(names.controls.length(), 0)
  let control_result_types = Array::make(names.controls.length(), 0)
  let expression_selections = Array::make(
    collected.expressions.length(),
    NoExpressionSelection,
  )
  let expression_type_arguments : Array[BodyTypeId] = []
  let object_field_targets = Array::make(
    collected.object_fields.length(),
    NoObjectFieldTarget,
  )
  let call_targets = Array::make(
    collected.expressions.length(),
    NoInferredCallTarget,
  )
  let operator_targets = Array::make(
    collected.expressions.length(),
    NoInferredCallTarget,
  )
  let map_hash_targets = Array::make(
    collected.expressions.length(),
    NoInferredCallTarget,
  )
  let map_eq_targets = Array::make(
    collected.expressions.length(),
    NoInferredCallTarget,
  )
  let call_type_arguments : Array[BodyTypeId] = []
  let diagnostics : Array[BodyInferenceDiagnostic] = []
  for body_index, body in collected.bodies {
    let job = jobs[body_index].unwrap()
    let type_start = types.length()
    let argument_start = type_arguments.length()
    for local_type_id in 1..<job.types.length() {
      match job.types[local_type_id] {
        BodyVariableType(variable) => types.push(BodyVariableType(variable))
        BodyAppliedType(base, arguments) => {
          let start = type_arguments.length()
          for index in 0..<arguments.length {
            type_arguments.push(
              remap_job_type(
                job.type_arguments[arguments.start + index],
                type_start,
              ),
            )
          }
          types.push(
            BodyAppliedType(remap_job_type(base, type_start), {
              start,
              length: arguments.length,
            }),
          )
        }
        BodyErrorType | BodyResolvedType(_) =>
          abort("unexpected compact body type during merge")
      }
    }
    let pattern_argument_start = pattern_type_arguments.length()
    for type_ in job.pattern_type_arguments {
      pattern_type_arguments.push(remap_job_type(type_, type_start))
    }
    let expression_argument_start = expression_type_arguments.length()
    for type_ in job.expression_type_arguments {
      expression_type_arguments.push(remap_job_type(type_, type_start))
    }
    let call_argument_start = call_type_arguments.length()
    for type_ in job.call_type_arguments {
      call_type_arguments.push(remap_job_type(type_, type_start))
    }
    for index in 0..<body.expressions.length {
      let expression = body.expressions.start + index
      expression_types[expression] = remap_job_type(
        job.expression_types[index],
        type_start,
      )
    }
    if job.expression_selections.length() > 0 {
      for index in 0..<body.expressions.length {
        let expression = body.expressions.start + index
        expression_selections[expression] = match
          job.expression_selections[index] {
          StructConstructionSelection(declaration, arguments) =>
            StructConstructionSelection(declaration, {
              start: expression_argument_start + arguments.start,
              length: arguments.length,
            })
          VariantConstructionSelection(variant, arguments) =>
            VariantConstructionSelection(variant, {
              start: expression_argument_start + arguments.start,
              length: arguments.length,
            })
          UnitVariantValueSelection(variant, arguments) =>
            UnitVariantValueSelection(variant, {
              start: expression_argument_start + arguments.start,
              length: arguments.length,
            })
          FieldAccessSelection(field) => FieldAccessSelection(field)
          ImportedModuleValueSelection(declaration) =>
            ImportedModuleValueSelection(declaration)
          FunctionReferenceSelection(declaration) =>
            FunctionReferenceSelection(declaration)
          NoExpressionSelection => NoExpressionSelection
          ErrorExpressionSelection => ErrorExpressionSelection
        }
      }
    }
    for index in 0..<body.object_fields.length {
      object_field_targets[body.object_fields.start + index] = job.object_field_targets[index]
    }
    for call_slot in 0..<job.call_expressions.length() {
      let expression = job.call_expressions[call_slot]
      call_targets[expression] = match job.call_targets[call_slot] {
        SelectedInferredCallTarget(declaration, arguments) =>
          SelectedInferredCallTarget(declaration, {
            start: call_argument_start + arguments.start,
            length: arguments.length,
          })
        SelectedFunctionValueCallTarget(target) =>
          SelectedFunctionValueCallTarget(target)
        NoInferredCallTarget => NoInferredCallTarget
        ErrorInferredCallTarget => ErrorInferredCallTarget
      }
    }
    for index in 0..<body.expressions.length {
      let expression = body.expressions.start + index
      operator_targets[expression] = match job.operator_targets[index] {
        SelectedInferredCallTarget(declaration, arguments) =>
          SelectedInferredCallTarget(declaration, {
            start: call_argument_start + arguments.start,
            length: arguments.length,
          })
        SelectedFunctionValueCallTarget(target) =>
          SelectedFunctionValueCallTarget(target)
        NoInferredCallTarget => NoInferredCallTarget
        ErrorInferredCallTarget => ErrorInferredCallTarget
      }
      map_hash_targets[expression] = match job.map_hash_targets[index] {
        SelectedInferredCallTarget(declaration, arguments) =>
          SelectedInferredCallTarget(declaration, {
            start: call_argument_start + arguments.start,
            length: arguments.length,
          })
        SelectedFunctionValueCallTarget(target) =>
          SelectedFunctionValueCallTarget(target)
        NoInferredCallTarget => NoInferredCallTarget
        ErrorInferredCallTarget => ErrorInferredCallTarget
      }
      map_eq_targets[expression] = match job.map_eq_targets[index] {
        SelectedInferredCallTarget(declaration, arguments) =>
          SelectedInferredCallTarget(declaration, {
            start: call_argument_start + arguments.start,
            length: arguments.length,
          })
        SelectedFunctionValueCallTarget(target) =>
          SelectedFunctionValueCallTarget(target)
        NoInferredCallTarget => NoInferredCallTarget
        ErrorInferredCallTarget => ErrorInferredCallTarget
      }
    }
    let name_info = names.body(body.id).unwrap()
    for index in 0..<name_info.locals.length {
      local_types[name_info.locals.start + index] = remap_job_type(
        job.local_types[index],
        type_start,
      )
    }
    for index in 0..<body.blocks.length {
      block_types[body.blocks.start + index] = remap_job_type(
        job.block_types[index],
        type_start,
      )
    }
    for index in 0..<body.patterns.length {
      let pattern = body.patterns.start + index
      pattern_types[pattern] = remap_job_type(
        job.pattern_types[index],
        type_start,
      )
      pattern_constructors[pattern] = match job.pattern_constructors[index] {
        StructInferredPatternConstructor(declaration, arguments) =>
          StructInferredPatternConstructor(declaration, {
            start: pattern_argument_start + arguments.start,
            length: arguments.length,
          })
        VariantInferredPatternConstructor(variant, arguments) =>
          VariantInferredPatternConstructor(variant, {
            start: pattern_argument_start + arguments.start,
            length: arguments.length,
          })
        NoInferredPatternConstructor => NoInferredPatternConstructor
        ErrorInferredPatternConstructor => ErrorInferredPatternConstructor
      }
    }
    for index in 0..<name_info.controls.length {
      control_state_types[name_info.controls.start + index] = remap_job_type(
        job.control_state_types[index],
        type_start,
      )
      control_result_types[name_info.controls.start + index] = remap_job_type(
        job.control_result_types[index],
        type_start,
      )
    }
    let diagnostic_start = diagnostics.length()
    for diagnostic in job.diagnostics {
      diagnostics.push(remap_job_diagnostic(diagnostic, type_start))
    }
    bodies.push({
      body: body.id,
      root_type: remap_job_type(job.result_type, type_start),
      types: { start: type_start, length: job.types.length() - 1 },
      type_arguments: {
        start: argument_start,
        length: type_arguments.length() - argument_start,
      },
      diagnostics: {
        start: diagnostic_start,
        length: diagnostics.length() - diagnostic_start,
      },
    })
  }
  {
    module_id: collected.module_id,
    module_values,
    impl_index,
    bodies,
    types,
    type_arguments,
    expression_types,
    local_types,
    block_types,
    pattern_types,
    pattern_constructors,
    pattern_type_arguments,
    control_state_types,
    control_result_types,
    expression_selections,
    expression_type_arguments,
    object_field_targets,
    call_targets,
    operator_targets,
    map_hash_targets,
    map_eq_targets,
    call_type_arguments,
    diagnostics,
  }
}

///|
fn infer_module_bodies_with_imports_in_order(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports?,
  names : ResolvedModuleNames,
  order : Array[Int],
) -> InferredModuleBodies {
  guard collected.module_id == resolved.module_id &&
    collected.module_id == names.module_id else {
    abort("body inference inputs belong to different modules")
  }
  guard order.length() == collected.bodies.length() else {
    abort("body inference order has the wrong length")
  }
  let callable_indices = callable_indices_by_declaration(collected)
  let variant_spans = variant_spans_by_declaration(collected)
  let field_spans = field_spans_by_declaration(collected)
  let impl_index = match imports {
    Some(imported) =>
      build_module_impl_index_with_imports(collected, resolved, imported)
    None => build_module_impl_index(collected, resolved)
  }
  let module_result = infer_module_values_internal(
    collected, resolved, imports, impl_index, names, callable_indices, variant_spans,
    field_spans,
  )
  let jobs = module_result.jobs
  let seen = Array::make(collected.bodies.length(), false)
  let solver = LocalTypeSolver::new(resolved)
  let call_scratch = CallInferenceScratch::new()
  let module_values = if collected.lets.length() == 0 {
    None
  } else {
    Some(
      ModuleValueInferenceContext::new(
        module_result.values,
        module_let_indices_by_declaration(collected),
        solver,
      ),
    )
  }
  let mut first_job = true
  for body_index in order {
    guard body_index >= 0 && body_index < collected.bodies.length() else {
      abort("body inference order contains an invalid body")
    }
    guard !seen[body_index] else {
      abort("body inference order contains a duplicate body")
    }
    seen[body_index] = true
    let body = collected.bodies[body_index]
    if body.kind == ModuleLetBody {
      continue
    }
    if first_job {
      first_job = false
    } else {
      solver.reset()
    }
    match module_values {
      Some(context) => context.begin_solver()
      None => ()
    }
    call_scratch.begin_body()
    jobs[body_index] = Some(
      BasicBodyInferencer::new(
        collected,
        resolved,
        imports,
        impl_index,
        names,
        body,
        callable_indices[semantic_id_local(body.declaration)],
        callable_indices,
        variant_spans,
        field_spans,
        solver,
        call_scratch,
        module_values,
      ).run(),
    )
  }
  merge_body_inference_jobs(
    collected,
    names,
    module_result.values,
    impl_index,
    jobs,
  )
}

///|
fn infer_module_bodies_in_order(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  names : ResolvedModuleNames,
  order : Array[Int],
) -> InferredModuleBodies {
  infer_module_bodies_with_imports_in_order(
    collected,
    resolved,
    None,
    names,
    order,
  )
}

///|
pub fn infer_module_bodies_with_imports(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports,
  names : ResolvedModuleNames,
) -> InferredModuleBodies {
  guard collected.module_id == imports.module_id else {
    abort("body import scope belongs to another module")
  }
  let order : Array[Int] = []
  for index in 0..<collected.bodies.length() {
    order.push(index)
  }
  infer_module_bodies_with_imports_in_order(
    collected,
    resolved,
    Some(imports),
    names,
    order,
  )
}

///|
/// Performs HIR-driven local inference for module values, parameters, literals,
/// locals, blocks, returns, if expressions, operators, direct and overloaded
/// calls, expected-type-driven patterns, nominal objects and constructions,
/// field access, enum values, matches, and functional-loop state/result types.
/// Methods, general qualified members, and indexing remain unsupported.
pub fn infer_module_bodies(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  names : ResolvedModuleNames,
) -> InferredModuleBodies {
  let order : Array[Int] = []
  for index in 0..<collected.bodies.length() {
    order.push(index)
  }
  infer_module_bodies_in_order(collected, resolved, names, order)
}
