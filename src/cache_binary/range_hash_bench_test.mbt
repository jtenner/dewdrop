///|
fn range_hash_benchmark_input() -> Bytes {
  let input = Buffer(size_hint=1024 * 1024 + 16)
  for index in 0..<(1024 * 1024 + 16) {
    input.write_byte((index % 251).to_byte())
  }
  input.to_bytes()
}

///|
test "bench footer hash copy control 1 MiB" (it : @bench.T) {
  let bytes = range_hash_benchmark_input()
  it.bench(fn() {
    let copied = bytes[0:1024 * 1024].to_owned()
    let digest = @cache_binary.blake3(copied)
    it.keep(digest[0])
  })
}

///|
test "bench footer hash checked range 1 MiB" (it : @bench.T) {
  let bytes = range_hash_benchmark_input()
  it.bench(fn() {
    let digest = @cache_binary.blake3_range(bytes, 0, 1024 * 1024).unwrap()
    it.keep(digest[0])
  })
}
