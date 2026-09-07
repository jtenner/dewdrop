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
  self.call_scratch.instantiation_method_generics = { start: 0, length: 0, }
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
  self.pattern_constructors[self.pattern_index(pattern)] = if variant {
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
      None => { start: 0, length: 0, }
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
  self.call_scratch.instantiation_method_generics = { start: 0, length: 0, }
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
  body_relative_index(self.collected, self.body, BodyObjectFields, field, 2)
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
    { start: 0, length: 0, }
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
  guard semantic_id_module(declaration) == self.collected.module_id else {
    return -1
  }
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
priv enum SelectedValueVariant {
  SelectedLocalValueVariant(Int)
  SelectedImportedValueVariant(ResolvedImportedVariant)
  NoSelectedValueVariant
}

///|
fn BasicBodyInferencer::select_value_variant(
  self : BasicBodyInferencer,
  name : NameId,
  expected : BodyTypeId,
  expression : ExprId,
  offset : UInt64,
) -> SelectedValueVariant {
  if self.inspect_nominal_type(expected) {
    let declaration = self.call_scratch.nominal_declaration
    if semantic_id_module(declaration) == self.collected.module_id {
      let selected = self.variant_index_in_declaration(declaration, name)
      if selected >= 0 {
        return SelectedLocalValueVariant(selected)
      }
    } else {
      match self.imported_variant_named(declaration, name) {
        Some(variant) => return SelectedImportedValueVariant(variant)
        None => ()
      }
    }
    self.diagnose(UnknownVariantValue(name, expression, offset))
    return NoSelectedValueVariant
  }
  let mut selected = NoSelectedValueVariant
  let mut first = 0UL
  let mut second = 0UL
  let mut count = 0
  for index, variant in self.collected.variants {
    if variant.name == name {
      count += 1
      if count == 1 {
        selected = SelectedLocalValueVariant(index)
        first = variant.id
      } else if count == 2 {
        second = variant.id
      }
    }
  }
  match self.imports {
    Some(imports) =>
      for variant in imports.variants {
        if variant.name == self.collected.name(name) &&
          self.imported_pattern_variant_is_visible(variant.declaration) {
          count += 1
          if count == 1 {
            selected = SelectedImportedValueVariant(variant)
            first = variant.variant
          } else if count == 2 {
            second = variant.variant
          }
        }
      }
    None => ()
  }
  if count == 1 {
    selected
  } else if count == 0 {
    self.diagnose(UnknownVariantValue(name, expression, offset))
    NoSelectedValueVariant
  } else {
    self.diagnose(
      AmbiguousVariantValue(name, expression, first, second, count, offset),
    )
    NoSelectedValueVariant
  }
}

///|
fn BasicBodyInferencer::imported_pattern_variant_is_visible(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Bool {
  match self.imports {
    Some(imports) =>
      for binding in imports.scope.declarations {
        if binding.declaration == declaration {
          return true
        }
      }
    None => ()
  }
  false
}

///|
fn BasicBodyInferencer::select_bare_variant(
  self : BasicBodyInferencer,
  name : NameId,
  expected : BodyTypeId,
  pattern : PatternId,
  offset : UInt64,
) -> VariantId? {
  if self.inspect_nominal_type(expected) {
    let declaration = self.call_scratch.nominal_declaration
    if semantic_id_module(declaration) == self.collected.module_id {
      let selected = self.variant_index_in_declaration(declaration, name)
      if selected >= 0 {
        return Some(self.collected.variants[selected].id)
      }
    } else {
      match self.imported_variant_named(declaration, name) {
        Some(variant) => return Some(variant.variant)
        None => ()
      }
    }
    self.diagnose(UnknownVariantForType(name, declaration, pattern, offset))
    return None
  }
  let mut selected : VariantId? = None
  let mut count = 0
  let mut first = 0UL
  let mut second = 0UL
  for variant in self.collected.variants {
    if variant.name == name {
      count += 1
      if count == 1 {
        selected = Some(variant.id)
        first = variant.id
      } else if count == 2 {
        second = variant.id
      }
    }
  }
  match self.imports {
    Some(imports) =>
      for variant in imports.variants {
        if variant.name == self.collected.name(name) &&
          self.imported_pattern_variant_is_visible(variant.declaration) {
          count += 1
          if count == 1 {
            selected = Some(variant.variant)
            first = variant.variant
          } else if count == 2 {
            second = variant.variant
          }
        }
      }
    None => ()
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
    None
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
  self.pattern_types[self.pattern_index(base)] = expected
  match self.collected.patterns[base] {
    HirBindingPattern(name, _) =>
      match self.names.pattern_references[base] {
        PatternVariantReference(_) =>
          self.select_bare_variant(name, expected, owner_pattern, offset)
        _ => {
          self.diagnose(InvalidPatternConstructor(owner_pattern, offset))
          None
        }
      }
    HirQualifiedPattern(root, property, _) => {
      self.pattern_types[self.pattern_index(root)] = expected
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
        ErrorPatternReference => None
        _ => {
          self.diagnose(InvalidPatternConstructor(owner_pattern, offset))
          None
        }
      }
    }
    HirImportAliasPattern(_, _) => None
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
fn BasicBodyInferencer::infer_product_pattern(
  self : BasicBodyInferencer,
  pattern : PatternId,
  arguments : HirSpan,
  expected : BodyTypeId,
  offset : UInt64,
) -> Unit {
  guard arena_span_is_valid(arguments, self.collected.pattern_children.length()) else {
    abort("ARN-101 product pattern children")
  }
  if arguments.length == 0 {
    self.constrain(
      expected,
      self.primitive(UnitType),
      pattern_type_origin(pattern, offset),
    )
    return
  }
  let mut rest_index = -1
  let mut explicit_count = 0
  for index in 0..<arguments.length {
    let child = self.collected.pattern_children[arguments.start + index]
    if self.collected.patterns[child] is HirRestPattern(_) {
      rest_index = index
    } else {
      explicit_count += 1
    }
  }
  let fields : Array[BodyTypeId] = []
  let term = self.solver.type_term(self.solver.representative_type(expected))
  let mut valid = true
  match term {
    BodyProductType(span) => {
      guard arena_span_is_valid(span, self.solver.type_arguments.length()) else {
        abort("ARN-101 product pattern body fields")
      }
      for index in 0..<span.length {
        fields.push(self.solver.type_arguments[span.start + index])
      }
    }
    BodyResolvedType(type_) =>
      match self.resolved.types[type_] {
        ProductType(span) => {
          guard arena_span_is_valid(span, self.resolved.type_arguments.length()) else {
            abort("ARN-101 product pattern resolved fields")
          }
          for index in 0..<span.length {
            fields.push(
              self.solver.resolved_type(
                self.resolved.type_arguments[span.start + index],
              ),
            )
          }
        }
        _ => valid = false
      }
    BodyVariableType(_) if rest_index < 0 => {
      for _ in 0..<explicit_count {
        fields.push(self.solver.fresh_variable())
      }
      self.constrain(
        expected,
        self.solver.product_type(fields),
        pattern_type_origin(pattern, offset),
      )
    }
    BodyErrorType => valid = false
    _ => valid = false
  }
  if !valid {
    if !(term is BodyErrorType) {
      self.diagnose(InvalidPatternConstructor(pattern, offset))
    }
    self.pattern_constructors[self.pattern_index(pattern)] = ErrorInferredPatternConstructor
  } else if (rest_index < 0 && explicit_count != fields.length()) ||
    (rest_index >= 0 && explicit_count > fields.length()) {
    self.diagnose(
      PatternPayloadArityMismatch(
        pattern,
        fields.length(),
        explicit_count,
        offset,
      ),
    )
    self.pattern_constructors[self.pattern_index(pattern)] = ErrorInferredPatternConstructor
    valid = false
  }
  let mut before = 0
  let mut after = 0
  for index in 0..<arguments.length {
    let child = self.collected.pattern_children[arguments.start + index]
    if self.collected.patterns[child] is HirRestPattern(_) {
      self.pattern_types[self.pattern_index(child)] = self.solver.error_type()
    } else {
      let field = if rest_index < 0 || index < rest_index {
        let result = before
        before += 1
        result
      } else {
        let result = fields.length() - (explicit_count - before) + after
        after += 1
        result
      }
      self.push_pattern_task(
        child,
        if valid && field >= 0 && field < fields.length() {
          fields[field]
        } else {
          self.solver.error_type()
        },
      )
    }
  }
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
      self.pattern_constructors[self.pattern_index(pattern)] = ErrorInferredPatternConstructor
      return
    }
  }
  if self.variant_kind(variant) != Some(TupleVariantDecl) {
    self.diagnose(PatternPayloadKindMismatch(pattern, variant, offset))
    self.pattern_constructors[self.pattern_index(pattern)] = ErrorInferredPatternConstructor
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
        self.pattern_types[self.pattern_index(child)] = self.solver.error_type()
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
      self.pattern_constructors[self.pattern_index(pattern)] = ErrorInferredPatternConstructor
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
  self.pattern_types[self.pattern_index(base)] = expected
  match self.names.pattern_references[base] {
    PatternTypeReference(declaration) => {
      if declaration == standard_nullable_ref_type_declaration() {
        self.diagnose(InvalidPatternConstructor(pattern, offset))
        self.pattern_constructors[self.pattern_index(pattern)] = ErrorInferredPatternConstructor
        return
      }
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
        self.pattern_constructors[self.pattern_index(pattern)] = ErrorInferredPatternConstructor
      }
    }
    _ => {
      let variant = match
        self.select_variant_base(base, expected, pattern, offset) {
        Some(variant) => variant
        None => {
          self.pattern_constructors[self.pattern_index(pattern)] = ErrorInferredPatternConstructor
          return
        }
      }
      if self.variant_kind(variant) != Some(StructVariantDecl) {
        self.diagnose(PatternPayloadKindMismatch(pattern, variant, offset))
        self.pattern_constructors[self.pattern_index(pattern)] = ErrorInferredPatternConstructor
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
      self.pattern_constructors[self.pattern_index(pattern)] = ErrorInferredPatternConstructor
      return
    }
  }
  if self.variant_kind(variant) != Some(UnitVariantDecl) {
    self.diagnose(PatternPayloadKindMismatch(pattern, variant, offset))
    self.pattern_constructors[self.pattern_index(pattern)] = ErrorInferredPatternConstructor
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
    if !self.live_pattern(pattern) {
      continue
    }
    self.pattern_types[self.pattern_index(pattern)] = expected
    match self.collected.patterns[pattern] {
      HirWildcardPattern(_) => ()
      HirRestPattern(_) | HirImportAliasPattern(_, _) =>
        self.pattern_types[self.pattern_index(pattern)] = self.solver.error_type()
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
            self.pattern_types[self.pattern_index(pattern)] = self.solver.error_type()
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
      HirProductPattern(arguments, offset) =>
        self.infer_product_pattern(pattern, arguments, expected, offset)
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
