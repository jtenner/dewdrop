///|
let name_expect_value = 0

///|
let name_expect_qualified_root = 1

///|
let name_expect_call_target = 2

///|
let name_task_visit_expression = 0

///|
let name_task_visit_block_items = 1

///|
let name_task_bind_let = 2

///|
let name_task_exit_scope = 3

///|
let name_task_visit_arm_list = 4

///|
let name_task_visit_arm = 5

///|
let name_task_enter_control = 6

///|
let name_task_exit_control = 7

///|
priv struct BodyNameJobResult {
  locals : Array[BodyLocal]
  controls : Array[BodyControl]
  expression_references : Array[BodyNameReference]
  pattern_references : Array[BodyPatternReference]
  parameter_span : HirSpan
  parameter_locals : Array[LocalId]
  block_item_locals : Array[LocalId]
  transfer_targets : Array[ControlId]
  expression_controls : Array[ControlId]
  diagnostics : Array[BodyResolutionDiagnostic]
}

///|
priv struct BodyNameResolver {
  collected : CollectedModule
  imports : ModuleImportScope?
  body : HirBody
  variant_names : Map[NameId, Bool]
  locals : Array[BodyLocal]
  controls : Array[BodyControl]
  expression_references : Array[BodyNameReference]
  pattern_references : Array[BodyPatternReference]
  parameter_span : HirSpan
  parameter_locals : Array[LocalId]
  block_item_locals : Array[LocalId]
  transfer_targets : Array[ControlId]
  expression_controls : Array[ControlId]
  diagnostics : Array[BodyResolutionDiagnostic]
  current_locals : Map[NameId, LocalId]
  scope_markers : Array[Int]
  scope_names : Array[NameId]
  scope_previous : Array[LocalId]
  control_stack : Array[ControlId]
  task_kinds : Array[Int]
  task_first : Array[Int]
  task_second : Array[Int]
  pattern_stack : Array[PatternId]
  pattern_contexts : Array[Bool]
  binding_names : Array[NameId]
  binding_patterns : Array[PatternId]
  binding_offsets : Array[UInt64]
  binding_first_lookup : Map[NameId, Int]
  canonical_names : Array[NameId]
  canonical_locals : Array[LocalId]
  canonical_offsets : Array[UInt64]
  canonical_lookup : Map[NameId, Int]
  alternative_seen : Array[Bool]
  pattern_literal_expressions : Array[ExprId]
}

///|
fn BodyNameResolver::new(
  collected : CollectedModule,
  imports : ModuleImportScope?,
  body : HirBody,
  variant_names : Map[NameId, Bool],
) -> BodyNameResolver {
  let parameter_span = collected.parameters_of(body.declaration)
  {
    collected,
    imports,
    body,
    variant_names,
    locals: [],
    controls: [],
    expression_references: Array::make(body.expressions.length, NoNameReference),
    pattern_references: Array::make(body.patterns.length, NoPatternReference),
    parameter_span,
    parameter_locals: Array::make(parameter_span.length, -1),
    block_item_locals: Array::make(body.block_items.length, -1),
    transfer_targets: Array::make(body.expressions.length, -1),
    expression_controls: Array::make(body.expressions.length, -1),
    diagnostics: [],
    current_locals: Map::default(),
    scope_markers: [],
    scope_names: [],
    scope_previous: [],
    control_stack: [],
    task_kinds: [],
    task_first: [],
    task_second: [],
    pattern_stack: [],
    pattern_contexts: [],
    binding_names: [],
    binding_patterns: [],
    binding_offsets: [],
    binding_first_lookup: Map::default(),
    canonical_names: [],
    canonical_locals: [],
    canonical_offsets: [],
    canonical_lookup: Map::default(),
    alternative_seen: [],
    pattern_literal_expressions: [],
  }
}

///|
fn BodyNameResolver::declaration_visible(
  self : BodyNameResolver,
  declaration : DeclId,
) -> Bool {
  self.collected.declaration_is_test_only(self.body.declaration) ||
  !self.collected.declaration_is_test_only(declaration)
}

///|
fn BodyNameResolver::module_value_visible(
  self : BodyNameResolver,
  name : NameId,
) -> Bool {
  match self.collected.value_bindings.get(name) {
    Some(binding) => {
      let mut cursor = binding.head
      while cursor >= 0 {
        let candidate = self.collected.value_binding_candidates[cursor]
        if self.declaration_visible(candidate.declaration) {
          return true
        }
        cursor = candidate.next
      }
      false
    }
    None => false
  }
}

///|
fn BodyNameResolver::expression_index(
  self : BodyNameResolver,
  expression : ExprId,
) -> Int {
  expression - self.body.expressions.start
}

///|
fn BodyNameResolver::pattern_index(
  self : BodyNameResolver,
  pattern : PatternId,
) -> Int {
  pattern - self.body.patterns.start
}

///|
fn BodyNameResolver::block_item_index(
  self : BodyNameResolver,
  item : Int,
) -> Int {
  item - self.body.block_items.start
}

///|
fn BodyNameResolver::diagnose(
  self : BodyNameResolver,
  diagnostic : BodyResolutionDiagnostic,
) -> Unit {
  self.diagnostics.push(diagnostic)
}

///|
fn BodyNameResolver::push_task(
  self : BodyNameResolver,
  kind : Int,
  first : Int,
  second : Int,
) -> Unit {
  self.task_kinds.push(kind)
  self.task_first.push(first)
  self.task_second.push(second)
}

///|
fn BodyNameResolver::enter_scope(self : BodyNameResolver) -> Unit {
  self.scope_markers.push(self.scope_names.length())
}

///|
fn BodyNameResolver::bind_existing_local(
  self : BodyNameResolver,
  name : NameId,
  local_id : LocalId,
) -> Unit {
  let previous = self.current_locals.get(name).unwrap_or(-1)
  self.scope_names.push(name)
  self.scope_previous.push(previous)
  self.current_locals[name] = local_id
}

///|
fn BodyNameResolver::exit_scope(self : BodyNameResolver) -> Unit {
  let start = self.scope_markers.pop().unwrap()
  while self.scope_names.length() > start {
    let name = self.scope_names.pop().unwrap()
    let previous = self.scope_previous.pop().unwrap()
    self.current_locals[name] = previous
  }
}

///|
fn BodyNameResolver::allocate_local(
  self : BodyNameResolver,
  name : NameId,
  kind : BodyLocalKind,
  mutable_ : Bool,
  source : Int,
  offset : UInt64,
) -> LocalId {
  let id = self.locals.length()
  self.locals.push({ id, name, kind, mutable_, source, offset })
  id
}

///|
fn BodyNameResolver::bind_parameters(self : BodyNameResolver) -> Unit {
  for local_index in 0..<self.parameter_span.length {
    let parameter_index = self.parameter_span.start + local_index
    let parameter = self.collected.parameters[parameter_index]
    let local_id = self.allocate_local(
      parameter.name,
      ParameterLocal,
      false,
      parameter_index,
      parameter.offset,
    )
    self.parameter_locals[local_index] = local_id
    self.bind_existing_local(parameter.name, local_id)
  }
}

///|
fn BodyNameResolver::set_expression_reference(
  self : BodyNameResolver,
  expression : ExprId,
  reference : BodyNameReference,
) -> Unit {
  self.expression_references[self.expression_index(expression)] = reference
}

///|
fn BodyNameResolver::set_pattern_reference(
  self : BodyNameResolver,
  pattern : PatternId,
  reference : BodyPatternReference,
) -> Unit {
  self.pattern_references[self.pattern_index(pattern)] = reference
}

///|
fn BodyNameResolver::resolve_expression_name(
  self : BodyNameResolver,
  expression : ExprId,
  name : NameId,
  offset : UInt64,
  expectation : Int,
) -> Unit {
  let local_id = self.current_locals.get(name).unwrap_or(-1)
  if local_id >= 0 {
    self.set_expression_reference(expression, LocalNameReference(local_id))
    return
  }
  let spelling = self.collected.name(name)
  if expectation == name_expect_qualified_root {
    match self.collected.type_bindings.get(name) {
      Some(declaration) if self.declaration_visible(declaration) => {
        self.set_expression_reference(
          expression,
          ModuleTypeNameReference(declaration),
        )
        return
      }
      _ => ()
    }
    match self.collected.trait_bindings.get(name) {
      Some(declaration) if self.declaration_visible(declaration) => {
        self.set_expression_reference(
          expression,
          ModuleTraitNameReference(declaration),
        )
        return
      }
      _ => ()
    }
    if self.module_value_visible(name) {
      self.set_expression_reference(expression, ModuleValueNameReference(name))
      return
    }
    match primitive_type_from_name(spelling) {
      Some(primitive) => {
        self.set_expression_reference(
          expression,
          PrimitiveTypeNameReference(primitive),
        )
        return
      }
      None => ()
    }
    match self.imports {
      Some(imports) => {
        match imports.lookup_type(spelling) {
          Some(binding) => {
            self.set_expression_reference(
              expression,
              ModuleTypeNameReference(binding.declaration),
            )
            return
          }
          None => ()
        }
        match imports.lookup_trait(spelling) {
          Some(binding) => {
            self.set_expression_reference(
              expression,
              ModuleTraitNameReference(binding.declaration),
            )
            return
          }
          None => ()
        }
        match imports.value_bindings.get(spelling) {
          Some(binding) if !binding.ambiguous => {
            self.set_expression_reference(
              expression,
              ImportedValueNameReference(binding.head),
            )
            return
          }
          Some(_) => {
            self.diagnose(
              AmbiguousImportedQualifiedRoot(name, expression, offset),
            )
            self.set_expression_reference(expression, ErrorNameReference)
            return
          }
          None => ()
        }
        if imports.type_is_ambiguous(spelling) ||
          imports.trait_is_ambiguous(spelling) {
          self.diagnose(
            AmbiguousImportedQualifiedRoot(name, expression, offset),
          )
          self.set_expression_reference(expression, ErrorNameReference)
          return
        }
      }
      None => ()
    }
    self.diagnose(UnknownQualifiedRoot(name, expression, offset))
    self.set_expression_reference(expression, ErrorNameReference)
    return
  }
  if self.module_value_visible(name) {
    self.set_expression_reference(expression, ModuleValueNameReference(name))
    return
  }
  match self.imports {
    Some(imports) =>
      match imports.value_bindings.get(spelling) {
        Some(binding) if !binding.ambiguous => {
          self.set_expression_reference(
            expression,
            ImportedValueNameReference(binding.head),
          )
          return
        }
        Some(_) => {
          self.diagnose(AmbiguousImportedValueName(name, expression, offset))
          self.set_expression_reference(expression, ErrorNameReference)
          return
        }
        None => ()
      }
    None => ()
  }
  if expectation == name_expect_call_target {
    match self.collected.type_bindings.get(name) {
      Some(declaration) if self.declaration_visible(declaration) => {
        self.set_expression_reference(
          expression,
          ModuleTypeNameReference(declaration),
        )
        return
      }
      _ => ()
    }
    match self.collected.trait_bindings.get(name) {
      Some(declaration) if self.declaration_visible(declaration) => {
        self.set_expression_reference(
          expression,
          ModuleTraitNameReference(declaration),
        )
        return
      }
      _ => ()
    }
    match self.imports {
      Some(imports) => {
        match imports.lookup_type(spelling) {
          Some(binding) => {
            self.set_expression_reference(
              expression,
              ModuleTypeNameReference(binding.declaration),
            )
            return
          }
          None => ()
        }
        match imports.lookup_trait(spelling) {
          Some(binding) => {
            self.set_expression_reference(
              expression,
              ModuleTraitNameReference(binding.declaration),
            )
            return
          }
          None => ()
        }
      }
      None => ()
    }
    if self.variant_names.contains(name) {
      self.set_expression_reference(expression, VariantNameReference(name))
      return
    }
  } else if self.variant_names.contains(name) {
    self.set_expression_reference(expression, VariantNameReference(name))
    return
  }
  self.diagnose(UnknownValueName(name, expression, offset))
  self.set_expression_reference(expression, ErrorNameReference)
}

///|
fn BodyNameResolver::known_pattern_constructor(
  self : BodyNameResolver,
  name : NameId,
) -> Bool {
  if self.collected.type_bindings.contains(name) ||
    self.collected.trait_bindings.contains(name) ||
    self.variant_names.contains(name) {
    return true
  }
  let spelling = self.collected.name(name)
  match self.imports {
    Some(imports) =>
      imports.lookup_type(spelling) is Some(_) ||
      imports.lookup_trait(spelling) is Some(_)
    None => false
  }
}

///|
fn BodyNameResolver::resolve_pattern_constructor(
  self : BodyNameResolver,
  pattern : PatternId,
  name : NameId,
  offset : UInt64,
) -> Unit {
  match self.collected.type_bindings.get(name) {
    Some(declaration) => {
      self.set_pattern_reference(pattern, PatternTypeReference(declaration))
      return
    }
    None => ()
  }
  match self.collected.trait_bindings.get(name) {
    Some(declaration) => {
      self.set_pattern_reference(pattern, PatternTraitReference(declaration))
      return
    }
    None => ()
  }
  let spelling = self.collected.name(name)
  match self.imports {
    Some(imports) => {
      match imports.lookup_type(spelling) {
        Some(binding) => {
          self.set_pattern_reference(
            pattern,
            PatternTypeReference(binding.declaration),
          )
          return
        }
        None => ()
      }
      match imports.lookup_trait(spelling) {
        Some(binding) => {
          self.set_pattern_reference(
            pattern,
            PatternTraitReference(binding.declaration),
          )
          return
        }
        None => ()
      }
    }
    None => ()
  }
  if self.variant_names.contains(name) {
    self.set_pattern_reference(pattern, PatternVariantReference(name))
  } else {
    self.diagnose(UnknownPatternConstructor(name, pattern, offset))
    self.set_pattern_reference(pattern, ErrorPatternReference)
  }
}

///|
fn BodyNameResolver::collect_pattern_alternative(
  self : BodyNameResolver,
  root : PatternId,
) -> Unit {
  self.pattern_stack.clear()
  self.pattern_contexts.clear()
  self.binding_names.clear()
  self.binding_patterns.clear()
  self.binding_offsets.clear()
  self.pattern_stack.push(root)
  self.pattern_contexts.push(true)
  while self.pattern_stack.length() > 0 {
    let pattern = self.pattern_stack.pop().unwrap()
    let binding_context = self.pattern_contexts.pop().unwrap()
    match self.collected.patterns[pattern] {
      HirWildcardPattern(_) | HirRestPattern(_) => ()
      HirBindingPattern(name, offset) =>
        if !binding_context || self.known_pattern_constructor(name) {
          self.resolve_pattern_constructor(pattern, name, offset)
        } else {
          self.binding_names.push(name)
          self.binding_patterns.push(pattern)
          self.binding_offsets.push(offset)
        }
      HirLiteralPattern(expression, _) =>
        self.pattern_literal_expressions.push(expression)
      HirQualifiedPattern(base, property, _) => {
        self.set_pattern_reference(pattern, PatternQualifiedReference(property))
        self.pattern_stack.push(base)
        self.pattern_contexts.push(false)
      }
      HirTuplePattern(base, arguments, _) => {
        let mut index = arguments.length
        while index > 0 {
          index -= 1
          self.pattern_stack.push(
            self.collected.pattern_children[arguments.start + index],
          )
          self.pattern_contexts.push(true)
        }
        self.pattern_stack.push(base)
        self.pattern_contexts.push(false)
      }
      HirStructPattern(base, fields, _, _, _) => {
        let mut index = fields.length
        while index > 0 {
          index -= 1
          self.pattern_stack.push(
            self.collected.pattern_fields[fields.start + index].pattern,
          )
          self.pattern_contexts.push(true)
        }
        self.pattern_stack.push(base)
        self.pattern_contexts.push(false)
      }
      HirAlternativePattern(first, remaining, _) => {
        let mut index = remaining.length
        while index > 0 {
          index -= 1
          self.pattern_stack.push(
            self.collected.pattern_children[remaining.start + index],
          )
          self.pattern_contexts.push(true)
        }
        self.pattern_stack.push(first)
        self.pattern_contexts.push(true)
      }
    }
  }
}

///|
fn BodyNameResolver::prepare_binding_lookup(self : BodyNameResolver) -> Unit {
  self.binding_first_lookup.clear()
  if self.binding_names.length() > 8 {
    for index, name in self.binding_names {
      if !self.binding_first_lookup.contains(name) {
        self.binding_first_lookup[name] = index
      }
    }
  }
}

///|
fn BodyNameResolver::binding_first_index(
  self : BodyNameResolver,
  before : Int,
  name : NameId,
) -> Int {
  if self.binding_names.length() > 8 {
    let first = self.binding_first_lookup.get(name).unwrap_or(-1)
    if first < before {
      first
    } else {
      -1
    }
  } else {
    for index in 0..<before {
      if self.binding_names[index] == name {
        return index
      }
    }
    -1
  }
}

///|
fn BodyNameResolver::rebuild_canonical_lookup(self : BodyNameResolver) -> Unit {
  self.canonical_lookup.clear()
  if self.canonical_names.length() > 8 {
    for index, name in self.canonical_names {
      self.canonical_lookup[name] = index
    }
  }
}

///|
fn BodyNameResolver::canonical_index(
  self : BodyNameResolver,
  name : NameId,
) -> Int {
  if self.canonical_names.length() > 8 {
    self.canonical_lookup.get(name).unwrap_or(-1)
  } else {
    for index in 0..<self.canonical_names.length() {
      if self.canonical_names[index] == name {
        return index
      }
    }
    -1
  }
}

///|
fn BodyNameResolver::install_canonical_pattern_bindings(
  self : BodyNameResolver,
) -> Unit {
  self.prepare_binding_lookup()
  for index in 0..<self.binding_names.length() {
    let name = self.binding_names[index]
    let first = self.binding_first_index(index, name)
    if first >= 0 {
      self.diagnose(
        DuplicatePatternBinding(
          name,
          self.binding_offsets[first],
          self.binding_offsets[index],
        ),
      )
      self.set_pattern_reference(
        self.binding_patterns[index],
        ErrorPatternReference,
      )
      continue
    }
    let local_id = self.allocate_local(
      name,
      PatternLocal,
      false,
      self.binding_patterns[index],
      self.binding_offsets[index],
    )
    self.canonical_names.push(name)
    self.canonical_locals.push(local_id)
    self.canonical_offsets.push(self.binding_offsets[index])
    self.set_pattern_reference(
      self.binding_patterns[index],
      PatternBindingReference(local_id),
    )
  }
  self.rebuild_canonical_lookup()
}

///|
fn BodyNameResolver::install_alternative_pattern_bindings(
  self : BodyNameResolver,
  alternative : PatternId,
) -> Unit {
  self.prepare_binding_lookup()
  self.alternative_seen.clear()
  for _ in 0..<self.canonical_names.length() {
    self.alternative_seen.push(false)
  }
  for index in 0..<self.binding_names.length() {
    let name = self.binding_names[index]
    let first = self.binding_first_index(index, name)
    if first >= 0 {
      self.diagnose(
        DuplicatePatternBinding(
          name,
          self.binding_offsets[first],
          self.binding_offsets[index],
        ),
      )
      self.set_pattern_reference(
        self.binding_patterns[index],
        ErrorPatternReference,
      )
      continue
    }
    let canonical = self.canonical_index(name)
    if canonical < 0 {
      self.diagnose(
        AlternativeExtraBinding(name, alternative, self.binding_offsets[index]),
      )
      self.set_pattern_reference(
        self.binding_patterns[index],
        ErrorPatternReference,
      )
    } else {
      self.alternative_seen[canonical] = true
      self.set_pattern_reference(
        self.binding_patterns[index],
        PatternBindingReference(self.canonical_locals[canonical]),
      )
    }
  }
  for index in 0..<self.canonical_names.length() {
    if !self.alternative_seen[index] {
      self.diagnose(
        AlternativeMissingBinding(
          self.canonical_names[index],
          alternative,
          self.collected.patterns[alternative].offset(),
        ),
      )
    }
  }
}

///|
fn BodyNameResolver::resolve_arm_pattern(
  self : BodyNameResolver,
  root : PatternId,
) -> Unit {
  self.canonical_names.clear()
  self.canonical_locals.clear()
  self.canonical_offsets.clear()
  self.pattern_literal_expressions.clear()
  match self.collected.patterns[root] {
    HirAlternativePattern(first, remaining, _) => {
      self.collect_pattern_alternative(first)
      self.install_canonical_pattern_bindings()
      for index in 0..<remaining.length {
        let alternative = self.collected.pattern_children[remaining.start +
          index]
        self.collect_pattern_alternative(alternative)
        self.install_alternative_pattern_bindings(alternative)
      }
    }
    _ => {
      self.collect_pattern_alternative(root)
      self.install_canonical_pattern_bindings()
    }
  }
  for index in 0..<self.canonical_names.length() {
    self.bind_existing_local(
      self.canonical_names[index],
      self.canonical_locals[index],
    )
  }
}

///|
fn BodyResolutionDiagnostic::rank(self : BodyResolutionDiagnostic) -> Int {
  match self {
    UnknownValueName(_, _, _) => 0
    AmbiguousImportedValueName(_, _, _) => 1
    AmbiguousImportedQualifiedRoot(_, _, _) => 2
    UnknownQualifiedRoot(_, _, _) => 3
    UnknownImportAlias(_, _, _) => 4
    UnknownPatternConstructor(_, _, _) => 5
    DuplicatePatternBinding(_, _, _) => 6
    AlternativeMissingBinding(_, _, _) => 7
    AlternativeExtraBinding(_, _, _) => 8
    BreakOutsideLoop(_, _) => 9
    ContinueOutsideLoop(_, _) => 10
  }
}

///|
fn BodyNameResolver::sort_diagnostics(self : BodyNameResolver) -> Unit {
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
fn BodyNameResolver::schedule_expression_children(
  self : BodyNameResolver,
  expression : ExprId,
  expectation : Int,
) -> Unit {
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
    | HirBytesExpr(_, _) => ()
    HirNameExpr(name, offset) =>
      self.resolve_expression_name(expression, name, offset, expectation)
    HirImportAliasExpr(name, offset) =>
      match self.imports {
        Some(imports) =>
          match imports.lookup_alias(self.collected.name(name)) {
            Some(interface_index) =>
              self.set_expression_reference(
                expression,
                ImportedModuleNameReference(interface_index),
              )
            None => {
              self.diagnose(UnknownImportAlias(name, expression, offset))
              self.set_expression_reference(expression, ErrorNameReference)
            }
          }
        None => {
          self.diagnose(UnknownImportAlias(name, expression, offset))
          self.set_expression_reference(expression, ErrorNameReference)
        }
      }
    HirObjectExpr(fields, _) => {
      let mut index = fields.length
      while index > 0 {
        index -= 1
        self.push_task(
          name_task_visit_expression,
          self.collected.object_fields[fields.start + index].value,
          name_expect_value,
        )
      }
    }
    HirConstructExpr(target, fields, _) => {
      let mut index = fields.length
      while index > 0 {
        index -= 1
        self.push_task(
          name_task_visit_expression,
          self.collected.object_fields[fields.start + index].value,
          name_expect_value,
        )
      }
      self.push_task(
        name_task_visit_expression, target, name_expect_qualified_root,
      )
    }
    HirBlockExpr(block, _) => self.schedule_block(block)
    HirIfExpr(condition, block, alternative, _) => {
      if alternative >= 0 {
        self.push_task(
          name_task_visit_expression, alternative, name_expect_value,
        )
      }
      self.schedule_block(block)
      self.push_task(name_task_visit_expression, condition, name_expect_value)
    }
    HirMatchExpr(scrutinee, arms, _) => {
      self.push_task(name_task_visit_arm_list, arms.start, arms.length)
      self.push_task(name_task_visit_expression, scrutinee, name_expect_value)
    }
    HirWhileExpr(initial, arms, offset) => {
      let control = self.controls.length()
      self.controls.push({
        id: control,
        kind: FunctionalWhileControl,
        expression,
        offset,
      })
      self.expression_controls[self.expression_index(expression)] = control
      self.push_task(name_task_exit_control, control, 0)
      self.push_task(name_task_visit_arm_list, arms.start, arms.length)
      self.push_task(name_task_enter_control, control, 0)
      self.push_task(name_task_visit_expression, initial, name_expect_value)
    }
    HirBreakExpr(value, offset) => {
      let target = if self.control_stack.length() > 0 {
        self.control_stack[self.control_stack.length() - 1]
      } else {
        self.diagnose(BreakOutsideLoop(expression, offset))
        -1
      }
      self.transfer_targets[self.expression_index(expression)] = target
      self.push_task(name_task_visit_expression, value, name_expect_value)
    }
    HirContinueExpr(value, offset) => {
      let target = if self.control_stack.length() > 0 {
        self.control_stack[self.control_stack.length() - 1]
      } else {
        self.diagnose(ContinueOutsideLoop(expression, offset))
        -1
      }
      self.transfer_targets[self.expression_index(expression)] = target
      self.push_task(name_task_visit_expression, value, name_expect_value)
    }
    HirPrefixExpr(_, value, _) | HirFieldExpr(value, _, _) =>
      self.push_task(name_task_visit_expression, value, name_expect_value)
    HirQualifiedExpr(value, _, _) =>
      self.push_task(
        name_task_visit_expression, value, name_expect_qualified_root,
      )
    HirBinaryExpr(_, left, right, _) | HirIndexExpr(left, right, _) => {
      self.push_task(name_task_visit_expression, right, name_expect_value)
      self.push_task(name_task_visit_expression, left, name_expect_value)
    }
    HirIndexSetExpr(base, index, value, _) => {
      self.push_task(name_task_visit_expression, value, name_expect_value)
      self.push_task(name_task_visit_expression, index, name_expect_value)
      self.push_task(name_task_visit_expression, base, name_expect_value)
    }
    HirCallExpr(target, arguments, _) => {
      let mut index = arguments.length
      while index > 0 {
        index -= 1
        self.push_task(
          name_task_visit_expression,
          self.collected.expression_children[arguments.start + index],
          name_expect_value,
        )
      }
      self.push_task(
        name_task_visit_expression, target, name_expect_call_target,
      )
    }
  }
}

///|
fn BodyNameResolver::schedule_block(
  self : BodyNameResolver,
  block : BlockId,
) -> Unit {
  let items = self.collected.blocks[block].items
  self.enter_scope()
  self.push_task(name_task_exit_scope, 0, 0)
  self.push_task(name_task_visit_block_items, items.start, items.length)
}

///|
fn BodyNameResolver::visit_block_items(
  self : BodyNameResolver,
  item : Int,
  remaining : Int,
) -> Unit {
  if remaining <= 0 {
    return
  }
  self.push_task(name_task_visit_block_items, item + 1, remaining - 1)
  match self.collected.block_items[item] {
    HirLetItem(_, _, _, value, _) => {
      self.push_task(name_task_bind_let, item, 0)
      self.push_task(name_task_visit_expression, value, name_expect_value)
    }
    HirReturnItem(value, _) =>
      if value >= 0 {
        self.push_task(name_task_visit_expression, value, name_expect_value)
      }
    HirExpressionItem(value, _) =>
      self.push_task(name_task_visit_expression, value, name_expect_value)
  }
}

///|
fn BodyNameResolver::bind_let(self : BodyNameResolver, item : Int) -> Unit {
  match self.collected.block_items[item] {
    HirLetItem(mutable_, name, name_offset, _, _) => {
      let local_id = self.allocate_local(
        name,
        LetLocal,
        mutable_,
        item,
        name_offset,
      )
      self.block_item_locals[self.block_item_index(item)] = local_id
      self.bind_existing_local(name, local_id)
    }
    _ => abort("body name binding task expected a let item")
  }
}

///|
fn BodyNameResolver::visit_arm_list(
  self : BodyNameResolver,
  start : Int,
  remaining : Int,
) -> Unit {
  if remaining <= 0 {
    return
  }
  self.push_task(name_task_visit_arm_list, start + 1, remaining - 1)
  self.push_task(name_task_visit_arm, self.collected.arm_children[start], 0)
}

///|
fn BodyNameResolver::visit_arm(
  self : BodyNameResolver,
  arm_id : PatternArmId,
) -> Unit {
  let arm = self.collected.pattern_arms[arm_id]
  self.enter_scope()
  self.resolve_arm_pattern(arm.pattern)
  self.push_task(name_task_exit_scope, 0, 0)
  self.push_task(name_task_visit_expression, arm.body, name_expect_value)
  if arm.guard_condition >= 0 {
    self.push_task(
      name_task_visit_expression,
      arm.guard_condition,
      name_expect_value,
    )
  }
  let mut index = self.pattern_literal_expressions.length()
  while index > 0 {
    index -= 1
    self.push_task(
      name_task_visit_expression,
      self.pattern_literal_expressions[index],
      name_expect_value,
    )
  }
}

///|
fn BodyNameResolver::run(self : BodyNameResolver) -> BodyNameJobResult {
  self.enter_scope()
  self.bind_parameters()
  match self.body.root {
    ExpressionBodyRoot(expression) =>
      self.push_task(name_task_visit_expression, expression, name_expect_value)
    BlockBodyRoot(block) => self.schedule_block(block)
  }
  while self.task_kinds.length() > 0 {
    let kind = self.task_kinds.pop().unwrap()
    let first = self.task_first.pop().unwrap()
    let second = self.task_second.pop().unwrap()
    match kind {
      0 => self.schedule_expression_children(first, second)
      1 => self.visit_block_items(first, second)
      2 => self.bind_let(first)
      3 => self.exit_scope()
      4 => self.visit_arm_list(first, second)
      5 => self.visit_arm(first)
      6 => self.control_stack.push(first)
      7 => {
        let control = self.control_stack.pop().unwrap()
        guard control == first else { abort("mismatched body control stack") }
      }
      _ => abort("invalid body name-resolution task")
    }
  }
  self.exit_scope()
  guard self.scope_markers.length() == 0 else {
    abort("unclosed body name-resolution scope")
  }
  guard self.control_stack.length() == 0 else {
    abort("unclosed body control scope")
  }
  self.sort_diagnostics()
  {
    locals: self.locals,
    controls: self.controls,
    expression_references: self.expression_references,
    pattern_references: self.pattern_references,
    parameter_span: self.parameter_span,
    parameter_locals: self.parameter_locals,
    block_item_locals: self.block_item_locals,
    transfer_targets: self.transfer_targets,
    expression_controls: self.expression_controls,
    diagnostics: self.diagnostics,
  }
}

///|
fn body_variant_names(collected : CollectedModule) -> Map[NameId, Bool] {
  let names : Map[NameId, Bool] = Map::default()
  for variant in collected.variants {
    names[variant.name] = true
  }
  names
}

///|
fn merge_body_name_jobs(
  collected : CollectedModule,
  jobs : Array[BodyNameJobResult?],
) -> ResolvedModuleNames {
  let bodies : Array[ResolvedBodyNames] = []
  let locals : Array[BodyLocal] = []
  let controls : Array[BodyControl] = []
  let diagnostics : Array[BodyResolutionDiagnostic] = []
  let expression_references = Array::make(
    collected.expressions.length(),
    NoNameReference,
  )
  let pattern_references = Array::make(
    collected.patterns.length(),
    NoPatternReference,
  )
  let parameter_locals = Array::make(collected.parameters.length(), -1)
  let block_item_locals = Array::make(collected.block_items.length(), -1)
  let transfer_targets = Array::make(collected.expressions.length(), -1)
  let expression_controls = Array::make(collected.expressions.length(), -1)
  for body_index, body in collected.bodies {
    let job = jobs[body_index].unwrap()
    let local_start = locals.length()
    for local_info in job.locals {
      locals.push(local_info)
    }
    let control_start = controls.length()
    for control in job.controls {
      controls.push(control)
    }
    let diagnostic_start = diagnostics.length()
    for diagnostic in job.diagnostics {
      diagnostics.push(diagnostic)
    }
    for index in 0..<body.expressions.length {
      let destination = body.expressions.start + index
      expression_references[destination] = job.expression_references[index]
      transfer_targets[destination] = job.transfer_targets[index]
      expression_controls[destination] = job.expression_controls[index]
    }
    for index in 0..<body.patterns.length {
      pattern_references[body.patterns.start + index] = job.pattern_references[index]
    }
    for index in 0..<body.block_items.length {
      block_item_locals[body.block_items.start + index] = job.block_item_locals[index]
    }
    for index in 0..<job.parameter_span.length {
      parameter_locals[job.parameter_span.start + index] = job.parameter_locals[index]
    }
    bodies.push({
      body: body.id,
      locals: { start: local_start, length: job.locals.length() },
      controls: { start: control_start, length: job.controls.length() },
      diagnostics: { start: diagnostic_start, length: job.diagnostics.length() },
    })
  }
  {
    module_id: collected.module_id,
    bodies,
    locals,
    controls,
    expression_references,
    pattern_references,
    parameter_locals,
    block_item_locals,
    transfer_targets,
    expression_controls,
    diagnostics,
  }
}

///|
fn resolve_module_names_with_imports_in_order(
  collected : CollectedModule,
  imports : ModuleImportScope?,
  order : Array[Int],
) -> ResolvedModuleNames {
  guard order.length() == collected.bodies.length() else {
    abort("body name-resolution order has the wrong length")
  }
  let jobs : Array[BodyNameJobResult?] = Array::make(
    collected.bodies.length(),
    None,
  )
  let variant_names = body_variant_names(collected)
  for body_index in order {
    guard body_index >= 0 && body_index < collected.bodies.length() else {
      abort("body name-resolution order contains an invalid body")
    }
    guard jobs[body_index] is None else {
      abort("body name-resolution order contains a duplicate body")
    }
    jobs[body_index] = Some(
      BodyNameResolver::new(
        collected,
        imports,
        collected.bodies[body_index],
        variant_names,
      ).run(),
    )
  }
  merge_body_name_jobs(collected, jobs)
}

///|
fn resolve_module_names_in_order(
  collected : CollectedModule,
  order : Array[Int],
) -> ResolvedModuleNames {
  resolve_module_names_with_imports_in_order(collected, None, order)
}

///|
pub fn resolve_module_names_with_imports(
  collected : CollectedModule,
  imports : ModuleImportScope,
) -> ResolvedModuleNames {
  guard collected.module_id == imports.module_id else {
    abort("name import scope belongs to another module")
  }
  let order : Array[Int] = []
  for index in 0..<collected.bodies.length() {
    order.push(index)
  }
  resolve_module_names_with_imports_in_order(collected, Some(imports), order)
}

///|
/// Resolves lexical locals, module names, pattern bindings, and functional-loop
/// control targets for every executable body. Body jobs are independent and
/// their results are merged in stable BodyId order.
pub fn resolve_module_names(collected : CollectedModule) -> ResolvedModuleNames {
  let order : Array[Int] = []
  for index in 0..<collected.bodies.length() {
    order.push(index)
  }
  resolve_module_names_in_order(collected, order)
}
