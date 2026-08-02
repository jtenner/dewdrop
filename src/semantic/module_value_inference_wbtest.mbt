///|
fn module_value_test(
  module_id : UInt64,
  source : Bytes,
) -> (
  CollectedModule,
  ResolvedModuleTypes,
  ResolvedModuleNames,
  InferredModuleValues,
  InferredModuleBodies,
) {
  let collected = collect_bytes(module_id, source)
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let values = infer_module_values(collected, resolved, names)
  let bodies = infer_module_bodies(collected, resolved, names)
  (collected, resolved, names, values, bodies)
}

///|
fn assert_module_value_primitive(
  values : InferredModuleValues,
  resolved : ResolvedModuleTypes,
  type_ : BodyTypeId,
  primitive : PrimitiveType,
) -> Unit {
  match values.type_term(type_) {
    BodyResolvedType(resolved_type) =>
      if resolved_type != resolved.primitive(primitive) {
        abort("unexpected module value primitive")
      }
    _ => abort("expected module value primitive")
  }
}

///|
test "module value inference resolves forward acyclic references" {
  let (collected, resolved, _, values, inferred) = module_value_test(
    130UL, b"let first = second + 1\nlet second = 2\nlet third = first + second\nfn read() -> I32 {\n  third\n}\n",
  )
  assert_eq(values.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  assert_eq(values.let_types.length(), 3)
  for type_ in values.let_types {
    assert_module_value_primitive(values, resolved, type_, I32Type)
  }
  assert_eq(inferred.module_values, values)
  assert_call_primitive(
    inferred,
    resolved,
    inferred.body(collected.bodies[3].id).unwrap().root_type,
    I32Type,
  )
}

///|
test "module value SCC inference shares constraints across mutual references" {
  let (_, resolved, _, values, inferred) = module_value_test(
    131UL, b"let first = second\nlet second = first + 1\n",
  )
  assert_eq(values.dependencies.sccs.length(), 1)
  assert_eq(values.dependencies.sccs[0].length, 2)
  assert_eq(values.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  for type_ in values.let_types {
    assert_module_value_primitive(values, resolved, type_, I32Type)
  }
}

///|
test "unconstrained module value cycles diagnose every affected declaration" {
  let (collected, _, _, values, inferred) = module_value_test(
    132UL, b"let first = second\nlet second = first\nlet self = self\n",
  )
  let mut unresolved_values = 0
  for diagnostic in values.diagnostics {
    match diagnostic {
      UnresolvedModuleValue(_, _) => unresolved_values += 1
      _ => ()
    }
  }
  assert_eq(unresolved_values, 3)
  assert_eq(values.let_types, [0, 0, 0])
  let mut integrated_unresolved = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      UnresolvedModuleValue(_, _) => integrated_unresolved += 1
      _ => ()
    }
  }
  assert_eq(integrated_unresolved, 3)
  for body in collected.bodies {
    assert_eq(inferred.body(body.id).unwrap().root_type, 0)
  }
}

///|
test "module value applied types import into independent function solvers" {
  let (collected, resolved, _, values, inferred) = module_value_test(
    133UL, b"struct Box<t> {\n  value: t\n}\nbuiltin box<t>(value: t) -> Box<t> = \"box\"\nlet boxed = box(1)\nfn read() -> Box<I32> {\n  boxed\n}\n",
  )
  assert_eq(values.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let value_type = values.let_types[0]
  match values.type_term(value_type) {
    BodyAppliedType(base, arguments) => {
      assert_eq(arguments.length, 1)
      match values.type_term(base) {
        BodyResolvedType(base_type) =>
          match resolved.types[base_type] {
            NominalType(declaration) =>
              assert_eq(declaration, collected.declarations[0].id)
            _ => fail("expected Box nominal constructor")
          }
        _ => fail("expected resolved Box base")
      }
      assert_module_value_primitive(
        values,
        resolved,
        values.type_arguments[arguments.start],
        I32Type,
      )
    }
    _ => fail("expected frozen applied module value type")
  }
  let function_body = collected.bodies[1]
  match inferred.type_term(inferred.body(function_body.id).unwrap().root_type) {
    BodyResolvedType(type_) =>
      match resolved.types[type_] {
        AppliedType(base, arguments) => {
          assert_eq(arguments.length, 1)
          match resolved.types[base] {
            NominalType(declaration) =>
              assert_eq(declaration, collected.declarations[0].id)
            _ => fail("expected canonical Box return base")
          }
        }
        _ => fail("expected canonical Box return type")
      }
    BodyAppliedType(_, _) => ()
    _ => fail("expected imported applied function result")
  }
}

///|
test "module values can select generic and overloaded calls before functions" {
  let (collected, resolved, _, values, inferred) = module_value_test(
    134UL, b"fn identity<t>(value: t) -> t {\n  value\n}\nbuiltin convert(value: I32) -> I64 = \"i32_to_i64\"\nbuiltin convert(value: F32) -> F64 = \"f32_to_f64\"\nlet flag = identity(true)\nlet converted = convert(1)\nfn read_flag() -> Bool {\n  flag\n}\nfn read_converted() -> I64 {\n  converted\n}\n",
  )
  assert_eq(values.diagnostics.length(), 0)
  assert_module_value_primitive(values, resolved, values.let_types[0], BoolType)
  assert_module_value_primitive(values, resolved, values.let_types[1], I64Type)
  assert_eq(inferred.diagnostics.length(), 0)
  assert_call_primitive(
    inferred,
    resolved,
    inferred.body(collected.bodies[3].id).unwrap().root_type,
    BoolType,
  )
  assert_call_primitive(
    inferred,
    resolved,
    inferred.body(collected.bodies[4].id).unwrap().root_type,
    I64Type,
  )
}

///|
test "module value and function inference stay deterministic across body order" {
  let collected = collect_bytes(
    135UL, b"let first = second + 1\nlet second = 2\nfn read_first() -> I32 {\n  first\n}\nfn read_second() -> I32 {\n  second\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let forward = infer_module_bodies_in_order(collected, resolved, names, [
    0, 1, 2, 3,
  ])
  let reverse = infer_module_bodies_in_order(collected, resolved, names, [
    3, 2, 1, 0,
  ])
  assert_eq(forward, reverse)
}
