///|
fn semantic_alias_module_source(declaration_count : Int) -> Bytes {
  let output = Buffer(size_hint=declaration_count * 48)
  for index in 0..<declaration_count {
    output.write_string_utf8("type Alias_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("<t> = Result<List<t>>\n")
  }
  output.to_bytes()
}

///|
fn semantic_mixed_module_source(declaration_groups : Int) -> Bytes {
  let output = Buffer(size_hint=declaration_groups * 320)
  for index in 0..<declaration_groups {
    output.write_string_utf8("struct Record_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("<t> {\n  first: t\n  second: List<t>\n}\n")
    output.write_string_utf8("enum Choice_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      "<t> {\n  None\n  Some(t)\n  Named {\n    value: t\n  }\n}\n",
    )
    output.write_string_utf8("fn identity_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("<t>(value: t) -> t {\n  value\n}\n")
  }
  output.to_bytes()
}

///|
fn semantic_function_body_module_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 120)
  for index in 0..<function_count {
    output.write_string_utf8("fn compute_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      "(left: I32, right: I32) -> I32 {\n  let product = left * right\n  product + 1\n}\n",
    )
  }
  output.to_bytes()
}

///|
fn semantic_match_body_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 24 + 48)
  output.write_string_utf8("let result = match state {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" => ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("  _ => 0\n}\n")
  output.to_bytes()
}

///|
fn semantic_nested_alias_source(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth * 5 + 32)
  output.write_string_utf8("type Deep<t> = ")
  for _ in 0..<depth {
    output.write_string_utf8("Box<")
  }
  output.write_string_utf8("t")
  for _ in 0..<depth {
    output.write_byte(b'>')
  }
  output.write_byte(b'\n')
  output.to_bytes()
}

///|
test "bench semantic collect-only aliases n=256" (it : @bench.T) {
  let events = @parser.parse_bytes(semantic_alias_module_source(256)).to_array()
  it.bench(fn() {
    let collected = collect_module(1UL, events.iter())
    it.keep(collected.declarations.length())
  })
}

///|
test "bench semantic parse and collect aliases n=256" (it : @bench.T) {
  let source = semantic_alias_module_source(256)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let collected = collect_tokens(1UL, tokens.iter())
    it.keep(collected.declarations.length())
  })
}

///|
test "bench semantic tokenize parse and collect aliases n=256" (it : @bench.T) {
  let source = semantic_alias_module_source(256)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    it.keep(collected.declarations.length())
  })
}

///|
test "bench semantic collect-only mixed declarations n=192" (it : @bench.T) {
  let events = @parser.parse_bytes(semantic_mixed_module_source(64)).to_array()
  it.bench(fn() {
    let collected = collect_module(1UL, events.iter())
    it.keep(collected.declarations.length())
  })
}

///|
test "bench semantic tokenize parse and collect mixed declarations n=192" (
  it : @bench.T,
) {
  let source = semantic_mixed_module_source(64)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    it.keep(collected.declarations.length())
  })
}

///|
test "bench semantic collect-only function bodies n=256" (it : @bench.T) {
  let events = @parser.parse_bytes(semantic_function_body_module_source(256)).to_array()
  it.bench(fn() {
    let collected = collect_module(1UL, events.iter())
    it.keep(collected.expressions.length())
  })
}

///|
test "bench semantic parse and collect function bodies n=256" (it : @bench.T) {
  let source = semantic_function_body_module_source(256)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let collected = collect_tokens(1UL, tokens.iter())
    it.keep(collected.expressions.length())
  })
}

///|
test "bench semantic tokenize parse and collect function bodies n=256" (
  it : @bench.T,
) {
  let source = semantic_function_body_module_source(256)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    it.keep(collected.expressions.length())
  })
}

///|
test "bench semantic collect-only match body arms=256" (it : @bench.T) {
  let events = @parser.parse_bytes(semantic_match_body_source(256)).to_array()
  it.bench(fn() {
    let collected = collect_module(1UL, events.iter())
    it.keep(collected.pattern_arms.length())
  })
}

///|
test "bench semantic tokenize parse and collect match body arms=256" (
  it : @bench.T,
) {
  let source = semantic_match_body_source(256)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    it.keep(collected.pattern_arms.length())
  })
}

///|
test "bench semantic collect-only nested type depth=256" (it : @bench.T) {
  let events = @parser.parse_bytes(semantic_nested_alias_source(256)).to_array()
  it.bench(fn() {
    let collected = collect_module(1UL, events.iter())
    it.keep(collected.type_syntax.length())
  })
}
