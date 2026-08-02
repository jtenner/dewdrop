///|
test "signed literal boundary is valid only beneath unary negation" {
  let collected = collect_bytes(
    2530UL, b"fn invalid() -> I8 {\n  128i8\n}\nfn valid() -> I8 {\n  -128i8\n}\nfn invalid64() -> I64 {\n  9223372036854775808i64\n}\nfn valid64() -> I64 {\n  -9223372036854775808i64\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let mut range_errors = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      NumericLiteralOutOfRange(_, I8Type | I64Type, _) => range_errors += 1
      _ => ()
    }
  }
  assert_eq(range_errors, 2)
}
