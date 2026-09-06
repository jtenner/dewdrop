///|
test "generic tuple variant bindings use specialized product storage" {
  let stages = backend_test_single_module_stages(
    28118UL, b"enum Maybe<t> {\n  Empty\n  Value(t)\n}\nfn extract<t>(value: Maybe<t>) -> t {\n  match value {\n    Maybe::Value(item) => item\n    Maybe::Empty => unreachable()\n  }\n}\npub fn run() -> I64 {\n  let (left, right) = extract(Maybe::Value((1i32, 2i64)))\n  right\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_binary(stages.lowering, stages.link) {
    Ok(_) => ()
    Err(error) => fail(@debug.to_string(error))
  }
}
