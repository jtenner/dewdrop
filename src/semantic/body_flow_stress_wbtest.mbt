///|
fn flow_enum_source(variant_count : Int, repeated : Bool) -> Bytes {
  let output = Buffer(size_hint=variant_count * 48 + 160)
  output.write_string_utf8("enum State {\n")
  for index in 0..<variant_count {
    output.write_string_utf8("  V")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8(
    "}\nfn read(state: State) -> I32 {\n  match state {\n",
  )
  for index in 0..<variant_count {
    output.write_string_utf8("    V")
    output.write_string_utf8(if repeated { "0" } else { index.to_string() })
    output.write_string_utf8(" => 0\n")
  }
  if repeated {
    output.write_string_utf8("    _ => 1\n")
  }
  output.write_string_utf8("  }\n}\n")
  output.to_bytes()
}

///|
fn unreachable_items_source(item_count : Int) -> Bytes {
  let output = Buffer(size_hint=item_count * 12 + 64)
  output.write_string_utf8("fn stop() -> I32 {\n  return 0\n")
  for index in 0..<item_count {
    output.write_string_utf8("  ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "flow exhaustiveness handles 1024 enum variants iteratively" {
  let (_, _, _, flows) = flow_test_module(301UL, flow_enum_source(1024, false))
  assert_eq(flows.diagnostics.length(), 0)
}

///|
test "flow redundancy handles 1024 ordered arms iteratively" {
  let (_, _, _, flows) = flow_test_module(302UL, flow_enum_source(1024, true))
  let mut redundant_count = 0
  for diagnostic in flows.diagnostics {
    match diagnostic {
      RedundantPatternArm(_, _) => redundant_count += 1
      _ => ()
    }
  }
  assert_eq(redundant_count, 1023)
}

///|
test "flow sequencing reports 1024 unreachable block items iteratively" {
  let (_, _, _, flows) = flow_test_module(303UL, unreachable_items_source(1024))
  let mut unreachable_count = 0
  for diagnostic in flows.diagnostics {
    match diagnostic {
      UnreachableBlockItem(_, _, _) => unreachable_count += 1
      _ => ()
    }
  }
  assert_eq(unreachable_count, 1024)
}
