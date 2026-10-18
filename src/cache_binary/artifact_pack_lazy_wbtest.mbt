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

///|
test "range footer verification rejects covered-byte corruption" {
  let source = ArtifactPack::empty()
  source
  .upsert(artifact_pack_test_entry("owner", b"a", b"context", b"payload"))
  .unwrap()
  let encoded = source.encode().unwrap()
  let opened = open_artifact_pack(encoded).unwrap()
  opened.verify_footer().unwrap()
  let mutation = opened.indexed_entries[0].offset
  let buffer = Buffer(size_hint=encoded.length())
  for index, byte in encoded {
    buffer.write_byte(if index == mutation { byte ^ 1 } else { byte })
  }
  let corrupt = { ..opened, encoded: Some(buffer.to_bytes()), }
  assert_eq(corrupt.verify_footer(), Err("artifact pack FOOT digest mismatch"))
  for covered in [-1, encoded.length() + 1] {
    assert_eq(
      { ..opened, footer_covered_bytes: covered, }.verify_footer(),
      Err("artifact pack footer covered range is invalid"),
    )
  }
}

///|
test "strict and lazy packs reject a corrupt footer digest" {
  let source = ArtifactPack::empty()
  source
  .upsert(artifact_pack_test_entry("owner", b"a", b"context", b"payload"))
  .unwrap()
  let encoded = source.encode().unwrap()
  let opened = open_artifact_pack(encoded).unwrap()
  let wrong_digest = opened.footer_digest.copy()
  wrong_digest[31] = wrong_digest[31] ^ 1
  let writer = Writer::new(size_hint=encoded.length())
  writer.write_raw(encoded[0:opened.footer_covered_bytes].to_owned())
  // Re-encode FOOT so its entry checksum, content lane, and metadata agree.
  // Only the digest of the covered range is wrong. This pack has two sections.
  artifact_pack_write_section(writer, artifact_pack_footer_kind, [
    artifact_pack_footer_entry(
      encoded.length(), opened.footer_covered_bytes, 2, wrong_digest,
    ),
  ]).unwrap()
  let corrupt = writer.to_bytes()
  assert_eq(corrupt.length(), encoded.length())
  assert_eq(
    decode_artifact_pack(corrupt),
    Err("artifact pack FOOT digest mismatch"),
  )
  // Opening checks metadata; the lazy covered-range check is deferred.
  let lazy_pack = open_artifact_pack(corrupt).unwrap()
  assert_eq(
    lazy_pack.verify_footer(),
    Err("artifact pack FOOT digest mismatch"),
  )
}
