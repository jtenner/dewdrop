///|
/// Stable module identity. Module IDs occupy the high 32 bits of every
/// semantic entity ID and must be assigned deterministically by the driver.
pub type ModuleId = UInt64

///|
/// Stable source-file identity. File IDs use the same packed module/local
/// representation as semantic IDs and are assigned in manifest order.
pub type FileId = UInt64

///|
pub fn make_file_id(module_id : ModuleId, local_index : Int) -> FileId {
  make_semantic_id(module_id, local_index)
}

///|
pub fn file_id_module(file : FileId) -> ModuleId {
  semantic_id_module(file)
}

///|
pub fn file_id_local(file : FileId) -> Int {
  semantic_id_local(file)
}

///|
pub struct SourceLocation {
  file : FileId
  offset : UInt64
} derive(Eq, Debug)

///|
/// Stable declaration identity. The low 32 bits are allocated in source order
/// within one module. Nested trait and impl methods share this sequence.
pub type DeclId = UInt64

///|
pub type FieldId = UInt64

///|
pub type VariantId = UInt64

///|
pub type GenericParameterId = UInt64

///|
pub type ParameterId = UInt64

///|
/// Stable executable-body identity. Body IDs use the same packed module/local
/// layout as declarations but have an independent local sequence.
pub type BodyId = UInt64

///|
/// Module-local interned name index.
pub type NameId = Int

///|
let semantic_id_mask : UInt64 = 0xffffffffUL

///|
fn make_semantic_id(module_id : ModuleId, local_index : Int) -> UInt64 {
  guard module_id <= semantic_id_mask else {
    abort("semantic module ID exceeds 32 bits")
  }
  guard local_index >= 0 else { abort("negative semantic local ID") }
  (module_id << 32) | local_index.reinterpret_as_uint().to_uint64()
}

///|
pub fn semantic_id_module(id : UInt64) -> ModuleId {
  id >> 32
}

///|
pub fn semantic_id_local(id : UInt64) -> Int {
  (id & semantic_id_mask).to_uint().reinterpret_as_int()
}
