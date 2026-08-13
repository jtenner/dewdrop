///|
test "generic structural callback adapters validate flattened wrapper closures" {
  let program = @semantic.collect_program_manifest(
    2410UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"fn increment(value: I32) -> I32 {\n  value + 1\n}\nfn apply(callback: fn(I32) -> I32, value: I32) -> I32 {\n  callback(value)\n}\npub fn invoke<t>(callback: fn(t) -> t, value: t, first: Bool) -> t {\n  if first {\n    callback(value)\n  } else {\n    callback(value)\n  }\n}\npub fn invoke_nested<t>(callback: fn(fn(t) -> t, t) -> t, inner: fn(t) -> t, value: t, first: Bool) -> t {\n  if first {\n    callback(inner, value)\n  } else {\n    callback(inner, value)\n  }\n}\npub fn round_trip<t>(callback: fn(t) -> t, first: Bool) -> fn(t) -> t {\n  if first {\n    callback\n  } else {\n    callback\n  }\n}\npub fn main() -> Unit {\n  assert(invoke(increment, 41, true) == 42, \"callback\")\n  assert(invoke_nested(apply, increment, 41, true) == 42, \"nested callback\")\n  let returned = round_trip(increment, true)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let helper_plan = starshine_program_adapter_helper_plan(lowering, link)
  assert_true(helper_plan.wrappers.length() >= 8)
  let mut has_to_erased = false
  let mut has_from_erased = false
  for wrapper in helper_plan.wrappers {
    assert_true(wrapper.wrapper_type_index < 0)
    if wrapper.to_erased {
      has_to_erased = true
    } else {
      has_from_erased = true
    }
  }
  assert_true(has_to_erased)
  assert_true(has_from_erased)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "generic aggregate callback fields plan flattened wrapper closures" {
  let program = @semantic.collect_program_manifest(
    2411UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"struct CallbackBox<t> {\n  callback: fn(t) -> t\n}\nfn increment(value: I32) -> I32 {\n  value + 1\n}\npub fn identity_box<t>(value: CallbackBox<t>, first: Bool) -> CallbackBox<t> {\n  if first {\n    value\n  } else {\n    value\n  }\n}\npub fn main() -> Unit {\n  let box = identity_box(CallbackBox::{\n    callback: increment\n  }, true)\n  assert(true, \"aggregate callback\")\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let helper_plan = starshine_program_adapter_helper_plan(lowering, link)
  assert_true(helper_plan.wrappers.length() >= 2)
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}
