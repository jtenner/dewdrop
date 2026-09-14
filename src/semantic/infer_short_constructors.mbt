///|
priv struct ConstructorIndex {
  module_id : ModuleId
  names : Map[NameId, Array[SelectedValueVariant]]
}

///|
fn BasicBodyInferencer::constructor_candidates(
  self : BasicBodyInferencer,
  name : NameId,
) -> Array[SelectedValueVariant] {
  let index = match self.call_scratch.constructor_index {
    Some(index) if index.module_id == self.collected.module_id => index
    _ => {
      let index : ConstructorIndex = {
        module_id: self.collected.module_id,
        names: Map::new(),
      }
      for slot, variant in self.collected.variants {
        let candidates = index.names.get_or_init(variant.name, fn() { [] })
        candidates.push(SelectedLocalValueVariant(slot))
      }
      match self.imports {
        Some(imports) =>
          for variant in imports.variants {
            match self.collected.find_name(variant.name) {
              Some(name) => {
                let candidates = index.names.get_or_init(name, fn() { [] })
                candidates.push(SelectedImportedValueVariant(variant))
              }
              None => ()
            }
          }
        None => ()
      }
      self.call_scratch.constructor_index = Some(index)
      index
    }
  }
  index.names.get(name).unwrap_or([])
}

///|
fn BasicBodyInferencer::constructor_variant_id(
  self : BasicBodyInferencer,
  candidate : SelectedValueVariant,
) -> VariantId {
  match candidate {
    SelectedLocalValueVariant(index) => self.collected.variants[index].id
    SelectedImportedValueVariant(variant) => variant.variant
    NoSelectedValueVariant =>
      abort("constructor candidate must have an identity")
  }
}

///|
fn BasicBodyInferencer::constructor_candidate_viable(
  self : BasicBodyInferencer,
  candidate : SelectedValueVariant,
  expression : ExprId,
  expected : BodyTypeId,
  offset : UInt64,
) -> Bool {
  let variant = self.constructor_variant_id(candidate)
  let kind = self.variant_kind(variant)
  let origin = expression_type_origin(expression, offset)
  let snapshot = self.solver.snapshot()
  self.begin_expression_instantiation(
    self.variant_declaration(variant).unwrap(),
    expected,
    expression,
    offset,
  )
  let mut viable = self.solver.diagnostics.length() == snapshot.diagnostic_count
  match self.collected.expressions[expression] {
    HirCallExpr(_, arguments, _) => {
      viable = viable &&
        kind == Some(TupleVariantDecl) &&
        arguments.length == self.variant_payload_length(variant)
      if viable {
        for index in 0..<arguments.length {
          let argument = self.collected.expression_children[arguments.start +
            index]
          let payload = self.instantiate_signature_type(
            self.variant_payload_type(variant, index),
          )
          if !self.solver.unify(self.expression_type(argument), payload, origin) {
            viable = false
            break
          }
        }
      }
    }
    HirConstructExpr(_, fields, _) => {
      viable = viable && kind == Some(StructVariantDecl)
      if viable {
        for index in 0..<fields.length {
          let field = self.collected.object_fields[fields.start + index]
          let mut found = false
          match candidate {
            SelectedLocalValueVariant(_) =>
              for declared in self.collected.fields {
                if declared.variant == Some(variant) &&
                  declared.name == field.name {
                  found = true
                  let type_ = self.instantiate_signature_type(
                    self.resolved.field_types[semantic_id_local(declared.id)],
                  )
                  viable = self.solver.unify(
                      self.expression_type(field.value),
                      type_,
                      origin,
                    ) &&
                    viable
                  break
                }
              }
            SelectedImportedValueVariant(_) =>
              match self.imports {
                Some(imports) =>
                  for declared in imports.fields {
                    if declared.variant == Some(variant) &&
                      declared.name == self.collected.name(field.name) {
                      found = true
                      let type_ = self.instantiate_signature_type(
                        declared.type_,
                      )
                      viable = self.solver.unify(
                          self.expression_type(field.value),
                          type_,
                          origin,
                        ) &&
                        viable
                      break
                    }
                  }
                None => ()
              }
            NoSelectedValueVariant => abort("missing constructor candidate")
          }
          viable = viable && found
        }
      }
    }
    _ => viable = viable && kind == Some(UnitVariantDecl)
  }
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::constrain_short_constructors(
  self : BasicBodyInferencer,
) -> Unit {
  let pending = self.call_scratch.pending_variant_calls.copy()
  self.call_scratch.pending_variant_calls.clear()
  for slot in pending {
    let expression = self.call_expressions[slot]
    match self.collected.expressions[expression] {
      HirCallExpr(target, arguments, offset) => {
        let name = match self.collected.expressions[target] {
          HirNameExpr(name, _) => name
          _ => abort("short constructor call must have a name")
        }
        if self.names.expression_references[target]
          is ContextualFactoryNameReference(_) {
          if !self.try_contextual_factory(
              slot, expression, arguments, name, offset,
            ) {
            self.call_scratch.pending_variant_calls.push(slot)
          }
          continue
        }
        match
          self.select_value_variant(
            name,
            self.expression_type(expression),
            expression,
            offset,
          ) {
          SelectedLocalValueVariant(index) =>
            self.infer_tuple_variant_call(
              slot, expression, arguments, index, offset,
            )
          SelectedImportedValueVariant(variant) =>
            self.infer_imported_tuple_variant_call(
              slot, expression, arguments, variant, offset,
            )
          NoSelectedValueVariant =>
            if self.call_scratch.final_constructors {
              self.call_targets[slot] = ErrorInferredCallTarget
              self.fail_expression_selection(expression)
            } else {
              self.call_scratch.pending_variant_calls.push(slot)
            }
        }
      }
      _ => abort("short constructor queue contains a non-call")
    }
  }
  let patterns = self.call_scratch.pending_patterns.copy()
  self.call_scratch.pending_patterns.clear()
  for task in patterns {
    self.infer_pattern(task.0, task.1)
  }
}

///|
fn BasicBodyInferencer::try_contextual_factory(
  self : BasicBodyInferencer,
  slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  name : NameId,
  offset : UInt64,
) -> Bool {
  let head = self.body_impl_target_head(self.expression_type(expression))
  let mut count = 0
  let mut first = 0UL
  let mut second = 0UL
  let mut selected_impl = -1
  match head {
    Some(head) if head != ErrorImplTargetHead => {
      let candidates = self.impl_index.method_dispatch_span(
        head, name, true, false,
      )
      for index in candidates.start..<(candidates.start + candidates.length) {
        let candidate = self.impl_index.method_dispatch[index]
        let method = self.impl_index.methods[candidate.method_index].declaration
        if self.implementation_visible(candidate.implementation) &&
          self.try_qualified_method_candidate(
            expression,
            arguments,
            method,
            candidate.implementation,
            offset,
          ) {
          count += 1
          if count == 1 {
            first = method
            selected_impl = candidate.implementation
          } else if count == 2 {
            second = method
          }
        }
      }
    }
    _ => ()
  }
  if count == 1 {
    self.select_qualified_method_candidate(
      slot, expression, arguments, first, selected_impl, offset,
    )
    self.call_scratch.constructor_progress += 1
    true
  } else if !self.call_scratch.final_constructors {
    false
  } else {
    self.call_targets[slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    if count > 1 {
      self.diagnose(
        AmbiguousMethod(name, expression, first, second, count, offset),
      )
    } else {
      self.diagnose(NoMatchingMethod(name, expression, offset))
    }
    true
  }
}

///|
fn BasicBodyInferencer::try_constructor_function(
  self : BasicBodyInferencer,
  expression : ExprId,
  name : NameId,
  offset : UInt64,
) -> Bool {
  if self.resolved_function_signature(self.expression_type(expression)) is None {
    return false
  }
  let mut count = 0
  let mut first = 0UL
  let mut second = 0UL
  let mut selected_type = -1
  for candidate in self.constructor_candidates(name) {
    let wrapper = match candidate {
      SelectedLocalValueVariant(index) =>
        self.collected.constructor_wrappers.get(
          self.collected.variants[index].id,
        )
      SelectedImportedValueVariant(variant) => variant.constructor
      NoSelectedValueVariant => None
    }
    match wrapper {
      Some(declaration) => {
        let type_ = if semantic_id_module(declaration) ==
          self.collected.module_id {
          self.resolved.callable_function_types[self.callable_index_of(
            declaration,
          )]
        } else {
          self.imported_callable_of(declaration).unwrap().function_type
        }
        if self.function_reference_candidate_viable(
            expression, declaration, type_, offset,
          ) {
          count += 1
          if count == 1 {
            first = declaration
            selected_type = type_
          } else if count == 2 {
            second = declaration
          }
        }
      }
      None => ()
    }
  }
  if count == 1 {
    self.commit_function_reference(expression, first, selected_type, offset)
    self.call_scratch.constructor_progress += 1
  } else if self.call_scratch.final_constructors {
    self.fail_expression_selection(expression)
    if count == 0 {
      self.diagnose(NoMatchingFunctionReference(name, expression, offset))
    } else {
      self.diagnose(
        AmbiguousFunctionReference(
          name, expression, first, second, count, offset,
        ),
      )
    }
  }
  true
}
