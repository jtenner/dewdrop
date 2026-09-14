///|
test "index lower bound agrees with linear search across equal lanes and sections" {
  let keys = [
    (1U, 0U, 2U),
    (1U, 4U, 0U),
    (1U, 4U, 3U),
    (1U, 4U, 3U),
    (3U, 0U, 0U),
    (3U, 4U, 3U),
  ]
  let entries = keys.map(fn(key) {
    { kind: key.0, owner_lane: key.1, content_lane: key.2, offset: 0, size: 0, }
  })
  for kind in 0U..<5U {
    for owner in 0U..<6U {
      for content in 0U..<5U {
        let mut expected = 0
        for key in keys {
          if key.0 < kind ||
            (key.0 == kind && key.1 < owner) ||
            (key.0 == kind && key.1 == owner && key.2 < content) {
            expected += 1
          }
        }
        assert_eq(
          artifact_pack_index_lower_bound(entries, kind, owner, content),
          expected,
        )
      }
    }
  }
  assert_eq(artifact_pack_index_lower_bound([], 0U, 0U, 0U), 0)
}

///|
test "indexed lookup finds all sections and rejects changed content" {
  let source = ArtifactPack::empty()
  let entries : Array[ArtifactPackEntry] = []
  for index in 0..<32 {
    let entry = ArtifactPackEntry::new(
      (index % 3).to_uint(),
      1U,
      0U,
      0U,
      "owner-\{index}",
      blake3(b"content"),
      blake3(b"context"),
      b"payload",
    )
    source.upsert(entry).unwrap()
    entries.push(entry)
  }
  let encoded = source.encode().unwrap()
  for entry in entries {
    let pack = open_artifact_pack(encoded).unwrap()
    assert_eq(
      pack
      .lookup_checked(
        entry.kind,
        1U,
        entry.owner,
        blake3(b"changed"),
        entry.context_digest,
      )
      .unwrap(),
      None,
    )
    assert_eq(pack.entries.length(), 0)
    assert_eq(
      pack
      .lookup_checked(
        entry.kind,
        1U,
        entry.owner,
        entry.content_digest,
        entry.context_digest,
      )
      .unwrap(),
      Some(b"payload"),
    )
  }
}
