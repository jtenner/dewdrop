///|
test "cache pack saves the latest owner after an earlier compiler phase lookup" {
  let source : CompilationCachePack = {
    enabled: true,
    path: "",
    pack: @cache_binary.ArtifactPack::empty(),
    dirty: false,
    hits: 0,
    misses: 0,
    reads: 0,
  }
  let owner = "example.app::main.dew"
  let context = @cache_binary.blake3(b"checked transform graph")
  let old_content = @cache_binary.blake3(b"original body")
  let new_content = @cache_binary.blake3(b"expanded body")
  let final_content = @cache_binary.blake3(b"final checked body")
  let kind = cache_pack_parse_event_kind
  source
  .store(kind, 1U, 0U, 1U, owner, old_content, context, b"original events")
  .unwrap()
  source
  .store(kind, 1U, 0U, 1U, "other.dew", old_content, context, b"other events")
  .unwrap()
  let session = {
    ..source,
    pack: @cache_binary.open_artifact_pack(source.pack.encode().unwrap()).unwrap(),
    dirty: false,
  }
  session
  .store(kind, 1U, 0U, 1U, owner, new_content, context, b"expanded events")
  .unwrap()
  assert_eq(
    session.lookup(kind, 1U, owner, old_content, context).unwrap(),
    Some(b"original events"),
  )
  session
  .store(kind, 1U, 0U, 1U, owner, final_content, context, b"final events")
  .unwrap()
  assert_eq(
    session.lookup(kind, 1U, owner, old_content, context).unwrap(),
    Some(b"original events"),
  )
  let saved = @cache_binary.open_artifact_pack(session.pack.encode().unwrap()).unwrap()
  assert_eq(
    saved
    .lookup_checked(
      kind,
      1U,
      owner,
      final_content,
      cache_pack_bound_context(context),
    )
    .unwrap(),
    Some(b"final events"),
  )
  assert_eq(
    saved
    .lookup_checked(
      kind,
      1U,
      owner,
      old_content,
      cache_pack_bound_context(context),
    )
    .unwrap(),
    None,
  )
  assert_eq(
    saved
    .lookup_checked(
      kind,
      1U,
      "other.dew",
      old_content,
      cache_pack_bound_context(context),
    )
    .unwrap(),
    Some(b"other events"),
  )
}
