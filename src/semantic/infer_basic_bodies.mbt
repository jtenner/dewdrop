///|
let instantiate_visit = 0

///|
let instantiate_finish_application = 1

///|
let instantiate_finish_function = 2

///|
let instantiate_finish_product = 3

///|
let import_value_visit = 0

///|
let import_value_finish_application = 1

///|
let import_value_finish_function = 2

///|
let import_value_finish_product = 3

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
let empty_hir_span_array : Array[HirSpan] = []

///|
pub struct BodyInferenceJobResult {
  result_type : BodyTypeId
  types : Array[BodyTypeTerm]
  type_arguments : Array[BodyTypeId]
  expression_types : Array[BodyTypeId]
  local_types : Array[BodyTypeId]
  capture_types : Array[BodyTypeId]
  block_types : Array[BodyTypeId]
  pattern_types : Array[BodyTypeId]
  pattern_constructors : Array[InferredPatternConstructor]
  pattern_type_arguments : Array[BodyTypeId]
  control_state_types : Array[BodyTypeId]
  control_result_types : Array[BodyTypeId]
  expression_selections : Array[InferredExpressionSelection]
  expression_type_arguments : Array[BodyTypeId]
  object_field_targets : Array[InferredObjectFieldTarget]
  trait_object_coercions : Array[InferredTraitObjectCoercion]
  call_expressions : Array[ExprId]
  call_targets : Array[InferredCallTarget]
  operator_targets : Array[InferredCallTarget]
  map_hash_targets : Array[InferredCallTarget]
  map_eq_targets : Array[InferredCallTarget]
  expression_evidence : Array[HirSpan]
  trait_evidence_roots : Array[Int]
  trait_evidence : Array[InferredTraitEvidence]
  trait_evidence_children : Array[Int]
  trait_evidence_arguments : Array[InferredTraitEvidenceArgument]
  call_type_arguments : Array[BodyTypeId]
  diagnostics : Array[BodyInferenceDiagnostic]
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct BodyInferenceLambdaArtifact {
  lambda : LambdaId
  job : BodyInferenceJobResult
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct BodyInferenceFamilyArtifact {
  module_id : ModuleId
  body : BodyId
  declaration : DeclId
  root : BodyInferenceJobResult
  lambdas : Array[BodyInferenceLambdaArtifact]
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct BodyInferenceFamilyAnalysis {
  inferred : InferredModuleBodies
  families : Array[BodyInferenceFamilyArtifact?]
  family_hits : Int
  family_misses : Int
}

///|
pub fn make_uncached_body_inference_family_analysis(
  inferred : InferredModuleBodies,
  body_count : Int,
) -> BodyInferenceFamilyAnalysis {
  {
    inferred,
    families: Array::make(body_count, None),
    family_hits: 0,
    family_misses: 0,
  }
}

///|
priv struct BodyJobTypeImporter {
  solver : LocalTypeSolver
  task_types : Array[BodyTypeId]
  task_states : Array[Int]
  result_starts : Array[Int]
  results : Array[BodyTypeId]
  arguments : Array[BodyTypeId]
}

///|
fn BodyJobTypeImporter::new(solver : LocalTypeSolver) -> BodyJobTypeImporter {
  {
    solver,
    task_types: [],
    task_states: [],
    result_starts: [],
    results: [],
    arguments: [],
  }
}

///|
fn BodyJobTypeImporter::push(
  self : BodyJobTypeImporter,
  type_ : BodyTypeId,
  state : Int,
  result_start : Int,
) -> Unit {
  self.task_types.push(type_)
  self.task_states.push(state)
  self.result_starts.push(result_start)
}

///|
fn BodyJobTypeImporter::import_type(
  self : BodyJobTypeImporter,
  job : BodyInferenceJobResult,
  root : BodyTypeId,
) -> BodyTypeId {
  if root <= 0 {
    return root
  }
  self.task_types.clear()
  self.task_states.clear()
  self.result_starts.clear()
  self.results.clear()
  self.push(root, 0, 0)
  while self.task_types.length() > 0 {
    let source = self.task_types.pop().unwrap()
    let state = self.task_states.pop().unwrap()
    let result_start = self.result_starts.pop().unwrap()
    if source <= 0 {
      self.results.push(source)
      continue
    }
    if state == 0 {
      match job.types[source] {
        BodyProductType(fields) => {
          self.push(source, 3, self.results.length())
          let mut index = fields.length
          while index > 0 {
            index -= 1
            self.push(job.type_arguments[fields.start + index], 0, 0)
          }
        }
        BodyAppliedType(base, arguments) => {
          self.push(source, 1, self.results.length())
          let mut index = arguments.length
          while index > 0 {
            index -= 1
            self.push(job.type_arguments[arguments.start + index], 0, 0)
          }
          self.push(base, 0, 0)
        }
        BodyFunctionType(parameters, result) => {
          self.push(source, 2, self.results.length())
          self.push(result, 0, 0)
          let mut index = parameters.length
          while index > 0 {
            index -= 1
            self.push(job.type_arguments[parameters.start + index], 0, 0)
          }
        }
        BodyVariableType(_) | BodyErrorType =>
          self.results.push(self.solver.error_type())
        BodyResolvedType(type_) =>
          self.results.push(self.solver.resolved_type(type_))
      }
    } else if state == 1 {
      let arguments = match job.types[source] {
        BodyAppliedType(_, arguments) => arguments
        _ => abort("body-job import expected an applied type")
      }
      let base = self.results[result_start]
      self.arguments.clear()
      for index in 0..<arguments.length {
        self.arguments.push(self.results[result_start + index + 1])
      }
      let result = self.solver.applied_type(base, self.arguments)
      self.results.truncate(result_start)
      self.results.push(result)
    } else if state == 2 {
      let parameters = match job.types[source] {
        BodyFunctionType(parameters, _) => parameters
        _ => abort("body-job import expected a function type")
      }
      self.arguments.clear()
      for index in 0..<parameters.length {
        self.arguments.push(self.results[result_start + index])
      }
      let result = self.solver.function_type(
        self.arguments,
        self.results[result_start + parameters.length],
      )
      self.results.truncate(result_start)
      self.results.push(result)
    } else {
      let fields = match job.types[source] {
        BodyProductType(fields) => fields
        _ => abort("body-job import expected a product type")
      }
      self.arguments.clear()
      for index in 0..<fields.length {
        self.arguments.push(self.results[result_start + index])
      }
      let result = self.solver.product_type(self.arguments)
      self.results.truncate(result_start)
      self.results.push(result)
    }
  }
  guard self.results.length() == 1 else {
    abort("invalid imported body-job type")
  }
  self.results[0]
}

///|
priv struct CallInferenceScratch {
  pending_calls : Array[ExprId]
  deferred_calls : Array[ExprId]
  pending_function_calls : Array[Int]
  deferred_function_calls : Array[Int]
  overload_candidates : Array[DeclId]
  overload_viable_candidates : Array[DeclId]
  overload_maximal_candidates : Array[DeclId]
  pending_methods : Array[ExprId]
  deferred_methods : Array[ExprId]
  pending_debug_dispatches : Array[Int]
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
    pending_function_calls: [],
    deferred_function_calls: [],
    overload_candidates: [],
    overload_viable_candidates: [],
    overload_maximal_candidates: [],
    pending_methods: [],
    deferred_methods: [],
    pending_debug_dispatches: [],
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
    instantiation_generics: { start: 0, length: 0, },
    instantiation_method_generics: { start: 0, length: 0, },
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
  self.pending_function_calls.clear()
  self.deferred_function_calls.clear()
  self.overload_candidates.clear()
  self.overload_viable_candidates.clear()
  self.overload_maximal_candidates.clear()
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
        BodyProductType(fields) => {
          self.push_task(
            source,
            import_value_finish_product,
            self.results.length(),
          )
          let mut index = fields.length
          while index > 0 {
            index -= 1
            self.push_task(
              self.values.type_arguments[fields.start + index],
              import_value_visit,
              0,
            )
          }
        }
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
        BodyFunctionType(parameters, result) => {
          self.push_task(
            source,
            import_value_finish_function,
            self.results.length(),
          )
          self.push_task(result, import_value_visit, 0)
          let mut index = parameters.length
          while index > 0 {
            index -= 1
            self.push_task(
              self.values.type_arguments[parameters.start + index],
              import_value_visit,
              0,
            )
          }
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
    } else if state == import_value_finish_application {
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
    } else if state == import_value_finish_function {
      let parameters = match self.values.types[source] {
        BodyFunctionType(parameters, _) => parameters
        _ => abort("module value import expected a function type")
      }
      self.arguments.clear()
      for index in 0..<parameters.length {
        self.arguments.push(self.results[result_start + index])
      }
      let result = self.solver.function_type(
        self.arguments,
        self.results[result_start + parameters.length],
      )
      self.marks[source] = self.generation
      self.cached[source] = result
      self.results.truncate(result_start)
      self.results.push(result)
    } else {
      let fields = match self.values.types[source] {
        BodyProductType(fields) => fields
        _ => abort("module value import expected a product type")
      }
      self.arguments.clear()
      for index in 0..<fields.length {
        self.arguments.push(self.results[result_start + index])
      }
      let result = self.solver.product_type(self.arguments)
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
  mut lambda : LambdaId
  mut local_span : HirSpan
  mut control_span : HirSpan
  mut capture_types : Array[BodyTypeId]
  callable_index : Int
  callable_indices : Array[Int]
  variant_spans : Array[HirSpan]
  field_spans : Array[HirSpan]
  solver : LocalTypeSolver
  expression_types : Array[BodyTypeId]
  mut local_types : Array[BodyTypeId]
  block_types : Array[BodyTypeId]
  pattern_types : Array[BodyTypeId]
  pattern_constructors : Array[InferredPatternConstructor]
  pattern_type_arguments : Array[BodyTypeId]
  mut control_state_types : Array[BodyTypeId]
  mut control_result_types : Array[BodyTypeId]
  mut expression_selections : Array[InferredExpressionSelection]
  expression_type_arguments : Array[BodyTypeId]
  object_field_targets : Array[InferredObjectFieldTarget]
  mut trait_object_coercions : Array[InferredTraitObjectCoercion]
  pending_trait_coercion_expressions : Array[ExprId]
  pending_trait_coercion_types : Array[BodyTypeId]
  pending_trait_coercion_origins : Array[TypeConstraintOrigin]
  pending_call_obligation_expressions : Array[ExprId]
  pending_call_obligation_declarations : Array[DeclId]
  pending_call_obligation_type_arguments : Array[HirSpan]
  pending_call_obligation_offsets : Array[UInt64]
  mut consumed_member_roots : Array[Bool]
  mut has_member_expressions : Bool
  call_expressions : Array[ExprId]
  call_targets : Array[InferredCallTarget]
  operator_targets : Array[InferredCallTarget]
  map_hash_targets : Array[InferredCallTarget]
  map_eq_targets : Array[InferredCallTarget]
  mut expression_evidence : Array[HirSpan]
  trait_evidence_roots : Array[Int]
  trait_evidence : Array[InferredTraitEvidence]
  trait_evidence_children : Array[Int]
  trait_evidence_arguments : Array[InferredTraitEvidenceArgument]
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
    lambda: -1,
    local_span: name_info.locals,
    control_span: name_info.controls,
    capture_types: [],
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
    trait_object_coercions: [],
    pending_trait_coercion_expressions: [],
    pending_trait_coercion_types: [],
    pending_trait_coercion_origins: [],
    pending_call_obligation_expressions: [],
    pending_call_obligation_declarations: [],
    pending_call_obligation_type_arguments: [],
    pending_call_obligation_offsets: [],
    consumed_member_roots: empty_inference_bool_array,
    has_member_expressions: false,
    call_expressions: [],
    call_targets: [],
    operator_targets: Array::make(body.expressions.length, NoInferredCallTarget),
    map_hash_targets: Array::make(body.expressions.length, NoInferredCallTarget),
    map_eq_targets: Array::make(body.expressions.length, NoInferredCallTarget),
    expression_evidence: empty_hir_span_array,
    trait_evidence_roots: [],
    trait_evidence: [],
    trait_evidence_children: [],
    trait_evidence_arguments: [],
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
fn BasicBodyInferencer::new_lambda(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports?,
  impl_index : ModuleImplIndex,
  names : ResolvedModuleNames,
  lambda : HirLambda,
  capture_types : Array[BodyTypeId],
  callable_indices : Array[Int],
  variant_spans : Array[HirSpan],
  field_spans : Array[HirSpan],
  solver : LocalTypeSolver,
  call_scratch : CallInferenceScratch,
  module_values : ModuleValueInferenceContext?,
) -> BasicBodyInferencer {
  let root_body = collected.bodies[semantic_id_local(lambda.root_body)]
  let body : HirBody = {
    id: lambda.root_body,
    declaration: root_body.declaration,
    kind: root_body.kind,
    root: BlockBodyRoot(lambda.body.root),
    expressions: lambda.body.expressions,
    expression_children: lambda.body.expression_children,
    blocks: lambda.body.blocks,
    block_items: lambda.body.block_items,
    patterns: lambda.body.patterns,
    pattern_children: lambda.body.pattern_children,
    pattern_arms: lambda.body.pattern_arms,
    arm_children: lambda.body.arm_children,
    object_fields: lambda.body.object_fields,
    pattern_fields: lambda.body.pattern_fields,
    offset: lambda.offset,
  }
  let name_info = names.lambda(lambda.id).unwrap()
  let inferencer = BasicBodyInferencer::new(
    collected,
    resolved,
    imports,
    impl_index,
    names,
    body,
    callable_indices[semantic_id_local(root_body.declaration)],
    callable_indices,
    variant_spans,
    field_spans,
    solver,
    call_scratch,
    module_values,
  )
  inferencer.lambda = lambda.id
  inferencer.local_span = name_info.locals
  inferencer.control_span = name_info.controls
  inferencer.capture_types = capture_types
  inferencer.local_types = Array::make(name_info.locals.length, 0)
  inferencer.control_state_types = if name_info.controls.length == 0 {
    empty_body_type_array
  } else {
    Array::make(name_info.controls.length, 0)
  }
  inferencer.control_result_types = if name_info.controls.length == 0 {
    empty_body_type_array
  } else {
    Array::make(name_info.controls.length, 0)
  }
  inferencer
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
fn BasicBodyInferencer::is_unit_type(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> Bool {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyResolvedType(resolved_type) =>
      resolved_type == self.resolved.primitive(UnitType)
    _ => false
  }
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
fn BasicBodyInferencer::body_trait_declaration(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> DeclId? {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyResolvedType(resolved_type) => self.resolved_bound_trait(resolved_type)
    BodyAppliedType(base, _) =>
      match self.solver.type_term(self.solver.representative_type(base)) {
        BodyResolvedType(resolved_type) =>
          self.resolved_bound_trait(resolved_type)
        _ => None
      }
    _ => None
  }
}

///|
fn BasicBodyInferencer::nullable_ref_argument(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> BodyTypeId? {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyAppliedType(base, arguments) if arguments.length == 1 =>
      match self.solver.type_term(self.solver.representative_type(base)) {
        BodyResolvedType(resolved_base) =>
          match self.resolved.types[resolved_base] {
            NominalType(declaration) if declaration ==
              standard_nullable_ref_type_declaration() =>
              Some(self.solver.type_arguments[arguments.start])
            _ => None
          }
        _ => None
      }
    BodyResolvedType(resolved_type) =>
      match self.resolved.types[resolved_type] {
        AppliedType(base, arguments) if arguments.length == 1 =>
          match self.resolved.types[base] {
            NominalType(declaration) if declaration ==
              standard_nullable_ref_type_declaration() =>
              Some(
                self.solver.resolved_type(
                  self.resolved.type_arguments[arguments.start],
                ),
              )
            _ => None
          }
        _ => None
      }
    _ => None
  }
}

///|
fn BasicBodyInferencer::trait_object_assignable(
  self : BasicBodyInferencer,
  actual : BodyTypeId,
  expected : BodyTypeId,
  trait_declaration : DeclId,
  origin : TypeConstraintOrigin,
) -> Bool {
  if self.body_trait_declaration(actual) == Some(trait_declaration) {
    return true
  }
  let diagnostic_start = self.solver.diagnostics.length()
  let satisfied = self.trait_obligation_satisfied_at_depth(
    actual, expected, trait_declaration, origin, 0,
  )
  self.solver.diagnostics.truncate(diagnostic_start)
  satisfied
}

///|
fn BasicBodyInferencer::assignable_viable(
  self : BasicBodyInferencer,
  actual : BodyTypeId,
  expected : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> Bool {
  if self.is_never_type(actual) {
    return true
  }
  match self.nullable_ref_argument(expected) {
    Some(argument) if !self.body_type_is_unresolved(actual) &&
      self.nullable_ref_argument(actual) is None =>
      return self.solver.unify(actual, argument, origin)
    _ => ()
  }
  match self.body_trait_declaration(expected) {
    Some(trait_declaration) =>
      self.trait_object_assignable(actual, expected, trait_declaration, origin)
    None => self.solver.unify(actual, expected, origin)
  }
}

///|
fn BasicBodyInferencer::ensure_trait_object_coercions(
  self : BasicBodyInferencer,
) -> Unit {
  if self.trait_object_coercions.length() == 0 &&
    self.body.expressions.length > 0 {
    self.trait_object_coercions = Array::make(
      self.body.expressions.length,
      NoInferredTraitObjectCoercion,
    )
  }
}

///|
fn BasicBodyInferencer::body_type_is_unresolved(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> Bool {
  match self.solver.type_term(self.solver.representative_type(type_)) {
    BodyVariableType(_) => true
    _ => false
  }
}

///|
fn BasicBodyInferencer::constrain_call_result(
  self : BasicBodyInferencer,
  expression : ExprId,
  result : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> Unit {
  let expected = self.expression_type(expression)
  if self.is_never_type(result) {
    if self.body_type_is_unresolved(expected) {
      self.constrain(expected, result, origin)
    }
  } else {
    self.constrain(expected, result, origin)
  }
}

///|
fn BasicBodyInferencer::constrain_expression_assignable(
  self : BasicBodyInferencer,
  expression : ExprId,
  expected : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> Unit {
  let actual = self.expression_type(expression)
  if self.is_never_type(actual) {
    return
  }
  match self.nullable_ref_argument(expected) {
    Some(argument) if !self.body_type_is_unresolved(actual) &&
      self.nullable_ref_argument(actual) is None => {
      self.constrain(actual, argument, origin)
      return
    }
    _ => ()
  }
  match self.body_trait_declaration(expected) {
    Some(trait_declaration) => {
      if self.body_type_is_unresolved(actual) {
        self.pending_trait_coercion_expressions.push(expression)
        self.pending_trait_coercion_types.push(expected)
        self.pending_trait_coercion_origins.push(origin)
        return
      }
      if self.body_trait_declaration(actual) == Some(trait_declaration) {
        self.constrain(actual, expected, origin)
        return
      }
      let diagnostic_start = self.solver.diagnostics.length()
      match
        self.select_trait_obligation_evidence(
          actual, expected, trait_declaration, origin,
        ) {
        Some(evidence) => {
          self.solver.diagnostics.truncate(diagnostic_start)
          self.ensure_trait_object_coercions()
          self.trait_object_coercions[self.expression_index(expression)] = SelectedInferredTraitObjectCoercion(
            trait_declaration, evidence,
          )
        }
        None => {
          self.ensure_trait_object_coercions()
          self.trait_object_coercions[self.expression_index(expression)] = ErrorInferredTraitObjectCoercion
          self.constrain(actual, expected, origin)
        }
      }
    }
    None => self.constrain(actual, expected, origin)
  }
}

///|
fn BasicBodyInferencer::constrain_assignable(
  self : BasicBodyInferencer,
  actual : BodyTypeId,
  expected : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> Unit {
  if self.is_never_type(actual) {
    return
  }
  match self.nullable_ref_argument(expected) {
    Some(argument) if !self.body_type_is_unresolved(actual) &&
      self.nullable_ref_argument(actual) is None =>
      self.constrain(actual, argument, origin)
    _ => self.constrain(actual, expected, origin)
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
fn BasicBodyInferencer::local_function_reference_candidate_count(
  self : BasicBodyInferencer,
  name : NameId,
) -> Int {
  let binding = match self.collected.value_bindings.get(name) {
    Some(binding) => binding
    None => return 0
  }
  let mut count = 0
  let mut cursor = binding.head
  while cursor >= 0 {
    let candidate = self.collected.value_binding_candidates[cursor]
    if self.declaration_visible(candidate.declaration) {
      let local_index = semantic_id_local(candidate.declaration)
      if local_index >= 0 && local_index < self.callable_indices.length() {
        let callable_index = self.callable_indices[local_index]
        if callable_index >= 0 {
          count += 1
        }
      }
    }
    cursor = candidate.next
  }
  count
}

///|
fn BasicBodyInferencer::imported_function_reference_candidate_count(
  self : BasicBodyInferencer,
  head : Int,
) -> Int {
  let imports = match self.imports {
    Some(imports) => imports
    None => return 0
  }
  let mut count = 0
  let mut cursor = head
  while cursor >= 0 {
    let reference = imports.scope.callable_references[cursor]
    let interface_ = imports.scope.interfaces[reference.interface_index].unwrap()
    let declaration = interface_.callables[reference.callable_index].declaration
    match imports.callable(declaration) {
      Some(_) => count += 1
      _ => ()
    }
    cursor = reference.next
  }
  count
}

///|
fn BasicBodyInferencer::function_reference_candidate_viable(
  self : BasicBodyInferencer,
  expression : ExprId,
  declaration : DeclId,
  candidate_type : ResolvedTypeId,
  offset : UInt64,
) -> Bool {
  ignore(candidate_type)
  let expected = match
    self.resolved_function_signature(self.expression_type(expression)) {
    Some(signature) => signature
    None => return false
  }
  if expected.parameters.length() != self.call_parameter_count(declaration) {
    return false
  }
  let snapshot = self.solver.snapshot()
  let diagnostic_start = self.solver.diagnostics.length()
  self.begin_call_candidate(declaration)
  let origin = expression_type_origin(expression, offset)
  for index in 0..<expected.parameters.length() {
    ignore(
      self.solver.unify(
        expected.parameters[index],
        self.instantiate_signature_type(
          self.call_parameter_type(declaration, index),
        ),
        origin,
      ),
    )
  }
  ignore(
    self.solver.unify(
      expected.result,
      self.instantiate_signature_type(self.call_result_type(declaration)),
      origin,
    ),
  )
  let viable = self.solver.diagnostics.length() == diagnostic_start
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::commit_function_reference(
  self : BasicBodyInferencer,
  expression : ExprId,
  declaration : DeclId,
  candidate_type : ResolvedTypeId,
  offset : UInt64,
) -> Unit {
  ignore(candidate_type)
  let expected = self
    .resolved_function_signature(self.expression_type(expression))
    .unwrap()
  self.begin_call_candidate(declaration)
  let origin = expression_type_origin(expression, offset)
  for index in 0..<expected.parameters.length() {
    ignore(
      self.solver.unify(
        expected.parameters[index],
        self.instantiate_signature_type(
          self.call_parameter_type(declaration, index),
        ),
        origin,
      ),
    )
  }
  ignore(
    self.solver.unify(
      expected.result,
      self.instantiate_signature_type(self.call_result_type(declaration)),
      origin,
    ),
  )
  let start = self.expression_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.expression_type_arguments.push(self.solver.representative_type(type_))
  }
  self.ensure_member_storage()
  self.expression_selections[self.expression_index(expression)] = FunctionReferenceSelection(
    declaration,
    { start, length: self.call_scratch.candidate_type_arguments.length(), },
  )
  let obligation_start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(self.solver.representative_type(type_))
  }
  self.validate_call_obligations_now(
    expression,
    declaration,
    {
      start: obligation_start,
      length: self.call_scratch.candidate_type_arguments.length(),
    },
    offset,
  )
  self.call_type_arguments.truncate(obligation_start)
}

///|
fn BasicBodyInferencer::select_local_function_reference(
  self : BasicBodyInferencer,
  expression : ExprId,
  name : NameId,
  offset : UInt64,
) -> Unit {
  let binding = match self.collected.value_bindings.get(name) {
    Some(binding) => binding
    None => return
  }
  let mut cursor = binding.head
  let mut viable_count = 0
  let mut first_declaration = 0UL
  let mut second_declaration = 0UL
  let mut selected_type = -1
  while cursor >= 0 {
    let candidate = self.collected.value_binding_candidates[cursor]
    if self.declaration_visible(candidate.declaration) {
      let local_index = semantic_id_local(candidate.declaration)
      if local_index >= 0 && local_index < self.callable_indices.length() {
        let callable_index = self.callable_indices[local_index]
        if callable_index >= 0 {
          let candidate_type = self.resolved.callable_function_types[callable_index]
          if self.function_reference_candidate_viable(
              expression,
              candidate.declaration,
              candidate_type,
              offset,
            ) {
            viable_count += 1
            if viable_count == 1 {
              first_declaration = candidate.declaration
              selected_type = candidate_type
            } else if viable_count == 2 {
              second_declaration = candidate.declaration
            }
          }
        }
      }
    }
    cursor = candidate.next
  }
  if viable_count == 1 {
    self.commit_function_reference(
      expression, first_declaration, selected_type, offset,
    )
  } else if viable_count == 0 {
    self.diagnose(NoMatchingFunctionReference(name, expression, offset))
  } else {
    self.diagnose(
      AmbiguousFunctionReference(
        name, expression, first_declaration, second_declaration, viable_count, offset,
      ),
    )
  }
}

///|
fn BasicBodyInferencer::select_imported_function_reference(
  self : BasicBodyInferencer,
  expression : ExprId,
  name : NameId,
  head : Int,
  offset : UInt64,
) -> Unit {
  let imports = match self.imports {
    Some(imports) => imports
    None => return
  }
  let mut cursor = head
  let mut viable_count = 0
  let mut first_declaration = 0UL
  let mut second_declaration = 0UL
  let mut selected_type = -1
  while cursor >= 0 {
    let reference = imports.scope.callable_references[cursor]
    let interface_ = imports.scope.interfaces[reference.interface_index].unwrap()
    let declaration = interface_.callables[reference.callable_index].declaration
    match imports.callable(declaration) {
      Some(callable) =>
        if self.function_reference_candidate_viable(
            expression,
            declaration,
            callable.function_type,
            offset,
          ) {
          viable_count += 1
          if viable_count == 1 {
            first_declaration = declaration
            selected_type = callable.function_type
          } else if viable_count == 2 {
            second_declaration = declaration
          }
        }
      _ => ()
    }
    cursor = reference.next
  }
  if viable_count == 1 {
    self.commit_function_reference(
      expression, first_declaration, selected_type, offset,
    )
  } else if viable_count == 0 {
    self.diagnose(NoMatchingFunctionReference(name, expression, offset))
  } else {
    self.diagnose(
      AmbiguousFunctionReference(
        name, expression, first_declaration, second_declaration, viable_count, offset,
      ),
    )
  }
}

///|
fn BasicBodyInferencer::is_syntactic_call_target(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Bool {
  for call_expression in self.call_expressions {
    match self.collected.expressions[call_expression] {
      HirCallExpr(target, _, _) if target == expression => return true
      _ => ()
    }
  }
  false
}

///|
fn BasicBodyInferencer::constrain_function_references(
  self : BasicBodyInferencer,
) -> Unit {
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    if self.is_function_reference(expression) {
      continue
    }
    if self.is_syntactic_call_target(expression) {
      match self.names.expression_references[expression] {
        ModuleValueNameReference(name) if self.module_value_type(name) is None =>
          self.poison_expression(expression)
        ImportedValueNameReference(_) => self.poison_expression(expression)
        _ => ()
      }
      continue
    }
    if self.has_member_expressions &&
      self.consumed_member_roots[self.expression_index(expression)] {
      continue
    }
    let (name, offset) = match self.collected.expressions[expression] {
      HirNameExpr(name, offset) => (name, offset)
      _ => continue
    }
    let candidate_count = match self.names.expression_references[expression] {
      ModuleValueNameReference(_) if self.module_value_type(name) is None =>
        self.local_function_reference_candidate_count(name)
      ImportedValueNameReference(head) =>
        self.imported_function_reference_candidate_count(head)
      _ => 0
    }
    if candidate_count <= 0 {
      continue
    }
    if self.solver.has_unresolved_variable(self.expression_type(expression)) {
      self.diagnose(
        FunctionReferenceExpectedTypeRequired(name, expression, offset),
      )
      self.poison_expression(expression)
      continue
    }
    match self.names.expression_references[expression] {
      ModuleValueNameReference(_) =>
        self.select_local_function_reference(expression, name, offset)
      ImportedValueNameReference(head) =>
        self.select_imported_function_reference(expression, name, head, offset)
      _ => ()
    }
  }
}

///|
fn BasicBodyInferencer::initialize_control_types(
  self : BasicBodyInferencer,
) -> Unit {
  for control in 0..<self.control_span.length {
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
fn BasicBodyInferencer::standard_array_constructor_type(
  self : BasicBodyInferencer,
) -> BodyTypeId {
  for index, type_ in self.resolved.types {
    match type_ {
      NominalType(declaration) if declaration ==
        standard_array_type_declaration() =>
        return self.solver.resolved_type(index)
      _ => ()
    }
  }
  self.solver.error_type()
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
      HirTypeBindingExpr(_, _) => self.primitive(UnitType)
      HirProductExpr(fields, _) => {
        let types : Array[BodyTypeId] = []
        for index in 0..<fields.length {
          types.push(
            self.expression_type(
              self.collected.expression_children[fields.start + index],
            ),
          )
        }
        self.solver.product_type(types)
      }
      HirArrayExpr(_, _) =>
        self.solver.applied_type(self.standard_array_constructor_type(), [
          self.solver.fresh_variable(),
        ])
      HirNameExpr(name, _) =>
        match self.names.expression_references[expression] {
          LocalNameReference(local_id) => self.local_types[local_id]
          LambdaCaptureNameReference(capture) => self.capture_types[capture]
          ModuleValueNameReference(_) =>
            match self.module_value_type(name) {
              Some(type_) => type_
              None =>
                match self.local_function_reference(name) {
                  Some((declaration, type_)) => {
                    self.ensure_member_storage()
                    self.expression_selections[self.expression_index(expression)] = FunctionReferenceSelection(
                      declaration,
                      { start: 0, length: 0, },
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
                  { start: 0, length: 0, },
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
      HirLambdaExpr(lambda, _) =>
        self.solver.resolved_type(self.resolved.lambda_function_types[lambda])
      HirIfExpr(_, _, alternative, _) if alternative < 0 =>
        self.primitive(UnitType)
      HirAssignmentExpr(_, _, _) => self.primitive(UnitType)
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
      HirReturnExpr(_, _) | HirBreakExpr(_, _) | HirContinueExpr(_, _) =>
        self.primitive(NeverType)
      HirCallExpr(_, _, _) => {
        self.call_expressions.push(expression)
        self.call_targets.push(NoInferredCallTarget)
        if self.direct_call_is_declared_never(expression) {
          self.primitive(NeverType)
        } else {
          self.solver.fresh_variable()
        }
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
  self.call_scratch.instantiation_generics = { start: 0, length: 0, }
  self.call_scratch.instantiation_method_generics = { start: 0, length: 0, }
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
  for local_id in 0..<self.local_span.length {
    let local_info = self.names.locals[self.local_span.start + local_id]
    self.local_types[local_id] = match local_info.kind {
      ParameterLocal =>
        self.body_signature_type(
          if self.lambda >= 0 {
            self.resolved.lambda_parameter_types[local_info.source]
          } else {
            self.resolved.parameter_types[local_info.source]
          },
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
        HirExpressionItem(expression, _) => self.expression_type(expression)
      }
    }
    self.block_types[self.block_index(block)] = type_
  }
}

///|
fn BasicBodyInferencer::constrain_block_expression_types(
  self : BasicBodyInferencer,
) -> Unit {
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    match self.collected.expressions[expression] {
      HirBlockExpr(block, offset) =>
        // Products can already hold the expression's original type variable.
        // Replacing the table entry would leave those references unbound.
        self.constrain(
          self.expression_type(expression),
          self.block_type(block),
          expression_type_origin(expression, offset),
        )
      _ => ()
    }
  }
}

///|
fn BasicBodyInferencer::initialize_return_type(
  self : BasicBodyInferencer,
) -> Unit {
  self.declared_return_type = if self.lambda >= 0 {
    self.body_signature_type(self.resolved.lambda_return_types[self.lambda])
  } else if self.callable_index >= 0 {
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
          None => { start: 0, length: 0, }
        }
      None => { start: 0, length: 0, }
    }
  }
  self.call_scratch.instantiation_method_generics = { start: 0, length: 0, }
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
        ProductType(fields) => {
          self.push_instantiation_task(
            source,
            instantiate_finish_product,
            self.call_scratch.instantiation_results.length(),
          )
          let mut index = fields.length
          while index > 0 {
            index -= 1
            self.push_instantiation_task(
              self.resolved.type_arguments[fields.start + index],
              instantiate_visit,
              0,
            )
          }
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
        FunctionType(parameters, result) => {
          self.push_instantiation_task(
            source,
            instantiate_finish_function,
            self.call_scratch.instantiation_results.length(),
          )
          self.push_instantiation_task(result, instantiate_visit, 0)
          let mut index = parameters.length
          while index > 0 {
            index -= 1
            self.push_instantiation_task(
              self.resolved.type_arguments[parameters.start + index],
              instantiate_visit,
              0,
            )
          }
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
        ErrorType | PrimitiveType(_) | NominalType(_) | TraitType(_) => {
          let result = self.solver.resolved_type(source)
          self.call_scratch.instantiation_marks[source] = self.call_scratch.instantiation_generation
          self.call_scratch.instantiation_values[source] = result
          self.call_scratch.instantiation_results.push(result)
        }
      }
    } else if state == instantiate_finish_application {
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
    } else if state == instantiate_finish_function {
      let (parameters, source_result) = match self.resolved.types[source] {
        FunctionType(parameters, result) => (parameters, result)
        _ => abort("signature instantiation expected a function type")
      }
      self.call_scratch.instantiation_arguments.clear()
      let mut unchanged = true
      for index in 0..<parameters.length {
        let parameter = self.call_scratch.instantiation_results[result_start +
          index]
        if parameter !=
          self.solver.resolved_type(
            self.resolved.type_arguments[parameters.start + index],
          ) {
          unchanged = false
        }
        self.call_scratch.instantiation_arguments.push(parameter)
      }
      let instantiated_result = self.call_scratch.instantiation_results[result_start +
        parameters.length]
      if instantiated_result != self.solver.resolved_type(source_result) {
        unchanged = false
      }
      let result = if unchanged {
        self.solver.resolved_type(source)
      } else {
        self.solver.function_type(
          self.call_scratch.instantiation_arguments,
          instantiated_result,
        )
      }
      self.call_scratch.instantiation_marks[source] = self.call_scratch.instantiation_generation
      self.call_scratch.instantiation_values[source] = result
      self.call_scratch.instantiation_results.truncate(result_start)
      self.call_scratch.instantiation_results.push(result)
    } else {
      let fields = match self.resolved.types[source] {
        ProductType(fields) => fields
        _ => abort("signature instantiation expected a product type")
      }
      self.call_scratch.instantiation_arguments.clear()
      let mut unchanged = true
      for index in 0..<fields.length {
        let field = self.call_scratch.instantiation_results[result_start + index]
        if field !=
          self.solver.resolved_type(
            self.resolved.type_arguments[fields.start + index],
          ) {
          unchanged = false
        }
        self.call_scratch.instantiation_arguments.push(field)
      }
      let result = if unchanged {
        self.solver.resolved_type(source)
      } else {
        self.solver.product_type(self.call_scratch.instantiation_arguments)
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
fn BasicBodyInferencer::is_function_reference(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Bool {
  if !self.has_member_expressions {
    return false
  }
  match self.expression_selections[self.expression_index(expression)] {
    FunctionReferenceSelection(_, _) => true
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
          LocalNameReference(_)
          | LambdaCaptureNameReference(_)
          | ErrorNameReference => ()
          ModuleValueNameReference(name) =>
            if self.module_value_type(name) is None &&
              !self.is_function_reference(expression) &&
              self.local_function_reference_candidate_count(name) == 0 {
              self.mark_unsupported(expression)
            }
          ImportedValueNameReference(head) =>
            if !self.is_function_reference(expression) &&
              self.imported_function_reference_candidate_count(head) == 0 {
              self.mark_unsupported(expression)
            }
          ImportedModuleNameReference(_) => self.mark_unsupported(expression)
          ForeignLibraryNameReference(_) => ()
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
  // A field's declared type is context for variant selection. Resolve only
  // the subject's field chain here; method selectors are not field reads.
  let fields : Array[ExprId] = []
  let mut subject = scrutinee
  while true {
    match self.collected.expressions[subject] {
      HirFieldExpr(base, _, _) => {
        if self.expression_selections[self.expression_index(subject)] !=
          NoExpressionSelection {
          break
        }
        fields.push(subject)
        subject = base
      }
      _ => break
    }
  }
  while fields.length() > 0 {
    let field = fields.pop().unwrap()
    match self.collected.expressions[field] {
      HirFieldExpr(base, name, field_offset) => {
        let _ = self.try_infer_field_expression(field, base, name, field_offset)
      }
      _ => abort("match subject field work item changed kind")
    }
  }
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
    let declared_never_call = self.direct_call_is_declared_never(arm.body)
    if declared_never_call {
      self.constrain(
        body_type,
        self.primitive(NeverType),
        expression_type_origin(arm.body, arm.offset),
      )
    }
    if !declared_never_call && !self.is_never_type(body_type) {
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
  let has_break = Array::make(self.control_span.length, false)
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
fn BasicBodyInferencer::constrain_product_field_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
  base : ExprId,
  index : Int,
  arity : Int,
  offset : UInt64,
) -> Unit {
  if index < 0 || index >= arity || arity < 2 || arity > 32 {
    self.solver.poison_type(self.expression_type(expression))
    return
  }
  let fields : Array[BodyTypeId] = []
  for _ in 0..<arity {
    fields.push(self.solver.fresh_variable())
  }
  let product = self.solver.product_type(fields)
  self.constrain(
    self.expression_type(base),
    product,
    expression_type_origin(expression, offset),
  )
  self.constrain(
    self.expression_type(expression),
    fields[index],
    expression_type_origin(expression, offset),
  )
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
      | HirImportAliasExpr(_, _)
      | HirProductExpr(_, _)
      | HirTypeBindingExpr(_, _) => ()
      HirArrayExpr(elements, offset) => {
        let expression_type = self.solver.representative_type(
          self.expression_type(expression),
        )
        let element_type = match self.solver.type_term(expression_type) {
          BodyAppliedType(_, arguments) if arguments.length == 1 =>
            self.solver.type_arguments[arguments.start]
          _ => self.solver.error_type()
        }
        for index in 0..<elements.length {
          self.constrain(
            self.expression_type(
              self.collected.expression_children[elements.start + index],
            ),
            element_type,
            expression_type_origin(expression, offset),
          )
        }
      }
      HirLambdaExpr(_, _) => ()
      HirReturnExpr(value, offset) =>
        if self.lambda < 0 && self.callable_index < 0 {
          self.diagnose(ReturnOutsideCallable(offset))
        } else if value >= 0 {
          self.constrain_expression_assignable(
            value,
            self.declared_return_type,
            return_type_origin(value, offset),
          )
        } else {
          self.constrain(
            self.primitive(UnitType),
            self.declared_return_type,
            return_type_origin(-1, offset),
          )
        }
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
      HirProductFieldExpr(base, index, arity, offset) =>
        self.constrain_product_field_expression(
          expression, base, index, arity, offset,
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
      HirAssignmentExpr(target, value, offset) => {
        match self.collected.expressions[target] {
          HirFieldExpr(_, _, _) => ()
          _ => {
            let mutable_ = match self.names.expression_references[target] {
              LocalNameReference(local_id) =>
                local_id >= 0 &&
                local_id < self.local_span.length &&
                self.names.locals[self.local_span.start + local_id].mutable_
              LambdaCaptureNameReference(capture) =>
                if self.lambda >= 0 {
                  match self.names.lambda(self.lambda) {
                    Some(lambda_names) =>
                      capture >= 0 &&
                      capture < lambda_names.captures.length &&
                      self.names.captures[lambda_names.captures.start + capture].mutable_
                    None => false
                  }
                } else {
                  false
                }
              ErrorNameReference => false
              _ => {
                self.diagnose(InvalidAssignmentTarget(expression, offset))
                false
              }
            }
            if !mutable_ {
              match self.names.expression_references[target] {
                LocalNameReference(_) | LambdaCaptureNameReference(_) =>
                  self.diagnose(ImmutableAssignmentTarget(expression, offset))
                _ => ()
              }
            }
          }
        }
        self.constrain_assignable(
          self.expression_type(value),
          self.expression_type(target),
          expression_type_origin(expression, offset),
        )
      }
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
  let root_expression = match self.body.root {
    ExpressionBodyRoot(expression) => Some(expression)
    BlockBodyRoot(block) => {
      let items = self.collected.blocks[block].items
      if items.length == 0 {
        None
      } else {
        match self.collected.block_items[items.start + items.length - 1] {
          HirExpressionItem(expression, _) => Some(expression)
          _ => None
        }
      }
    }
  }
  self.result_type = match self.body.root {
    ExpressionBodyRoot(expression) => self.expression_type(expression)
    BlockBodyRoot(block) => self.block_type(block)
  }
  if self.callable_index >= 0 {
    let origin = return_type_origin(
      semantic_id_local(self.body.id),
      self.body.offset,
    )
    match root_expression {
      Some(expression) =>
        if !self.is_unit_type(self.declared_return_type) {
          self.constrain_expression_assignable(
            expression,
            self.declared_return_type,
            origin,
          )
        }
      None =>
        self.constrain_assignable(
          self.result_type,
          self.declared_return_type,
          origin,
        )
    }
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
    UnresolvedLambdaLocalType(_, _, _) => 37
    NumericLiteralOutOfRange(_, _, _) => 38
    InvalidAssignmentTarget(_, _) => 39
    ImmutableAssignmentTarget(_, _) => 40
    FunctionReferenceExpectedTypeRequired(_, _, _) => 41
    NoMatchingFunctionReference(_, _, _) => 42
    AmbiguousFunctionReference(_, _, _, _, _, _) => 43
    UnsatisfiedTraitObligation(_, _, _, _, _) => 44
    CallTypeArgumentCountMismatch(_, _, _, _, _) => 45
  }
}

///|
fn BasicBodyInferencer::validate_field_assignments(
  self : BasicBodyInferencer,
) -> Unit {
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    match self.collected.expressions[expression] {
      HirAssignmentExpr(target, _, offset) =>
        match self.collected.expressions[target] {
          HirFieldExpr(_, _, _) =>
            match self.expression_selections[self.expression_index(target)] {
              FieldAccessSelection(_, mutable_) =>
                if !mutable_ {
                  self.diagnose(ImmutableAssignmentTarget(expression, offset))
                }
              _ => ()
            }
          _ => ()
        }
      _ => ()
    }
  }
}

///|
fn BasicBodyInferencer::constrain_body(self : BasicBodyInferencer) -> Unit {
  self.solver_diagnostic_start = self.solver.diagnostics.length()
  self.initialize_local_types()
  if self.control_span.length > 0 {
    self.initialize_control_types()
  }
  self.initialize_expression_types()
  self.initialize_block_types()
  self.constrain_block_expression_types()
  self.initialize_return_type()
  self.constrain_name_expressions()
  self.constrain_block_items()
  self.constrain_expressions()
  if self.control_span.length > 0 {
    self.constrain_control_results()
  }
  self.constrain_root()
  self.constrain_calls()
  self.constrain_members(false)
  // A member can depend on indexing, while a method/operator can depend on
  // that member. Finish the shared constraint queue before reporting missing
  // calls. Each successful round removes at least one pending call.
  while true {
    let before = self.call_scratch.pending_methods.length() +
      self.call_scratch.pending_operators.length() +
      self.call_scratch.pending_function_calls.length()
    self.constrain_pending_function_calls(false)
    self.constrain_method_calls(false)
    self.constrain_members(false)
    self.constrain_operator_calls(false)
    self.constrain_members(false)
    let after = self.call_scratch.pending_methods.length() +
      self.call_scratch.pending_operators.length() +
      self.call_scratch.pending_function_calls.length()
    guard after <= before else {
      abort("body inference constraint queue grew during resolution")
    }
    if after == before {
      break
    }
  }
  self.constrain_method_calls(true)
  self.constrain_debug_dispatches()
  self.constrain_operator_calls(true)
  self.constrain_members(true)
  self.validate_field_assignments()
  self.constrain_function_references()
  self.constrain_pending_function_calls(true)
  self.solver_diagnostic_end = self.solver.diagnostics.length()
}

///|
fn BasicBodyInferencer::resolve_pending_call_obligations(
  self : BasicBodyInferencer,
) -> Unit {
  for index in 0..<self.pending_call_obligation_expressions.length() {
    self.validate_call_obligations_now(
      self.pending_call_obligation_expressions[index],
      self.pending_call_obligation_declarations[index],
      self.pending_call_obligation_type_arguments[index],
      self.pending_call_obligation_offsets[index],
    )
  }
  self.pending_call_obligation_expressions.clear()
  self.pending_call_obligation_declarations.clear()
  self.pending_call_obligation_type_arguments.clear()
  self.pending_call_obligation_offsets.clear()
}

///|
fn BasicBodyInferencer::resolve_pending_trait_object_coercions(
  self : BasicBodyInferencer,
) -> Unit {
  for index in 0..<self.pending_trait_coercion_expressions.length() {
    self.constrain_expression_assignable(
      self.pending_trait_coercion_expressions[index],
      self.pending_trait_coercion_types[index],
      self.pending_trait_coercion_origins[index],
    )
  }
  self.pending_trait_coercion_expressions.clear()
  self.pending_trait_coercion_types.clear()
  self.pending_trait_coercion_origins.clear()
}

///|
fn BasicBodyInferencer::finish(
  self : BasicBodyInferencer,
) -> BodyInferenceJobResult {
  self.resolve_pending_trait_object_coercions()
  self.resolve_pending_call_obligations()
  self.solver_diagnostic_end = self.solver.diagnostics.length()
  self.finalize_types()
  self.compact_results()
  {
    result_type: self.result_type,
    types: self.compact_types,
    type_arguments: self.compact_arguments,
    expression_types: self.expression_types,
    local_types: self.local_types,
    capture_types: self.capture_types,
    block_types: self.block_types,
    pattern_types: self.pattern_types,
    pattern_constructors: self.pattern_constructors,
    pattern_type_arguments: self.pattern_type_arguments,
    control_state_types: self.control_state_types,
    control_result_types: self.control_result_types,
    expression_selections: self.expression_selections,
    expression_type_arguments: self.expression_type_arguments,
    object_field_targets: self.object_field_targets,
    trait_object_coercions: self.trait_object_coercions,
    call_expressions: self.call_expressions,
    call_targets: self.call_targets,
    operator_targets: self.operator_targets,
    map_hash_targets: self.map_hash_targets,
    map_eq_targets: self.map_eq_targets,
    expression_evidence: self.expression_evidence,
    trait_evidence_roots: self.trait_evidence_roots,
    trait_evidence: self.trait_evidence,
    trait_evidence_children: self.trait_evidence_children,
    trait_evidence_arguments: self.trait_evidence_arguments,
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
      spans[declaration_index] = { start: index, length: 1, }
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
      spans[local_index] = { start: index, length: 1, }
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
fn remap_job_call_target(
  target : InferredCallTarget,
  call_argument_start : Int,
) -> InferredCallTarget {
  match target {
    SelectedInferredCallTarget(declaration, arguments) =>
      SelectedInferredCallTarget(declaration, {
        start: call_argument_start + arguments.start,
        length: arguments.length,
      })
    SelectedBoundInferredCallTarget(declaration, evidence, arguments) =>
      SelectedBoundInferredCallTarget(declaration, evidence, {
        start: call_argument_start + arguments.start,
        length: arguments.length,
      })
    SelectedDynamicTraitCallTarget(trait_, requirement, slot, arguments) =>
      SelectedDynamicTraitCallTarget(trait_, requirement, slot, {
        start: call_argument_start + arguments.start,
        length: arguments.length,
      })
    SelectedFunctionValueCallTarget(expression) =>
      SelectedFunctionValueCallTarget(expression)
    NoInferredCallTarget => NoInferredCallTarget
    ErrorInferredCallTarget => ErrorInferredCallTarget
  }
}

///|
fn merge_job_trait_evidence(
  job : BodyInferenceJobResult,
  expression_start : Int,
  expression_length : Int,
  expression_evidence : Array[HirSpan],
  trait_evidence_roots : Array[Int],
  trait_evidence : Array[InferredTraitEvidence],
  trait_evidence_children : Array[Int],
  trait_evidence_arguments : Array[InferredTraitEvidenceArgument],
) -> Unit {
  let evidence_start = trait_evidence.length()
  let child_start = trait_evidence_children.length()
  let root_start = trait_evidence_roots.length()
  let evidence_argument_start = trait_evidence_arguments.length()
  for argument in job.trait_evidence_arguments {
    trait_evidence_arguments.push(argument)
  }
  for evidence in job.trait_evidence {
    let kind = match evidence.kind {
      ConcreteInferredTraitEvidence(declaration, arguments) =>
        ConcreteInferredTraitEvidence(declaration, {
          start: evidence_argument_start + arguments.start,
          length: arguments.length,
        })
      BoundInferredTraitEvidence(slot) => BoundInferredTraitEvidence(slot)
    }
    trait_evidence.push({
      kind,
      prerequisites: {
        start: child_start + evidence.prerequisites.start,
        length: evidence.prerequisites.length,
      },
    })
  }
  for child in job.trait_evidence_children {
    trait_evidence_children.push(evidence_start + child)
  }
  for root in job.trait_evidence_roots {
    trait_evidence_roots.push(evidence_start + root)
  }
  if job.expression_evidence.length() == 0 {
    return
  }
  for index in 0..<expression_length {
    let span = job.expression_evidence[index]
    expression_evidence[expression_start + index] = {
      start: root_start + span.start,
      length: span.length,
    }
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
      BodyProductType(fields) => {
        let start = values.type_arguments.length()
        for index in 0..<fields.length {
          values.type_arguments.push(
            remap_job_type(job.type_arguments[fields.start + index], type_start),
          )
        }
        values.types.push(BodyProductType({ start, length: fields.length, }))
      }
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
      BodyFunctionType(parameters, result) => {
        let start = values.type_arguments.length()
        for index in 0..<parameters.length {
          values.type_arguments.push(
            remap_job_type(
              job.type_arguments[parameters.start + index],
              type_start,
            ),
          )
        }
        values.types.push(
          BodyFunctionType(
            { start, length: parameters.length, },
            remap_job_type(result, type_start),
          ),
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
    return { values, jobs, }
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
  { values, jobs, }
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
fn infer_module_values_with_imports(
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
  lambda_jobs : Array[BodyInferenceJobResult?],
) -> InferredModuleBodies {
  let bodies : Array[InferredBody] = []
  let lambdas : Array[InferredLambda] = []
  let types : Array[BodyTypeTerm] = [BodyErrorType]
  let type_arguments : Array[BodyTypeId] = []
  let expression_types = Array::make(collected.expressions.length(), 0)
  let local_types = Array::make(names.locals.length(), 0)
  let capture_types = Array::make(names.captures.length(), 0)
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
  let trait_object_coercions = Array::make(
    collected.expressions.length(),
    NoInferredTraitObjectCoercion,
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
  let mut expression_evidence = empty_hir_span_array
  let trait_evidence_roots : Array[Int] = []
  let trait_evidence : Array[InferredTraitEvidence] = []
  let trait_evidence_children : Array[Int] = []
  let trait_evidence_arguments : Array[InferredTraitEvidenceArgument] = []
  let call_type_arguments : Array[BodyTypeId] = []
  let diagnostics : Array[BodyInferenceDiagnostic] = []
  for body_index, body in collected.bodies {
    let job = jobs[body_index].unwrap()
    let type_start = types.length()
    let argument_start = type_arguments.length()
    for local_type_id in 1..<job.types.length() {
      match job.types[local_type_id] {
        BodyVariableType(variable) => types.push(BodyVariableType(variable))
        BodyProductType(fields) => {
          let start = type_arguments.length()
          for index in 0..<fields.length {
            type_arguments.push(
              remap_job_type(
                job.type_arguments[fields.start + index],
                type_start,
              ),
            )
          }
          types.push(BodyProductType({ start, length: fields.length, }))
        }
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
        BodyFunctionType(parameters, result) => {
          let start = type_arguments.length()
          for index in 0..<parameters.length {
            type_arguments.push(
              remap_job_type(
                job.type_arguments[parameters.start + index],
                type_start,
              ),
            )
          }
          types.push(
            BodyFunctionType(
              { start, length: parameters.length, },
              remap_job_type(result, type_start),
            ),
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
          FieldAccessSelection(field, mutable_) =>
            FieldAccessSelection(field, mutable_)
          ImportedModuleValueSelection(declaration) =>
            ImportedModuleValueSelection(declaration)
          FunctionReferenceSelection(declaration, arguments) =>
            FunctionReferenceSelection(declaration, {
              start: expression_argument_start + arguments.start,
              length: arguments.length,
            })
          NoExpressionSelection => NoExpressionSelection
          ErrorExpressionSelection => ErrorExpressionSelection
        }
      }
    }
    for index in 0..<body.object_fields.length {
      object_field_targets[body.object_fields.start + index] = job.object_field_targets[index]
    }
    let job_evidence_start = trait_evidence.length()
    if job.trait_object_coercions.length() > 0 {
      for index in 0..<body.expressions.length {
        trait_object_coercions[body.expressions.start + index] = match
          job.trait_object_coercions[index] {
          SelectedInferredTraitObjectCoercion(trait_, evidence) =>
            SelectedInferredTraitObjectCoercion(
              trait_,
              job_evidence_start + evidence,
            )
          NoInferredTraitObjectCoercion => NoInferredTraitObjectCoercion
          ErrorInferredTraitObjectCoercion => ErrorInferredTraitObjectCoercion
        }
      }
    }
    if job.expression_evidence.length() > 0 && expression_evidence.length() == 0 {
      expression_evidence = Array::make(collected.expressions.length(), {
        start: 0,
        length: 0,
      })
    }
    merge_job_trait_evidence(
      job,
      body.expressions.start,
      body.expressions.length,
      expression_evidence,
      trait_evidence_roots,
      trait_evidence,
      trait_evidence_children,
      trait_evidence_arguments,
    )
    for call_slot in 0..<job.call_expressions.length() {
      let expression = job.call_expressions[call_slot]
      call_targets[expression] = remap_job_call_target(
        job.call_targets[call_slot],
        call_argument_start,
      )
    }
    for index in 0..<body.expressions.length {
      let expression = body.expressions.start + index
      operator_targets[expression] = remap_job_call_target(
        job.operator_targets[index],
        call_argument_start,
      )
      map_hash_targets[expression] = remap_job_call_target(
        job.map_hash_targets[index],
        call_argument_start,
      )
      map_eq_targets[expression] = remap_job_call_target(
        job.map_eq_targets[index],
        call_argument_start,
      )
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
      types: { start: type_start, length: job.types.length() - 1, },
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
  for lambda_index, lambda in collected.lambdas {
    let job = lambda_jobs[lambda_index].unwrap()
    let type_start = types.length()
    let argument_start = type_arguments.length()
    for local_type_id in 1..<job.types.length() {
      match job.types[local_type_id] {
        BodyVariableType(variable) => types.push(BodyVariableType(variable))
        BodyProductType(fields) => {
          let start = type_arguments.length()
          for index in 0..<fields.length {
            type_arguments.push(
              remap_job_type(
                job.type_arguments[fields.start + index],
                type_start,
              ),
            )
          }
          types.push(BodyProductType({ start, length: fields.length, }))
        }
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
        BodyFunctionType(parameters, result) => {
          let start = type_arguments.length()
          for index in 0..<parameters.length {
            type_arguments.push(
              remap_job_type(
                job.type_arguments[parameters.start + index],
                type_start,
              ),
            )
          }
          types.push(
            BodyFunctionType(
              { start, length: parameters.length, },
              remap_job_type(result, type_start),
            ),
          )
        }
        BodyErrorType | BodyResolvedType(_) =>
          abort("unexpected compact lambda type during merge")
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
    for index in 0..<lambda.body.expressions.length {
      let expression = lambda.body.expressions.start + index
      expression_types[expression] = remap_job_type(
        job.expression_types[index],
        type_start,
      )
    }
    if job.expression_selections.length() > 0 {
      for index in 0..<lambda.body.expressions.length {
        let expression = lambda.body.expressions.start + index
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
          FieldAccessSelection(field, mutable_) =>
            FieldAccessSelection(field, mutable_)
          ImportedModuleValueSelection(declaration) =>
            ImportedModuleValueSelection(declaration)
          FunctionReferenceSelection(declaration, arguments) =>
            FunctionReferenceSelection(declaration, {
              start: expression_argument_start + arguments.start,
              length: arguments.length,
            })
          NoExpressionSelection => NoExpressionSelection
          ErrorExpressionSelection => ErrorExpressionSelection
        }
      }
    }
    for index in 0..<lambda.body.object_fields.length {
      object_field_targets[lambda.body.object_fields.start + index] = job.object_field_targets[index]
    }
    let job_evidence_start = trait_evidence.length()
    if job.trait_object_coercions.length() > 0 {
      for index in 0..<lambda.body.expressions.length {
        trait_object_coercions[lambda.body.expressions.start + index] = match
          job.trait_object_coercions[index] {
          SelectedInferredTraitObjectCoercion(trait_, evidence) =>
            SelectedInferredTraitObjectCoercion(
              trait_,
              job_evidence_start + evidence,
            )
          NoInferredTraitObjectCoercion => NoInferredTraitObjectCoercion
          ErrorInferredTraitObjectCoercion => ErrorInferredTraitObjectCoercion
        }
      }
    }
    if job.expression_evidence.length() > 0 && expression_evidence.length() == 0 {
      expression_evidence = Array::make(collected.expressions.length(), {
        start: 0,
        length: 0,
      })
    }
    merge_job_trait_evidence(
      job,
      lambda.body.expressions.start,
      lambda.body.expressions.length,
      expression_evidence,
      trait_evidence_roots,
      trait_evidence,
      trait_evidence_children,
      trait_evidence_arguments,
    )
    for call_slot in 0..<job.call_expressions.length() {
      let expression = job.call_expressions[call_slot]
      call_targets[expression] = remap_job_call_target(
        job.call_targets[call_slot],
        call_argument_start,
      )
    }
    for index in 0..<lambda.body.expressions.length {
      let expression = lambda.body.expressions.start + index
      operator_targets[expression] = remap_job_call_target(
        job.operator_targets[index],
        call_argument_start,
      )
      map_hash_targets[expression] = remap_job_call_target(
        job.map_hash_targets[index],
        call_argument_start,
      )
      map_eq_targets[expression] = remap_job_call_target(
        job.map_eq_targets[index],
        call_argument_start,
      )
    }
    let name_info = names.lambda(lambda.id).unwrap()
    for index in 0..<name_info.locals.length {
      local_types[name_info.locals.start + index] = remap_job_type(
        job.local_types[index],
        type_start,
      )
    }
    for index in 0..<name_info.captures.length {
      capture_types[name_info.captures.start + index] = remap_job_type(
        job.capture_types[index],
        type_start,
      )
    }
    for index in 0..<lambda.body.blocks.length {
      block_types[lambda.body.blocks.start + index] = remap_job_type(
        job.block_types[index],
        type_start,
      )
    }
    for index in 0..<lambda.body.patterns.length {
      let pattern = lambda.body.patterns.start + index
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
    lambdas.push({
      lambda: lambda.id,
      root_type: remap_job_type(job.result_type, type_start),
      types: { start: type_start, length: job.types.length() - 1, },
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
    lambdas,
    types,
    type_arguments,
    expression_types,
    local_types,
    capture_types,
    block_types,
    pattern_types,
    pattern_constructors,
    pattern_type_arguments,
    control_state_types,
    control_result_types,
    expression_selections,
    expression_type_arguments,
    object_field_targets,
    trait_object_coercions,
    call_targets,
    operator_targets,
    map_hash_targets,
    map_eq_targets,
    expression_evidence,
    trait_evidence_roots,
    trait_evidence,
    trait_evidence_children,
    trait_evidence_arguments,
    call_type_arguments,
    diagnostics,
  }
}

///|
fn infer_module_bodies_with_imports_in_order_and_family_cache(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports?,
  names : ResolvedModuleNames,
  order : Array[Int],
  cached_families : Array[BodyInferenceFamilyArtifact?],
) -> Result[BodyInferenceFamilyAnalysis, String] {
  guard collected.module_id == resolved.module_id &&
    collected.module_id == names.module_id else {
    abort("body inference inputs belong to different modules")
  }
  guard order.length() == collected.bodies.length() else {
    abort("body inference order has the wrong length")
  }
  if cached_families.length() != collected.bodies.length() {
    return Err("body-family cache slot count mismatch")
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
  let lambda_jobs : Array[BodyInferenceJobResult?] = Array::make(
    collected.lambdas.length(),
    None,
  )
  let families : Array[BodyInferenceFamilyArtifact?] = Array::make(
    collected.bodies.length(),
    None,
  )
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
  let mut family_hits = 0
  let mut family_misses = 0
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
      if cached_families[body_index] is Some(_) {
        return Err("module-value body has an unexpected family artifact")
      }
      continue
    }
    match cached_families[body_index] {
      Some(artifact) => {
        match
          validate_body_inference_family_artifact(
            collected, names, body_index, artifact,
          ) {
          Ok(_) => ()
          Err(error) => return Err(error)
        }
        restore_body_inference_family_artifact(
          collected, artifact, jobs, lambda_jobs,
        )
        families[body_index] = Some(artifact)
        family_hits += 1
        continue
      }
      None => family_misses += 1
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
  let job_importer = BodyJobTypeImporter::new(solver)
  for lambda_index, lambda in collected.lambdas {
    if lambda_jobs[lambda_index] is Some(_) {
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
    let capture_types : Array[BodyTypeId] = []
    let lambda_names = names.lambda(lambda.id).unwrap()
    for capture_index in 0..<lambda_names.captures.length {
      let capture = names.captures[lambda_names.captures.start + capture_index]
      let (source_job, source_type) = match capture.source {
        BodyLocalCapture(body, local_id) => {
          let job = jobs[semantic_id_local(body)].unwrap()
          (job, job.local_types[local_id])
        }
        LambdaLocalCapture(owner, local_id) => {
          let job = lambda_jobs[owner].unwrap()
          (job, job.local_types[local_id])
        }
      }
      capture_types.push(job_importer.import_type(source_job, source_type))
    }
    lambda_jobs[lambda_index] = Some(
      BasicBodyInferencer::new_lambda(
        collected, resolved, imports, impl_index, names, lambda, capture_types, callable_indices,
        variant_spans, field_spans, solver, call_scratch, module_values,
      ).run(),
    )
  }
  for body_index, body in collected.bodies {
    if body.kind != ModuleLetBody && families[body_index] is None {
      families[body_index] = Some(
        make_body_inference_family_artifact(
          collected,
          body,
          jobs[body_index].unwrap(),
          lambda_jobs,
        ),
      )
    }
  }
  Ok({
    inferred: merge_body_inference_jobs(
      collected,
      names,
      module_result.values,
      impl_index,
      jobs,
      lambda_jobs,
    ),
    families,
    family_hits,
    family_misses,
  })
}

///|
fn infer_module_bodies_in_order(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  names : ResolvedModuleNames,
  order : Array[Int],
) -> InferredModuleBodies {
  infer_module_bodies_with_imports_in_order_and_family_cache(
    collected,
    resolved,
    None,
    names,
    order,
    Array::make(collected.bodies.length(), None),
  ).unwrap().inferred
}

///|
pub fn infer_module_bodies_with_family_cache_in_order(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  names : ResolvedModuleNames,
  cached_families : Array[BodyInferenceFamilyArtifact?],
  order : Array[Int],
) -> Result[BodyInferenceFamilyAnalysis, String] {
  infer_module_bodies_with_imports_in_order_and_family_cache(
    collected,
    resolved,
    None,
    names,
    order,
    cached_families,
  )
}

///|
pub fn infer_module_bodies_with_family_cache(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  names : ResolvedModuleNames,
  cached_families : Array[BodyInferenceFamilyArtifact?],
) -> Result[BodyInferenceFamilyAnalysis, String] {
  let order : Array[Int] = []
  for index in 0..<collected.bodies.length() {
    order.push(index)
  }
  infer_module_bodies_with_imports_in_order_and_family_cache(
    collected,
    resolved,
    None,
    names,
    order,
    cached_families,
  )
}

///|
pub fn infer_module_bodies_with_imports_and_family_cache(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports,
  names : ResolvedModuleNames,
  cached_families : Array[BodyInferenceFamilyArtifact?],
) -> Result[BodyInferenceFamilyAnalysis, String] {
  guard collected.module_id == imports.module_id else {
    abort("body import scope belongs to another module")
  }
  let order : Array[Int] = []
  for index in 0..<collected.bodies.length() {
    order.push(index)
  }
  infer_module_bodies_with_imports_in_order_and_family_cache(
    collected,
    resolved,
    Some(imports),
    names,
    order,
    cached_families,
  )
}

///|
pub fn infer_module_bodies_with_imports(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports,
  names : ResolvedModuleNames,
) -> InferredModuleBodies {
  infer_module_bodies_with_imports_and_family_cache(
    collected,
    resolved,
    imports,
    names,
    Array::make(collected.bodies.length(), None),
  ).unwrap().inferred
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
