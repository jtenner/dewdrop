///|
let test_parse_event_pack_kind = 0x54564550U

///|
fn artifact_pack_test_entry(
  owner : String,
  source : Bytes,
  context : Bytes,
  payload : Bytes,
) -> ArtifactPackEntry {
  {
    kind: test_parse_event_pack_kind,
    schema_version: 1U,
    flags: 0U,
    owner_kind: 0U,
    owner,
    content_digest: blake3(source),
    context_digest: blake3(context),
    payload,
  }
}

///|
test "artifact pack uses one aligned canonical file" {
  let pack = ArtifactPack::empty()
  pack
  .upsert(
    artifact_pack_test_entry("module:a.dew", b"a", b"parser-v1", b"payload-a"),
  )
  .unwrap()
  pack
  .upsert(
    artifact_pack_test_entry("module:b.dew", b"b", b"parser-v1", b"payload-b"),
  )
  .unwrap()
  let encoded = pack.encode().unwrap()
  assert_eq(
    artifact_pack_copy_bytes(encoded, 0, 16),
    b"dewartv1\x00\x00\x00\x00\x00\x00\x00\x00",
  )
  assert_eq(encoded.length() % 16, 0)
  let decoded = decode_artifact_pack(encoded).unwrap()
  assert_eq(decoded.encode().unwrap(), encoded)
  assert_eq(
    decoded.lookup(
      test_parse_event_pack_kind,
      1U,
      "module:b.dew",
      blake3(b"b"),
      blake3(b"parser-v1"),
    ),
    Some(b"payload-b"),
  )
}

///|
test "artifact pack replaces one owner without retaining stale versions" {
  let pack = ArtifactPack::empty()
  pack
  .upsert(
    artifact_pack_test_entry("module:a.dew", b"old", b"parser-v1", b"old"),
  )
  .unwrap()
  pack
  .upsert(
    artifact_pack_test_entry("module:a.dew", b"new", b"parser-v1", b"new"),
  )
  .unwrap()
  assert_eq(pack.entries.length(), 1)
  let decoded = decode_artifact_pack(pack.encode().unwrap()).unwrap()
  assert_eq(
    decoded.lookup(
      test_parse_event_pack_kind,
      1U,
      "module:a.dew",
      blake3(b"old"),
      blake3(b"parser-v1"),
    ),
    None,
  )
  assert_eq(
    decoded.lookup(
      test_parse_event_pack_kind,
      1U,
      "module:a.dew",
      blake3(b"new"),
      blake3(b"parser-v1"),
    ),
    Some(b"new"),
  )
}

///|
test "artifact pack verifies full digests after the 32-bit lookup lanes" {
  let first = blake3(b"first")
  let colliding = blake3(b"second")
  for index in 0..<4 {
    colliding[index] = first[index]
  }
  let pack = ArtifactPack::empty()
  pack
  .upsert({
    kind: test_parse_event_pack_kind,
    schema_version: 1U,
    flags: 0U,
    owner_kind: 0U,
    owner: "module:a.dew",
    content_digest: first,
    context_digest: blake3(b"context"),
    payload: b"payload",
  })
  .unwrap()
  assert_eq(
    pack.lookup(
      test_parse_event_pack_kind,
      1U,
      "module:a.dew",
      colliding,
      blake3(b"context"),
    ),
    None,
  )
}

///|
test "artifact pack rejects truncation and corruption" {
  let pack = ArtifactPack::empty()
  pack
  .upsert(
    artifact_pack_test_entry("module:a.dew", b"a", b"parser-v1", b"payload"),
  )
  .unwrap()
  let encoded = pack.encode().unwrap()
  let truncated = artifact_pack_copy_bytes(encoded, 0, encoded.length() - 1)
  assert_true(decode_artifact_pack(truncated) is Err(_))
  let corrupt = Buffer(size_hint=encoded.length())
  for index, byte in encoded {
    corrupt.write_byte(if index == 200 { byte ^ 1 } else { byte })
  }
  assert_true(decode_artifact_pack(corrupt.to_bytes()) is Err(_))
}
