///|
test "operator inference rejects heterogeneous operands before dispatch" {
  let collected = collect_bytes(
    993UL, b"trait Add<t> {\n  fn add(self, right: t) -> Self\n}\nimpl Add<I64> for I32 {\n  fn add(self, right: I64) -> I32 {\n    self\n  }\n}\nfn invalid(left: I32, right: I64) -> I32 {\n  left + right\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let declaration = collected.lookup_value("invalid").unwrap()
  let body = collected.body_of(declaration).unwrap()
  let mut operator = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match collected.expressions[expression] {
      HirBinaryExpr(HirAdd, _, _, _) => operator = expression
      _ => ()
    }
  }
  assert_true(operator >= 0)
  assert_eq(inferred.operator_targets[operator], ErrorInferredCallTarget)
  assert_true(inferred.diagnostics.length() > 0)
}
