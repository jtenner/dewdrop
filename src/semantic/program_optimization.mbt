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
  let mut candidate = expression
  let mut remaining = module_.expressions.length() + 1
  while remaining > 0 {
    remaining -= 1
    if candidate < 0 || candidate >= module_.expressions.length() {
      return -1
    }
    match module_.expressions[candidate].kind {
      PlannedLocalGet(local_id) =>
        return transparent_callback_local_parameter(module_, body, local_id, 0)
      PlannedParameterSelect(arguments, selected) if selected >= 0 &&
        selected < arguments.length =>
        candidate = module_.expression_children[arguments.start + selected]
      _ => return -1
    }
  }
  -1
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
priv enum ProgramInlineSummary {
  ProgramInlineParameter(Int, Int)
  ProgramInlineConstant(PlannedExpressionKind)
}

///|
fn program_inline_scalar_shape(shape : PlannedValueShape) -> Bool {
  match shape {
    I32PlannedValueShape
    | U32PlannedValueShape
    | I64PlannedValueShape
    | U64PlannedValueShape => true
    _ => false
  }
}

///|
fn program_inline_scalar_constant(
  kind : PlannedExpressionKind,
) -> PlannedExpressionKind? {
  match kind {
    PlannedI32Const(_)
    | PlannedU32Const(_)
    | PlannedI64Const(_)
    | PlannedU64Const(_)
    | PlannedBoolConst(_) => Some(kind)
    _ => None
  }
}

///|
fn program_inline_summary(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  effects : Map[DeclId, ProgramCallableEffectSummary],
) -> ProgramInlineSummary? {
  let callable = match module_.functions.callable_of(body.declaration) {
    Some(value) if !value.has_receiver &&
      program_callable_generic_parameters(value).length == 0 => value
    _ => return None
  }
  let root = transparent_callback_root_expression(module_, body, effects)
  if root < 0 || root >= module_.expressions.length() {
    return None
  }
  let mut parameter_count = 0
  for local_id in 0..<body.locals.length {
    match module_.locals[body.locals.start + local_id].kind {
      ParameterLocal => parameter_count += 1
      _ => break
    }
  }
  let selected = transparent_callback_expression_parameter(module_, body, root)
  if selected >= 0 &&
    program_inline_scalar_shape(module_.expressions[root].shape) {
    return Some(ProgramInlineParameter(selected, parameter_count))
  }
  if parameter_count == 0 {
    match program_inline_scalar_constant(module_.expressions[root].kind) {
      Some(kind) => return Some(ProgramInlineConstant(kind))
      None => ()
    }
  }
  ignore(callable)
  None
}

///|
fn inline_program_calls_from_summaries(
  modules : Array[PlannedModuleLowering],
  effects : Map[DeclId, ProgramCallableEffectSummary],
) -> Unit {
  let summaries : Map[DeclId, ProgramInlineSummary] = Map::default()
  let mut changed = true
  let mut remaining = 1
  for module_ in modules {
    remaining += module_.expressions.length() + module_.bodies.length()
  }
  while changed && remaining > 0 {
    remaining -= 1
    changed = false
    for module_ in modules {
      for body in module_.bodies {
        if summaries.contains(body.declaration) {
          continue
        }
        match program_inline_summary(module_, body, effects) {
          Some(summary) => {
            summaries[body.declaration] = summary
            changed = true
          }
          None => ()
        }
      }
    }
    for module_ in modules {
      for expression in 0..<module_.expressions.length() {
        let (declaration, arguments) = match
          module_.expressions[expression].kind {
          PlannedDirectCall(declaration, receiver, arguments, type_arguments) => {
            if receiver >= 0 || type_arguments.length != 0 {
              continue
            }
            (declaration, arguments)
          }
          _ => continue
        }
        let summary = match summaries.get(declaration) {
          Some(value) => value
          None => continue
        }
        let source = module_.expressions[expression]
        match summary {
          ProgramInlineParameter(selected, parameter_count) => {
            if parameter_count != arguments.length ||
              selected < 0 ||
              selected >= arguments.length ||
              arguments.start < 0 ||
              arguments.start + selected >= module_.expression_children.length() {
              continue
            }
            let selected_expression = module_.expression_children[arguments.start +
              selected]
            if selected_expression < 0 ||
              selected_expression >= module_.expressions.length() {
              continue
            }
            let selected_source = module_.expressions[selected_expression]
            module_.expressions[expression] = {
              ..source,
              type_: selected_source.type_,
              shape: selected_source.shape,
              trait_object_coercion: selected_source.trait_object_coercion,
              kind: PlannedParameterSelect(arguments, selected),
            }
            changed = true
          }
          ProgramInlineConstant(kind) => {
            if arguments.length != 0 {
              continue
            }
            module_.expressions[expression] = { ..source, kind, }
            changed = true
          }
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
      bodies: module_.bodies.copy(),
      locals: module_.locals.copy(),
      blocks: module_.blocks.copy(),
      expressions: module_.expressions.copy(),
      block_items: module_.block_items.copy(),
      expression_children: module_.expression_children.copy(),
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
fn program_cse_scalar_shape(shape : PlannedValueShape) -> Bool {
  match shape {
    ErrorPlannedValueShape
    | UnitPlannedValueShape
    | RefPlannedValueShape
    | GenericPlannedValueShape
    | NeverPlannedValueShape => false
    _ => true
  }
}

///|
fn program_cse_field_key(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  expression : ExprId,
) -> (FieldId, LocalId)? {
  if expression < 0 || expression >= module_.expressions.length() {
    return None
  }
  let source = module_.expressions[expression]
  if !program_cse_scalar_shape(source.shape) ||
    !(source.trait_object_coercion is NoInferredTraitObjectCoercion) {
    return None
  }
  let (field, base) = match source.kind {
    PlannedFieldGet(field, base) => (field, base)
    _ => return None
  }
  if base < 0 || base >= module_.expressions.length() {
    return None
  }
  let local_id = match module_.expressions[base].kind {
    PlannedLocalGet(local_id) => local_id
    _ => return None
  }
  if local_id < 0 || local_id >= body.locals.length {
    return None
  }
  let planned_local = module_.locals[body.locals.start + local_id]
  if planned_local.mutable_ {
    return None
  }
  Some((field, local_id))
}

///|
fn program_cse_cached_field_local(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  expression : ExprId,
  available : Map[(FieldId, LocalId), LocalId],
) -> LocalId {
  let key = match program_cse_field_key(module_, body, expression) {
    Some(value) => value
    None => return -1
  }
  let local_id = match available.get(key) {
    Some(value) => value
    None => return -1
  }
  if local_id < 0 || local_id >= body.locals.length {
    return -1
  }
  let source = module_.expressions[expression]
  let cached = module_.locals[body.locals.start + local_id]
  if source.type_ != cached.type_ || source.shape != cached.shape {
    return -1
  }
  local_id
}

///|
fn program_cse_rewrite_field_from_local(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  expression : ExprId,
  available : Map[(FieldId, LocalId), LocalId],
) -> Bool {
  let local_id = program_cse_cached_field_local(
    module_, body, expression, available,
  )
  if local_id < 0 {
    return false
  }
  let source = module_.expressions[expression]
  module_.expressions[expression] = {
    ..source,
    kind: PlannedLocalGet(local_id),
  }
  true
}

///|
fn program_cse_local_is_captured(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  local_id : LocalId,
) -> Bool {
  for capture in module_.captures {
    match capture.source {
      BodyLocalCapture(source_body, source_local) if source_body == body.body &&
        source_local == local_id => return true
      _ => ()
    }
  }
  false
}

///|
fn program_cse_elide_local_alias(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  local_id : LocalId,
  cached_local : LocalId,
) -> Bool {
  if local_id < 0 ||
    local_id >= body.locals.length ||
    cached_local < 0 ||
    cached_local >= body.locals.length ||
    module_.locals[body.locals.start + local_id].mutable_ ||
    program_cse_local_is_captured(module_, body, local_id) {
    return false
  }
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    let source = module_.expressions[expression]
    match source.kind {
      PlannedLocalGet(source_local) if source_local == local_id =>
        module_.expressions[expression] = {
          ..source,
          kind: PlannedLocalGet(cached_local),
        }
      _ => ()
    }
  }
  true
}

///|
fn cse_program_field_extractions(
  modules : Array[PlannedModuleLowering],
) -> Unit {
  for module_ in modules {
    for body in module_.bodies {
      for
        block in body.blocks.start..<(body.blocks.start + body.blocks.length) {
        if block < 0 || block >= module_.blocks.length() {
          continue
        }
        let items = module_.blocks[block].items
        if items.start < 0 ||
          items.start + items.length > module_.block_items.length() {
          continue
        }
        let available : Map[(FieldId, LocalId), LocalId] = Map::default()
        for index in 0..<items.length {
          match module_.block_items[items.start + index].kind {
            PlannedLetItem(local_id, mutable_, value) => {
              let cached_local = program_cse_cached_field_local(
                module_, body, value, available,
              )
              if cached_local >= 0 {
                if !mutable_ &&
                  program_cse_elide_local_alias(
                    module_, body, local_id, cached_local,
                  ) {
                  module_.block_items[items.start + index] = {
                    ..module_.block_items[items.start + index],
                    kind: PlannedElidedLetItem(local_id),
                  }
                  let source = module_.expressions[value]
                  module_.expressions[value] = {
                    ..source,
                    kind: PlannedConsumedExpression,
                  }
                } else {
                  let source = module_.expressions[value]
                  module_.expressions[value] = {
                    ..source,
                    kind: PlannedLocalGet(cached_local),
                  }
                }
                continue
              }
              if mutable_ {
                continue
              }
              match program_cse_field_key(module_, body, value) {
                Some(key) => available[key] = local_id
                None => ()
              }
            }
            PlannedReturnItem(value) | PlannedExpressionItem(value) =>
              if value >= 0 {
                ignore(
                  program_cse_rewrite_field_from_local(
                    module_,
                    body,
                    value,
                    available,
                  ),
                )
              }
            PlannedElidedLetItem(_) => ()
          }
        }
      }
    }
  }
}

///|
fn program_scalar_replaceable_field_shape(
  shape : PlannedValueShape,
) -> Bool {
  match shape {
    I32PlannedValueShape
    | U32PlannedValueShape
    | I64PlannedValueShape
    | U64PlannedValueShape
    | F32PlannedValueShape
    | F64PlannedValueShape
    | Swar32PlannedValueShape
    | Swar64PlannedValueShape
    | V128PlannedValueShape => true
    _ => false
  }
}

///|
fn scalar_replace_program_struct_field_read(
  module_ : PlannedModuleLowering,
  expression : ExprId,
  struct_expression : ExprId,
) -> Bool {
  if expression < 0 ||
    expression >= module_.expressions.length() ||
    struct_expression < 0 ||
    struct_expression >= module_.expressions.length() {
    return false
  }
  let source = module_.expressions[expression]
  let field = match source.kind {
    PlannedFieldGet(field, _) => field
    _ => return false
  }
  if !(module_.expressions[struct_expression].trait_object_coercion is NoInferredTraitObjectCoercion) {
    return false
  }
  let fields = match module_.expressions[struct_expression].kind {
    PlannedStructNew(_, _, fields) => fields
    _ => return false
  }
  if fields.start < 0 ||
    fields.start + fields.length > module_.object_fields.length() ||
    (!program_scalar_replaceable_field_shape(source.shape) &&
    !(fields.length == 1 &&
    ((source.shape is RefPlannedValueShape) ||
    (source.shape is GenericPlannedValueShape)))) {
    return false
  }
  let start = module_.expression_children.length()
  let mut selected = -1
  for index in 0..<fields.length {
    let object_field = module_.object_fields[fields.start + index]
    module_.expression_children.push(object_field.value)
    if object_field.field == field {
      if selected >= 0 {
        selected = -2
      } else {
        selected = index
      }
    }
  }
  if selected < 0 {
    while module_.expression_children.length() > start {
      ignore(module_.expression_children.pop())
    }
    return false
  }
  module_.expressions[expression] = {
    ..source,
    kind: PlannedParameterSelect(
      { start, length: fields.length },
      selected,
    ),
  }
  let struct_source = module_.expressions[struct_expression]
  module_.expressions[struct_expression] = {
    ..struct_source,
    kind: PlannedConsumedExpression,
  }
  true
}

///|
fn program_local_get_count(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  local_id : LocalId,
) -> (Int, ExprId) {
  let mut count = 0
  let mut selected = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match module_.expressions[expression].kind {
      PlannedLocalGet(source_local) if source_local == local_id => {
        count += 1
        selected = expression
      }
      _ => ()
    }
  }
  (count, selected)
}

///|
fn program_scalar_replacement_block_tail(
  module_ : PlannedModuleLowering,
  block : BlockId,
) -> ExprId {
  if block < 0 || block >= module_.blocks.length() {
    return -1
  }
  let items = module_.blocks[block].items
  if items.length == 0 ||
    items.start < 0 ||
    items.start + items.length > module_.block_items.length() {
    return -1
  }
  match module_.block_items[items.start + items.length - 1].kind {
    PlannedExpressionItem(expression) => expression
    _ => -1
  }
}

///|
fn program_can_scalarize_joined_struct_field(
  module_ : PlannedModuleLowering,
  expression : ExprId,
  field : FieldId,
  type_ : BodyTypeId,
  shape : PlannedValueShape,
  depth : Int,
) -> Bool {
  if expression < 0 ||
    expression >= module_.expressions.length() ||
    depth > module_.expressions.length() + module_.blocks.length() ||
    !(module_.expressions[expression].trait_object_coercion is NoInferredTraitObjectCoercion) {
    return false
  }
  match module_.expressions[expression].kind {
    PlannedStructNew(_, _, fields) => {
      if fields.start < 0 ||
        fields.start + fields.length > module_.object_fields.length() {
        return false
      }
      let mut selected = -1
      for index in 0..<fields.length {
        let object_field = module_.object_fields[fields.start + index]
        if object_field.field == field {
          if selected >= 0 {
            return false
          }
          selected = object_field.value
        }
      }
      selected >= 0 &&
      selected < module_.expressions.length() &&
      module_.expressions[selected].type_ == type_ &&
      module_.expressions[selected].shape == shape
    }
    PlannedBlockExpression(block) => {
      let tail = program_scalar_replacement_block_tail(module_, block)
      program_can_scalarize_joined_struct_field(
        module_, tail, field, type_, shape, depth + 1,
      )
    }
    PlannedIfExpression(_, then_block, alternative) => {
      let then_tail = program_scalar_replacement_block_tail(
        module_, then_block,
      )
      program_can_scalarize_joined_struct_field(
        module_, then_tail, field, type_, shape, depth + 1,
      ) &&
      program_can_scalarize_joined_struct_field(
        module_, alternative, field, type_, shape, depth + 1,
      )
    }
    PlannedMatchExpression(_, arms) => {
      if arms.length == 0 ||
        arms.start < 0 ||
        arms.start + arms.length > module_.pattern_arms.length() {
        return false
      }
      for index in 0..<arms.length {
        if !program_can_scalarize_joined_struct_field(
            module_,
            module_.pattern_arms[arms.start + index].body,
            field,
            type_,
            shape,
            depth + 1,
          ) {
          return false
        }
      }
      true
    }
    _ => false
  }
}

///|
fn scalarize_joined_struct_field(
  module_ : PlannedModuleLowering,
  expression : ExprId,
  field : FieldId,
  type_ : BodyTypeId,
  shape : PlannedValueShape,
  depth : Int,
) -> Bool {
  if expression < 0 ||
    expression >= module_.expressions.length() ||
    depth > module_.expressions.length() + module_.blocks.length() {
    return false
  }
  let source = module_.expressions[expression]
  match source.kind {
    PlannedStructNew(_, _, fields) => {
      let start = module_.expression_children.length()
      let mut selected = -1
      for index in 0..<fields.length {
        let object_field = module_.object_fields[fields.start + index]
        module_.expression_children.push(object_field.value)
        if object_field.field == field {
          selected = index
        }
      }
      if selected < 0 {
        return false
      }
      module_.expressions[expression] = {
        ..source,
        type_,
        shape,
        trait_object_coercion: NoInferredTraitObjectCoercion,
        kind: PlannedParameterSelect(
          { start, length: fields.length },
          selected,
        ),
      }
      true
    }
    PlannedBlockExpression(block) => {
      let tail = program_scalar_replacement_block_tail(module_, block)
      if !scalarize_joined_struct_field(
          module_, tail, field, type_, shape, depth + 1,
        ) {
        return false
      }
      module_.expressions[expression] = {
        ..source,
        type_,
        shape,
        trait_object_coercion: NoInferredTraitObjectCoercion,
      }
      true
    }
    PlannedIfExpression(condition, then_block, alternative) => {
      let then_tail = program_scalar_replacement_block_tail(
        module_, then_block,
      )
      if !scalarize_joined_struct_field(
          module_, then_tail, field, type_, shape, depth + 1,
        ) ||
        !scalarize_joined_struct_field(
          module_, alternative, field, type_, shape, depth + 1,
        ) {
        return false
      }
      module_.expressions[expression] = {
        ..source,
        type_,
        shape,
        trait_object_coercion: NoInferredTraitObjectCoercion,
        kind: PlannedIfExpression(condition, then_block, alternative),
      }
      true
    }
    PlannedMatchExpression(scrutinee, arms) => {
      for index in 0..<arms.length {
        if !scalarize_joined_struct_field(
            module_,
            module_.pattern_arms[arms.start + index].body,
            field,
            type_,
            shape,
            depth + 1,
          ) {
          return false
        }
      }
      module_.expressions[expression] = {
        ..source,
        type_,
        shape,
        trait_object_coercion: NoInferredTraitObjectCoercion,
        kind: PlannedMatchExpression(scrutinee, arms),
      }
      true
    }
    _ => false
  }
}

///|
fn scalar_replace_joined_struct_field_local(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  local_id : LocalId,
  initializer : ExprId,
) -> Bool {
  if initializer < 0 ||
    initializer >= module_.expressions.length() ||
    (!(module_.expressions[initializer].kind is PlannedIfExpression(_, _, _)) &&
    !(module_.expressions[initializer].kind is PlannedMatchExpression(_, _))) {
    return false
  }
  let (use_count, only_use) = program_local_get_count(
    module_, body, local_id,
  )
  if use_count != 1 || only_use < 0 {
    return false
  }
  let mut field_expression = -1
  let mut field : FieldId? = None
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match module_.expressions[expression].kind {
      PlannedFieldGet(candidate, base) if base == only_use => {
        if field_expression >= 0 {
          return false
        }
        field_expression = expression
        field = Some(candidate)
      }
      _ => ()
    }
  }
  if field_expression < 0 ||
    !program_scalar_replaceable_field_shape(
      module_.expressions[field_expression].shape,
    ) ||
    !(module_.expressions[field_expression].trait_object_coercion is NoInferredTraitObjectCoercion) {
    return false
  }
  let field = match field {
    Some(field) => field
    None => return false
  }
  let field_source = module_.expressions[field_expression]
  if !program_can_scalarize_joined_struct_field(
      module_, initializer, field, field_source.type_, field_source.shape, 0,
    ) ||
    !scalarize_joined_struct_field(
      module_, initializer, field, field_source.type_, field_source.shape, 0,
    ) {
    return false
  }
  let local_index = body.locals.start + local_id
  let local_source = module_.locals[local_index]
  module_.locals[local_index] = {
    ..local_source,
    type_: field_source.type_,
    shape: field_source.shape,
    nominal: 0UL,
  }
  let base_source = module_.expressions[only_use]
  module_.expressions[only_use] = {
    ..base_source,
    kind: PlannedConsumedExpression,
  }
  module_.expressions[field_expression] = {
    ..field_source,
    kind: PlannedLocalGet(local_id),
  }
  true
}

///|
fn scalar_replace_struct_component_aliases(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  items : HirSpan,
  item_index : Int,
  local_id : LocalId,
  initializer : ExprId,
) -> Bool {
  if initializer < 0 ||
    initializer >= module_.expressions.length() ||
    !(module_.expressions[initializer].trait_object_coercion is NoInferredTraitObjectCoercion) {
    return false
  }
  let fields = match module_.expressions[initializer].kind {
    PlannedStructNew(_, _, fields) => fields
    _ => return false
  }
  if fields.length < 2 ||
    fields.start < 0 ||
    fields.start + fields.length > module_.object_fields.length() {
    return false
  }
  let (use_count, _) = program_local_get_count(module_, body, local_id)
  if use_count < fields.length - 1 ||
    use_count > fields.length ||
    item_index + use_count >= items.length {
    return false
  }
  let component_locals : Array[LocalId] = Array::make(fields.length, -1)
  let field_gets : Array[ExprId] = Array::make(fields.length, -1)
  let base_gets : Array[ExprId] = Array::make(fields.length, -1)
  for alias_index in 0..<use_count {
    let (component_local, field_get) = match
      module_.block_items[items.start + item_index + alias_index + 1].kind {
      PlannedLetItem(component_local, false, field_get) =>
        (component_local, field_get)
      _ => return false
    }
    if field_get < 0 || field_get >= module_.expressions.length() {
      return false
    }
    let (field, base) = match module_.expressions[field_get].kind {
      PlannedFieldGet(field, base) => (field, base)
      _ => return false
    }
    if base < 0 || base >= module_.expressions.length() {
      return false
    }
    let source_local = match module_.expressions[base].kind {
      PlannedLocalGet(source_local) => source_local
      _ => return false
    }
    if source_local != local_id ||
      !program_scalar_replaceable_field_shape(
        module_.expressions[field_get].shape,
      ) ||
      !(module_.expressions[field_get].trait_object_coercion is NoInferredTraitObjectCoercion) {
      return false
    }
    let mut selected_field = -1
    for field_index in 0..<fields.length {
      if module_.object_fields[fields.start + field_index].field == field {
        if selected_field >= 0 {
          return false
        }
        selected_field = field_index
      }
    }
    if selected_field < 0 || component_locals[selected_field] >= 0 {
      return false
    }
    let object_value = module_.object_fields[
      fields.start + selected_field
    ].value
    if object_value < 0 ||
      object_value >= module_.expressions.length() ||
      module_.expressions[object_value].shape !=
      module_.expressions[field_get].shape ||
      module_.expressions[object_value].type_ !=
      module_.expressions[field_get].type_ {
      return false
    }
    component_locals[selected_field] = component_local
    field_gets[selected_field] = field_get
    base_gets[selected_field] = base
  }
  let mut missing = 0
  for field_index in 0..<fields.length {
    let object_value = module_.object_fields[fields.start + field_index].value
    if object_value < 0 || object_value >= module_.expressions.length() {
      return false
    }
    if component_locals[field_index] < 0 {
      missing += 1
    }
  }
  if missing > 1 {
    return false
  }
  let initializer_source = module_.expressions[initializer]
  module_.expressions[initializer] = {
    ..initializer_source,
    kind: PlannedConsumedExpression,
  }
  let aggregate_local_index = body.locals.start + local_id
  let aggregate_local = module_.locals[aggregate_local_index]
  module_.locals[aggregate_local_index] = {
    ..aggregate_local,
    shape: UnitPlannedValueShape,
    nominal: 0UL,
  }
  for field_index in 0..<fields.length {
    let object_value = module_.object_fields[fields.start + field_index].value
    let target_item = items.start + item_index + field_index
    let target_source = module_.block_items[target_item]
    module_.block_items[target_item] = if component_locals[field_index] >= 0 {
      {
        ..target_source,
        kind: PlannedLetItem(
          component_locals[field_index],
          false,
          object_value,
        ),
      }
    } else {
      { ..target_source, kind: PlannedExpressionItem(object_value) }
    }
    if field_gets[field_index] >= 0 {
      let field_get = field_gets[field_index]
      let field_source = module_.expressions[field_get]
      module_.expressions[field_get] = {
        ..field_source,
        kind: PlannedConsumedExpression,
      }
      let base = base_gets[field_index]
      let base_source = module_.expressions[base]
      module_.expressions[base] = {
        ..base_source,
        kind: PlannedConsumedExpression,
      }
    }
  }
  if use_count == fields.length {
    let remaining = items.start + item_index + fields.length
    module_.block_items[remaining] = {
      ..module_.block_items[remaining],
      kind: PlannedElidedLetItem(local_id),
    }
  }
  true
}

///|
fn scalar_replace_repeated_same_struct_field_local(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  local_id : LocalId,
  initializer : ExprId,
) -> Bool {
  if local_id < 0 ||
    local_id >= body.locals.length ||
    initializer < 0 ||
    initializer >= module_.expressions.length() ||
    !(module_.expressions[initializer].trait_object_coercion is NoInferredTraitObjectCoercion) {
    return false
  }
  let fields = match module_.expressions[initializer].kind {
    PlannedStructNew(_, _, fields) => fields
    _ => return false
  }
  if fields.start < 0 ||
    fields.start + fields.length > module_.object_fields.length() {
    return false
  }
  let field_gets : Array[ExprId] = []
  let base_gets : Array[ExprId] = []
  let mut total_gets = 0
  let mut selected_field : FieldId? = None
  let mut selected_field_expression = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if module_.expressions[expression].kind is PlannedLocalGet(source_local) &&
      source_local == local_id {
      total_gets += 1
    }
  }
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    let (field, base) = match module_.expressions[expression].kind {
      PlannedFieldGet(field, base) => (field, base)
      _ => continue
    }
    if base < body.expressions.start ||
      base >= body.expressions.start + body.expressions.length {
      continue
    }
    let source_local = match module_.expressions[base].kind {
      PlannedLocalGet(source_local) => source_local
      _ => continue
    }
    if source_local != local_id {
      continue
    }
    for existing in base_gets {
      if existing == base {
        return false
      }
    }
    if !program_scalar_replaceable_field_shape(
        module_.expressions[expression].shape,
      ) ||
      !(module_.expressions[expression].trait_object_coercion is NoInferredTraitObjectCoercion) {
      return false
    }
    match selected_field {
      Some(selected) if selected != field => return false
      Some(_) => ()
      None => {
        selected_field = Some(field)
        selected_field_expression = expression
      }
    }
    base_gets.push(base)
    field_gets.push(expression)
  }
  if total_gets != field_gets.length() ||
    field_gets.length() < 2 ||
    selected_field_expression < 0 {
    return false
  }
  let field = match selected_field {
    Some(field) => field
    None => return false
  }
  let start = module_.expression_children.length()
  let mut selected = -1
  for index in 0..<fields.length {
    let object_field = module_.object_fields[fields.start + index]
    module_.expression_children.push(object_field.value)
    if object_field.field == field {
      if selected >= 0 {
        selected = -2
      } else {
        selected = index
      }
    }
  }
  if selected < 0 {
    while module_.expression_children.length() > start {
      ignore(module_.expression_children.pop())
    }
    return false
  }
  let initializer_source = module_.expressions[initializer]
  let field_source = module_.expressions[selected_field_expression]
  module_.expressions[initializer] = {
    ..initializer_source,
    type_: field_source.type_,
    shape: field_source.shape,
    trait_object_coercion: NoInferredTraitObjectCoercion,
    kind: PlannedParameterSelect(
      { start, length: fields.length },
      selected,
    ),
  }
  let local_index = body.locals.start + local_id
  let local_source = module_.locals[local_index]
  module_.locals[local_index] = {
    ..local_source,
    type_: field_source.type_,
    shape: field_source.shape,
    nominal: 0UL,
  }
  for index in 0..<field_gets.length() {
    let base = base_gets[index]
    let base_source = module_.expressions[base]
    module_.expressions[base] = {
      ..base_source,
      kind: PlannedConsumedExpression,
    }
    let field_get = field_gets[index]
    let source = module_.expressions[field_get]
    module_.expressions[field_get] = {
      ..source,
      kind: PlannedLocalGet(local_id),
    }
  }
  true
}

///|
fn scalar_replace_synthesized_struct_components(
  module_ : PlannedModuleLowering,
  body_index : Int,
) -> Bool {
  if body_index < 0 || body_index >= module_.bodies.length() {
    return false
  }
  let body = module_.bodies[body_index]
  if body.locals.start < 0 ||
    body.locals.start + body.locals.length > module_.locals.length() {
    return false
  }
  for block in body.blocks.start..<(body.blocks.start + body.blocks.length) {
    if block < 0 || block >= module_.blocks.length() {
      continue
    }
    let items = module_.blocks[block].items
    if items.start < 0 ||
      items.start + items.length > module_.block_items.length() {
      continue
    }
    for item_index in 0..<items.length {
      let (local_id, initializer) = match
        module_.block_items[items.start + item_index].kind {
        PlannedLetItem(local_id, false, initializer) =>
          (local_id, initializer)
        _ => continue
      }
      if local_id < 0 ||
        local_id >= body.locals.length ||
        initializer < 0 ||
        initializer >= module_.expressions.length() ||
        program_cse_local_is_captured(module_, body, local_id) {
        continue
      }
      let fields = match module_.expressions[initializer].kind {
        PlannedStructNew(_, _, fields) => fields
        _ => continue
      }
      if fields.length < 2 ||
        fields.start < 0 ||
        fields.start + fields.length > module_.object_fields.length() {
        continue
      }
      let (use_count, _) = program_local_get_count(module_, body, local_id)
      if use_count < 2 {
        continue
      }
      let field_gets : Array[ExprId] = []
      let base_gets : Array[ExprId] = []
      let field_indices : Array[Int] = []
      let first_field_get : Array[ExprId] = Array::make(fields.length, -1)
      let component_nominals : Array[DeclId] = Array::make(fields.length, 0UL)
      let mut valid = true
      for expression in body.expressions.start..<(body.expressions.start + body.expressions.length) {
        let source_local = match module_.expressions[expression].kind {
          PlannedLocalGet(candidate) => candidate
          _ => continue
        }
        if source_local != local_id {
          continue
        }
        let mut selected_get = -1
        let mut selected_field : FieldId? = None
        for candidate in body.expressions.start..<(body.expressions.start + body.expressions.length) {
          match module_.expressions[candidate].kind {
            PlannedFieldGet(field, base) if base == expression => {
              if selected_get >= 0 {
                valid = false
                break
              }
              selected_get = candidate
              selected_field = Some(field)
            }
            _ => ()
          }
        }
        if !valid || selected_get < 0 {
          valid = false
          break
        }
        let selected_field = match selected_field {
          Some(field) => field
          None => {
            valid = false
            break
          }
        }
        let mut selected_index = -1
        for field_index in 0..<fields.length {
          if module_.object_fields[fields.start + field_index].field ==
            selected_field {
            if selected_index >= 0 {
              valid = false
              break
            }
            selected_index = field_index
          }
        }
        if !valid || selected_index < 0 {
          valid = false
          break
        }
        let object_value = module_.object_fields[
          fields.start + selected_index
        ].value
        if object_value < 0 || object_value >= module_.expressions.length() {
          valid = false
          break
        }
        let field_shape = module_.expressions[selected_get].shape
        let mut component_nominal = 0UL
        let supported_shape = if program_scalar_replaceable_field_shape(
          field_shape,
        ) {
          true
        } else if field_shape is RefPlannedValueShape {
          match module_.expressions[object_value].kind {
            PlannedLocalGet(source_local) if
              source_local >= 0 && source_local < body.locals.length => {
              component_nominal = module_.locals[
                body.locals.start + source_local
              ].nominal
              component_nominal != 0UL
            }
            _ => false
          }
        } else {
          false
        }
        if !supported_shape ||
          module_.expressions[object_value].type_ !=
          module_.expressions[selected_get].type_ ||
          module_.expressions[object_value].shape != field_shape ||
          !(module_.expressions[selected_get].trait_object_coercion is NoInferredTraitObjectCoercion) {
          valid = false
          break
        }
        if first_field_get[selected_index] >= 0 &&
          component_nominals[selected_index] != component_nominal {
          valid = false
          break
        }
        for candidate_block in body.blocks.start..<(body.blocks.start + body.blocks.length) {
          if candidate_block < 0 || candidate_block >= module_.blocks.length() {
            continue
          }
          let candidate_items = module_.blocks[candidate_block].items
          for candidate_item in 0..<candidate_items.length {
            match module_.block_items[
              candidate_items.start + candidate_item
            ].kind {
              PlannedLetItem(_, false, value) if value == selected_get => {
                valid = false
                break
              }
              _ => ()
            }
          }
          if !valid {
            break
          }
        }
        if !valid {
          break
        }
        field_gets.push(selected_get)
        base_gets.push(expression)
        field_indices.push(selected_index)
        if first_field_get[selected_index] < 0 {
          first_field_get[selected_index] = selected_get
          component_nominals[selected_index] = component_nominal
        }
      }
      if !valid || field_gets.length() != use_count {
        continue
      }
      let mut selected_fields = 0
      for field_index in 0..<fields.length {
        if first_field_get[field_index] >= 0 {
          selected_fields += 1
        }
      }
      if selected_fields < 2 {
        continue
      }
      let new_locals_start = module_.locals.length()
      for index in 0..<body.locals.length {
        module_.locals.push(module_.locals[body.locals.start + index])
      }
      let component_locals : Array[LocalId] = Array::make(fields.length, -1)
      for field_index in 0..<fields.length {
        let field_get = first_field_get[field_index]
        if field_get < 0 {
          continue
        }
        let field_source = module_.expressions[field_get]
        component_locals[field_index] = module_.locals.length() -
          new_locals_start
        module_.locals.push({
          body: module_.locals[new_locals_start + local_id].body,
          lambda: module_.locals[new_locals_start + local_id].lambda,
          local_id: component_locals[field_index],
          kind: LetLocal,
          mutable_: false,
          type_: field_source.type_,
          shape: field_source.shape,
          nominal: component_nominals[field_index],
          offset: field_source.offset,
        })
      }
      let aggregate_local = module_.locals[new_locals_start + local_id]
      module_.locals[new_locals_start + local_id] = {
        ..aggregate_local,
        shape: UnitPlannedValueShape,
        nominal: 0UL,
      }
      let new_items_start = module_.block_items.length()
      for index in 0..<item_index {
        module_.block_items.push(module_.block_items[items.start + index])
      }
      let aggregate_item = module_.block_items[items.start + item_index]
      for field_index in 0..<fields.length {
        let object_value = module_.object_fields[
          fields.start + field_index
        ].value
        module_.block_items.push(
          if component_locals[field_index] >= 0 {
            {
              ..aggregate_item,
              kind: PlannedLetItem(
                component_locals[field_index], false, object_value,
              ),
            }
          } else {
            { ..aggregate_item, kind: PlannedExpressionItem(object_value) }
          },
        )
      }
      for index in (item_index + 1)..<items.length {
        module_.block_items.push(module_.block_items[items.start + index])
      }
      let initializer_source = module_.expressions[initializer]
      module_.expressions[initializer] = {
        ..initializer_source,
        kind: PlannedConsumedExpression,
      }
      for index in 0..<field_gets.length() {
        let field_index = field_indices[index]
        let field_get = field_gets[index]
        let field_source = module_.expressions[field_get]
        module_.expressions[field_get] = {
          ..field_source,
          kind: PlannedLocalGet(component_locals[field_index]),
        }
        let base = base_gets[index]
        let base_source = module_.expressions[base]
        module_.expressions[base] = {
          ..base_source,
          kind: PlannedConsumedExpression,
        }
      }
      module_.blocks[block] = {
        ..module_.blocks[block],
        items: {
          start: new_items_start,
          length: items.length - 1 + fields.length,
        },
      }
      module_.bodies[body_index] = {
        ..body,
        locals: {
          start: new_locals_start,
          length: body.locals.length + selected_fields,
        },
      }
      return true
    }
  }
  false
}

///|
fn program_struct_initializer_is_discardable(
  module_ : PlannedModuleLowering,
  initializer : ExprId,
  effects : Map[DeclId, ProgramCallableEffectSummary],
) -> Bool {
  if initializer < 0 || initializer >= module_.expressions.length() {
    return false
  }
  let fields = match module_.expressions[initializer].kind {
    PlannedStructNew(_, _, fields) => fields
    _ => return false
  }
  if fields.start < 0 ||
    fields.start + fields.length > module_.object_fields.length() {
    return false
  }
  for index in 0..<fields.length {
    if !program_effect_summary_expression_is_discardable(
        module_,
        module_.object_fields[fields.start + index].value,
        effects,
        0,
      ) {
      return false
    }
  }
  true
}

///|
fn scalar_replace_program_struct_field_reads(
  modules : Array[PlannedModuleLowering],
  effects : Map[DeclId, ProgramCallableEffectSummary],
) -> Unit {
  for module_ in modules {
    for expression in 0..<module_.expressions.length() {
      let base = match module_.expressions[expression].kind {
        PlannedFieldGet(_, base) => base
        _ => continue
      }
      ignore(
        scalar_replace_program_struct_field_read(
          module_, expression, base,
        ),
      )
    }
    for body_index in 0..<module_.bodies.length() {
      while scalar_replace_synthesized_struct_components(
        module_, body_index,
      ) {}
    }
    for body in module_.bodies {
      for
        block in body.blocks.start..<(body.blocks.start + body.blocks.length) {
        if block < 0 || block >= module_.blocks.length() {
          continue
        }
        let items = module_.blocks[block].items
        if items.start < 0 ||
          items.start + items.length > module_.block_items.length() {
          continue
        }
        for index in 0..<(items.length - 1) {
          let (local_id, initializer) = match
            module_.block_items[items.start + index].kind {
            PlannedLetItem(local_id, false, initializer) =>
              (local_id, initializer)
            _ => continue
          }
          if initializer < 0 || initializer >= module_.expressions.length() {
            continue
          }
          let supported_initializer = match
            module_.expressions[initializer].kind {
            PlannedStructNew(_, _, _)
            | PlannedIfExpression(_, _, _)
            | PlannedMatchExpression(_, _) => true
            _ => false
          }
          if !supported_initializer ||
            program_cse_local_is_captured(module_, body, local_id) {
            continue
          }
          if scalar_replace_joined_struct_field_local(
              module_, body, local_id, initializer,
            ) {
            continue
          }
          if scalar_replace_struct_component_aliases(
              module_, body, items, index, local_id, initializer,
            ) {
            continue
          }
          if scalar_replace_repeated_same_struct_field_local(
              module_, body, local_id, initializer,
            ) {
            continue
          }
          let (use_count, only_use) = program_local_get_count(
            module_, body, local_id,
          )
          if use_count != 1 || only_use < 0 {
            continue
          }
          let initializer_is_discardable =
            program_struct_initializer_is_discardable(
              module_, initializer, effects,
            )
          let mut selected_expression = -1
          for candidate in (index + 1)..<items.length {
            let (candidate_expression, exits) = match
              module_.block_items[items.start + candidate].kind {
              PlannedLetItem(_, _, value) | PlannedExpressionItem(value) =>
                (value, false)
              PlannedReturnItem(value) => (value, true)
              PlannedElidedLetItem(_) => continue
            }
            if candidate_expression < 0 ||
              candidate_expression >= module_.expressions.length() {
              break
            }
            let field_base = match
              module_.expressions[candidate_expression].kind {
              PlannedFieldGet(_, base) => base
              _ => -1
            }
            if field_base == only_use {
              selected_expression = candidate_expression
              break
            }
            if exits ||
              !initializer_is_discardable ||
              !program_effect_summary_expression_is_discardable(
                module_, candidate_expression, effects, 0,
              ) {
              break
            }
          }
          if selected_expression < 0 ||
            !scalar_replace_program_struct_field_read(
              module_, selected_expression, initializer,
            ) {
            continue
          }
          let field_base = only_use
          let local_source = module_.expressions[field_base]
          module_.expressions[field_base] = {
            ..local_source,
            kind: PlannedConsumedExpression,
          }
          module_.block_items[items.start + index] = {
            ..module_.block_items[items.start + index],
            kind: PlannedElidedLetItem(local_id),
          }
        }
      }
    }
  }
}

///|
fn program_variant_field_name(
  module_ : PlannedModuleLowering,
  field : FieldId,
) -> String? {
  for layout in module_.type_layouts.fields {
    if layout.field == field {
      return Some(layout.name)
    }
  }
  None
}

///|
fn program_pattern_contains_binding(
  module_ : PlannedModuleLowering,
  pattern : PatternId,
  binding : LocalId,
  depth : Int,
) -> Bool {
  if depth >= 64 || pattern < 0 || pattern >= module_.patterns.length() {
    return false
  }
  if module_.patterns[pattern].reference is PatternBindingReference(candidate) {
    return candidate == binding
  }
  match module_.patterns[pattern].source {
    HirQualifiedPattern(base, _, _) =>
      program_pattern_contains_binding(module_, base, binding, depth + 1)
    HirTuplePattern(_, children, _) => {
      if children.start < 0 ||
        children.start + children.length > module_.pattern_children.length() {
        return false
      }
      for index in 0..<children.length {
        if program_pattern_contains_binding(
            module_,
            module_.pattern_children[children.start + index],
            binding,
            depth + 1,
          ) {
          return true
        }
      }
      false
    }
    HirStructPattern(_, fields, _, _, _) => {
      if fields.start < 0 ||
        fields.start + fields.length > module_.pattern_fields.length() {
        return false
      }
      for index in 0..<fields.length {
        if program_pattern_contains_binding(
            module_,
            module_.pattern_fields[fields.start + index].pattern,
            binding,
            depth + 1,
          ) {
          return true
        }
      }
      false
    }
    HirAlternativePattern(first, remaining, _) => {
      if program_pattern_contains_binding(
          module_, first, binding, depth + 1,
        ) {
        return true
      }
      if remaining.start < 0 ||
        remaining.start + remaining.length > module_.pattern_children.length() {
        return false
      }
      for index in 0..<remaining.length {
        if program_pattern_contains_binding(
            module_,
            module_.pattern_children[remaining.start + index],
            binding,
            depth + 1,
          ) {
          return true
        }
      }
      false
    }
    _ => false
  }
}

///|
fn program_pattern_variant_relation(
  module_ : PlannedModuleLowering,
  pattern : PatternId,
  variant : VariantId,
  depth : Int,
) -> Int {
  if depth >= 64 || pattern < 0 || pattern >= module_.patterns.length() {
    return -1
  }
  match module_.patterns[pattern].source {
    HirAlternativePattern(first, remaining, _) => {
      if remaining.start < 0 ||
        remaining.start + remaining.length > module_.pattern_children.length() {
        return -1
      }
      let mut matching = 0
      let first_relation = program_pattern_variant_relation(
        module_, first, variant, depth + 1,
      )
      if first_relation < 0 {
        return -1
      }
      if first_relation > 0 {
        matching += 1
      }
      for index in 0..<remaining.length {
        let relation = program_pattern_variant_relation(
          module_,
          module_.pattern_children[remaining.start + index],
          variant,
          depth + 1,
        )
        if relation < 0 {
          return -1
        }
        if relation > 0 {
          matching += 1
        }
      }
      if matching > 0 { 1 } else { 0 }
    }
    _ =>
      match module_.patterns[pattern].selected_constructor {
        VariantInferredPatternConstructor(candidate, _) =>
          if candidate == variant { 1 } else { 0 }
        _ => -1
      }
  }
}

///|
fn program_pattern_for_variant(
  module_ : PlannedModuleLowering,
  pattern : PatternId,
  variant : VariantId,
  depth : Int,
) -> PatternId {
  if depth >= 64 || pattern < 0 || pattern >= module_.patterns.length() {
    return -1
  }
  match module_.patterns[pattern].source {
    HirAlternativePattern(first, remaining, _) => {
      if remaining.start < 0 ||
        remaining.start + remaining.length > module_.pattern_children.length() {
        return -1
      }
      let mut selected = -1
      if program_pattern_variant_relation(
          module_, first, variant, depth + 1,
        ) > 0 {
        selected = first
      }
      for index in 0..<remaining.length {
        let candidate = module_.pattern_children[remaining.start + index]
        if program_pattern_variant_relation(
            module_, candidate, variant, depth + 1,
          ) > 0 {
          if selected >= 0 {
            return -1
          }
          selected = candidate
        }
      }
      if selected < 0 {
        -1
      } else {
        program_pattern_for_variant(module_, selected, variant, depth + 1)
      }
    }
    _ =>
      if program_pattern_variant_relation(module_, pattern, variant, depth) > 0 {
        pattern
      } else {
        -1
      }
  }
}

///|
fn program_can_scalarize_nested_pattern_binding(
  module_ : PlannedModuleLowering,
  pattern : PatternId,
  value : ExprId,
  binding : LocalId,
  target_type : BodyTypeId,
  target_shape : PlannedValueShape,
  depth : Int,
) -> Bool {
  if depth >= 64 ||
    pattern < 0 ||
    pattern >= module_.patterns.length() ||
    value < 0 ||
    value >= module_.expressions.length() ||
    !(module_.expressions[value].trait_object_coercion is NoInferredTraitObjectCoercion) {
    return false
  }
  if module_.patterns[pattern].reference is PatternBindingReference(candidate) {
    return candidate == binding &&
      module_.expressions[value].type_ == target_type &&
      module_.expressions[value].shape == target_shape
  }
  match (module_.patterns[pattern].source, module_.expressions[value].kind) {
    (
      HirStructPattern(_, pattern_fields, _, _, _),
      PlannedStructNew(_, _, object_fields),
    ) => {
      if pattern_fields.start < 0 ||
        pattern_fields.start + pattern_fields.length >
        module_.pattern_fields.length() ||
        object_fields.start < 0 ||
        object_fields.start + object_fields.length >
        module_.object_fields.length() {
        return false
      }
      let mut selected_pattern = -1
      let mut selected_name : String? = None
      for index in 0..<pattern_fields.length {
        let candidate = module_.pattern_fields[
          pattern_fields.start + index
        ]
        if program_pattern_contains_binding(
            module_, candidate.pattern, binding, depth + 1,
          ) {
          if selected_pattern >= 0 {
            return false
          }
          selected_pattern = candidate.pattern
          selected_name = Some(candidate.name)
        }
      }
      let selected_name = match selected_name {
        Some(name) => name
        None => return false
      }
      let mut selected_value = -1
      for index in 0..<object_fields.length {
        let candidate = module_.object_fields[object_fields.start + index]
        match program_variant_field_name(module_, candidate.field) {
          Some(name) if name == selected_name => {
            if selected_value >= 0 {
              return false
            }
            selected_value = candidate.value
          }
          _ => ()
        }
      }
      selected_value >= 0 &&
      program_can_scalarize_nested_pattern_binding(
        module_,
        selected_pattern,
        selected_value,
        binding,
        target_type,
        target_shape,
        depth + 1,
      )
    }
    (HirTuplePattern(_, children, _), PlannedStructNew(_, _, fields)) => {
      if children.length != fields.length ||
        children.start < 0 ||
        children.start + children.length > module_.pattern_children.length() ||
        fields.start < 0 ||
        fields.start + fields.length > module_.object_fields.length() {
        return false
      }
      let mut selected = -1
      for index in 0..<children.length {
        let child = module_.pattern_children[children.start + index]
        if program_pattern_contains_binding(
            module_, child, binding, depth + 1,
          ) {
          if selected >= 0 {
            return false
          }
          selected = index
        }
      }
      selected >= 0 &&
      program_can_scalarize_nested_pattern_binding(
        module_,
        module_.pattern_children[children.start + selected],
        module_.object_fields[fields.start + selected].value,
        binding,
        target_type,
        target_shape,
        depth + 1,
      )
    }
    _ => false
  }
}

///|
fn scalarize_nested_pattern_binding(
  module_ : PlannedModuleLowering,
  pattern : PatternId,
  value : ExprId,
  binding : LocalId,
  target_type : BodyTypeId,
  target_shape : PlannedValueShape,
  depth : Int,
) -> Bool {
  if depth >= 64 ||
    pattern < 0 ||
    pattern >= module_.patterns.length() ||
    value < 0 ||
    value >= module_.expressions.length() {
    return false
  }
  if module_.patterns[pattern].reference is PatternBindingReference(candidate) {
    return candidate == binding
  }
  let mut selected = -1
  let mut selected_pattern = -1
  let mut selected_value = -1
  let mut selector = { start: -1, length: 0 }
  match (module_.patterns[pattern].source, module_.expressions[value].kind) {
    (
      HirStructPattern(_, pattern_fields, _, _, _),
      PlannedStructNew(_, _, object_fields),
    ) => {
      let mut selected_name : String? = None
      for index in 0..<pattern_fields.length {
        let candidate = module_.pattern_fields[
          pattern_fields.start + index
        ]
        if program_pattern_contains_binding(
            module_, candidate.pattern, binding, depth + 1,
          ) {
          if selected >= 0 {
            return false
          }
          selected_pattern = candidate.pattern
          selected_name = Some(candidate.name)
        }
      }
      let selected_name = match selected_name {
        Some(name) => name
        None => return false
      }
      let start = module_.expression_children.length()
      for index in 0..<object_fields.length {
        let candidate = module_.object_fields[object_fields.start + index]
        module_.expression_children.push(candidate.value)
        match program_variant_field_name(module_, candidate.field) {
          Some(name) if name == selected_name => {
            selected = index
            selected_value = candidate.value
          }
          _ => ()
        }
      }
      selector = { start, length: object_fields.length }
    }
    (HirTuplePattern(_, children, _), PlannedStructNew(_, _, fields)) => {
      let start = module_.expression_children.length()
      for index in 0..<fields.length {
        let child = module_.pattern_children[children.start + index]
        let candidate = module_.object_fields[fields.start + index].value
        module_.expression_children.push(candidate)
        if program_pattern_contains_binding(
            module_, child, binding, depth + 1,
          ) {
          selected = index
          selected_pattern = child
          selected_value = candidate
        }
      }
      selector = { start, length: fields.length }
    }
    _ => return false
  }
  if selected < 0 ||
    !scalarize_nested_pattern_binding(
      module_,
      selected_pattern,
      selected_value,
      binding,
      target_type,
      target_shape,
      depth + 1,
    ) {
    while module_.expression_children.length() > selector.start {
      ignore(module_.expression_children.pop())
    }
    return false
  }
  let source = module_.expressions[value]
  module_.expressions[value] = {
    ..source,
    type_: target_type,
    shape: target_shape,
    kind: PlannedParameterSelect(selector, selected),
  }
  true
}

///|
fn program_pattern_is_direct_catchall(
  module_ : PlannedModuleLowering,
  pattern : PatternId,
) -> Bool {
  if pattern < 0 || pattern >= module_.patterns.length() {
    return false
  }
  match module_.patterns[pattern].source {
    HirWildcardPattern(_) | HirBindingPattern(_, _) => true
    _ => false
  }
}

///|
fn scalar_replace_known_variant_catchall(
  module_ : PlannedModuleLowering,
  expression : ExprId,
  variant_expression : ExprId,
  arm : PlannedPatternArm,
) -> Bool {
  if expression < 0 ||
    expression >= module_.expressions.length() ||
    variant_expression < 0 ||
    variant_expression >= module_.expressions.length() ||
    arm.body < 0 ||
    arm.body >= module_.expressions.length() ||
    !program_pattern_is_direct_catchall(module_, arm.pattern) {
    return false
  }
  let source = module_.expressions[expression]
  let body = module_.expressions[arm.body]
  if body.type_ != source.type_ ||
    body.shape != source.shape ||
    !program_scalar_replaceable_field_shape(source.shape) ||
    !(body.trait_object_coercion is NoInferredTraitObjectCoercion) {
    return false
  }
  match body.kind {
    PlannedI32Const(_)
    | PlannedU32Const(_)
    | PlannedI64Const(_)
    | PlannedU64Const(_)
    | PlannedF32Const(_)
    | PlannedF64Const(_)
    | PlannedBoolConst(_) => ()
    _ => return false
  }
  let selector_start = module_.expression_children.length()
  match module_.expressions[variant_expression].kind {
    PlannedVariantTupleNew(_, _, arguments) => {
      if arguments.start < 0 ||
        arguments.start + arguments.length > module_.expression_children.length() {
        return false
      }
      for index in 0..<arguments.length {
        module_.expression_children.push(
          module_.expression_children[arguments.start + index],
        )
      }
    }
    PlannedVariantStructNew(_, _, fields) => {
      if fields.start < 0 ||
        fields.start + fields.length > module_.object_fields.length() {
        return false
      }
      for index in 0..<fields.length {
        module_.expression_children.push(
          module_.object_fields[fields.start + index].value,
        )
      }
    }
    _ => return false
  }
  module_.expression_children.push(arm.body)
  module_.expressions[expression] = {
    ..source,
    kind: PlannedParameterSelect(
      {
        start: selector_start,
        length: module_.expression_children.length() - selector_start,
      },
      module_.expression_children.length() - selector_start - 1,
    ),
  }
  let variant_source = module_.expressions[variant_expression]
  module_.expressions[variant_expression] = {
    ..variant_source,
    kind: PlannedConsumedExpression,
  }
  true
}

///|
fn scalar_replace_program_variant_payload_match(
  module_ : PlannedModuleLowering,
  expression : ExprId,
  variant_expression : ExprId,
) -> Bool {
  if expression < 0 ||
    expression >= module_.expressions.length() ||
    variant_expression < 0 ||
    variant_expression >= module_.expressions.length() {
    return false
  }
  let source = module_.expressions[expression]
  let arms = match source.kind {
    PlannedMatchExpression(_, arms) => arms
    _ => return false
  }
  if arms.length == 0 ||
    arms.start < 0 ||
    arms.start + arms.length > module_.pattern_arms.length() ||
    !(source.trait_object_coercion is NoInferredTraitObjectCoercion) ||
    !(module_.expressions[variant_expression].trait_object_coercion is NoInferredTraitObjectCoercion) {
    return false
  }
  let variant = match module_.expressions[variant_expression].kind {
    PlannedVariantTupleNew(variant, _, _)
    | PlannedVariantStructNew(variant, _, _) => variant
    _ => return false
  }
  let mut selected_arm = -1
  for index in 0..<arms.length {
    let candidate = module_.pattern_arms[arms.start + index]
    if candidate.pattern < 0 ||
      candidate.pattern >= module_.patterns.length() ||
      candidate.body < 0 ||
      candidate.body >= module_.expressions.length() {
      return false
    }
    let guard_constant = if candidate.guard_condition < 0 {
      1
    } else if candidate.guard_condition >= module_.expressions.length() {
      -1
    } else {
      match module_.expressions[candidate.guard_condition].kind {
        PlannedBoolConst(false) => 0
        PlannedBoolConst(true) => 1
        _ => -1
      }
    }
    if guard_constant == 0 {
      continue
    }
    match program_pattern_variant_relation(
      module_, candidate.pattern, variant, 0,
    ) {
      1 => {
        if guard_constant < 0 {
          return false
        }
        selected_arm = arms.start + index
        break
      }
      0 => ()
      _ => {
        if guard_constant > 0 &&
          program_pattern_is_direct_catchall(module_, candidate.pattern) {
          return scalar_replace_known_variant_catchall(
            module_, expression, variant_expression, candidate,
          )
        }
        return false
      }
    }
  }
  if selected_arm < 0 {
    return false
  }
  let arm = module_.pattern_arms[selected_arm]
  let root_pattern = program_pattern_for_variant(
    module_, arm.pattern, variant, 0,
  )
  if root_pattern < 0 {
    return false
  }
  let root = module_.patterns[root_pattern]
  let selected_variant = variant
  let local_id = match module_.expressions[arm.body].kind {
    PlannedLocalGet(local_id) => local_id
    _ => return false
  }
  let mut selected = -1
  let mut payload = -1
  let mut payload_pattern = -1
  let mut payload_count = 0
  let mut selector = { start: -1, length: 0 }
  let mut appended_selector = false
  match (module_.expressions[variant_expression].kind, root.source) {
    (
      PlannedVariantTupleNew(variant, _, arguments),
      HirTuplePattern(_, children, _),
    ) => {
      if selected_variant != variant ||
        arguments.length == 0 ||
        arguments.start < 0 ||
        arguments.start + arguments.length > module_.expression_children.length() ||
        children.length != arguments.length ||
        children.start < 0 ||
        children.start + children.length > module_.pattern_children.length() {
        return false
      }
      for index in 0..<children.length {
        let pattern = module_.pattern_children[children.start + index]
        if pattern < 0 || pattern >= module_.patterns.length() {
          return false
        }
        if program_pattern_contains_binding(
            module_, pattern, local_id, 0,
          ) {
          if selected >= 0 {
            return false
          }
          selected = index
          payload_pattern = pattern
        }
      }
      if selected < 0 {
        return false
      }
      payload = module_.expression_children[arguments.start + selected]
      payload_count = arguments.length
      selector = arguments
    }
    (
      PlannedVariantStructNew(variant, _, fields),
      HirStructPattern(_, pattern_fields, _, _, _),
    ) => {
      if selected_variant != variant ||
        fields.length == 0 ||
        fields.start < 0 ||
        fields.start + fields.length > module_.object_fields.length() ||
        pattern_fields.start < 0 ||
        pattern_fields.start + pattern_fields.length > module_.pattern_fields.length() {
        return false
      }
      let mut selected_name : String? = None
      for index in 0..<pattern_fields.length {
        let pattern_field = module_.pattern_fields[pattern_fields.start + index]
        if pattern_field.pattern < 0 ||
          pattern_field.pattern >= module_.patterns.length() {
          return false
        }
        if program_pattern_contains_binding(
            module_, pattern_field.pattern, local_id, 0,
          ) {
          if selected_name is Some(_) {
            return false
          }
          selected_name = Some(pattern_field.name)
          payload_pattern = pattern_field.pattern
        }
      }
      let selected_name = match selected_name {
        Some(name) => name
        None => return false
      }
      for index in 0..<fields.length {
        let object_field = module_.object_fields[fields.start + index]
        match program_variant_field_name(module_, object_field.field) {
          Some(name) if name == selected_name => {
            if selected >= 0 {
              return false
            }
            selected = index
            payload = object_field.value
          }
          _ => ()
        }
      }
      if selected < 0 {
        return false
      }
      payload_count = fields.length
      let start = module_.expression_children.length()
      for index in 0..<fields.length {
        module_.expression_children.push(
          module_.object_fields[fields.start + index].value,
        )
      }
      selector = { start, length: fields.length }
      appended_selector = true
    }
    _ => return false
  }
  let direct_payload = payload_pattern >= 0 &&
    module_.patterns[payload_pattern].reference is PatternBindingReference(binding) &&
    binding == local_id
  if payload < 0 ||
    payload >= module_.expressions.length() ||
    payload_pattern < 0 ||
    (!program_scalar_replaceable_field_shape(source.shape) &&
    !(direct_payload &&
    payload_count == 1 &&
    ((source.shape is RefPlannedValueShape) ||
    (source.shape is GenericPlannedValueShape)))) ||
    !program_can_scalarize_nested_pattern_binding(
      module_,
      payload_pattern,
      payload,
      local_id,
      source.type_,
      source.shape,
      0,
    ) ||
    !scalarize_nested_pattern_binding(
      module_,
      payload_pattern,
      payload,
      local_id,
      source.type_,
      source.shape,
      0,
    ) {
    if appended_selector {
      while module_.expression_children.length() > selector.start {
        ignore(module_.expression_children.pop())
      }
    }
    return false
  }
  module_.expressions[expression] = {
    ..source,
    kind: PlannedParameterSelect(selector, selected),
  }
  let variant_source = module_.expressions[variant_expression]
  module_.expressions[variant_expression] = {
    ..variant_source,
    kind: PlannedConsumedExpression,
  }
  true
}

///|
fn scalar_replace_program_variant_payload_reads(
  modules : Array[PlannedModuleLowering],
) -> Unit {
  for module_ in modules {
    for expression in 0..<module_.expressions.length() {
      let scrutinee = match module_.expressions[expression].kind {
        PlannedMatchExpression(scrutinee, _) => scrutinee
        _ => continue
      }
      if scrutinee < 0 || scrutinee >= module_.expressions.length() {
        continue
      }
      if module_.expressions[scrutinee].kind is PlannedVariantTupleNew(_, _, _) ||
        module_.expressions[scrutinee].kind is PlannedVariantStructNew(_, _, _) {
        ignore(
          scalar_replace_program_variant_payload_match(
            module_, expression, scrutinee,
          ),
        )
      }
    }
    for body in module_.bodies {
      for
        block in body.blocks.start..<(body.blocks.start + body.blocks.length) {
        if block < 0 || block >= module_.blocks.length() {
          continue
        }
        let items = module_.blocks[block].items
        if items.start < 0 ||
          items.start + items.length > module_.block_items.length() {
          continue
        }
        for index in 0..<items.length {
          let (local_id, initializer) = match
            module_.block_items[items.start + index].kind {
            PlannedLetItem(local_id, false, initializer) =>
              (local_id, initializer)
            _ => continue
          }
          if initializer < 0 ||
            initializer >= module_.expressions.length() ||
            (!(module_.expressions[initializer].kind is PlannedVariantTupleNew(_, _, _)) &&
            !(module_.expressions[initializer].kind is PlannedVariantStructNew(_, _, _))) ||
            program_cse_local_is_captured(module_, body, local_id) {
            continue
          }
          let (use_count, only_use) = program_local_get_count(
            module_, body, local_id,
          )
          if use_count != 1 || only_use < 0 {
            continue
          }
          let mut match_expression = -1
          for
            candidate in body.expressions.start..<(body.expressions.start +
            body.expressions.length) {
            match module_.expressions[candidate].kind {
              PlannedMatchExpression(scrutinee, _) if scrutinee == only_use => {
                if match_expression >= 0 {
                  match_expression = -2
                  break
                }
                match_expression = candidate
              }
              _ => ()
            }
          }
          if match_expression < 0 ||
            !scalar_replace_program_variant_payload_match(
              module_, match_expression, initializer,
            ) {
            continue
          }
          let use_source = module_.expressions[only_use]
          module_.expressions[only_use] = {
            ..use_source,
            kind: PlannedConsumedExpression,
          }
          module_.block_items[items.start + index] = {
            ..module_.block_items[items.start + index],
            kind: PlannedElidedLetItem(local_id),
          }
        }
      }
    }
  }
}

///|
fn mark_tail_recursive_expression(
  module_ : PlannedModuleLowering,
  expression : ExprId,
  declaration : DeclId,
  depth : Int,
) -> Unit {
  if expression < 0 ||
    expression >= module_.expressions.length() ||
    depth > module_.expressions.length() + module_.blocks.length() {
    return
  }
  let source = module_.expressions[expression]
  match source.kind {
    PlannedDirectCall(target, receiver, arguments, type_arguments) if target ==
      declaration &&
      receiver < 0 &&
      type_arguments.length == 0 =>
      module_.expressions[expression] = {
        ..source,
        kind: PlannedTailCall(target, receiver, arguments, type_arguments),
      }
    PlannedBlockExpression(block) =>
      mark_tail_recursive_block(module_, block, declaration, depth + 1)
    PlannedIfExpression(_, then_block, alternative) => {
      mark_tail_recursive_block(module_, then_block, declaration, depth + 1)
      mark_tail_recursive_expression(
        module_,
        alternative,
        declaration,
        depth + 1,
      )
    }
    PlannedMatchExpression(_, arms) => {
      if arms.start < 0 ||
        arms.start + arms.length > module_.pattern_arms.length() {
        return
      }
      for index in 0..<arms.length {
        mark_tail_recursive_expression(
          module_,
          module_.pattern_arms[arms.start + index].body,
          declaration,
          depth + 1,
        )
      }
    }
    _ => ()
  }
}

///|
fn mark_tail_recursive_block(
  module_ : PlannedModuleLowering,
  block : BlockId,
  declaration : DeclId,
  depth : Int,
) -> Unit {
  if block < 0 ||
    block >= module_.blocks.length() ||
    depth > module_.expressions.length() + module_.blocks.length() {
    return
  }
  let items = module_.blocks[block].items
  if items.start < 0 ||
    items.start + items.length > module_.block_items.length() {
    return
  }
  for index in 0..<items.length {
    match module_.block_items[items.start + index].kind {
      PlannedReturnItem(value) if value >= 0 =>
        mark_tail_recursive_expression(module_, value, declaration, depth + 1)
      _ => ()
    }
  }
  if items.length == 0 {
    return
  }
  match module_.block_items[items.start + items.length - 1].kind {
    PlannedExpressionItem(value) =>
      mark_tail_recursive_expression(module_, value, declaration, depth + 1)
    _ => ()
  }
}

///|
fn program_tail_scalar_shape(shape : PlannedValueShape) -> Bool {
  match shape {
    ErrorPlannedValueShape
    | RefPlannedValueShape
    | GenericPlannedValueShape => false
    _ => true
  }
}

///|
fn program_tail_body_uses_scalar_carriers(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
  callable : PlannedCallable,
) -> Bool {
  if !program_tail_scalar_shape(callable.result_shape) {
    return false
  }
  for local_id in 0..<body.locals.length {
    if !program_tail_scalar_shape(
        module_.locals[body.locals.start + local_id].shape,
      ) {
      return false
    }
  }
  true
}

///|
fn mark_program_tail_recursion(modules : Array[PlannedModuleLowering]) -> Unit {
  for module_ in modules {
    for body in module_.bodies {
      let callable = match module_.functions.callable_of(body.declaration) {
        Some(value) => value
        None => continue
      }
      if callable.has_receiver ||
        program_callable_generic_parameters(callable).length > 0 ||
        !program_tail_body_uses_scalar_carriers(module_, body, callable) {
        continue
      }
      match body.root {
        ExpressionBodyRoot(expression) =>
          mark_tail_recursive_expression(
            module_,
            expression,
            body.declaration,
            0,
          )
        BlockBodyRoot(block) =>
          mark_tail_recursive_block(module_, block, body.declaration, 0)
      }
    }
  }
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
  let initial_effects = program_callable_effect_summaries(modules)
  inline_program_calls_from_summaries(modules, initial_effects)
  let effects = program_callable_effect_summaries(modules)
  directize_transparent_callback_calls(modules, effects)
  directize_generic_parameter_selectors(modules)
  let elided_trait_wrappers = directize_exact_runtime_trait_flows(
    modules,
    lowering.index.module_lookup,
    effects,
  )
  cse_program_field_extractions(modules)
  scalar_replace_program_struct_field_reads(modules, effects)
  scalar_replace_program_variant_payload_reads(modules)
  mark_program_tail_recursion(modules)
  {
    graph: lowering.graph,
    modules,
    index: lowering.index,
    elided_trait_wrappers,
  }
}
