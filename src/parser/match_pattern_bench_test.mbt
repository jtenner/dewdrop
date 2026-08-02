///|
fn qualified_pattern_benchmark_source(part_count : Int) -> Bytes {
  let output = Buffer(size_hint=part_count * 12 + 4)
  output.write_string_utf8("Root")
  for index in 0..<part_count {
    output.write_string_utf8("::Part_")
    output.write_string_utf8(index.to_string())
  }
  output.to_bytes()
}

///|
fn unit_match_benchmark_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 28 + 32)
  output.write_string_utf8("match value {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  Variant_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" => ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_byte(b'}')
  output.to_bytes()
}

///|
fn tuple_match_benchmark_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 48 + 32)
  output.write_string_utf8("match value {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  Option::Some(value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(") => value_")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_byte(b'}')
  output.to_bytes()
}

///|
fn struct_match_benchmark_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 72 + 32)
  output.write_string_utf8("match value {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  Message::Data {\n    value: item_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n  } => item_")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_byte(b'}')
  output.to_bytes()
}

///|
fn guarded_alternative_match_benchmark_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 96 + 32)
  output.write_string_utf8("match value {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  Left_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(item), Right_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(item) if item > 0 => item\n")
  }
  output.write_byte(b'}')
  output.to_bytes()
}

///|
fn rest_match_benchmark_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 80 + 32)
  output.write_string_utf8("match value {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  Message::Data {\n    value: item_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n    ...\n  } => item_")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_byte(b'}')
  output.to_bytes()
}

///|
test "bench pattern parse-only qualified chain n=128" (it : @bench.T) {
  let source = qualified_pattern_benchmark_source(128)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_pattern()
    it.keep(result)
  })
}

///|
test "bench pattern tokenize and parse qualified chain n=128" (it : @bench.T) {
  let source = qualified_pattern_benchmark_source(128)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_pattern()
    it.keep(result)
  })
}

///|
test "bench match parse-only unit arms n=256" (it : @bench.T) {
  let source = unit_match_benchmark_source(256)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench match tokenize-only unit arms n=256" (it : @bench.T) {
  let source = unit_match_benchmark_source(256)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench match tokenize and parse unit arms n=256" (it : @bench.T) {
  let source = unit_match_benchmark_source(256)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench match parse-only tuple arms n=128" (it : @bench.T) {
  let source = tuple_match_benchmark_source(128)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench match tokenize and parse tuple arms n=128" (it : @bench.T) {
  let source = tuple_match_benchmark_source(128)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench match parse-only struct arms n=64" (it : @bench.T) {
  let source = struct_match_benchmark_source(64)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench match tokenize and parse struct arms n=64" (it : @bench.T) {
  let source = struct_match_benchmark_source(64)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench match parse-only guarded alternatives n=128" (it : @bench.T) {
  let source = guarded_alternative_match_benchmark_source(128)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench match tokenize and parse guarded alternatives n=128" (it : @bench.T) {
  let source = guarded_alternative_match_benchmark_source(128)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench match parse-only struct rest arms n=64" (it : @bench.T) {
  let source = rest_match_benchmark_source(64)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench match tokenize and parse struct rest arms n=64" (it : @bench.T) {
  let source = rest_match_benchmark_source(64)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench match tokenize and parse short mixed match" (it : @bench.T) {
  let source = b"match option {\n  Option::None => fallback\n  Option::Some(value) => value\n}"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}
