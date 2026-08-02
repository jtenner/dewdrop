///|
fn body_name_function_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 132 + 32)
  output.write_string_utf8("let global = 1\n")
  for index in 0..<function_count {
    output.write_string_utf8("fn resolve_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      "(value: I32) -> I32 {\n  let first = value + global\n  let mut value = first\n  value\n}\n",
    )
  }
  output.to_bytes()
}

///|
fn body_name_match_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 52 + 160)
  output.write_string_utf8(
    "enum State {\n  Value(I32)\n}\nfn select(state: State) -> I32 {\n  match state {\n",
  )
  for index in 0..<arm_count {
    output.write_string_utf8("    Value(value) if value == ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" => value\n")
  }
  output.write_string_utf8("    _ => 0\n  }\n}\n")
  output.to_bytes()
}

///|
fn body_name_wide_pattern_source(field_count : Int) -> Bytes {
  let output = Buffer(size_hint=field_count * 96 + 256)
  output.write_string_utf8("enum Record {\n  A {\n")
  for index in 0..<field_count {
    output.write_string_utf8("    field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": I32\n")
  }
  output.write_string_utf8("  }\n  B {\n")
  for index in 0..<field_count {
    output.write_string_utf8("    field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": I32\n")
  }
  output.write_string_utf8(
    "  }\n}\nfn read(record: Record) -> I32 {\n  match record {\n    A {\n",
  )
  for index in 0..<field_count {
    output.write_string_utf8("      field_")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("    }, B {\n")
  for index in 0..<field_count {
    output.write_string_utf8("      field_")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("    } => field_")
  output.write_string_utf8((field_count - 1).to_string())
  output.write_string_utf8("\n  }\n}\n")
  output.to_bytes()
}

///|
fn body_name_local_source(local_count : Int) -> Bytes {
  let output = Buffer(size_hint=local_count * 40 + 96)
  output.write_string_utf8("fn resolve(initial: I32) -> I32 {\n")
  for index in 0..<local_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = ")
    if index == 0 {
      output.write_string_utf8("initial")
    } else {
      output.write_string_utf8("value_")
      output.write_string_utf8((index - 1).to_string())
    }
    output.write_byte(b'\n')
  }
  output.write_string_utf8("  value_")
  output.write_string_utf8((local_count - 1).to_string())
  output.write_string_utf8("\n}\n")
  output.to_bytes()
}

///|
test "bench names resolve-only function bodies n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, body_name_function_source(256))
  it.bench(fn() {
    let names = resolve_module_names(collected)
    it.keep(names.locals.length())
  })
}

///|
test "bench names collect-events and resolve bodies n=256" (it : @bench.T) {
  let events = @parser.parse_bytes(body_name_function_source(256)).to_array()
  it.bench(fn() {
    let names = resolve_module_names(collect_module(1UL, events.iter()))
    it.keep(names.locals.length())
  })
}

///|
test "bench names full body pipeline n=256" (it : @bench.T) {
  let source = body_name_function_source(256)
  it.bench(fn() {
    let names = resolve_module_names(collect_bytes(1UL, source))
    it.keep(names.locals.length())
  })
}

///|
test "bench names resolve match arms n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, body_name_match_source(256))
  it.bench(fn() {
    let names = resolve_module_names(collected)
    it.keep(names.locals.length())
  })
}

///|
test "bench names resolve sequential locals n=512" (it : @bench.T) {
  let collected = collect_bytes(1UL, body_name_local_source(512))
  it.bench(fn() {
    let names = resolve_module_names(collected)
    it.keep(names.locals.length())
  })
}

///|
test "bench names resolve wide alternatives fields=128" (it : @bench.T) {
  let collected = collect_bytes(1UL, body_name_wide_pattern_source(128))
  it.bench(fn() {
    let names = resolve_module_names(collected)
    it.keep(names.locals.length())
  })
}
