///|
priv struct ProgramCallableEffectSummary {
  discardable : Bool
}

///|
fn program_effect_summary_block_is_discardable(
  module_ : PlannedModuleLowering,
  block : BlockId,
  summaries : Map[DeclId, ProgramCallableEffectSummary],
  depth : Int,
) -> Bool {
  if block < 0 ||
    block >= module_.blocks.length() ||
    depth > module_.expressions.length() + module_.blocks.length() {
    return false
  }
  let items = module_.blocks[block].items
  if items.start < 0 ||
    items.start + items.length > module_.block_items.length() {
    return false
  }
  for index in 0..<items.length {
    let expression = match module_.block_items[items.start + index].kind {
      PlannedLetItem(_, _, value) | PlannedExpressionItem(value) => value
      PlannedReturnItem(value) => if value < 0 { continue } else { value }
      PlannedElidedLetItem(_) => continue
    }
    if !program_effect_summary_expression_is_discardable(
        module_,
        expression,
        summaries,
        depth + 1,
      ) {
      return false
    }
  }
  true
}

///|
fn program_effect_summary_arguments_are_discardable(
  module_ : PlannedModuleLowering,
  arguments : HirSpan,
  summaries : Map[DeclId, ProgramCallableEffectSummary],
  depth : Int,
) -> Bool {
  if arguments.start < 0 ||
    arguments.start + arguments.length > module_.expression_children.length() {
    return false
  }
  for index in 0..<arguments.length {
    if !program_effect_summary_expression_is_discardable(
        module_,
        module_.expression_children[arguments.start + index],
        summaries,
        depth + 1,
      ) {
      return false
    }
  }
  true
}

///|
fn program_effect_summary_expression_is_discardable(
  module_ : PlannedModuleLowering,
  expression : ExprId,
  summaries : Map[DeclId, ProgramCallableEffectSummary],
  depth : Int,
) -> Bool {
  if expression < 0 ||
    expression >= module_.expressions.length() ||
    depth > module_.expressions.length() + module_.blocks.length() {
    return false
  }
  match module_.expressions[expression].kind {
    PlannedConsumedExpression
    | PlannedI8Const(_)
    | PlannedI16Const(_)
    | PlannedI32Const(_)
    | PlannedI64Const(_)
    | PlannedU8Const(_)
    | PlannedU16Const(_)
    | PlannedU32Const(_)
    | PlannedU64Const(_)
    | PlannedF32Const(_)
    | PlannedF64Const(_)
    | PlannedBoolConst(_)
    | PlannedStringConst(_)
    | PlannedBytesConst(_)
    | PlannedLocalGet(_)
    | PlannedCaptureGet(_) => true
    PlannedBlockExpression(block) =>
      program_effect_summary_block_is_discardable(
        module_,
        block,
        summaries,
        depth + 1,
      )
    PlannedIfExpression(condition, then_block, alternative) =>
      program_effect_summary_expression_is_discardable(
        module_,
        condition,
        summaries,
        depth + 1,
      ) &&
      program_effect_summary_block_is_discardable(
        module_,
        then_block,
        summaries,
        depth + 1,
      ) &&
      program_effect_summary_expression_is_discardable(
        module_,
        alternative,
        summaries,
        depth + 1,
      )
    PlannedMatchExpression(value, arms) => {
      if !program_effect_summary_expression_is_discardable(
          module_,
          value,
          summaries,
          depth + 1,
        ) ||
        arms.start < 0 ||
        arms.start + arms.length > module_.pattern_arms.length() {
        return false
      }
      for index in 0..<arms.length {
        let arm = module_.pattern_arms[arms.start + index]
        if (
            arm.guard_condition >= 0 &&
            !program_effect_summary_expression_is_discardable(
              module_,
              arm.guard_condition,
              summaries,
              depth + 1,
            )
          ) ||
          !program_effect_summary_expression_is_discardable(
            module_,
            arm.body,
            summaries,
            depth + 1,
          ) {
          return false
        }
      }
      true
    }
    PlannedDirectCall(target, receiver, arguments, _) => {
      match summaries.get(target) {
        Some({ discardable: true }) => ()
        _ => return false
      }
      (
        receiver < 0 ||
        program_effect_summary_expression_is_discardable(
          module_,
          receiver,
          summaries,
          depth + 1,
        )
      ) &&
      program_effect_summary_arguments_are_discardable(
        module_,
        arguments,
        summaries,
        depth + 1,
      )
    }
    PlannedParameterSelect(arguments, _) =>
      program_effect_summary_arguments_are_discardable(
        module_,
        arguments,
        summaries,
        depth + 1,
      )
    _ => false
  }
}

///|
fn program_callable_effect_summaries(
  modules : Array[PlannedModuleLowering],
) -> Map[DeclId, ProgramCallableEffectSummary] {
  let summaries : Map[DeclId, ProgramCallableEffectSummary] = Map::default()
  let mut changed = true
  while changed {
    changed = false
    for module_ in modules {
      for callable in module_.functions.callables {
        if summaries.contains(callable.declaration) {
          continue
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
        let discardable = match body.root {
          ExpressionBodyRoot(expression) =>
            program_effect_summary_expression_is_discardable(
              module_, expression, summaries, 0,
            )
          BlockBodyRoot(block) =>
            program_effect_summary_block_is_discardable(
              module_, block, summaries, 0,
            )
        }
        if discardable {
          summaries[callable.declaration] = { discardable: true }
          changed = true
        }
      }
    }
  }
  summaries
}

///|
fn transparent_callback_root_expression(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  summaries : Map[DeclId, ProgramCallableEffectSummary],
) -> ExprId {
  match body.root {
    ExpressionBodyRoot(expression) => expression
    BlockBodyRoot(block) => {
      if block < 0 || block >= module_.blocks.length() {
        return -1
      }
      let items = module_.blocks[block].items
      if items.length == 0 ||
        items.start < 0 ||
        items.start + items.length > module_.block_items.length() {
        return -1
      }
      let tail = match
        module_.block_items[items.start + items.length - 1].kind {
        PlannedExpressionItem(expression) | PlannedReturnItem(expression) =>
          expression
        _ => return -1
      }
      if tail < 0 {
        return -1
      }
      let mut candidate = tail
      let mut candidate_item = items.length - 1
      if items.length >= 2 {
        match module_.expressions[tail].kind {
          PlannedLocalGet(tail_local_id) =>
            match module_.block_items[items.start + items.length - 2].kind {
              PlannedLetItem(local_id, false, initializer) if local_id ==
                tail_local_id => {
                candidate = initializer
                candidate_item = items.length - 2
              }
              _ => ()
            }
          _ => ()
        }
      }
      for index in 0..<items.length {
        if index == candidate_item || index == items.length - 1 {
          continue
        }
        let expression = match module_.block_items[items.start + index].kind {
          PlannedLetItem(_, _, value) | PlannedExpressionItem(value) => value
          PlannedElidedLetItem(_) => continue
          PlannedReturnItem(_) => return -1
        }
        if !program_effect_summary_expression_is_discardable(
            module_, expression, summaries, 0,
          ) {
          return -1
        }
      }
      candidate
    }
  }
}

///|
priv struct TransparentCallbackCallSummary {
  parameter_count : Int
}

///|
fn transparent_callback_local_parameter(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  local_id : LocalId,
  depth : Int,
) -> Int {
  if local_id < 0 ||
    local_id >= body.locals.length ||
    depth > body.locals.length {
    return -1
  }
  match module_.locals[body.locals.start + local_id].kind {
    ParameterLocal => {
      let mut parameter = 0
      for index in 0..<local_id {
        match module_.locals[body.locals.start + index].kind {
          ParameterLocal => parameter += 1
          _ => return -1
        }
      }
      return parameter
    }
    _ => ()
  }
  if module_.locals[body.locals.start + local_id].mutable_ {
    return -1
  }
  let mut initializer = -1
  for
    block_index in body.blocks.start..<(body.blocks.start + body.blocks.length) {
    if block_index < 0 || block_index >= module_.blocks.length() {
      return -1
    }
    let items = module_.blocks[block_index].items
    if items.start < 0 ||
      items.start + items.length > module_.block_items.length() {
      return -1
    }
    for index in 0..<items.length {
      match module_.block_items[items.start + index].kind {
        PlannedLetItem(candidate, false, value) if candidate == local_id => {
          if initializer >= 0 {
            return -1
          }
          initializer = value
        }
        _ => ()
      }
    }
  }
  if initializer < 0 || initializer >= module_.expressions.length() {
    return -1
  }
  match module_.expressions[initializer].kind {
    PlannedLocalGet(source) =>
      transparent_callback_local_parameter(module_, body, source, depth + 1)
    _ => -1
  }
}

///|
fn transparent_callback_expression_parameter(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  expression : ExprId,
) -> Int {
  if expression < 0 || expression >= module_.expressions.length() {
    return -1
  }
  match module_.expressions[expression].kind {
    PlannedLocalGet(local_id) =>
      transparent_callback_local_parameter(module_, body, local_id, 0)
    _ => -1
  }
}

///|
fn transparent_callback_arguments_match_parameters(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  arguments : HirSpan,
  first_parameter : Int,
) -> Bool {
  if arguments.start < 0 ||
    arguments.start + arguments.length > module_.expression_children.length() {
    return false
  }
  for index in 0..<arguments.length {
    if transparent_callback_expression_parameter(
        module_,
        body,
        module_.expression_children[arguments.start + index],
      ) !=
      first_parameter + index {
      return false
    }
  }
  true
}

///|
fn transparent_callback_call_summary(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  effects : Map[DeclId, ProgramCallableEffectSummary],
  summaries : Map[DeclId, TransparentCallbackCallSummary],
) -> TransparentCallbackCallSummary? {
  let mut parameter_count = 0
  for local_id in 0..<body.locals.length {
    match module_.locals[body.locals.start + local_id].kind {
      ParameterLocal => parameter_count += 1
      _ => break
    }
  }
  if parameter_count <= 0 {
    return None
  }
  let root_expression = transparent_callback_root_expression(
    module_, body, effects,
  )
  if root_expression < 0 {
    return None
  }
  match module_.expressions[root_expression].kind {
    PlannedFunctionValueCall(target, arguments, _) =>
      if transparent_callback_expression_parameter(module_, body, target) != 0 ||
        arguments.length != parameter_count - 1 ||
        !transparent_callback_arguments_match_parameters(
          module_, body, arguments, 1,
        ) {
        return None
      }
    PlannedDirectCall(target, receiver, arguments, _) if receiver < 0 => {
      let target_summary = match summaries.get(target) {
        Some(value) => value
        None => return None
      }
      if target_summary.parameter_count != parameter_count ||
        arguments.length != parameter_count ||
        !transparent_callback_arguments_match_parameters(
          module_, body, arguments, 0,
        ) {
        return None
      }
    }
    _ => return None
  }
  Some({ parameter_count, })
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
  effects : Map[DeclId, ProgramCallableEffectSummary],
) -> Unit {
  let summaries : Map[DeclId, TransparentCallbackCallSummary] = Map::default()
  let mut changed = true
  while changed {
    changed = false
    for module_ in modules {
      for body in module_.bodies {
        if summaries.contains(body.declaration) {
          continue
        }
        match
          transparent_callback_call_summary(module_, body, effects, summaries) {
          Some(summary) => {
            summaries[body.declaration] = summary
            changed = true
          }
          None => ()
        }
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
        Some(summary) => summary.parameter_count
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
  effects : Map[DeclId, ProgramCallableEffectSummary],
) -> Bool {
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if expression == root {
      match module_.expressions[expression].kind {
        PlannedDirectCall(_, _, _, _)
        | PlannedDynamicTraitCall(_, _, _, _, _, _) => continue
        _ => return false
      }
    }
    if !program_effect_summary_expression_is_discardable(
        module_, expression, effects, 0,
      ) {
      return false
    }
  }
  true
}

///|
fn transparent_trait_call_summaries(
  modules : Array[PlannedModuleLowering],
  analyses : Map[BodyId, RuntimeTraitBodyAnalysis],
  effects : Map[DeclId, ProgramCallableEffectSummary],
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
        if !runtime_trait_summary_body_is_transparent(
            module_, body, expression, effects,
          ) {
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
  effects : Map[DeclId, ProgramCallableEffectSummary],
) -> Int {
  let root_expression = transparent_callback_root_expression(
    module_, body, effects,
  )
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
  effects : Map[DeclId, ProgramCallableEffectSummary],
) -> Array[DeclId] {
  let selectors : Map[DeclId, Int] = Map::default()
  for module_ in modules {
    for body in module_.bodies {
      let selected = trait_parameter_selector(module_, body, effects)
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
priv enum ProgramFoldConstant {
  ProgramFoldBool(Bool)
  ProgramFoldI32(UInt64)
  ProgramFoldU32(UInt64)
  ProgramFoldI64(UInt64)
  ProgramFoldU64(UInt64)
}

///|
fn program_fold_constant(
  module_ : PlannedModuleLowering,
  expression : ExprId,
) -> ProgramFoldConstant? {
  if expression < 0 || expression >= module_.expressions.length() {
    return None
  }
  match module_.expressions[expression].kind {
    PlannedBoolConst(value) => Some(ProgramFoldBool(value))
    PlannedI32Const(value) => Some(ProgramFoldI32(value & 0xFFFFFFFFUL))
    PlannedU32Const(value) => Some(ProgramFoldU32(value & 0xFFFFFFFFUL))
    PlannedI64Const(value) => Some(ProgramFoldI64(value))
    PlannedU64Const(value) => Some(ProgramFoldU64(value))
    _ => None
  }
}

///|
fn program_fold_kind(constant : ProgramFoldConstant) -> PlannedExpressionKind {
  match constant {
    ProgramFoldBool(value) => PlannedBoolConst(value)
    ProgramFoldI32(value) => PlannedI32Const(value & 0xFFFFFFFFUL)
    ProgramFoldU32(value) => PlannedU32Const(value & 0xFFFFFFFFUL)
    ProgramFoldI64(value) => PlannedI64Const(value)
    ProgramFoldU64(value) => PlannedU64Const(value)
  }
}

///|
fn program_fold_prefix(
  operator : HirPrefixOperator,
  value : ProgramFoldConstant,
) -> ProgramFoldConstant? {
  match (operator, value) {
    (HirPositive, constant) => Some(constant)
    (HirLogicalNot, ProgramFoldBool(value)) => Some(ProgramFoldBool(!value))
    (HirNegative, ProgramFoldI32(value)) =>
      Some(ProgramFoldI32((0UL - value) & 0xFFFFFFFFUL))
    (HirNegative, ProgramFoldI64(value)) => Some(ProgramFoldI64(0UL - value))
    _ => None
  }
}

///|
fn program_fold_bool_binary(
  operator : HirBinaryOperator,
  left : Bool,
  right : Bool,
) -> ProgramFoldConstant? {
  match operator {
    HirLogicalOr => Some(ProgramFoldBool(left || right))
    HirLogicalAnd => Some(ProgramFoldBool(left && right))
    HirEqual => Some(ProgramFoldBool(left == right))
    HirNotEqual => Some(ProgramFoldBool(left != right))
    _ => None
  }
}

///|
fn program_fold_i32_binary(
  operator : HirBinaryOperator,
  left : UInt64,
  right : UInt64,
) -> ProgramFoldConstant? {
  let left_bits = left & 0xFFFFFFFFUL
  let right_bits = right & 0xFFFFFFFFUL
  match operator {
    HirBitOr => Some(ProgramFoldI32(left_bits | right_bits))
    HirBitXor => Some(ProgramFoldI32(left_bits ^ right_bits))
    HirBitAnd => Some(ProgramFoldI32(left_bits & right_bits))
    HirAdd => Some(ProgramFoldI32((left_bits + right_bits) & 0xFFFFFFFFUL))
    HirSubtract => Some(ProgramFoldI32((left_bits - right_bits) & 0xFFFFFFFFUL))
    HirMultiply => Some(ProgramFoldI32((left_bits * right_bits) & 0xFFFFFFFFUL))
    HirEqual => Some(ProgramFoldBool(left_bits == right_bits))
    HirNotEqual => Some(ProgramFoldBool(left_bits != right_bits))
    HirLess => Some(ProgramFoldBool(left_bits.to_int() < right_bits.to_int()))
    HirLessEqual =>
      Some(ProgramFoldBool(left_bits.to_int() <= right_bits.to_int()))
    HirGreater =>
      Some(ProgramFoldBool(left_bits.to_int() > right_bits.to_int()))
    HirGreaterEqual =>
      Some(ProgramFoldBool(left_bits.to_int() >= right_bits.to_int()))
    _ => None
  }
}

///|
fn program_fold_u32_binary(
  operator : HirBinaryOperator,
  left : UInt64,
  right : UInt64,
) -> ProgramFoldConstant? {
  let left_bits = left & 0xFFFFFFFFUL
  let right_bits = right & 0xFFFFFFFFUL
  match operator {
    HirBitOr => Some(ProgramFoldU32(left_bits | right_bits))
    HirBitXor => Some(ProgramFoldU32(left_bits ^ right_bits))
    HirBitAnd => Some(ProgramFoldU32(left_bits & right_bits))
    HirAdd => Some(ProgramFoldU32((left_bits + right_bits) & 0xFFFFFFFFUL))
    HirSubtract => Some(ProgramFoldU32((left_bits - right_bits) & 0xFFFFFFFFUL))
    HirMultiply => Some(ProgramFoldU32((left_bits * right_bits) & 0xFFFFFFFFUL))
    HirEqual => Some(ProgramFoldBool(left_bits == right_bits))
    HirNotEqual => Some(ProgramFoldBool(left_bits != right_bits))
    HirLess => Some(ProgramFoldBool(left_bits < right_bits))
    HirLessEqual => Some(ProgramFoldBool(left_bits <= right_bits))
    HirGreater => Some(ProgramFoldBool(left_bits > right_bits))
    HirGreaterEqual => Some(ProgramFoldBool(left_bits >= right_bits))
    _ => None
  }
}

///|
fn program_fold_i64_binary(
  operator : HirBinaryOperator,
  left : UInt64,
  right : UInt64,
) -> ProgramFoldConstant? {
  match operator {
    HirBitOr => Some(ProgramFoldI64(left | right))
    HirBitXor => Some(ProgramFoldI64(left ^ right))
    HirBitAnd => Some(ProgramFoldI64(left & right))
    HirAdd => Some(ProgramFoldI64(left + right))
    HirSubtract => Some(ProgramFoldI64(left - right))
    HirMultiply => Some(ProgramFoldI64(left * right))
    HirEqual => Some(ProgramFoldBool(left == right))
    HirNotEqual => Some(ProgramFoldBool(left != right))
    HirLess =>
      Some(
        ProgramFoldBool(
          left.reinterpret_as_int64() < right.reinterpret_as_int64(),
        ),
      )
    HirLessEqual =>
      Some(
        ProgramFoldBool(
          left.reinterpret_as_int64() <= right.reinterpret_as_int64(),
        ),
      )
    HirGreater =>
      Some(
        ProgramFoldBool(
          left.reinterpret_as_int64() > right.reinterpret_as_int64(),
        ),
      )
    HirGreaterEqual =>
      Some(
        ProgramFoldBool(
          left.reinterpret_as_int64() >= right.reinterpret_as_int64(),
        ),
      )
    _ => None
  }
}

///|
fn program_fold_u64_binary(
  operator : HirBinaryOperator,
  left : UInt64,
  right : UInt64,
) -> ProgramFoldConstant? {
  match operator {
    HirBitOr => Some(ProgramFoldU64(left | right))
    HirBitXor => Some(ProgramFoldU64(left ^ right))
    HirBitAnd => Some(ProgramFoldU64(left & right))
    HirAdd => Some(ProgramFoldU64(left + right))
    HirSubtract => Some(ProgramFoldU64(left - right))
    HirMultiply => Some(ProgramFoldU64(left * right))
    HirEqual => Some(ProgramFoldBool(left == right))
    HirNotEqual => Some(ProgramFoldBool(left != right))
    HirLess => Some(ProgramFoldBool(left < right))
    HirLessEqual => Some(ProgramFoldBool(left <= right))
    HirGreater => Some(ProgramFoldBool(left > right))
    HirGreaterEqual => Some(ProgramFoldBool(left >= right))
    _ => None
  }
}

///|
fn program_fold_binary(
  operator : HirBinaryOperator,
  left : ProgramFoldConstant,
  right : ProgramFoldConstant,
) -> ProgramFoldConstant? {
  match (left, right) {
    (ProgramFoldBool(left), ProgramFoldBool(right)) =>
      program_fold_bool_binary(operator, left, right)
    (ProgramFoldI32(left), ProgramFoldI32(right)) =>
      program_fold_i32_binary(operator, left, right)
    (ProgramFoldU32(left), ProgramFoldU32(right)) =>
      program_fold_u32_binary(operator, left, right)
    (ProgramFoldI64(left), ProgramFoldI64(right)) =>
      program_fold_i64_binary(operator, left, right)
    (ProgramFoldU64(left), ProgramFoldU64(right)) =>
      program_fold_u64_binary(operator, left, right)
    _ => None
  }
}

///|
fn fold_program_constants(modules : Array[PlannedModuleLowering]) -> Unit {
  for module_ in modules {
    let mut changed = true
    let mut remaining = module_.expressions.length() + 1
    while changed && remaining > 0 {
      remaining -= 1
      changed = false
      for expression in 0..<module_.expressions.length() {
        let folded = match module_.expressions[expression].kind {
          PlannedPrefixExpression(operator, value) =>
            match program_fold_constant(module_, value) {
              Some(constant) => program_fold_prefix(operator, constant)
              None => None
            }
          PlannedBinaryExpression(operator, left, right)
          | PlannedOperatorCall(_, operator, left, right, _) =>
            match
              (
                program_fold_constant(module_, left),
                program_fold_constant(module_, right),
              ) {
              (Some(left), Some(right)) =>
                program_fold_binary(operator, left, right)
              _ => None
            }
          _ => None
        }
        match folded {
          Some(constant) => {
            let source = module_.expressions[expression]
            let kind = program_fold_kind(constant)
            if source.kind != kind {
              module_.expressions[expression] = { ..source, kind, }
              changed = true
            }
          }
          None => ()
        }
      }
    }
  }
}

///|
fn prepare_program_optimization_mutation(
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
      expressions: module_.expressions.copy(),
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
  module_lookup : Map[ModuleId, Int],
  effects : Map[DeclId, ProgramCallableEffectSummary],
) -> Array[DeclId] {
  let selectors = directize_trait_parameter_selectors(modules, effects)
  let analyses = runtime_trait_body_analyses(modules)
  let summaries = transparent_trait_call_summaries(modules, analyses, effects)
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
/// Applies backend-neutral whole-program rewrites to a copied lowering plan.
/// The input lowering and its mutable arenas remain unchanged.
pub fn optimize_program_lowering(
  lowering : PlannedProgramLowering,
) -> PlannedProgramLowering {
  let modules = lowering.modules.copy()
  prepare_program_optimization_mutation(modules)
  fold_program_constants(modules)
  let effects = program_callable_effect_summaries(modules)
  directize_transparent_callback_calls(modules, effects)
  directize_generic_parameter_selectors(modules)
  let elided_trait_wrappers = directize_exact_runtime_trait_flows(
    modules,
    lowering.index.module_lookup,
    effects,
  )
  {
    graph: lowering.graph,
    modules,
    index: lowering.index,
    elided_trait_wrappers,
  }
}
