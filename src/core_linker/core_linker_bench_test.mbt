///|
fn core_link_bench_ref(index : Int) -> @lib.ValType {
  @lib.ValType::ref_type(
    @lib.RefType::new(
      false,
      @lib.HeapType::new(@lib.TypeIdx::new(index.reinterpret_as_uint())),
    ),
  )
}

///|
fn core_link_bench_dew(string_parameter : Bool) -> @lib.Module {
  let marker = @lib.RecType::new(
    @lib.SubType::comp_type(@lib.CompType::struct_([])),
  )
  let signature = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::func(
        if string_parameter {
          [@lib.ValType::eqref_null()]
        } else {
          []
        },
        [core_link_bench_ref(0)],
      ),
    ),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([marker, signature]))
  .with_import_sec(
    @lib.ImportSec::new([
      @lib.Import::new(
        @lib.Name::from_string("link:starshine"),
        @lib.Name::from_string(
          if string_parameter {
            "module_new_named"
          } else {
            "module_new"
          },
        ),
        @lib.ExternType::func(@lib.TypeIdx::new(1U)),
      ),
    ]),
  )
}

///|
fn core_link_bench_guest(string_parameter : Bool) -> @lib.Module {
  let concrete = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::struct_([
        @lib.FieldType::new(
          @lib.StorageType::val_type(@lib.ValType::i32()),
          @lib.Mut::const_(),
        ),
      ]),
    ),
  )
  let signature = @lib.RecType::new(
    @lib.SubType::comp_type(@lib.CompType::func([], [core_link_bench_ref(0)])),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([concrete, signature]))
  .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(1U)]))
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string(
          if string_parameter {
            "module_new_named"
          } else {
            "module_new"
          },
        ),
        @lib.ExternIdx::func(@lib.FuncIdx::new(0U)),
      ),
    ]),
  )
  .with_code_sec(
    @lib.CodeSec::new([
      @lib.Func::new(
        @lib.Locals::empty(),
        @lib.Expr::new([
          @lib.Instruction::i32_const(@lib.I32::new(7)),
          @lib.Instruction::struct_new(@lib.TypeIdx::new(0U)),
        ]),
      ),
    ]),
  )
}

///|
test "bench Core Wasm-GC static link module_new" (it : @bench.T) {
  let dew = @binary.encode_module(core_link_bench_dew(false)).unwrap()
  let guest = @binary.encode_module(core_link_bench_guest(false)).unwrap()
  let libraries : Array[CoreWasmLibrary] = [
    { provider: "starshine", bytes: guest },
  ]
  it.bench(fn() {
    let linked = link_core_wasm_gc_modules(dew, libraries, options={
      keep_guest_exports: false,
      validate_each_phase: false,
      run_cleanup: false,
      preserve_dew_memory_zero: true,
    }).unwrap()
    it.keep(linked.length())
  })
}
