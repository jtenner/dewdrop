///|
test "optimizer flags preserve explicit pass order and compiler arguments" {
  let plan = bootstrap_parse_optimization([
    "--module", "sample", "--starshine-pass", "precompute", "--starshine-pass", "inlining",
    "--starshine-pass", "precompute", "main.dew", "-o", "out.wasm",
  ]).unwrap()
  assert_eq(plan.passes, ["precompute", "inlining", "precompute"])
  assert_eq(plan.arguments, ["--module", "sample", "main.dew", "-o", "out.wasm"])
  assert_true(plan.enabled())
}

///|
test "optimization is explicit and printable without source files" {
  let disabled = bootstrap_parse_optimization(["main.dew"]).unwrap()
  assert_false(disabled.enabled())
  let speed = bootstrap_parse_optimization([
    "--optimize", "speed", "--print-passes",
  ]).unwrap()
  assert_true(speed.enabled())
  assert_true(speed.print_passes)
  assert_true(speed.passes.contains("inlining"))
  assert_true(speed.passes.contains("remove-unused-module-elements"))
  assert_eq(speed.arguments, [])
}

///|
test "invalid and conflicting optimizer options retain useful diagnostics" {
  for
    args in [
      ["--optimize"],
      ["--starshine-pass"],
      ["--optimize", "missing"],
      ["--starshine-pass", "--traps-never-happen"],
      ["--optimize", "speed", "--starshine-pass", "vacuum"],
      ["--optimize", "none", "--optimize", "speed"],
    ] {
    match bootstrap_parse_optimization(args) {
      Ok(_) => fail("invalid optimization options were accepted: \{args}")
      Err(message) => assert_true(message.length() > 0)
    }
  }
}

///|
test "optimizer publication replaces output arguments without changing inputs" {
  assert_eq(
    bootstrap_optimizer_output_arguments(
      ["main.dew", "--output", "old.wasm", "--root", "main"],
      "temporary.wasm",
    ),
    ["main.dew", "--output", "temporary.wasm", "--root", "main"],
  )
}
