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
  match self.names.expression_references[target] {
    ModuleTypeNameReference(declaration) => {
      if declaration == standard_nullable_ref_type_declaration() {
        self.diagnose(InvalidConstructionTarget(expression, offset))
        self.fail_expression_selection(expression)
      } else if self.declaration_is_struct(declaration) {
        self.select_struct_construction(expression, fields, declaration, offset)
      } else {
        self.diagnose(InvalidConstructionTarget(expression, offset))
        self.fail_expression_selection(expression)
      }
      return
    }
    _ => ()
  }
  match self.collected.expressions[target] {
    HirQualifiedExpr(base, property, _) =>
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
    HirNameExpr(_, _) | HirQualifiedExpr(_, _, _) =>
      match self.names.expression_references[base] {
        ForeignLibraryNameReference(library) => {
          self.consume_member_root(base)
          match self.collected.foreign_library_member(library, property) {
            Some(declaration) => {
              let local_index = semantic_id_local(declaration)
              let callable_index = if local_index >= 0 &&
                local_index < self.callable_indices.length() {
                self.callable_indices[local_index]
              } else {
                -1
              }
              if callable_index >= 0 {
                self.constrain(
                  self.expression_type(expression),
                  self.solver.resolved_type(
                    self.resolved.callable_function_types[callable_index],
                  ),
                  expression_type_origin(expression, offset),
                )
                self.expression_selections[self.expression_index(expression)] = FunctionReferenceSelection(
                  declaration,
                  { start: 0, length: 0 },
                )
              } else {
                self.mark_unsupported(expression)
              }
            }
            None => {
              self.diagnose(
                UnknownQualifiedMember(property, library, expression, offset),
              )
              self.fail_expression_selection(expression)
            }
          }
        }
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
          field.mutable_,
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
    self.collected.fields[field_index].mutable_,
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
              match self.select_value_variant(
                name,
                self.expression_type(expression),
                expression,
                offset,
              ) {
                SelectedLocalValueVariant(variant_index) =>
                  self.infer_unit_variant_value(
                    expression, variant_index, offset,
                  )
                SelectedImportedValueVariant(variant) =>
                  self.infer_imported_unit_variant_value(
                    expression, variant, offset,
                  )
                NoSelectedValueVariant =>
                  self.fail_expression_selection(expression)
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
