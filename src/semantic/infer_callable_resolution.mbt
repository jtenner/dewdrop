///|
fn BasicBodyInferencer::trait_declaration_named(
  self : BasicBodyInferencer,
  name : String,
) -> DeclId? {
  match self.collected.lookup_trait(name) {
    Some(declaration) => Some(declaration)
    None =>
      match self.imports {
        Some(imports) =>
          match imports.scope.lookup_trait(name) {
            Some(binding) => Some(binding.declaration)
            None => None
          }
        None => None
      }
  }
}

///|
fn BasicBodyInferencer::callable_index_of(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Int {
  if semantic_id_module(declaration) != self.collected.module_id {
    -1
  } else {
    let local_index = semantic_id_local(declaration)
    if local_index < 0 || local_index >= self.callable_indices.length() {
      -1
    } else {
      self.callable_indices[local_index]
    }
  }
}

///|
fn BasicBodyInferencer::imported_callable_of(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> ResolvedImportedCallable? {
  match self.imports {
    Some(imports) => imports.callable(declaration)
    None => None
  }
}

///|
fn BasicBodyInferencer::callable_exists(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Bool {
  self.callable_index_of(declaration) >= 0 ||
  self.imported_callable_of(declaration) is Some(_)
}

///|
fn BasicBodyInferencer::type_qualified_impl_target_head(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> ImplTargetHead {
  if semantic_id_module(declaration) == self.collected.module_id {
    match self.collected.declaration(declaration) {
      Some(TopLevelReference({ kind: TypeAliasDecl, .. })) => {
        let resolved_type = self.resolved.declaration_type(declaration)
        for index, alias_info in self.collected.aliases {
          if alias_info.declaration == declaration {
            return resolved_impl_target_head(
                self.resolved,
                self.resolved.alias_target_types[index],
              ).0
          }
        }
        resolved_impl_target_head(self.resolved, resolved_type).0
      }
      _ => NominalImplTargetHead(declaration)
    }
  } else {
    match self.imports {
      Some(imports) =>
        match imports.type_declaration_type(declaration) {
          Some(type_) => resolved_impl_target_head(self.resolved, type_).0
          None => NominalImplTargetHead(declaration)
        }
      None => NominalImplTargetHead(declaration)
    }
  }
}

///|
fn BasicBodyInferencer::call_parameter_count(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Int {
  if semantic_id_module(declaration) == self.collected.module_id {
    self.collected.parameters_of(declaration).length
  } else {
    match self.imported_callable_of(declaration) {
      Some(callable) => callable.parameters.length
      None => -1
    }
  }
}

///|
fn BasicBodyInferencer::call_parameter_is_receiver(
  self : BasicBodyInferencer,
  declaration : DeclId,
  index : Int,
) -> Bool {
  if semantic_id_module(declaration) == self.collected.module_id {
    let parameters = self.collected.parameters_of(declaration)
    self.collected.parameters[parameters.start + index].kind ==
    ReceiverParameterDecl
  } else {
    let callable = self.imported_callable_of(declaration).unwrap()
    let imports = self.imports.unwrap()
    imports.parameter_receivers[callable.parameters.start + index]
  }
}

///|
fn BasicBodyInferencer::call_parameter_type(
  self : BasicBodyInferencer,
  declaration : DeclId,
  index : Int,
) -> ResolvedTypeId {
  if semantic_id_module(declaration) == self.collected.module_id {
    let parameters = self.collected.parameters_of(declaration)
    self.resolved.parameter_types[parameters.start + index]
  } else {
    let callable = self.imported_callable_of(declaration).unwrap()
    let imports = self.imports.unwrap()
    imports.parameter_types[callable.parameters.start + index]
  }
}

///|
fn BasicBodyInferencer::call_result_type(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> ResolvedTypeId {
  let local_index = self.callable_index_of(declaration)
  if local_index >= 0 {
    self.resolved.callable_return_types[local_index]
  } else {
    self.imported_callable_of(declaration).unwrap().result_type
  }
}

///|
fn BasicBodyInferencer::call_result_is_never(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Bool {
  if !self.callable_exists(declaration) {
    return false
  }
  self.resolved.types[self.call_result_type(declaration)]
  is PrimitiveType(NeverType)
}

///|
fn BasicBodyInferencer::direct_call_is_declared_never(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Bool {
  let target = match self.collected.expressions[expression] {
    HirCallExpr(target, _, _) => target
    _ => return false
  }
  match self.collected.expressions[target] {
    HirNameExpr(name, _) =>
      match self.collected.value_bindings.get(name) {
        Some(binding) => {
          let mut cursor = binding.head
          let mut found = false
          while cursor >= 0 {
            let candidate = self.collected.value_binding_candidates[cursor]
            if self.declaration_visible(candidate.declaration) {
              if !self.call_result_is_never(candidate.declaration) {
                return false
              }
              found = true
            }
            cursor = candidate.next
          }
          found
        }
        None =>
          match self.names.expression_references[target] {
            ImportedValueNameReference(head) =>
              match self.imports {
                Some(imports) => {
                  let mut cursor = head
                  let mut found = false
                  while cursor >= 0 {
                    let declaration = imports.callables[cursor].declaration
                    if !self.call_result_is_never(declaration) {
                      return false
                    }
                    found = true
                    cursor = imports.scope.callable_references[cursor].next
                  }
                  found
                }
                None => false
              }
            _ => false
          }
      }
    _ => false
  }
}

///|
fn BasicBodyInferencer::call_function_type(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> ResolvedTypeId {
  let local_index = self.callable_index_of(declaration)
  if local_index >= 0 {
    self.resolved.callable_function_types[local_index]
  } else {
    self.imported_callable_of(declaration).unwrap().function_type
  }
}

///|
fn BasicBodyInferencer::call_generic_count(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Int {
  if semantic_id_module(declaration) == self.collected.module_id {
    self.collected.generic_parameters_of(declaration).length
  } else {
    match self.imported_callable_of(declaration) {
      Some(callable) => callable.generic_parameters.length
      None => -1
    }
  }
}

///|
fn BasicBodyInferencer::explicit_call_type_arguments(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> HirSpan {
  if expression < 0 ||
    expression >= self.collected.explicit_call_type_argument_spans.length() {
    { start: 0, length: 0, }
  } else {
    self.collected.explicit_call_type_argument_spans[expression]
  }
}

///|
fn BasicBodyInferencer::apply_explicit_call_type_arguments(
  self : BasicBodyInferencer,
  expression : ExprId,
  candidate_start : Int,
  candidate_count : Int,
) -> Bool {
  let explicit = self.explicit_call_type_arguments(expression)
  if explicit.length == 0 {
    return true
  }
  if explicit.length != candidate_count {
    return false
  }
  for index in 0..<candidate_count {
    self.call_scratch.candidate_type_arguments[candidate_start + index] = self.solver.resolved_type(
      self.resolved.explicit_call_type_arguments[explicit.start + index],
    )
  }
  true
}

///|
fn BasicBodyInferencer::call_arity_matches(
  self : BasicBodyInferencer,
  declaration : DeclId,
  arguments : HirSpan,
) -> Bool {
  self.call_parameter_count(declaration) == arguments.length
}

///|
fn BasicBodyInferencer::explicit_call_type_arity_matches(
  self : BasicBodyInferencer,
  expression : ExprId,
  declaration : DeclId,
) -> Bool {
  let explicit = self.explicit_call_type_arguments(expression)
  explicit.length == 0 ||
  explicit.length == self.call_generic_count(declaration)
}

///|
fn BasicBodyInferencer::diagnose_call_type_arity(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  declaration : DeclId,
  offset : UInt64,
) -> Unit {
  let explicit = self.explicit_call_type_arguments(expression)
  self.call_targets[call_slot] = ErrorInferredCallTarget
  self.poison_expression(expression)
  self.diagnose(
    CallTypeArgumentCountMismatch(
      expression,
      declaration,
      self.call_generic_count(declaration),
      explicit.length,
      offset,
    ),
  )
}

///|
fn BasicBodyInferencer::object_argument_matches_nominal_shape(
  self : BasicBodyInferencer,
  argument : ExprId,
  expected : BodyTypeId,
) -> Bool {
  let fields = match self.collected.expressions[argument] {
    HirObjectExpr(fields, _) => fields
    _ => return true
  }
  if !self.inspect_nominal_type(expected) {
    return false
  }
  let declaration = self.call_scratch.nominal_declaration
  match self.collected.declaration(declaration) {
    Some(TopLevelReference({ kind: StructDecl, .. })) => ()
    _ => return false
  }
  let mut declared_count = 0
  for field in self.collected.fields {
    if field.declaration == declaration && field.variant is None {
      declared_count += 1
      let mut matches = 0
      for index in 0..<fields.length {
        if self.collected.object_fields[fields.start + index].name == field.name {
          matches += 1
        }
      }
      if matches != 1 {
        return false
      }
    }
  }
  if declared_count != fields.length {
    return false
  }
  true
}

///|
fn BasicBodyInferencer::call_has_object_argument(
  self : BasicBodyInferencer,
  arguments : HirSpan,
) -> Bool {
  for index in 0..<arguments.length {
    let argument = self.collected.expression_children[arguments.start + index]
    match self.collected.expressions[argument] {
      HirObjectExpr(_, _) => return true
      _ => ()
    }
  }
  false
}

///|
fn BasicBodyInferencer::is_debug_dispatch(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> Bool {
  if semantic_id_module(declaration) == self.collected.module_id {
    for builtin in self.collected.builtins {
      if builtin.declaration == declaration {
        return builtin.builtin_name == b"dew_debug_dispatch"
      }
    }
    return false
  }
  let imports = match self.imports {
    Some(value) => value
    None => return false
  }
  for interface_index in imports.scope.imported_interfaces {
    let interface_ = imports.scope.interfaces[interface_index].unwrap()
    for callable in interface_.callables {
      if callable.declaration == declaration {
        return match callable.kind {
          FrozenBuiltinCallable(name) => name == b"dew_debug_dispatch"
          _ => false
        }
      }
    }
  }
  false
}

///|
fn BasicBodyInferencer::select_debug_dispatch(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  receiver : ExprId,
  offset : UInt64,
) -> Unit {
  let name = self.collected.find_name("debug").unwrap()
  if self.select_declared_bound_method(
      call_slot,
      expression,
      receiver,
      name,
      { start: 0, length: 0, },
      offset,
    ) {
    return
  }
  if !self.collect_method_candidates(self.expression_type(receiver), name) {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.diagnose(NoMatchingMethod(name, expression, offset))
    return
  }
  let arguments = { start: 0, length: 0, }
  let mut viable_count = 0
  let mut selected_declaration = 0UL
  let mut selected_impl = -1
  let mut selected_specificity = -1
  let mut second_declaration = 0UL
  for candidate_index in 0..<self.call_scratch.method_candidates.length() {
    let declaration = self.call_scratch.method_candidates[candidate_index]
    let implementation_index = self.call_scratch.method_candidate_impls[candidate_index]
    if self.try_method_candidate(
        expression, receiver, arguments, declaration, implementation_index, offset,
      ) {
      let specificity = self.impl_index.implementations[implementation_index].specificity
      if specificity > selected_specificity {
        selected_specificity = specificity
        viable_count = 1
        selected_declaration = declaration
        selected_impl = implementation_index
        second_declaration = 0UL
      } else if specificity == selected_specificity {
        viable_count += 1
        if viable_count == 2 {
          second_declaration = declaration
        }
      }
    }
  }
  if viable_count == 1 {
    self.select_method_candidate(
      call_slot, expression, receiver, arguments, selected_declaration, selected_impl,
      offset,
    )
  } else {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    if viable_count > 1 {
      self.diagnose(
        AmbiguousMethod(
          name, expression, selected_declaration, second_declaration, viable_count,
          offset,
        ),
      )
    } else {
      self.diagnose(NoMatchingMethod(name, expression, offset))
    }
  }
}

///|
fn BasicBodyInferencer::constrain_debug_dispatches(
  self : BasicBodyInferencer,
) -> Unit {
  for call_slot in self.call_scratch.pending_debug_dispatches {
    let expression = self.call_expressions[call_slot]
    let arguments = match self.collected.expressions[expression] {
      HirCallExpr(_, values, _) => values
      _ => abort("pending debug dispatch is not a call")
    }
    if arguments.length != 1 {
      continue
    }
    self.select_debug_dispatch(
      call_slot,
      expression,
      self.collected.expression_children[arguments.start],
      self.collected.expressions[expression].offset(),
    )
  }
  self.call_scratch.pending_debug_dispatches.clear()
}

///|
fn BasicBodyInferencer::select_call_candidate(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  offset : UInt64,
) -> Unit {
  guard self.callable_exists(declaration) else {
    abort("selected call is not callable")
  }
  self.begin_call_candidate(declaration)
  guard self.apply_explicit_call_type_arguments(
    expression,
    0,
    self.call_scratch.candidate_type_arguments.length(),
  ) else {
    abort("selected call has mismatched explicit type argument count")
  }
  let origin = call_type_origin(expression, offset)
  let parameter_types : Array[BodyTypeId] = []
  for index in 0..<arguments.length {
    parameter_types.push(
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index),
      ),
    )
  }
  let result_type = self.instantiate_signature_type(
    self.call_result_type(declaration),
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  for index in 0..<arguments.length {
    self.constrain_expression_assignable(
      self.collected.expression_children[arguments.start + index],
      parameter_types[index],
      origin,
    )
  }
  self.constrain_call_result(expression, result_type, origin)
  let type_arguments = {
    start,
    length: self.call_scratch.candidate_type_arguments.length(),
  }
  self.call_targets[call_slot] = SelectedInferredCallTarget(
    declaration, type_arguments,
  )
  if self.is_debug_dispatch(declaration) && arguments.length == 1 {
    self.call_scratch.pending_debug_dispatches.push(call_slot)
  } else {
    self.validate_call_obligations(
      expression, declaration, type_arguments, offset,
    )
  }
}

///|
priv struct InferredFunctionSignature {
  parameters : Array[BodyTypeId]
  result : BodyTypeId
}

///|
fn BasicBodyInferencer::resolved_function_signature(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> InferredFunctionSignature? {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyResolvedType(resolved_type) =>
      match self.resolved.types[resolved_type] {
        FunctionType(parameters, result) => {
          let values : Array[BodyTypeId] = []
          for index in 0..<parameters.length {
            values.push(
              self.solver.resolved_type(
                self.resolved.type_arguments[parameters.start + index],
              ),
            )
          }
          Some({
            parameters: values,
            result: self.solver.resolved_type(result),
          })
        }
        _ => None
      }
    BodyFunctionType(parameters, result) => {
      let values : Array[BodyTypeId] = []
      for index in 0..<parameters.length {
        values.push(self.solver.type_arguments[parameters.start + index])
      }
      Some({ parameters: values, result, })
    }
    _ => None
  }
}

///|
fn BasicBodyInferencer::select_function_value_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  target : ExprId,
  arguments : HirSpan,
  offset : UInt64,
) -> Bool {
  let signature = match
    self.resolved_function_signature(self.expression_type(target)) {
    Some(value) => value
    None => return false
  }
  if signature.parameters.length() != arguments.length {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(
      FunctionCallArgumentCountMismatch(
        expression,
        signature.parameters.length(),
        arguments.length,
        offset,
      ),
    )
    return true
  }
  let origin = call_type_origin(expression, offset)
  for index in 0..<arguments.length {
    self.constrain(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      signature.parameters[index],
      origin,
    )
  }
  self.constrain_call_result(expression, signature.result, origin)
  self.call_targets[call_slot] = SelectedFunctionValueCallTarget(target)
  true
}

///|
fn BasicBodyInferencer::record_invalid_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  offset : UInt64,
) -> Unit {
  self.call_targets[call_slot] = ErrorInferredCallTarget
  self.poison_expression(expression)
  self.diagnose(InvalidCallTarget(expression, offset))
}

///|
fn BasicBodyInferencer::prepare_imported_value_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  target : ExprId,
  arguments : HirSpan,
  offset : UInt64,
  head : Int,
) -> Unit {
  match self.imports {
    Some(imports) => {
      self.names.expression_references[target] = ImportedValueNameReference(
        head,
      )
      let first = imports.scope.callable_references[head]
      if first.next < 0 {
        let declaration = imports.callables[head].declaration
        if !self.call_arity_matches(declaration, arguments) {
          self.call_targets[call_slot] = ErrorInferredCallTarget
          self.poison_expression(expression)
          self.diagnose(
            CallArgumentCountMismatch(
              expression,
              declaration,
              self.call_parameter_count(declaration),
              arguments.length,
              offset,
            ),
          )
        } else if !self.explicit_call_type_arity_matches(
            expression, declaration,
          ) {
          self.diagnose_call_type_arity(
            call_slot, expression, declaration, offset,
          )
        } else {
          self.select_call_candidate(
            call_slot, expression, arguments, declaration, offset,
          )
        }
      } else {
        self.call_scratch.pending_calls.push(call_slot)
      }
    }
    None => self.record_invalid_call(call_slot, expression, offset)
  }
}

///|
fn BasicBodyInferencer::prepare_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  target : ExprId,
  arguments : HirSpan,
  offset : UInt64,
) -> Unit {
  match self.collected.expressions[target] {
    HirNameExpr(name, _) => {
      self.consume_unsupported_root(target)
      match self.names.expression_references[target] {
        ModuleValueNameReference(name) =>
          match self.collected.value_bindings.get(name) {
            Some(binding) => {
              let first = self.collected.value_binding_candidates[binding.head]
              if first.next < 0 {
                let declaration = first.declaration
                let callable_index = self.callable_index_of(declaration)
                if callable_index < 0 {
                  if !self.select_function_value_call(
                      call_slot, expression, target, arguments, offset,
                    ) {
                    self.record_invalid_call(call_slot, expression, offset)
                  }
                } else if !self.call_arity_matches(declaration, arguments) {
                  self.call_targets[call_slot] = ErrorInferredCallTarget
                  self.poison_expression(expression)
                  self.diagnose(
                    CallArgumentCountMismatch(
                      expression,
                      declaration,
                      self.collected.parameters_of(declaration).length,
                      arguments.length,
                      offset,
                    ),
                  )
                } else if !self.explicit_call_type_arity_matches(
                    expression, declaration,
                  ) {
                  self.diagnose_call_type_arity(
                    call_slot, expression, declaration, offset,
                  )
                } else {
                  self.select_call_candidate(
                    call_slot, expression, arguments, declaration, offset,
                  )
                }
              } else {
                self.call_scratch.pending_calls.push(call_slot)
              }
            }
            None => self.record_invalid_call(call_slot, expression, offset)
          }
        ImportedValueNameReference(head) =>
          self.prepare_imported_value_call(
            call_slot, expression, target, arguments, offset, head,
          )
        LocalNameReference(_)
        | LambdaCaptureNameReference(_)
        | ImportedModuleValueNameReference(_) =>
          if !self.select_function_value_call(
              call_slot, expression, target, arguments, offset,
            ) {
            self.call_scratch.pending_function_calls.push(call_slot)
          }
        VariantNameReference(_) => {
          self.consume_member_root(target)
          match
            self.select_value_variant(
              name,
              self.expression_type(expression),
              expression,
              offset,
            ) {
            SelectedLocalValueVariant(variant_index) =>
              self.infer_tuple_variant_call(
                call_slot, expression, arguments, variant_index, offset,
              )
            SelectedImportedValueVariant(variant) =>
              self.infer_imported_tuple_variant_call(
                call_slot, expression, arguments, variant, offset,
              )
            NoSelectedValueVariant => {
              self.call_targets[call_slot] = ErrorInferredCallTarget
              self.fail_expression_selection(expression)
            }
          }
        }
        _ => self.record_invalid_call(call_slot, expression, offset)
      }
    }
    HirFieldExpr(base, property, _) =>
      match self.names.expression_references[base] {
        ForeignLibraryNameReference(library) => {
          self.consume_member_root(target)
          self.consume_member_root(base)
          match self.collected.foreign_library_member(library, property) {
            Some(declaration) =>
              self.select_call_candidate(
                call_slot, expression, arguments, declaration, offset,
              )
            None => {
              self.call_targets[call_slot] = ErrorInferredCallTarget
              self.diagnose(
                UnknownQualifiedMember(property, library, expression, offset),
              )
              self.fail_expression_selection(expression)
            }
          }
        }
        _ => {
          self.call_scratch.pending_methods.push(call_slot)
          self.consume_member_root(target)
        }
      }
    HirQualifiedExpr(base, property, _) =>
      match self.collected.expressions[base] {
        HirImportAliasExpr(_, _) =>
          match self.names.expression_references[base] {
            ImportedModuleNameReference(interface_index) => {
              self.consume_member_root(target)
              match self.imports {
                Some(imports) =>
                  match
                    imports.scope.lookup_module_callable(
                      interface_index,
                      self.collected.name(property),
                    ) {
                    Some(head) =>
                      self.prepare_imported_value_call(
                        call_slot, expression, target, arguments, offset, head,
                      )
                    None => {
                      self.call_targets[call_slot] = ErrorInferredCallTarget
                      self.poison_expression(expression)
                      self.diagnose(
                        UnknownImportedModuleMember(
                          property, expression, offset,
                        ),
                      )
                    }
                  }
                None => self.record_invalid_call(call_slot, expression, offset)
              }
            }
            _ => self.record_invalid_call(call_slot, expression, offset)
          }
        HirNameExpr(_, _) | HirQualifiedExpr(_, _, _) =>
          match self.names.expression_references[base] {
            ForeignLibraryNameReference(library) => {
              self.consume_member_root(target)
              match self.collected.foreign_library_member(library, property) {
                Some(declaration) =>
                  self.select_call_candidate(
                    call_slot, expression, arguments, declaration, offset,
                  )
                None => {
                  self.call_targets[call_slot] = ErrorInferredCallTarget
                  self.diagnose(
                    UnknownQualifiedMember(
                      property, library, expression, offset,
                    ),
                  )
                  self.fail_expression_selection(expression)
                }
              }
            }
            ModuleTypeNameReference(declaration) => {
              self.consume_member_root(target)
              if semantic_id_module(declaration) == self.collected.module_id {
                let variant_index = self.variant_index_in_declaration(
                  declaration, property,
                )
                if variant_index >= 0 {
                  self.infer_tuple_variant_call(
                    call_slot, expression, arguments, variant_index, offset,
                  )
                } else if !self.resolve_type_qualified_method_call(
                    call_slot,
                    expression,
                    arguments,
                    self.type_qualified_impl_target_head(declaration),
                    property,
                    offset,
                  ) {
                  self.call_targets[call_slot] = ErrorInferredCallTarget
                  self.diagnose(
                    UnknownQualifiedMember(
                      property, declaration, expression, offset,
                    ),
                  )
                  self.fail_expression_selection(expression)
                }
              } else {
                match self.imported_variant_named(declaration, property) {
                  Some(variant) =>
                    self.infer_imported_tuple_variant_call(
                      call_slot, expression, arguments, variant, offset,
                    )
                  None =>
                    if !self.resolve_type_qualified_method_call(
                        call_slot,
                        expression,
                        arguments,
                        self.type_qualified_impl_target_head(declaration),
                        property,
                        offset,
                      ) {
                      self.call_targets[call_slot] = ErrorInferredCallTarget
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
            PrimitiveTypeNameReference(primitive) => {
              self.consume_member_root(target)
              if !self.resolve_type_qualified_method_call(
                  call_slot,
                  expression,
                  arguments,
                  PrimitiveImplTargetHead(primitive),
                  property,
                  offset,
                ) {
                self.call_targets[call_slot] = ErrorInferredCallTarget
                self.diagnose(NoMatchingMethod(property, expression, offset))
                self.fail_expression_selection(expression)
              }
            }
            ModuleTraitNameReference(declaration) => {
              self.consume_member_root(target)
              if !self.resolve_trait_qualified_method_call(
                  call_slot, expression, arguments, declaration, property, offset,
                ) {
                self.call_targets[call_slot] = ErrorInferredCallTarget
                self.diagnose(
                  UnknownQualifiedMember(
                    property, declaration, expression, offset,
                  ),
                )
                self.fail_expression_selection(expression)
              }
            }
            _ => {
              self.mark_unsupported(expression)
              self.consume_member_root(target)
            }
          }
        _ => {
          self.mark_unsupported(expression)
          self.consume_member_root(target)
        }
      }
    _ =>
      if !self.select_function_value_call(
          call_slot, expression, target, arguments, offset,
        ) {
        self.call_scratch.pending_function_calls.push(call_slot)
      }
  }
}

///|
fn BasicBodyInferencer::trial_overload(
  self : BasicBodyInferencer,
  expression : ExprId,
  reference : BodyNameReference,
  arguments : HirSpan,
  offset : UInt64,
) -> Unit {
  self.call_scratch.trial_viable_count = 0
  self.call_scratch.trial_first_declaration = 0UL
  self.call_scratch.trial_second_declaration = 0UL
  self.call_scratch.overload_candidates.clear()
  match reference {
    ModuleValueNameReference(name) => {
      let binding = self.collected.value_bindings.get(name).unwrap()
      let mut cursor = binding.head
      while cursor >= 0 {
        let candidate = self.collected.value_binding_candidates[cursor]
        if self.declaration_visible(candidate.declaration) {
          self.call_scratch.overload_candidates.push(candidate.declaration)
        }
        cursor = candidate.next
      }
    }
    ImportedValueNameReference(head) =>
      match self.imports {
        Some(imports) => {
          let mut cursor = head
          while cursor >= 0 {
            self.call_scratch.overload_candidates.push(
              imports.callables[cursor].declaration,
            )
            cursor = imports.scope.callable_references[cursor].next
          }
        }
        None => ()
      }
    _ => abort("overload trial reference is not a value binding")
  }
  self.call_scratch.overload_viable_candidates.clear()
  for declaration in self.call_scratch.overload_candidates {
    if self.call_generic_count(declaration) == 0 &&
      self.try_call_candidate(expression, arguments, declaration, offset) {
      self.call_scratch.overload_viable_candidates.push(declaration)
    }
  }
  if self.call_scratch.overload_viable_candidates.length() > 0 {
    self.retain_structurally_maximal_overloads()
    return
  }
  for declaration in self.call_scratch.overload_candidates {
    if self.call_generic_count(declaration) > 0 &&
      self.try_call_candidate(expression, arguments, declaration, offset) {
      self.call_scratch.overload_viable_candidates.push(declaration)
    }
  }
  self.retain_structurally_maximal_overloads()
}

///|
fn BasicBodyInferencer::call_pattern_matches(
  self : BasicBodyInferencer,
  general : DeclId,
  specific : DeclId,
) -> Bool {
  let snapshot = self.solver.snapshot()
  self.begin_call_candidate(general)
  let general_type = self.instantiate_signature_type(
    self.call_function_type(general),
  )
  let matches = self.solver.unify(
    general_type,
    self.solver.resolved_type(self.call_function_type(specific)),
    synthetic_type_origin(-1, 0UL),
  )
  self.solver.rollback(snapshot)
  matches
}

///|
fn BasicBodyInferencer::retain_structurally_maximal_overloads(
  self : BasicBodyInferencer,
) -> Unit {
  self.call_scratch.overload_maximal_candidates.clear()
  for candidate in self.call_scratch.overload_viable_candidates {
    let mut dominated = false
    for other in self.call_scratch.overload_viable_candidates {
      if candidate == other {
        continue
      }
      if self.call_pattern_matches(candidate, other) &&
        !self.call_pattern_matches(other, candidate) {
        dominated = true
        break
      }
    }
    if !dominated {
      self.call_scratch.overload_maximal_candidates.push(candidate)
    }
  }
  self.call_scratch.trial_viable_count = self.call_scratch.overload_maximal_candidates.length()
  self.call_scratch.trial_first_declaration = if self.call_scratch.trial_viable_count >
    0 {
    self.call_scratch.overload_maximal_candidates[0]
  } else {
    0UL
  }
  self.call_scratch.trial_second_declaration = if self.call_scratch.trial_viable_count >
    1 {
    self.call_scratch.overload_maximal_candidates[1]
  } else {
    0UL
  }
}

///|
fn BasicBodyInferencer::call_has_poison(
  self : BasicBodyInferencer,
  expression : ExprId,
  arguments : HirSpan,
) -> Bool {
  if self.solver.representative_type(self.expression_type(expression)) ==
    self.solver.error_type() {
    return true
  }
  for index in 0..<arguments.length {
    if self.solver.representative_type(
        self.expression_type(
          self.collected.expression_children[arguments.start + index],
        ),
      ) ==
      self.solver.error_type() {
      return true
    }
  }
  false
}

///|
fn BasicBodyInferencer::constrain_pending_calls(
  self : BasicBodyInferencer,
) -> Unit {
  while self.call_scratch.pending_calls.length() > 0 {
    self.call_scratch.deferred_calls.clear()
    let mut progress = false
    for call_slot in self.call_scratch.pending_calls {
      let expression = self.call_expressions[call_slot]
      let (target, arguments, offset) = match
        self.collected.expressions[expression] {
        HirCallExpr(target, arguments, offset) => (target, arguments, offset)
        _ => abort("pending call does not reference a call expression")
      }
      let reference = self.names.expression_references[target]
      self.trial_overload(expression, reference, arguments, offset)
      if self.call_scratch.trial_viable_count == 1 {
        self.select_call_candidate(
          call_slot,
          expression,
          arguments,
          self.call_scratch.trial_first_declaration,
          offset,
        )
        progress = true
      } else {
        self.call_scratch.deferred_calls.push(call_slot)
      }
    }
    self.call_scratch.pending_calls.clear()
    for call_slot in self.call_scratch.deferred_calls {
      self.call_scratch.pending_calls.push(call_slot)
    }
    if !progress {
      break
    }
  }
  for call_slot in self.call_scratch.pending_calls {
    let expression = self.call_expressions[call_slot]
    let (target, arguments, offset) = match
      self.collected.expressions[expression] {
      HirCallExpr(target, arguments, offset) => (target, arguments, offset)
      _ => abort("pending call does not reference a call expression")
    }
    let name = match self.collected.expressions[target] {
      HirNameExpr(name, _) => name
      _ => abort("pending overload target is not a name")
    }
    let reference = self.names.expression_references[target]
    self.call_targets[call_slot] = ErrorInferredCallTarget
    if self.call_has_poison(expression, arguments) {
      self.poison_expression(expression)
      continue
    }
    self.trial_overload(expression, reference, arguments, offset)
    self.poison_expression(expression)
    if self.call_scratch.trial_viable_count == 0 {
      if !self.call_has_object_argument(arguments) {
        self.diagnose(NoMatchingCallOverload(name, expression, offset))
      }
    } else {
      self.diagnose(
        AmbiguousCallOverload(
          name,
          expression,
          self.call_scratch.trial_first_declaration,
          self.call_scratch.trial_second_declaration,
          self.call_scratch.trial_viable_count,
          offset,
        ),
      )
    }
  }
}

///|
fn BasicBodyInferencer::constrain_pending_function_calls(
  self : BasicBodyInferencer,
  final_ : Bool,
) -> Unit {
  while self.call_scratch.pending_function_calls.length() > 0 {
    self.call_scratch.deferred_function_calls.clear()
    let mut progress = false
    for call_slot in self.call_scratch.pending_function_calls {
      let expression = self.call_expressions[call_slot]
      let (target, arguments, offset) = match
        self.collected.expressions[expression] {
        HirCallExpr(target, arguments, offset) => (target, arguments, offset)
        _ => abort("pending function-value call is not a call expression")
      }
      if self.select_function_value_call(
          call_slot, expression, target, arguments, offset,
        ) {
        progress = true
      } else {
        self.call_scratch.deferred_function_calls.push(call_slot)
      }
    }
    self.call_scratch.pending_function_calls.clear()
    for call_slot in self.call_scratch.deferred_function_calls {
      self.call_scratch.pending_function_calls.push(call_slot)
    }
    if !progress {
      break
    }
  }
  if final_ {
    for call_slot in self.call_scratch.pending_function_calls {
      let expression = self.call_expressions[call_slot]
      let offset = self.collected.expressions[expression].offset()
      self.record_invalid_call(call_slot, expression, offset)
    }
    self.call_scratch.pending_function_calls.clear()
  }
}

///|
fn BasicBodyInferencer::constrain_calls(self : BasicBodyInferencer) -> Unit {
  let mut call_slot = self.call_expressions.length()
  while call_slot > 0 {
    call_slot -= 1
    let expression = self.call_expressions[call_slot]
    match self.collected.expressions[expression] {
      HirCallExpr(target, arguments, offset) =>
        self.prepare_call(call_slot, expression, target, arguments, offset)
      _ => abort("recorded call does not reference a call expression")
    }
  }
  self.constrain_pending_calls()
  self.constrain_pending_function_calls(false)
}
