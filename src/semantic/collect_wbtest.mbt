///|
test "collection assigns deterministic module-local identities" {
  let collected = collect_bytes(
    7UL, b"trait Convert<t> {\n  fn convert(self, value: t) -> t\n}\nimpl<t> Convert<t> for Box<t> {\n  fn convert(self, value: t) -> t {\n    value\n  }\n}\nstruct Pair<t> {\n  first: t\n  second: t\n}\nenum Maybe<t> {\n  None\n  Some(t)\n  Named {\n    value: t\n  }\n}\nfn identity<t>(value: t) -> t {\n  value\n}\ntype Alias<t> = Pair<t>\nlet answer = 42\n",
  )
  assert_eq(collected.declarations.length(), 7)
  assert_eq(collected.methods.length(), 2)
  assert_eq(collected.fields.length(), 3)
  assert_eq(collected.variants.length(), 3)
  assert_eq(collected.generic_parameters.length(), 6)
  assert_eq(collected.parameters.length(), 5)
  assert_eq(collected.callables.length(), 3)
  assert_eq(collected.lets.length(), 1)
  assert_eq(collected.lets[0].mutable_, false)
  assert_eq(collected.impls.length(), 1)
  assert_eq(collected.impls[0].foreign_, false)
  assert_eq(collected.aliases.length(), 1)
  assert_eq(collected.generic_parameters_of(collected.declarations[0].id), {
    start: 0,
    length: 1,
  })
  assert_eq(collected.parameters_of(collected.methods[0].id), {
    start: 0,
    length: 2,
  })
  assert_eq(semantic_id_module(collected.declarations[0].id), 7UL)
  assert_eq(semantic_id_local(collected.declarations[0].id), 0)
  assert_eq(semantic_id_local(collected.methods[0].id), 1)
  assert_eq(semantic_id_local(collected.declarations[1].id), 2)
  assert_eq(semantic_id_local(collected.methods[1].id), 3)
  assert_eq(semantic_id_local(collected.declarations[2].id), 4)
  assert_eq(semantic_id_local(collected.declarations[6].id), 8)
  assert_eq(collected.methods[0].parent, collected.declarations[0].id)
  assert_eq(collected.methods[1].parent, collected.declarations[1].id)
  match collected.declaration(collected.declarations[2].id) {
    Some(TopLevelReference({ kind: StructDecl, .. })) => ()
    _ => fail("expected top-level declaration lookup")
  }
  match collected.declaration(collected.methods[1].id) {
    Some(MethodReference({ kind: ImplMethodDecl, .. })) => ()
    _ => fail("expected method declaration lookup")
  }
  assert_eq(collected.declaration(99UL << 32), None)
  assert_eq(collected.fields[2].variant, Some(collected.variants[2].id))
  assert_eq(collected.diagnostics.length(), 0)
}

///|
test "collection interns repeated names once" {
  let collected = collect_bytes(
    1UL, b"struct Pair<t> {\n  first: t\n  second: t\n}\nfn first<t>(first: t) -> t {\n  first\n}\n",
  )
  let first = collected.find_name("first")
  let t = collected.find_name("t")
  assert_true(first is Some(_))
  assert_true(t is Some(_))
  match (first, t) {
    (Some(first_id), Some(t_id)) => {
      assert_eq(collected.name(first_id), "first")
      assert_eq(collected.name(t_id), "t")
      assert_eq(collected.fields[0].name, first_id)
      assert_eq(collected.declarations[1].name, first_id)
      assert_eq(collected.parameters[0].name, first_id)
      assert_eq(collected.generic_parameters[0].name, t_id)
      assert_eq(collected.generic_parameters[1].name, t_id)
    }
    _ => fail("expected interned names")
  }
}

///|
test "collection lowers signature types into flat child-first HIR" {
  let collected = collect_bytes(
    2UL, b"type Rows<t> = Result<List<t>>\nfn map<t>(rows: Result<List<t>>) -> Result<List<t>> {\n  rows\n}\n",
  )
  assert_eq(collected.aliases.length(), 1)
  let target = collected.aliases[0].target
  match collected.type_syntax[target] {
    AppliedTypeSyntax(base, arguments, _) => {
      match collected.type_syntax[base] {
        NamedTypeSyntax(name, _) => assert_eq(collected.name(name), "Result")
        _ => fail("expected named Result base")
      }
      assert_eq(arguments.length, 1)
      let list = collected.type_arguments[arguments.start]
      match collected.type_syntax[list] {
        AppliedTypeSyntax(list_base, list_arguments, _) => {
          match collected.type_syntax[list_base] {
            NamedTypeSyntax(name, _) => assert_eq(collected.name(name), "List")
            _ => fail("expected named List base")
          }
          assert_eq(list_arguments.length, 1)
          match
            collected.type_syntax[collected.type_arguments[list_arguments.start]] {
            NamedTypeSyntax(name, _) => assert_eq(collected.name(name), "t")
            _ => fail("expected generic name syntax")
          }
        }
        _ => fail("expected applied List type")
      }
    }
    _ => fail("expected applied alias target")
  }
  let function_id = collected.declarations[1].id
  let parameters = collected.parameters_of(function_id)
  assert_eq(parameters.length, 1)
  assert_true(collected.parameters[parameters.start].type_ >= 0)
  assert_true(collected.callables[0].return_type >= 0)
}

///|
fn deeply_applied_alias(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth * 5 + 32)
  output.write_string_utf8("type Deep<t> = ")
  for _ in 0..<depth {
    output.write_string_utf8("Box<")
  }
  output.write_string_utf8("t")
  for _ in 0..<depth {
    output.write_byte(b'>')
  }
  output.write_byte(b'\n')
  output.to_bytes()
}

///|
test "type HIR lowering remains iterative for 1024 applications" {
  let collected = collect_bytes(6UL, deeply_applied_alias(1024))
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.aliases.length(), 1)
  assert_eq(collected.type_syntax.length(), 2049)
  match collected.type_syntax[collected.aliases[0].target] {
    AppliedTypeSyntax(_, arguments, _) => assert_eq(arguments.length, 1)
    _ => fail("expected deeply applied target")
  }
}

///|
test "module namespaces are separate and duplicates are diagnostic" {
  let collected = collect_bytes(
    3UL, b"struct Item {}\ntrait Item {}\nfn Item() -> Unit {}\nstruct Item {}\ntrait Item {}\nlet Item = 1\n",
  )
  assert_true(collected.lookup_type("Item") is Some(_))
  assert_true(collected.lookup_trait("Item") is Some(_))
  assert_true(collected.lookup_value("Item") is Some(_))
  assert_eq(collected.diagnostics.length(), 3)
  match collected.diagnostics[0] {
    DuplicateName({ space: ModuleType, .. }) => ()
    _ => fail("expected duplicate type diagnostic")
  }
  match collected.diagnostics[1] {
    DuplicateName({ space: ModuleTrait, .. }) => ()
    _ => fail("expected duplicate trait diagnostic")
  }
  match collected.diagnostics[2] {
    DuplicateName({ space: ModuleValue, .. }) => ()
    _ => fail("expected duplicate value diagnostic")
  }
}

///|
test "builtin declarations form source-ordered overload sets" {
  let collected = collect_bytes(
    4UL, b"builtin convert(value: I32) -> I64 = \"i32_to_i64\"\nbuiltin convert(value: F32) -> F64 = \"f32_to_f64\"\n",
  )
  let overloads = collected.value_declarations("convert").to_array()
  assert_eq(overloads.length(), 2)
  assert_eq(overloads[0], collected.declarations[0].id)
  assert_eq(overloads[1], collected.declarations[1].id)
  assert_eq(collected.builtins.length(), 2)
  assert_eq(collected.builtins[0].builtin_name, b"i32_to_i64")
  assert_eq(collected.builtins[1].builtin_name, b"f32_to_f64")
  assert_eq(collected.diagnostics.length(), 0)
}

///|
test "collection preserves parse diagnostics and continues" {
  let collected = collect_bytes(
    5UL, b"type Before = I32\nnot a declaration\ntype After = I64\n",
  )
  assert_eq(collected.declarations.length(), 2)
  assert_eq(collected.diagnostics.length(), 1)
  match collected.diagnostics[0] {
    ParseDiagnostic(_, { severity: @parser.Error, .. }) => ()
    _ => fail("expected parser diagnostic")
  }
  assert_true(collected.lookup_type("Before") is Some(_))
  assert_true(collected.lookup_type("After") is Some(_))
}

///|
fn wide_duplicate_scope_module(width : Int) -> Bytes {
  let output = Buffer(size_hint=width * 40 + 96)
  output.write_string_utf8("type Wide<")
  for index in 0..<width {
    if index > 0 {
      output.write_string_utf8(", ")
    }
    output.write_string_utf8("t")
    output.write_string_utf8(index.to_string())
  }
  output.write_string_utf8(", t0> = I32\nstruct Record {\n")
  for index in 0..<width {
    output.write_string_utf8("  field")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": I32\n")
  }
  output.write_string_utf8("  field0: I64\n}\n")
  output.to_bytes()
}

///|
test "large owner scopes switch to hash duplicate detection" {
  let collected = collect_bytes(11UL, wide_duplicate_scope_module(16))
  assert_eq(collected.diagnostics.length(), 2)
  match collected.diagnostics[0] {
    DuplicateName({ space: GenericParameter, .. }) => ()
    _ => fail("expected wide generic duplicate")
  }
  match collected.diagnostics[1] {
    DuplicateName({ space: StructField, .. }) => ()
    _ => fail("expected wide field duplicate")
  }
}

///|
fn large_collection_module(declaration_count : Int) -> Bytes {
  let output = Buffer(size_hint=declaration_count * 32)
  for index in 0..<declaration_count {
    output.write_string_utf8("type Alias_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = I32\n")
  }
  output.to_bytes()
}

///|
test "large module collection remains iterative" {
  let collected = collect_bytes(12UL, large_collection_module(1024))
  assert_eq(collected.declarations.length(), 1024)
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(semantic_id_local(collected.declarations[1023].id), 1023)
}

///|
test "nested collection scopes diagnose their own duplicates" {
  let collected = collect_bytes(
    9UL, b"trait Broken<t, t> {\n  fn same(value: t, value: t) -> t\n  fn same(other: t) -> t\n}\nstruct Record {\n  value: I32\n  value: I64\n}\nenum Choice {\n  Same\n  Same\n  Named {\n    field: I32\n    field: I64\n  }\n}\n",
  )
  let mut generic_count = 0
  let mut parameter_count = 0
  let mut method_count = 0
  let mut field_count = 0
  let mut variant_count = 0
  for diagnostic in collected.diagnostics {
    match diagnostic {
      DuplicateName({ space: GenericParameter, .. }) => generic_count += 1
      DuplicateName({ space: Parameter, .. }) => parameter_count += 1
      DuplicateName({ space: TraitMethod, .. }) => method_count += 1
      DuplicateName({ space: StructField, .. })
      | DuplicateName({ space: VariantField, .. }) => field_count += 1
      DuplicateName({ space: EnumVariant, .. }) => variant_count += 1
      _ => ()
    }
  }
  assert_eq(generic_count, 1)
  assert_eq(parameter_count, 1)
  assert_eq(method_count, 1)
  assert_eq(field_count, 2)
  assert_eq(variant_count, 1)
}
