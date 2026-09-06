///|
test "compile time discarded generic lambda has no template signature" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn ignore<t>(value: t) -> I32 {\n  8i32\n}\nfn choose<t>() -> I32 {\n  if is_unit::<t>() {\n    7i32\n  } else {\n    let unused = fn(value: field_type<t>(\"item\")) -> I32 {\n      8i32\n    }\n    ignore(unused)\n  }\n}\npub fn main() -> I32 {\n  choose::<Unit>()\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  assert_false(lowering.modules[0].lambdas[0].elided)
  let plan = plan_program_wasmgc_fragments(analyzed, lowering)
  assert_eq(validate_module_wasmgc_arenas(plan.modules[0]), Ok(()))
  for function_ in plan.modules[0].functions {
    assert_false(function_.kind is PlannedWasmDefinedLambdaFunction(_))
  }
  for type_ in plan.modules[0].physical_types {
    assert_false(type_.kind is PlannedWasmLambdaClosureType(_))
    assert_false(type_.kind is PlannedWasmCaptureCellType(_))
  }
}

///|
test "compile time lambda layouts preserve exact scalar and erased captures" {
  let program = collect_program_manifest(
    24910UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nfn capture<t>(value: t) -> fn() -> t {\n  fn() -> t {\n    let _ = is_unit::<t>()\n    value\n  }\n}\npub fn main() -> I64 {\n  let unit = capture::<Unit>(())\n  let scalar = capture::<I64>(42i64)\n  unit()\n  scalar()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let planned = plan_program_wasmgc_fragments(analyzed, lowering)
  let fragments = planned.modules[0]
  assert_eq(validate_module_wasmgc_arenas(fragments), Ok(()))
  let mut checked = 0
  for key, layout in fragments.specialized_lambda_layouts {
    let instance = program_function_lowering(lowering, 0, key)
    let selected = program_function_fragments(instance, fragments, key)
    for index, lambda in instance.lambdas {
      if lambda.elided || layout.closure_types[index] < 0 {
        continue
      }
      let function_ = selected.functions[selected.lambda_function_indices[index]]
      if function_.specialization_abi_key != key {
        continue
      }
      let capture = instance.captures[lambda.captures.start]
      let closure = fragments.physical_types[layout.closure_types[index]]
      match capture.shape {
        UnitPlannedValueShape => {
          assert_eq(closure.fields.length, 1)
          assert_eq(function_.results.length, 0)
          assert_eq(layout.capture_fields[lambda.captures.start], -1)
        }
        I64PlannedValueShape => {
          assert_eq(closure.fields.length, 2)
          assert_eq(function_.results.length, 1)
          assert_eq(
            fragments.fields[closure.fields.start + 1].storage,
            WasmI64Storage,
          )
          assert_eq(
            fragments.function_value_types[function_.results.start],
            WasmI64Value,
          )
        }
        other => fail("unresolved capture: " + @debug.to_string(other))
      }
      checked += 1
    }
  }
  assert_eq(checked, 2)
  let replanned = plan_program_wasmgc_fragments(analyzed, lowering)
  assert_eq(replanned.modules[0].physical_types, fragments.physical_types)
  assert_eq(replanned.modules[0].fields, fragments.fields)
  assert_eq(
    replanned.modules[0].specialized_lambda_layouts,
    fragments.specialized_lambda_layouts,
  )
  let encoded = serialize_planned_module_wasmgc_fragments(fragments).unwrap()
  let decoded = deserialize_planned_module_wasmgc_fragments(encoded).unwrap()
  assert_eq(decoded, fragments)
  assert_eq(
    serialize_planned_module_wasmgc_fragments(decoded).unwrap(),
    encoded,
  )
  let link = link_program_wasmgc_fragments(planned, lowering, 0)
  assert_eq(link.diagnostics, [])
  // One-field negative mutation: no missing lookup can be accepted as empty.
  let first = fragments.specialized_lambda_layouts.iter().next().unwrap()
  let (key, layout) = first
  fragments.specialized_lambda_layouts[key] = { ..layout, capture_fields: [], }
  assert_eq(
    validate_module_wasmgc_arenas(fragments),
    Err("WasmGC specialized lambda lookup arenas have different lengths"),
  )
}
