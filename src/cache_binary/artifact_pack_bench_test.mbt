///|
let artifact_pack_benchmark_kind = 0x54564550U

///|
fn artifact_pack_benchmark_bytes() -> Bytes {
  let pack = ArtifactPack::empty()
  for index in 0..<512 {
    let payload = Buffer(size_hint=4096)
    for byte_index in 0..<4096 {
      payload.write_byte(((index + byte_index) % 251).to_byte())
    }
    pack
    .upsert(
      ArtifactPackEntry::new(
        artifact_pack_benchmark_kind,
        1U,
        0U,
        0U,
        "module:file-\{index}.dew",
        blake3(@utf8.encode("source-\{index}")),
        blake3(b"context"),
        payload.to_bytes(),
      ),
    )
    .unwrap()
  }
  pack.encode().unwrap()
}

///|
test "bench BLAKE3 1 MiB" (it : @bench.T) {
  let input = Buffer(size_hint=1024 * 1024)
  for index in 0..<(1024 * 1024) {
    input.write_byte((index % 251).to_byte())
  }
  let bytes = input.to_bytes()
  it.bench(fn() {
    let digest = blake3(bytes)
    it.keep(digest[0])
  })
}

///|
test "bench indexed artifact pack open and exact lookup 512 entries" (
  it : @bench.T,
) {
  let encoded = artifact_pack_benchmark_bytes()
  let content = blake3(@utf8.encode("source-511"))
  let context = blake3(b"context")
  it.bench(fn() {
    let pack = open_artifact_pack(encoded).unwrap()
    let payload = pack
      .lookup_checked(
        artifact_pack_benchmark_kind, 1U, "module:file-511.dew", content, context,
      )
      .unwrap()
      .unwrap()
    it.keep(payload.length())
  })
}

///|
test "bench strict artifact pack validation 512 entries" (it : @bench.T) {
  let encoded = artifact_pack_benchmark_bytes()
  it.bench(fn() {
    let pack = decode_artifact_pack(encoded).unwrap()
    it.keep(pack.entries.length())
  })
}
