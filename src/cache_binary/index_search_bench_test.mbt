///|
test "bench indexed cache changed content entries=512" (it : @bench.T) {
  let source = ArtifactPack::empty()
  let owners : Array[String] = []
  let digest = blake3(b"old content")
  let changed = blake3(b"changed content")
  let context = blake3(b"context")
  for i in 0..<512 {
    let owner = "module-\{i}"
    owners.push(owner)
    source
    .upsert(
      ArtifactPackEntry::new(1U, 1U, 0U, 0U, owner, digest, context, b"x"),
    )
    .unwrap()
  }
  let pack = open_artifact_pack(source.encode().unwrap()).unwrap()
  it.bench(fn() {
    for owner in owners {
      let found = pack.lookup_checked(1U, 1U, owner, changed, context).unwrap()
      if found is Some(_) {
        abort("changed content must miss")
      }
      it.keep(found)
    }
  })
}

///|
test "bench indexed cache changed content entries=4096" (it : @bench.T) {
  let source = ArtifactPack::empty()
  let owners : Array[String] = []
  let digest = blake3(b"old content")
  let changed = blake3(b"changed content")
  let context = blake3(b"context")
  for i in 0..<4096 {
    let owner = "module-\{i}"
    owners.push(owner)
    source
    .upsert(
      ArtifactPackEntry::new(1U, 1U, 0U, 0U, owner, digest, context, b"x"),
    )
    .unwrap()
  }
  let pack = open_artifact_pack(source.encode().unwrap()).unwrap()
  it.bench(fn() {
    for owner in owners {
      let found = pack.lookup_checked(1U, 1U, owner, changed, context).unwrap()
      if found is Some(_) {
        abort("changed content must miss")
      }
      it.keep(found)
    }
  })
}
