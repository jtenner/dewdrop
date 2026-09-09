///|
test "unknown builtins fail instead of becoming host imports" {
  for case in [
    (b"builtin unknown(value: I32) -> I32 = \"custom.host\"\npub fn run(value: I32) -> I32 {\n  unknown(value)\n}\n", b"custom.host"),
    (b"builtin unknown(value: I32) -> I32 = \"wasi_snapshot_preview1.args_get\"\npub fn run(value: I32) -> I32 {\n  unknown(value)\n}\n", b"wasi_snapshot_preview1.args_get"),
    (b"builtin unknown(value: I32) -> I32 = \"custom.host\"\npub fn run() -> fn(I32) -> I32 {\n  unknown\n}\n", b"custom.host"),
  ] {
    let (source, name) = case
    let stages = backend_test_single_module_stages(28201UL, source)
    assert_eq(stages.diagnostic_count(), 0)
    match emit_starshine_program_module(stages.lowering, stages.link) {
      Err(UnsupportedBuiltin(actual)) => assert_eq(actual, name)
      Err(error) => fail(@debug.to_string(error))
      Ok(_) => fail("unknown builtin emitted a module instead of a diagnostic")
    }
  }
}

///|
test "explicit foreign host calls still emit and validate" {
  let stages = backend_test_single_module_stages(
    28202UL, b"foreign import \"custom.host\" as Host {\n  fn send(value: I32) -> I32 = \"send\"\n}\npub fn run(value: I32) -> I32 {\n  Host.send(value)\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let module_ = stages.emit_module()
  assert_eq(@validate.validate_module(module_), Ok(()))
}
