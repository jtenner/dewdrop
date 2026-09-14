///|
test "bench materialized pack lookup entries=128" (it : @bench.T) {
  let pack = ArtifactPack::empty()
  let digest = blake3(b"content")
  let owners : Array[String] = []
  for i in 0..<128 {
    let owner = "module:file-\{i}.dew"
    owners.push(owner)
    pack
    .upsert(ArtifactPackEntry::new(1U, 1U, 0U, 0U, owner, digest, digest, b"x"))
    .unwrap()
  }
  it.bench(fn() {
    for owner in owners {
      it.keep(
        pack.lookup_checked(1U, 1U, owner, digest, digest).unwrap().unwrap(),
      )
    }
  })
}

///|
test "bench materialized pack encode entries=128" (it : @bench.T) {
  let pack = ArtifactPack::empty()
  let digest = blake3(b"content")
  let owners : Array[String] = []
  for i in 0..<128 {
    let owner = "module:file-\{i}.dew"
    owners.push(owner)
    pack
    .upsert(ArtifactPackEntry::new(1U, 1U, 0U, 0U, owner, digest, digest, b"x"))
    .unwrap()
  }
  it.bench(fn() { it.keep(pack.encode().unwrap()) })
}

///|
test "bench materialized pack lookup entries=512" (it : @bench.T) {
  let pack = ArtifactPack::empty()
  let digest = blake3(b"content")
  let owners : Array[String] = []
  for i in 0..<512 {
    let owner = "module:file-\{i}.dew"
    owners.push(owner)
    pack
    .upsert(ArtifactPackEntry::new(1U, 1U, 0U, 0U, owner, digest, digest, b"x"))
    .unwrap()
  }
  it.bench(fn() {
    for owner in owners {
      it.keep(
        pack.lookup_checked(1U, 1U, owner, digest, digest).unwrap().unwrap(),
      )
    }
  })
}

///|
test "bench materialized pack encode entries=512" (it : @bench.T) {
  let pack = ArtifactPack::empty()
  let digest = blake3(b"content")
  let owners : Array[String] = []
  for i in 0..<512 {
    let owner = "module:file-\{i}.dew"
    owners.push(owner)
    pack
    .upsert(ArtifactPackEntry::new(1U, 1U, 0U, 0U, owner, digest, digest, b"x"))
    .unwrap()
  }
  it.bench(fn() { it.keep(pack.encode().unwrap()) })
}
