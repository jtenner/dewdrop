///|
fn arena_span_is_valid(span : HirSpan, length : Int) -> Bool {
  span.start >= 0 &&
  span.length >= 0 &&
  span.start + span.length >= span.start &&
  span.start + span.length <= length
}

///|
pub struct PlannedLoweredBodyView {
  body : PlannedBodyLowering
  locals : ArrayView[PlannedLocal]
  expressions : ArrayView[PlannedExpression]
  blocks : ArrayView[PlannedBlock]
  patterns : ArrayView[PlannedPattern]
  pattern_arms : ArrayView[PlannedPatternArm]
  diagnostics : ArrayView[LoweringPlanDiagnostic]
}

///|
pub fn PlannedModuleLowering::body_view(
  self : PlannedModuleLowering,
  body : BodyId,
) -> PlannedLoweredBodyView? {
  if semantic_id_module(body) != self.module_id {
    return None
  }
  let index = semantic_id_local(body)
  if index < 0 || index >= self.bodies.length() {
    return None
  }
  let planned = self.bodies[index]
  if !arena_span_is_valid(planned.locals, self.locals.length()) ||
    !arena_span_is_valid(planned.expressions, self.expressions.length()) ||
    !arena_span_is_valid(planned.blocks, self.blocks.length()) ||
    !arena_span_is_valid(planned.patterns, self.patterns.length()) ||
    !arena_span_is_valid(planned.pattern_arms, self.pattern_arms.length()) ||
    !arena_span_is_valid(planned.diagnostics, self.diagnostics.length()) {
    return None
  }
  Some({
    body: planned,
    locals: self.locals[planned.locals.start:planned.locals.start +
    planned.locals.length],
    expressions: self.expressions[planned.expressions.start:planned.expressions.start +
    planned.expressions.length],
    blocks: self.blocks[planned.blocks.start:planned.blocks.start +
    planned.blocks.length],
    patterns: self.patterns[planned.patterns.start:planned.patterns.start +
    planned.patterns.length],
    pattern_arms: self.pattern_arms[planned.pattern_arms.start:planned.pattern_arms.start +
    planned.pattern_arms.length],
    diagnostics: self.diagnostics[planned.diagnostics.start:planned.diagnostics.start +
    planned.diagnostics.length],
  })
}

///|
pub struct ResolvedTypeView {
  type_ : ResolvedType
  arguments : ArrayView[ResolvedTypeId]
}

///|
pub fn ResolvedModuleTypes::type_view(
  self : ResolvedModuleTypes,
  type_ : ResolvedTypeId,
) -> ResolvedTypeView? {
  if type_ < 0 || type_ >= self.types.length() {
    return None
  }
  let value = self.types[type_]
  let arguments = match value {
    AppliedType(_, span) | FunctionType(span, _) => {
      if !arena_span_is_valid(span, self.type_arguments.length()) {
        return None
      }
      self.type_arguments[span.start:span.start + span.length]
    }
    _ => self.type_arguments[0:0]
  }
  Some({ type_: value, arguments })
}

///|
pub struct PlannedCallSpecializationView {
  function : PlannedWasmFunctionFragment
  parameters : ArrayView[PlannedWasmValueType]
  results : ArrayView[PlannedWasmValueType]
  shapes : ArrayView[PlannedValueShape]
  evidence_roots : ArrayView[Int]
}

///|
pub fn PlannedModuleWasmGCFragments::function_view(
  self : PlannedModuleWasmGCFragments,
  index : Int,
) -> PlannedCallSpecializationView? {
  if index < 0 || index >= self.functions.length() {
    return None
  }
  let function_ = self.functions[index]
  if !arena_span_is_valid(
      function_.parameters,
      self.function_value_types.length(),
    ) ||
    !arena_span_is_valid(function_.results, self.function_value_types.length()) ||
    !arena_span_is_valid(
      function_.specialization_shapes,
      self.specialization_shapes.length(),
    ) ||
    !arena_span_is_valid(
      function_.specialization_evidence,
      self.specialization_evidence_roots.length(),
    ) {
    return None
  }
  Some({
    function: function_,
    parameters: self.function_value_types[function_.parameters.start:function_.parameters.start +
    function_.parameters.length],
    results: self.function_value_types[function_.results.start:function_.results.start +
    function_.results.length],
    shapes: self.specialization_shapes[function_.specialization_shapes.start:function_.specialization_shapes.start +
    function_.specialization_shapes.length],
    evidence_roots: self.specialization_evidence_roots[function_.specialization_evidence.start:function_.specialization_evidence.start +
    function_.specialization_evidence.length],
  })
}

///|
pub struct PlannedTraitEvidenceView {
  evidence : InferredTraitEvidence
  prerequisites : ArrayView[Int]
}

///|
pub fn PlannedModuleLowering::trait_evidence_view(
  self : PlannedModuleLowering,
  index : Int,
) -> PlannedTraitEvidenceView? {
  if index < 0 || index >= self.trait_evidence.length() {
    return None
  }
  let evidence = self.trait_evidence[index]
  if !arena_span_is_valid(
      evidence.prerequisites,
      self.trait_evidence_children.length(),
    ) {
    return None
  }
  Some({
    evidence,
    prerequisites: self.trait_evidence_children[evidence.prerequisites.start:evidence.prerequisites.start +
    evidence.prerequisites.length],
  })
}

///|
pub struct PlannedProgramFunctionView {
  function : PlannedProgramWasmFunction
  fragments : PlannedModuleWasmGCFragments
  specialization_shapes : ArrayView[PlannedValueShape]
  specialization_evidence : ArrayView[Int]
}

///|
pub fn PlannedProgramWasmGCLink::function_view(
  self : PlannedProgramWasmGCLink,
  index : Int,
) -> PlannedProgramFunctionView? {
  if index < 0 || index >= self.functions.length() {
    return None
  }
  let function_ = self.functions[index]
  if function_.module_index < 0 ||
    function_.module_index >= self.modules.length() {
    return None
  }
  let module_ = self.modules[function_.module_index]
  if !arena_span_is_valid(
      function_.specialization_shapes,
      module_.specialization_shapes.length(),
    ) ||
    !arena_span_is_valid(
      function_.specialization_evidence,
      module_.specialization_evidence_roots.length(),
    ) {
    return None
  }
  Some({
    function: function_,
    fragments: module_,
    specialization_shapes: module_.specialization_shapes[function_.specialization_shapes.start:function_.specialization_shapes.start +
    function_.specialization_shapes.length],
    specialization_evidence: module_.specialization_evidence_roots[function_.specialization_evidence.start:function_.specialization_evidence.start +
    function_.specialization_evidence.length],
  })
}

///|
fn validate_planned_module_lowering_arenas(
  module_ : PlannedModuleLowering,
) -> Result[Unit, String] {
  for body in module_.bodies {
    if module_.body_view(body.body) is None {
      return Err("lowered body contains an invalid arena span")
    }
  }
  for span in module_.expression_evidence {
    if !arena_span_is_valid(span, module_.trait_evidence_roots.length()) {
      return Err("lowered expression evidence span is outside its arena")
    }
  }
  for evidence_index in 0..<module_.trait_evidence.length() {
    if module_.trait_evidence_view(evidence_index) is None {
      return Err("lowered trait evidence span is outside its arena")
    }
  }
  Ok(())
}

///|
fn validate_module_wasmgc_arenas(
  module_ : PlannedModuleWasmGCFragments,
) -> Result[Unit, String] {
  for index in 0..<module_.functions.length() {
    if module_.function_view(index) is None {
      return Err("WasmGC function contains an invalid arena span")
    }
  }
  Ok(())
}
