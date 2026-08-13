///|
fn wide_construction_source(field_count : Int) -> Bytes {
  let output = Buffer(size_hint=field_count * 48 + 128)
  output.write_string_utf8("struct Wide {\n")
  for index in 0..<field_count {
    output.write_string_utf8("  field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": I32\n")
  }
  output.write_string_utf8("}\nfn make() -> Wide {\n  Wide::{\n")
  for index in 0..<field_count {
    output.write_string_utf8("    field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("  }\n}\n")
  output.to_bytes()
}

///|
fn nested_member_source(depth : Int, objects : Bool) -> Bytes {
  let output = Buffer(size_hint=depth * 64 + 256)
  output.write_string_utf8("struct Node0 {\n  value: I32\n}\n")
  for index in 1..<=depth {
    output.write_string_utf8("struct Node")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {\n  next: Node")
    output.write_string_utf8((index - 1).to_string())
    output.write_string_utf8("\n}\n")
  }
  if objects {
    output.write_string_utf8("fn make() -> Node")
    output.write_string_utf8(depth.to_string())
    output.write_string_utf8(" {\n")
    for _ in 0..<depth {
      output.write_string_utf8("  {\n    next: ")
    }
    output.write_string_utf8("{\n  value: 1\n}")
    for _ in 0..<depth {
      output.write_string_utf8("\n  }\n")
    }
    output.write_string_utf8("}\n")
  } else {
    output.write_string_utf8("fn read(value: Node")
    output.write_string_utf8(depth.to_string())
    output.write_string_utf8(") -> I32 {\n  value")
    for _ in 0..<depth {
      output.write_string_utf8(".next")
    }
    output.write_string_utf8(".value\n}\n")
  }
  output.to_bytes()
}

///|
test "construction inference handles 512 fields with stable targets" {
  let (collected, _, _, inferred) = call_test_module(
    501UL,
    wide_construction_source(512),
  )
  assert_eq(inferred.diagnostics.length(), 0)
  assert_eq(inferred.object_field_targets.length(), 512)
  for index, target in inferred.object_field_targets {
    assert_eq(target, SelectedObjectFieldTarget(collected.fields[index].id))
  }
}

///|
test "member worklist handles 512 nested expected objects iteratively" {
  let (_, _, _, inferred) = call_test_module(
    502UL,
    nested_member_source(512, true),
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let mut selected = 0
  for selection in inferred.expression_selections {
    match selection {
      StructConstructionSelection(_, _) => selected += 1
      _ => ()
    }
  }
  assert_eq(selected, 513)
}

///|
test "member worklist handles a 512-field access chain iteratively" {
  let (_, resolved, _, inferred) = call_test_module(
    503UL,
    nested_member_source(512, false),
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let mut selected = 0
  let mut final_type = 0
  for index, selection in inferred.expression_selections {
    match selection {
      FieldAccessSelection(_) => {
        selected += 1
        final_type = inferred.expression_types[index]
      }
      _ => ()
    }
  }
  assert_eq(selected, 513)
  assert_call_primitive(inferred, resolved, final_type, I32Type)
}
