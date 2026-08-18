///|
fn rebase_family_source_id(source : Int, delta : Int) -> Int {
  if source < 0 {
    source
  } else {
    source + delta
  }
}

///|
fn rebase_family_offset(value : UInt64, delta : Int) -> UInt64 {
  let rebased = value.to_uint().reinterpret_as_int() + delta
  if rebased < 0 {
    0UL
  } else {
    rebased.reinterpret_as_uint().to_uint64()
  }
}

///|
fn rebase_family_origin(
  origin : TypeConstraintOrigin,
  expression_delta : Int,
  pattern_delta : Int,
  offset_delta : Int,
) -> TypeConstraintOrigin {
  let source = match origin.kind {
    ExpressionTypeConstraint | CallTypeConstraint | OperatorTypeConstraint =>
      rebase_family_source_id(origin.source, expression_delta)
    PatternTypeConstraint =>
      rebase_family_source_id(origin.source, pattern_delta)
    LocalTypeConstraint | ReturnTypeConstraint | SyntheticTypeConstraint =>
      origin.source
  }
  {
    ..origin,
    source,
    offset: rebase_family_offset(origin.offset, offset_delta),
  }
}

///|
fn rebase_family_local_diagnostic(
  diagnostic : LocalInferenceDiagnostic,
  expression_delta : Int,
  pattern_delta : Int,
  offset_delta : Int,
) -> LocalInferenceDiagnostic {
  match diagnostic {
    LocalTypeMismatch(left, right, origin) =>
      LocalTypeMismatch(
        left,
        right,
        rebase_family_origin(
          origin, expression_delta, pattern_delta, offset_delta,
        ),
      )
    InfiniteLocalType(variable, type_, origin) =>
      InfiniteLocalType(
        variable,
        type_,
        rebase_family_origin(
          origin, expression_delta, pattern_delta, offset_delta,
        ),
      )
  }
}

///|
fn rebase_family_diagnostic(
  diagnostic : BodyInferenceDiagnostic,
  expression_delta : Int,
  pattern_delta : Int,
  offset_delta : Int,
) -> BodyInferenceDiagnostic {
  let expression = fn(value : ExprId) {
    rebase_family_source_id(value, expression_delta)
  }
  let pattern = fn(value : PatternId) {
    rebase_family_source_id(value, pattern_delta)
  }
  let source_offset = fn(value : UInt64) {
    rebase_family_offset(value, offset_delta)
  }
  match diagnostic {
    BodyConstraintDiagnostic(value) =>
      BodyConstraintDiagnostic(
        rebase_family_local_diagnostic(
          value, expression_delta, pattern_delta, offset_delta,
        ),
      )
    NumericLiteralOutOfRange(value, primitive, offset) =>
      NumericLiteralOutOfRange(
        expression(value),
        primitive,
        source_offset(offset),
      )
    UnsupportedExpressionInference(value, offset) =>
      UnsupportedExpressionInference(expression(value), source_offset(offset))
    InvalidCallTarget(value, offset) =>
      InvalidCallTarget(expression(value), source_offset(offset))
    InvalidAssignmentTarget(value, offset) =>
      InvalidAssignmentTarget(expression(value), source_offset(offset))
    ImmutableAssignmentTarget(value, offset) =>
      ImmutableAssignmentTarget(expression(value), source_offset(offset))
    FunctionReferenceExpectedTypeRequired(name, value, offset) =>
      FunctionReferenceExpectedTypeRequired(
        name,
        expression(value),
        source_offset(offset),
      )
    NoMatchingFunctionReference(name, value, offset) =>
      NoMatchingFunctionReference(
        name,
        expression(value),
        source_offset(offset),
      )
    AmbiguousFunctionReference(name, value, first, second, count, offset) =>
      AmbiguousFunctionReference(
        name,
        expression(value),
        first,
        second,
        count,
        source_offset(offset),
      )
    FunctionCallArgumentCountMismatch(value, expected, actual, offset) =>
      FunctionCallArgumentCountMismatch(
        expression(value),
        expected,
        actual,
        source_offset(offset),
      )
    CallArgumentCountMismatch(value, declaration, expected, actual, offset) =>
      CallArgumentCountMismatch(
        expression(value),
        declaration,
        expected,
        actual,
        source_offset(offset),
      )
    CallTypeArgumentCountMismatch(value, declaration, expected, actual, offset) =>
      CallTypeArgumentCountMismatch(
        expression(value),
        declaration,
        expected,
        actual,
        source_offset(offset),
      )
    NoMatchingCallOverload(name, value, offset) =>
      NoMatchingCallOverload(name, expression(value), source_offset(offset))
    AmbiguousCallOverload(name, value, first, second, count, offset) =>
      AmbiguousCallOverload(
        name,
        expression(value),
        first,
        second,
        count,
        source_offset(offset),
      )
    UnresolvedCallTypeArgument(value, index, offset) =>
      UnresolvedCallTypeArgument(
        expression(value),
        index,
        source_offset(offset),
      )
    UnresolvedModuleValue(declaration, offset) =>
      UnresolvedModuleValue(declaration, source_offset(offset))
    InvalidPatternConstructor(value, offset) =>
      InvalidPatternConstructor(pattern(value), source_offset(offset))
    UnknownVariantForType(name, declaration, value, offset) =>
      UnknownVariantForType(
        name,
        declaration,
        pattern(value),
        source_offset(offset),
      )
    AmbiguousPatternVariant(name, value, first, second, count, offset) =>
      AmbiguousPatternVariant(
        name,
        pattern(value),
        first,
        second,
        count,
        source_offset(offset),
      )
    PatternPayloadKindMismatch(value, expected, offset) =>
      PatternPayloadKindMismatch(
        pattern(value),
        expected,
        source_offset(offset),
      )
    PatternPayloadArityMismatch(value, expected, actual, offset) =>
      PatternPayloadArityMismatch(
        pattern(value),
        expected,
        actual,
        source_offset(offset),
      )
    UnknownPatternField(name, value, offset) =>
      UnknownPatternField(name, pattern(value), source_offset(offset))
    MissingPatternField(name, value, offset) =>
      MissingPatternField(name, pattern(value), source_offset(offset))
    MissingImportedPatternField(name, value, offset) =>
      MissingImportedPatternField(name, pattern(value), source_offset(offset))
    UnresolvedPatternTypeArgument(value, index, offset) =>
      UnresolvedPatternTypeArgument(
        pattern(value),
        index,
        source_offset(offset),
      )
    InvalidConstructionTarget(value, offset) =>
      InvalidConstructionTarget(expression(value), source_offset(offset))
    ObjectTypeRequired(value, offset) =>
      ObjectTypeRequired(expression(value), source_offset(offset))
    ConstructionPayloadKindMismatch(value, expected, offset) =>
      ConstructionPayloadKindMismatch(
        expression(value),
        expected,
        source_offset(offset),
      )
    ConstructionPayloadArityMismatch(value, variant, expected, actual, offset) =>
      ConstructionPayloadArityMismatch(
        expression(value),
        variant,
        expected,
        actual,
        source_offset(offset),
      )
    UnknownVariantValue(name, value, offset) =>
      UnknownVariantValue(name, expression(value), source_offset(offset))
    AmbiguousVariantValue(name, value, first, second, count, offset) =>
      AmbiguousVariantValue(
        name,
        expression(value),
        first,
        second,
        count,
        source_offset(offset),
      )
    DuplicateConstructionField(name, first, second) =>
      DuplicateConstructionField(
        name,
        source_offset(first),
        source_offset(second),
      )
    UnknownConstructionField(name, value, offset) =>
      UnknownConstructionField(name, expression(value), source_offset(offset))
    MissingConstructionField(name, value, offset) =>
      MissingConstructionField(name, expression(value), source_offset(offset))
    FieldAccessRequiresNominal(value, offset) =>
      FieldAccessRequiresNominal(expression(value), source_offset(offset))
    UnknownFieldForType(name, declaration, value, offset) =>
      UnknownFieldForType(
        name,
        declaration,
        expression(value),
        source_offset(offset),
      )
    UnknownQualifiedMember(name, declaration, value, offset) =>
      UnknownQualifiedMember(
        name,
        declaration,
        expression(value),
        source_offset(offset),
      )
    UnknownImportedModuleMember(name, value, offset) =>
      UnknownImportedModuleMember(
        name,
        expression(value),
        source_offset(offset),
      )
    NoMatchingMethod(name, value, offset) =>
      NoMatchingMethod(name, expression(value), source_offset(offset))
    AmbiguousMethod(name, value, first, second, count, offset) =>
      AmbiguousMethod(
        name,
        expression(value),
        first,
        second,
        count,
        source_offset(offset),
      )
    UnsatisfiedTraitObligation(declaration, parameter, trait_, value, offset) =>
      UnsatisfiedTraitObligation(
        declaration,
        parameter,
        trait_,
        expression(value),
        source_offset(offset),
      )
    UnresolvedExpressionTypeArgument(value, index, offset) =>
      UnresolvedExpressionTypeArgument(
        expression(value),
        index,
        source_offset(offset),
      )
    ReturnOutsideCallable(offset) =>
      ReturnOutsideCallable(source_offset(offset))
    UnresolvedExpressionType(value, offset) =>
      UnresolvedExpressionType(expression(value), source_offset(offset))
    UnresolvedLocalType(body, local_id, offset) =>
      UnresolvedLocalType(body, local_id, source_offset(offset))
    UnresolvedLambdaLocalType(lambda, local_id, offset) =>
      UnresolvedLambdaLocalType(lambda, local_id, source_offset(offset))
  }
}

///|
fn rebase_family_call_target(
  target : InferredCallTarget,
  expression_delta : Int,
) -> InferredCallTarget {
  match target {
    SelectedFunctionValueCallTarget(expression) =>
      SelectedFunctionValueCallTarget(
        rebase_family_source_id(expression, expression_delta),
      )
    other => other
  }
}

///|
fn rebase_body_inference_job(
  job : BodyInferenceJobResult,
  expression_delta : Int,
  pattern_delta : Int,
  offset_delta : Int,
) -> BodyInferenceJobResult {
  let call_expressions : Array[ExprId] = []
  for expression in job.call_expressions {
    call_expressions.push(rebase_family_source_id(expression, expression_delta))
  }
  let call_targets : Array[InferredCallTarget] = []
  for target in job.call_targets {
    call_targets.push(rebase_family_call_target(target, expression_delta))
  }
  let operator_targets : Array[InferredCallTarget] = []
  for target in job.operator_targets {
    operator_targets.push(rebase_family_call_target(target, expression_delta))
  }
  let map_hash_targets : Array[InferredCallTarget] = []
  for target in job.map_hash_targets {
    map_hash_targets.push(rebase_family_call_target(target, expression_delta))
  }
  let map_eq_targets : Array[InferredCallTarget] = []
  for target in job.map_eq_targets {
    map_eq_targets.push(rebase_family_call_target(target, expression_delta))
  }
  let diagnostics : Array[BodyInferenceDiagnostic] = []
  for diagnostic in job.diagnostics {
    diagnostics.push(
      rebase_family_diagnostic(
        diagnostic, expression_delta, pattern_delta, offset_delta,
      ),
    )
  }
  {
    ..job,
    call_expressions,
    call_targets,
    operator_targets,
    map_hash_targets,
    map_eq_targets,
    diagnostics,
  }
}

///|
fn body_inference_job_has_compatible_shape(
  job : BodyInferenceJobResult,
  expression_length : Int,
  local_length : Int,
  capture_length : Int,
  block_length : Int,
  pattern_length : Int,
  control_length : Int,
  object_field_length : Int,
) -> Bool {
  job.expression_types.length() == expression_length &&
  job.local_types.length() == local_length &&
  job.capture_types.length() == capture_length &&
  job.block_types.length() == block_length &&
  job.pattern_types.length() == pattern_length &&
  job.pattern_constructors.length() == pattern_length &&
  job.control_state_types.length() == control_length &&
  job.control_result_types.length() == control_length &&
  job.object_field_targets.length() == object_field_length &&
  job.operator_targets.length() == expression_length &&
  job.map_hash_targets.length() == expression_length &&
  job.map_eq_targets.length() == expression_length &&
  (
    job.expression_selections.length() == 0 ||
    job.expression_selections.length() == expression_length
  ) &&
  (
    job.trait_object_coercions.length() == 0 ||
    job.trait_object_coercions.length() == expression_length
  ) &&
  (
    job.expression_evidence.length() == 0 ||
    job.expression_evidence.length() == expression_length
  ) &&
  job.call_targets.length() == job.call_expressions.length()
}

///|
fn body_family_span_is_valid(span : HirSpan, length : Int) -> Bool {
  span.start >= 0 &&
  span.length >= 0 &&
  span.start <= length &&
  span.length <= length - span.start
}

///|
fn body_family_type_is_valid(type_ : BodyTypeId, length : Int) -> Bool {
  type_ <= 0 || type_ < length
}

///|
fn body_family_type_array_is_valid(
  types : Array[BodyTypeId],
  length : Int,
) -> Bool {
  for type_ in types {
    if !body_family_type_is_valid(type_, length) {
      return false
    }
  }
  true
}

///|
fn body_inference_job_type_graph_is_valid(job : BodyInferenceJobResult) -> Bool {
  if job.types.length() == 0 || !(job.types[0] is BodyErrorType) {
    return false
  }
  let type_length = job.types.length()
  for index in 1..<type_length {
    match job.types[index] {
      BodyVariableType(_) => ()
      BodyProductType(fields) => {
        if !body_family_span_is_valid(fields, job.type_arguments.length()) {
          return false
        }
        for field_index in fields.start..<(fields.start + fields.length) {
          if !body_family_type_is_valid(
              job.type_arguments[field_index],
              type_length,
            ) {
            return false
          }
        }
      }
      BodyAppliedType(base, arguments) => {
        if !body_family_type_is_valid(base, type_length) ||
          !body_family_span_is_valid(arguments, job.type_arguments.length()) {
          return false
        }
        for
          argument_index in arguments.start..<(arguments.start +
          arguments.length) {
          if !body_family_type_is_valid(
              job.type_arguments[argument_index],
              type_length,
            ) {
            return false
          }
        }
      }
      BodyFunctionType(parameters, result) => {
        if !body_family_type_is_valid(result, type_length) ||
          !body_family_span_is_valid(parameters, job.type_arguments.length()) {
          return false
        }
        for
          parameter_index in parameters.start..<(parameters.start +
          parameters.length) {
          if !body_family_type_is_valid(
              job.type_arguments[parameter_index],
              type_length,
            ) {
            return false
          }
        }
      }
      BodyErrorType | BodyResolvedType(_) => return false
    }
  }
  if !body_family_type_is_valid(job.result_type, type_length) ||
    !body_family_type_array_is_valid(job.expression_types, type_length) ||
    !body_family_type_array_is_valid(job.local_types, type_length) ||
    !body_family_type_array_is_valid(job.capture_types, type_length) ||
    !body_family_type_array_is_valid(job.block_types, type_length) ||
    !body_family_type_array_is_valid(job.pattern_types, type_length) ||
    !body_family_type_array_is_valid(job.pattern_type_arguments, type_length) ||
    !body_family_type_array_is_valid(job.control_state_types, type_length) ||
    !body_family_type_array_is_valid(job.control_result_types, type_length) ||
    !body_family_type_array_is_valid(job.expression_type_arguments, type_length) ||
    !body_family_type_array_is_valid(job.call_type_arguments, type_length) {
    return false
  }
  for selection in job.expression_selections {
    let span = match selection {
      StructConstructionSelection(_, arguments)
      | VariantConstructionSelection(_, arguments)
      | UnitVariantValueSelection(_, arguments)
      | FunctionReferenceSelection(_, arguments) => Some(arguments)
      _ => None
    }
    match span {
      Some(arguments) =>
        if !body_family_span_is_valid(
            arguments,
            job.expression_type_arguments.length(),
          ) {
          return false
        }
      None => ()
    }
  }
  for pattern_constructor in job.pattern_constructors {
    let span = match pattern_constructor {
      StructInferredPatternConstructor(_, arguments)
      | VariantInferredPatternConstructor(_, arguments) => Some(arguments)
      _ => None
    }
    match span {
      Some(arguments) =>
        if !body_family_span_is_valid(
            arguments,
            job.pattern_type_arguments.length(),
          ) {
          return false
        }
      None => ()
    }
  }
  for
    targets in [
      job.call_targets,
      job.operator_targets,
      job.map_hash_targets,
      job.map_eq_targets,
    ] {
    for target in targets {
      let span = match target {
        SelectedInferredCallTarget(_, arguments)
        | SelectedBoundInferredCallTarget(_, _, arguments)
        | SelectedDynamicTraitCallTarget(_, _, _, arguments) => Some(arguments)
        _ => None
      }
      match span {
        Some(arguments) =>
          if !body_family_span_is_valid(
              arguments,
              job.call_type_arguments.length(),
            ) {
            return false
          }
        None => ()
      }
    }
  }
  for root in job.trait_evidence_roots {
    if root < 0 || root >= job.trait_evidence.length() {
      return false
    }
  }
  for child in job.trait_evidence_children {
    if child < 0 || child >= job.trait_evidence.length() {
      return false
    }
  }
  for evidence in job.trait_evidence {
    if !body_family_span_is_valid(
        evidence.prerequisites,
        job.trait_evidence_children.length(),
      ) {
      return false
    }
    match evidence.kind {
      ConcreteInferredTraitEvidence(_, arguments) =>
        if !body_family_span_is_valid(
            arguments,
            job.trait_evidence_arguments.length(),
          ) {
          return false
        }
      BoundInferredTraitEvidence(_) => ()
    }
  }
  for coercion in job.trait_object_coercions {
    match coercion {
      SelectedInferredTraitObjectCoercion(_, evidence) if evidence < 0 ||
        evidence >= job.trait_evidence.length() => return false
      _ => ()
    }
  }
  for span in job.expression_evidence {
    if !body_family_span_is_valid(span, job.trait_evidence_roots.length()) {
      return false
    }
  }
  true
}

///|
fn body_inference_job_local_ids_are_valid(
  job : BodyInferenceJobResult,
  expression_length : Int,
) -> Bool {
  for expression in job.call_expressions {
    if expression < 0 || expression >= expression_length {
      return false
    }
  }
  for
    targets in [
      job.call_targets,
      job.operator_targets,
      job.map_hash_targets,
      job.map_eq_targets,
    ] {
    for target in targets {
      match target {
        SelectedFunctionValueCallTarget(expression) if expression < 0 ||
          expression >= expression_length => return false
        _ => ()
      }
    }
  }
  true
}

///|
fn validate_body_inference_family_artifact(
  collected : CollectedModule,
  names : ResolvedModuleNames,
  body_index : Int,
  artifact : BodyInferenceFamilyArtifact,
) -> Result[Unit, String] {
  if body_index < 0 || body_index >= collected.bodies.length() {
    return Err("body-family artifact index is out of range")
  }
  let body = collected.bodies[body_index]
  if body.kind == ModuleLetBody {
    return Err("module-value bodies cannot use body-family artifacts")
  }
  if artifact.module_id != collected.module_id ||
    artifact.body != body.id ||
    artifact.declaration != body.declaration {
    return Err("body-family artifact owner mismatch")
  }
  let body_names = names.body(body.id).unwrap()
  if !body_inference_job_has_compatible_shape(
      artifact.root,
      body.expressions.length,
      body_names.locals.length,
      0,
      body.blocks.length,
      body.patterns.length,
      body_names.controls.length,
      body.object_fields.length,
    ) ||
    !body_inference_job_type_graph_is_valid(artifact.root) ||
    !body_inference_job_local_ids_are_valid(
      artifact.root,
      body.expressions.length,
    ) {
    return Err("body-family artifact root arena mismatch")
  }
  let expected_lambdas : Array[HirLambda] = []
  for lambda in collected.lambdas {
    if lambda.root_body == body.id {
      expected_lambdas.push(lambda)
    }
  }
  if artifact.lambdas.length() != expected_lambdas.length() {
    return Err("body-family artifact lambda count mismatch")
  }
  for index, lambda_artifact in artifact.lambdas {
    let lambda = expected_lambdas[index]
    if lambda_artifact.lambda != lambda.id {
      return Err("body-family artifact lambda identity mismatch")
    }
    let lambda_names = names.lambda(lambda.id).unwrap()
    if !body_inference_job_has_compatible_shape(
        lambda_artifact.job,
        lambda.body.expressions.length,
        lambda_names.locals.length,
        lambda_names.captures.length,
        lambda.body.blocks.length,
        lambda.body.patterns.length,
        lambda_names.controls.length,
        lambda.body.object_fields.length,
      ) ||
      !body_inference_job_type_graph_is_valid(lambda_artifact.job) ||
      !body_inference_job_local_ids_are_valid(
        lambda_artifact.job,
        lambda.body.expressions.length,
      ) {
      return Err("body-family artifact lambda arena mismatch")
    }
  }
  Ok(())
}

///|
fn make_body_inference_family_artifact(
  collected : CollectedModule,
  body : HirBody,
  job : BodyInferenceJobResult,
  lambda_jobs : Array[BodyInferenceJobResult?],
) -> BodyInferenceFamilyArtifact {
  let declaration_offset = collected
    .declaration_location(body.declaration)
    .unwrap().offset
    .to_uint()
    .reinterpret_as_int()
  let lambdas : Array[BodyInferenceLambdaArtifact] = []
  for lambda in collected.lambdas {
    if lambda.root_body == body.id {
      lambdas.push({
        lambda: lambda.id,
        job: rebase_body_inference_job(
          lambda_jobs[lambda.id].unwrap(),
          -lambda.body.expressions.start,
          -lambda.body.patterns.start,
          -declaration_offset,
        ),
      })
    }
  }
  {
    module_id: collected.module_id,
    body: body.id,
    declaration: body.declaration,
    root: rebase_body_inference_job(
      job,
      -body.expressions.start,
      -body.patterns.start,
      -declaration_offset,
    ),
    lambdas,
  }
}

///|
fn restore_body_inference_family_artifact(
  collected : CollectedModule,
  artifact : BodyInferenceFamilyArtifact,
  jobs : Array[BodyInferenceJobResult?],
  lambda_jobs : Array[BodyInferenceJobResult?],
) -> Unit {
  let body = collected.bodies[semantic_id_local(artifact.body)]
  let declaration_offset = collected
    .declaration_location(body.declaration)
    .unwrap().offset
    .to_uint()
    .reinterpret_as_int()
  jobs[semantic_id_local(body.id)] = Some(
    rebase_body_inference_job(
      artifact.root,
      body.expressions.start,
      body.patterns.start,
      declaration_offset,
    ),
  )
  for lambda_artifact in artifact.lambdas {
    let lambda = collected.lambdas[lambda_artifact.lambda]
    lambda_jobs[lambda.id] = Some(
      rebase_body_inference_job(
        lambda_artifact.job,
        lambda.body.expressions.start,
        lambda.body.patterns.start,
        declaration_offset,
      ),
    )
  }
}
