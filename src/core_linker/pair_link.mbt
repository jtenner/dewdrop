///|
priv struct CorePlannedImport {
  source : Int
  value : @lib.Import
}

///|
fn core_full_index_map(
  type_indices : Array[Int],
  function_indices : Array[Int],
  table_indices : Array[Int],
  memory_indices : Array[Int],
  global_indices : Array[Int],
  tag_indices : Array[Int],
  element_indices : Array[Int],
  data_indices : Array[Int],
) -> CoreWasmIndexMap {
  {
    type_indices,
    function_indices,
    table_indices,
    memory_indices,
    global_indices,
    tag_indices,
    element_indices,
    data_indices,
  }
}

///|
fn core_assign_import_index(
  type_ : @lib.ExternType,
  old_function : Int,
  old_table : Int,
  old_memory : Int,
  old_global : Int,
  old_tag : Int,
  function_indices : Array[Int],
  table_indices : Array[Int],
  memory_indices : Array[Int],
  global_indices : Array[Int],
  tag_indices : Array[Int],
  next : Array[Int],
) -> Unit {
  match type_ {
    @lib.FuncExternType(_) => {
      function_indices[old_function] = next[0]
      next[0] += 1
    }
    @lib.TableExternType(_) => {
      table_indices[old_table] = next[1]
      next[1] += 1
    }
    @lib.MemExternType(_) => {
      memory_indices[old_memory] = next[2]
      next[2] += 1
    }
    @lib.GlobalExternType(_) => {
      global_indices[old_global] = next[3]
      next[3] += 1
    }
    @lib.TagExternType(_) => {
      tag_indices[old_tag] = next[4]
      next[4] += 1
    }
  }
}

///|
fn core_advance_import_ordinals(
  type_ : @lib.ExternType,
  ordinals : Array[Int],
) -> Unit {
  match type_ {
    @lib.FuncExternType(_) => ordinals[0] += 1
    @lib.TableExternType(_) => ordinals[1] += 1
    @lib.MemExternType(_) => ordinals[2] += 1
    @lib.GlobalExternType(_) => ordinals[3] += 1
    @lib.TagExternType(_) => ordinals[4] += 1
  }
}

///|
fn core_build_type_maps(
  dew_arena : CoreTypeArena,
  guest_arena : CoreTypeArena,
  marker_guest_types : Array[Int],
  concrete_guest_types : Array[Int],
) -> Result[(Array[Int], Array[Int], Array[Bool], Int), CoreWasmLinkError] {
  let guest_types = core_make_sequential_indices(
    guest_arena.subtypes.length(),
    0,
  )
  let dew_types = Array::make(dew_arena.subtypes.length(), -1)
  let dropped_groups = Array::make(dew_arena.groups.length(), false)
  let mut next = guest_arena.subtypes.length()
  for group_index, group in dew_arena.groups {
    let length = match group {
      @lib.SingleRecType(_) => 1
      @lib.GroupRecType(values) => values.length()
    }
    let start = if length == 0 {
      0
    } else {
      let mut found = -1
      for type_index in 0..<dew_arena.group_by_type.length() {
        if dew_arena.group_by_type[type_index] == group_index {
          found = type_index
          break
        }
      }
      found
    }
    let mut bound_count = 0
    let mut bound_guest_type = -1
    for offset in 0..<length {
      let dew_type = start + offset
      let guest_type = if marker_guest_types[dew_type] >= 0 {
        marker_guest_types[dew_type]
      } else {
        concrete_guest_types[dew_type]
      }
      if guest_type >= 0 {
        bound_count += 1
        bound_guest_type = guest_type
      }
    }
    if bound_count > 0 {
      if length != 1 || bound_count != 1 {
        return Err(CoreWasmInvalidMarkerGroup(group_index))
      }
      dropped_groups[group_index] = true
      dew_types[start] = guest_types[bound_guest_type]
    } else {
      for offset in 0..<length {
        dew_types[start + offset] = next
        next += 1
      }
    }
  }
  Ok((dew_types, guest_types, dropped_groups, next))
}

///|
fn core_pair_link(
  dew : @lib.Module,
  guest : @lib.Module,
  provider : String,
  options : CoreWasmLinkOptions,
) -> Result[@lib.Module, CoreWasmLinkError] {
  let dew_arena = core_type_arena(dew)
  let guest_arena = core_type_arena(guest)
  let dew_counts = core_import_counts(dew)
  let guest_counts = core_import_counts(guest)
  let marker_guest_types = Array::make(dew_arena.subtypes.length(), -1)
  let concrete_guest_types = Array::make(dew_arena.subtypes.length(), -1)
  let linked_guest_function_by_dew_import = Array::make(
    dew_counts.functions,
    -1,
  )
  let string_adapter_parameters_by_dew_import : Array[Array[Int]] = []
  for _ in 0..<dew_counts.functions {
    string_adapter_parameters_by_dew_import.push([])
  }
  let mut dew_function_ordinal = 0
  let mut found_link = false
  for import_ in core_imports(dew) {
    match import_ {
      @lib.Import(module_name, export_name, @lib.FuncExternType(dew_signature)) => {
        if core_is_link_module(module_name) &&
          core_link_provider_name(module_name) == provider {
          found_link = true
          let guest_function = match
            core_exported_function(guest, export_name) {
            Some(value) => value
            None =>
              return Err(
                CoreWasmMissingExport(provider, export_name.to_string()),
              )
          }
          let dew_type = match core_type_index(dew_signature) {
            Some(value) => value
            None =>
              return Err(
                CoreWasmSignatureMismatch(provider, export_name.to_string()),
              )
          }
          let guest_type = match
            core_function_signature_type(guest, guest_function) {
            Some(value) => value
            None =>
              return Err(
                CoreWasmSignatureMismatch(provider, export_name.to_string()),
              )
          }
          match
            core_bind_signature(
              provider,
              core_name_text(export_name),
              dew_arena,
              guest_arena,
              dew_type,
              guest_type,
              marker_guest_types,
              concrete_guest_types,
            ) {
            Ok(parameters) =>
              string_adapter_parameters_by_dew_import[dew_function_ordinal] = parameters
            Err(error) => return Err(error)
          }
          linked_guest_function_by_dew_import[dew_function_ordinal] = guest_function
        }
        dew_function_ordinal += 1
      }
      _ => ()
    }
  }
  if !found_link {
    return Ok(dew)
  }
  let (dew_type_indices, guest_type_indices, dropped_dew_groups, type_count) = match
    core_build_type_maps(
      dew_arena, guest_arena, marker_guest_types, concrete_guest_types,
    ) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let dew_function_indices = Array::make(
    dew_counts.functions + core_functions(dew).length(),
    -1,
  )
  let guest_function_indices = Array::make(
    guest_counts.functions + core_functions(guest).length(),
    -1,
  )
  let dew_table_indices = Array::make(
    dew_counts.tables + core_tables(dew).length(),
    -1,
  )
  let guest_table_indices = Array::make(
    guest_counts.tables + core_tables(guest).length(),
    -1,
  )
  let dew_memory_indices = Array::make(
    dew_counts.memories + core_memories(dew).length(),
    -1,
  )
  let guest_memory_indices = Array::make(
    guest_counts.memories + core_memories(guest).length(),
    -1,
  )
  let dew_global_indices = Array::make(
    dew_counts.globals + core_globals(dew).length(),
    -1,
  )
  let guest_global_indices = Array::make(
    guest_counts.globals + core_globals(guest).length(),
    -1,
  )
  let dew_tag_indices = Array::make(
    dew_counts.tags + core_tags(dew).length(),
    -1,
  )
  let guest_tag_indices = Array::make(
    guest_counts.tags + core_tags(guest).length(),
    -1,
  )
  let dew_element_indices = core_make_sequential_indices(
    core_elements(dew).length(),
    0,
  )
  let guest_element_indices = core_make_sequential_indices(
    core_elements(guest).length(),
    core_elements(dew).length(),
  )
  let dew_data_indices = core_make_sequential_indices(
    core_datas(dew).length(),
    0,
  )
  let guest_data_indices = core_make_sequential_indices(
    core_datas(guest).length(),
    core_datas(dew).length(),
  )
  let planned_imports : Array[CorePlannedImport] = []
  let next = [0, 0, 0, 0, 0]
  let dew_ordinals = [0, 0, 0, 0, 0]
  for import_ in core_imports(dew) {
    match import_ {
      @lib.Import(module_name, _, type_) => {
        let linked = match type_ {
          @lib.FuncExternType(_) =>
            core_is_link_module(module_name) &&
            core_link_provider_name(module_name) == provider
          _ => false
        }
        if !linked {
          core_assign_import_index(
            type_,
            dew_ordinals[0],
            dew_ordinals[1],
            dew_ordinals[2],
            dew_ordinals[3],
            dew_ordinals[4],
            dew_function_indices,
            dew_table_indices,
            dew_memory_indices,
            dew_global_indices,
            dew_tag_indices,
            next,
          )
          planned_imports.push({ source: 0, value: import_ })
        }
        core_advance_import_ordinals(type_, dew_ordinals)
      }
    }
  }
  let guest_ordinals = [0, 0, 0, 0, 0]
  for import_ in core_imports(guest) {
    match import_ {
      @lib.Import(_, _, type_) => {
        core_assign_import_index(
          type_,
          guest_ordinals[0],
          guest_ordinals[1],
          guest_ordinals[2],
          guest_ordinals[3],
          guest_ordinals[4],
          guest_function_indices,
          guest_table_indices,
          guest_memory_indices,
          guest_global_indices,
          guest_tag_indices,
          next,
        )
        core_advance_import_ordinals(type_, guest_ordinals)
        planned_imports.push({ source: 1, value: import_ })
      }
    }
  }
  let imported_function_count = next[0]
  let imported_table_count = next[1]
  let imported_memory_count = next[2]
  let imported_global_count = next[3]
  let imported_tag_count = next[4]
  core_append_defined_indices(
    dew_function_indices,
    dew_counts.functions,
    core_functions(dew).length(),
    imported_function_count,
  )
  core_append_defined_indices(
    guest_function_indices,
    guest_counts.functions,
    core_functions(guest).length(),
    imported_function_count + core_functions(dew).length(),
  )
  core_append_defined_indices(
    dew_table_indices,
    dew_counts.tables,
    core_tables(dew).length(),
    imported_table_count,
  )
  core_append_defined_indices(
    guest_table_indices,
    guest_counts.tables,
    core_tables(guest).length(),
    imported_table_count + core_tables(dew).length(),
  )
  core_append_defined_indices(
    dew_memory_indices,
    dew_counts.memories,
    core_memories(dew).length(),
    imported_memory_count,
  )
  core_append_defined_indices(
    guest_memory_indices,
    guest_counts.memories,
    core_memories(guest).length(),
    imported_memory_count + core_memories(dew).length(),
  )
  if options.preserve_dew_memory_zero &&
    dew_memory_indices.length() > 0 &&
    dew_memory_indices[0] != 0 {
    return Err(
      CoreWasmUnsupportedImport(
        "guest memory imports prevent Dew host memory from remaining memory 0",
      ),
    )
  }
  core_append_defined_indices(
    dew_global_indices,
    dew_counts.globals,
    core_globals(dew).length(),
    imported_global_count,
  )
  core_append_defined_indices(
    guest_global_indices,
    guest_counts.globals,
    core_globals(guest).length(),
    imported_global_count + core_globals(dew).length(),
  )
  core_append_defined_indices(
    dew_tag_indices,
    dew_counts.tags,
    core_tags(dew).length(),
    imported_tag_count,
  )
  core_append_defined_indices(
    guest_tag_indices,
    guest_counts.tags,
    core_tags(guest).length(),
    imported_tag_count + core_tags(dew).length(),
  )
  let string_adapter_imports : Array[Int] = []
  for index in 0..<linked_guest_function_by_dew_import.length() {
    let guest_function = linked_guest_function_by_dew_import[index]
    if guest_function >= 0 {
      if string_adapter_parameters_by_dew_import[index].length() > 0 {
        if string_adapter_parameters_by_dew_import[index] != [0] {
          return Err(
            CoreWasmUnsupportedImport(
              "Dew String adapters currently require one leading String parameter",
            ),
          )
        }
        dew_function_indices[index] = imported_function_count +
          core_functions(dew).length() +
          core_functions(guest).length() +
          string_adapter_imports.length()
        string_adapter_imports.push(index)
      } else {
        dew_function_indices[index] = guest_function_indices[guest_function]
      }
    }
  }
  let dew_map = core_full_index_map(
    dew_type_indices, dew_function_indices, dew_table_indices, dew_memory_indices,
    dew_global_indices, dew_tag_indices, dew_element_indices, dew_data_indices,
  )
  let guest_map = core_full_index_map(
    guest_type_indices, guest_function_indices, guest_table_indices, guest_memory_indices,
    guest_global_indices, guest_tag_indices, guest_element_indices, guest_data_indices,
  )
  let final_types = []
  for group in guest_arena.groups {
    final_types.push(core_remap_rec_group(guest_map, group))
  }
  for group_index, group in dew_arena.groups {
    if !dropped_dew_groups[group_index] {
      final_types.push(core_remap_rec_group(dew_map, group))
    }
  }
  ignore(type_count)
  let final_imports = []
  for planned in planned_imports {
    let map = if planned.source == 0 { dew_map } else { guest_map }
    match planned.value {
      @lib.Import(module_name, field, type_) =>
        final_imports.push(
          @lib.Import::new(
            module_name,
            field,
            core_remap_extern_type(map, type_),
          ),
        )
    }
  }
  let function_types = []
  for type_ in core_function_types(dew) {
    function_types.push(core_remap_type_idx(dew_map, type_))
  }
  for type_ in core_function_types(guest) {
    function_types.push(core_remap_type_idx(guest_map, type_))
  }
  for import_index in string_adapter_imports {
    let signature = core_function_signature_type(dew, import_index).unwrap()
    function_types.push(
      core_remap_type_idx(
        dew_map,
        @lib.TypeIdx::new(signature.reinterpret_as_uint()),
      ),
    )
  }
  let functions = []
  for function_ in core_functions(dew) {
    functions.push(core_remap_func(dew_map, function_))
  }
  for function_ in core_functions(guest) {
    functions.push(core_remap_func(guest_map, function_))
  }
  if string_adapter_imports.length() > 0 {
    let (dew_chunks, dew_text) = match core_find_dew_string_types(dew_arena) {
      Some(value) => value
      None =>
        return Err(
          CoreWasmUnsupportedImport("Dew String runtime types were not emitted"),
        )
    }
    let scratch_memory = imported_memory_count +
      core_memories(dew).length() +
      core_memories(guest).length()
    for import_index in string_adapter_imports {
      let guest_function = linked_guest_function_by_dew_import[import_index]
      let guest_signature = core_function_signature_type(guest, guest_function).unwrap()
      let (parameters, _) = core_function_comp_type(
        guest_arena, guest_signature,
      ).unwrap()
      let moonbit_string = match core_ref_defined_type(parameters[0]) {
        Some((false, _, value)) => guest_type_indices[value]
        _ =>
          return Err(
            CoreWasmUnsupportedImport("guest String parameter is not concrete"),
          )
      }
      functions.push(
        core_dew_to_moonbit_string_adapter(
          dew_type_indices[dew_chunks],
          dew_type_indices[dew_text],
          moonbit_string,
          guest_function_indices[guest_function],
          scratch_memory,
        ),
      )
    }
  }
  let tables = []
  for table in core_tables(dew) {
    tables.push(core_remap_table(dew_map, table))
  }
  for table in core_tables(guest) {
    tables.push(core_remap_table(guest_map, table))
  }
  let memories = []
  for memory in core_memories(dew) {
    memories.push(memory)
  }
  for memory in core_memories(guest) {
    memories.push(memory)
  }
  if string_adapter_imports.length() > 0 {
    memories.push(@lib.MemType::new(@lib.Limits::i32(1U, Some(1U))))
  }
  let globals = []
  for global_ in core_globals(dew) {
    globals.push(core_remap_global(dew_map, global_))
  }
  for global_ in core_globals(guest) {
    globals.push(core_remap_global(guest_map, global_))
  }
  let tags = []
  for tag in core_tags(dew) {
    tags.push(core_remap_tag_type(dew_map, tag))
  }
  for tag in core_tags(guest) {
    tags.push(core_remap_tag_type(guest_map, tag))
  }
  let elements = []
  for element in core_elements(dew) {
    elements.push(core_remap_elem(dew_map, element))
  }
  for element in core_elements(guest) {
    elements.push(core_remap_elem(guest_map, element))
  }
  let datas = []
  for data in core_datas(dew) {
    datas.push(core_remap_data(dew_map, data))
  }
  for data in core_datas(guest) {
    datas.push(core_remap_data(guest_map, data))
  }
  let exports = []
  for export_ in core_exports(dew) {
    exports.push(core_remap_export(dew_map, export_))
  }
  if options.keep_guest_exports {
    for export_ in core_exports(guest) {
      exports.push(core_remap_export(guest_map, export_))
    }
  }
  let start = match (dew.start_sec, guest.start_sec) {
    (Some(@lib.StartSec(index)), None) =>
      Some(@lib.StartSec::new(core_remap_func_idx(dew_map, index)))
    (None, Some(@lib.StartSec(index))) =>
      Some(@lib.StartSec::new(core_remap_func_idx(guest_map, index)))
    (None, None) => None
    (Some(_), Some(_)) =>
      return Err(CoreWasmUnsupportedImport("cannot merge two start functions"))
  }
  let custom_secs = []
  for section in dew.custom_secs {
    custom_secs.push(section)
  }
  for section in guest.custom_secs {
    custom_secs.push(section)
  }
  let mut output = @lib.Module::new(custom_secs~)
    .with_type_sec(@lib.TypeSec::new(final_types))
    .with_import_sec(@lib.ImportSec::new(final_imports))
    .with_func_sec(@lib.FuncSec::new(function_types))
    .with_table_sec(@lib.TableSec::new(tables))
    .with_mem_sec(@lib.MemSec::new(memories))
    .with_tag_sec(@lib.TagSec::new(tags))
    .with_global_sec(@lib.GlobalSec::new(globals))
    .with_export_sec(@lib.ExportSec::new(exports))
    .with_elem_sec(@lib.ElemSec::new(elements))
    .with_data_cnt_sec(
      @lib.DataCntSec::new(@lib.U32::new(datas.length().reinterpret_as_uint())),
    )
    .with_code_sec(@lib.CodeSec::new(functions))
    .with_data_sec(@lib.DataSec::new(datas))
  match start {
    Some(value) => output = output.with_start_sec(value)
    None => ()
  }
  if options.validate_each_phase {
    match @validate.validate_module(output) {
      Ok(_) => ()
      Err(error) => return Err(CoreWasmValidationError(error.to_string()))
    }
  }
  Ok(output)
}

///|
pub fn link_core_wasm_gc_modules(
  dew_bytes : Bytes,
  libraries : Array[CoreWasmLibrary],
  options? : CoreWasmLinkOptions = CoreWasmLinkOptions::default(),
) -> Result[Bytes, CoreWasmLinkError] {
  let mut module_ = match @binary.decode_module(dew_bytes) {
    Ok(value) => value
    Err(error) => return Err(CoreWasmDecodeError(error.to_string()))
  }
  for library in libraries {
    let guest = match @binary.decode_module(library.bytes) {
      Ok(value) => value
      Err(error) => return Err(CoreWasmDecodeError(error.to_string()))
    }
    match core_pair_link(module_, guest, library.provider, options) {
      Ok(value) => module_ = value
      Err(error) => return Err(error)
    }
  }
  for import_ in core_imports(module_) {
    match import_ {
      @lib.Import(module_name, _, _) if core_is_link_module(module_name) =>
        return Err(
          CoreWasmMissingProvider(core_link_provider_name(module_name)),
        )
      _ => ()
    }
  }
  if options.run_cleanup {
    let candidate = @passes.rume_run_module_pass(
      module_,
      traps_never_happen=false,
      closed_world=false,
    )
    match @validate.validate_module(candidate) {
      Ok(_) => module_ = candidate
      Err(error) =>
        return Err(
          CoreWasmValidationError(
            "post-link cleanup transaction failed: " + error.to_string(),
          ),
        )
    }
  }
  match @binary.encode_module(module_) {
    Ok(bytes) => Ok(bytes)
    Err(error) => Err(CoreWasmEncodeError(error.to_string()))
  }
}
