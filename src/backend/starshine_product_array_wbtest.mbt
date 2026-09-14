///|
test "array literals use declared library fields and constructor identity" {
  let program = @semantic.collect_program_manifest_with_standard_sources(
    28119UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"pub fn run() -> I32 {\n  let values = [1i32, 2i32, 3i32]\n  if values.count == 3u32 && values.marker == 37i32 {\n    42i32\n  } else {\n    0i32\n  }\n}\n",
        ),
      ]),
    ]),
    @semantic.StandardLibrarySources::new([
      @semantic.ManifestFile::new(
        "std/array.dew", b"pub struct BeforeArray {}\npub struct Array<t> {\n  marker: I32\n  mut count: U32\n}\npub fn array_with_capacity<t>(capacity: U32) -> Array<t> {\n  Array::{\n    marker: 37i32\n    count: 0u32\n  }\n}\nimpl<t> Array<t> {\n  fn push(self, value: t) -> Unit {\n    self.count = self.count + 1u32\n  }\n}\n",
      ),
    ]),
    true,
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  let stages : BackendCompilerTestStages = {
    program,
    analyzed,
    lowering,
    link,
  }
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "array literals emit exact-capacity WasmGC arrays" {
  let stages = backend_test_single_module_stages(
    28111UL, b"open dew.std.array\npub fn run() -> I32 {\n  let values = [10, 20, 30]\n  values[0u32] + values[2u32]\n}\npub fn pairs() -> Array<(I32, I64)> {\n  [(1, 2L), (3, 4L)]\n}\npub fn first_pair() -> (I32, I64) {\n  let values = pairs()\n  values[0u32]\n}\npub fn empty() -> Array<I32> {\n  []\n}\npub fn empty_pairs() -> Array<(I32, I64)> {\n  []\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => {
      debug_inspect(error)
      fail("array literal emission failed")
    }
  }
}

///|
test "products use multivalue ABIs and box only at storage boundaries" {
  let stages = backend_test_single_module_stages(
    28112UL, b"open dew.std.array\nfn pair() -> (I32, I64) {\n  (7, 9L)\n}\nlet stored = pair()\nfn identity(value: (I32, I64)) -> (I32, I64) {\n  value\n}\npub fn choose(flag: Bool) -> (I32, I64) {\n  if flag {\n    identity(pair())\n  } else {\n    (11, 13L)\n  }\n}\npub fn choose_match(flag: Bool) -> (I32, I64) {\n  match flag {\n    true => pair()\n    false => (17, 19L)\n  }\n}\npub fn forward() -> (I32, I64) {\n  let value = pair()\n  identity(value)\n}\npub fn destructure() -> (I32, I64) {\n  let (first, second) = pair()\n  (first, second)\n}\nfn nested() -> (I32, (I64, Bool)) {\n  (23, (29L, true))\n}\npub fn destructure_nested() -> (I32, (I64, Bool)) {\n  let (first, (second, third)) = nested()\n  (first, (second, third))\n}\npub fn captured() -> (I32, I64) {\n  let value = pair()\n  let read = fn() -> (I32, I64) {\n    value\n  }\n  read()\n}\npub fn lambda_parameter() -> (I32, I64) {\n  let identity = fn(value: (I32, I64)) -> (I32, I64) {\n    value\n  }\n  identity(pair())\n}\nfn generic_identity<t>(value: (t, t)) -> (t, t) {\n  value\n}\npub fn generic_pair() -> (I32, I32) {\n  generic_identity((41, 43))\n}\nfn generic_array<t>(value: t) -> Array<(t, t)> {\n  [(value, value)]\n}\npub fn generic_array_i32() -> Array<(I32, I32)> {\n  generic_array(59)\n}\npub fn captured_mut() -> (I32, I64) {\n  let mut value = pair()\n  let update = fn() -> (I32, I64) {\n    value = (31, 37L)\n    value\n  }\n  update()\n}\nstruct Holder {\n  value: (I32, I64)\n}\nenum Stored {\n  Pair((I32, I64))\n  Empty\n}\npub fn holder() -> Holder {\n  Holder::{\n    value: pair()\n  }\n}\npub fn stored_enum() -> Stored {\n  Stored::Pair(pair())\n}\npub fn stored_enum_value() -> (I32, I64) {\n  match stored_enum() {\n    Stored::Pair(value) => value\n    Stored::Empty => pair()\n  }\n}\npub fn holder_value() -> (I32, I64) {\n  holder().value\n}\npub fn holder_match() -> (I32, I64) {\n  match holder() {\n    Holder {\n      value: value\n    } => value\n  }\n}\npub fn stored_value() -> (I32, I64) {\n  stored\n}\npub fn loop_product() -> (I32, I64) {\n  while pair() {\n    value => break value\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => {
      debug_inspect(error)
      fail("product emission failed")
    }
  }
}

///|
test "dynamic closure calls may return products" {
  let stages = backend_test_single_module_stages(
    28114UL, b"fn make_pair(offset: I32) -> fn(I32) -> (I32, I64) {\n  fn(value: I32) -> (I32, I64) {\n    (value + offset, 9L)\n  }\n}\npub fn run() -> (I32, I64) {\n  let callback = make_pair(1)\n  callback(7)\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => {
      debug_inspect(error)
      fail("dynamic product closure emission failed")
    }
  }
}

///|
test "product arguments do not suppress later nominal casts" {
  let stages = backend_test_single_module_stages(
    28116UL, b"struct Holder {\n  value: I32\n}\nfn read(pair: (I32, I32), holder: Holder) -> I32 {\n  let (first, second) = pair\n  holder.value + first + second\n}\npub fn run(flag: Bool) -> I32 {\n  read(\n    (1, 2),\n    if flag {\n      Holder::{\n        value: 7\n      }\n    } else {\n      Holder::{\n        value: 9\n      }\n    },\n  )\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => {
      debug_inspect(error)
      fail("product argument nominal cast emission failed")
    }
  }
}

///|
test "Unit functions discard every product root value" {
  let stages = backend_test_single_module_stages(
    28117UL, b"open dew.std.array\npub fn ignore(value: (I32, I64)) -> Unit {\n  value\n}\nfn discard<t>(value: t) -> Unit {\n  value\n}\nfn use<t>(value: t) -> I32 {\n  value\n  7\n}\npub fn discard_generic() -> Unit {\n  discard((1, 2L))\n}\npub fn use_generic() -> I32 {\n  use((3, 4L))\n}\npub fn visit(values: Array<(I32, I64)>) -> Unit {\n  for value in values {\n    value\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => {
      debug_inspect(error)
      fail("product root discard emission failed")
    }
  }
}

///|
test "parameter selection discards the value arity, not instruction count" {
  let stages = backend_test_single_module_stages(
    28118UL, b"foreign impl \"host\" as Host {\n  fn effect() -> Unit = \"effect\"\n}\nstruct UnitField {\n  ignored: Unit\n  kept: I32\n}\nstruct ProductField {\n  ignored: (I32, I64)\n  kept: I32\n}\npub fn keep_after_effect() -> I32 {\n  UnitField::{\n    ignored: Host.effect()\n    kept: 7\n  }.kept\n}\npub fn keep_after_product() -> I32 {\n  ProductField::{\n    ignored: (1, 2L)\n    kept: 9\n  }.kept\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => {
      debug_inspect(error)
      fail("parameter selection emission failed")
    }
  }
}
