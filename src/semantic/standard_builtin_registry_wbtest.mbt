///|
fn assert_standard_registry_declaration(
  module_ : CollectedModule,
  local_index : Int,
  name : String,
) -> Unit {
  guard local_index >= 0 && local_index < module_.declarations.length() else {
    abort("standard registry declaration ordinal is outside the module")
  }
  guard module_.name(module_.declarations[local_index].name) == name else {
    abort("standard registry declaration name does not match source order")
  }
}

///|
test "generated standard builtin registry matches collected bootstrap declarations" {
  let source = Buffer()
  source.write_string_utf8(
    "open dew.std.fixed_array\nopen dew.std.collections.stack\nopen dew.std.queue\nopen dew.std.map\nopen dew.std.set\n",
  )
  for index in 0..<20 {
    source.write_string_utf8("import ")
    source.write_string_utf8(standard_lane_module_path(index))
    source.write_byte(b'\n')
  }
  source.write_string_utf8("pub fn value() -> I32 {\n  1\n}\n")
  let program = collect_program_manifest(
    23010UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new("main.dew", source.to_bytes()),
      ]),
    ]),
  )
  let fixed = program.modules[program
    .module_index("dew.std.fixed_array")
    .unwrap()]
  assert_eq(fixed.module_id, standard_library_module_id(10))
  assert_standard_registry_declaration(fixed, 0, "FixedArray")
  assert_eq(
    standard_fixed_array_method_declaration("make"),
    make_semantic_id(fixed.module_id, 6),
  )
  assert_eq(
    standard_fixed_array_method_declaration("set_unchecked"),
    make_semantic_id(fixed.module_id, 11),
  )
  assert_eq(
    standard_fixed_array_operation(make_semantic_id(fixed.module_id, 1)),
    WasmArrayNew,
  )
  assert_eq(
    standard_fixed_array_operation(make_semantic_id(fixed.module_id, 13)),
    WasmArrayGet,
  )
  assert_eq(
    standard_fixed_array_operation(make_semantic_id(fixed.module_id, 15)),
    WasmArraySet,
  )

  let stack = program.modules[program
    .module_index("dew.std.collections.stack")
    .unwrap()]
  assert_eq(stack.module_id, standard_library_module_id(14))
  assert_standard_registry_declaration(stack, 0, "Stack")
  assert_eq(
    standard_stack_operation(make_semantic_id(stack.module_id, 2)),
    StackNew,
  )
  assert_eq(
    standard_stack_operation(make_semantic_id(stack.module_id, 10)),
    StackIter,
  )

  let queue = program.modules[program.module_index("dew.std.queue").unwrap()]
  assert_eq(queue.module_id, standard_library_module_id(15))
  assert_standard_registry_declaration(queue, 0, "Queue")
  assert_eq(
    standard_queue_operation(make_semantic_id(queue.module_id, 2)),
    QueueNew,
  )
  assert_eq(
    standard_queue_operation(make_semantic_id(queue.module_id, 12)),
    QueueIterNext,
  )

  let map = program.modules[program.module_index("dew.std.map").unwrap()]
  assert_eq(map.module_id, standard_library_module_id(11))
  assert_standard_registry_declaration(map, 0, "Map")
  assert_eq(
    standard_map_method_declaration("singleton"),
    make_semantic_id(map.module_id, 9),
  )
  assert_eq(
    standard_map_method_declaration("clear"),
    make_semantic_id(map.module_id, 18),
  )
  assert_eq(
    standard_map_operation(make_semantic_id(map.module_id, 20)),
    MapGetUnchecked,
  )
  assert_eq(standard_map_operation(make_semantic_id(map.module_id, 22)), MapSet)
  assert_eq(
    standard_map_operation(make_semantic_id(map.module_id, 23)),
    MapEmpty,
  )
  assert_eq(
    standard_map_operation(make_semantic_id(map.module_id, 25)),
    MapClear,
  )

  let set = program.modules[program.module_index("dew.std.set").unwrap()]
  assert_eq(set.module_id, standard_library_module_id(12))
  assert_standard_registry_declaration(set, 0, "Set")
  assert_eq(
    standard_set_method_declaration("empty"),
    make_semantic_id(set.module_id, 10),
  )
  assert_eq(
    standard_set_method_declaration("clear"),
    make_semantic_id(set.module_id, 17),
  )
  assert_eq(
    standard_set_operation(make_semantic_id(set.module_id, 10)),
    SetEmpty,
  )

  let option = program.modules[program.module_index("dew.std.option").unwrap()]
  assert_eq(option.module_id, standard_library_module_id(2))
  assert_standard_registry_declaration(option, 0, "Option")
  assert_eq(
    standard_option_none_variant(),
    make_semantic_id(option.module_id, 0),
  )
  assert_eq(
    standard_option_some_variant(),
    make_semantic_id(option.module_id, 1),
  )

  for lane_index in 0..<20 {
    let path = standard_lane_module_path(lane_index)
    let module_ = program.modules[program.module_index(path).unwrap()]
    assert_eq(module_.module_id, standard_library_module_id(16 + lane_index))
  }
}
