///|
fn subtype_link_benchmark_module(count : Int) -> @lib.Module {
  let original = core_link_bench_dew(false)
  let groups = match original.type_sec {
    Some(@lib.TypeSec(groups)) => groups.copy()
    None => abort("benchmark needs type section")
  }
  for _ in 0..<count {
    groups.push(
      @lib.RecType::new(@lib.SubType::comp_type(@lib.CompType::struct_([]))),
    )
  }
  let import_ = match original.import_sec {
    Some(@lib.ImportSec(imports)) => imports[0]
    None => abort("benchmark needs import section")
  }
  original
  .with_type_sec(@lib.TypeSec::new(groups))
  .with_import_sec(@lib.ImportSec::new(Array::make(count, import_)))
}

///|
test "bench complete marker link imports=512 types=514" (it : @bench.T) {
  let dew = @binary.encode_module(subtype_link_benchmark_module(512)).unwrap()
  let guest = @binary.encode_module(core_link_bench_guest(false)).unwrap()
  it.bench(fn() {
    it.keep(
      link_core_wasm_gc_modules(
        dew,
        [{ provider: "starshine", bytes: guest, }],
        options={
          keep_guest_exports: false,
          validate_each_phase: false,
          run_cleanup: false,
          preserve_dew_memory_zero: true,
        },
      ).unwrap(),
    )
  })
}

///|
test "bench complete marker link imports=4096 types=4098" (it : @bench.T) {
  let dew = @binary.encode_module(subtype_link_benchmark_module(4096)).unwrap()
  let guest = @binary.encode_module(core_link_bench_guest(false)).unwrap()
  it.bench(fn() {
    it.keep(
      link_core_wasm_gc_modules(
        dew,
        [{ provider: "starshine", bytes: guest, }],
        options={
          keep_guest_exports: false,
          validate_each_phase: false,
          run_cleanup: false,
          preserve_dew_memory_zero: true,
        },
      ).unwrap(),
    )
  })
}
