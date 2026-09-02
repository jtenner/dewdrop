///|
fn compiler_fact_test_section(
  source : Bytes,
) -> (@lib.Module, @representation.OptimizationFactsSec) raise {
  let stages = backend_test_single_module_stages(260831UL, source)
  assert_eq(stages.diagnostic_count(), 0)
  let module_ = stages.emit_module()
  assert_eq(@validate.validate_module(module_), Ok(()))
  let section = module_.compiler_fact_custom_section.unwrap()
  (module_, section.facts)
}

///|
test "Dewdrop attaches typed compiler facts after final module assembly" {
  let (module_, facts) = compiler_fact_test_section(
    b"pub fn main() -> U32 {\n  42u32\n}\n",
  )
  assert_eq(facts.producer.unwrap().name, "dewdrop")
  assert_eq(facts.producer.unwrap().version, "0.1.0")
  assert_true(facts.world is Some(_))
  assert_true(facts.functions.length() > 0)
  let bytes = @binary.encode_module(module_).unwrap()
  let decoded = @binary.decode_module(bytes).unwrap()
  assert_eq(@validate.validate_module(decoded), Ok(()))
  assert_eq(
    decoded.compiler_fact_custom_section,
    module_.compiler_fact_custom_section,
  )
  assert_eq(@binary.encode_module(decoded).unwrap(), bytes)
  let size = measure_starshine_compiler_fact_size(module_).unwrap()
  assert_true(size.compiler_facts_bytes > 0)
  assert_true(size.fact_bearing_wasm_bytes > size.core_wasm_bytes)
}

///|
test "small integer parameter and result facts use i32 carrier widths" {
  let (_, facts) = compiler_fact_test_section(
    b"pub fn bool_identity(value: Bool) -> Bool {\n  value\n}\npub fn i8_identity(value: I8) -> I8 {\n  value\n}\npub fn u8_identity(value: U8) -> U8 {\n  value\n}\npub fn i16_identity(value: I16) -> I16 {\n  value\n}\npub fn u16_identity(value: U16) -> U16 {\n  value\n}\n",
  )
  let mut saw_bool = false
  let mut saw_i8 = false
  let mut saw_u8 = false
  let mut saw_i16 = false
  let mut saw_u16 = false
  for function in facts.functions {
    let values : Array[@representation.ValueFacts] = []
    for parameter in function.parameters {
      match parameter.value {
        Some(value) => values.push(value)
        None => ()
      }
    }
    for result in function.results {
      match result.value {
        Some(value) => values.push(value)
        None => ()
      }
    }
    for value in values {
      match Some(value) {
        Some({ integer: Some(integer), .. }) => {
          assert_eq(integer.width, @representation.IntWidth::i32())
          match (integer.unsigned_range, integer.signed_range) {
            (Some({ min: 0UL, max: 1UL, }), _) => saw_bool = true
            (Some({ min: 0UL, max: 255UL, }), _) => saw_u8 = true
            (Some({ min: 0UL, max: 65535UL, }), _) => saw_u16 = true
            (_, Some({ min: -128L, max: 127L, })) => saw_i8 = true
            (_, Some({ min: -32768L, max: 32767L, })) => saw_i16 = true
            _ => ()
          }
        }
        _ => ()
      }
    }
  }
  assert_true(saw_bool)
  assert_true(saw_i8)
  assert_true(saw_u8)
  assert_true(saw_i16)
  assert_true(saw_u16)
}

///|
test "exact float constants preserve raw bits and proven IEEE classes" {
  let (_, facts) = compiler_fact_test_section(
    b"pub fn float32() -> F32 {\n  1.5f32\n}\npub fn positive_zero64() -> F64 {\n  0.0f64\n}\n",
  )
  let mut saw_f32 = false
  let mut saw_positive_zero = false
  for body in facts.bodies {
    for site in body.sites {
      match (site.facts.possible_values, site.facts.float_) {
        (
          Some(@representation.ClosedValueSet([@representation.F32Bits(_)])),
          Some({ possible_classes, .. }),
        ) if possible_classes.contains(
            @representation.FloatClassMask::positive_normal(),
          ) => saw_f32 = true
        (
          Some(@representation.ClosedValueSet([@representation.F64Bits(_)])),
          Some({ possible_classes, .. }),
        ) if possible_classes.contains(
            @representation.FloatClassMask::positive_zero(),
          ) => saw_positive_zero = true
        _ => ()
      }
    }
  }
  assert_true(saw_f32)
  assert_true(saw_positive_zero)
}

///|
test "known function singleton facts directize only under TrustAssertions" {
  let (module_, facts) = compiler_fact_test_section(
    b"fn increment(value: I32) -> I32 {\n  value + 1\n}\nfn escape(callback: fn(I32) -> I32) -> fn(I32) -> I32 {\n  callback\n}\npub fn main() -> I32 {\n  let callback = escape(increment)\n  callback(41)\n}\n",
  )
  let mut exact = 0
  for body in facts.bodies {
    for call in body.calls {
      if call.direct_target is Some(_) {
        exact += 1
      }
    }
  }
  assert_true(exact > 0)
  let ignored = @passes.apply_compiler_facts(
    module_,
    @passes.CompilerFactUsePolicy::ignore(),
  ).unwrap()
  let hinted = @passes.apply_compiler_facts(
    module_,
    @passes.CompilerFactUsePolicy::hints_only(),
  ).unwrap()
  let trusted = @passes.apply_compiler_facts(
    module_,
    @passes.CompilerFactUsePolicy::trust_assertions(),
  ).unwrap()
  assert_eq(ignored.stats.call_ref_converted, 0)
  assert_eq(hinted.stats.call_ref_converted, 0)
  assert_true(trusted.stats.call_ref_converted > 0)
  assert_eq(@validate.validate_module(trusted.module_), Ok(()))
}

///|
test "allocations carry non-null exact runtime type and allocation kind" {
  let (_, facts) = compiler_fact_test_section(
    b"pub struct Box {\n  value: I32\n}\nfn make(value: I32) -> Box {\n  Box::{\n    value: value\n  }\n}\npub fn main() -> I32 {\n  make(42).value\n}\n",
  )
  let mut allocations = 0
  let mut exact_nonnull = 0
  for body in facts.bodies {
    allocations += body.allocations.length()
    for site in body.sites {
      match site.facts.reference {
        Some(
          {
            nullability: Some(@representation.NonNull),
            heap: Some(@representation.ExactRuntimeType(_)),
            ..
          }
        ) => exact_nonnull += 1
        _ => ()
      }
    }
  }
  assert_true(allocations > 0)
  assert_true(exact_nonnull > 0)
}

///|
test "compiler facts are deterministic across repeated builds" {
  let source = b"pub fn main() -> U32 {\n  42u32\n}\n"
  let first = backend_test_single_module_stages(260833UL, source).emit_binary()
  let second = backend_test_single_module_stages(260833UL, source).emit_binary()
  assert_eq(first, second)
}

///|
test "compiler facts use absolute function indexes after imports" {
  let stages = backend_test_single_module_stages(
    260832UL, b"foreign impl \"host\" as Host {\n  fn value() -> I32 = \"value\"\n}\npub fn main() -> I32 {\n  Host.value()\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 1)
  let facts = stages.emit_module().compiler_fact_custom_section.unwrap().facts
  assert_true(facts.functions.any(fn(value) { value.function == 0U }))
  assert_true(facts.functions.any(fn(value) { value.function == 1U }))
  for body in facts.bodies {
    assert_true(body.function >= 1U)
  }
}

///|
test "compiler fact audit covers every frozen v1 top-level family" {
  let audit = starshine_compiler_fact_family_audit()
  assert_true(audit.length() >= 45)
  assert_true(audit.any(fn(entry) { entry.0 == "EffectFacts" }))
  assert_true(audit.any(fn(entry) { entry.0 == "NumericOperationSiteFacts" }))
  assert_eq(starshine_compiler_fact_proof_strengths().length(), 5)
}
