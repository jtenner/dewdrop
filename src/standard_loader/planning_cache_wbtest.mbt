///|
fn planning_cache_test_program(source : Bytes) -> @semantic.CollectedProgram {
  @semantic.collect_program_manifest(
    23960UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cache.plans", [
        @semantic.ManifestFile::new("main.dew", source),
      ]),
    ]),
  )
}

///|
test "planning cache envelopes bind provenance checksum and kind" {
  let key = @crypto.sha256(b"key")
  let source = @crypto.sha256(b"source")
  let context = @crypto.sha256(b"context")
  let payload = b"payload"
  let layout = wrap_type_layout_cache_payload(key, source, context, payload).unwrap()
  assert_eq(
    unwrap_type_layout_cache_payload(layout, key, source, context).unwrap(),
    payload,
  )
  let fragment = wrap_wasmgc_fragment_cache_payload(
    key, source, context, payload,
  ).unwrap()
  assert_eq(
    unwrap_wasmgc_fragment_cache_payload(fragment, key, source, context).unwrap(),
    payload,
  )
  let changed = @crypto.sha256(b"changed")
  assert_true(
    unwrap_type_layout_cache_payload(layout, changed, source, context) is Err(_),
  )
  assert_true(
    unwrap_wasmgc_fragment_cache_payload(fragment, key, source, changed)
    is Err(_),
  )
  assert_true(
    unwrap_type_layout_cache_payload(fragment, key, source, context) is Err(_),
  )
}

///|
test "planning cache keys track source interface root and planning mode" {
  let program = planning_cache_test_program(
    b"struct Item {\n  value: I32\n}\npub fn main() -> I32 {\n  1\n}\n",
  )
  let changed = planning_cache_test_program(
    b"struct Item {\n  value: I64\n}\npub fn main() -> I32 {\n  1\n}\n",
  )
  let frozen = @semantic.freeze_program_interfaces(program)
  let changed_frozen = @semantic.freeze_program_interfaces(changed)
  let (layout_key, _, _, _) = type_layout_cache_key(program, frozen, 0).unwrap()
  let (changed_layout_key, _, _, _) = type_layout_cache_key(
    changed, changed_frozen, 0,
  ).unwrap()
  assert_true(layout_key != changed_layout_key)
  let production = @semantic.WasmGCPlanningOptions::optimized_subtype_families()
  let testing = @semantic.WasmGCPlanningOptions::test_mode()
  let production_context = wasmgc_fragment_program_context(
    program, frozen, 0, production,
  ).unwrap()
  let testing_context = wasmgc_fragment_program_context(
    program, frozen, 0, testing,
  ).unwrap()
  let changed_context = wasmgc_fragment_program_context(
    changed, changed_frozen, 0, production,
  ).unwrap()
  assert_true(production_context != testing_context)
  assert_true(production_context != changed_context)
  let (fragment_key, _, _) = wasmgc_fragment_cache_key(
    program, 0, production_context,
  )
  let (changed_fragment_key, _, _) = wasmgc_fragment_cache_key(
    changed, 0, changed_context,
  )
  assert_true(fragment_key != changed_fragment_key)
}
