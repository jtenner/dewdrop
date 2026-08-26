///|
let flow_falls_through = 1

///|
let flow_returns = 2

///|
let flow_breaks = 4

///|
let flow_continues = 8

///|
let flow_diverges = 16

///|
let empty_flow_summaries : Array[BodyFlowSummary] = []

///|
let empty_flow_bools : Array[Bool] = []

///|
let empty_flow_spans : Array[HirSpan] = []

///|
pub struct BodyFlowSummary {
  outcomes : Int
} derive(Eq, Debug)

///|
pub fn BodyFlowSummary::may_fall_through(self : BodyFlowSummary) -> Bool {
  (self.outcomes & flow_falls_through) != 0
}

///|
pub fn BodyFlowSummary::may_return(self : BodyFlowSummary) -> Bool {
  (self.outcomes & flow_returns) != 0
}

///|
pub fn BodyFlowSummary::may_break(self : BodyFlowSummary) -> Bool {
  (self.outcomes & flow_breaks) != 0
}

///|
pub fn BodyFlowSummary::may_continue(self : BodyFlowSummary) -> Bool {
  (self.outcomes & flow_continues) != 0
}

///|
pub fn BodyFlowSummary::may_diverge(self : BodyFlowSummary) -> Bool {
  (self.outcomes & flow_diverges) != 0
}

///|
pub enum MissingPatternCase {
  MissingCatchAllCase
  MissingBoolCase(Bool)
  MissingVariantCase(VariantId)
} derive(Eq, Debug)

///|
pub enum BodyFlowDiagnostic {
  NonExhaustiveMatch(ExprId, HirSpan, UInt64)
  NonExhaustiveFunctionalLoop(ExprId, HirSpan, UInt64)
  RedundantPatternArm(PatternArmId, UInt64)
  FunctionalLoopArmFallsThrough(PatternArmId, UInt64)
  UnreachableBlockItem(BlockId, Int, UInt64)
} derive(Eq, Debug)

///|
pub fn BodyFlowDiagnostic::offset(self : BodyFlowDiagnostic) -> UInt64 {
  match self {
    NonExhaustiveMatch(_, _, offset)
    | NonExhaustiveFunctionalLoop(_, _, offset)
    | RedundantPatternArm(_, offset)
    | FunctionalLoopArmFallsThrough(_, offset)
    | UnreachableBlockItem(_, _, offset) => offset
  }
}

///|
pub struct AnalyzedBodyFlow {
  body : BodyId
  flow : BodyFlowSummary
  diagnostics : HirSpan
} derive(Eq, Debug)

///|
pub struct AnalyzedLambdaFlow {
  lambda : LambdaId
  flow : BodyFlowSummary
  diagnostics : HirSpan
} derive(Eq, Debug)

///|
pub struct AnalyzedModuleFlows {
  module_id : ModuleId
  bodies : Array[AnalyzedBodyFlow]
  lambdas : Array[AnalyzedLambdaFlow]
  expression_flows : Array[BodyFlowSummary]
  block_flows : Array[BodyFlowSummary]
  arm_flows : Array[BodyFlowSummary]
  missing_cases : Array[MissingPatternCase]
  diagnostics : Array[BodyFlowDiagnostic]
} derive(Eq, Debug)

///|
pub fn AnalyzedModuleFlows::body(
  self : AnalyzedModuleFlows,
  body : BodyId,
) -> AnalyzedBodyFlow? {
  if semantic_id_module(body) != self.module_id {
    return None
  }
  let index = semantic_id_local(body)
  if index < 0 || index >= self.bodies.length() {
    None
  } else {
    Some(self.bodies[index])
  }
}

///|
pub fn AnalyzedModuleFlows::lambda(
  self : AnalyzedModuleFlows,
  lambda : LambdaId,
) -> AnalyzedLambdaFlow? {
  if lambda < 0 || lambda >= self.lambdas.length() {
    None
  } else {
    Some(self.lambdas[lambda])
  }
}

///|
fn flow(outcomes : Int) -> BodyFlowSummary {
  { outcomes, }
}

///|
fn flow_sequence(
  first : BodyFlowSummary,
  second : BodyFlowSummary,
) -> BodyFlowSummary {
  let exits = first.outcomes - (first.outcomes & flow_falls_through)
  if first.may_fall_through() {
    flow(exits | second.outcomes)
  } else {
    flow(exits)
  }
}

///|
fn flow_union(
  left : BodyFlowSummary,
  right : BodyFlowSummary,
) -> BodyFlowSummary {
  flow(left.outcomes | right.outcomes)
}

///|
priv enum CoverageDomain {
  ErrorCoverageDomain
  OpenCoverageDomain
  BoolCoverageDomain
  EnumCoverageDomain(DeclId)
} derive(Eq)

///|
priv enum CoverageAtom {
  ErrorCoverageAtom
  UnknownCoverageAtom
  CatchAllCoverageAtom
  BoolCoverageAtom(Bool)
  VariantCoverageAtom(VariantId)
}

///|
priv struct BodyFlowJobResult {
  flow : BodyFlowSummary
  expression_flows : Array[BodyFlowSummary]
  block_flows : Array[BodyFlowSummary]
  arm_flows : Array[BodyFlowSummary]
  missing_cases : Array[MissingPatternCase]
  diagnostics : Array[BodyFlowDiagnostic]
}

///|
priv struct BodyFlowAnalyzer {
  collected : CollectedModule
  resolved : ResolvedModuleTypes
  inferred : InferredModuleBodies
  imports : ResolvedModuleImports?
  body : HirBody
  expression_flows : Array[BodyFlowSummary]
  block_flows : Array[BodyFlowSummary]
  block_done : Array[Bool]
  arm_flows : Array[BodyFlowSummary]
  pattern_irrefutable : Array[Bool]
  pattern_payload_irrefutable : Array[Bool]
  pattern_has_error : Array[Bool]
  variant_spans : Array[HirSpan]
  pattern_tasks : Array[PatternId]
  missing_cases : Array[MissingPatternCase]
  diagnostics : Array[BodyFlowDiagnostic]
}

///|
fn BodyFlowAnalyzer::new(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
  imports : ResolvedModuleImports?,
  body : HirBody,
  variant_spans : Array[HirSpan],
  pattern_tasks : Array[PatternId],
) -> BodyFlowAnalyzer {
  pattern_tasks.clear()
  {
    collected,
    resolved,
    inferred,
    imports,
    body,
    expression_flows: if body.expressions.length == 0 {
      empty_flow_summaries
    } else {
      Array::make(body.expressions.length, flow(0))
    },
    block_flows: if body.blocks.length == 0 {
      empty_flow_summaries
    } else {
      Array::make(body.blocks.length, flow(0))
    },
    block_done: if body.blocks.length == 0 {
      empty_flow_bools
    } else {
      Array::make(body.blocks.length, false)
    },
    arm_flows: if body.pattern_arms.length == 0 {
      empty_flow_summaries
    } else {
      Array::make(body.pattern_arms.length, flow(0))
    },
    pattern_irrefutable: if body.patterns.length == 0 {
      empty_flow_bools
    } else {
      Array::make(body.patterns.length, false)
    },
    pattern_payload_irrefutable: if body.patterns.length == 0 {
      empty_flow_bools
    } else {
      Array::make(body.patterns.length, false)
    },
    pattern_has_error: if body.patterns.length == 0 {
      empty_flow_bools
    } else {
      Array::make(body.patterns.length, false)
    },
    variant_spans,
    pattern_tasks,
    missing_cases: [],
    diagnostics: [],
  }
}

///|
fn BodyFlowAnalyzer::expression_flow(
  self : BodyFlowAnalyzer,
  expression : ExprId,
) -> BodyFlowSummary {
  self.expression_flows[expression - self.body.expressions.start]
}

///|
fn BodyFlowAnalyzer::set_expression_flow(
  self : BodyFlowAnalyzer,
  expression : ExprId,
  summary : BodyFlowSummary,
) -> Unit {
  self.expression_flows[expression - self.body.expressions.start] = summary
}

///|
fn BodyFlowAnalyzer::pattern_is_irrefutable(
  self : BodyFlowAnalyzer,
  pattern : PatternId,
) -> Bool {
  self.pattern_irrefutable[pattern - self.body.patterns.start]
}

///|
fn BodyFlowAnalyzer::pattern_payload_is_irrefutable(
  self : BodyFlowAnalyzer,
  pattern : PatternId,
) -> Bool {
  self.pattern_payload_irrefutable[pattern - self.body.patterns.start]
}

///|
fn BodyFlowAnalyzer::expression_is_never(
  self : BodyFlowAnalyzer,
  expression : ExprId,
) -> Bool {
  let mut type_ = self.inferred.expression_types[expression]
  while true {
    match self.inferred.type_term(type_) {
      BodyErrorType
      | BodyVariableType(_)
      | BodyProductType(_)
      | BodyFunctionType(_, _) => return false
      BodyAppliedType(base, _) => type_ = base
      BodyResolvedType(resolved_type) => {
        let mut current = resolved_type
        while true {
          match self.resolved.types[current] {
            PrimitiveType(NeverType) => return true
            AppliedType(base, _) => current = base
            _ => return false
          }
        }
      }
    }
  }
  false
}

///|
fn BodyFlowAnalyzer::terminal_flow(
  self : BodyFlowAnalyzer,
  expression : ExprId,
) -> BodyFlowSummary {
  if self.expression_is_never(expression) {
    flow(flow_diverges)
  } else {
    flow(flow_falls_through)
  }
}

///|
fn BodyFlowAnalyzer::sequence_expression_children(
  self : BodyFlowAnalyzer,
  children : HirSpan,
) -> BodyFlowSummary {
  let mut summary = flow(flow_falls_through)
  for index in 0..<children.length {
    summary = flow_sequence(
      summary,
      self.expression_flow(
        self.collected.expression_children[children.start + index],
      ),
    )
  }
  summary
}

///|
fn BodyFlowAnalyzer::field_count(
  self : BodyFlowAnalyzer,
  declaration : DeclId,
  variant : VariantId?,
) -> Int {
  if semantic_id_module(declaration) != self.collected.module_id {
    return match self.imports {
      Some(imports) => {
        let mut count = 0
        for field in imports.fields_of(declaration) {
          if field.variant == variant {
            count += 1
          }
        }
        count
      }
      None => 0
    }
  }
  let mut count = 0
  for field in self.collected.fields {
    if field.declaration == declaration && field.variant == variant {
      count += 1
    }
  }
  count
}

///|
fn BodyFlowAnalyzer::initialize_pattern_irrefutability(
  self : BodyFlowAnalyzer,
) -> Unit {
  match self.inferred.body(self.body.id) {
    Some(body_result) =>
      for index in 0..<body_result.diagnostics.length {
        match self.inferred.diagnostics[body_result.diagnostics.start + index] {
          InvalidPatternConstructor(pattern, _)
          | UnknownVariantForType(_, _, pattern, _)
          | AmbiguousPatternVariant(_, pattern, _, _, _, _)
          | PatternPayloadKindMismatch(pattern, _, _)
          | PatternPayloadArityMismatch(pattern, _, _, _)
          | UnknownPatternField(_, pattern, _)
          | MissingPatternField(_, pattern, _)
          | MissingImportedPatternField(_, pattern, _)
          | UnresolvedPatternTypeArgument(pattern, _, _) =>
            if pattern >= self.body.patterns.start &&
              pattern < self.body.patterns.start + self.body.patterns.length {
              self.pattern_has_error[pattern - self.body.patterns.start] = true
            }
          _ => ()
        }
      }
    None => ()
  }
  for
    pattern in self.body.patterns.start..<(self.body.patterns.start +
    self.body.patterns.length) {
    let pattern_slot = pattern - self.body.patterns.start
    let selected = self.inferred.pattern_constructors[pattern]
    let payload_irrefutable = match self.collected.patterns[pattern] {
      HirWildcardPattern(_) | HirBindingPattern(_, _) | HirRestPattern(_) =>
        true
      HirImportAliasPattern(_, _) | HirLiteralPattern(_, _) => false
      HirQualifiedPattern(_, _, _) =>
        match selected {
          VariantInferredPatternConstructor(_, _) => true
          _ => false
        }
      HirTuplePattern(_, children, _) => {
        let mut result = true
        for index in 0..<children.length {
          let child = self.collected.pattern_children[children.start + index]
          match self.collected.patterns[child] {
            HirRestPattern(_) => ()
            _ => if !self.pattern_is_irrefutable(child) { result = false }
          }
        }
        result
      }
      HirStructPattern(_, fields, rest, _, _) => {
        let mut result = true
        for index in 0..<fields.length {
          let field = self.collected.pattern_fields[fields.start + index]
          if !self.pattern_is_irrefutable(field.pattern) {
            result = false
          }
        }
        if result && !rest {
          match selected {
            StructInferredPatternConstructor(declaration, _) =>
              result = fields.length == self.field_count(declaration, None)
            VariantInferredPatternConstructor(variant, _) => {
              let declaration = if semantic_id_module(variant) ==
                self.collected.module_id {
                Some(
                  self.collected.variants[semantic_id_local(variant)].declaration,
                )
              } else {
                match self.imports {
                  Some(imports) =>
                    match imports.variant(variant) {
                      Some(imported) => Some(imported.declaration)
                      None => None
                    }
                  None => None
                }
              }
              result = match declaration {
                Some(owner) =>
                  fields.length == self.field_count(owner, Some(variant))
                None => false
              }
            }
            _ => result = false
          }
        }
        result
      }
      HirAlternativePattern(first, alternatives, _) => {
        let mut result = self.pattern_is_irrefutable(first)
        for index in 0..<alternatives.length {
          if self.pattern_is_irrefutable(
              self.collected.pattern_children[alternatives.start + index],
            ) {
            result = true
          }
        }
        result
      }
    }
    let valid_payload = payload_irrefutable &&
      !self.pattern_has_error[pattern_slot]
    self.pattern_payload_irrefutable[pattern_slot] = valid_payload
    self.pattern_irrefutable[pattern_slot] = match selected {
      StructInferredPatternConstructor(_, _) => valid_payload
      VariantInferredPatternConstructor(_, _)
      | ErrorInferredPatternConstructor => false
      NoInferredPatternConstructor =>
        match self.collected.patterns[pattern] {
          HirWildcardPattern(_) | HirBindingPattern(_, _) | HirRestPattern(_) =>
            true
          HirAlternativePattern(_, _, _) => valid_payload
          _ => false
        }
    }
  }
}

///|
fn BodyFlowAnalyzer::coverage_domain(
  self : BodyFlowAnalyzer,
  type_ : BodyTypeId,
) -> CoverageDomain {
  let mut current = type_
  while true {
    match self.inferred.type_term(current) {
      BodyErrorType | BodyVariableType(_) => return ErrorCoverageDomain
      BodyProductType(_) | BodyFunctionType(_, _) => return OpenCoverageDomain
      BodyAppliedType(base, _) => current = base
      BodyResolvedType(resolved_type) => {
        let mut resolved_current = resolved_type
        while true {
          match self.resolved.types[resolved_current] {
            ErrorType | GenericParameterType(_) | TraitType(_) | SelfType(_) =>
              return ErrorCoverageDomain
            ProductType(_) => return OpenCoverageDomain
            PrimitiveType(BoolType) => return BoolCoverageDomain
            PrimitiveType(_) => return OpenCoverageDomain
            NominalType(declaration) =>
              match self.collected.declaration(declaration) {
                Some(TopLevelReference({ kind: EnumDecl, .. })) =>
                  return EnumCoverageDomain(declaration)
                Some(_) => return OpenCoverageDomain
                None =>
                  match self.imports {
                    Some(imports) if imports.is_enum(declaration) =>
                      return EnumCoverageDomain(declaration)
                    _ => return OpenCoverageDomain
                  }
              }
            AppliedType(base, _) => resolved_current = base
            FunctionType(_, _) => return OpenCoverageDomain
          }
        }
      }
    }
  }
  ErrorCoverageDomain
}

///|
fn BodyFlowAnalyzer::variant_payload_is_irrefutable(
  self : BodyFlowAnalyzer,
  pattern : PatternId,
  variant : VariantId,
) -> Bool {
  if semantic_id_module(variant) != self.collected.module_id {
    return self.pattern_payload_is_irrefutable(pattern)
  }
  let variant_info = self.collected.variants[semantic_id_local(variant)]
  match variant_info.kind {
    UnitVariantDecl => true
    TupleVariantDecl | StructVariantDecl =>
      self.pattern_payload_is_irrefutable(pattern)
  }
}

///|
fn BodyFlowAnalyzer::coverage_atom(
  self : BodyFlowAnalyzer,
  pattern : PatternId,
) -> CoverageAtom {
  if self.pattern_has_error[pattern - self.body.patterns.start] {
    return ErrorCoverageAtom
  }
  match self.inferred.pattern_constructors[pattern] {
    ErrorInferredPatternConstructor => ErrorCoverageAtom
    StructInferredPatternConstructor(_, _) =>
      if self.pattern_is_irrefutable(pattern) {
        CatchAllCoverageAtom
      } else {
        UnknownCoverageAtom
      }
    VariantInferredPatternConstructor(variant, _) =>
      if self.variant_payload_is_irrefutable(pattern, variant) {
        VariantCoverageAtom(variant)
      } else {
        UnknownCoverageAtom
      }
    NoInferredPatternConstructor =>
      match self.collected.patterns[pattern] {
        HirWildcardPattern(_) | HirBindingPattern(_, _) => CatchAllCoverageAtom
        HirLiteralPattern(expression, _) =>
          match self.collected.expressions[expression] {
            HirBoolExpr(value, _) => BoolCoverageAtom(value)
            _ => UnknownCoverageAtom
          }
        _ => UnknownCoverageAtom
      }
  }
}

///|
fn BodyFlowAnalyzer::push_pattern_alternatives(
  self : BodyFlowAnalyzer,
  pattern : PatternId,
) -> Unit {
  self.pattern_tasks.clear()
  self.pattern_tasks.push(pattern)
}

///|
fn BodyFlowAnalyzer::next_coverage_atom(
  self : BodyFlowAnalyzer,
) -> CoverageAtom? {
  while self.pattern_tasks.length() > 0 {
    let pattern = self.pattern_tasks.pop().unwrap()
    match self.collected.patterns[pattern] {
      HirAlternativePattern(first, alternatives, _) => {
        let mut index = alternatives.length
        while index > 0 {
          index -= 1
          self.pattern_tasks.push(
            self.collected.pattern_children[alternatives.start + index],
          )
        }
        self.pattern_tasks.push(first)
      }
      _ => return Some(self.coverage_atom(pattern))
    }
  }
  None
}

///|
fn BodyFlowAnalyzer::variant_span(
  self : BodyFlowAnalyzer,
  declaration : DeclId,
) -> HirSpan {
  let index = semantic_id_local(declaration)
  if index < 0 || index >= self.variant_spans.length() {
    { start: 0, length: 0 }
  } else {
    self.variant_spans[index]
  }
}

///|
fn BodyFlowAnalyzer::enum_variants(
  self : BodyFlowAnalyzer,
  declaration : DeclId,
) -> Array[VariantId] {
  let variants : Array[VariantId] = []
  if semantic_id_module(declaration) == self.collected.module_id {
    let span = self.variant_span(declaration)
    for index in 0..<span.length {
      variants.push(self.collected.variants[span.start + index].id)
    }
  } else {
    match self.imports {
      Some(imports) =>
        for imported in imports.variants_of(declaration) {
          variants.push(imported.variant)
        }
      None => ()
    }
  }
  variants
}

///|
fn BodyFlowAnalyzer::analyze_coverage(
  self : BodyFlowAnalyzer,
  expression : ExprId,
  expected : BodyTypeId,
  arms : HirSpan,
  loop_ : Bool,
  offset : UInt64,
) -> Bool {
  let domain = self.coverage_domain(expected)
  if domain == ErrorCoverageDomain {
    return true
  }
  let domain_variants = match domain {
    EnumCoverageDomain(declaration) => self.enum_variants(declaration)
    _ => []
  }
  let covered_variants = Array::make(domain_variants.length(), false)
  let mut covered_true = false
  let mut covered_false = false
  let mut covered_variant_count = 0
  let mut catch_all = false
  let mut coverage_error = false
  for arm_index in 0..<arms.length {
    let arm_id = self.collected.arm_children[arms.start + arm_index]
    let arm = self.collected.pattern_arms[arm_id]
    self.push_pattern_alternatives(arm.pattern)
    let mut useful = false
    while true {
      match self.next_coverage_atom() {
        None => break
        Some(atom) => {
          let complete = catch_all ||
            (match domain {
              BoolCoverageDomain => covered_true && covered_false
              EnumCoverageDomain(_) =>
                covered_variant_count == domain_variants.length()
              OpenCoverageDomain | ErrorCoverageDomain => false
            })
          if complete {
            continue
          }
          match atom {
            ErrorCoverageAtom => {
              useful = true
              coverage_error = true
            }
            UnknownCoverageAtom => useful = true
            CatchAllCoverageAtom => {
              useful = true
              if arm.guard_condition < 0 {
                catch_all = true
              }
            }
            BoolCoverageAtom(value) =>
              if domain != BoolCoverageDomain {
                useful = true
                coverage_error = true
              } else {
                let already = if value { covered_true } else { covered_false }
                if !already {
                  useful = true
                  if arm.guard_condition < 0 {
                    if value {
                      covered_true = true
                    } else {
                      covered_false = true
                    }
                  }
                }
              }
            VariantCoverageAtom(variant) => {
              let mut variant_slot = -1
              for index, candidate in domain_variants {
                if candidate == variant {
                  variant_slot = index
                  break
                }
              }
              if variant_slot < 0 || variant_slot >= covered_variants.length() {
                useful = true
                coverage_error = true
              } else if !covered_variants[variant_slot] {
                useful = true
                if arm.guard_condition < 0 {
                  covered_variants[variant_slot] = true
                  covered_variant_count += 1
                }
              }
            }
          }
        }
      }
    }
    if !useful {
      self.diagnostics.push(RedundantPatternArm(arm_id, arm.offset))
    }
  }
  if coverage_error {
    return true
  }
  let missing_start = self.missing_cases.length()
  if !catch_all {
    match domain {
      BoolCoverageDomain => {
        if !covered_false {
          self.missing_cases.push(MissingBoolCase(false))
        }
        if !covered_true {
          self.missing_cases.push(MissingBoolCase(true))
        }
      }
      EnumCoverageDomain(_) =>
        for index in 0..<domain_variants.length() {
          if !covered_variants[index] {
            self.missing_cases.push(MissingVariantCase(domain_variants[index]))
          }
        }
      OpenCoverageDomain => self.missing_cases.push(MissingCatchAllCase)
      ErrorCoverageDomain => ()
    }
  }
  let missing = {
    start: missing_start,
    length: self.missing_cases.length() - missing_start,
  }
  if missing.length > 0 {
    if loop_ {
      self.diagnostics.push(
        NonExhaustiveFunctionalLoop(expression, missing, offset),
      )
    } else {
      self.diagnostics.push(NonExhaustiveMatch(expression, missing, offset))
    }
    false
  } else {
    true
  }
}

///|
fn block_item_offset(item : HirBlockItem) -> UInt64 {
  match item {
    HirLetItem(_, _, _, _, offset) | HirExpressionItem(_, offset) => offset
  }
}

///|
fn BodyFlowAnalyzer::block_flow(
  self : BodyFlowAnalyzer,
  block : BlockId,
) -> BodyFlowSummary {
  let block_slot = block - self.body.blocks.start
  if self.block_done[block_slot] {
    return self.block_flows[block_slot]
  }
  let block_info = self.collected.blocks[block]
  let mut summary = flow(flow_falls_through)
  for item_index in 0..<block_info.items.length {
    let item = self.collected.block_items[block_info.items.start + item_index]
    if !summary.may_fall_through() {
      self.diagnostics.push(
        UnreachableBlockItem(block, item_index, block_item_offset(item)),
      )
      continue
    }
    let item_flow = match item {
      HirLetItem(_, _, _, value, _) | HirExpressionItem(value, _) =>
        self.expression_flow(value)
    }
    summary = flow_sequence(summary, item_flow)
  }
  self.block_flows[block_slot] = summary
  self.block_done[block_slot] = true
  summary
}

///|
fn BodyFlowAnalyzer::arm_flow(
  self : BodyFlowAnalyzer,
  arm_id : PatternArmId,
) -> BodyFlowSummary {
  let arm = self.collected.pattern_arms[arm_id]
  let body = self.expression_flow(arm.body)
  let result = if arm.guard_condition < 0 {
    body
  } else {
    flow_sequence(self.expression_flow(arm.guard_condition), body)
  }
  self.arm_flows[arm_id - self.body.pattern_arms.start] = result
  result
}

///|
fn BodyFlowAnalyzer::match_flow(
  self : BodyFlowAnalyzer,
  expression : ExprId,
  scrutinee : ExprId,
  arms : HirSpan,
  offset : UInt64,
) -> BodyFlowSummary {
  let exhaustive = self.analyze_coverage(
    expression,
    self.inferred.expression_types[scrutinee],
    arms,
    false,
    offset,
  )
  let mut branches = flow(0)
  for index in 0..<arms.length {
    branches = flow_union(
      branches,
      self.arm_flow(self.collected.arm_children[arms.start + index]),
    )
  }
  if !exhaustive || arms.length == 0 {
    branches = flow_union(branches, flow(flow_diverges))
  }
  flow_sequence(self.expression_flow(scrutinee), branches)
}

///|
fn BodyFlowAnalyzer::while_flow(
  self : BodyFlowAnalyzer,
  expression : ExprId,
  initial : ExprId,
  arms : HirSpan,
  offset : UInt64,
) -> BodyFlowSummary {
  let _ = self.analyze_coverage(
    expression,
    self.inferred.expression_types[initial],
    arms,
    true,
    offset,
  )
  let mut arm_outcomes = 0
  for index in 0..<arms.length {
    let arm_id = self.collected.arm_children[arms.start + index]
    let arm_summary = self.arm_flow(arm_id)
    if arm_summary.may_fall_through() {
      self.diagnostics.push(
        FunctionalLoopArmFallsThrough(
          arm_id,
          self.collected.pattern_arms[arm_id].offset,
        ),
      )
    }
    arm_outcomes = arm_outcomes | arm_summary.outcomes
  }
  let mut loop_outcomes = arm_outcomes & (flow_returns | flow_diverges)
  if (arm_outcomes & flow_breaks) != 0 {
    loop_outcomes = loop_outcomes | flow_falls_through
  }
  if (arm_outcomes & (flow_continues | flow_falls_through)) != 0 ||
    loop_outcomes == 0 {
    loop_outcomes = loop_outcomes | flow_diverges
  }
  flow_sequence(self.expression_flow(initial), flow(loop_outcomes))
}

///|
fn BodyFlowAnalyzer::analyze_expressions(self : BodyFlowAnalyzer) -> Unit {
  for
    expression in self.body.expressions.start..<(self.body.expressions.start +
    self.body.expressions.length) {
    let summary = match self.collected.expressions[expression] {
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
      | HirLambdaExpr(_, _) => self.terminal_flow(expression)
      HirProductExpr(elements, _) | HirArrayExpr(elements, _) =>
        flow_sequence(
          self.sequence_expression_children(elements),
          self.terminal_flow(expression),
        )
      HirObjectExpr(fields, _) => {
        let mut prefix = flow(flow_falls_through)
        for index in 0..<fields.length {
          prefix = flow_sequence(
            prefix,
            self.expression_flow(
              self.collected.object_fields[fields.start + index].value,
            ),
          )
        }
        flow_sequence(prefix, self.terminal_flow(expression))
      }
      HirConstructExpr(target, fields, _) => {
        let mut prefix = self.expression_flow(target)
        for index in 0..<fields.length {
          prefix = flow_sequence(
            prefix,
            self.expression_flow(
              self.collected.object_fields[fields.start + index].value,
            ),
          )
        }
        flow_sequence(prefix, self.terminal_flow(expression))
      }
      HirBlockExpr(block, _) => self.block_flow(block)
      HirIfExpr(condition, block, alternative, _) => {
        let then_flow = self.block_flow(block)
        let else_flow = if alternative < 0 {
          flow(flow_falls_through)
        } else {
          self.expression_flow(alternative)
        }
        flow_sequence(
          self.expression_flow(condition),
          flow_union(then_flow, else_flow),
        )
      }
      HirMatchExpr(scrutinee, arms, offset) =>
        self.match_flow(expression, scrutinee, arms, offset)
      HirWhileExpr(initial, arms, offset) =>
        self.while_flow(expression, initial, arms, offset)
      HirReturnExpr(value, _) =>
        if value < 0 {
          flow(flow_returns)
        } else {
          flow_sequence(self.expression_flow(value), flow(flow_returns))
        }
      HirBreakExpr(value, _) =>
        flow_sequence(self.expression_flow(value), flow(flow_breaks))
      HirContinueExpr(value, _) =>
        flow_sequence(self.expression_flow(value), flow(flow_continues))
      HirPrefixExpr(_, value, _) =>
        flow_sequence(
          self.expression_flow(value),
          self.terminal_flow(expression),
        )
      HirBinaryExpr(operator, left, right, _) =>
        match operator {
          HirLogicalAnd | HirLogicalOr => {
            let result = self.terminal_flow(expression)
            let evaluate_right = flow_sequence(
              self.expression_flow(right),
              result,
            )
            flow_sequence(
              self.expression_flow(left),
              flow_union(result, evaluate_right),
            )
          }
          _ => {
            let prefix = flow_sequence(
              self.expression_flow(left),
              self.expression_flow(right),
            )
            flow_sequence(prefix, self.terminal_flow(expression))
          }
        }
      HirCallExpr(target, arguments, _) => {
        let prefix = flow_sequence(
          self.expression_flow(target),
          self.sequence_expression_children(arguments),
        )
        flow_sequence(prefix, self.terminal_flow(expression))
      }
      HirFieldExpr(base, _, _)
      | HirQualifiedExpr(base, _, _)
      | HirProductFieldExpr(base, _, _, _) =>
        flow_sequence(
          self.expression_flow(base),
          self.terminal_flow(expression),
        )
      HirIndexExpr(base, index, _) => {
        let prefix = flow_sequence(
          self.expression_flow(base),
          self.expression_flow(index),
        )
        flow_sequence(prefix, self.terminal_flow(expression))
      }
      HirAssignmentExpr(_, value, _) =>
        flow_sequence(
          self.expression_flow(value),
          self.terminal_flow(expression),
        )
      HirIndexSetExpr(base, index, value, _) => {
        let prefix = flow_sequence(
          flow_sequence(self.expression_flow(base), self.expression_flow(index)),
          self.expression_flow(value),
        )
        flow_sequence(prefix, self.terminal_flow(expression))
      }
    }
    self.set_expression_flow(expression, summary)
  }
}

///|
fn body_flow_diagnostic_rank(diagnostic : BodyFlowDiagnostic) -> Int {
  match diagnostic {
    RedundantPatternArm(_, _) => 0
    NonExhaustiveMatch(_, _, _) => 1
    NonExhaustiveFunctionalLoop(_, _, _) => 2
    FunctionalLoopArmFallsThrough(_, _) => 3
    UnreachableBlockItem(_, _, _) => 4
  }
}

///|
fn BodyFlowAnalyzer::finish(self : BodyFlowAnalyzer) -> BodyFlowJobResult {
  self.initialize_pattern_irrefutability()
  self.analyze_expressions()
  let root = match self.body.root {
    ExpressionBodyRoot(expression) => self.expression_flow(expression)
    BlockBodyRoot(block) => self.block_flow(block)
  }
  self.diagnostics.sort_by(fn(left, right) {
    let offset_order = left.offset().compare(right.offset())
    if offset_order != 0 {
      offset_order
    } else {
      body_flow_diagnostic_rank(left) - body_flow_diagnostic_rank(right)
    }
  })
  {
    flow: root,
    expression_flows: self.expression_flows,
    block_flows: self.block_flows,
    arm_flows: self.arm_flows,
    missing_cases: self.missing_cases,
    diagnostics: self.diagnostics,
  }
}

///|
fn flow_variant_spans(collected : CollectedModule) -> Array[HirSpan] {
  if collected.variants.length() == 0 {
    return empty_flow_spans
  }
  let spans = Array::make(collected.declaration_locations.length(), {
    start: 0,
    length: 0,
  })
  for index, variant in collected.variants {
    let declaration_slot = semantic_id_local(variant.declaration)
    if spans[declaration_slot].length == 0 {
      spans[declaration_slot] = { start: index, length: 1 }
    } else {
      spans[declaration_slot] = {
        start: spans[declaration_slot].start,
        length: spans[declaration_slot].length + 1,
      }
    }
  }
  spans
}

///|
fn lambda_flow_body(collected : CollectedModule, lambda : HirLambda) -> HirBody {
  let root = collected.bodies[semantic_id_local(lambda.root_body)]
  {
    id: lambda.root_body,
    declaration: root.declaration,
    kind: root.kind,
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
}

///|
fn analyze_module_flows_internal(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
  imports : ResolvedModuleImports?,
  order : Array[Int],
) -> AnalyzedModuleFlows {
  if collected.module_id != resolved.module_id ||
    collected.module_id != inferred.module_id {
    abort("flow analysis inputs belong to different modules")
  }
  if order.length() != collected.bodies.length() {
    abort("flow analysis order must contain every body")
  }
  let variant_spans = flow_variant_spans(collected)
  let jobs : Array[BodyFlowJobResult?] = Array::make(
    collected.bodies.length(),
    None,
  )
  let pattern_tasks : Array[PatternId] = []
  let seen = Array::make(collected.bodies.length(), false)
  for body_index in order {
    if body_index < 0 || body_index >= collected.bodies.length() {
      abort("flow analysis order contains an invalid body")
    }
    if seen[body_index] {
      abort("flow analysis order contains a duplicate body")
    }
    seen[body_index] = true
    let body = collected.bodies[body_index]
    jobs[body_index] = Some(
      BodyFlowAnalyzer::new(
        collected, resolved, inferred, imports, body, variant_spans, pattern_tasks,
      ).finish(),
    )
  }
  let lambda_jobs : Array[BodyFlowJobResult?] = Array::make(
    collected.lambdas.length(),
    None,
  )
  for index, lambda in collected.lambdas {
    lambda_jobs[index] = Some(
      BodyFlowAnalyzer::new(
        collected,
        resolved,
        inferred,
        imports,
        lambda_flow_body(collected, lambda),
        variant_spans,
        pattern_tasks,
      ).finish(),
    )
  }
  let bodies : Array[AnalyzedBodyFlow] = []
  let lambdas : Array[AnalyzedLambdaFlow] = []
  let expression_flows = Array::make(collected.expressions.length(), flow(0))
  let block_flows = Array::make(collected.blocks.length(), flow(0))
  let arm_flows = Array::make(collected.pattern_arms.length(), flow(0))
  let missing_cases : Array[MissingPatternCase] = []
  let diagnostics : Array[BodyFlowDiagnostic] = []
  for body_index in 0..<collected.bodies.length() {
    let body = collected.bodies[body_index]
    let result = jobs[body_index].unwrap()
    let diagnostic_start = diagnostics.length()
    let missing_start = missing_cases.length()
    for missing in result.missing_cases {
      missing_cases.push(missing)
    }
    for diagnostic in result.diagnostics {
      diagnostics.push(
        match diagnostic {
          NonExhaustiveMatch(expression, missing, offset) =>
            NonExhaustiveMatch(
              expression,
              { start: missing_start + missing.start, length: missing.length },
              offset,
            )
          NonExhaustiveFunctionalLoop(expression, missing, offset) =>
            NonExhaustiveFunctionalLoop(
              expression,
              { start: missing_start + missing.start, length: missing.length },
              offset,
            )
          RedundantPatternArm(arm, offset) => RedundantPatternArm(arm, offset)
          FunctionalLoopArmFallsThrough(arm, offset) =>
            FunctionalLoopArmFallsThrough(arm, offset)
          UnreachableBlockItem(block, index, offset) =>
            UnreachableBlockItem(block, index, offset)
        },
      )
    }
    for index in 0..<body.expressions.length {
      expression_flows[body.expressions.start + index] = result.expression_flows[index]
    }
    for index in 0..<body.blocks.length {
      block_flows[body.blocks.start + index] = result.block_flows[index]
    }
    for index in 0..<body.pattern_arms.length {
      arm_flows[body.pattern_arms.start + index] = result.arm_flows[index]
    }
    bodies.push({
      body: body.id,
      flow: result.flow,
      diagnostics: {
        start: diagnostic_start,
        length: diagnostics.length() - diagnostic_start,
      },
    })
  }
  for lambda_index, lambda in collected.lambdas {
    let result = lambda_jobs[lambda_index].unwrap()
    let diagnostic_start = diagnostics.length()
    let missing_start = missing_cases.length()
    for missing in result.missing_cases {
      missing_cases.push(missing)
    }
    for diagnostic in result.diagnostics {
      diagnostics.push(
        match diagnostic {
          NonExhaustiveMatch(expression, missing, offset) =>
            NonExhaustiveMatch(
              expression,
              { start: missing_start + missing.start, length: missing.length },
              offset,
            )
          NonExhaustiveFunctionalLoop(expression, missing, offset) =>
            NonExhaustiveFunctionalLoop(
              expression,
              { start: missing_start + missing.start, length: missing.length },
              offset,
            )
          RedundantPatternArm(arm, offset) => RedundantPatternArm(arm, offset)
          FunctionalLoopArmFallsThrough(arm, offset) =>
            FunctionalLoopArmFallsThrough(arm, offset)
          UnreachableBlockItem(block, index, offset) =>
            UnreachableBlockItem(block, index, offset)
        },
      )
    }
    for index in 0..<lambda.body.expressions.length {
      expression_flows[lambda.body.expressions.start + index] = result.expression_flows[index]
    }
    for index in 0..<lambda.body.blocks.length {
      block_flows[lambda.body.blocks.start + index] = result.block_flows[index]
    }
    for index in 0..<lambda.body.pattern_arms.length {
      arm_flows[lambda.body.pattern_arms.start + index] = result.arm_flows[index]
    }
    lambdas.push({
      lambda: lambda.id,
      flow: result.flow,
      diagnostics: {
        start: diagnostic_start,
        length: diagnostics.length() - diagnostic_start,
      },
    })
  }
  {
    module_id: collected.module_id,
    bodies,
    lambdas,
    expression_flows,
    block_flows,
    arm_flows,
    missing_cases,
    diagnostics,
  }
}

///|
fn analyze_module_flows_in_order(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
  order : Array[Int],
) -> AnalyzedModuleFlows {
  analyze_module_flows_internal(collected, resolved, inferred, None, order)
}

///|
pub fn analyze_module_flows(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
) -> AnalyzedModuleFlows {
  let order : Array[Int] = []
  for index in 0..<collected.bodies.length() {
    order.push(index)
  }
  analyze_module_flows_in_order(collected, resolved, inferred, order)
}

///|
fn analyze_module_flows_with_imports(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
  imports : ResolvedModuleImports,
) -> AnalyzedModuleFlows {
  guard imports.module_id == collected.module_id else {
    abort("flow import scope belongs to another module")
  }
  let order : Array[Int] = []
  for index in 0..<collected.bodies.length() {
    order.push(index)
  }
  analyze_module_flows_internal(
    collected,
    resolved,
    inferred,
    Some(imports),
    order,
  )
}
