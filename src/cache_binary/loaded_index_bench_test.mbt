///|
fn loaded_index_fixture() -> ArtifactPack {
  let pack = ArtifactPack::empty()
  let digest = blake3(b"x")
  for i in 0..<4096 {
    pack.upsert(ArtifactPackEntry::new(1U, 1U, 0U, 0U, "owner-\{i}", digest, digest, b"x")).unwrap()
  }
  pack
}

///|
test "bench loaded pack upsert count=4096" (it : @bench.T) {
  it.bench(fn() { it.keep(loaded_index_fixture()) }, count=3U)
}

///|
test "bench loaded pack lookup count=4096" (it : @bench.T) {
  let pack = loaded_index_fixture()
  let owners = pack.entries.map(e => e.owner)
  let digest = blake3(b"x")
  it.bench(fn() {
    for owner in owners {
      it.keep(pack.lookup_checked(1U, 1U, owner, digest, digest).unwrap().unwrap())
    }
  }, count=3U)
}

///|
test "bench lazy pack materialize count=4096" (it : @bench.T) {
  let pack = open_artifact_pack(loaded_index_fixture().encode().unwrap()).unwrap()
  it.bench(fn() { it.keep(pack.encode().unwrap()) }, count=3U)
}
