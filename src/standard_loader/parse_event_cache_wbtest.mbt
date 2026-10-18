///|
test "parse-event cache envelope verifies checksum and provenance" {
  let key = @crypto.sha256(b"key")
  let source = @crypto.sha256(b"source")
  let payload = b"payload"
  let wrapped = wrap_parse_event_cache_payload(key, source, payload).unwrap()
  assert_eq(wrapped[8], 1)
  assert_eq(wrapped[9], 1)
  assert_eq(wrapped[10], 0)
  assert_eq(wrapped[11], 0)
  assert_eq(wrapped[12], 0)
  assert_true(
    parse_event_cache_file(key).has_suffix(
      "/parse-events/v1-" + @crypto.bytes_to_hex_string(key) + ".dpe",
    ),
  )
  assert_eq(
    unwrap_parse_event_cache_payload(wrapped, key, source).unwrap(),
    payload,
  )
  for cut in 0..<wrapped.length() {
    let truncated = Buffer(size_hint=cut)
    for index in 0..<cut {
      truncated.write_byte(wrapped[index])
    }
    assert_true(
      unwrap_parse_event_cache_payload(truncated.to_bytes(), key, source)
      is Err(_),
    )
  }
  for selected in 0..<wrapped.length() {
    let mutated = Buffer(size_hint=wrapped.length())
    for index in 0..<wrapped.length() {
      mutated.write_byte(
        if index == selected {
          wrapped[index] ^ 0x80
        } else {
          wrapped[index]
        },
      )
    }
    assert_true(
      unwrap_parse_event_cache_payload(mutated.to_bytes(), key, source)
      is Err(_),
    )
  }
  let changed_key = @crypto.sha256(b"other-key")
  match unwrap_parse_event_cache_payload(wrapped, changed_key, source) {
    Err(error) => assert_true(error.contains("provenance mismatch"))
    Ok(_) => fail("expected key provenance mismatch")
  }
  let corrupt = Buffer()
  for index in 0..<(wrapped.length() - 1) {
    corrupt.write_byte(wrapped[index])
  }
  corrupt.write_byte(b'x')
  match unwrap_parse_event_cache_payload(corrupt.to_bytes(), key, source) {
    Err(error) => assert_true(error.contains("checksum mismatch"))
    Ok(_) => fail("expected checksum mismatch")
  }
}

///|
test "parse-event cache skips deep trees across cold warm and edited files" {
  for terms in [2044, 2045, 2046, 2055] {
    let source = Buffer()
    source.write_bytes(b"fn value() -> I32 {\n  1")
    for _ in 1..<terms {
      source.write_bytes(b" + 1")
    }
    source.write_bytes(b"\n}\n")
    let file = @semantic.ManifestFile::new("deep.dew", source.to_bytes())
    let other = @semantic.ManifestFile::new(
      "other.dew", b"fn other() -> I32 {\n  1\n}\n",
    )
    let changed = @semantic.ManifestFile::new(
      "other.dew", b"fn other() -> I32 {\n  2\n}\n",
    )
    let session = program_output_test_session()
    let (cold, status) = prepare_manifest_file_parse_events(
      "depth.test",
      file,
      true,
      pack=Some(session),
    ).unwrap()
    assert_true(status is ParseEventCacheMiss)
    assert_false(
      cold.parse_events
      .unwrap()
      .any(fn(event) { event is @parser.Diagnostic(_) }),
    )
    let (_, other_status) = prepare_manifest_file_parse_events(
      "depth.test",
      other,
      true,
      pack=Some(session),
    ).unwrap()
    assert_true(other_status is ParseEventCacheMiss)
    let (_, other_warm_status) = prepare_manifest_file_parse_events(
      "depth.test",
      other,
      true,
      pack=Some(session),
    ).unwrap()
    assert_true(other_warm_status is ParseEventCacheHit)
    for pass in 0..<2 {
      if pass == 1 {
        let (_, changed_status) = prepare_manifest_file_parse_events(
          "depth.test",
          changed,
          true,
          pack=Some(session),
        ).unwrap()
        assert_true(changed_status is ParseEventCacheMiss)
      }
      let (warm, warm_status) = prepare_manifest_file_parse_events(
        "depth.test",
        file,
        true,
        pack=Some(session),
      ).unwrap()
      assert_eq(warm.parse_events, cold.parse_events)
      assert_true(
        if terms <= 2045 {
          warm_status is ParseEventCacheHit
        } else {
          warm_status is ParseEventCacheMiss
        },
      )
    }
  }
}

///|
test "parse-event cache keeps stored corruption visible" {
  let file = @semantic.ManifestFile::new(
    "main.dew", b"fn main() -> I32 {\n  1\n}\n",
  )
  let session = program_output_test_session()
  session
  .store(
    cache_pack_parse_event_kind,
    1U,
    0U,
    0U,
    parse_event_pack_owner("corrupt.test", file.path),
    @cache_binary.blake3(file.source),
    parse_event_pack_context("corrupt.test", file),
    b"invalid stored syntax",
  )
  .unwrap()
  match
    prepare_manifest_file_parse_events(
      "corrupt.test",
      file,
      true,
      pack=Some(session),
    ) {
    Err(error) =>
      assert_true(error.contains("corrupt parse-event cache pack entry"))
    Ok(_) => fail("expected corrupt stored bytes to remain visible")
  }
}
