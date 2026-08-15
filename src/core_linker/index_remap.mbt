///|
priv struct CoreWasmIndexMap {
  type_indices : Array[Int]
  function_indices : Array[Int]
  table_indices : Array[Int]
  memory_indices : Array[Int]
  global_indices : Array[Int]
  tag_indices : Array[Int]
  element_indices : Array[Int]
  data_indices : Array[Int]
}

///|
fn core_remap_index(indices : Array[Int], index : UInt, space : String) -> UInt {
  let source = index.reinterpret_as_int()
  if source < 0 || source >= indices.length() || indices[source] < 0 {
    abort("invalid " + space + " index during Core Wasm link")
  }
  indices[source].reinterpret_as_uint()
}

///|
fn core_remap_type_idx(
  map : CoreWasmIndexMap,
  value : @lib.TypeIdx,
) -> @lib.TypeIdx {
  match value {
    @lib.RecIdx(index) => @lib.TypeIdx::rec(index)
    @lib.TypeIdx(index) =>
      @lib.TypeIdx::new(core_remap_index(map.type_indices, index, "type"))
  }
}

///|
fn core_remap_func_idx(
  map : CoreWasmIndexMap,
  value : @lib.FuncIdx,
) -> @lib.FuncIdx {
  match value {
    @lib.FuncIdx(index) =>
      @lib.FuncIdx::new(
        core_remap_index(map.function_indices, index, "function"),
      )
  }
}

///|
fn core_remap_table_idx(
  map : CoreWasmIndexMap,
  value : @lib.TableIdx,
) -> @lib.TableIdx {
  match value {
    @lib.TableIdx(index) =>
      @lib.TableIdx::new(core_remap_index(map.table_indices, index, "table"))
  }
}

///|
fn core_remap_mem_idx(
  map : CoreWasmIndexMap,
  value : @lib.MemIdx,
) -> @lib.MemIdx {
  match value {
    @lib.MemIdx(index) =>
      @lib.MemIdx::new(core_remap_index(map.memory_indices, index, "memory"))
  }
}

///|
fn core_remap_global_idx(
  map : CoreWasmIndexMap,
  value : @lib.GlobalIdx,
) -> @lib.GlobalIdx {
  match value {
    @lib.GlobalIdx(index) =>
      @lib.GlobalIdx::new(core_remap_index(map.global_indices, index, "global"))
  }
}

///|
fn core_remap_tag_idx(
  map : CoreWasmIndexMap,
  value : @lib.TagIdx,
) -> @lib.TagIdx {
  match value {
    @lib.TagIdx(index) =>
      @lib.TagIdx::new(core_remap_index(map.tag_indices, index, "tag"))
  }
}

///|
fn core_remap_elem_idx(
  map : CoreWasmIndexMap,
  value : @lib.ElemIdx,
) -> @lib.ElemIdx {
  match value {
    @lib.ElemIdx(index) =>
      @lib.ElemIdx::new(core_remap_index(map.element_indices, index, "element"))
  }
}

///|
fn core_remap_data_idx(
  map : CoreWasmIndexMap,
  value : @lib.DataIdx,
) -> @lib.DataIdx {
  match value {
    @lib.DataIdx(index) =>
      @lib.DataIdx::new(core_remap_index(map.data_indices, index, "data"))
  }
}

///|
fn core_remap_heap_type(
  map : CoreWasmIndexMap,
  value : @lib.HeapType,
) -> @lib.HeapType {
  match value {
    @lib.AbsHeapTypeHeapType(kind) => @lib.HeapType::abs(kind)
    @lib.SharedAbsHeapTypeHeapType(kind) => @lib.HeapType::shared_abs(kind)
    @lib.DefTypeHeapType(kind) => @lib.HeapType::def_type(kind)
    @lib.HeapType(index) => @lib.HeapType::new(core_remap_type_idx(map, index))
  }
}

///|
fn core_remap_ref_type(
  map : CoreWasmIndexMap,
  value : @lib.RefType,
) -> @lib.RefType {
  match value {
    @lib.AbsHeapTypeRefType(kind) => @lib.RefType::abs(kind)
    @lib.HeapTypeRefType(nullable, exact, heap) =>
      @lib.RefType::new(nullable, core_remap_heap_type(map, heap), exact~)
  }
}

///|
fn core_remap_val_type(
  map : CoreWasmIndexMap,
  value : @lib.ValType,
) -> @lib.ValType {
  match value {
    @lib.BotValType => @lib.ValType::bottom()
    @lib.NumTypeValType(kind) => @lib.ValType::num_type(kind)
    @lib.VecTypeValType => @lib.ValType::v128()
    @lib.RefTypeValType(reference) =>
      @lib.ValType::ref_type(core_remap_ref_type(map, reference))
  }
}

///|
fn core_remap_storage_type(
  map : CoreWasmIndexMap,
  value : @lib.StorageType,
) -> @lib.StorageType {
  match value {
    @lib.PackTypeStorageType(kind) => @lib.StorageType::pack_type(kind)
    @lib.ValTypeStorageType(type_) =>
      @lib.StorageType::val_type(core_remap_val_type(map, type_))
  }
}

///|
fn core_remap_field_type(
  map : CoreWasmIndexMap,
  value : @lib.FieldType,
) -> @lib.FieldType {
  match value {
    @lib.FieldType(storage, mutable_) =>
      @lib.FieldType::new(core_remap_storage_type(map, storage), mutable_)
  }
}

///|
fn core_remap_block_type(
  map : CoreWasmIndexMap,
  value : @lib.BlockType,
) -> @lib.BlockType {
  match value {
    @lib.VoidBlockType => @lib.BlockType::void_()
    @lib.TypeIdxBlockType(index) =>
      @lib.BlockType::type_idx(core_remap_type_idx(map, index))
    @lib.ValTypeBlockType(type_) =>
      @lib.BlockType::val_type(core_remap_val_type(map, type_))
  }
}

///|
fn core_remap_mem_arg(
  map : CoreWasmIndexMap,
  value : @lib.MemArg,
) -> @lib.MemArg {
  match value {
    @lib.MemArg(align, memory, offset) =>
      @lib.MemArg::new(
        align,
        match memory {
          Some(index) => Some(core_remap_mem_idx(map, index))
          None =>
            if map.memory_indices.length() == 0 || map.memory_indices[0] == 0 {
              None
            } else {
              Some(
                @lib.MemIdx::new(map.memory_indices[0].reinterpret_as_uint()),
              )
            }
        },
        offset,
      )
  }
}

///|
fn core_remap_catch(map : CoreWasmIndexMap, value : @lib.Catch) -> @lib.Catch {
  match value {
    @lib.Catch(tag, label) =>
      @lib.Catch::new(core_remap_tag_idx(map, tag), label)
    @lib.CatchRef(tag, label) =>
      @lib.Catch::ref_(core_remap_tag_idx(map, tag), label)
    @lib.CatchAll(label) => @lib.Catch::all(label)
    @lib.CatchAllRef(label) => @lib.Catch::all_ref(label)
  }
}

///|
fn core_remap_catches(
  map : CoreWasmIndexMap,
  values : Array[@lib.Catch],
) -> Array[@lib.Catch] {
  let result = []
  for value in values {
    result.push(core_remap_catch(map, value))
  }
  result
}

///|
fn core_remap_resume_handler(
  map : CoreWasmIndexMap,
  value : @lib.ResumeHandler,
) -> @lib.ResumeHandler {
  match value {
    @lib.ResumeOnLabel(tag, label) =>
      @lib.ResumeHandler::on_label(core_remap_tag_idx(map, tag), label)
    @lib.ResumeOnSwitch(tag) =>
      @lib.ResumeHandler::on_switch(core_remap_tag_idx(map, tag))
  }
}

///|
fn core_remap_resume_handlers(
  map : CoreWasmIndexMap,
  values : Array[@lib.ResumeHandler],
) -> Array[@lib.ResumeHandler] {
  let result = []
  for value in values {
    result.push(core_remap_resume_handler(map, value))
  }
  result
}

///|
fn core_remap_expr(map : CoreWasmIndexMap, value : @lib.Expr) -> @lib.Expr {
  match value {
    @lib.Expr(instructions) => {
      let result = []
      for instruction in instructions {
        result.push(core_remap_instruction(map, instruction))
      }
      @lib.Expr::new(result)
    }
  }
}

///|
fn core_remap_instructions(
  map : CoreWasmIndexMap,
  values : Array[@lib.Instruction],
) -> Array[@lib.Instruction] {
  let result = []
  for value in values {
    result.push(core_remap_instruction(map, value))
  }
  result
}

///|
fn core_remap_optional_instructions(
  map : CoreWasmIndexMap,
  values : Array[@lib.Instruction]?,
) -> Array[@lib.Instruction]? {
  match values {
    Some(items) => Some(core_remap_instructions(map, items))
    None => None
  }
}

///|
fn core_remap_optional_val_types(
  map : CoreWasmIndexMap,
  values : Array[@lib.ValType]?,
) -> Array[@lib.ValType]? {
  match values {
    Some(items) => {
      let result = []
      for value in items {
        result.push(core_remap_val_type(map, value))
      }
      Some(result)
    }
    None => None
  }
}

///|
fn core_remap_legacy_catches(
  map : CoreWasmIndexMap,
  values : Array[@lib.LegacyCatch],
) -> Array[@lib.LegacyCatch] {
  let result = []
  for value in values {
    result.push(
      match value {
        @lib.LegacyCatch(tag, body) =>
          @lib.LegacyCatch::tagged(
            core_remap_tag_idx(map, tag),
            core_remap_expr(map, body),
          )
        @lib.LegacyCatchAll(body) =>
          @lib.LegacyCatch::all(core_remap_expr(map, body))
      },
    )
  }
  result
}
