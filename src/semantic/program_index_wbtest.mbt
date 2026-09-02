///|
test "program index resolves packed semantic owners without duplicate maps" {
  let stages = compiler_test_stages(22903UL, [
    CompilerTestModule::new("app.main", [
      CompilerTestSource::new(
        "main.dew", b"struct Item {\n  value: I32\n}\npub fn read(item: Item) -> I32 {\n  item.value\n}\n",
      ),
    ]),
  ])
  let collected = stages.program.modules[0]
  let declaration = collected.lookup_value("read").unwrap()
  let body = collected.body_of(declaration).unwrap().id
  let item = collected.lookup_type("Item").unwrap()
  assert_eq(stages.lowering.index.module_index(collected.module_id), Some(0))
  assert_eq(stages.lowering.index.declaration_owner(declaration), Some(0))
  assert_eq(stages.lowering.index.body_owner(body), Some(0))
  assert_eq(stages.lowering.index.implementation_owner(declaration), Some(0))
  assert_eq(stages.lowering.index.type_owner(item), Some(0))
}

///|
test "physical linker receives a validated compact specialization plan" {
  let stages = compiler_test_stages(22904UL, [
    CompilerTestModule::new("app.main", [
      CompilerTestSource::new("main.dew", b"pub fn value() -> I32 {\n  42\n}\n"),
    ]),
  ])
  let plan = plan_program_wasmgc_fragments(stages.analyzed, stages.lowering)
  assert_eq(validate_program_specialization_plan(plan, stages.lowering), Ok(()))
  let invalid = { ..plan, modules: [], }
  match validate_program_specialization_plan(invalid, stages.lowering) {
    Err(error) =>
      assert_eq(
        error, "specialization plan module count does not match lowering",
      )
    Ok(_) => fail("expected invalid specialization plan")
  }
}
