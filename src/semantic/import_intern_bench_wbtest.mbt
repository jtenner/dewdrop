///|
test "bench imported structural types count=4096" (it : @bench.T) {
  it.bench(fn() {
    let resolved = resolve_module_types(collect_bytes(77UL, b""))
    let importer = InterfaceTypeImporter::new(resolved, [])
    for i in 0..<4096 {
      let nominal = importer.intern_simple(0, NominalType(make_semantic_id(77UL, i)))
      it.keep(importer.intern_function([nominal], nominal))
      it.keep(importer.intern_product([nominal]))
      it.keep(importer.intern_applied(nominal, [nominal]))
    }
  }, count=3U)
}
