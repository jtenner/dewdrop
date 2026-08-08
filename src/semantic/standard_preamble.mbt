///|
pub struct ProgramFile {
  id : FileId
  path : String
  source : Bytes
  test_only : Bool
} derive(Eq, Debug)

///|
pub fn ProgramFile::new(id : FileId, source : Bytes) -> ProgramFile {
  { id, path: "", source, test_only: false }
}

///|
pub fn ProgramFile::named(
  id : FileId,
  path : String,
  source : Bytes,
) -> ProgramFile {
  { id, path, source, test_only: path.has_suffix("_test.dew") }
}

///|
let standard_preamble_file_capacity = 256

///|
pub fn make_program_file_id(
  module_id : ModuleId,
  manifest_index : Int,
) -> FileId {
  guard manifest_index >= 0 else { abort("negative manifest file index") }
  make_file_id(module_id, standard_preamble_file_capacity + manifest_index)
}

///|
fn standard_preamble_builtins_source() -> Bytes {
  b"pub builtin assert(condition: Bool, message: String) -> Unit = \"dew_assert\"\npub builtin unreachable() -> Never = \"dew_unreachable\"\npub builtin i32_add(left: I32, right: I32) -> I32 = \"i32_add\"\npub builtin i32_sub(left: I32, right: I32) -> I32 = \"i32_sub\"\npub builtin i32_lte(left: I32, right: I32) -> Bool = \"i32_lte\"\npub builtin swar32_from_bits(value: U32) -> Swar32 = \"swar32_from_bits\"\npub builtin swar32_to_bits(value: Swar32) -> U32 = \"swar32_to_bits\"\npub builtin swar32_and(left: Swar32, right: Swar32) -> Swar32 = \"swar32_and\"\npub builtin swar32_or(left: Swar32, right: Swar32) -> Swar32 = \"swar32_or\"\npub builtin swar32_xor(left: Swar32, right: Swar32) -> Swar32 = \"swar32_xor\"\npub builtin swar64_from_bits(value: U64) -> Swar64 = \"swar64_from_bits\"\npub builtin swar64_to_bits(value: Swar64) -> U64 = \"swar64_to_bits\"\npub builtin swar64_and(left: Swar64, right: Swar64) -> Swar64 = \"swar64_and\"\npub builtin swar64_or(left: Swar64, right: Swar64) -> Swar64 = \"swar64_or\"\npub builtin swar64_xor(left: Swar64, right: Swar64) -> Swar64 = \"swar64_xor\"\npub builtin v128_and(left: V128, right: V128) -> V128 = \"v128_and\"\npub builtin v128_or(left: V128, right: V128) -> V128 = \"v128_or\"\npub builtin v128_xor(left: V128, right: V128) -> V128 = \"v128_xor\"\n"
}

///|
fn standard_preamble_traits_source() -> Bytes {
  b"pub trait Add {\n  fn add(self, right: Self) -> Self\n}\npub trait Sub {\n  fn sub(self, right: Self) -> Self\n}\npub trait Lte {\n  fn lte(self, right: Self) -> Bool\n}\npub trait BitAnd {\n  fn bit_and(self, right: Self) -> Self\n}\npub trait BitOr {\n  fn bit_or(self, right: Self) -> Self\n}\npub trait BitXor {\n  fn bit_xor(self, right: Self) -> Self\n}\npub trait Eq {\n  fn eq(self, right: Self) -> Bool\n}\npub trait Ne {\n  fn ne(self, right: Self) -> Bool\n}\npub trait Lt {\n  fn lt(self, right: Self) -> Bool\n}\npub trait Gt {\n  fn gt(self, right: Self) -> Bool\n}\npub trait Gte {\n  fn gte(self, right: Self) -> Bool\n}\npub trait Shl {\n  fn shl(self, right: Self) -> Self\n}\npub trait Shr {\n  fn shr(self, right: Self) -> Self\n}\npub trait Mul {\n  fn mul(self, right: Self) -> Self\n}\npub trait Div {\n  fn div(self, right: Self) -> Self\n}\npub trait Rem {\n  fn rem(self, right: Self) -> Self\n}\npub trait Into<t> {\n  fn into(self) -> t\n}\n\npub trait Index<key, value> {\n  fn index(self, key: key) -> value\n}\n\npub trait IndexSet<key, value> {\n  fn index_set(self, key: key, value: value) -> Unit\n}\n\npub trait Hash {\n  fn hash(self) -> U64\n  fn hash_eq(self, right: Self) -> Bool\n}\n"
}

///|
fn standard_debug_preamble_source() -> Bytes {
  b"pub trait Debug {\n  fn debug(self) -> Unit\n}\n\nbuiltin __dew_debug_write(fd: U32, value: Bytes) -> U32 = \"dew_wasi_fd_write\"\nbuiltin __dew_debug_ignore(value: U32) -> Unit = \"dew_debug_ignore\"\nbuiltin __dew_debug_i8(value: I8) -> U32 = \"dew_debug_i8\"\nbuiltin __dew_debug_i16(value: I16) -> U32 = \"dew_debug_i16\"\nbuiltin __dew_debug_i32(value: I32) -> U32 = \"dew_debug_i32\"\nbuiltin __dew_debug_i64(value: I64) -> U32 = \"dew_debug_i64\"\nbuiltin __dew_debug_u8(value: U8) -> U32 = \"dew_debug_u8\"\nbuiltin __dew_debug_u16(value: U16) -> U32 = \"dew_debug_u16\"\nbuiltin __dew_debug_u32(value: U32) -> U32 = \"dew_debug_u32\"\nbuiltin __dew_debug_u64(value: U64) -> U32 = \"dew_debug_u64\"\nbuiltin __dew_debug_f32(value: F32) -> U32 = \"dew_debug_f32\"\nbuiltin __dew_debug_f64(value: F64) -> U32 = \"dew_debug_f64\"\nbuiltin __dew_debug_string(value: String) -> U32 = \"dew_debug_string\"\nbuiltin __dew_debug_bytes(value: Bytes) -> U32 = \"dew_debug_bytes\"\npub builtin debug<t: Debug>(value: t) -> Unit = \"dew_debug_dispatch\"\n\nimpl Debug for Unit {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_write(1u32, b\"()\"))\n  }\n}\n\nimpl Debug for Bool {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(if self {\n      __dew_debug_write(1u32, b\"true\")\n    } else {\n      __dew_debug_write(1u32, b\"false\")\n    })\n  }\n}\n\nimpl Debug for I8 {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_i8(self))\n  }\n}\n\nimpl Debug for I16 {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_i16(self))\n  }\n}\n\nimpl Debug for I32 {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_i32(self))\n  }\n}\n\nimpl Debug for I64 {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_i64(self))\n  }\n}\n\nimpl Debug for U8 {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_u8(self))\n  }\n}\n\nimpl Debug for U16 {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_u16(self))\n  }\n}\n\nimpl Debug for U32 {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_u32(self))\n  }\n}\n\nimpl Debug for U64 {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_u64(self))\n  }\n}\n\nimpl Debug for F32 {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_f32(self))\n  }\n}\n\nimpl Debug for F64 {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_f64(self))\n  }\n}\n\nimpl Debug for String {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_string(self))\n  }\n}\n\nimpl Debug for Bytes {\n  fn debug(self) -> Unit {\n    __dew_debug_ignore(__dew_debug_bytes(self))\n  }\n}\n"
}

///|
fn standard_preamble_i32_source() -> Bytes {
  b"impl Add for I32 {\n  fn add(self, right: I32) -> I32 {\n    i32_add(self, right)\n  }\n}\nimpl Sub for I32 {\n  fn sub(self, right: I32) -> I32 {\n    i32_sub(self, right)\n  }\n}\nimpl Lte for I32 {\n  fn lte(self, right: I32) -> Bool {\n    i32_lte(self, right)\n  }\n}\n"
}

///|
fn standard_preamble_packed_source() -> Bytes {
  b"impl Swar32 {\n  fn from_bits(value: U32) -> Swar32 {\n    swar32_from_bits(value)\n  }\n  fn to_bits(self) -> U32 {\n    swar32_to_bits(self)\n  }\n}\nimpl BitAnd for Swar32 {\n  fn bit_and(self, right: Swar32) -> Swar32 {\n    swar32_and(self, right)\n  }\n}\nimpl BitOr for Swar32 {\n  fn bit_or(self, right: Swar32) -> Swar32 {\n    swar32_or(self, right)\n  }\n}\nimpl BitXor for Swar32 {\n  fn bit_xor(self, right: Swar32) -> Swar32 {\n    swar32_xor(self, right)\n  }\n}\nimpl Swar64 {\n  fn from_bits(value: U64) -> Swar64 {\n    swar64_from_bits(value)\n  }\n  fn to_bits(self) -> U64 {\n    swar64_to_bits(self)\n  }\n}\nimpl BitAnd for Swar64 {\n  fn bit_and(self, right: Swar64) -> Swar64 {\n    swar64_and(self, right)\n  }\n}\nimpl BitOr for Swar64 {\n  fn bit_or(self, right: Swar64) -> Swar64 {\n    swar64_or(self, right)\n  }\n}\nimpl BitXor for Swar64 {\n  fn bit_xor(self, right: Swar64) -> Swar64 {\n    swar64_xor(self, right)\n  }\n}\nimpl BitAnd for V128 {\n  fn bit_and(self, right: V128) -> V128 {\n    v128_and(self, right)\n  }\n}\nimpl BitOr for V128 {\n  fn bit_or(self, right: V128) -> V128 {\n    v128_or(self, right)\n  }\n}\nimpl BitXor for V128 {\n  fn bit_xor(self, right: V128) -> V128 {\n    v128_xor(self, right)\n  }\n}\n"
}

///|
fn selected_standard_modules(
  files : Array[ProgramFile],
) -> (Int, Bool, Bool, Bool, Bool, Bool, Int) {
  let mut text_mask = 0
  let mut wasi = false
  let mut wasm_intrinsics = false
  let mut fixed_array = false
  let mut map = false
  let mut set = false
  let mut lane_mask = 0
  for file in files {
    let events = @parser.parse_bytes(file.source)
    let mut scanning = true
    while scanning {
      match events.next() {
        Some(@parser.Declaration(@parser.Import(import_))) =>
          if import_.wildcard &&
            import_.path.length() == 2 &&
            import_.path[0] == "dew" &&
            import_.path[1] == "std" {
            text_mask = 15
            wasi = true
            lane_mask = 1048575
            wasm_intrinsics = true
            fixed_array = true
            map = true
            set = true
          } else if import_.path.length() == 4 &&
            import_.path[0] == "dew" &&
            import_.path[1] == "std" &&
            import_.path[2] == "wasm" &&
            import_.path[3] == "intrinsics" {
            wasm_intrinsics = true
          } else if import_.path.length() == 3 &&
            import_.path[0] == "dew" &&
            import_.path[1] == "std" {
            match import_.path[2] {
              "string" => text_mask = text_mask | 1
              "string_builder" => text_mask = text_mask | 2
              "bytes_builder" => text_mask = text_mask | 4
              "bytes" => text_mask = text_mask | 8
              "wasi" => wasi = true
              "fixed_array" => fixed_array = true
              "map" => map = true
              "set" => set = true
              "i8x4" => lane_mask = lane_mask | 1
              "u8x4" => lane_mask = lane_mask | 2
              "i16x2" => lane_mask = lane_mask | 4
              "u16x2" => lane_mask = lane_mask | 8
              "i8x8" => lane_mask = lane_mask | 16
              "u8x8" => lane_mask = lane_mask | 32
              "i16x4" => lane_mask = lane_mask | 64
              "u16x4" => lane_mask = lane_mask | 128
              "i32x2" => lane_mask = lane_mask | 256
              "u32x2" => lane_mask = lane_mask | 512
              "i8x16" => lane_mask = lane_mask | 1024
              "u8x16" => lane_mask = lane_mask | 2048
              "i16x8" => lane_mask = lane_mask | 4096
              "u16x8" => lane_mask = lane_mask | 8192
              "i32x4" => lane_mask = lane_mask | 16384
              "u32x4" => lane_mask = lane_mask | 32768
              "i64x2" => lane_mask = lane_mask | 65536
              "u64x2" => lane_mask = lane_mask | 131072
              "f32x4" => lane_mask = lane_mask | 262144
              "f64x2" => lane_mask = lane_mask | 524288
              _ => ()
            }
          }
        Some(@parser.Diagnostic(_)) => ()
        Some(@parser.Declaration(_)) | None => scanning = false
      }
    }
  }
  (text_mask, wasi, wasm_intrinsics, fixed_array, map, set, lane_mask)
}

///|
fn CollectionBuilder::collect_standard_preamble(
  self : CollectionBuilder,
) -> Unit {
  let paths = [
    "__dew_preamble_builtins.dew", "__dew_preamble_traits.dew", "__dew_preamble_i32.dew",
    "__dew_preamble_packed.dew", "__dew_numeric_builtins.dew", "__dew_numeric_impls.dew",
    "__dew_memory_preamble.dew", "__dew_into_builtins.dew", "__dew_into_impls.dew",
    "__dew_swar_preamble.dew", "__dew_v128_preamble.dew", "__dew_debug_preamble.dew",
  ]
  let sources = [
    standard_preamble_builtins_source(),
    standard_preamble_traits_source(),
    standard_preamble_i32_source(),
    standard_preamble_packed_source(),
    standard_numeric_builtins_source(),
    standard_numeric_impls_source(),
    standard_memory_preamble_source(),
    standard_into_builtins_source(),
    standard_into_impls_source(),
    standard_swar_preamble_source(),
    standard_v128_preamble_source(),
    standard_debug_preamble_source(),
  ]
  for index, source in sources {
    self.collect_file_events(
      make_file_id(self.module_id, index),
      paths[index],
      source,
      @parser.parse_bytes(source),
    )
  }
  self.preamble_declaration_count = self.next_declaration_local
}

///|
/// Collects manifest-ordered files into one shared module namespace after the
/// implicit `dew.std.preamble` files. File IDs must match manifest order.
fn collect_program_files_with_optional_preamble(
  module_id : ModuleId,
  files : Array[ProgramFile],
  include_preamble : Bool,
) -> CollectedModule {
  let builder = CollectionBuilder::new(module_id)
  if include_preamble {
    builder.collect_standard_preamble()
  } else {
    builder.preamble_declaration_count = 0
  }
  for index, file in files {
    let expected = make_program_file_id(module_id, index)
    guard file.id == expected else {
      abort("program files are not in deterministic manifest order")
    }
    builder.current_file_test_only = file.test_only
    if file.test_only {
      builder.test_files.push(file.id)
    }
    builder.collect_file_events(
      file.id,
      file.path,
      file.source,
      @parser.parse_bytes(file.source),
    )
  }
  builder.finish()
}

///|
pub fn collect_program_files(
  module_id : ModuleId,
  files : Array[ProgramFile],
) -> CollectedModule {
  collect_program_files_with_optional_preamble(module_id, files, true)
}

///|
fn collect_program_files_with_frozen_standard_imports(
  module_id : ModuleId,
  files : Array[ProgramFile],
) -> CollectedModule {
  collect_program_files_with_optional_preamble(module_id, files, false)
}

///|
/// Collects the compiler-owned `dew.std.preamble` module before one user
/// file while preserving the user's original byte offsets.
pub fn collect_bytes_with_standard_preamble(
  module_id : ModuleId,
  source : Bytes,
) -> CollectedModule {
  collect_program_files(module_id, [
    ProgramFile::new(make_program_file_id(module_id, 0), source),
  ])
}

///|
/// Production-oriented byte entry point. Unlike the raw `collect_bytes` phase
/// helper, this includes Dew's compiler-owned `dew.std.preamble` module.
pub fn collect_program_bytes(
  module_id : ModuleId,
  source : Bytes,
) -> CollectedModule {
  collect_bytes_with_standard_preamble(module_id, source)
}

///|
/// Collects one synthetic `_test.dew` file for test runners and embedders.
pub fn collect_program_test_bytes(
  module_id : ModuleId,
  source : Bytes,
) -> CollectedModule {
  collect_program_files(module_id, [
    ProgramFile::named(
      make_program_file_id(module_id, 0),
      "input_test.dew",
      source,
    ),
  ])
}
