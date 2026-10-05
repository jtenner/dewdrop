///|
test "erased adapter kinds emit valid Wasm with exact linked targets" {
  let stages = backend_test_single_module_stages(
    28203UL, b"struct Item {\n  value: I32\n}\npub fn identity<t>(value: t) -> t {\n  value\n}\nfn return_identity() -> fn(Item) -> Item {\n  identity\n}\npub fn main() -> Unit {}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  let mut checked = 0
  for function_ in stages.link.functions {
    if function_.kind is @semantic.PlannedWasmErasedAdapterFunction {
      assert_true(function_.erased_adapter_target >= 0)
      let target = stages.link.erased_adapter_target_function(function_).unwrap()
      assert_eq(target.function_index, function_.erased_adapter_target)
      assert_eq(target.declaration, function_.declaration)
      checked += 1
    }
  }
  assert_eq(checked, 1)
}

///|
test "cyclic nominal erased adapters retain their exact fallback target" {
  let stages = backend_test_single_module_stages(
    28204UL,
    b"enum List<t> {\n  Nil\n  Cons(t, List<t>)\n}\npub fn echo_list<t>(value: List<t>) -> List<t> {\n  match value {\n    List::Nil => List::Nil\n    List::Cons(head, tail) => List::Cons(head, tail)\n  }\n}\npub fn main() -> Unit {\n  let value = echo_list(List::Cons(1, List::Cons(2, List::Nil)))\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let helper_plan = starshine_program_adapter_helper_plan(
    stages.lowering, stages.link,
  )
  let mut checked = 0
  for function_ in stages.link.functions {
    if function_.kind is @semantic.PlannedWasmErasedAdapterFunction {
      match
        starshine_program_erased_adapter_body(
          stages.lowering, stages.link, function_, helper_plan,
        ) {
        Ok(_) => ()
        Err(_) => fail("failed to emit cyclic nominal erased adapter")
      }
      checked += 1
    }
  }
  assert_eq(checked, 1)
  assert_eq(helper_plan.helpers.length(), 2)
  let mut to_erased = 0
  let mut from_erased = 0
  for helper in helper_plan.helpers {
    match
      emit_starshine_program_adapter_helper_body(
        stages.lowering, stages.link, helper_plan, helper,
      ) {
      Ok(_) => ()
      Err(_) => fail("failed to emit cyclic nominal adapter helper")
    }
    if helper.to_erased {
      to_erased += 1
    } else {
      from_erased += 1
    }
  }
  assert_eq(to_erased, 1)
  assert_eq(from_erased, 1)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  assert_true(stages.emit_binary().length() > 8)
}
