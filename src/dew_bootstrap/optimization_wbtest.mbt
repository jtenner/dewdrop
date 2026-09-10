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

///|
test "deep speed profile preserves verified local cleanup boundaries" {
  let plan = bootstrap_parse_optimization([
    "--optimize", "speed-deep", "--print-passes",
  ]).unwrap()
  assert_eq(plan.passes.length(), 50)
  assert_eq(plan.passes[6], "heap2local")
  assert_eq(plan.passes[7], "ssa-nomerge")
  assert_eq(plan.passes[8], "inlining")
  assert_eq(plan.passes[10], "simplify-locals-nostructure")
  assert_eq(plan.passes[12], "coalesce-locals")
  assert_eq(plan.passes[49], "strip-debug")
  assert_eq(
    plan.passes.filter(pass => pass == "simplify-locals-nostructure").length(),
    1,
  )
  assert_eq(plan.passes.filter(pass => pass == "coalesce-locals").length(), 1)
  assert_true(plan.enabled())
  assert_true(plan.print_passes)
  assert_eq(plan.arguments, [])
}
