///|
test "return expressions and unqualified constructors infer from context" {
  let (_, _, _, inferred) = call_test_module(
    489UL,
    b"enum Result<t, e> {\n  Ok(t)\n  Err(e)\n}\nenum Option<t> {\n  Some(t)\n  None\n}\nenum Unique {\n  Only(I32)\n}\nfn sample(value: Result<I32, String>) -> Option<I32> {\n  match value {\n    Ok(val) => return None\n    Err(_) => ()\n  }\n  Some(42)\n}\nfn unique_without_context() -> Unit {\n  let selected = Only(1)\n  ()\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
}
