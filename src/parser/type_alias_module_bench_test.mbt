///|
fn type_alias_module_source(alias_count : Int) -> Bytes {
  let output = Buffer(size_hint=alias_count * 48)
  for index in 0..<alias_count {
    output.write_string_utf8("type Alias_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("<t> = Result<List<t>>\n")
  }
  output.to_bytes()
}

///|
fn recovering_type_alias_module_source(alias_count : Int) -> Bytes {
  let output = Buffer(size_hint=alias_count * 64)
  for index in 0..<alias_count {
    output.write_string_utf8("malformed line\n")
    output.write_string_utf8("type Alias_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = I32\n")
  }
  output.to_bytes()
}

///|
fn recovering_impl_module_source(declaration_count : Int) -> Bytes {
  let output = Buffer(size_hint=declaration_count * 160)
  for index in 0..<declaration_count {
    output.write_string_utf8("impl Value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      " {\n  fn broken(self) -> Unit {\n    let value =\n  }\n  fn nested(self) -> Unit {}\n}\ntype Alias_",
    )
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = I32\n")
  }
  output.to_bytes()
}

///|
fn recovering_nested_function_module_source(declaration_count : Int) -> Bytes {
  let output = Buffer(size_hint=declaration_count * 160)
  for index in 0..<declaration_count {
    output.write_string_utf8("fn Broken_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      "() -> Unit {\n  if ready {\n    match state {\n      _ => malformed +\n    }\n  }\n  let local = 1\n}\ntype Alias_",
    )
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = I32\n")
  }
  output.to_bytes()
}

///|
fn count_parse_events(events : Iter[ParseEvent]) -> Int {
  let mut count = 0
  while events.next() is Some(_) {
    count += 1
  }
  count
}

///|
test "bench type alias parse-only recursive target" (it : @bench.T) {
  let source = b"pub type Rows<t> = Result<List<Map<String, t>>>\n"
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench type alias tokenize-only recursive target" (it : @bench.T) {
  let source = b"pub type Rows<t> = Result<List<Map<String, t>>>\n"
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench type alias tokenize and parse recursive target" (it : @bench.T) {
  let source = b"pub type Rows<t> = Result<List<Map<String, t>>>\n"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench module stream parse-only aliases n=256" (it : @bench.T) {
  let source = type_alias_module_source(256)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let count = count_parse_events(parse(tokens.iter()))
    it.keep(count)
  })
}

///|
test "bench module stream tokenize and parse aliases n=256" (it : @bench.T) {
  let source = type_alias_module_source(256)
  it.bench(fn() {
    let count = count_parse_events(parse_bytes(source))
    it.keep(count)
  })
}

///|
test "bench module stream recovery n=64" (it : @bench.T) {
  let source = recovering_type_alias_module_source(64)
  it.bench(fn() {
    let count = count_parse_events(parse_bytes(source))
    it.keep(count)
  })
}

///|
test "bench module structural impl recovery parse-only n=64" (it : @bench.T) {
  let source = recovering_impl_module_source(64)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let count = count_parse_events(parse(tokens.iter()))
    it.keep(count)
  })
}

///|
test "bench module structural impl recovery end-to-end n=64" (it : @bench.T) {
  let source = recovering_impl_module_source(64)
  it.bench(fn() {
    let count = count_parse_events(parse_bytes(source))
    it.keep(count)
  })
}

///|
test "bench module nested function recovery parse-only n=64" (it : @bench.T) {
  let source = recovering_nested_function_module_source(64)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let count = count_parse_events(parse(tokens.iter()))
    it.keep(count)
  })
}

///|
test "bench module nested function recovery end-to-end n=64" (it : @bench.T) {
  let source = recovering_nested_function_module_source(64)
  it.bench(fn() {
    let count = count_parse_events(parse_bytes(source))
    it.keep(count)
  })
}

///|
test "bench module unclosed declaration recovery to eof" (it : @bench.T) {
  let source = b"fn broken() -> Unit {\n  if ready {\n    malformed +\ntype Uncertain = I32\n"
  it.bench(fn() {
    let count = count_parse_events(parse_bytes(source))
    it.keep(count)
  })
}

///|
test "bench empty module stream" (it : @bench.T) {
  let source = b"\n\n"
  it.bench(fn() {
    let count = count_parse_events(parse_bytes(source))
    it.keep(count)
  })
}
