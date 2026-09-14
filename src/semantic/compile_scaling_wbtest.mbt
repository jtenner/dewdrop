///|
test "single interface fingerprint matches full refresh with shared dependencies" {
  let program = collect_program_manifest(
    3100UL,
    ProgramManifest::new([
      ManifestModule::new("bench.base", [
        ManifestFile::new("base.dew", b"pub struct Item {\n value: I32\n}\n"),
      ]),
      ManifestModule::new("bench.left", [
        ManifestFile::new(
          "left.dew", b"open bench.base\npub fn keep(value: Item) -> Item {\n value\n}\n",
        ),
      ]),
      ManifestModule::new("bench.right", [
        ManifestFile::new(
          "right.dew", b"import bench.base\npub fn value() -> I32 {\n 1\n}\n",
        ),
      ]),
      ManifestModule::new("bench.root", [
        ManifestFile::new(
          "root.dew", b"import bench.left\nimport bench.right\npub fn value() -> I32 {\n 1\n}\n",
        ),
      ]),
      ManifestModule::new("bench.unrelated", [
        ManifestFile::new("unrelated.dew", b"pub struct Other {}\n"),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  let slots = frozen.interfaces.map(fn(value) { Some(value) })
  for missing in [false, true] {
    if missing {
      slots[4] = None
    }
    let full = frozen_available_interfaces_with_fingerprints(
      frozen.graph,
      slots,
    )
    for index in 0..<4 {
      assert_eq(
        Some(
          frozen_module_interface_with_available_fingerprints(
            frozen.graph,
            index,
            slots,
          ),
        ),
        full[index],
      )
    }
  }
  // A missing dependency must remain unavailable, not gain a partial hash.
  slots[0] = None
  let full = frozen_available_interfaces_with_fingerprints(frozen.graph, slots)
  for index in 0..<4 {
    assert_eq(
      frozen_available_interfaces_with_fingerprints(
        frozen.graph,
        slots,
        only_module=Some(index),
      )[index],
      full[index],
    )
  }
}
