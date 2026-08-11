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
fn selected_standard_modules(
  files : Array[ProgramFile],
) -> (Int, Bool, Bool, Bool, Bool, Bool, Bool, Int, Int) {
  let mut text_mask = 0
  let mut wasi = false
  let mut wasm_intrinsics = false
  let mut fixed_array = false
  let mut array = false
  let mut map = false
  let mut set = false
  let mut collection_mask = 0
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
            array = true
            map = true
            set = true
            collection_mask = 3
          } else if import_.path.length() == 4 &&
            import_.path[0] == "dew" &&
            import_.path[1] == "std" &&
            import_.path[2] == "collections" {
            match import_.path[3] {
              "stack" => collection_mask = collection_mask | 1
              _ => ()
            }
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
              "array" => array = true
              "map" => map = true
              "set" => set = true
              "queue" => collection_mask = collection_mask | 2
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
  (
    text_mask, wasi, wasm_intrinsics, fixed_array, array, map, set, collection_mask,
    lane_mask,
  )
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
    @standard_sources.standard_preamble_builtins_source(),
    @standard_sources.standard_preamble_traits_source(),
    @standard_sources.standard_preamble_i32_source(),
    @standard_sources.standard_preamble_packed_source(),
    @standard_sources.standard_numeric_builtins_source(),
    @standard_sources.standard_numeric_impls_source(),
    @standard_sources.standard_memory_preamble_source(),
    @standard_sources.standard_into_builtins_source(),
    @standard_sources.standard_into_impls_source(),
    @standard_sources.standard_swar_preamble_source(),
    @standard_sources.standard_v128_preamble_source(),
    @standard_sources.standard_debug_preamble_source(),
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
fn collect_bytes_with_standard_preamble(
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
