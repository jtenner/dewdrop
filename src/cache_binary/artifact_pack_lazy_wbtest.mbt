///|
test "lazy artifact pack opens indexes and decodes only the selected entry" {
  let source = ArtifactPack::empty()
  source
  .upsert(artifact_pack_test_entry("module:a.dew", b"a", b"context", b"alpha"))
  .unwrap()
  source
  .upsert(artifact_pack_test_entry("module:b.dew", b"b", b"context", b"beta"))
  .unwrap()
  let encoded = source.encode().unwrap()
  let indexed_pack = open_artifact_pack(encoded).unwrap()
  assert_eq(indexed_pack.entries.length(), 0)
  assert_eq(indexed_pack.indexed_entries.length(), 2)
  assert_eq(
    indexed_pack
    .lookup_checked(
      test_parse_event_pack_kind,
      1U,
      "module:b.dew",
      blake3(b"b"),
      blake3(b"context"),
    )
    .unwrap(),
    Some(b"beta"),
  )
  assert_eq(indexed_pack.entries.length(), 1)
}

///|
test "lazy artifact pack keeps old entries when one owner is replaced" {
  let source = ArtifactPack::empty()
  source
  .upsert(artifact_pack_test_entry("module:a.dew", b"a", b"context", b"alpha"))
  .unwrap()
  source
  .upsert(artifact_pack_test_entry("module:b.dew", b"b", b"context", b"beta"))
  .unwrap()
  let indexed_pack = open_artifact_pack(source.encode().unwrap()).unwrap()
  indexed_pack
  .upsert(
    artifact_pack_test_entry("module:a.dew", b"a2", b"context", b"alpha2"),
  )
  .unwrap()
  let decoded = decode_artifact_pack(indexed_pack.encode().unwrap()).unwrap()
  assert_eq(decoded.entries.length(), 2)
  assert_eq(
    decoded.lookup(
      test_parse_event_pack_kind,
      1U,
      "module:a.dew",
      blake3(b"a2"),
      blake3(b"context"),
    ),
    Some(b"alpha2"),
  )
  assert_eq(
    decoded.lookup(
      test_parse_event_pack_kind,
      1U,
      "module:b.dew",
      blake3(b"b"),
      blake3(b"context"),
    ),
    Some(b"beta"),
  )
}

///|
test "lazy artifact pack reports corruption in a selected entry" {
  let source = ArtifactPack::empty()
  source
  .upsert(artifact_pack_test_entry("module:a.dew", b"a", b"context", b"alpha"))
  .unwrap()
  let encoded = source.encode().unwrap()
  let opened = open_artifact_pack(encoded).unwrap()
  let indexed = opened.indexed_entries[0]
  let mutation = indexed.offset + indexed.size - 1
  let corrupt = Buffer(size_hint=encoded.length())
  for index, byte in encoded {
    corrupt.write_byte(if index == mutation { byte ^ 1 } else { byte })
  }
  let indexed_pack = open_artifact_pack(corrupt.to_bytes()).unwrap()
  assert_true(
    indexed_pack.lookup_checked(
      test_parse_event_pack_kind,
      1U,
      "module:a.dew",
      blake3(b"a"),
      blake3(b"context"),
    )
    is Err(_),
  )
}

///|
test "checked artifact lookup rejects short digests without trapping" {
  let pack = ArtifactPack::empty()
  let short_digest : FixedArray[Byte] = FixedArray::make(3, (0 : Byte))
  match
    pack.lookup_checked(
      test_parse_event_pack_kind,
      1U,
      "module:a.dew",
      short_digest,
      blake3(b"context"),
    ) {
    Err(error) => assert_true(error.contains("content digest"))
    Ok(_) => fail("short content digest must be rejected")
  }
  match
    pack.lookup_checked(
      test_parse_event_pack_kind,
      1U,
      "module:a.dew",
      blake3(b"content"),
      short_digest,
    ) {
    Err(error) => assert_true(error.contains("context digest"))
    Ok(_) => fail("short context digest must be rejected")
  }
}
