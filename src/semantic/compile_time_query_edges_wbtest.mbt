///|
test "compile time query edge: owner and method generics have distinct logical slots" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box<t> {\n  item: t\n}\nimpl<t> Box<t> {\n  fn unrelated<u>(self, value: u) -> u {\n    value\n  }\n  fn compare<u>(self, value: u) -> Bool {\n    type_equal::<t, u>()\n  }\n}\npub fn main() -> Bool {\n  let box = Box::{\n    item: 0i32\n  }\n  box.compare(0i32) && !box.compare(0i64)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time query edge: concrete impl Self pure query has a logical identity" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box {\n  item: I64\n}\nimpl Box {\n  fn identity(self) -> Bool {\n    type_equal::<Self, Box>()\n  }\n}\npub fn main() -> Bool {\n  let box = Box::{\n    item: 0i64\n  }\n  box.identity()\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time query edge: projected function reference infers its owner from a later parameter" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box<t> {\n  item: t\n}\nfn keep<t>(value: field_type<t>(\"item\"), owner: t) -> field_type<t>(\"item\") {\n  value\n}\nfn invoke(callback: fn(I64, Box<I64>) -> I64) -> I64 {\n  callback(42i64, Box::{\n    item: 0i64\n  })\n}\npub fn main() -> I64 {\n  invoke(keep)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time query edge: member projection resolves a generic impl Self owner" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box<t> {\n  item: t\n}\nimpl<t> Box<t> {\n  fn keep(self, value: field_type<Self>(\"item\")) -> field_type<Self>(\"item\") {\n    value\n  }\n}\npub fn main() -> I64 {\n  let box = Box::{\n    item: 0i64\n  }\n  box.keep(42i64)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time query edge: implements proof selects a method on a compound generic target" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\ntrait Read {\n  fn read(self) -> I32\n}\nimpl Read for I32 {\n  fn read(self) -> I32 {\n    self\n  }\n}\nstruct Box<t> {\n  item: t\n}\nimpl<t: Read> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.item.read()\n  }\n}\nfn guarded<t>(value: Box<t>) -> I32 {\n  if implements::<Box<t>, Read>() {\n    value.read()\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  guarded(Box::{\n    item: 42i32\n  })\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time query edge: member projection resolves a concrete impl Self owner" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box {\n  item: I64\n}\nimpl Box {\n  fn keep(self, value: field_type<Self>(\"item\")) -> field_type<Self>(\"item\") {\n    value\n  }\n}\npub fn main() -> I64 {\n  let box = Box::{\n    item: 0i64\n  }\n  box.keep(42i64)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time query edge: nested projected function reference preserves owner equations" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box<t> {\n  item: t\n}\nfn keep<t>(value: (field_type<t>(\"item\"), t)) -> field_type<t>(\"item\") {\n  let (item, owner) = value\n  item\n}\nfn invoke(callback: fn((I64, Box<I64>)) -> I64) -> I64 {\n  callback((42i64, Box::{\n    item: 0i64\n  }))\n}\npub fn main() -> I64 {\n  invoke(keep)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}
