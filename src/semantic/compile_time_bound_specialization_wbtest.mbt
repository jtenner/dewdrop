///|
test "generic implementation query arguments" {
  let (program, lowering) = compile_time_evidence_test(
    b"import dew.std.types as @types\n\ntrait Answer {\n  fn answer(self) -> I32\n}\nstruct Left {\n  value: I32\n}\nstruct Right {\n  value: I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl Answer for Left {\n  fn answer(self) -> I32 {\n    self.value + 1i32\n  }\n}\nimpl Answer for Right {\n  fn answer(self) -> I32 {\n    self.value + 2i32\n  }\n}\nimpl<t: Answer> Answer for Box<t> {\n  fn answer(self) -> I32 {\n    self.value.answer() + if @types.type_equal::<t, Left>() {\n      1i32\n    } else {\n      2i32\n    }\n  }\n}\nfn read<t: Answer>(value: t) -> I32 {\n  value.answer()\n}\npub fn main() -> I32 {\n  let left = Box::{\n    value: Left::{\n      value: 18i32\n    }\n  }\n  let right = Box::{\n    value: Right::{\n      value: 18i32\n    }\n  }\n  read(left) + read(right)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  let linked = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_eq(linked.diagnostics, [])
  assert_true(lowering.compile_time.unwrap().instances.length() > 1)
}

///|
test "generic implementation method arguments and evidence" {
  let (program, lowering) = compile_time_evidence_test(
    b"import dew.std.types as @types\ntrait Mark {\n  fn mark(self) -> I32\n}\nimpl Mark for U8 {\n  fn mark(self) -> I32 {\n    40i32\n  }\n}\nimpl Mark for U64 {\n  fn mark(self) -> I32 {\n    2i32\n  }\n}\ntrait Answer {\n  fn answer<u: Mark>(self, value: u) -> I32\n}\nstruct Left {}\nstruct Right {}\nstruct Box<t> {\n  value: t\n}\nimpl Answer for Left {\n  fn answer<u: Mark>(self, value: u) -> I32 {\n    value.mark()\n  }\n}\nimpl Answer for Right {\n  fn answer<u: Mark>(self, value: u) -> I32 {\n    value.mark()\n  }\n}\nimpl<t: Answer> Answer for Box<t> {\n  fn answer<u: Mark>(self, value: u) -> I32 {\n    let _ = @types.type_equal::<t, Left>()\n    let _ = @types.type_equal::<u, U8>()\n    self.value.answer(value)\n  }\n}\nfn read<t: Answer, u: Mark>(value: t, other: u) -> I32 {\n  value.answer(other)\n}\npub fn main() -> I32 {\n  let left = Box::{\n    value: Left::{}\n  }\n  let right = Box::{\n    value: Right::{}\n  }\n  read(left, 1u8) + read(right, 1u64)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  let linked = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_eq(linked.diagnostics, [])
  assert_true(lowering.compile_time.unwrap().instances.length() > 1)
}

///|
test "generic implementation trait-only arguments" {
  let (program, lowering) = compile_time_evidence_test(
    b"import dew.std.types as @types\ntrait Answer<u> {\n  fn answer(self) -> I32\n}\nstruct Marker {}\nimpl<t> Answer<t> for Marker {\n  fn answer(self) -> I32 {\n    if @types.type_equal::<t, I32>() {\n      40i32\n    } else {\n      2i32\n    }\n  }\n}\nfn read<t: Answer<u>, u>(value: t) -> I32 {\n  value.answer()\n}\npub fn main() -> I32 {\n  read::<Marker, I32>(Marker::{}) + read::<Marker, I64>(Marker::{})\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  let linked = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_eq(linked.diagnostics, [])
  assert_true(lowering.compile_time.unwrap().instances.length() > 1)
}
