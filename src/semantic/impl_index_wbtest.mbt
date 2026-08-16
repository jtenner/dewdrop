///|
fn impl_test_module(
  module_id : UInt64,
  source : Bytes,
) -> (CollectedModule, ResolvedModuleTypes, ModuleImplIndex) {
  let collected = collect_bytes(module_id, source)
  let resolved = resolve_module_types(collected)
  let index = build_module_impl_index(collected, resolved)
  (collected, resolved, index)
}

///|
fn indexed_impl_test_module(
  module_id : UInt64,
  source : Bytes,
) -> (CollectedModule, ResolvedModuleTypes, ModuleImplIndex) {
  let collected = collect_bytes_with_standard_preamble(module_id, source)
  let resolved = resolve_module_types(collected)
  let index = build_module_impl_index(collected, resolved)
  (collected, resolved, index)
}

///|
test "trait_declaration impl index retains coherent method_info evidence" {
  let (collected, _, index) = impl_test_module(
    601UL, b"trait Show {\n  fn show(self) -> String\n}\nstruct Item {}\nimpl Show for Item {\n  fn show(self) -> String {\n    \"item\"\n  }\n}\n",
  )
  assert_eq(index.diagnostics.length(), 0)
  assert_eq(index.implementations.length(), 1)
  assert_eq(index.buckets.length(), 1)
  let implementation = index.implementations[0]
  match implementation.kind {
    TraitIndexedImpl(trait_declaration) =>
      assert_eq(trait_declaration, collected.declarations[0].id)
    _ => fail("expected trait_declaration impl")
  }
  assert_eq(
    implementation.target_head,
    NominalImplTargetHead(collected.declarations[1].id),
  )
  assert_true(implementation.coherent)
  assert_eq(implementation.methods.length, 1)
  let method_info = index.methods[implementation.methods.start]
  assert_eq(method_info.declaration, collected.methods[1].id)
  assert_eq(method_info.requirement, Some(collected.methods[0].id))
}

///|
test "inherent impls share a nominal bucket and retain static methods" {
  let (collected, _, index) = impl_test_module(
    602UL, b"struct Item {}\nimpl Item {\n  fn value(self) -> I32 {\n    1\n  }\n}\nimpl Item {\n  fn make() -> Item {\n    Item::{}\n  }\n}\n",
  )
  assert_eq(index.diagnostics.length(), 0)
  assert_eq(index.buckets.length(), 1)
  match index.buckets[0].kind {
    InherentImplBucket => ()
    _ => fail("expected inherent bucket")
  }
  assert_eq(index.buckets[0].implementations.length, 2)
  assert_eq(index.methods.length(), 2)
  assert_eq(index.methods[0].requirement, None)
  assert_eq(index.methods[1].declaration, collected.methods[1].id)
}

///|
test "equivalent trait impl patterns are incoherent" {
  let (_, _, index) = impl_test_module(
    603UL, b"trait Show {\n  fn show(self) -> I32\n}\nstruct Box<t> {}\nimpl<t> Show for Box<t> {\n  fn show(self) -> I32 {\n    1\n  }\n}\nimpl<u> Show for Box<u> {\n  fn show(self) -> I32 {\n    2\n  }\n}\n",
  )
  let mut overlap = 0
  for diagnostic in index.diagnostics {
    match diagnostic {
      OverlappingTraitImpl(_, _, _, _, _) => overlap += 1
      _ => ()
    }
  }
  assert_eq(overlap, 1)
  assert_false(index.implementations[0].coherent)
  assert_false(index.implementations[1].coherent)
}

///|
test "indexed traits allow only one implementation for each receiver type" {
  let (collected, _, index) = indexed_impl_test_module(
    615UL, b"struct Box<t> {}\nimpl<t> IndexedGet<U32, t> for Box<t> {\n  fn indexed_get(self, index: U32) -> t {\n    unreachable()\n  }\n}\nimpl IndexedGet<String, I32> for Box<I32> {\n  fn indexed_get(self, index: String) -> I32 {\n    1\n  }\n}\nimpl<t> IndexedSet<U32, t> for Box<t> {\n  fn indexed_set(self, index: U32, value: t) -> Unit {}\n}\nimpl IndexedSet<String, I32> for Box<I32> {\n  fn indexed_set(self, index: String, value: I32) -> Unit {}\n}\n",
  )
  let mut overlaps = 0
  for diagnostic in index.diagnostics {
    match diagnostic {
      OverlappingTraitImpl(_, _, _, _, _) => overlaps += 1
      _ => ()
    }
  }
  assert_eq(overlaps, 2)
  let box_head = NominalImplTargetHead(collected.lookup_type("Box").unwrap())
  for implementation in index.implementations {
    if implementation.target_head == box_head {
      assert_false(implementation.coherent)
    }
  }
}

///|
test "program modules enforce indexed implementation uniqueness" {
  let program = collect_program_manifest(
    617UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Box<t> {}\nimpl<t> IndexedGet<U32, t> for Box<t> {\n  fn indexed_get(self, index: U32) -> t {\n    unreachable()\n  }\n}\nimpl IndexedGet<String, I32> for Box<I32> {\n  fn indexed_get(self, index: String) -> I32 {\n    1\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let app = program.module_index("app.main").unwrap()
  let mut overlaps = 0
  for diagnostic in analyzed.modules[app].inferred.impl_index.diagnostics {
    match diagnostic {
      OverlappingTraitImpl(_, _, _, _, _) => overlaps += 1
      _ => ()
    }
  }
  assert_eq(overlaps, 1)
}

///|
test "indexed traits permit implementations for disjoint receiver types" {
  let (collected, _, index) = indexed_impl_test_module(
    616UL, b"struct Box<t> {}\nimpl IndexedGet<U32, I32> for Box<I32> {\n  fn indexed_get(self, index: U32) -> I32 {\n    1\n  }\n}\nimpl IndexedGet<String, Bool> for Box<Bool> {\n  fn indexed_get(self, index: String) -> Bool {\n    true\n  }\n}\nimpl IndexedSet<U32, I32> for Box<I32> {\n  fn indexed_set(self, index: U32, value: I32) -> Unit {}\n}\nimpl IndexedSet<String, Bool> for Box<Bool> {\n  fn indexed_set(self, index: String, value: Bool) -> Unit {}\n}\n",
  )
  assert_eq(index.diagnostics.length(), 0)
  let box_head = NominalImplTargetHead(collected.lookup_type("Box").unwrap())
  for implementation in index.implementations {
    if implementation.target_head == box_head {
      assert_true(implementation.coherent)
    }
  }
}

///|
test "trait_declaration impls diagnose missing unknown and receiver-mismatched methods" {
  let (_, _, index) = impl_test_module(
    604UL, b"trait Convert {\n  fn convert(self, value: I32) -> I32\n  fn reset(self) -> I32\n}\nstruct Item {}\nimpl Convert for Item {\n  fn convert(value: I32) -> I32 {\n    value\n  }\n  fn extra(self) -> I32 {\n    0\n  }\n}\n",
  )
  let mut missing = 0
  let mut unknown = 0
  let mut receiver = 0
  for diagnostic in index.diagnostics {
    match diagnostic {
      MissingTraitMethod(_, _, _) => missing += 1
      UnknownTraitImplMethod(_, _, _) => unknown += 1
      TraitMethodReceiverMismatch(_, _, _) => receiver += 1
      _ => ()
    }
  }
  assert_eq(missing, 1)
  assert_eq(unknown, 1)
  assert_eq(receiver, 1)
}

///|
test "impl target heads include primitives and reject open generic heads" {
  let (_, _, index) = impl_test_module(
    605UL, b"trait Show {\n  fn show(self) -> I32\n}\nimpl Show for I32 {\n  fn show(self) -> I32 {\n    self\n  }\n}\nimpl<t> Show for t {\n  fn show(self) -> I32 {\n    0\n  }\n}\n",
  )
  assert_eq(
    index.implementations[0].target_head,
    PrimitiveImplTargetHead(I32Type),
  )
  let mut invalid = 0
  for diagnostic in index.diagnostics {
    match diagnostic {
      InvalidImplTargetHead(_, _) => invalid += 1
      _ => ()
    }
  }
  assert_eq(invalid, 1)
}

///|
test "trait method signatures substitute trait generics and Self" {
  let (_, _, valid) = impl_test_module(
    607UL, b"trait Convert<t> {\n  fn convert(self, value: t) -> t\n}\nstruct Box<a> {}\nimpl<a> Convert<a> for Box<a> {\n  fn convert(self, value: a) -> a {\n    value\n  }\n}\n",
  )
  assert_eq(valid.diagnostics.length(), 0)
  let (_, _, invalid_generics) = impl_test_module(
    610UL, b"trait Choose {\n  fn choose(self, value: I32) -> I32\n}\nstruct Item {}\nimpl Choose for Item {\n  fn choose<u>(self, value: I32) -> I32 {\n    value\n  }\n}\n",
  )
  let mut generic_counts = 0
  for diagnostic in invalid_generics.diagnostics {
    match diagnostic {
      TraitMethodGenericParameterCountMismatch(_, _, _, _, _) =>
        generic_counts += 1
      _ => ()
    }
  }
  assert_eq(generic_counts, 1)
  let (_, _, invalid) = impl_test_module(
    608UL, b"trait Convert<t> {\n  fn convert(self, value: t) -> t\n}\nstruct Item {}\nimpl Convert<I32> for Item {\n  fn convert(self, value: Bool) -> Bool {\n    value\n  }\n}\n",
  )
  let mut parameters = 0
  let mut returns = 0
  for diagnostic in invalid.diagnostics {
    match diagnostic {
      TraitMethodParameterTypeMismatch(_, _, _, _) => parameters += 1
      TraitMethodReturnTypeMismatch(_, _, _) => returns += 1
      _ => ()
    }
  }
  assert_eq(parameters, 1)
  assert_eq(returns, 1)
}

///|
test "trait impl coherence distinguishes disjoint and strict specialization" {
  let (_, _, disjoint) = impl_test_module(
    611UL, b"trait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {}\nimpl Read for Box<I32> {\n  fn read(self) -> I32 {\n    1\n  }\n}\nimpl Read for Box<Bool> {\n  fn read(self) -> I32 {\n    2\n  }\n}\n",
  )
  assert_eq(disjoint.diagnostics.length(), 0)
  assert_true(disjoint.implementations[0].coherent)
  assert_true(disjoint.implementations[1].coherent)
  let (_, _, specialized) = impl_test_module(
    612UL, b"trait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {}\nimpl<t> Read for Box<t> {\n  fn read(self) -> I32 {\n    1\n  }\n}\nimpl Read for Box<I32> {\n  fn read(self) -> I32 {\n    2\n  }\n}\n",
  )
  assert_eq(specialized.diagnostics.length(), 0)
  assert_true(specialized.implementations[0].coherent)
  assert_true(specialized.implementations[1].coherent)
  assert_eq(specialized.implementations[0].specificity, 0)
  assert_eq(specialized.implementations[1].specificity, 1)
}

///|
test "trait application arguments participate in coherence" {
  let (_, _, index) = impl_test_module(
    614UL, b"trait Convert<t> {\n  fn convert(self) -> t\n}\nstruct Item {}\nimpl Convert<I32> for Item {\n  fn convert(self) -> I32 {\n    1\n  }\n}\nimpl Convert<Bool> for Item {\n  fn convert(self) -> Bool {\n    true\n  }\n}\n",
  )
  assert_eq(index.diagnostics.length(), 0)
  assert_true(index.implementations[0].coherent)
  assert_true(index.implementations[1].coherent)
}

///|
test "incomparable overlapping trait impl patterns are rejected" {
  let (_, _, index) = impl_test_module(
    613UL, b"trait Read {\n  fn read(self) -> I32\n}\nstruct Pair<a, b> {}\nimpl<a> Read for Pair<a, I32> {\n  fn read(self) -> I32 {\n    1\n  }\n}\nimpl<b> Read for Pair<Bool, b> {\n  fn read(self) -> I32 {\n    2\n  }\n}\n",
  )
  let mut overlaps = 0
  for diagnostic in index.diagnostics {
    match diagnostic {
      OverlappingTraitImpl(_, _, _, _, _) => overlaps += 1
      _ => ()
    }
  }
  assert_eq(overlaps, 1)
  assert_false(index.implementations[0].coherent)
  assert_false(index.implementations[1].coherent)
}

///|
test "inherent duplicate method_info names are diagnosed across impl blocks" {
  let (_, _, index) = impl_test_module(
    606UL, b"struct Item {}\nimpl Item {\n  fn value(self) -> I32 {\n    1\n  }\n}\nimpl Item {\n  fn value(self) -> I32 {\n    2\n  }\n}\n",
  )
  let mut duplicate = 0
  for diagnostic in index.diagnostics {
    match diagnostic {
      DuplicateInherentMethod(_, _, _, _) => duplicate += 1
      _ => ()
    }
  }
  assert_eq(duplicate, 1)
}
