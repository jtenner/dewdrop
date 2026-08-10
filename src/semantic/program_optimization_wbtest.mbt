///|
test "program optimization preserves its unoptimized input" {
  let program = collect_program_manifest(
    22804UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn increment(value: I32) -> I32 {\n  value + 1\n}\nfn apply(callback: fn(I32) -> I32, value: I32) -> I32 {\n  let result = callback(value)\n  result\n}\npub fn main() -> I32 {\n  apply(increment, 41)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  assert_eq(
    unoptimized.index.module_index(program.modules[0].module_id),
    Some(0),
  )
  assert_eq(optimized.index.module_index(program.modules[0].module_id), Some(0))
  let collected = program.modules[0]
  let apply = collected.lookup_value("apply").unwrap()
  let increment = collected.lookup_value("increment").unwrap()
  let main = collected.lookup_value("main").unwrap()
  let body = collected.body_of(main).unwrap()
  let call = body_calls(collected, body)[0]
  match unoptimized.modules[0].expressions[call].kind {
    PlannedDirectCall(declaration, _, arguments, _) => {
      assert_eq(declaration, apply)
      assert_eq(arguments.length, 2)
    }
    _ => fail("expected unoptimized callback wrapper call")
  }
  match optimized.modules[0].expressions[call].kind {
    PlannedDirectCall(declaration, _, arguments, _) => {
      assert_eq(declaration, increment)
      assert_eq(arguments.length, 1)
    }
    _ => fail("expected optimized callback wrapper directization")
  }
  assert_eq(unoptimized.elided_trait_wrappers.length(), 0)
}
