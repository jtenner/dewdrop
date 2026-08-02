///|
test "type resolution canonicalizes primitives generics and applications" {
  let collected = collect_bytes(
    40UL, b"struct Pair<t> {\n  first: t\n  second: I32\n}\nenum Result<t> {\n  Ok(t)\n}\nfn identity<t>(value: Pair<t>) -> Pair<t> {\n  value\n}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(resolved.field_types[0], resolved.generic_parameter_types[0])
  assert_eq(resolved.field_types[1], resolved.primitive(I32Type))
  match
    resolved.types[resolved.declaration_type(collected.declarations[0].id)] {
    NominalType(declaration) =>
      assert_eq(declaration, collected.declarations[0].id)
    _ => fail("expected declaration type constructor")
  }
  let function_parameter = collected.parameters_of(collected.declarations[2].id)
  let parameter_type = resolved.parameter_types[function_parameter.start]
  let return_type = resolved.callable_return_types[0]
  assert_eq(parameter_type, return_type)
  match resolved.types[return_type] {
    AppliedType(base, arguments) => {
      assert_eq(arguments.length, 1)
      match resolved.types[base] {
        NominalType(declaration) =>
          assert_eq(declaration, collected.declarations[0].id)
        _ => fail("expected Pair constructor")
      }
      assert_eq(
        resolved.type_arguments[arguments.start],
        resolved.generic_parameter_types[2],
      )
    }
    _ => fail("expected canonical applied Pair type")
  }
  assert_eq(resolved.variant_payloads[0].length, 1)
  assert_eq(
    resolved.signature_type_lists[resolved.variant_payloads[0].start],
    resolved.generic_parameter_types[1],
  )
}

///|
test "function types intern canonically and normalize generic aliases" {
  let collected = collect_bytes(
    56UL, b"type Callback<t> = fn(t) -> t\nfn passthrough(value: Callback<I32>) -> fn(I32) -> I32 {\n  value\n}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(resolved.parameter_types[0], resolved.callable_return_types[0])
  match resolved.types[resolved.parameter_types[0]] {
    FunctionType(parameters, result) => {
      assert_eq(parameters.length, 1)
      assert_eq(
        resolved.type_arguments[parameters.start],
        resolved.primitive(I32Type),
      )
      assert_eq(result, resolved.primitive(I32Type))
    }
    _ => fail("expected normalized function type")
  }
}

///|
test "lambda signatures resolve canonically in their root generic context" {
  let collected = collect_bytes(
    57UL, b"fn wrap<t>(value: t) -> t {\n  let callback = fn(item: t, transform: fn(t) -> I32) -> t {\n    item\n  }\n  value\n}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(resolved.lambda_parameter_types.length(), 2)
  assert_eq(resolved.lambda_return_types.length(), 1)
  assert_eq(resolved.lambda_function_types.length(), 1)
  let generic = resolved.generic_parameter_types[0]
  assert_eq(resolved.lambda_parameter_types[0], generic)
  assert_eq(resolved.lambda_return_types[0], generic)
  match resolved.types[resolved.lambda_parameter_types[1]] {
    FunctionType(parameters, result) => {
      assert_eq(parameters.length, 1)
      assert_eq(resolved.type_arguments[parameters.start], generic)
      assert_eq(result, resolved.primitive(I32Type))
    }
    _ => fail("expected nested lambda parameter function type")
  }
  match resolved.types[resolved.lambda_function_types[0]] {
    FunctionType(parameters, result) => {
      assert_eq(parameters.length, 2)
      assert_eq(resolved.type_arguments[parameters.start], generic)
      assert_eq(
        resolved.type_arguments[parameters.start + 1],
        resolved.lambda_parameter_types[1],
      )
      assert_eq(result, generic)
    }
    _ => fail("expected canonical lambda function type")
  }
}

///|
test "type resolution diagnoses unknown names and generic arity" {
  let collected = collect_bytes(
    41UL, b"struct Box<t> {}\nfn bad<t>(a: Missing, b: Box, c: I32<String>, d: t<I32>, e: Unknown) -> Unit {}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 5)
  let mut unknown_count = 0
  let mut arity_count = 0
  let mut not_applicable_count = 0
  for diagnostic in resolved.diagnostics {
    match diagnostic {
      UnknownType(_, _, _) => unknown_count += 1
      TypeArityMismatch(_, _, _, _, _) => arity_count += 1
      TypeNotApplicable(_, _, _) => not_applicable_count += 1
      _ => ()
    }
  }
  assert_eq(unknown_count, 2)
  assert_eq(arity_count, 2)
  assert_eq(not_applicable_count, 1)
  let parameters = collected.parameters_of(collected.declarations[1].id)
  for index in parameters.start..<(parameters.start + parameters.length) {
    assert_eq(resolved.parameter_types[index], resolved.error_type)
  }
  assert_eq(resolved.callable_return_types[0], resolved.primitive(UnitType))
}

///|
test "trait and impl signatures resolve parent generic and Self scopes" {
  let collected = collect_bytes(
    42UL, b"trait Convert<t> {\n  fn convert(self, value: t) -> Self\n}\nstruct Box<t> {\n  value: t\n}\nimpl<a> Convert<a> for Box<a> {\n  fn convert(self, value: a) -> a {\n    value\n  }\n}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 0)
  match resolved.types[resolved.impl_trait_types[0]] {
    AppliedType(base, arguments) => {
      match resolved.types[base] {
        TraitType(declaration) =>
          assert_eq(declaration, collected.declarations[0].id)
        _ => fail("expected resolved trait constructor")
      }
      assert_eq(arguments.length, 1)
    }
    _ => fail("expected applied trait type")
  }
  match resolved.types[resolved.impl_target_types[0]] {
    AppliedType(base, arguments) => {
      match resolved.types[base] {
        NominalType(declaration) =>
          assert_eq(declaration, collected.declarations[1].id)
        _ => fail("expected Box target")
      }
      assert_eq(arguments.length, 1)
    }
    _ => fail("expected applied impl target")
  }
  let trait_receiver = collected.parameters_of(collected.methods[0].id)
  match resolved.types[resolved.parameter_types[trait_receiver.start]] {
    SelfType(declaration) =>
      assert_eq(declaration, collected.declarations[0].id)
    _ => fail("expected trait Self receiver")
  }
  match resolved.types[resolved.callable_return_types[0]] {
    SelfType(declaration) =>
      assert_eq(declaration, collected.declarations[0].id)
    _ => fail("expected trait Self return")
  }
  let impl_receiver = collected.parameters_of(collected.methods[1].id)
  match resolved.types[resolved.parameter_types[impl_receiver.start]] {
    SelfType(declaration) =>
      assert_eq(declaration, collected.declarations[2].id)
    _ => fail("expected impl Self receiver")
  }
}

///|
test "top-level shorthand self has no implicit Self context" {
  let collected = collect_bytes(43UL, b"fn invalid(self) -> Unit {}\n")
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 1)
  match resolved.diagnostics[0] {
    SelfOutsideContext(declaration, _) =>
      assert_eq(declaration, collected.declarations[0].id)
    _ => fail("expected missing Self context diagnostic")
  }
  assert_eq(resolved.parameter_types[0], resolved.error_type)
}

///|
test "impl trait positions distinguish non-traits and unknown traits" {
  let collected = collect_bytes(
    44UL, b"struct Display {}\nimpl Display for I32 {}\nimpl Missing for I32 {}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 2)
  match resolved.diagnostics[0] {
    ExpectedTraitType(name, _, _) => assert_eq(collected.name(name), "Display")
    _ => fail("expected non-trait diagnostic")
  }
  match resolved.diagnostics[1] {
    UnknownTrait(name, _, _) => assert_eq(collected.name(name), "Missing")
    _ => fail("expected unknown trait diagnostic")
  }
  assert_eq(resolved.impl_trait_types[0], resolved.error_type)
  assert_eq(resolved.impl_trait_types[1], resolved.error_type)
}

///|
test "primitive and Self type names are reserved" {
  let collected = collect_bytes(45UL, b"struct I32 {}\ntype Self = I32\n")
  let resolved = resolve_module_types(collected)
  let mut reserved_count = 0
  for diagnostic in resolved.diagnostics {
    match diagnostic {
      ReservedTypeName(_, _, _) => reserved_count += 1
      _ => ()
    }
  }
  assert_eq(reserved_count, 2)
  assert_eq(resolved.alias_target_types[0], resolved.primitive(I32Type))
}

///|
test "alias dependency collection deduplicates nested applications" {
  let collected = collect_bytes(
    48UL, b"struct Pair<a, b> {}\ntype Element<t> = t\ntype Wrapped<t> = Pair<Element<t>, Element<t>>\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(resolved.alias_dependencies[0].length, 0)
  let wrapped = resolved.alias_dependencies[1]
  assert_eq(wrapped.length, 1)
  assert_eq(
    resolved.alias_dependency_declarations[wrapped.start],
    collected.aliases[0].declaration,
  )
}

///|
test "alias dependency analysis reports deterministic SCC cycles" {
  let collected = collect_bytes(
    46UL, b"type A = B\ntype B = C\ntype C = A\ntype Stable = I32\ntype SelfCycle = SelfCycle\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.alias_cycles.length(), 2)
  assert_true(resolved.alias_is_cyclic[0])
  assert_true(resolved.alias_is_cyclic[1])
  assert_true(resolved.alias_is_cyclic[2])
  assert_false(resolved.alias_is_cyclic[3])
  assert_true(resolved.alias_is_cyclic[4])
  assert_eq(resolved.alias_cycles[0].length, 3)
  assert_eq(resolved.alias_cycles[1].length, 1)
  let first = resolved.alias_cycles[0]
  assert_eq(
    resolved.alias_cycle_declarations[first.start],
    collected.aliases[0].declaration,
  )
  assert_eq(
    resolved.alias_cycle_declarations[first.start + 2],
    collected.aliases[2].declaration,
  )
  let mut cycle_diagnostics = 0
  for diagnostic in resolved.diagnostics {
    match diagnostic {
      AliasCycle(_, _) => cycle_diagnostics += 1
      _ => ()
    }
  }
  assert_eq(cycle_diagnostics, 2)
}

///|
fn cyclic_alias_module(alias_count : Int) -> Bytes {
  let output = Buffer(size_hint=alias_count * 40)
  for index in 0..<alias_count {
    output.write_string_utf8("type Alias_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = Alias_")
    output.write_string_utf8(((index + 1) % alias_count).to_string())
    output.write_byte(b'\n')
  }
  output.to_bytes()
}

///|
test "alias SCC analysis remains iterative for 1024 aliases" {
  let collected = collect_bytes(47UL, cyclic_alias_module(1024))
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.alias_cycles.length(), 1)
  assert_eq(resolved.alias_cycles[0].length, 1024)
  assert_eq(resolved.diagnostics.length(), 1)
  for cyclic in resolved.alias_is_cyclic {
    assert_true(cyclic)
  }
}

///|
test "zero-argument aliases normalize signatures and syntax lookups" {
  let collected = collect_bytes(
    49UL, b"type Count = I32\nfn identity(value: Count) -> Count {\n  value\n}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(resolved.parameter_types[0], resolved.primitive(I32Type))
  assert_eq(resolved.callable_return_types[0], resolved.primitive(I32Type))
  let parameter_syntax = collected.parameters[0].type_
  match resolved.types[resolved.syntax_type(parameter_syntax)] {
    NominalType(declaration) =>
      assert_eq(declaration, collected.aliases[0].declaration)
    _ => fail("expected source-preserving alias syntax type")
  }
  match
    resolved.types[resolved.declaration_type(collected.aliases[0].declaration)] {
    NominalType(declaration) =>
      assert_eq(declaration, collected.aliases[0].declaration)
    _ => fail("expected alias declaration constructor to remain nominal")
  }
}

///|
test "aliases normalize fields variants and impl targets" {
  let collected = collect_bytes(
    55UL, b"type Count = I32\nstruct Holder {\n  value: Count\n}\nenum Event {\n  Value(Count)\n}\nimpl Count {}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(resolved.field_types[0], resolved.primitive(I32Type))
  let payload = resolved.variant_payloads[0]
  assert_eq(payload.length, 1)
  assert_eq(
    resolved.signature_type_lists[payload.start],
    resolved.primitive(I32Type),
  )
  assert_eq(resolved.impl_trait_types[0], -1)
  assert_eq(resolved.impl_target_types[0], resolved.primitive(I32Type))
}

///|
test "generic aliases substitute and normalize nested applications" {
  let collected = collect_bytes(
    50UL, b"struct Pair<a, b> {}\ntype Left<t> = Pair<t, I32>\ntype Wrapped<u> = Left<Pair<u, u>>\nfn use(value: Wrapped<String>, again: Wrapped<String>) -> Left<String> {\n  value\n}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(resolved.parameter_types[0], resolved.parameter_types[1])
  let pair_declaration = collected.declarations[0].id
  match resolved.types[resolved.parameter_types[0]] {
    AppliedType(base, outer_arguments) => {
      match resolved.types[base] {
        NominalType(declaration) => assert_eq(declaration, pair_declaration)
        _ => fail("expected normalized outer Pair")
      }
      assert_eq(outer_arguments.length, 2)
      match resolved.types[resolved.type_arguments[outer_arguments.start]] {
        AppliedType(inner_base, inner_arguments) => {
          match resolved.types[inner_base] {
            NominalType(declaration) => assert_eq(declaration, pair_declaration)
            _ => fail("expected normalized inner Pair")
          }
          assert_eq(inner_arguments.length, 2)
          assert_eq(
            resolved.type_arguments[inner_arguments.start],
            resolved.primitive(StringType),
          )
          assert_eq(
            resolved.type_arguments[inner_arguments.start + 1],
            resolved.primitive(StringType),
          )
        }
        _ => fail("expected substituted inner Pair")
      }
      assert_eq(
        resolved.type_arguments[outer_arguments.start + 1],
        resolved.primitive(I32Type),
      )
    }
    _ => fail("expected normalized Wrapped application")
  }
  match resolved.types[resolved.callable_return_types[0]] {
    AppliedType(_, arguments) => {
      assert_eq(
        resolved.type_arguments[arguments.start],
        resolved.primitive(StringType),
      )
      assert_eq(
        resolved.type_arguments[arguments.start + 1],
        resolved.primitive(I32Type),
      )
    }
    _ => fail("expected normalized Left application")
  }
}

///|
test "cyclic and transitively cyclic aliases normalize to the poison type" {
  let collected = collect_bytes(
    51UL, b"type A = B\ntype B = A\ntype C = A\nfn use(value: C) -> Unit {}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.alias_cycles.length(), 1)
  assert_true(resolved.alias_is_cyclic[0])
  assert_true(resolved.alias_is_cyclic[1])
  assert_false(resolved.alias_is_cyclic[2])
  assert_eq(resolved.parameter_types[0], resolved.error_type)
  assert_eq(resolved.diagnostics.length(), 1)
  match resolved.diagnostics[0] {
    AliasCycle(_, _) => ()
    _ => fail("expected only the root alias cycle diagnostic")
  }
}

///|
test "alias expansion budget emits one deterministic poison diagnostic" {
  let collected = collect_bytes(
    52UL, b"type Count = I32\nfn use(value: Count) -> Count {\n  value\n}\n",
  )
  let resolved = resolve_module_types_with_alias_expansion_limit(collected, 0)
  assert_eq(resolved.alias_expansion_limit, 0)
  assert_eq(resolved.alias_expansion_work, 0)
  assert_eq(resolved.parameter_types[0], resolved.error_type)
  assert_eq(resolved.callable_return_types[0], resolved.error_type)
  assert_eq(resolved.diagnostics.length(), 1)
  match resolved.diagnostics[0] {
    AliasExpansionLimit(declaration, limit, _) => {
      assert_eq(declaration, collected.aliases[0].declaration)
      assert_eq(limit, 0)
    }
    _ => fail("expected alias expansion limit diagnostic")
  }
}

///|
test "normalization propagates poison through applied arguments" {
  let collected = collect_bytes(
    53UL, b"struct Box<t> {}\nfn invalid(value: Box<Missing>) -> Unit {}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 1)
  assert_eq(resolved.parameter_types[0], resolved.error_type)
}

///|
fn acyclic_alias_module(alias_count : Int) -> Bytes {
  let output = Buffer(size_hint=alias_count * 44 + 80)
  output.write_string_utf8("type Alias_0 = I32\n")
  for index in 1..<alias_count {
    output.write_string_utf8("type Alias_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = Alias_")
    output.write_string_utf8((index - 1).to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("fn use(value: Alias_")
  output.write_string_utf8((alias_count - 1).to_string())
  output.write_string_utf8(") -> I32 {\n  value\n}\n")
  output.to_bytes()
}

///|
test "transparent normalization remains iterative for 1024 aliases" {
  let collected = collect_bytes(54UL, acyclic_alias_module(1024))
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(resolved.alias_expansion_work, 1024)
  assert_eq(resolved.parameter_types[0], resolved.primitive(I32Type))
}
