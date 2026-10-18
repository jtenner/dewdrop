///|
test "ordinary imported JSON constructors cannot forge checked provenance" {
  let sources = [
    b"open dew.std.json\npub fn forge() -> JsonNumber {\n  JsonNumber::{\n    lexeme: \"BAD\"\n  }\n}\n",
    b"open dew.std.json\npub fn forge() -> JsonString {\n  JsonString::{\n    value: \"a\\\"b\"\n    needs_escape: false\n  }\n}\n",
    b"open dew.std.json\npub fn forge() -> JsonDocument {\n  JsonDocument::{\n    source: \"BAD\"\n    value: JsonValue::Null\n  }\n}\n",
    b"open dew.std.json\npub fn forge() -> JsonRawDocument {\n  JsonRawDocument::{\n    source: \"BAD\"\n    limits: json_default_limits()\n  }\n}\n",
  ]
  for source in sources {
    let program = compiler_test_single_module_program(28403UL, source)
    assert_eq(program.diagnostics, [])
    assert_eq(program.modules[0].diagnostics, [])
    let analyzed = analyze_program_semantics(program)
    assert_true(
      analyzed.modules[0].inferred.diagnostics.any(diagnostic =>
        diagnostic is UnknownConstructionField(_, _, _)),
    )
  }
}
