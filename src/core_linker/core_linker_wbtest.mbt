///|
test "link preserves backing array memory offsets and alignment" {
  let map : CoreWasmIndexMap = {
    type_indices: [7],
    function_indices: [],
    table_indices: [],
    memory_indices: [],
    global_indices: [],
    tag_indices: [],
    element_indices: [],
    data_indices: [],
  }
  let argument = @lib.MemArg::new(@lib.U32::new(1U), None, @lib.U64::new(23UL))
  let load = @lib.Instruction::array_load(
    @lib.LoadOp::i32_load(),
    @lib.TypeIdx::new(0U),
    memarg=argument,
  )
  let store = @lib.Instruction::array_store(
    @lib.StoreOp::i32_store(),
    @lib.TypeIdx::new(0U),
    memarg=argument,
  )
  assert_eq(
    core_remap_instruction(map, load),
    @lib.Instruction::array_load(
      @lib.LoadOp::i32_load(),
      @lib.TypeIdx::new(7U),
      memarg=argument,
    ),
  )
  assert_eq(
    core_remap_instruction(map, store),
    @lib.Instruction::array_store(
      @lib.StoreOp::i32_store(),
      @lib.TypeIdx::new(7U),
      memarg=argument,
    ),
  )
}

///|
test "link remaps atomic aggregate and waitqueue type indices" {
  let map : CoreWasmIndexMap = {
    type_indices: [9],
    function_indices: [],
    table_indices: [],
    memory_indices: [],
    global_indices: [],
    tag_indices: [],
    element_indices: [],
    data_indices: [],
  }
  let order = @lib.AtomicOrder::acq_rel()
  let source = @lib.TypeIdx::new(0U)
  let target = @lib.TypeIdx::new(9U)
  let field = @lib.U32::new(3U)
  assert_eq(
    core_remap_instruction(
      map,
      @lib.Instruction::array_atomic_set(order, source),
    ),
    @lib.Instruction::array_atomic_set(order, target),
  )
  assert_eq(
    core_remap_instruction(
      map,
      @lib.Instruction::struct_atomic_set(order, source, field),
    ),
    @lib.Instruction::struct_atomic_set(order, target, field),
  )
  assert_eq(
    core_remap_instruction(map, @lib.Instruction::struct_wait(source, field)),
    @lib.Instruction::struct_wait(target, field),
  )
  for
    instruction in [
      @lib.Instruction::waitqueue_new(),
      @lib.Instruction::waitqueue_notify(),
    ] {
    assert_eq(core_remap_instruction(map, instruction), instruction)
  }
}

///|
fn core_link_test_ref(index : Int) -> @lib.ValType {
  @lib.ValType::ref_type(
    @lib.RefType::new(
      false,
      @lib.HeapType::new(@lib.TypeIdx::new(index.reinterpret_as_uint())),
    ),
  )
}

///|
fn core_link_test_nullable_ref(index : Int) -> @lib.ValType {
  @lib.ValType::ref_type(
    @lib.RefType::new(
      true,
      @lib.HeapType::new(@lib.TypeIdx::new(index.reinterpret_as_uint())),
    ),
  )
}

///|
fn core_link_test_dew_module() -> @lib.Module {
  let marker = @lib.RecType::new(
    @lib.SubType::comp_type(@lib.CompType::struct_([])),
  )
  let signature = @lib.RecType::new(
    @lib.SubType::comp_type(@lib.CompType::func([], [core_link_test_ref(0)])),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([marker, signature]))
  .with_import_sec(
    @lib.ImportSec::new([
      @lib.Import::new(
        @lib.Name::from_string("link:starshine"),
        @lib.Name::from_string("module_new"),
        @lib.ExternType::func(@lib.TypeIdx::new(1U)),
      ),
    ]),
  )
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("make"),
        @lib.ExternIdx::func(@lib.FuncIdx::new(0U)),
      ),
    ]),
  )
}

///|
fn core_link_test_guest_module() -> @lib.Module {
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
    @lib.SubType::comp_type(@lib.CompType::func([], [core_link_test_ref(0)])),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([concrete, signature]))
  .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(1U)]))
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("module_new"),
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
test "Core Wasm linker indexes provider function exports once" {
  let functions = core_exported_function_index(core_link_test_guest_module())
  assert_eq(functions.get("module_new"), Some(0))
  assert_eq(functions.get("missing"), None)
}

///|
test "Core Wasm linker replaces a nominal marker with the guest concrete type" {
  let dew = @binary.encode_module(core_link_test_dew_module()).unwrap()
  let guest = @binary.encode_module(core_link_test_guest_module()).unwrap()
  let linked = link_core_wasm_gc_modules(dew, [
    { provider: "starshine", bytes: guest, },
  ]).unwrap()
  let module_ = @binary.decode_module(linked).unwrap()
  // This check proves that cleanup keeps all retained type indices valid.
  assert_eq(@validate.validate_module(module_), Ok(()))
  match module_.import_sec {
    Some(@lib.ImportSec(imports)) => assert_eq(imports.length(), 0)
    None => ()
  }
  match module_.type_sec {
    Some(@lib.TypeSec(groups)) =>
      // Cleanup removes the marker and the unused linked import signature.
      assert_eq(groups.length(), 2)
    None => fail("expected linked types")
  }
  match module_.export_sec {
    Some(
      @lib.ExportSec(
        [@lib.Export(name, @lib.FuncExternIdx(@lib.FuncIdx(index)))]
      )
    ) => {
      assert_eq(name, @lib.Name::from_string("make"))
      assert_eq(index, 0U)
    }
    _ => fail("expected remapped Dew export")
  }
}

///|
fn core_link_test_nullable_dew_module() -> @lib.Module {
  let marker = @lib.RecType::new(
    @lib.SubType::comp_type(@lib.CompType::struct_([])),
  )
  let imported_signature = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::func([], [core_link_test_nullable_ref(0)]),
    ),
  )
  let defined_signature = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::func([], [core_link_test_nullable_ref(0)]),
    ),
  )
  @lib.Module::new()
  .with_type_sec(
    @lib.TypeSec::new([marker, imported_signature, defined_signature]),
  )
  .with_import_sec(
    @lib.ImportSec::new([
      @lib.Import::new(
        @lib.Name::from_string("link:starshine"),
        @lib.Name::from_string("maybe"),
        @lib.ExternType::func(@lib.TypeIdx::new(1U)),
      ),
    ]),
  )
  .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(2U)]))
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("make_null"),
        @lib.ExternIdx::func(@lib.FuncIdx::new(1U)),
      ),
    ]),
  )
  .with_code_sec(
    @lib.CodeSec::new([
      @lib.Func::new(
        @lib.Locals::empty(),
        @lib.Expr::new([
          @lib.Instruction::ref_null(@lib.HeapType::new(@lib.TypeIdx::new(0U))),
        ]),
      ),
    ]),
  )
}

///|
fn core_link_test_nullable_guest_module() -> @lib.Module {
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
    @lib.SubType::comp_type(
      @lib.CompType::func([], [core_link_test_nullable_ref(0)]),
    ),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([concrete, signature]))
  .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(1U)]))
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("maybe"),
        @lib.ExternIdx::func(@lib.FuncIdx::new(0U)),
      ),
    ]),
  )
  .with_code_sec(
    @lib.CodeSec::new([
      @lib.Func::new(
        @lib.Locals::empty(),
        @lib.Expr::new([
          @lib.Instruction::ref_null(@lib.HeapType::new(@lib.TypeIdx::new(0U))),
        ]),
      ),
    ]),
  )
}

///|
fn core_link_test_non_nullable_maybe_dew_module() -> @lib.Module {
  let marker = @lib.RecType::new(
    @lib.SubType::comp_type(@lib.CompType::struct_([])),
  )
  let signature = @lib.RecType::new(
    @lib.SubType::comp_type(@lib.CompType::func([], [core_link_test_ref(0)])),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([marker, signature]))
  .with_import_sec(
    @lib.ImportSec::new([
      @lib.Import::new(
        @lib.Name::from_string("link:starshine"),
        @lib.Name::from_string("maybe"),
        @lib.ExternType::func(@lib.TypeIdx::new(1U)),
      ),
    ]),
  )
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("make"),
        @lib.ExternIdx::func(@lib.FuncIdx::new(0U)),
      ),
    ]),
  )
}

///|
fn core_link_test_non_nullable_maybe_guest_module() -> @lib.Module {
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
    @lib.SubType::comp_type(@lib.CompType::func([], [core_link_test_ref(0)])),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([concrete, signature]))
  .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(1U)]))
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("maybe"),
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
test "Core Wasm linker binds nullable markers and remaps ref.null" {
  let dew = @binary.encode_module(core_link_test_nullable_dew_module()).unwrap()
  let guest = @binary.encode_module(core_link_test_nullable_guest_module()).unwrap()
  let linked = link_core_wasm_gc_modules(
    dew,
    [{ provider: "starshine", bytes: guest, }],
    options={
      keep_guest_exports: false,
      validate_each_phase: true,
      run_cleanup: false,
      preserve_dew_memory_zero: true,
    },
  ).unwrap()
  let module_ = @binary.decode_module(linked).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match module_.code_sec {
    Some(@lib.CodeSec([@lib.Func(_, @lib.Expr(instructions)), _])) =>
      match instructions {
        [
          @lib.RefNull(
            @lib.HeapTypeRefType(_, _, @lib.HeapType(@lib.TypeIdx(index)))
          ),
        ] => assert_eq(index, 0U)
        _ => fail("expected remapped Dew ref.null")
      }
    _ => fail("expected Dew and guest functions")
  }
}

///|
test "Core Wasm linker rejects nullable Dew and non-null guest mismatch" {
  let dew = @binary.encode_module(core_link_test_nullable_dew_module()).unwrap()
  let guest = @binary.encode_module(
    core_link_test_non_nullable_maybe_guest_module(),
  ).unwrap()
  match
    link_core_wasm_gc_modules(dew, [{ provider: "starshine", bytes: guest, }]) {
    Err(CoreWasmSignatureMismatch("starshine", "maybe")) => ()
    _ => fail("expected nullable-to-non-null signature mismatch")
  }
}

///|
test "Core Wasm linker rejects non-null Dew and nullable guest mismatch" {
  let dew = @binary.encode_module(
    core_link_test_non_nullable_maybe_dew_module(),
  ).unwrap()
  let guest = @binary.encode_module(core_link_test_nullable_guest_module()).unwrap()
  match
    link_core_wasm_gc_modules(dew, [{ provider: "starshine", bytes: guest, }]) {
    Err(CoreWasmSignatureMismatch("starshine", "maybe")) => ()
    _ => fail("expected non-null-to-nullable signature mismatch")
  }
}

///|
fn core_link_test_packed_array_dew_module() -> @lib.Module {
  let string = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::array(
        @lib.FieldType::new(
          @lib.StorageType::pack_type(@lib.PackType::i16()),
          @lib.Mut::var_(),
        ),
      ),
    ),
  )
  let marker = @lib.RecType::new(
    @lib.SubType::comp_type(@lib.CompType::struct_([])),
  )
  let signature = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::func([core_link_test_ref(0)], [core_link_test_ref(1)]),
    ),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([string, marker, signature]))
  .with_import_sec(
    @lib.ImportSec::new([
      @lib.Import::new(
        @lib.Name::from_string("link:starshine"),
        @lib.Name::from_string("module_new_named"),
        @lib.ExternType::func(@lib.TypeIdx::new(2U)),
      ),
    ]),
  )
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("make_named"),
        @lib.ExternIdx::func(@lib.FuncIdx::new(0U)),
      ),
    ]),
  )
}

///|
test "Core Wasm linker coalesces exact packed array types without an adapter" {
  let dew = @binary.encode_module(core_link_test_packed_array_dew_module()).unwrap()
  let guest = @binary.encode_module(core_link_test_string_guest_module()).unwrap()
  let linked = link_core_wasm_gc_modules(
    dew,
    [{ provider: "starshine", bytes: guest, }],
    options={
      keep_guest_exports: false,
      validate_each_phase: true,
      run_cleanup: false,
      preserve_dew_memory_zero: true,
    },
  ).unwrap()
  let module_ = @binary.decode_module(linked).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match module_.type_sec {
    Some(@lib.TypeSec(groups)) => assert_eq(groups.length(), 4)
    None => fail("expected coalesced linked types")
  }
  match module_.code_sec {
    Some(@lib.CodeSec(functions)) => assert_eq(functions.length(), 1)
    None => fail("expected only the guest function")
  }
  match module_.mem_sec {
    None | Some(@lib.MemSec([])) => ()
    _ => fail("did not expect adapter memory")
  }
}

///|
fn core_link_test_i32_array_dew_module() -> @lib.Module {
  let values = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::array(
        @lib.FieldType::new(
          @lib.StorageType::val_type(@lib.ValType::i32()),
          @lib.Mut::var_(),
        ),
      ),
    ),
  )
  let marker = @lib.RecType::new(
    @lib.SubType::comp_type(@lib.CompType::struct_([])),
  )
  let signature = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::func([core_link_test_ref(0)], [core_link_test_ref(1)]),
    ),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([values, marker, signature]))
  .with_import_sec(
    @lib.ImportSec::new([
      @lib.Import::new(
        @lib.Name::from_string("link:facet"),
        @lib.Name::from_string("consume_i32_array"),
        @lib.ExternType::func(@lib.TypeIdx::new(2U)),
      ),
    ]),
  )
}

///|
fn core_link_test_i32_array_guest_module() -> @lib.Module {
  let values = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::array(
        @lib.FieldType::new(
          @lib.StorageType::val_type(@lib.ValType::i32()),
          @lib.Mut::var_(),
        ),
      ),
    ),
  )
  let result = @lib.RecType::new(
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
    @lib.SubType::comp_type(
      @lib.CompType::func([core_link_test_ref(0)], [core_link_test_ref(1)]),
    ),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([values, result, signature]))
  .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(2U)]))
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("consume_i32_array"),
        @lib.ExternIdx::func(@lib.FuncIdx::new(0U)),
      ),
    ]),
  )
  .with_code_sec(
    @lib.CodeSec::new([
      @lib.Func::new(
        @lib.Locals::empty(),
        @lib.Expr::new([
          @lib.Instruction::i32_const(@lib.I32::new(1)),
          @lib.Instruction::struct_new(@lib.TypeIdx::new(1U)),
        ]),
      ),
    ]),
  )
}

///|
test "Core Wasm linker coalesces exact non-packed numeric array types" {
  let linked = link_core_wasm_gc_modules(
    @binary.encode_module(core_link_test_i32_array_dew_module()).unwrap(),
    [
      {
        provider: "facet",
        bytes: @binary.encode_module(core_link_test_i32_array_guest_module()).unwrap(),
      },
    ],
    options={
      keep_guest_exports: false,
      validate_each_phase: true,
      run_cleanup: false,
      preserve_dew_memory_zero: true,
    },
  ).unwrap()
  assert_eq(
    @validate.validate_module(@binary.decode_module(linked).unwrap()),
    Ok(()),
  )
}

///|
fn core_link_test_string_dew_module() -> @lib.Module {
  let marker = @lib.RecType::new(
    @lib.SubType::comp_type(@lib.CompType::struct_([])),
  )
  let chunks = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::array(
        @lib.FieldType::new(
          @lib.StorageType::val_type(@lib.ValType::v128()),
          @lib.Mut::var_(),
        ),
      ),
    ),
  )
  let text = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::struct_([
        @lib.FieldType::new(
          @lib.StorageType::val_type(core_link_test_ref(1)),
          @lib.Mut::const_(),
        ),
        @lib.FieldType::new(
          @lib.StorageType::val_type(@lib.ValType::i32()),
          @lib.Mut::const_(),
        ),
        @lib.FieldType::new(
          @lib.StorageType::val_type(@lib.ValType::i32()),
          @lib.Mut::const_(),
        ),
      ]),
    ),
  )
  let signature = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::func([@lib.ValType::eqref_null()], [core_link_test_ref(0)]),
    ),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([marker, chunks, text, signature]))
  .with_import_sec(
    @lib.ImportSec::new([
      @lib.Import::new(
        @lib.Name::from_string("link:starshine"),
        @lib.Name::from_string("module_new_named"),
        @lib.ExternType::func(@lib.TypeIdx::new(3U)),
      ),
    ]),
  )
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("make_named"),
        @lib.ExternIdx::func(@lib.FuncIdx::new(0U)),
      ),
    ]),
  )
}

///|
fn core_link_test_string_guest_module() -> @lib.Module {
  let string = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::array(
        @lib.FieldType::new(
          @lib.StorageType::pack_type(@lib.PackType::i16()),
          @lib.Mut::var_(),
        ),
      ),
    ),
  )
  let module_type = @lib.RecType::new(
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
    @lib.SubType::comp_type(
      @lib.CompType::func([core_link_test_ref(0)], [core_link_test_ref(1)]),
    ),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([string, module_type, signature]))
  .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(2U)]))
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("module_new_named"),
        @lib.ExternIdx::func(@lib.FuncIdx::new(0U)),
      ),
    ]),
  )
  .with_code_sec(
    @lib.CodeSec::new([
      @lib.Func::new(
        @lib.Locals::empty(),
        @lib.Expr::new([
          @lib.Instruction::i32_const(@lib.I32::new(1)),
          @lib.Instruction::struct_new(@lib.TypeIdx::new(1U)),
        ]),
      ),
    ]),
  )
}

///|
test "Core Wasm linker adds the Dew String to MoonBit String adapter" {
  let dew = @binary.encode_module(core_link_test_string_dew_module()).unwrap()
  let guest = @binary.encode_module(core_link_test_string_guest_module()).unwrap()
  let linked = link_core_wasm_gc_modules(
    dew,
    [{ provider: "starshine", bytes: guest, }],
    options={
      keep_guest_exports: false,
      validate_each_phase: true,
      run_cleanup: false,
      preserve_dew_memory_zero: true,
    },
  ).unwrap()
  let module_ = @binary.decode_module(linked).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match module_.mem_sec {
    Some(@lib.MemSec(memories)) => assert_eq(memories.length(), 1)
    None => fail("expected private adapter scratch memory")
  }
  match module_.code_sec {
    Some(@lib.CodeSec(functions)) => assert_eq(functions.length(), 2)
    None => fail("expected guest and adapter functions")
  }
}

///|
test "Core Wasm linker keeps Dew and guest memories separate" {
  let dew_base = core_link_test_dew_module()
  let dew = dew_base
    .with_type_sec(
      @lib.TypeSec::new([
        @lib.RecType::new(@lib.SubType::comp_type(@lib.CompType::struct_([]))),
        @lib.RecType::new(
          @lib.SubType::comp_type(
            @lib.CompType::func([], [core_link_test_ref(0)]),
          ),
        ),
        @lib.RecType::new(
          @lib.SubType::comp_type(
            @lib.CompType::func([], [@lib.ValType::i32()]),
          ),
        ),
      ]),
    )
    .with_table_sec(
      @lib.TableSec::new([
        @lib.Table::new(
          @lib.TableType::new(
            @lib.RefType::abs(@lib.AbsHeapType::func()),
            @lib.Limits::i32(1U, Some(1U)),
          ),
          None,
        ),
      ]),
    )
    .with_mem_sec(
      @lib.MemSec::new([@lib.MemType::new(@lib.Limits::i32(1U, Some(1U)))]),
    )
    .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(2U)]))
    .with_code_sec(
      @lib.CodeSec::new([
        @lib.Func::new(
          @lib.Locals::empty(),
          @lib.Expr::new([
            @lib.Instruction::i32_const(@lib.I32::new(0)),
            @lib.Instruction::i32_load(
              @lib.MemArg::new(@lib.U32::new(2U), None, @lib.U64::new(0UL)),
            ),
          ]),
        ),
      ]),
    )
  let guest_base = core_link_test_guest_module()
  let guest = guest_base
    .with_table_sec(
      @lib.TableSec::new([
        @lib.Table::new(
          @lib.TableType::new(
            @lib.RefType::abs(@lib.AbsHeapType::func()),
            @lib.Limits::i32(1U, Some(1U)),
          ),
          None,
        ),
      ]),
    )
    .with_mem_sec(
      @lib.MemSec::new([@lib.MemType::new(@lib.Limits::i32(1U, Some(1U)))]),
    )
    .with_code_sec(
      @lib.CodeSec::new([
        @lib.Func::new(
          @lib.Locals::empty(),
          @lib.Expr::new([
            @lib.Instruction::table_size(@lib.TableIdx::new(0U)),
            @lib.Instruction::drop(),
            @lib.Instruction::i32_const(@lib.I32::new(0)),
            @lib.Instruction::i32_const(@lib.I32::new(7)),
            @lib.Instruction::i32_store(
              @lib.MemArg::new(@lib.U32::new(2U), None, @lib.U64::new(0UL)),
            ),
            @lib.Instruction::i32_const(@lib.I32::new(7)),
            @lib.Instruction::struct_new(@lib.TypeIdx::new(0U)),
          ]),
        ),
      ]),
    )
  let linked = link_core_wasm_gc_modules(
    @binary.encode_module(dew).unwrap(),
    [{ provider: "starshine", bytes: @binary.encode_module(guest).unwrap(), }],
    options={
      keep_guest_exports: false,
      validate_each_phase: true,
      run_cleanup: false,
      preserve_dew_memory_zero: true,
    },
  ).unwrap()
  let module_ = @binary.decode_module(linked).unwrap()
  match module_.mem_sec {
    Some(@lib.MemSec(memories)) => assert_eq(memories.length(), 2)
    None => fail("expected two private memories")
  }
  match module_.table_sec {
    Some(@lib.TableSec(tables)) => assert_eq(tables.length(), 2)
    None => fail("expected two private tables")
  }
  let mut remapped_guest_store = false
  let mut remapped_guest_table = false
  match module_.code_sec {
    Some(@lib.CodeSec(functions)) =>
      match functions[1] {
        @lib.Func(_, @lib.Expr(instructions)) =>
          for instruction in instructions {
            match instruction {
              @lib.I32Store(@lib.MemArg(_, Some(@lib.MemIdx(1U)), _)) =>
                remapped_guest_store = true
              @lib.TableSize(@lib.TableIdx(1U)) => remapped_guest_table = true
              _ => ()
            }
          }
      }
    None => fail("expected linked functions")
  }
  assert_true(remapped_guest_store)
  assert_true(remapped_guest_table)
}

///|
test "Core Wasm linker keeps Dew memory zero for Facet providers" {
  let dew = core_link_test_dew_module()
    .with_import_sec(
      @lib.ImportSec::new([
        @lib.Import::new(
          @lib.Name::from_string("link:facet"),
          @lib.Name::from_string("module_new"),
          @lib.ExternType::func(@lib.TypeIdx::new(1U)),
        ),
      ]),
    )
    .with_mem_sec(
      @lib.MemSec::new([@lib.MemType::new(@lib.Limits::i32(1U, Some(1U)))]),
    )
  let guest = core_link_test_guest_module()
    .with_mem_sec(
      @lib.MemSec::new([@lib.MemType::new(@lib.Limits::i32(2U, Some(2U)))]),
    )
    .with_code_sec(
      @lib.CodeSec::new([
        @lib.Func::new(
          @lib.Locals::empty(),
          @lib.Expr::new([
            @lib.Instruction::i32_const(@lib.I32::new(0)),
            @lib.Instruction::i32_load(
              @lib.MemArg::new(@lib.U32::new(2U), None, @lib.U64::new(0UL)),
            ),
            @lib.Instruction::drop(),
            @lib.Instruction::i32_const(@lib.I32::new(7)),
            @lib.Instruction::struct_new(@lib.TypeIdx::new(0U)),
          ]),
        ),
      ]),
    )
  let linked = link_core_wasm_gc_modules(
    @binary.encode_module(dew).unwrap(),
    [{ provider: "facet", bytes: @binary.encode_module(guest).unwrap(), }],
    options={
      keep_guest_exports: false,
      validate_each_phase: true,
      run_cleanup: false,
      preserve_dew_memory_zero: true,
    },
  ).unwrap()
  let module_ = @binary.decode_module(linked).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  let mut guest_uses_memory_one = false
  match module_.code_sec {
    Some(@lib.CodeSec(functions)) =>
      match functions[0] {
        @lib.Func(_, @lib.Expr(instructions)) =>
          for instruction in instructions {
            match instruction {
              @lib.I32Load(@lib.MemArg(_, Some(@lib.MemIdx(1U)), _)) =>
                guest_uses_memory_one = true
              _ => ()
            }
          }
      }
    None => fail("expected Facet guest function")
  }
  assert_true(guest_uses_memory_one)
}

///|
test "Core Wasm linker reports missing providers" {
  let dew = @binary.encode_module(core_link_test_dew_module()).unwrap()
  match link_core_wasm_gc_modules(dew, []) {
    Err(CoreWasmMissingProvider("starshine")) => ()
    _ => fail("expected missing-provider error")
  }
}

///|
test "Core Wasm linker binds an exact direct import module provider" {
  let signature = @lib.RecType::new(
    @lib.SubType::comp_type(@lib.CompType::func([], [@lib.ValType::i64()])),
  )
  let dew = @lib.Module::new()
    .with_type_sec(@lib.TypeSec::new([signature]))
    .with_import_sec(
      @lib.ImportSec::new([
        @lib.Import::new(
          @lib.Name::from_string("__moonbit_time_unstable"),
          @lib.Name::from_string("now"),
          @lib.ExternType::func(@lib.TypeIdx::new(0U)),
        ),
      ]),
    )
    .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(0U)]))
    .with_export_sec(
      @lib.ExportSec::new([
        @lib.Export::new(
          @lib.Name::from_string("read_time"),
          @lib.ExternIdx::func(@lib.FuncIdx::new(1U)),
        ),
      ]),
    )
    .with_code_sec(
      @lib.CodeSec::new([
        @lib.Func::new(
          @lib.Locals::empty(),
          @lib.Expr::new([@lib.Instruction::call(@lib.FuncIdx::new(0U))]),
        ),
      ]),
    )
  let provider = @lib.Module::new()
    .with_type_sec(@lib.TypeSec::new([signature]))
    .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(0U)]))
    .with_export_sec(
      @lib.ExportSec::new([
        @lib.Export::new(
          @lib.Name::from_string("now"),
          @lib.ExternIdx::func(@lib.FuncIdx::new(0U)),
        ),
      ]),
    )
    .with_code_sec(
      @lib.CodeSec::new([
        @lib.Func::new(
          @lib.Locals::empty(),
          @lib.Expr::new([@lib.Instruction::i64_const(0L)]),
        ),
      ]),
    )
  let linked = link_core_wasm_gc_modules(
    @binary.encode_module(dew).unwrap(),
    [
      {
        provider: "__moonbit_time_unstable",
        bytes: @binary.encode_module(provider).unwrap(),
      },
    ],
    options={
      keep_guest_exports: false,
      validate_each_phase: true,
      run_cleanup: false,
      preserve_dew_memory_zero: true,
    },
  ).unwrap()
  let module_ = @binary.decode_module(linked).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_eq(core_imports(module_).length(), 0)
}

///|
fn core_link_test_erased_reference_dew_module() -> @lib.Module {
  let signature = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::func([@lib.ValType::eqref_null()], [
        @lib.ValType::eqref_null(),
      ]),
    ),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([signature]))
  .with_import_sec(
    @lib.ImportSec::new([
      @lib.Import::new(
        @lib.Name::from_string("link:starshine"),
        @lib.Name::from_string("identity"),
        @lib.ExternType::func(@lib.TypeIdx::new(0U)),
      ),
    ]),
  )
  .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(0U)]))
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("call_identity"),
        @lib.ExternIdx::func(@lib.FuncIdx::new(1U)),
      ),
    ]),
  )
  .with_code_sec(
    @lib.CodeSec::new([
      @lib.Func::new(
        @lib.Locals::empty(),
        @lib.Expr::new([
          @lib.Instruction::local_get(@lib.LocalIdx::new(0U)),
          @lib.Instruction::call(@lib.FuncIdx::new(0U)),
        ]),
      ),
    ]),
  )
}

///|
fn core_link_test_concrete_reference_guest_module() -> @lib.Module {
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
    @lib.SubType::comp_type(
      @lib.CompType::func([core_link_test_ref(0)], [core_link_test_ref(0)]),
    ),
  )
  @lib.Module::new()
  .with_type_sec(@lib.TypeSec::new([concrete, signature]))
  .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(1U)]))
  .with_export_sec(
    @lib.ExportSec::new([
      @lib.Export::new(
        @lib.Name::from_string("identity"),
        @lib.ExternIdx::func(@lib.FuncIdx::new(0U)),
      ),
    ]),
  )
  .with_code_sec(
    @lib.CodeSec::new([
      @lib.Func::new(
        @lib.Locals::empty(),
        @lib.Expr::new([@lib.Instruction::local_get(@lib.LocalIdx::new(0U))]),
      ),
    ]),
  )
}

///|
test "Core Wasm linker does not classify Facet i16 arrays as Strings" {
  let dew = match core_link_test_erased_reference_dew_module().import_sec {
    Some(@lib.ImportSec([@lib.Import(_, name, type_)])) =>
      core_link_test_erased_reference_dew_module().with_import_sec(
        @lib.ImportSec::new([
          @lib.Import::new(@lib.Name::from_string("link:facet"), name, type_),
        ]),
      )
    _ => fail("expected erased reference fixture import")
  }
  let array_i16 = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::array(
        @lib.FieldType::new(
          @lib.StorageType::pack_type(@lib.PackType::i16()),
          @lib.Mut::var_(),
        ),
      ),
    ),
  )
  let signature = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::func([core_link_test_ref(0)], [core_link_test_ref(0)]),
    ),
  )
  let guest = @lib.Module::new()
    .with_type_sec(@lib.TypeSec::new([array_i16, signature]))
    .with_func_sec(@lib.FuncSec::new([@lib.TypeIdx::new(1U)]))
    .with_export_sec(
      @lib.ExportSec::new([
        @lib.Export::new(
          @lib.Name::from_string("identity"),
          @lib.ExternIdx::func(@lib.FuncIdx::new(0U)),
        ),
      ]),
    )
    .with_code_sec(
      @lib.CodeSec::new([
        @lib.Func::new(
          @lib.Locals::empty(),
          @lib.Expr::new([@lib.Instruction::local_get(@lib.LocalIdx::new(0U))]),
        ),
      ]),
    )
  let linked = link_core_wasm_gc_modules(
    @binary.encode_module(dew).unwrap(),
    [{ provider: "facet", bytes: @binary.encode_module(guest).unwrap(), }],
    options={
      keep_guest_exports: false,
      validate_each_phase: true,
      run_cleanup: false,
      preserve_dew_memory_zero: true,
    },
  ).unwrap()
  assert_eq(
    @validate.validate_module(@binary.decode_module(linked).unwrap()),
    Ok(()),
  )
}

///|
test "Core Wasm linker adapts erased eqref parameters to concrete provider references" {
  let linked = link_core_wasm_gc_modules(
    @binary.encode_module(core_link_test_erased_reference_dew_module()).unwrap(),
    [
      {
        provider: "starshine",
        bytes: @binary.encode_module(
          core_link_test_concrete_reference_guest_module(),
        ).unwrap(),
      },
    ],
    options={
      keep_guest_exports: false,
      validate_each_phase: true,
      run_cleanup: false,
      preserve_dew_memory_zero: true,
    },
  ).unwrap()
  let module_ = @binary.decode_module(linked).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match module_.code_sec {
    Some(@lib.CodeSec(functions)) => {
      assert_eq(functions.length(), 3)
      match functions[0] {
        @lib.Func(
          _,
          @lib.Expr(
            [@lib.LocalGet(@lib.LocalIdx(0U)), @lib.Call(@lib.FuncIdx(2U))]
          )
        ) => ()
        _ => fail("expected Dew call to use the reference adapter")
      }
      match functions[2] {
        @lib.Func(
          _,
          @lib.Expr(
            [
              @lib.LocalGet(@lib.LocalIdx(0U)),
              @lib.RefCast(_, _, _),
              @lib.Call(@lib.FuncIdx(1U)),
            ]
          )
        ) => ()
        _ => fail("expected eqref-to-concrete cast adapter")
      }
    }
    None => fail("expected linked functions")
  }
}
