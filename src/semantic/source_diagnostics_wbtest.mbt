///|
fn source_diagnostic_program(
  files : Array[ManifestFile],
) -> (
  CollectedProgram,
  AnalyzedProgramSemantics,
  PlannedProgramLowering,
  PlannedProgramWasmGCLink,
) {
  let program = collect_program_manifest(
    2600UL,
    ProgramManifest::new([ManifestModule::new("app", files)]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  (program, analyzed, lowering, link)
}

///|
test "HIR nodes retain exact source files across one module" {
  let (program, _, _, _) = source_diagnostic_program([
    ManifestFile::new(
      "first.dew", b"fn first(value: I32) -> I32 {\n  value\n}\n",
    ),
    ManifestFile::new(
      "second.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\n\npub fn second(value: Pair) -> Pair {\n  let identity = fn(value: I32) -> I32 {\n    value\n  }\n  match value {\n    Pair {\n      left: left\n      right: right\n    } => Pair::{\n      left: identity(right)\n      right: left\n    }\n  }\n}\n",
    ),
  ])
  let collected = program.modules[0]
  let second_file = make_program_file_id(2600UL, 1)
  let second = collected
    .body_of(collected.lookup_value("second").unwrap())
    .unwrap()
  for
    expression in second.expressions.start..<(second.expressions.start +
    second.expressions.length) {
    assert_eq(collected.expression_files[expression], second_file)
  }
  for
    block in second.blocks.start..<(second.blocks.start + second.blocks.length) {
    assert_eq(collected.block_files[block], second_file)
  }
  for
    item in second.block_items.start..<(second.block_items.start +
    second.block_items.length) {
    assert_eq(collected.block_item_files[item], second_file)
  }
  for
    field in second.object_fields.start..<(second.object_fields.start +
    second.object_fields.length) {
    assert_eq(collected.object_field_files[field], second_file)
  }
  for
    pattern in second.patterns.start..<(second.patterns.start +
    second.patterns.length) {
    assert_eq(collected.pattern_files[pattern], second_file)
  }
  for
    field in second.pattern_fields.start..<(second.pattern_fields.start +
    second.pattern_fields.length) {
    assert_eq(collected.pattern_field_files[field], second_file)
  }
  for
    arm in second.pattern_arms.start..<(second.pattern_arms.start +
    second.pattern_arms.length) {
    assert_eq(collected.pattern_arm_files[arm], second_file)
  }
  for parameter_file in collected.lambda_parameter_files {
    assert_eq(parameter_file, second_file)
  }
  let second_declaration = collected.lookup_value("second").unwrap()
  let parameter_span = collected.parameters_of(second_declaration)
  assert_eq(
    collected.type_syntax_files[collected.parameters[parameter_span.start].type_],
    second_file,
  )
  let source = program.source_file(second_file).unwrap()
  assert_eq(source.path, "second.dew")
  assert_eq(source.line_column(0UL), {
    line: 1,
    column: 1,
    line_start: 0,
    line_end: 13,
  })
}

///|
test "source line lookup uses stable byte columns and CRLF lines" {
  let file = ProgramFile::named(
    make_file_id(2601UL, 0),
    "unicode.dew",
    b"\xCE\xBBx\r\nnext",
  )
  assert_eq(file.line_column(2UL), {
    line: 1,
    column: 3,
    line_start: 0,
    line_end: 3,
  })
  assert_eq(file.line_column(5UL), {
    line: 2,
    column: 1,
    line_start: 5,
    line_end: 9,
  })
}

///|
test "source diagnostics render line columns excerpts and secondary labels" {
  let (program, analyzed, lowering, link) = source_diagnostic_program([
    ManifestFile::new("first.dew", b"fn same() -> I32 {\n  1\n}\n"),
    ManifestFile::new("second.dew", b"fn same() -> I32 {\n  2\n}\n"),
  ])
  let diagnostics = collect_compiler_source_diagnostics(
    program, analyzed, lowering, link,
  )
  assert_true(diagnostics.length() >= 1)
  let rendered = render_compiler_source_diagnostic(program, diagnostics[0])
  inspect(
    rendered,
    content="second.dew:1:4: error: DuplicateName(\n  {\n    space: ModuleValue,\n    name: 0,\n    first: 11166914969600,\n    duplicate: 11166914969601,\n    first_file: 11166914969856,\n    duplicate_file: 11166914969857,\n    first_offset: 3,\n    duplicate_offset: 3,\n  },\n)\n  |\n1 | fn same() -> I32 {\n  |    ^\n  = first.dew:1:4: first declaration is here",
  )
}
