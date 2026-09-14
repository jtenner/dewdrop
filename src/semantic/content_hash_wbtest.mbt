///|
test "completed content reuse matches full refresh for cold and stale cached SCC dependencies" {
  for base_id in [3200UL, 6400UL] {
    let manifest = ProgramManifest::new([
      ManifestModule::new("bench.base", [
        ManifestFile::new("base.dew", b"pub struct Item {\n value: I32\n}\n"),
      ]),
      ManifestModule::new("bench.a", [
        ManifestFile::new(
          "a.dew", b"open bench.b\npub struct A {}\npub fn from_b(value: B) -> B {\n value\n}\n",
        ),
      ]),
      ManifestModule::new("bench.b", [
        ManifestFile::new(
          "b.dew", b"open bench.a\npub struct B {}\npub fn from_a(value: A) -> A {\n value\n}\n",
        ),
      ]),
      ManifestModule::new("bench.mid", [
        ManifestFile::new(
          "mid.dew", b"open bench.base\npub fn keep(value: Item) -> Item {\n value\n}\n",
        ),
      ]),
      ManifestModule::new("bench.root", [
        ManifestFile::new(
          "root.dew", b"import bench.mid\nimport bench.a\npub fn value() -> I32 {\n 1\n}\n",
        ),
      ]),
    ])
    let program = collect_program_manifest(base_id, manifest)
    let cold = freeze_program_interfaces(program)
    assert_eq(cold.import_diagnostics.length(), 0)
    for cached_input in [false, true] {
      let cached : Array[FrozenModuleInterface?] = Array::make(
        program.modules.length(),
        None,
      )
      if cached_input {
        for index in 0..<3 {
          cached[index] = Some({
            ..cold.interfaces[index],
            content_fingerprint: "stale cache content",
          })
        }
      }
      let observed = cached.copy()
      let checks : Array[(FrozenModuleInterface, FrozenModuleInterface)] = []
      let frozen = freeze_program_interfaces_with_cache_hooks(
        program,
        cached,
        fn(_, slots) {
          for index, slot in slots {
            observed[index] = slot
          }
          None
        },
        fn(index, interface_) {
          observed[index] = Some(interface_)
          let reference = frozen_available_interfaces_with_fingerprints(
            cold.graph,
            observed,
          )[index].unwrap()
          checks.push((interface_, reference))
        },
        fn(_, _, _) { () },
        fn(scc, indices, slots) {
          let reference = frozen_available_interfaces_with_fingerprints(
            cold.graph,
            slots,
          )
          for edge in 0..<scc.length {
            let index = indices[scc.start + edge]
            checks.push((slots[index].unwrap(), reference[index].unwrap()))
          }
        },
      )
      assert_true(checks.length() >= 2)
      for (actual, expected) in checks {
        assert_eq(actual, expected)
      }
      assert_eq(frozen.interfaces, cold.interfaces)
    }
  }
}
