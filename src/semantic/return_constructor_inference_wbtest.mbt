///|
test "a matched field provides context for short variant names" {
  let (collected, _, names, inferred) = call_test_module(
    492UL,
    b"enum First {\n  Item(I32)\n}\nenum Second {\n  Item(I64)\n}\nstruct Holder {\n  source: First\n}\nfn read(holder: Holder) -> I32 {\n  match holder.source {\n    Item(value) => value\n  }\n}\n",
  )
  assert_eq(collected.bodies.length(), 1)
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics, [])
}

///|
test "bare struct variant constructors use the expected enum" {
  let (collected, _, _, inferred) = call_test_module(
    490UL,
    b"enum Small {\n  Entry {\n    value: I32\n  }\n}\nenum Wide {\n  Entry {\n    value: I64\n  }\n}\nfn small() -> Small {\n  Entry::{\n    value: 7\n  }\n}\nfn wide() -> Wide {\n  Entry::{\n    value: 8i64\n  }\n}\n",
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.bodies.length(), 2)
  assert_eq(inferred.diagnostics, [])
}

///|
test "bare struct variant constructors reject ambiguous owners" {
  let (collected, _, names, inferred) = call_test_module(
    491UL,
    b"enum First {\n  Entry {\n    value: I32\n  }\n}\nenum Second {\n  Entry {\n    value: I32\n  }\n}\nfn run() -> Unit {\n  let entry = Entry::{\n    value: 7\n  }\n  ()\n}\n",
  )
  assert_eq(collected.bodies.length(), 1)
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_true(inferred.diagnostics.any(fn(diagnostic) {
    diagnostic is AmbiguousVariantValue(_, _, _, _, 2, _)
  }))
}

///|
test "imports and opens expose enum constructors without a type prefix" {
  for consumer in [
    b"import app.library\nfn make() -> Payload {\n  Entry::{\n    value: 7\n  }\n}\nfn read(value: Payload) -> I32 {\n  match value {\n    Entry {\n      value: item\n    } => item\n  }\n}\n",
    b"open app.library\nfn make() -> Payload {\n  Entry::{\n    value: 7\n  }\n}\nfn read(value: Payload) -> I32 {\n  match value {\n    Entry {\n      value: item\n    } => item\n  }\n}\n",
  ] {
    let (program, frozen, _, names, inferred) = imported_semantic_program(
      consumer,
      b"pub enum Payload {\n  Entry {\n    value: I32\n  }\n}\n",
    )
    assert_eq(program.modules[0].bodies.length(), 2)
    assert_eq(program.modules[0].diagnostics.length(), 0)
    assert_eq(frozen.import_diagnostics.length(), 0)
    assert_eq(names.diagnostics.length(), 0)
    assert_eq(inferred.diagnostics.length(), 0)
  }
}

///|
test "return expressions and unqualified constructors infer from context" {
  let (_, _, _, inferred) = call_test_module(
    489UL, b"enum Result<t, e> {\n  Ok(t)\n  Err(e)\n}\nenum Option<t> {\n  Some(t)\n  None\n}\nenum Unique {\n  Only(I32)\n}\nfn sample(value: Result<I32, String>) -> Option<I32> {\n  match value {\n    Ok(val) => return None\n    Err(_) => ()\n  }\n  Some(42)\n}\nfn unique_without_context() -> Unit {\n  let selected = Only(1)\n  ()\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
}
