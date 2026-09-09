///|
fn backend_test_raw_text_cast_instruction(source : Bytes) -> Unit raise {
  let stages = backend_test_single_module_stages(28239UL, source)
  assert_eq(stages.diagnostic_count(), 0)
  let mut declaration = 0UL
  for module_ in stages.lowering.modules {
    for callable in module_.functions.callables {
      if callable.name == b"cast" {
        assert_eq(declaration, 0UL)
        declaration = callable.declaration
      }
    }
  }
  assert_true(declaration != 0UL)
  let mut checked = 0
  for module_ in stages.link.modules {
    for function_ in module_.functions {
      if function_.declaration == declaration &&
        function_.kind is @semantic.PlannedWasmInlineHeapFunction(instruction) {
        let actual = starshine_raw_heap_instructions(
          instruction, module_, Some(stages.link), module_.function_value_types,
          function_.parameters, function_.results,
        ).unwrap()
        let target = starshine_text_runtime_base_for_body(module_, Some(stages.link)) + 2
        assert_eq(actual, [@lib.Instruction::ref_cast(
          false, @lib.HeapType::new(@lib.TypeIdx::new(target.reinterpret_as_uint())),
        )])
        checked += 1
      }
    }
  }
  assert_eq(checked, 1)
}

///|
test "String raw cast emits one instruction with the Bytes result heap" {
  backend_test_raw_text_cast_instruction(
    b"builtin cast(value: String) -> Bytes = \"ref.cast\"\npub fn run(value: String) -> Bytes {\n  cast(value)\n}\n",
  )
}

///|
test "raw reference casts retain primitive result heaps without runtime imports" {
  let stages = backend_test_single_module_stages(
    28235UL, b"builtin cast(value: Bytes) -> String = \"ref.cast\"\npub fn run(value: Bytes) -> String {\n  cast(value)\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "raw reference casts retain declared result heaps" {
  let stages = backend_test_single_module_stages(
    28236UL, b"struct Record {\n  value: I64\n}\nbuiltin cast(value: Bytes) -> Record = \"ref.cast\"\npub fn run(value: Bytes) -> Record {\n  cast(value)\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "raw reference casts retain result heaps in returned function values" {
  let stages = backend_test_single_module_stages(
    28237UL, b"builtin cast(value: Bytes) -> String = \"ref.cast\"\npub fn factory() -> fn(Bytes) -> String {\n  cast\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "raw reference casts reject missing or inconsistent type contracts" {
  for case in [
    (b"struct Box<t> {\n  value: t\n}\nbuiltin cast(value: Bytes) -> Box<I32> = \"ref.cast\"\npub fn run(value: Bytes) -> Box<I32> {\n  cast(value)\n}\n", "invalid heap owner (1=parameters, 2=arena, 3=nonconcrete, 4=cycle): 3"),
    (b"builtin cast(value: I32) -> String = \"ref.cast\"\npub fn run(value: I32) -> String {\n  cast(value)\n}\n", "ref.cast requires reference carriers"),
    (b"builtin cast(value: Bytes) -> I32 = \"ref.cast\"\npub fn run(value: Bytes) -> I32 {\n  cast(value)\n}\n", "ref.cast requires reference carriers"),
    (b"builtin cast(value: Bytes) -> String = \"ref.cast 17\"\npub fn run(value: Bytes) -> String {\n  cast(value)\n}\n", "ref.cast takes its target from the declared result type"),
    (b"builtin cast() -> String = \"ref.cast\"\npub fn run() -> String {\n  cast()\n}\n", "ref.cast requires one operand and one result"),
  ] {
    let (source, expected) = case
    let stages = backend_test_single_module_stages(28238UL, source)
    let diagnostics = @semantic.collect_compiler_source_diagnostics(
      stages.program, stages.analyzed, stages.lowering, stages.link,
    )
    if !diagnostics.is_empty() {
      fail("reference cast source diagnostic: " + @debug.to_string((source, diagnostics)))
    }
    match emit_starshine_program_module(stages.lowering, stages.link) {
      Err(InvalidHeapIntrinsic(_, actual)) => assert_eq(actual, expected)
      other => fail("expected an exact reference cast contract error, got " + @debug.to_string(other))
    }
  }
}

///|
test "raw reference casts reject generic source targets before emission" {
  let stages = backend_test_single_module_stages(
    28238UL, b"builtin cast<t>(value: Bytes) -> t = \"ref.cast\"\npub fn run(value: Bytes) -> String {\n  cast(value)\n}\n",
  )
  let diagnostics = @semantic.collect_compiler_source_diagnostics(
    stages.program, stages.analyzed, stages.lowering, stages.link,
  )
  assert_eq(diagnostics.length(), 1)
  assert_eq(diagnostics[0].message, "UnsupportedProgramGenericCall(28238, 121281286504448, 91)")
  assert_eq(diagnostics[0].has_primary, true)
  assert_eq(diagnostics[0].primary.file, 121281286504704UL)
  assert_eq(diagnostics[0].primary.offset, 91UL)
}

///|
test "raw struct reads use the declared owner and field index" {
  let stages = backend_test_single_module_stages(
    28231UL, b"struct Record {\n  first: U32\n  second: I64\n}\nbuiltin read(value: Record) -> I64 = \"struct.get 1\"\npub fn run(value: Record) -> I64 {\n  read(value)\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "raw primitive struct reads do not import a runtime algorithm" {
  let stages = backend_test_single_module_stages(
    28232UL, b"builtin read(value: Bytes) -> U32 = \"struct.get 2\"\npub fn run(value: Bytes) -> U32 {\n  read(value)\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "raw primitive struct reads retain their owner when used as function values" {
  let stages = backend_test_single_module_stages(
    28233UL, b"builtin read(value: Bytes) -> U32 = \"struct.get 2\"\npub fn reader() -> fn(Bytes) -> U32 {\n  read\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "raw struct reads reject invalid field contracts before Wasm validation" {
  for
    case in [
      (
        b"builtin read(value: Bytes) -> U32 = \"struct.get 3\"\npub fn run(value: Bytes) -> U32 {\n  read(value)\n}\n",
        "field is outside the primitive struct",
      ),
      (
        b"builtin read(value: Bytes) -> I64 = \"struct.get 2\"\npub fn run(value: Bytes) -> I64 {\n  read(value)\n}\n",
        "struct.get result carrier does not match its field",
      ),
      (
        b"builtin read(value: I32) -> U32 = \"struct.get 2\"\npub fn run(value: I32) -> U32 {\n  read(value)\n}\n",
        "struct.get operand has no reference carrier",
      ),
      (
        b"builtin read(value: Bytes) -> Bytes = \"struct.get 0\"\npub fn run(value: Bytes) -> Bytes {\n  read(value)\n}\n",
        "reference fields require a complete heap result contract",
      ),
      (
        b"struct Packed {\n  value: I8\n}\nbuiltin read(value: Packed) -> I32 = \"struct.get 0\"\npub fn run(value: Packed) -> I32 {\n  read(value)\n}\n",
        "struct.get currently requires unpacked scalar field storage",
      ),
      (
        b"struct Item {\n  value: I64\n}\nbuiltin read(value: Item) -> I64 = \"struct.get 1\"\npub fn run(value: Item) -> I64 {\n  read(value)\n}\n",
        "field is outside the declared struct",
      ),
      (
        b"builtin read(value: Bytes) -> U32 = \"struct.get 02\"\npub fn run(value: Bytes) -> U32 {\n  read(value)\n}\n",
        "invalid struct.get field immediate",
      ),
    ] {
    let (source, expected) = case
    let stages = backend_test_single_module_stages(28234UL, source)
    assert_eq(stages.diagnostic_count(), 0)
    match emit_starshine_program_module(stages.lowering, stages.link) {
      Err(InvalidHeapIntrinsic(_, actual)) => assert_eq(actual, expected)
      other =>
        fail(
          "expected exact raw struct contract error, got " +
          @debug.to_string(other),
        )
    }
  }
}

///|
test "raw bit casts preserve packed scalar and vector carriers" {
  let stages = backend_test_single_module_stages(
    28201UL, b"builtin cast<a, b>(value: a) -> b = \"unsafe.bitcast\"\npub fn pack(value: U32) -> I16x2 {\n  cast(value)\n}\npub fn unpack(value: I16x2) -> U32 {\n  cast(value)\n}\npub fn wide(value: U64) -> I16x4 {\n  cast(value)\n}\npub fn vector(value: V128) -> F32x4 {\n  cast(value)\n}\n",
  )
  @test.assert_eq(
    @semantic.collect_compiler_source_diagnostics(
      stages.program,
      stages.analyzed,
      stages.lowering,
      stages.link,
    ),
    [],
  )
  assert_eq(stages.link.imported_function_count, 0)
  let module_ = emit_starshine_program_module(stages.lowering, stages.link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "raw bit casts reject different carriers before Wasm validation" {
  let stages = backend_test_single_module_stages(
    28202UL, b"builtin cast<a, b>(value: a) -> b = \"unsafe.bitcast\"\npub fn invalid(value: U32) -> U64 {\n  cast(value)\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Err(InvalidBuiltinSignature(name, _, _)) =>
      assert_eq(name, b"unsafe.bitcast")
    _ => fail("expected InvalidBuiltinSignature before Wasm validation")
  }
}

///|
test "raw bit casts reject references and erased signatures" {
  for
    source in [
      b"builtin cast<a, b>(value: a) -> b = \"unsafe.bitcast\"\npub fn invalid(value: String) -> String {\n  cast(value)\n}\n",
      b"builtin cast<a, b>(value: a) -> b = \"unsafe.bitcast\"\npub fn invalid(value: F32) -> U32 {\n  cast(value)\n}\n",
      b"builtin cast(value: Unit) -> Unit = \"unsafe.bitcast\"\npub fn invalid() -> Unit {\n  cast(())\n}\n",
    ] {
    let stages = backend_test_single_module_stages(28203UL, source)
    assert_eq(stages.diagnostic_count(), 0)
    match emit_starshine_program_module(stages.lowering, stages.link) {
      Err(InvalidBuiltinSignature(name, _, _)) =>
        assert_eq(name, b"unsafe.bitcast")
      _ => fail("expected InvalidBuiltinSignature for non-carrier cast")
    }
  }
}

///|
test "packed wrappers reduce to one opcode without boxing or forwarding calls" {
  let stages = backend_test_single_module_stages(
    28204UL, b"pub fn masked(left: I16x2, right: I16x2) -> I16x2 {\n  unsafe_bitcast(u32_and(unsafe_bitcast(left), unsafe_bitcast(right)))\n}\npub fn loaded(address: U32) -> I16x4 {\n  unsafe_bitcast(u64_load(address))\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let mut count = 0
  for function_ in stages.link.functions {
    if function_.name == b"masked" {
      assert_eq(function_.direct_builtin, b"i32.and")
      count += 1
    } else if function_.name == b"loaded" {
      assert_eq(function_.direct_builtin, b"i64.load")
      count += 1
    }
  }
  assert_eq(count, 2)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "raw opcode signatures are checked for ordinary user declarations" {
  let stages = backend_test_single_module_stages(
    28205UL, b"builtin wrong(left: I64, right: I64) -> I64 = \"i32.and\"\npub fn main() -> I64 {\n  wrong(1i64, 2i64)\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Err(InvalidBuiltinSignature(name, _, _)) => assert_eq(name, b"i32.and")
    _ => fail("expected raw opcode signature diagnostic")
  }
}

///|
test "raw forwarding requires every parameter once and in order" {
  let stages = backend_test_single_module_stages(
    28206UL, b"pub fn duplicate(left: I16x2, right: I16x2) -> I16x2 {\n  unsafe_bitcast(u32_and(unsafe_bitcast(left), unsafe_bitcast(left)))\n}\npub fn reverse(left: I16x2, right: I16x2) -> I16x2 {\n  unsafe_bitcast(u32_and(unsafe_bitcast(right), unsafe_bitcast(left)))\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let mut count = 0
  for function_ in stages.link.functions {
    if function_.name == b"duplicate" || function_.name == b"reverse" {
      assert_eq(function_.direct_builtin, b"")
      count += 1
    }
  }
  assert_eq(count, 2)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "packed forwarding functions remain usable as function values" {
  let stages = backend_test_single_module_stages(
    28207UL, b"fn masked(left: I16x2, right: I16x2) -> I16x2 {\n  unsafe_bitcast(u32_and(unsafe_bitcast(left), unsafe_bitcast(right)))\n}\npub fn main() -> U32 {\n  let operation = masked\n  unsafe_bitcast(operation(unsafe_bitcast(298u32), unsafe_bitcast(255u32)))\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "raw forwarding worklist closes a reverse-ordered dependency chain" {
  let source = Buffer(size_hint=1024)
  source.write_string_utf8(
    "pub fn step0(value: I32) -> I32 {\n  unsafe_bitcast(value)\n}\n",
  )
  for index in 1..<12 {
    source.write_string_utf8(
      "pub fn step\{index}(value: I32) -> I32 {\n  step\{index - 1}(value)\n}\n",
    )
  }
  let stages = backend_test_single_module_stages(28208UL, source.to_bytes())
  assert_eq(stages.diagnostic_count(), 0)
  let mut count = 0
  for function_ in stages.link.modules[0].functions {
    if function_.direct_builtin == b"unsafe.bitcast" {
      count += 1
    }
  }
  assert_eq(count, 12)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "packed peer Into implementations select the expected result type" {
  let source = Buffer(size_hint=16384)
  source.write_string_utf8(
    "open dew.std.i8x4\nopen dew.std.u8x4\nopen dew.std.i16x2\nopen dew.std.u16x2\nopen dew.std.i8x8\nopen dew.std.u8x8\nopen dew.std.i16x4\nopen dew.std.u16x4\nopen dew.std.i32x2\nopen dew.std.u32x2\nopen dew.std.i8x16\nopen dew.std.u8x16\nopen dew.std.i16x8\nopen dew.std.u16x8\nopen dew.std.i32x4\nopen dew.std.u32x4\nopen dew.std.i64x2\nopen dew.std.u64x2\nopen dew.std.f32x4\nopen dew.std.f64x2\n",
  )
  let families = [
    ["I8x4", "U8x4", "I16x2", "U16x2"],
    ["I8x8", "U8x8", "I16x4", "U16x4", "I32x2", "U32x2"],
    [
      "I8x16", "U8x16", "I16x8", "U16x8", "I32x4", "U32x4", "I64x2", "U64x2", "F32x4",
      "F64x2",
    ],
  ]
  let mut count = 0
  for family in families {
    for source_type in family {
      for target_type in family {
        if source_type != target_type {
          source.write_string_utf8(
            "pub fn convert\{count}(value: \{source_type}) -> \{target_type} {\n  value.into()\n}\n",
          )
          count += 1
        }
      }
    }
  }
  assert_eq(count, 132)
  let stages = backend_test_single_module_stages(28209UL, source.to_bytes())
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}
