///|
fn wasmgc_test_inputs(
  module_id : UInt64,
  source : Bytes,
) -> (ResolvedModuleTypes, PlannedModuleLowering) {
  let collected = collect_bytes(module_id, source)
  let resolved = resolve_module_types(collected)
  let layouts = plan_module_type_layouts(collected, resolved)
  let functions = plan_module_functions(collected, resolved)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let initialization = plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = analyze_module_flows(collected, resolved, inferred)
  let lowering = plan_module_lowering(
    collected, resolved, layouts, initialization, functions, names, inferred, flows,
  )
  (resolved, lowering)
}

///|
test "all Preview 1 builtin names select the WASI import namespace" {
  assert_eq(
    wasmgc_builtin_import_identity(b"wasi_snapshot_preview1.args_get"),
    WasmImportIdentity::wasi(b"args_get"),
  )
  assert_eq(
    wasmgc_builtin_import_identity(b"wasi_snapshot_preview1.sock_shutdown"),
    WasmImportIdentity::wasi(b"sock_shutdown"),
  )
  assert_eq(
    wasmgc_builtin_import_identity(b"custom.host"),
    WasmImportIdentity::host(b"custom.host"),
  )
}

///|
test "mutually recursive structs form one stable WasmGC recursive group" {
  let (resolved, lowering) = wasmgc_test_inputs(
    971UL, b"struct Left {\n  right: Right\n}\nstruct Right {\n  left: Left\n}\n",
  )
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_eq(planned.type_groups.length(), 1)
  assert_eq(planned.type_groups[0].types.length, 2)
  assert_eq(planned.physical_types.length(), 2)
  assert_eq(planned.physical_types[0].type_index, 0)
  assert_eq(planned.physical_types[1].type_index, 1)
  assert_eq(
    planned.type_index_of(lowering.type_layouts.layouts[0].declaration),
    Some(0),
  )
  assert_eq(
    planned.type_index_of(lowering.type_layouts.layouts[1].declaration),
    Some(1),
  )
  match planned.fields[planned.physical_types[0].fields.start].storage {
    WasmNominalRefStorage(WasmRecursiveTypeReference(1)) => ()
    _ => fail("expected Left.right to reference recursive member 1")
  }
  match planned.fields[planned.physical_types[1].fields.start].storage {
    WasmNominalRefStorage(WasmRecursiveTypeReference(0)) => ()
    _ => fail("expected Right.left to reference recursive member 0")
  }
}

///|
test "WasmGC type groups are dependency first rather than source first" {
  let (resolved, lowering) = wasmgc_test_inputs(
    972UL, b"struct Outer {\n  inner: Inner\n}\nstruct Inner {\n  value: I32\n}\n",
  )
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  let outer = lowering.type_layouts.layouts[0].declaration
  let inner = lowering.type_layouts.layouts[1].declaration
  assert_eq(planned.type_groups.length(), 2)
  assert_eq(planned.type_index_of(inner), Some(0))
  assert_eq(planned.type_index_of(outer), Some(1))
  match planned.physical_types[1].kind {
    PlannedWasmStructType(actual) => assert_eq(actual, outer)
    _ => fail("expected outer struct after its dependency")
  }
}

///|
test "enum subtype bases keep stable tags and direct payload fields" {
  let (resolved, lowering) = wasmgc_test_inputs(
    973UL, b"enum Step {\n  Done\n  Next(Node)\n}\nstruct Node {\n  step: Step\n}\n",
  )
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  let enum_layout = lowering.type_layouts.layouts[0]
  let node_layout = lowering.type_layouts.layouts[1]
  let done_variant = lowering.type_layouts.variants[0]
  let next_variant = lowering.type_layouts.variants[1]
  assert_eq(planned.type_index_of(enum_layout.declaration), Some(0))
  assert_eq(planned.type_index_of(node_layout.declaration), Some(1))
  assert_eq(
    planned.payload_type_index_of(done_variant.variant),
    planned.type_index_of(enum_layout.declaration),
  )
  assert_eq(planned.payload_type_index_of(next_variant.variant), Some(2))
  let base = planned.physical_types[0]
  match base.kind {
    PlannedWasmEnumBaseType(actual) =>
      assert_eq(actual, enum_layout.declaration)
    _ => fail("expected enum base")
  }
  assert_eq(base.fields.length, 1)
  match planned.fields[base.fields.start].role {
    WasmEnumTagField => ()
    _ => fail("expected stable i32 tag field")
  }
  let subtype = planned.physical_types[2]
  match subtype.kind {
    PlannedWasmEnumSubtypeType(_, variant, 1) =>
      assert_eq(variant, next_variant.variant)
    _ => fail("expected Next subtype")
  }
  match planned.fields[subtype.fields.start + 1].storage {
    WasmNominalRefStorage(WasmModuleTypeReference(1)) => ()
    _ => fail("expected direct subtype field to reference Node")
  }
}

///|
test "enum subtype families retain one distinct physical type per variant" {
  let (resolved, lowering) = wasmgc_test_inputs(
    9735UL, b"enum Step {\n  Done\n  Next(Node)\n}\nstruct Node {\n  step: Step\n}\n",
  )
  let planned = plan_module_wasmgc_fragments_with_options(
    resolved,
    lowering,
    WasmGCPlanningOptions::subtype_families(),
  )
  let enum_layout = lowering.type_layouts.layouts[0]
  let done = lowering.type_layouts.variants[0]
  let next = lowering.type_layouts.variants[1]
  assert_eq(planned.physical_types.length(), 4)
  assert_eq(planned.type_index_of(enum_layout.declaration), Some(0))
  assert_true(planned.payload_type_index_of(done.variant) is Some(_))
  assert_true(planned.payload_type_index_of(next.variant) is Some(_))
  let done_type = planned.physical_types[planned
    .payload_type_index_of(done.variant)
    .unwrap()]
  let next_type = planned.physical_types[planned
    .payload_type_index_of(next.variant)
    .unwrap()]
  match done_type.kind {
    PlannedWasmEnumSubtypeType(_, variant, 0) =>
      assert_eq(variant, done.variant)
    _ => fail("expected distinct Done subtype")
  }
  match next_type.kind {
    PlannedWasmEnumSubtypeType(_, variant, 1) =>
      assert_eq(variant, next.variant)
    _ => fail("expected distinct Next subtype")
  }
  assert_eq(done_type.fields.length, 1)
  assert_eq(next_type.fields.length, 2)
  match planned.fields[next_type.fields.start].role {
    WasmEnumTagField => ()
    _ => fail("expected inherited tag prefix")
  }
}

///|
test "exact enum shape sharing and unit base reuse reduce physical types" {
  let (resolved, lowering) = wasmgc_test_inputs(
    9736UL, b"enum Many {\n  A(I32)\n  B(I32)\n  C\n  D\n}\n",
  )
  let subtypes = plan_module_wasmgc_fragments_with_options(
    resolved,
    lowering,
    WasmGCPlanningOptions::optimized_subtype_families(),
  )
  let variants = lowering.type_layouts.variants
  assert_eq(subtypes.physical_types.length(), 2)
  assert_eq(
    subtypes.payload_type_index_of(variants[0].variant),
    subtypes.payload_type_index_of(variants[1].variant),
  )
  assert_eq(
    subtypes.payload_type_index_of(variants[2].variant),
    subtypes.type_index_of(variants[2].declaration),
  )
  assert_eq(
    subtypes.payload_type_index_of(variants[3].variant),
    subtypes.type_index_of(variants[3].declaration),
  )
}

///|
test "exact sharing handles recursive and cross enum payload shapes" {
  let (resolved, lowering) = wasmgc_test_inputs(
    97365UL, b"enum Recursive {\n  Left(Recursive)\n  Right(Recursive)\n}\nstruct Node {\n  value: I32\n}\nenum First {\n  One(Node)\n}\nenum Second {\n  Two(Node)\n}\n",
  )
  let subtypes = plan_module_wasmgc_fragments_with_options(
    resolved,
    lowering,
    WasmGCPlanningOptions::optimized_subtype_families(),
  )
  let variants = lowering.type_layouts.variants
  assert_eq(subtypes.physical_types.length(), 7)
  assert_eq(
    subtypes.payload_type_index_of(variants[0].variant),
    subtypes.payload_type_index_of(variants[1].variant),
  )
  assert_true(
    subtypes.payload_type_index_of(variants[2].variant) !=
    subtypes.payload_type_index_of(variants[3].variant),
  )
}

///|
test "all unit enums use only their compact subtype base" {
  let (resolved, lowering) = wasmgc_test_inputs(
    9737UL, b"enum Flags {\n  Off\n  On\n  Unknown\n}\n",
  )
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  let declaration = lowering.type_layouts.layouts[0].declaration
  assert_eq(planned.physical_types.length(), 1)
  assert_eq(planned.type_index_of(declaration), Some(0))
  for variant in lowering.type_layouts.variants {
    assert_eq(
      planned.payload_type_index_of(variant.variant),
      planned.type_index_of(declaration),
    )
  }
}

///|
test "WasmGC function slots separate imports definitions and signatures" {
  let (resolved, lowering) = wasmgc_test_inputs(
    974UL, b"builtin host(value: I32) -> I32 = \"host\"\ntrait Read {\n  fn read(self) -> I32\n}\nfn call(value: I32) -> I32 {\n  host(value)\n}\nstruct Item {}\nimpl Item {\n  fn read(self) -> I32 {\n    1\n  }\n}\n",
  )
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_eq(planned.functions.length(), 4)
  assert_eq(planned.imported_function_count, 1)
  assert_eq(planned.defined_function_count, 2)
  match planned.functions[0].kind {
    PlannedWasmImportedFunction(identity) => {
      assert_eq(identity.module_name, b"dew")
      assert_eq(identity.field, b"host")
      assert_eq(identity.kind, HostWasmImport)
    }
    _ => fail("expected builtin import")
  }
  assert_eq(planned.functions[0].function_index, 0)
  match planned.functions[1].kind {
    PlannedWasmSignatureOnlyFunction => ()
    _ => fail("expected trait dictionary signature")
  }
  assert_eq(planned.functions[1].function_index, -1)
  assert_eq(planned.functions[2].function_index, 1)
  assert_eq(planned.functions[3].function_index, 2)
  assert_eq(planned.signature_type_count, 3)
  assert_eq(
    planned.functions[0].signature_type_index,
    planned.physical_types.length(),
  )
  assert_eq(planned.functions[1].signature_type_index, -1)
  assert_eq(
    planned.functions[2].signature_type_index,
    planned.physical_types.length() + 1,
  )
  assert_eq(
    planned.functions[3].signature_type_index,
    planned.physical_types.length() + 2,
  )
}

///|
test "foreign host imports preserve arbitrary namespaces and scalar signatures" {
  let (resolved, lowering) = wasmgc_test_inputs(
    9751UL, b"foreign import \"custom.host\" as Host {\n  fn send(value: I64) -> I32 = \"send\"\n}\npub fn run(value: I64) -> I32 {\n  Host.send(value)\n}\n",
  )
  assert_eq(lowering.diagnostics.length(), 0)
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  let encoded = serialize_planned_module_wasmgc_fragments(planned).unwrap()
  let restored = deserialize_planned_module_wasmgc_fragments(encoded).unwrap()
  assert_eq(restored, planned)
  assert_eq(serialize_planned_module_wasmgc_fragments(restored).unwrap(), encoded)
  let mut found = false
  for function_ in planned.functions {
    if function_.kind is PlannedWasmImportedFunction(identity) {
      assert_eq(identity.module_name, b"custom.host")
      assert_eq(identity.field, b"send")
      assert_eq(identity.kind, ForeignHostWasmImport)
      assert_eq(identity.lookup_name(), b"custom.host.send")
      assert_eq(function_.parameters.length, 1)
      assert_eq(planned.function_value_types[function_.parameters.start], WasmI64Value)
      assert_eq(function_.results.length, 1)
      assert_eq(planned.function_value_types[function_.results.start], WasmI32Value)
      found = true
    }
  }
  assert_true(found)
}

///|
test "foreign libraries plan link imports with nominal marker signatures" {
  let (resolved, lowering) = wasmgc_test_inputs(
    9750UL, b"foreign type StarshineModule\nforeign impl \"starshine\" as Starshine {\n  fn module_new() -> StarshineModule = \"module_new\"\n}\npub fn make() -> StarshineModule {\n  Starshine.module_new()\n}\n",
  )
  assert_eq(lowering.diagnostics.length(), 0)
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_eq(lowering.type_layouts.layouts.length(), 1)
  let declaration = lowering.type_layouts.layouts[0].declaration
  let marker_index = planned.type_index_of(declaration).unwrap()
  match planned.physical_types[marker_index].kind {
    PlannedWasmForeignMarkerType(actual) => assert_eq(actual, declaration)
    _ => fail("expected foreign nominal marker type")
  }
  assert_eq(planned.physical_types[marker_index].fields.length, 0)
  let mut found = false
  for function_ in planned.functions {
    match function_.kind {
      PlannedWasmImportedFunction(identity) => {
        assert_eq(identity.module_name, b"link:starshine")
        assert_eq(identity.field, b"module_new")
        match identity.kind {
          StaticLinkWasmImport => ()
          _ => fail("expected static-link import kind")
        }
        assert_eq(function_.results.length, 1)
        match planned.function_value_types[function_.results.start] {
          WasmNominalRefValue(actual) => assert_eq(actual, marker_index)
          _ => fail("expected nominal marker result")
        }
        found = true
      }
      _ => ()
    }
  }
  assert_true(found)
}

///|
test "WasmGC fragment merge is independent of simulated job order" {
  let (resolved, lowering) = wasmgc_test_inputs(
    975UL, b"struct Left {\n  right: Right\n}\nstruct Right {\n  left: Left\n}\nbuiltin host(value: I32) -> I32 = \"host\"\nfn first(value: I32) -> I32 {\n  host(value)\n}\nfn second(value: I64) -> I64 {\n  value\n}\n",
  )
  let type_count = wasmgc_physical_type_count_with_options(
    lowering.type_layouts,
    WasmGCPlanningOptions::optimized_subtype_families(),
  )
  let type_forward : Array[Int] = []
  let type_reverse : Array[Int] = []
  for index in 0..<type_count {
    type_forward.push(index)
    type_reverse.push(type_count - index - 1)
  }
  let function_count = lowering.functions.callables.length()
  let function_forward : Array[Int] = []
  let function_reverse : Array[Int] = []
  for index in 0..<function_count {
    function_forward.push(index)
    function_reverse.push(function_count - index - 1)
  }
  let options = WasmGCPlanningOptions::optimized_subtype_families()
  let forward = plan_module_wasmgc_fragments_in_orders(
    resolved,
    lowering,
    None,
    options,
    type_forward,
    function_forward,
    Map::default(),
    Map::default(),
    [],
  )
  let reverse = plan_module_wasmgc_fragments_in_orders(
    resolved,
    lowering,
    None,
    options,
    type_reverse,
    function_reverse,
    Map::default(),
    Map::default(),
    [],
  )
  assert_eq(forward, reverse)
}

///|
test "WasmGC type planning remains iterative for 1024 nominal dependencies" {
  let (resolved, lowering) = wasmgc_test_inputs(
    976UL,
    nested_member_source(1023, false),
  )
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_eq(planned.type_groups.length(), 1024)
  assert_eq(planned.physical_types.length(), 1024)
  assert_eq(planned.physical_types[1023].type_index, 1023)
}
