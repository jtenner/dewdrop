///|
fn TypeResolver::contains_compile_time_type(
  self : TypeResolver,
  root : ResolvedTypeId,
) -> Bool {
  let work = [root]
  let visited : Map[ResolvedTypeId, Bool] = Map([])
  while work.length() > 0 {
    let current = work.pop().unwrap()
    if current < 0 {
      continue
    }
    guard current < self.interner.types.length() else {
      abort("ARN-104 type storage check is outside its arena")
    }
    if visited.contains(current) {
      continue
    }
    visited[current] = true
    match self.interner.types[current] {
      PrimitiveType(CompileTimeTypeType) => return true
      ProductType(arguments)
      | AppliedType(_, arguments)
      | FunctionType(arguments, _) => {
        guard program_specialization_span_is_valid(
          arguments,
          self.interner.arguments.length(),
        ) else {
          abort("ARN-101 type storage arguments are outside their arena")
        }
        for index in 0..<arguments.length {
          work.push(self.interner.arguments[arguments.start + index])
        }
        match self.interner.types[current] {
          AppliedType(base, _) => work.push(base)
          FunctionType(_, result) => work.push(result)
          _ => ()
        }
      }
      _ => ()
    }
  }
  false
}

///|
fn TypeResolver::check_compile_time_storage(
  self : TypeResolver,
  declaration : DeclId,
  type_ : ResolvedTypeId,
  offset : UInt64,
) -> Unit {
  if self.contains_compile_time_type(type_) {
    self.diagnose(
      ComputedTypeFailure(
        declaration, "CT-037 Type is compile-time-only and has no runtime storage",
        offset,
      ),
    )
  }
}

///|
// Run after aliases are normalized, before inference/physical planning. A
// metatype must never acquire an eqref or be silently erased from runtime data.
fn TypeResolver::validate_compile_time_storage(self : TypeResolver) -> Unit {
  for index, callable in self.collected.callables {
    let declaration = callable.declaration
    let parameters = self.collected.parameters_of(declaration)
    for offset in 0..<parameters.length {
      let parameter = self.collected.parameters[parameters.start + offset]
      self.check_compile_time_storage(
        declaration,
        self.parameter_types[parameters.start + offset],
        parameter.offset,
      )
    }
    let mut type_query = false
    for builtin in self.collected.builtins {
      if builtin.declaration == declaration &&
        computed_type_builtin(builtin.builtin_name) {
        type_query = true
        break
      }
    }
    if !type_query {
      self.check_compile_time_storage(
        declaration,
        self.callable_return_types[index],
        self.collected.type_syntax[callable.return_type].offset(),
      )
    }
  }
  for index, field in self.collected.fields {
    self.check_compile_time_storage(
      field.declaration,
      self.field_types[index],
      field.offset,
    )
  }
  for index, variant in self.collected.variants {
    let payload = self.variant_payloads[index]
    for offset in 0..<payload.length {
      self.check_compile_time_storage(
        variant.declaration,
        self.signature_type_lists[payload.start + offset],
        variant.offset,
      )
    }
  }
  for index, lambda in self.collected.lambdas {
    let declaration = self.collected.bodies[semantic_id_local(lambda.root_body)].declaration
    self.check_compile_time_storage(
      declaration,
      self.lambda_return_types[index],
      self.collected.type_syntax[lambda.return_type].offset(),
    )
    for offset in 0..<lambda.parameters.length {
      let slot = lambda.parameters.start + offset
      self.check_compile_time_storage(
        declaration,
        self.lambda_parameter_types[slot],
        self.collected.lambda_parameters[slot].offset,
      )
    }
  }
}
