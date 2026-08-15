///|
pub(all) struct CoreWasmLibrary {
  provider : String
  bytes : Bytes
} derive(Eq, Debug)

///|
pub(all) struct CoreWasmLinkOptions {
  keep_guest_exports : Bool
  validate_each_phase : Bool
  run_cleanup : Bool
  preserve_dew_memory_zero : Bool
} derive(Eq, Debug)

///|
pub fn CoreWasmLinkOptions::default() -> CoreWasmLinkOptions {
  {
    keep_guest_exports: false,
    validate_each_phase: true,
    run_cleanup: true,
    preserve_dew_memory_zero: true,
  }
}

///|
pub(all) enum CoreWasmLinkError {
  CoreWasmDecodeError(String)
  CoreWasmMissingProvider(String)
  CoreWasmMissingExport(String, String)
  CoreWasmUnsupportedImport(String)
  CoreWasmSignatureMismatch(String, String)
  CoreWasmInvalidMarkerGroup(Int)
  CoreWasmValidationError(String)
  CoreWasmEncodeError(String)
} derive(Eq, Debug)

///|
priv struct CoreTypeArena {
  groups : Array[@lib.RecType]
  subtypes : Array[@lib.SubType]
  group_by_type : Array[Int]
}

///|
fn core_type_arena(module_ : @lib.Module) -> CoreTypeArena {
  let groups = match module_.type_sec {
    Some(@lib.TypeSec(values)) => values
    None => []
  }
  let subtypes = []
  let group_by_type = []
  for group_index, group in groups {
    let values = match group {
      @lib.SingleRecType(value) => [value]
      @lib.GroupRecType(values) => values
    }
    for value in values {
      subtypes.push(value)
      group_by_type.push(group_index)
    }
  }
  { groups, subtypes, group_by_type }
}

///|
fn core_imports(module_ : @lib.Module) -> Array[@lib.Import] {
  match module_.import_sec {
    Some(@lib.ImportSec(values)) => values
    None => []
  }
}

///|
fn core_function_types(module_ : @lib.Module) -> Array[@lib.TypeIdx] {
  match module_.func_sec {
    Some(@lib.FuncSec(values)) => values
    None => []
  }
}

///|
fn core_functions(module_ : @lib.Module) -> Array[@lib.Func] {
  match module_.code_sec {
    Some(@lib.CodeSec(values)) => values
    None => []
  }
}

///|
fn core_tables(module_ : @lib.Module) -> Array[@lib.Table] {
  match module_.table_sec {
    Some(@lib.TableSec(values)) => values
    None => []
  }
}

///|
fn core_memories(module_ : @lib.Module) -> Array[@lib.MemType] {
  match module_.mem_sec {
    Some(@lib.MemSec(values)) => values
    None => []
  }
}

///|
fn core_globals(module_ : @lib.Module) -> Array[@lib.Global] {
  match module_.global_sec {
    Some(@lib.GlobalSec(values)) => values
    None => []
  }
}

///|
fn core_tags(module_ : @lib.Module) -> Array[@lib.TagType] {
  match module_.tag_sec {
    Some(@lib.TagSec(values)) => values
    None => []
  }
}

///|
fn core_elements(module_ : @lib.Module) -> Array[@lib.Elem] {
  match module_.elem_sec {
    Some(@lib.ElemSec(values)) => values
    None => []
  }
}

///|
fn core_datas(module_ : @lib.Module) -> Array[@lib.Data] {
  match module_.data_sec {
    Some(@lib.DataSec(values)) => values
    None => []
  }
}

///|
fn core_exports(module_ : @lib.Module) -> Array[@lib.Export] {
  match module_.export_sec {
    Some(@lib.ExportSec(values)) => values
    None => []
  }
}

///|
priv struct CoreImportCounts {
  functions : Int
  tables : Int
  memories : Int
  globals : Int
  tags : Int
}

///|
fn core_import_counts(module_ : @lib.Module) -> CoreImportCounts {
  let mut functions = 0
  let mut tables = 0
  let mut memories = 0
  let mut globals = 0
  let mut tags = 0
  for import_ in core_imports(module_) {
    match import_ {
      @lib.Import(_, _, type_) =>
        match type_ {
          @lib.FuncExternType(_) => functions += 1
          @lib.TableExternType(_) => tables += 1
          @lib.MemExternType(_) => memories += 1
          @lib.GlobalExternType(_) => globals += 1
          @lib.TagExternType(_) => tags += 1
        }
    }
  }
  { functions, tables, memories, globals, tags }
}

///|
fn core_name_text(value : @lib.Name) -> String {
  match value {
    @lib.Name(text) => text.to_owned()
  }
}

///|
fn core_is_link_module(value : @lib.Name) -> Bool {
  let text = core_name_text(value)
  text.length() >= 5 && text[0:5] == "link:"
}

///|
fn core_link_provider_name(value : @lib.Name) -> String {
  let text = core_name_text(value)
  if text.length() < 5 {
    ""
  } else {
    text[5:].to_owned()
  }
}

///|
fn core_type_index(value : @lib.TypeIdx) -> Int? {
  match value {
    @lib.TypeIdx(index) => Some(index.reinterpret_as_int())
    @lib.RecIdx(_) => None
  }
}

///|
fn core_function_signature_type(
  module_ : @lib.Module,
  function_index : Int,
) -> Int? {
  let imports = core_imports(module_)
  let mut imported_function = 0
  for import_ in imports {
    match import_ {
      @lib.Import(_, _, type_) =>
        match type_ {
          @lib.FuncExternType(index) => {
            if imported_function == function_index {
              return core_type_index(index)
            }
            imported_function += 1
          }
          _ => ()
        }
    }
  }
  let defined = function_index - imported_function
  let types = core_function_types(module_)
  if defined < 0 || defined >= types.length() {
    return None
  }
  core_type_index(types[defined])
}

///|
fn core_exported_function(module_ : @lib.Module, name : @lib.Name) -> Int? {
  for export_ in core_exports(module_) {
    match export_ {
      @lib.Export(candidate, item) =>
        if candidate == name {
          match item {
            @lib.FuncExternIdx(@lib.FuncIdx(index)) =>
              return Some(index.reinterpret_as_int())
            _ => return None
          }
        }
    }
  }
  None
}

///|
fn core_function_comp_type(
  arena : CoreTypeArena,
  index : Int,
) -> (Array[@lib.ValType], Array[@lib.ValType])? {
  if index < 0 || index >= arena.subtypes.length() {
    return None
  }
  match arena.subtypes[index].get_comptype() {
    @lib.FuncCompType(parameters, results) => Some((parameters, results))
    _ => None
  }
}

///|
fn core_empty_struct_marker(arena : CoreTypeArena, index : Int) -> Bool {
  if index < 0 || index >= arena.subtypes.length() {
    return false
  }
  match arena.subtypes[index].get_comptype() {
    @lib.StructCompType(fields) => fields.length() == 0
    _ => false
  }
}

///|
fn core_ref_defined_type(value : @lib.ValType) -> (Bool, Bool, Int)? {
  match value {
    @lib.RefTypeValType(
      @lib.HeapTypeRefType(nullable, exact, @lib.HeapType(index))
    ) =>
      match core_type_index(index) {
        Some(value) => Some((nullable, exact, value))
        None => None
      }
    _ => None
  }
}

///|
fn core_same_packed_array_type(
  dew_arena : CoreTypeArena,
  guest_arena : CoreTypeArena,
  dew : Int,
  guest : Int,
) -> Bool {
  if dew < 0 ||
    dew >= dew_arena.subtypes.length() ||
    guest < 0 ||
    guest >= guest_arena.subtypes.length() {
    return false
  }
  match
    (
      dew_arena.subtypes[dew].get_comptype(),
      guest_arena.subtypes[guest].get_comptype(),
    ) {
    (@lib.ArrayCompType(dew_field), @lib.ArrayCompType(guest_field)) =>
      dew_field == guest_field && dew_field.get_storage_type().is_packed()
    _ => false
  }
}

///|
fn core_bind_value_type(
  dew_arena : CoreTypeArena,
  guest_arena : CoreTypeArena,
  dew : @lib.ValType,
  guest : @lib.ValType,
  marker_guest_types : Array[Int],
  concrete_guest_types : Array[Int],
) -> Bool {
  match (core_ref_defined_type(dew), core_ref_defined_type(guest)) {
    (
      Some((dew_nullable, dew_exact, marker)),
      Some((guest_nullable, guest_exact, concrete)),
    ) if core_empty_struct_marker(dew_arena, marker) => {
      if dew_nullable != guest_nullable ||
        dew_exact != guest_exact ||
        concrete < 0 ||
        concrete >= guest_arena.subtypes.length() {
        return false
      }
      if marker_guest_types[marker] >= 0 &&
        marker_guest_types[marker] != concrete {
        return false
      }
      marker_guest_types[marker] = concrete
      true
    }
    (
      Some((dew_nullable, dew_exact, dew_concrete)),
      Some((guest_nullable, guest_exact, guest_concrete)),
    ) if dew_nullable == guest_nullable &&
      dew_exact == guest_exact &&
      core_same_packed_array_type(
        dew_arena, guest_arena, dew_concrete, guest_concrete,
      ) => {
      if concrete_guest_types[dew_concrete] >= 0 &&
        concrete_guest_types[dew_concrete] != guest_concrete {
        return false
      }
      concrete_guest_types[dew_concrete] = guest_concrete
      true
    }
    _ => dew == guest
  }
}

///|
fn core_is_nullable_eqref(value : @lib.ValType) -> Bool {
  value == @lib.ValType::eqref_null()
}

///|
fn core_is_moonbit_string_type(arena : CoreTypeArena, index : Int) -> Bool {
  if index < 0 || index >= arena.subtypes.length() {
    return false
  }
  match arena.subtypes[index].get_comptype() {
    @lib.ArrayCompType(field) =>
      match field.get_storage_type() {
        @lib.PackTypeStorageType(@lib.I16PackType) => true
        _ => false
      }
    _ => false
  }
}

///|
fn core_bind_signature(
  provider : String,
  export_name : String,
  dew_arena : CoreTypeArena,
  guest_arena : CoreTypeArena,
  dew_type : Int,
  guest_type : Int,
  marker_guest_types : Array[Int],
  concrete_guest_types : Array[Int],
) -> Result[Array[Int], CoreWasmLinkError] {
  let (dew_parameters, dew_results) = match
    core_function_comp_type(dew_arena, dew_type) {
    Some(value) => value
    None => return Err(CoreWasmSignatureMismatch(provider, export_name))
  }
  let (guest_parameters, guest_results) = match
    core_function_comp_type(guest_arena, guest_type) {
    Some(value) => value
    None => return Err(CoreWasmSignatureMismatch(provider, export_name))
  }
  if dew_parameters.length() != guest_parameters.length() ||
    dew_results.length() != guest_results.length() {
    return Err(CoreWasmSignatureMismatch(provider, export_name))
  }
  let parameter_adapters : Array[Int] = []
  for index in 0..<dew_parameters.length() {
    if core_is_nullable_eqref(dew_parameters[index]) {
      match core_ref_defined_type(guest_parameters[index]) {
        Some((false, _, concrete)) if core_is_moonbit_string_type(
            guest_arena, concrete,
          ) => {
          parameter_adapters.push(index)
          continue
        }
        _ => ()
      }
    }
    if !core_bind_value_type(
        dew_arena,
        guest_arena,
        dew_parameters[index],
        guest_parameters[index],
        marker_guest_types,
        concrete_guest_types,
      ) {
      return Err(CoreWasmSignatureMismatch(provider, export_name))
    }
  }
  for index in 0..<dew_results.length() {
    if !core_bind_value_type(
        dew_arena,
        guest_arena,
        dew_results[index],
        guest_results[index],
        marker_guest_types,
        concrete_guest_types,
      ) {
      return Err(CoreWasmSignatureMismatch(provider, export_name))
    }
  }
  Ok(parameter_adapters)
}

///|
fn core_make_sequential_indices(length : Int, base : Int) -> Array[Int] {
  let result = Array::make(length, -1)
  for index in 0..<length {
    result[index] = base + index
  }
  result
}

///|
fn core_append_defined_indices(
  target : Array[Int],
  imported : Int,
  defined : Int,
  base : Int,
) -> Unit {
  for index in 0..<defined {
    target[imported + index] = base + index
  }
}

///|
fn core_remap_comp_type(
  map : CoreWasmIndexMap,
  value : @lib.CompType,
) -> @lib.CompType {
  match value {
    @lib.ArrayCompType(field) =>
      @lib.CompType::array(core_remap_field_type(map, field))
    @lib.ContCompType(index) =>
      @lib.CompType::cont(core_remap_type_idx(map, index))
    @lib.FuncCompType(parameters, results) => {
      let mapped_parameters = []
      let mapped_results = []
      for parameter in parameters {
        mapped_parameters.push(core_remap_val_type(map, parameter))
      }
      for result in results {
        mapped_results.push(core_remap_val_type(map, result))
      }
      @lib.CompType::func(mapped_parameters, mapped_results)
    }
    @lib.StructCompType(fields) => {
      let mapped = []
      for field in fields {
        mapped.push(core_remap_field_type(map, field))
      }
      @lib.CompType::struct_(mapped)
    }
  }
}

///|
fn core_remap_subtype(
  map : CoreWasmIndexMap,
  value : @lib.SubType,
) -> @lib.SubType {
  match value {
    @lib.CompTypeSubType(metadata, composite) =>
      @lib.SubType::comp_type(core_remap_comp_type(map, composite), metadata~)
    @lib.SubType(final_, supers, metadata, composite) => {
      let mapped_supers = []
      for super_ in supers {
        mapped_supers.push(core_remap_type_idx(map, super_))
      }
      @lib.SubType::new(
        final_,
        mapped_supers,
        core_remap_comp_type(map, composite),
        metadata~,
      )
    }
  }
}

///|
fn core_remap_rec_group(
  map : CoreWasmIndexMap,
  value : @lib.RecType,
) -> @lib.RecType {
  match value {
    @lib.SingleRecType(type_) =>
      @lib.RecType::new(core_remap_subtype(map, type_))
    @lib.GroupRecType(types) => {
      let mapped = []
      for type_ in types {
        mapped.push(core_remap_subtype(map, type_))
      }
      @lib.RecType::group(mapped)
    }
  }
}

///|
fn core_remap_global_type(
  map : CoreWasmIndexMap,
  value : @lib.GlobalType,
) -> @lib.GlobalType {
  match value {
    @lib.GlobalType(type_, mutable_) =>
      @lib.GlobalType::new(core_remap_val_type(map, type_), mutable_)
  }
}

///|
fn core_remap_table_type(
  map : CoreWasmIndexMap,
  value : @lib.TableType,
) -> @lib.TableType {
  match value {
    @lib.TableType(type_, limits) =>
      @lib.TableType::new(core_remap_ref_type(map, type_), limits)
  }
}

///|
fn core_remap_tag_type(
  map : CoreWasmIndexMap,
  value : @lib.TagType,
) -> @lib.TagType {
  match value {
    @lib.TagType(type_) => @lib.TagType::new(core_remap_type_idx(map, type_))
  }
}

///|
fn core_remap_extern_type(
  map : CoreWasmIndexMap,
  value : @lib.ExternType,
) -> @lib.ExternType {
  match value {
    @lib.FuncExternType(type_) =>
      @lib.ExternType::func(core_remap_type_idx(map, type_))
    @lib.TableExternType(type_) =>
      @lib.ExternType::table(core_remap_table_type(map, type_))
    @lib.MemExternType(type_) => @lib.ExternType::mem(type_)
    @lib.GlobalExternType(type_) =>
      @lib.ExternType::global(core_remap_global_type(map, type_))
    @lib.TagExternType(type_) =>
      @lib.ExternType::tag(core_remap_tag_type(map, type_))
  }
}

///|
fn core_remap_func(map : CoreWasmIndexMap, value : @lib.Func) -> @lib.Func {
  match value {
    @lib.Func(locals, body) => {
      let mapped_locals = []
      for run in locals.runs() {
        mapped_locals.push(
          @lib.LocalRun::new(
            run.count(),
            core_remap_val_type(map, run.val_type()),
          ),
        )
      }
      @lib.Func::new(
        @lib.Locals::from_decl_runs_preserving_groups(mapped_locals),
        core_remap_expr(map, body),
      )
    }
  }
}

///|
fn core_remap_table(map : CoreWasmIndexMap, value : @lib.Table) -> @lib.Table {
  match value {
    @lib.Table(type_, init) =>
      @lib.Table::new(
        core_remap_table_type(map, type_),
        match init {
          Some(value) => Some(core_remap_expr(map, value))
          None => None
        },
      )
  }
}

///|
fn core_remap_global(
  map : CoreWasmIndexMap,
  value : @lib.Global,
) -> @lib.Global {
  match value {
    @lib.Global(type_, init) =>
      @lib.Global::new(
        core_remap_global_type(map, type_),
        core_remap_expr(map, init),
      )
  }
}

///|
fn core_remap_elem(map : CoreWasmIndexMap, value : @lib.Elem) -> @lib.Elem {
  match value {
    @lib.Elem(mode, kind) => {
      let mapped_mode = match mode {
        @lib.Active(table, offset) =>
          @lib.ElemMode::active(
            core_remap_table_idx(map, table),
            core_remap_expr(map, offset),
          )
        @lib.Declarative => @lib.ElemMode::declarative()
        @lib.Passive => @lib.ElemMode::passive()
      }
      let mapped_kind = match kind {
        @lib.FuncsElemKind(functions) => {
          let mapped = []
          for function_ in functions {
            mapped.push(core_remap_func_idx(map, function_))
          }
          @lib.ElemKind::funcs(mapped)
        }
        @lib.FuncExprsElemKind(expressions) => {
          let mapped = []
          for expression in expressions {
            mapped.push(core_remap_expr(map, expression))
          }
          @lib.ElemKind::func_exprs(mapped)
        }
        @lib.TypedExprsElemKind(type_, expressions) => {
          let mapped = []
          for expression in expressions {
            mapped.push(core_remap_expr(map, expression))
          }
          @lib.ElemKind::typed_exprs(core_remap_ref_type(map, type_), mapped)
        }
      }
      @lib.Elem::new(mapped_mode, mapped_kind)
    }
  }
}

///|
fn core_remap_data(map : CoreWasmIndexMap, value : @lib.Data) -> @lib.Data {
  match value {
    @lib.Data(mode, bytes) => {
      let mapped_mode = match mode {
        @lib.Active(memory, offset) =>
          @lib.DataMode::active(
            core_remap_mem_idx(map, memory),
            core_remap_expr(map, offset),
          )
        @lib.Passive => @lib.DataMode::passive()
      }
      @lib.Data::new(mapped_mode, bytes)
    }
  }
}

///|
fn core_remap_export(
  map : CoreWasmIndexMap,
  value : @lib.Export,
) -> @lib.Export {
  match value {
    @lib.Export(name, item) => {
      let mapped = match item {
        @lib.FuncExternIdx(index) =>
          @lib.ExternIdx::func(core_remap_func_idx(map, index))
        @lib.TableExternIdx(index) =>
          @lib.ExternIdx::table(core_remap_table_idx(map, index))
        @lib.MemExternIdx(index) =>
          @lib.ExternIdx::mem(core_remap_mem_idx(map, index))
        @lib.GlobalExternIdx(index) =>
          @lib.ExternIdx::global(core_remap_global_idx(map, index))
        @lib.TagExternIdx(index) =>
          @lib.ExternIdx::tag(core_remap_tag_idx(map, index))
      }
      @lib.Export::new(name, mapped)
    }
  }
}
