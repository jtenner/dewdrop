///|
fn computed_type_builtin(name : Bytes) -> Bool {
  name == b"types.field_type" || name == b"types.variant_payload_types"
}

///|
// Dependency resolution shares type arenas and cycle marks, but never clears
// the caller's traversal stack. A query can refer to a later field or alias.
fn TypeResolver::computed_dependency(
  self : TypeResolver,
  owner : DeclId,
  syntax : HirTypeId,
) -> ResolvedTypeId {
  guard syntax >= 0 && syntax < self.syntax_types.length() else {
    abort("ARN-104 computed type dependency is outside its arena")
  }
  if self.syntax_types[syntax] >= 0 {
    return self.syntax_types[syntax]
  }
  let child = {
    ..self,
    task_syntax: [],
    task_states: [],
    task_expectations: [],
    task_constructor_positions: [],
    application_scratch: [],
    substitution_task_types: [],
    substitution_task_states: [],
    substitution_result_starts: [],
    substitution_results: [],
    substitution_application_scratch: [],
    substitution_marks: [],
    substitution_values: [],
    substitution_generation: 0,
    computed_depth: self.computed_depth + 1,
  }
  child.resolve_syntax(owner, syntax, any_type_name)
}

///|
fn TypeResolver::computed_builtin_recipe(
  self : TypeResolver,
  syntax : HirTypeId,
) -> Result[Bytes, String] {
  let scope = self.imports
  let reference = match self.collected.type_syntax[syntax] {
    NamedTypeSyntax(name, _) => {
      let name = self.collected.name(name)
      match self.collected.lookup_value(name) {
        Some(declaration) => {
          for builtin in self.collected.builtins {
            if builtin.declaration == declaration {
              if !computed_type_builtin(builtin.builtin_name) {
                return Err(
                  "CT-030 a type position requires a type-returning builtin",
                )
              }
              let generics = self.collected.generic_parameters_of(declaration)
              let parameters = self.collected.parameters_of(declaration)
              if generics.length != 1 || parameters.length != 1 {
                return Err("CT-031 invalid type-query declaration signature")
              }
              let parameter = self.collected.parameters[parameters.start]
              let input = self.computed_dependency(declaration, parameter.type_)
              let mut output = self.interner.error_type
              for callable in self.collected.callables {
                if callable.declaration == declaration {
                  output = self.computed_dependency(
                    declaration,
                    callable.return_type,
                  )
                  break
                }
              }
              if self.interner.types[input] != PrimitiveType(StringType) ||
                self.interner.types[output] !=
                PrimitiveType(CompileTimeTypeType) {
                return Err(
                  "CT-031 type queries require a String selector and return Type",
                )
              }
              return Ok(builtin.builtin_name)
            }
          }
          return Err("CT-030 ordinary functions cannot be used as types")
        }
        None => ()
      }
      let scope = match scope {
        Some(scope) => scope
        None => return Err("CT-030 unknown type-query builtin")
      }
      if scope.let_bindings.contains(name) {
        return Err("CT-030 a value cannot be called in a type position")
      }
      match scope.value_bindings.get(name) {
        Some(binding) if !binding.ambiguous => binding.head
        _ => return Err("CT-030 missing or ambiguous type-query builtin")
      }
    }
    QualifiedTypeSyntax(alias, name, _, _) => {
      let scope = match scope {
        Some(scope) => scope
        None => return Err("CT-030 unknown type-query module")
      }
      let interface_ = match scope.lookup_alias(self.collected.name(alias)) {
        Some(index) => index
        None => return Err("CT-030 unknown type-query module alias")
      }
      match
        scope.lookup_module_callable(interface_, self.collected.name(name)) {
        Some(index) => index
        None => return Err("CT-030 missing or ambiguous qualified type query")
      }
    }
    _ => return Err("CT-030 invalid type-query target")
  }
  let scope = scope.unwrap()
  guard reference >= 0 && reference < scope.callable_references.length() else {
    abort("ARN-104 type-query callable reference is outside its arena")
  }
  let reference = scope.callable_references[reference]
  if reference.next >= 0 {
    return Err("CT-030 ambiguous type-query declaration")
  }
  let interface_ = scope.interfaces[reference.interface_index].unwrap()
  let callable = interface_.callables[reference.callable_index]
  let name = match callable.kind {
    FrozenBuiltinCallable(name) if computed_type_builtin(name) => name
    _ => return Err("CT-030 a type position requires a type-returning builtin")
  }
  if callable.generic_parameters.length != 1 || callable.parameters.length != 1 {
    return Err("CT-031 invalid type-query declaration signature")
  }
  let input = interface_.parameters[callable.parameters.start].type_
  if interface_.resolved_types.types[input] != PrimitiveType(StringType) ||
    interface_.resolved_types.types[callable.result_type] !=
    PrimitiveType(CompileTimeTypeType) {
    return Err("CT-031 type queries require a String selector and return Type")
  }
  Ok(name)
}

///|
fn TypeResolver::computed_nominal(
  self : TypeResolver,
  input : ResolvedTypeId,
) -> Result[(DeclId, Array[ResolvedTypeId]), String] {
  let mut current = input
  let visited : Map[ResolvedTypeId, Bool] = Map([])
  while true {
    if visited.contains(current) {
      return Err("CT-033 cyclic computed type alias")
    }
    if visited.length() >= 1024 {
      return Err("CT-034 computed type alias limit exceeded")
    }
    visited[current] = true
    let arguments : Array[ResolvedTypeId] = []
    let base = match self.interner.types[current] {
      AppliedType(base, span) => {
        guard program_specialization_span_is_valid(
          span,
          self.interner.arguments.length(),
        ) else {
          abort("ARN-101 computed type arguments are outside their arena")
        }
        for index in 0..<span.length {
          arguments.push(self.interner.arguments[span.start + index])
        }
        base
      }
      _ => current
    }
    let declaration = match self.interner.types[base] {
      NominalType(declaration) => declaration
      GenericParameterType(_) | SelfType(_) =>
        return Err("CT-035 member type query requires a known nominal type")
      _ => return Err("CT-032 member type query requires a struct or enum")
    }
    match self.alias_indices.get(declaration) {
      Some(index) => {
        let alias_ = self.collected.aliases[index]
        let target = self.computed_dependency(declaration, alias_.target)
        if target == self.interner.error_type {
          return Err("CT-033 invalid computed type dependency")
        }
        current = self.substitute_declared_type(
          declaration,
          self.collected.generic_parameters_of(declaration),
          target,
          arguments,
        )
      }
      None => return Ok((declaration, arguments))
    }
  } nobreak {
    abort("INV-001 computed nominal traversal fell through")
  }
}

///|
fn TypeResolver::computed_member_type(
  self : TypeResolver,
  operation : Bytes,
  declaration : DeclId,
  arguments : Array[ResolvedTypeId],
  selector : String,
) -> Result[ResolvedTypeId, String] {
  let field_query = operation == b"types.field_type"
  let values : Array[ResolvedTypeId] = []
  let mut generics = empty_hir_span(0)
  let mut found = false
  if semantic_id_module(declaration) == self.collected.module_id {
    generics = self.collected.generic_parameters_of(declaration)
    let kind = match self.collected.declaration(declaration) {
      Some(TopLevelReference(value)) => value.kind
      _ => return Err("CT-032 invalid member type owner")
    }
    if (field_query && kind != StructDecl) || (!field_query && kind != EnumDecl) {
      return Err(
        "CT-032 field_type requires a struct; variant_payload_types requires an enum",
      )
    }
    if field_query {
      for field in self.collected.fields {
        if field.declaration == declaration &&
          field.variant is None &&
          self.collected.name(field.name) == selector {
          values.push(self.computed_dependency(declaration, field.type_))
          found = true
          break
        }
      }
    } else {
      for variant in self.collected.variants {
        if variant.declaration != declaration ||
          self.collected.name(variant.name) != selector {
          continue
        }
        found = true
        if variant.kind == StructVariantDecl {
          for field in self.collected.fields {
            if field.variant == Some(variant.id) {
              values.push(self.computed_dependency(declaration, field.type_))
            }
          }
        } else {
          for index in 0..<variant.payload_types.length {
            values.push(
              self.computed_dependency(
                declaration,
                self.collected.type_arguments[variant.payload_types.start +
                index],
              ),
            )
          }
        }
        break
      }
    }
  } else {
    let scope = match self.imports {
      Some(scope) => scope
      None => return Err("CT-032 missing imported member type owner")
    }
    let binding = match scope.declaration_bindings.get(declaration) {
      Some(index) => scope.declarations[index]
      None => return Err("CT-032 missing imported type declaration")
    }
    if (field_query && binding.source_kind != StructDecl) ||
      (!field_query && binding.source_kind != EnumDecl) {
      return Err(
        "CT-032 field_type requires a struct; variant_payload_types requires an enum",
      )
    }
    generics = binding.generic_parameters
    let interface_ = scope.interfaces[binding.interface_index].unwrap()
    if field_query {
      for field in interface_.fields {
        if field.declaration == declaration &&
          field.variant is None &&
          field.name == selector {
          values.push(
            self.import_interface_type(binding.interface_index, field.type_),
          )
          found = true
          break
        }
      }
    } else {
      for variant in interface_.variants {
        if variant.declaration != declaration || variant.name != selector {
          continue
        }
        found = true
        if variant.kind == StructVariantDecl {
          for field in interface_.fields {
            if field.variant == Some(variant.variant) {
              values.push(
                self.import_interface_type(binding.interface_index, field.type_),
              )
            }
          }
        } else {
          for index in 0..<variant.payload_types.length {
            values.push(
              self.import_interface_type(
                binding.interface_index,
                interface_.variant_payload_types[variant.payload_types.start +
                index],
              ),
            )
          }
        }
        break
      }
    }
  }
  if !found {
    return Err("CT-032 no such member: " + selector)
  }
  if generics.length != arguments.length() {
    return Err("CT-031 member owner has the wrong generic arity")
  }
  for index, value in values {
    if value == self.interner.error_type {
      return Err("CT-033 invalid member type dependency")
    }
    values[index] = self.substitute_declared_type(
      declaration, generics, value, arguments,
    )
  }
  Ok(if field_query { values[0] } else { self.interner.intern_product(values) })
}

///|
fn TypeResolver::resolve_computed_type(
  self : TypeResolver,
  owner : DeclId,
  target : HirTypeId,
  selector : Bytes,
  offset : UInt64,
) -> ResolvedTypeId {
  let result = self.evaluate_computed_type(owner, target, selector)
  match result {
    Ok(type_) => type_
    Err(message) => {
      self.diagnose(ComputedTypeFailure(owner, message, offset))
      self.interner.error_type
    }
  }
}

///|
fn TypeResolver::evaluate_computed_type(
  self : TypeResolver,
  owner : DeclId,
  target : HirTypeId,
  selector : Bytes,
) -> Result[ResolvedTypeId, String] {
  let (callee, arguments) = match self.collected.type_syntax[target] {
    AppliedTypeSyntax(callee, arguments, _) if arguments.length == 1 =>
      (callee, arguments)
    _ => return Err("CT-031 member type queries require one type argument")
  }
  let operation = match self.computed_builtin_recipe(callee) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let input = self.computed_dependency(
    owner,
    self.collected.type_arguments[arguments.start],
  )
  if input == self.interner.error_type {
    return Err("CT-033 invalid queried type")
  }
  let (declaration, types) = match self.computed_nominal(input) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let selector = @utf8.decode(selector) catch {
    _ => return Err("CT-032 member selector must be valid UTF-8")
  }
  self.computed_member_type(operation, declaration, types, selector)
}
