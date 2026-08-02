///|
fn repeated_benchmark_expression(term_count : Int, operator : String) -> Bytes {
  let output = Buffer(size_hint=term_count * (operator.length() + 1))
  for index in 0..<term_count {
    if index > 0 {
      output.write_string_utf8(operator)
    }
    output.write_byte(b'1')
  }
  output.to_bytes()
}

///|
fn postfix_benchmark_expression(chain_count : Int) -> Bytes {
  let output = Buffer(size_hint=chain_count * 16 + 4)
  output.write_string_utf8("root")
  for _ in 0..<chain_count {
    output.write_string_utf8(".field[1](2,)")
  }
  output.to_bytes()
}

///|
fn named_benchmark_expression(term_count : Int) -> Bytes {
  let output = Buffer(size_hint=term_count * 8)
  for index in 0..<term_count {
    if index > 0 {
      output.write_string_utf8(" + ")
    }
    output.write_string_utf8("value")
  }
  output.to_bytes()
}

///|
fn qualified_benchmark_expression(property_count : Int) -> Bytes {
  let output = Buffer(size_hint=property_count * 12 + 4)
  output.write_string_utf8("Root")
  for index in 0..<property_count {
    output.write_string_utf8("::item_")
    output.write_string_utf8(index.to_string())
  }
  output.to_bytes()
}

///|
test "bench expression parse-only left associative n=256" (it : @bench.T) {
  let source = repeated_benchmark_expression(256, " + ")
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression parse-only right associative n=256" (it : @bench.T) {
  let source = repeated_benchmark_expression(256, " ** ")
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression parse-only postfix chain n=64" (it : @bench.T) {
  let source = postfix_benchmark_expression(64)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression tokenize and parse left associative n=256" (
  it : @bench.T,
) {
  let source = repeated_benchmark_expression(256, " + ")
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression tokenize-only integer operands n=256" (it : @bench.T) {
  let source = repeated_benchmark_expression(256, " + ")
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench expression parse-only identifier operands n=256" (it : @bench.T) {
  let source = named_benchmark_expression(256)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression tokenize-only identifier operands n=256" (it : @bench.T) {
  let source = named_benchmark_expression(256)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench expression parse-only short mixed expression" (it : @bench.T) {
  let source = b"alpha + beta * gamma"
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression parse-only qualified chain n=128" (it : @bench.T) {
  let source = qualified_benchmark_expression(128)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression tokenize and parse qualified chain n=128" (it : @bench.T) {
  let source = qualified_benchmark_expression(128)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression tokenize and parse short mixed expression" (
  it : @bench.T,
) {
  let source = b"alpha + beta * gamma"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}
