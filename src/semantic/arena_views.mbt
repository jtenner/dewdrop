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
  Some({ type_: value, arguments, })
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
fn validate_wasmgc_storage_type(
  storage : PlannedWasmStorageType,
  physical_count : Int,
  signature_limit : Int,
) -> Bool {
  match storage {
    WasmFunctionRefStorage(index) => index >= 0 && index < signature_limit
    WasmNominalRefStorage(WasmModuleTypeReference(index))
    | WasmNullableNominalRefStorage(WasmModuleTypeReference(index)) =>
      index >= 0 && index < physical_count
    WasmNominalRefStorage(WasmRecursiveTypeReference(index))
    | WasmNullableNominalRefStorage(WasmRecursiveTypeReference(index)) =>
      index >= 0
    WasmFixedArrayRefStorage(carrier) => carrier >= 0 && carrier < 8
    _ => true
  }
}

///|
fn validate_wasmgc_value_type(
  value : PlannedWasmValueType,
  physical_count : Int,
  signature_limit : Int,
) -> Bool {
  match value {
    WasmFunctionRefValue(index) => index >= 0 && index < signature_limit
    WasmNominalRefValue(index) | WasmNullableNominalRefValue(index) =>
      index >= 0 && index < physical_count
    WasmFixedArrayRefValue(carrier) => carrier >= 0 && carrier < 8
    _ => true
  }
}

///|
pub fn validate_module_wasmgc_arenas(
  module_ : PlannedModuleWasmGCFragments,
) -> Result[Unit, String] {
  let physical_count = module_.physical_types.length()
  let signature_limit = physical_count + module_.signature_type_count
  if module_.signature_type_count < 0 ||
    module_.imported_function_count < 0 ||
    module_.defined_function_count < 0 {
    return Err("WasmGC fragment count is negative")
  }
  let physical_seen = Array::make(physical_count, false)
  let mut covered_physical_types = 0
  for group_index, group in module_.type_groups {
    if !arena_span_is_valid(group.types, physical_count) ||
      group.types.length == 0 ||
      group.first_type_index < 0 {
      return Err("WasmGC recursive group contains an invalid arena span")
    }
    for index in 0..<group.types.length {
      let physical = module_.physical_types[group.types.start + index]
      covered_physical_types += 1
      if physical.group_index != group_index {
        return Err("WasmGC physical type has an inconsistent group index")
      }
    }
  }
  if covered_physical_types != physical_count {
    return Err("WasmGC recursive groups do not cover every physical type")
  }
  for physical in module_.physical_types {
    if physical.type_index < 0 ||
      physical.type_index >= physical_count ||
      physical_seen[physical.type_index] ||
      physical.group_index < 0 ||
      physical.group_index >= module_.type_groups.length() ||
      !arena_span_is_valid(physical.fields, module_.fields.length()) {
      return Err("WasmGC physical type contains an invalid index or span")
    }
    physical_seen[physical.type_index] = true
  }
  for field in module_.fields {
    if field.physical_index < 0 ||
      !validate_wasmgc_storage_type(
        field.storage,
        physical_count,
        signature_limit,
      ) {
      return Err("WasmGC field has a negative physical index")
    }
  }
  if module_.payload_type_index_by_variant.length() !=
    module_.variant_declarations.length() ||
    module_.variant_declarations.length() != module_.variant_tags.length() ||
    module_.variant_tags.length() != module_.variant_field_spans.length() {
    return Err("WasmGC variant lookup arenas have different lengths")
  }
  for variant_index, tag in module_.variant_tags {
    if tag < -1 ||
      (
        tag >= 0 &&
        semantic_id_module(module_.variant_declarations[variant_index]) !=
        module_.module_id
      ) {
      return Err("WasmGC variant lookup record is invalid")
    }
  }
  for span in module_.variant_field_spans {
    if !arena_span_is_valid(span, module_.variant_fields.length()) {
      return Err("WasmGC variant field span is outside its arena")
    }
  }
  for index in module_.type_index_by_declaration {
    if index < -1 || index >= physical_count {
      return Err("WasmGC declaration type index is out of range")
    }
  }
  for index in module_.payload_type_index_by_variant {
    if index < -1 || index >= physical_count {
      return Err("WasmGC variant payload type index is out of range")
    }
  }
  if module_.closure_type_index < -1 ||
    module_.closure_type_index >= physical_count ||
    module_.capture_cell_type_indices.length() != 6 {
    return Err("WasmGC closure type index is invalid")
  }
  for
    indices in [
      module_.capture_cell_type_indices,
      module_.lambda_closure_type_indices,
    ] {
    for index in indices {
      if index < -1 || index >= physical_count {
        return Err("WasmGC synthetic type index is out of range")
      }
    }
  }
  for index in module_.lambda_capture_field_indices {
    if index < -1 {
      return Err("WasmGC lambda capture field index is invalid")
    }
  }
  for field in module_.variant_fields {
    if field.physical_index < 0 ||
      !validate_wasmgc_storage_type(
        field.storage,
        physical_count,
        signature_limit,
      ) {
      return Err("WasmGC variant field contains an invalid index")
    }
  }
  for value in module_.function_value_types {
    if !validate_wasmgc_value_type(value, physical_count, signature_limit) {
      return Err("WasmGC function value type contains an invalid index")
    }
  }
  for function_type in module_.function_types {
    if function_type.signature_type_index < 0 ||
      function_type.signature_type_index >= signature_limit ||
      !arena_span_is_valid(
        function_type.parameters,
        module_.function_value_types.length(),
      ) ||
      !arena_span_is_valid(
        function_type.results,
        module_.function_value_types.length(),
      ) {
      return Err("WasmGC function type contains an invalid index or span")
    }
  }
  for
    indices in [
      module_.function_type_by_resolved,
      module_.closure_entry_type_by_resolved,
      module_.erased_closure_direct_type_by_resolved,
      module_.erased_closure_entry_type_by_resolved,
      module_.lambda_entry_signature_indices,
    ] {
    for index in indices {
      if index < -1 || index >= signature_limit {
        return Err("WasmGC signature lookup index is out of range")
      }
    }
  }
  for
    indices in [
      module_.closure_entry_type_by_resolved,
      module_.erased_closure_direct_type_by_resolved,
      module_.erased_closure_entry_type_by_resolved,
    ] {
    if indices.length() != module_.function_type_by_resolved.length() {
      return Err(
        "WasmGC callback signature lookup arenas have different lengths",
      )
    }
  }
  for index in module_.lambda_capture_parameter_indices {
    if index < -1 {
      return Err("WasmGC lambda capture parameter index is invalid")
    }
  }
  for key, layout in module_.specialized_lambda_layouts {
    if key == "" ||
      layout.closure_types.length() !=
      module_.lambda_closure_type_indices.length() ||
      layout.capture_fields.length() !=
      module_.lambda_capture_field_indices.length() ||
      layout.capture_parameters.length() !=
      module_.lambda_capture_parameter_indices.length() {
      return Err(
        "WasmGC specialized lambda lookup arenas have different lengths",
      )
    }
    for lambda, type_ in layout.closure_types {
      if type_ < -1 || type_ >= physical_count {
        return Err("WasmGC specialized closure type is outside its arena")
      }
      if type_ >= 0 &&
        module_.physical_types[type_].kind !=
        PlannedWasmLambdaClosureType(lambda) {
        return Err("WasmGC specialized closure has the wrong lambda identity")
      }
    }
    for table in [layout.capture_fields, layout.capture_parameters] {
      for index in table {
        if index < -1 {
          return Err("WasmGC specialized capture has an invalid index")
        }
      }
    }
  }
  if module_.trait_layout_methods.length() !=
    module_.trait_method_signature_indices.length() {
    return Err("WasmGC trait layout arenas have different lengths")
  }
  for layout in module_.trait_layouts {
    if layout.vtable_type_index < 0 ||
      layout.vtable_type_index >= physical_count ||
      layout.object_type_index < 0 ||
      layout.object_type_index >= physical_count ||
      !arena_span_is_valid(
        layout.methods,
        module_.trait_layout_methods.length(),
      ) {
      return Err("WasmGC trait layout contains an invalid index or span")
    }
  }
  for index in module_.trait_method_signature_indices {
    if index < 0 || index >= signature_limit {
      return Err("WasmGC trait method signature index is out of range")
    }
  }
  for dictionary in module_.trait_dictionaries {
    if dictionary.vtable_type_index < 0 ||
      dictionary.vtable_type_index >= physical_count ||
      dictionary.object_type_index < 0 ||
      dictionary.object_type_index >= physical_count ||
      !arena_span_is_valid(dictionary.methods, module_.trait_methods.length()) ||
      !arena_span_is_valid(
        dictionary.runtime_evidence_parameters,
        module_.trait_dictionary_runtime_evidence_parameters.length(),
      ) {
      return Err("WasmGC trait dictionary contains an invalid index or span")
    }
  }
  for trait_method in module_.trait_methods {
    if trait_method.slot < 0 ||
      trait_method.signature_type_index < 0 ||
      trait_method.signature_type_index >= signature_limit ||
      trait_method.adapter_function < -1 ||
      trait_method.adapter_function >= module_.functions.length() {
      return Err("WasmGC trait method contains an invalid index")
    }
  }
  for index in 0..<module_.functions.length() {
    if module_.function_view(index) is None {
      return Err("WasmGC function contains an invalid arena span")
    }
    let function_ = module_.functions[index]
    if function_.signature_type_index < -1 ||
      function_.signature_type_index >= signature_limit ||
      function_.function_index < -1 ||
      function_.function_index >=
      module_.imported_function_count + module_.defined_function_count {
      return Err("WasmGC function contains an invalid index")
    }
  }
  for declaration_index, function_index in module_.function_by_declaration {
    if function_index < -1 || function_index >= module_.functions.length() {
      return Err("WasmGC declaration function index is out of range")
    }
    if function_index >= 0 &&
      semantic_id_module(module_.functions[function_index].declaration) ==
      module_.module_id &&
      semantic_id_local(module_.functions[function_index].declaration) !=
      declaration_index {
      return Err("WasmGC declaration function lookup is inconsistent")
    }
  }
  for function_index in module_.lambda_function_indices {
    if function_index < -1 || function_index >= module_.functions.length() {
      return Err("WasmGC lambda function index is out of range")
    }
  }
  for root in module_.specialization_evidence_roots {
    if root < 0 || root >= module_.specialization_trait_evidence.length() {
      return Err("WasmGC specialization evidence root is out of range")
    }
  }
  for evidence in module_.specialization_trait_evidence {
    if !arena_span_is_valid(
        evidence.prerequisites,
        module_.specialization_evidence_children.length(),
      ) {
      return Err("WasmGC specialization prerequisite span is outside its arena")
    }
    match evidence.kind {
      PlannedConcreteTraitEvidence(_, arguments) =>
        if !arena_span_is_valid(
            arguments,
            module_.specialization_evidence_arguments.length(),
          ) {
          return Err("WasmGC specialization argument span is outside its arena")
        }
      PlannedRuntimeTraitEvidence(_, parameter) =>
        if parameter < 0 {
          return Err("WasmGC runtime evidence parameter is negative")
        }
    }
  }
  for child in module_.specialization_evidence_children {
    if child < 0 || child >= module_.specialization_trait_evidence.length() {
      return Err("WasmGC specialization evidence child is out of range")
    }
  }
  Ok(())
}
