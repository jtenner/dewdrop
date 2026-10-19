///|
test "annotations carry parsed arguments and original source offsets" {
  let source = "#replace(\"answer\", helper(1i32 + 2i32))\nfn sample() -> I32 {\n 0i32\n}\n"
  let file = match scan({ path: "args.dew", source: bytes(source), }, 0, 0) {
    Ok(file) => file
    Err(error) => {
      fail(error)
      abort("unreachable")
    }
  }
  assert_eq(file.annotations.length(), 1)
  let annotation = file.annotations[0]
  assert_eq(annotation.arguments.length(), 2)
  assert_eq(annotation.arguments_source, "\"answer\", helper(1i32 + 2i32)")
  let m = builder_machine()
  let values = m.sequence_values(m.annotation_nodes(annotation))
  assert_eq(string(field(values[0], "kind")), "String")
  assert_eq(string(field(values[0], "label")), "answer")
  assert_eq(raw_bits(field(values[0], "offset")), 9UL)
  assert_eq(string(field(values[1], "kind")), "call")
}

///|
test "annotation scanner accepts empty lists and rejects invalid bracket nesting" {
  for prefix in ["#replace", "#replace()"] {
    assert_true(
      scan(
        {
          path: "args.dew",
          source: bytes(prefix + "\nfn sample() -> I32 {\n 0i32\n}\n"),
        },
        0,
        0,
      )
      is Ok(_),
    )
  }
  for
    prefix in [
      "#replace(1i32]",
      "#replace(1i32)",
      "#replace(\n1i32)",
      "#replace(" + "(".repeat(128) + "1i32" + ")".repeat(128) + ")",
      "#replace(\"" + "x".repeat(65_537) + "\")",
    ] {
    // The valid closed form is followed by stray source to check line ownership.
    let prefix = if prefix == "#replace(1i32)" {
      prefix + " extra"
    } else {
      prefix
    }
    let result = scan(
      {
        path: "args.dew",
        source: bytes(prefix + "\nfn sample() -> I32 {\n 0i32\n}\n"),
      },
      0,
      0,
    )
    assert_true(
      result is Err(_),
      msg=prefix.substring(start=0, end=prefix.length().min(40)).to_string(),
    )
  }
}
