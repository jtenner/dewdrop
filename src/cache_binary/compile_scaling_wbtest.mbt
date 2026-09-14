///|
test "cached pack sort preserves canonical bytes across insertion orders" {
  let forward = ArtifactPack::empty()
  let reverse = ArtifactPack::empty()
  let entries : Array[ArtifactPackEntry] = []
  for i in 0..<64 {
    entries.push(
      ArtifactPackEntry::new(
        (i % 3).to_uint(),
        1U,
        0U,
        0U,
        "owner-\{i}",
        blake3(@utf8.encode("content-\{i}")),
        blake3(b"context"),
        b"payload",
      ),
    )
  }
  for entry in entries {
    forward.upsert(entry).unwrap()
  }
  for i in 0..<entries.length() {
    reverse.upsert(entries[entries.length() - 1 - i]).unwrap()
  }
  let encoded = forward.encode().unwrap()
  assert_eq(reverse.encode().unwrap(), encoded)
  let lazy = open_artifact_pack(encoded).unwrap()
  for entry in entries {
    assert_eq(
      lazy
      .lookup_checked(
        entry.kind,
        entry.schema_version,
        entry.owner,
        entry.content_digest,
        entry.context_digest,
      )
      .unwrap(),
      Some(entry.payload),
    )
    assert_eq(
      lazy
      .lookup_checked(
        entry.kind,
        entry.schema_version,
        entry.owner,
        entry.content_digest,
        blake3(b"wrong context"),
      )
      .unwrap(),
      None,
    )
    assert_eq(
      lazy
      .lookup_checked(
        entry.kind,
        entry.schema_version,
        entry.owner,
        blake3(b"wrong content"),
        entry.context_digest,
      )
      .unwrap(),
      None,
    )
  }
  assert_eq(lazy.encode().unwrap(), encoded)
  assert_eq(decode_artifact_pack(encoded).unwrap().encode().unwrap(), encoded)
}
