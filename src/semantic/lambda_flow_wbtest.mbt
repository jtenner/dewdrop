///|
test "lambda flow analysis owns non-exhaustive and unreachable diagnostics" {
  let collected = collect_bytes(
    630UL, b"fn main() -> Unit {\n  let choose = fn(value: Bool) -> I32 {\n    match value {\n      true => 1\n    }\n  }\n  let stopped = fn() -> I32 {\n    return 1\n    2\n  }\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let flows = analyze_module_flows(collected, resolved, inferred)
  assert_eq(inferred.diagnostics.length(), 0)
  assert_eq(flows.lambdas.length(), 2)
  assert_eq(flows.lambda(0).unwrap().diagnostics.length, 1)
  assert_eq(flows.lambda(1).unwrap().diagnostics.length, 1)
  assert_eq(flows.diagnostics.length(), 2)
  match flows.diagnostics[0] {
    NonExhaustiveMatch(_, missing, _) => {
      assert_eq(missing.length, 1)
      assert_eq(flows.missing_cases[missing.start], MissingBoolCase(false))
    }
    _ => fail("expected lambda exhaustiveness diagnostic")
  }
  match flows.diagnostics[1] {
    UnreachableBlockItem(_, 1, _) => ()
    _ => fail("expected lambda unreachable-item diagnostic")
  }
  assert_true(flows.lambda(0).unwrap().flow.may_fall_through())
  assert_true(flows.lambda(1).unwrap().flow.may_return())
  assert_false(flows.lambda(1).unwrap().flow.may_fall_through())
}
