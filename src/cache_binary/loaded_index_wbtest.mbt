///|
test "loaded owner index keeps old versions and first-owner replacement" {
  let source = ArtifactPack::empty()
  let old = artifact_pack_test_entry(
    "module:a.dew", b"old", b"context", b"old payload",
  )
  source.upsert(old).unwrap()
  let pack = open_artifact_pack(source.encode().unwrap()).unwrap()
  let fresh = artifact_pack_test_entry(
    "module:a.dew", b"fresh", b"context", b"fresh payload",
  )
  pack.upsert(fresh).unwrap()
  assert_eq(
    pack.lookup(
      old.kind,
      old.schema_version,
      old.owner,
      old.content_digest,
      old.context_digest,
    ),
    Some(old.payload),
  )
  assert_eq(
    pack.lookup(
      fresh.kind,
      fresh.schema_version,
      fresh.owner,
      fresh.content_digest,
      fresh.context_digest,
    ),
    Some(fresh.payload),
  )
  assert_eq(pack.entries.length(), 2)
  pack.upsert(fresh).unwrap()
  assert_eq(pack.entries.length(), 2)
  assert_eq(
    pack.encode(),
    Err("artifact pack contains duplicate section owners"),
  )
  let decoded = decode_artifact_pack(source.encode().unwrap()).unwrap()
  decoded.upsert(fresh).unwrap()
  assert_eq(decoded.entries.length(), 1)
  assert_eq(
    decoded.lookup(
      fresh.kind,
      fresh.schema_version,
      fresh.owner,
      fresh.content_digest,
      fresh.context_digest,
    ),
    Some(fresh.payload),
  )
}

///|
test "loaded owner index separates section and verifies full identity" {
  let pack = ArtifactPack::empty()
  let a = artifact_pack_test_entry("owner", b"a", b"context", b"a")
  let b = { ..a, kind: a.kind + 1U, payload: b"b", }
  pack.upsert(a).unwrap()
  pack.upsert(b).unwrap()
  for
    candidate in [
      pack,
      decode_artifact_pack(pack.encode().unwrap()).unwrap(),
      open_artifact_pack(pack.encode().unwrap()).unwrap(),
    ] {
    for entry in [a, b] {
      assert_eq(
        candidate.lookup(
          entry.kind,
          entry.schema_version,
          entry.owner,
          entry.content_digest,
          entry.context_digest,
        ),
        Some(entry.payload),
      )
      assert_eq(
        candidate.lookup(
          entry.kind,
          entry.schema_version + 1U,
          entry.owner,
          entry.content_digest,
          entry.context_digest,
        ),
        None,
      )
      assert_eq(
        candidate.lookup(
          entry.kind,
          entry.schema_version,
          entry.owner,
          blake3(b"miss"),
          entry.context_digest,
        ),
        None,
      )
      assert_eq(
        candidate.lookup(
          entry.kind,
          entry.schema_version,
          entry.owner,
          entry.content_digest,
          blake3(b"miss"),
        ),
        None,
      )
    }
  }
}

///|
test "materialization still validates saved entries hidden by replacements" {
  let source = ArtifactPack::empty()
  let entry = artifact_pack_test_entry("owner", b"a", b"context", b"payload")
  source.upsert(entry).unwrap()
  let encoded = source.encode().unwrap()
  let opened = open_artifact_pack(encoded).unwrap()
  let indexed = opened.indexed_entries[0]
  let mutation = indexed.offset + indexed.size - 1
  let buffer = Buffer(size_hint=encoded.length())
  for index, byte in encoded {
    buffer.write_byte(if index == mutation { byte ^ 1 } else { byte })
  }
  let bytes = buffer.to_bytes()
  // Supply a valid outer checksum so this checks the saved entry itself.
  let corrupt = {
    ..opened,
    encoded: Some(bytes),
    footer_digest: blake3(bytes[0:opened.footer_covered_bytes].to_owned()),
  }
  corrupt.verify_footer().unwrap()
  corrupt.upsert(entry).unwrap()
  assert_true(corrupt.encode() is Err(_))
}
