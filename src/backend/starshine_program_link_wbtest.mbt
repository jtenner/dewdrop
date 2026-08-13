///|
fn backend_program_link_pipeline() -> (
  @semantic.CollectedProgram,
  @semantic.AnalyzedProgramSemantics,
  @semantic.PlannedProgramLowering,
  @semantic.PlannedProgramWasmGCLink,
) {
  let program = @semantic.collect_program_manifest(
    2400UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.math\npub fn run(value: I32) -> I32 {\n  double(value)\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.math", [
        @semantic.ManifestFile::new(
          "math.dew", b"pub fn double(value: I32) -> I32 {\n  value + value\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  (program, analyzed, lowering, link)
}

///|
test "array scratch allocation does not suppress later Set scratch locals" {
  let program = @semantic.collect_program_manifest(
    2396UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.array\nopen dew.std.set\nopen dew.std.string\nfn read_first(values: Array<String>) -> String {\n  values.get_unchecked(0u32)\n}\npub fn run() -> U32 {\n  let values = Array::new()\n  values.push(\"a\")\n  let seen = Set::empty()\n  seen.insert(\"a\")\n  if seen.contains(read_first(values)) {\n    1u32\n  } else {\n    0u32\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "wasm intrinsics are imported through an at alias" {
  let program = @semantic.collect_program_manifest(
    2397UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"import dew.std.wasm.intrinsics as @wasm\npub fn run(value: I64) -> I32 {\n  @wasm.i64_trunc_i32(value)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].names.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "generic Unit specialization omits carrier parameters consistently" {
  let program = @semantic.collect_program_manifest(
    2398UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.show\nfn unit_value() -> Unit {\n}\npub fn run() -> String {\n  show(unit_value())\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "cross module GC-backed String call and UTF8 runtime validate" {
  let program = @semantic.collect_program_manifest(
    2399UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.bytes\nopen app.text\npub fn run() -> U32 {\n  message().as_bytes().to_string().byte_length()\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.text", [
        @semantic.ManifestFile::new(
          "text.dew", b"pub fn message() -> String {\n  \"hello λ\"\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "cross module StringView feeds linked StringBuilder" {
  let program = @semantic.collect_program_manifest(
    2398UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.bytes\nopen dew.std.string_builder\nopen app.text\npub fn run() -> U32 {\n  let builder = StringBuilder::new()\n  builder.append(\">\")\n  builder.append_view(middle())\n  builder.append(\"<\")\n  builder.finish().byte_length()\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.text", [
        @semantic.ManifestFile::new(
          "text.dew", b"open dew.std.string\nopen dew.std.bytes\npub fn middle() -> StringView {\n  \"xλy\".view(1u32, 2u32)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "cross module Bytes find result preserves its exact nominal ABI" {
  let program = @semantic.collect_program_manifest(
    2395UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.bytes\nopen app.search\npub fn run() -> U32 {\n  match locate() {\n    Option::Some(index) => index\n    Option::None => 4294967295u32\n  }\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.search", [
        @semantic.ManifestFile::new(
          "search.dew", b"open dew.std.string\nopen dew.std.bytes\npub fn locate() -> Option<U32> {\n  b\"xx0123456789abcdef-tail\".view(2u32, 21u32).find(b\"cdef-tail\")\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "cross module WASI Bytes marshalling preserves imports and memory" {
  let program = @semantic.collect_program_manifest(
    2395UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.io\npub fn write(fd: U32) -> U32 {\n  write_payload(fd)\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.io", [
        @semantic.ManifestFile::new(
          "io.dew", b"open dew.std.bytes\nopen dew.std.wasi\npub fn write_payload(fd: U32) -> U32 {\n  wasi_fd_write(fd, b\"xxcross-module-payloadyy\".view(2u32, 20u32))\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.imported_function_count, 1)
  let mut uses_linear_memory = false
  for module_ in link.modules {
    uses_linear_memory = uses_linear_memory || module_.uses_linear_memory
  }
  assert_true(uses_linear_memory)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "cross module String and StringView matching preserves byte offsets" {
  let program = @semantic.collect_program_manifest(
    2394UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.bytes\nopen app.text_search\npub fn find_view() -> U32 {\n  match hay_string().find_view(needle_view()) {\n    Option::Some(index) => index\n    Option::None => 4294967295u32\n  }\n}\npub fn find_string() -> U32 {\n  match hay_view().find_string(needle_string()) {\n    Option::Some(index) => index\n    Option::None => 4294967295u32\n  }\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.text_search", [
        @semantic.ManifestFile::new(
          "search.dew", b"open dew.std.string\nopen dew.std.bytes\npub fn hay_string() -> String {\n  \"xxprefix λ世界🌍 suffixyy\".view(2u32, 26u32).to_string()\n}\npub fn hay_view() -> StringView {\n  \"xxprefix λ世界🌍 suffixyy\".view(2u32, 26u32)\n}\npub fn needle_string() -> String {\n  \"🌍 suffix\"\n}\npub fn needle_view() -> StringView {\n  \"zz🌍 suffixqq\".view(2u32, 11u32)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "cross module text ranges feed flat concatenation" {
  let program = @semantic.collect_program_manifest(
    2396UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.bytes\nopen app.parts\npub fn run() -> U32 {\n  prefix().concat_view(suffix()).byte_length() + left_bytes().concat(right_bytes()).byte_length()\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.parts", [
        @semantic.ManifestFile::new(
          "parts.dew", b"open dew.std.string\nopen dew.std.bytes\npub fn prefix() -> String {\n  \"xxprefix \".view(2u32, 7u32).to_string()\n}\npub fn suffix() -> StringView {\n  \"yyλ世界\".view(2u32, 8u32)\n}\npub fn left_bytes() -> Bytes {\n  b\"xx\\x00\\xFF\".view(2u32, 2u32)\n}\npub fn right_bytes() -> Bytes {\n  b\"yytail\".view(2u32, 4u32)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "cross module BytesBuilder result feeds checked String conversion" {
  let program = @semantic.collect_program_manifest(
    2397UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.bytes\nopen app.bytes\npub fn run() -> U32 {\n  payload().to_string().byte_length()\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.bytes", [
        @semantic.ManifestFile::new(
          "bytes.dew", b"open dew.std.string\nopen dew.std.bytes\nopen dew.std.bytes_builder\npub fn payload() -> Bytes {\n  let builder = BytesBuilder::with_capacity(1u32)\n  builder.append(b\"linked λ \" )\n  builder.append_byte(33u8)\n  builder.finish()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "cross module scalar call emits one valid linked module" {
  let (_, _, lowering, link) = backend_program_link_pipeline()
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.imported_function_count, 0)
  assert_eq(link.defined_function_count, 2)
  let helper_plan = starshine_program_adapter_helper_plan(lowering, link)
  assert_eq(
    emit_starshine_program_type_section(link, helper_plan),
    @lib.TypeSec::new([
      @lib.RecType::new(
        @lib.SubType::comp_type(
          @lib.CompType::func([@lib.ValType::i32()], [@lib.ValType::i32()]),
        ),
      ),
      @lib.RecType::new(
        @lib.SubType::comp_type(
          @lib.CompType::func([@lib.ValType::i32()], [@lib.ValType::i32()]),
        ),
      ),
    ]),
  )
  let module_ = match emit_starshine_program_module(lowering, link) {
    Ok(module_) => module_
    Err(_) => fail("failed to emit linked Starshine module")
  }
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, link) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode linked Starshine module")
  }
}

///|
test "linked module exports only public functions from the root module" {
  let (program, _, lowering, link) = backend_program_link_pipeline()
  let run = program.modules[0].lookup_value("run").unwrap()
  let double = program.modules[1].lookup_value("double").unwrap()
  assert_eq(link.function_of(double).unwrap().function_index, 0)
  assert_eq(link.function_of(run).unwrap().function_index, 1)
  let expected = @lib.ExportSec::new([
    @lib.Export::new(
      @lib.Name::from_string("run"),
      @lib.ExternIdx::func(@lib.FuncIdx::new(1U)),
    ),
  ])
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  let helper_plan = starshine_program_adapter_helper_plan(lowering, link)
  let type_section = emit_starshine_program_type_section(link, helper_plan)
  let expected_module = @lib.Module::new()
    .with_type_sec(type_section)
    .with_import_sec(emit_starshine_program_import_section(link))
    .with_func_sec(emit_starshine_program_function_section(link, helper_plan))
    .with_export_sec(expected)
    .with_code_sec(
      emit_starshine_program_code_section(lowering, link, helper_plan).unwrap(),
    )
  assert_eq(module_, expected_module)
}

///|
test "linked program emits struct construction and field access" {
  let program = @semantic.collect_program_manifest(
    2420UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"pub struct Pair {\n  first: I32\n  second: I32\n}\nfn make(first: I32, second: I32) -> Pair {\n  Pair::{\n    second: second\n    first: first\n  }\n}\nfn sum(value: Pair) -> I32 {\n  value.first + value.second\n}\npub fn run(value: I32) -> I32 {\n  sum(make(value, 1))\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, link) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode linked struct program")
  }
}

///|
test "wide imported enum construction validates through Starshine" {
  let library = Buffer(size_hint=1024)
  library.write_string_utf8("pub enum Message {\n  Idle\n")
  for index in 0..<32 {
    library.write_string_utf8("  Value_")
    library.write_string_utf8(index.to_string())
    library.write_string_utf8("(I32)\n")
  }
  library.write_string_utf8("}\n")
  let program = @semantic.collect_program_manifest(
    2414UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.enum_main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.enum_library\npub fn build(value: I32) -> Message {\n  Message::Value_31(value)\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.enum_library", [
        @semantic.ManifestFile::new("library.dew", library.to_bytes()),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  match emit_starshine_program_module(lowering, link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(UnsupportedExpression(_, _)) => fail("unsupported expression")
    Err(MissingBody(_)) => fail("missing body")
    Err(MissingFunction(_)) => fail("missing function")
    Err(SignatureOnlyCall(_)) => fail("signature-only call")
    Err(InvalidLocal(_, _)) => fail("invalid local")
    Err(UnsupportedBuiltin(_)) => fail("unsupported builtin")
    Err(InvalidFunctionBody(_)) => fail("invalid function body")
    Err(ProgramLinkDiagnostics(_)) => fail("program link diagnostics")
  }
}

///|
test "shared exact enum shapes construct and match nonrepresentative variants" {
  let program = @semantic.collect_program_manifest(
    24142UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.library\nfn read(value: Choice) -> I32 {\n  match value {\n    Choice::A(item) => item\n    Choice::B(item) => item\n  }\n}\npub fn run(value: I32) -> I32 {\n  read(Choice::B(value))\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.library", [
        @semantic.ManifestFile::new(
          "library.dew", b"pub enum Choice {\n  A(I32)\n  B(I32)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let options = [@semantic.WasmGCPlanningOptions::optimized_subtype_families()]
  for option in options {
    let link = @semantic.plan_program_wasmgc_link_with_options(
      analyzed, lowering, 0, option,
    )
    assert_eq(link.diagnostics.length(), 0)
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    assert_eq(@validate.validate_module(module_), Ok(()))
  }
}

///|
test "dense enum tag dispatch validates with optimized subtype dispatch" {
  let program = @semantic.collect_program_manifest(
    24143UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.library\nfn read(value: Code) -> I32 {\n  match value {\n    Code::A => 0\n    Code::B => 1\n    Code::C => 2\n    Code::D => 3\n  }\n}\npub fn run() -> I32 {\n  read(Code::C)\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.library", [
        @semantic.ManifestFile::new(
          "library.dew", b"pub enum Code {\n  A\n  B\n  C\n  D\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let options = [@semantic.WasmGCPlanningOptions::optimized_subtype_families()]
  for option in options {
    let link = @semantic.plan_program_wasmgc_link_with_options(
      analyzed, lowering, 0, option,
    )
    assert_eq(link.diagnostics.length(), 0)
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    assert_eq(@validate.validate_module(module_), Ok(()))
  }
}

///|
test "imported struct variant match validates with the subtype representation" {
  let program = @semantic.collect_program_manifest(
    24144UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.library\nfn read(value: Message) -> I32 {\n  match value {\n    Message::Idle => 0\n    Message::Move {\n      x\n      ...\n    } => x\n  }\n}\npub fn run(value: I32) -> I32 {\n  read(Message::Move::{\n    y: 0\n    x: value\n  })\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.library", [
        @semantic.ManifestFile::new(
          "library.dew", b"pub enum Message {\n  Idle\n  Move {\n    x: I32\n    y: I32\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let options = [@semantic.WasmGCPlanningOptions::optimized_subtype_families()]
  for option in options {
    let link = @semantic.plan_program_wasmgc_link_with_options(
      analyzed, lowering, 0, option,
    )
    assert_eq(link.diagnostics.length(), 0)
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    assert_eq(@validate.validate_module(module_), Ok(()))
  }
}

///|
test "imported enum match validates with the subtype representation" {
  let program = @semantic.collect_program_manifest(
    24145UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.library\nfn read(value: OptionI32) -> I32 {\n  match value {\n    OptionI32::Some(item) if false => 0\n    OptionI32::None => 0\n    OptionI32::Some(item) => item\n  }\n}\npub fn run(value: I32) -> I32 {\n  read(OptionI32::Some(value))\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.library", [
        @semantic.ManifestFile::new(
          "library.dew", b"pub enum OptionI32 {\n  None\n  Some(I32)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let options = [@semantic.WasmGCPlanningOptions::optimized_subtype_families()]
  for option in options {
    let link = @semantic.plan_program_wasmgc_link_with_options(
      analyzed, lowering, 0, option,
    )
    assert_eq(link.diagnostics.length(), 0)
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    assert_eq(@validate.validate_module(module_), Ok(()))
    match emit_starshine_program_binary(lowering, link) {
      Ok(bytes) => assert_true(bytes.length() > 8)
      Err(_) => fail("failed to encode imported enum match")
    }
  }
}

///|
test "imported enum construction validates with the subtype representation" {
  let program = @semantic.collect_program_manifest(
    2415UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.library\npub fn idle() -> Message {\n  Message::Idle\n}\npub fn number(value: I32) -> Message {\n  Message::Number(value)\n}\npub fn move(x: I32, y: I32) -> Message {\n  Message::Move::{\n    y: y\n    x: x\n  }\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.library", [
        @semantic.ManifestFile::new(
          "library.dew", b"pub enum Message {\n  Idle\n  Number(I32)\n  Move {\n    x: I32\n    y: I32\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let options = [@semantic.WasmGCPlanningOptions::optimized_subtype_families()]
  for option in options {
    let link = @semantic.plan_program_wasmgc_link_with_options(
      analyzed, lowering, 0, option,
    )
    assert_eq(link.diagnostics.length(), 0)
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    assert_eq(@validate.validate_module(module_), Ok(()))
    match emit_starshine_program_binary(lowering, link) {
      Ok(bytes) => assert_true(bytes.length() > 8)
      Err(_) => fail("failed to encode imported enum construction")
    }
  }
}

///|
test "imported struct construction and field access emit external type indices" {
  let program = @semantic.collect_program_manifest(
    2425UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.library\nfn make(value: I32) -> Item {\n  Item::{\n    value: value\n  }\n}\nfn read(value: Item) -> I32 {\n  value.value\n}\npub fn run(value: I32) -> I32 {\n  read(make(value))\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.library", [
        @semantic.ManifestFile::new(
          "library.dew", b"pub struct Item {\n  value: I32\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, link) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode imported struct program")
  }
}

///|
test "imported aggregate signatures emit typed cross module references" {
  let program = @semantic.collect_program_manifest(
    2430UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.library\npub fn run(value: Item) -> Item {\n  keep(value)\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.library", [
        @semantic.ManifestFile::new(
          "library.dew", b"pub struct Item {\n  value: I32\n}\npub fn keep(value: Item) -> Item {\n  value\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, link) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode imported aggregate signature")
  }
}

///|
test "aggregate fields may reference earlier dependency types" {
  let program = @semantic.collect_program_manifest(
    2440UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.outer", [
        @semantic.ManifestFile::new(
          "outer.dew", b"open app.inner\npub struct Outer {\n  inner: Inner\n}\npub fn run() -> I32 {\n  1\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.inner", [
        @semantic.ManifestFile::new("inner.dew", b"pub struct Inner {}\n"),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "cross module recursive aggregate SCC emits one valid recursive group" {
  let program = @semantic.collect_program_manifest(
    2445UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cycle.a", [
        @semantic.ManifestFile::new(
          "a.dew", b"open cycle.b\npub struct A {\n  b: B\n}\npub fn keep(value: A) -> A {\n  value\n}\npub fn main() -> I32 {\n  42\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("cycle.b", [
        @semantic.ManifestFile::new(
          "b.dew", b"open cycle.a\npub struct B {\n  a: A\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let mut found_pair = false
  for group in link.program_type_groups {
    if group.types.length == 2 {
      found_pair = true
    }
  }
  assert_true(found_pair)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, link) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode recursive cross-module aggregates")
  }
}

///|
test "recursive nominal values survive generic arrays and aggregate fields" {
  let stages = backend_test_single_module_stages(
    2446UL, b"open dew.std.array\npub enum Node {\n  Leaf(I32)\n  Branch(Array<Node>)\n}\npub struct Holder {\n  values: Array<Node>\n}\nfn build() -> Holder {\n  let children = Array::new()\n  children.push(Node::Leaf(42))\n  let roots = Array::new()\n  roots.push(Node::Branch(children))\n  Holder::{\n    values: roots\n  }\n}\npub fn main() -> I32 {\n  match build().values.get_unchecked(0u32) {\n    Node::Branch(children) => {\n      match children.get_unchecked(0u32) {\n        Node::Leaf(value) => value\n        _ => 0\n      }\n    }\n    _ => 0\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let module_ = stages.emit_module()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(stages.emit_binary().length() > 8)
}

///|
test "cross module recursive SCC emits valid forward calls" {
  let program = @semantic.collect_program_manifest(
    2450UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cycle.a", [
        @semantic.ManifestFile::new(
          "a.dew", b"open cycle.b\npub fn a(value: I32) -> I32 {\n  b(value)\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("cycle.b", [
        @semantic.ManifestFile::new(
          "b.dew", b"open cycle.a\npub fn b(value: I32) -> I32 {\n  a(value)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "local implementation methods cast imported nominal arguments" {
  let program = @semantic.collect_program_manifest(
    2475UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.types\npub trait Read {\n  fn read(self) -> I32\n}\nimpl Read for Item {\n  fn read(self) -> I32 {\n    42\n  }\n}\npub fn main() -> I32 {\n  let item = Item::{}\n  item.read()\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.types", [
        @semantic.ManifestFile::new("types.dew", b"pub struct Item {}\n"),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.impl_index.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "local implementation methods accept imported nominal aggregate fields" {
  let program = @semantic.collect_program_manifest(
    2476UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.types\npub trait Read {\n  fn read(self) -> I32\n}\nimpl Read for Item {\n  fn read(self) -> I32 {\n    42\n  }\n}\nstruct Holder {\n  item: Item\n}\npub fn main() -> I32 {\n  let holder = Holder { item: Item {} }\n  let item = Item {}\n  let callback = fn() -> I32 {\n    item.read()\n  }\n  holder.item.read() + callback()\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.types", [
        @semantic.ManifestFile::new("types.dew", b"pub struct Item {}\n"),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.impl_index.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "generic bound calls cast specialized nominal parameters" {
  let program = @semantic.collect_program_manifest(
    2479UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nstruct Item {}\nimpl Value for Item {\n  fn value(self) -> I32 {\n    42\n  }\n}\nfn read<t: Value>(value: t) -> I32 {\n  value.value()\n}\npub fn main() -> I32 {\n  read(Item::{})\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "public generic evidence fallbacks retain source bound order" {
  let program = @semantic.collect_program_manifest(
    2480UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"trait First {}\ntrait Second {\n  fn second(self) -> I32\n}\nimpl First for I32 {}\nimpl Second for I32 {\n  fn second(self) -> I32 {\n    self\n  }\n}\npub fn erase<t: First + Second>(value: t) -> Second {\n  value\n}\nfn invoke(value: Second) -> I32 {\n  value.second()\n}\npub fn main() -> I32 {\n  invoke(erase(42))\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let erase = program.modules[0].lookup_value("erase").unwrap()
  let mut fallbacks = 0
  for function_ in link.functions {
    if function_.declaration != erase ||
      function_.specialization_evidence.length != 2 ||
      function_.elided {
      continue
    }
    let fragments = link.modules[function_.module_index]
    let first_root = fragments.specialization_evidence_roots[function_.specialization_evidence.start]
    match fragments.specialization_trait_evidence[first_root].kind {
      @semantic.PlannedRuntimeTraitEvidence(_, _) => ()
      _ => continue
    }
    assert_eq(function_.parameters.length, 3)
    for slot in 0..<2 {
      let root = fragments.specialization_evidence_roots[function_.specialization_evidence.start +
        slot]
      match fragments.specialization_trait_evidence[root].kind {
        @semantic.PlannedRuntimeTraitEvidence(_, parameter) =>
          assert_eq(parameter, slot + 1)
        _ => fail("expected ordered runtime evidence parameter")
      }
    }
    fallbacks += 1
  }
  assert_eq(fallbacks, 1)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "public generic evidence fallbacks dispatch bound operators" {
  let program = @semantic.collect_program_manifest(
    2481UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"pub fn sum<t: Add>(left: t, right: t) -> t {\n  left + right\n}\npub fn main() -> I32 {\n  sum(20, 22)\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics.length(), 0)
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let sum = program.modules[0].lookup_value("sum").unwrap()
  let mut fallbacks = 0
  for function_ in link.functions {
    if function_.declaration != sum ||
      function_.specialization_evidence.length != 1 ||
      function_.elided {
      continue
    }
    let fragments = link.modules[function_.module_index]
    let root = fragments.specialization_evidence_roots[function_.specialization_evidence.start]
    match fragments.specialization_trait_evidence[root].kind {
      @semantic.PlannedRuntimeTraitEvidence(_, parameter) => {
        assert_eq(parameter, 2)
        assert_eq(function_.parameters.length, 3)
        fallbacks += 1
      }
      _ => ()
    }
  }
  assert_eq(fallbacks, 1)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "concrete bounded generic function references preserve evidence" {
  let program = @semantic.collect_program_manifest(
    2484UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\nfn read<t: Value>(value: t) -> I32 {\n  value.value()\n}\npub fn main() -> I32 {\n  let callback: fn(I32) -> I32 = read\n  callback(42)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.evidence_function_references.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "unbounded generic function references keep the singleton fast path" {
  let program = @semantic.collect_program_manifest(
    2487UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"fn identity<t>(value: t) -> t {\n  value\n}\nfn reader<t>() -> fn(t) -> t {\n  identity\n}\npub fn main() -> I32 {\n  let callback: fn(I32) -> I32 = reader()\n  callback(42)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.evidence_function_references.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "erased trait dictionaries capture caller runtime prerequisites" {
  let program = @semantic.collect_program_manifest(
    2488UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\nfn erase_read<t: Read>(value: t) -> Read {\n  value\n}\nfn helper<t: Value>(value: t) -> Read {\n  erase_read(Box::{\n    value: value\n  })\n}\npub fn outer<t: Value>(value: t) -> Read {\n  helper(value)\n}\nfn invoke(value: Read) -> I32 {\n  value.read()\n}\npub fn main() -> I32 {\n  let result = invoke(outer(42))\n  assert(result == 42, \"captured erased dictionary result\")\n  result\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let mut target = 0UL
  let mut target_key = ""
  for module_fragments in link.modules {
    for dictionary in module_fragments.trait_dictionaries {
      if dictionary.runtime_evidence_parameters.length > 0 {
        let method_info = module_fragments.trait_methods[dictionary.methods.start]
        target = method_info.implementation_method
        target_key = method_info.implementation_specialization_abi_key
      }
    }
  }
  assert_true(target > 0UL)
  assert_true(target_key != "")
  let mut targets = 0
  for function_ in link.functions {
    if function_.declaration == target &&
      function_.specialization_abi_key == target_key &&
      !function_.elided {
      targets += 1
    }
  }
  assert_eq(targets, 1)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  while link.modules[0].trait_dictionary_runtime_evidence_parameters.length() >
        0 {
    ignore(link.modules[0].trait_dictionary_runtime_evidence_parameters.pop())
  }
  match emit_starshine_program_module(lowering, link) {
    Err(MissingFunction(_)) => ()
    _ => fail("expected malformed captured dictionary span to fail visibly")
  }
}

///|
test "imported erased trait dictionaries capture caller runtime prerequisites" {
  let program = @semantic.collect_program_manifest(
    2489UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.provider", [
        @semantic.ManifestFile::new(
          "provider.dew", b"pub trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\npub trait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\npub fn erase<t: Value>(value: t) -> Read {\n  Box::{\n    value: value\n  }\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.provider\npub fn outer<t: Value>(value: t) -> Read {\n  erase(value)\n}\nfn invoke(value: Read) -> I32 {\n  value.read()\n}\npub fn main() -> I32 {\n  let result = invoke(outer(42))\n  assert(result == 42, \"imported captured erased dictionary result\")\n  result\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics.length(), 0)
  }
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 1)
  assert_eq(link.diagnostics.length(), 0)
  let mut captured = 0
  for module_ in link.modules {
    for dictionary in module_.trait_dictionaries {
      if dictionary.runtime_evidence_parameters.length > 0 {
        captured += 1
      }
    }
  }
  assert_eq(captured, 1)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "escaping bounded function references capture runtime evidence" {
  let program = @semantic.collect_program_manifest(
    2485UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\nfn read<t: Value>(value: t) -> I32 {\n  value.value()\n}\npub fn reader<t: Value>() -> fn(t) -> I32 {\n  read\n}\nfn invoke(callback: fn(I32) -> I32) -> I32 {\n  callback(42)\n}\npub fn main() -> I32 {\n  invoke(reader())\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.evidence_function_references.length(), 2)
  let mut captured = 0
  for reference in link.evidence_function_references {
    if reference.runtime_evidence_parameters.length > 0 {
      captured += 1
    }
  }
  assert_eq(captured, 1)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
  while link.evidence_function_reference_runtime_evidence_parameters.length() >
        0 {
    ignore(link.evidence_function_reference_runtime_evidence_parameters.pop())
  }
  match emit_starshine_program_module(lowering, link) {
    Err(UnsupportedExpression(_, _)) => ()
    _ => fail("expected malformed evidence-capture span to fail visibly")
  }
}

///|
test "escaping bounded imported function references capture runtime evidence" {
  let program = @semantic.collect_program_manifest(
    2486UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.provider", [
        @semantic.ManifestFile::new(
          "provider.dew", b"pub trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\npub fn read<t: Value>(value: t) -> I32 {\n  value.value()\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.provider\npub fn reader<t: Value>() -> fn(t) -> I32 {\n  read\n}\nfn invoke(callback: fn(I32) -> I32) -> I32 {\n  callback(42)\n}\npub fn main() -> I32 {\n  let result = invoke(reader())\n  assert(result == 42, \"imported captured callback result\")\n  result\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics.length(), 0)
  }
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 1)
  assert_eq(link.diagnostics.length(), 0)
  let read = program.modules[0].lookup_value("read").unwrap()
  let mut captured = 0
  for reference in link.evidence_function_references {
    if reference.target == read &&
      reference.runtime_evidence_parameters.length > 0 {
      captured += 1
    }
  }
  assert_eq(captured, 1)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "public runtime evidence forwards through imported recursive generics" {
  let program = @semantic.collect_program_manifest(
    2482UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.provider\npub fn read<t: Value>(value: t) -> I32 {\n  forwarded_read(0, value)\n}\npub fn main() -> I32 {\n  read(42)\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.provider", [
        @semantic.ManifestFile::new(
          "provider.dew", b"pub trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\nfn finish_read<t: Value>(remaining: I32, prefix: I32, value: t) -> I32 {\n  if remaining > 0 {\n    finish_read(remaining - 1, prefix, value)\n  } else {\n    prefix + value.value()\n  }\n}\npub fn forwarded_read<t: Value>(prefix: I32, value: t) -> I32 {\n  finish_read(0, prefix, value)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics.length(), 0)
  }
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let read = program.modules[0].lookup_value("read").unwrap()
  let forwarded = program.modules[1].lookup_value("forwarded_read").unwrap()
  let finish = program.modules[1].lookup_value("finish_read").unwrap()
  let mut runtime_functions = 0
  for function_ in link.functions {
    if function_.elided || function_.specialization_evidence.length != 1 {
      continue
    }
    let fragments = link.modules[function_.module_index]
    let root = fragments.specialization_evidence_roots[function_.specialization_evidence.start]
    match fragments.specialization_trait_evidence[root].kind {
      @semantic.PlannedRuntimeTraitEvidence(_, _) =>
        if function_.declaration == read {
          assert_eq(function_.parameters.length, 2)
          runtime_functions += 1
        } else if function_.declaration == forwarded {
          assert_eq(function_.parameters.length, 3)
          runtime_functions += 1
        } else if function_.declaration == finish {
          assert_eq(function_.parameters.length, 4)
          runtime_functions += 1
        }
      _ => ()
    }
  }
  assert_eq(runtime_functions, 3)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "public runtime evidence forwards recursive static prerequisite trees" {
  let program = @semantic.collect_program_manifest(
    2483UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\ntrait Inspect {\n  fn inspect(self) -> I32\n}\nstruct Wrap<t> {\n  value: t\n}\nimpl<t: Read> Inspect for Wrap<t> {\n  fn inspect(self) -> I32 {\n    self.value.read()\n  }\n}\nfn consume<t: Inspect>(value: t) -> I32 {\n  value.inspect()\n}\npub fn nested_read<t: Value>(value: t) -> I32 {\n  consume(Wrap::{\n    value: Box::{\n      value: value\n    }\n  })\n}\npub fn main() -> I32 {\n  nested_read(42)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "open generic prerequisite dictionaries emit valid adapters" {
  let program = @semantic.collect_program_manifest(
    2477UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\nfn choose<t: Read>(flag: Bool, value: t) -> Read {\n  if flag {\n    value\n  } else {\n    value\n  }\n}\nfn invoke(value: Read) -> I32 {\n  value.read()\n}\npub fn main() -> I32 {\n  invoke(choose(true, Box::{\n    value: 42\n  }))\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.modules[0].trait_dictionaries.length(), 1)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "imported open generic dictionaries share canonical trait layouts" {
  let program = @semantic.collect_program_manifest(
    2478UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.provider\nfn invoke(value: Value) -> I32 {\n  value.value()\n}\npub fn main() -> I32 {\n  invoke(choose(true, 42))\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.provider", [
        @semantic.ManifestFile::new(
          "provider.dew", b"pub trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\npub fn choose<t: Value>(flag: Bool, value: t) -> Value {\n  if flag {\n    value\n  } else {\n    value\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "program emitter includes unreferenced aggregate type groups" {
  let program = @semantic.collect_program_manifest(
    2500UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"pub struct Item {}\npub fn run() -> I32 {\n  1\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}
