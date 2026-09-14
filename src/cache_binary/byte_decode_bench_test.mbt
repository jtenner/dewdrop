///|
test "bench raw bytes decode bytes=4096" (it : @bench.T) {
  let buffer = Buffer()
  for _ in 0..<4098 {
    buffer.write_byte(b'a')
  }
  let bytes = buffer.to_bytes()
  it.bench(fn() {
    let reader = Reader::new(bytes)
    reader.skip(1, "prefix")
    it.keep(reader.read_raw_bytes(4096, 4096, "value"))
  })
}

///|
test "bench UTF-8 string decode bytes=4096" (it : @bench.T) {
  let buffer = Buffer()
  for _ in 0..<4098 {
    buffer.write_byte(b'a')
  }
  let bytes = buffer.to_bytes()
  let writer = Writer::new()
  writer.write_bytes(bytes[1:4097].to_owned())
  let encoded = writer.to_bytes()
  it.bench(fn() { it.keep(Reader::new(encoded).read_string(4096, "value")) })
}

///|
test "bench raw bytes decode bytes=1048576" (it : @bench.T) {
  let buffer = Buffer()
  for _ in 0..<1048578 {
    buffer.write_byte(b'a')
  }
  let bytes = buffer.to_bytes()
  it.bench(fn() {
    let reader = Reader::new(bytes)
    reader.skip(1, "prefix")
    it.keep(reader.read_raw_bytes(1048576, 1048576, "value"))
  })
}

///|
test "bench UTF-8 string decode bytes=1048576" (it : @bench.T) {
  let buffer = Buffer()
  for _ in 0..<1048578 {
    buffer.write_byte(b'a')
  }
  let bytes = buffer.to_bytes()
  let writer = Writer::new()
  writer.write_bytes(bytes[1:1048577].to_owned())
  let encoded = writer.to_bytes()
  it.bench(fn() { it.keep(Reader::new(encoded).read_string(1048576, "value")) })
}
