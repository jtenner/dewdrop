///|
fn body_signature_test_program() -> (CollectedProgram, AnalyzedProgramSemantics) raise {
  let program = collect_program_manifest(
    22907UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn identity<t>(value: t) -> t {\n  value\n}\nfn reader<t>() -> fn(t) -> t {\n  identity\n}\npub fn run(left: I32, right: I64) -> I64 {\n  let callback = reader::<(I32, I64)>()\n  let (_, selected) = callback((left, right))\n  selected\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(program.modules[0].diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  (program, analyzed)
}

///|
test "body signatures extend lowering without changing frozen interfaces" {
  let (program, analyzed) = body_signature_test_program()
  let frozen = analyzed.frozen.interfaces[0].resolved_types
  let original_types = frozen.types.copy()
  let original_arguments = frozen.type_arguments.copy()
  let lowering = plan_program_lowering(program, analyzed)
  let module_ = lowering.modules[0]
  assert_eq(frozen.types, original_types)
  assert_eq(frozen.type_arguments, original_arguments)
  assert_true(module_.resolved_types.length() > original_types.length())
  let mut found = false
  for expression in module_.expressions {
    match expression.kind {
      PlannedFunctionValueCall(_, _, type_) => {
        assert_true(type_ >= 0 && type_ < module_.resolved_types.length())
        match module_.resolved_types[type_] {
          FunctionType(parameters, result) => {
            assert_eq(parameters.length, 1)
            let parameter = module_.resolved_type_arguments[parameters.start]
            assert_eq(parameter, result)
            match module_.resolved_types[parameter] {
              ProductType(fields) => {
                assert_eq(fields.length, 2)
                assert_eq(
                  module_.resolved_types[module_.resolved_type_arguments[fields.start]],
                  PrimitiveType(I32Type),
                )
                assert_eq(
                  module_.resolved_types[module_.resolved_type_arguments[fields.start +
                  1]],
                  PrimitiveType(I64Type),
                )
              }
              _ => fail("callback must retain a concrete product parameter")
            }
          }
          _ => fail("callback must retain a function signature")
        }
        found = true
      }
      _ => ()
    }
  }
  assert_true(found)
  let repeated = plan_program_lowering(program, analyzed).modules[0]
  assert_eq(module_.resolved_types, repeated.resolved_types)
  assert_eq(module_.resolved_type_arguments, repeated.resolved_type_arguments)
}

///|
test "body signature interning checks structural equality after hash lookup" {
  let (_, analyzed) = body_signature_test_program()
  let resolved = analyzed.frozen.interfaces[0].resolved_types
  let pool = BodySignaturePool::new(resolved)
  let i32_type = resolved.primitive(I32Type)
  let i64_type = resolved.primitive(I64Type)
  let first = pool.intern(3, i64_type, [i32_type])
  let wrong_hash = body_signature_hash(3, i32_type, [i64_type], {
    start: 0,
    length: 1,
  })
  // Force a collision in one bucket; equality must still check the full key.
  pool.buckets[wrong_hash] = [first]
  let second = pool.intern(3, i32_type, [i64_type])
  assert_false(first == second)
  assert_eq(pool.intern(3, i32_type, [i64_type]), second)
}

///|
test "missing and erroneous body types do not create callback signatures" {
  let (_, analyzed) = body_signature_test_program()
  let resolved = analyzed.frozen.interfaces[0].resolved_types
  for
    argument in [
      BodyErrorType,
      BodyVariableType(0),
      BodyResolvedType(resolved.error_type),
    ] {
    let inferred = {
      ..analyzed.modules[0].inferred,
      types: [
        argument,
        BodyFunctionType(
          { start: 0, length: 1, },
          -resolved.primitive(I64Type) - 2,
        ),
      ],
      type_arguments: [0],
    }
    let extended = materialize_body_function_types(resolved, inferred)
    assert_eq(extended.types, resolved.types)
    assert_eq(extended.type_arguments, resolved.type_arguments)
  }
}
