///|
test "compile time selected source: lambda parameter types use the selected source mapping" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Record {\n  value: I32\n}\nfn read<T>(value: T) -> I32 {\n  let call = fn(item: T) -> I32 {\n    if is_unit::<T>() {\n      0i32\n    } else {\n      item.value\n    }\n  }\n  call(value)\n}\npub fn main() -> I32 {\n  read(()) + read(Record::{\n    value: 42i32\n  })\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time selected source: a selected return removes later dependent field checks" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn read<T>(value: T) -> I32 {\n  if is_integer::<T>() {\n    return 42i32\n    value.missing\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  read(7i64)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time selected source: selected short circuit skips its dependent right operand" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn read<T>(value: T) -> I32 {\n  if is_integer::<T>() {\n    let yes = is_integer::<T>() || value.missing\n    if yes {\n      42i32\n    } else {\n      0i32\n    }\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  read(7i64)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time selected source: a nonreturning call operand removes later dependent checks" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nbuiltin stop() -> Never = \"dew_unreachable\"\nfn accept(left: I32, right: I32) -> I32 {\n  right\n}\nfn read<T>(value: T, flag: Bool) -> I32 {\n  if is_integer::<T>() {\n    if flag {\n      accept(stop(), value.missing)\n    } else {\n      42i32\n    }\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  read(7i64, false)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}
