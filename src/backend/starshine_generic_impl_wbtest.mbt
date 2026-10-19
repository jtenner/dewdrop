///|
test "generic implementation queries emit checked calls" {
  let program = @semantic.collect_program_manifest(
    24980UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"import dew.std.types as @types\n\ntrait Answer {\n  fn answer(self) -> I32\n}\nstruct Left {\n  value: I32\n}\nstruct Right {\n  value: I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl Answer for Left {\n  fn answer(self) -> I32 {\n    self.value + 1i32\n  }\n}\nimpl Answer for Right {\n  fn answer(self) -> I32 {\n    self.value + 2i32\n  }\n}\nimpl<t: Answer> Answer for Box<t> {\n  fn answer(self) -> I32 {\n    self.value.answer() + if @types.type_equal::<t, Left>() {\n      1i32\n    } else {\n      2i32\n    }\n  }\n}\nfn read<t: Answer>(value: t) -> I32 {\n  value.answer()\n}\npub fn main() -> I32 {\n  let left = Box::{\n    value: Left::{\n      value: 18i32\n    }\n  }\n  let right = Box::{\n    value: Right::{\n      value: 18i32\n    }\n  }\n  read(left) + read(right)\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = @semantic.analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = @semantic.plan_unoptimized_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics, [])
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "generic implementation method types and evidence emit checked calls" {
  let program = @semantic.collect_program_manifest(
    24980UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"import dew.std.types as @types\ntrait Mark {\n  fn mark(self) -> I32\n}\nimpl Mark for U8 {\n  fn mark(self) -> I32 {\n    40i32\n  }\n}\nimpl Mark for U64 {\n  fn mark(self) -> I32 {\n    2i32\n  }\n}\ntrait Answer {\n  fn answer<u: Mark>(self, value: u) -> I32\n}\nstruct Left {}\nstruct Right {}\nstruct Box<t> {\n  value: t\n}\nimpl Answer for Left {\n  fn answer<u: Mark>(self, value: u) -> I32 {\n    value.mark()\n  }\n}\nimpl Answer for Right {\n  fn answer<u: Mark>(self, value: u) -> I32 {\n    value.mark()\n  }\n}\nimpl<t: Answer> Answer for Box<t> {\n  fn answer<u: Mark>(self, value: u) -> I32 {\n    let _ = @types.type_equal::<t, Left>()\n    let _ = @types.type_equal::<u, U8>()\n    self.value.answer(value)\n  }\n}\nfn read<t: Answer, u: Mark>(value: t, other: u) -> I32 {\n  value.answer(other)\n}\npub fn main() -> I32 {\n  let left = Box::{\n    value: Left::{}\n  }\n  let right = Box::{\n    value: Right::{}\n  }\n  read(left, 1u8) + read(right, 1u64)\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = @semantic.analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = @semantic.plan_unoptimized_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics, [])
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "generic implementation trait-only types emit checked calls" {
  let program = @semantic.collect_program_manifest(
    24980UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"import dew.std.types as @types\ntrait Answer<u> {\n  fn answer(self) -> I32\n}\nstruct Marker {}\nimpl<t> Answer<t> for Marker {\n  fn answer(self) -> I32 {\n    if @types.type_equal::<t, I32>() {\n      40i32\n    } else {\n      2i32\n    }\n  }\n}\nfn read<t: Answer<u>, u>(value: t) -> I32 {\n  value.answer()\n}\npub fn main() -> I32 {\n  read::<Marker, I32>(Marker::{}) + read::<Marker, I64>(Marker::{})\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = @semantic.analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = @semantic.plan_unoptimized_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics, [])
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}
