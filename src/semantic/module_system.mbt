///|
pub struct ManifestFile {
  path : String
  source : Bytes
} derive(Eq, Debug)

///|
pub fn ManifestFile::new(path : String, source : Bytes) -> ManifestFile {
  { path, source }
}

///|
pub struct ManifestModule {
  path : String
  files : Array[ManifestFile]
} derive(Eq, Debug)

///|
pub fn ManifestModule::new(
  path : String,
  files : Array[ManifestFile],
) -> ManifestModule {
  { path, files }
}

///|
pub struct ProgramManifest {
  modules : Array[ManifestModule]
} derive(Eq, Debug)

///|
pub fn ProgramManifest::new(modules : Array[ManifestModule]) -> ProgramManifest {
  { modules, }
}

///|
/// Exact logical standard-library source paths mapped to caller-provided bytes.
/// Missing entries use the portable generated bootstrap provider.
pub struct StandardLibrarySources {
  paths : Array[String]
  sources : Array[Bytes]
  lookup : Map[String, Int]
}

///|
pub fn StandardLibrarySources::new(
  files : Array[ManifestFile],
) -> StandardLibrarySources {
  let paths : Array[String] = []
  let sources : Array[Bytes] = []
  let lookup : Map[String, Int] = Map::default()
  for file in files {
    guard !lookup.contains(file.path) else {
      abort("duplicate standard-library source path")
    }
    lookup[file.path] = paths.length()
    paths.push(file.path)
    sources.push(file.source)
  }
  { paths, sources, lookup }
}

///|
pub fn StandardLibrarySources::bootstrap() -> StandardLibrarySources {
  StandardLibrarySources::new([])
}

///|
fn StandardLibrarySources::source_or(
  self : StandardLibrarySources,
  path : String,
  fallback : Bytes,
) -> Bytes {
  match self.lookup.get(path) {
    Some(index) => self.sources[index]
    None => fallback
  }
}

///|
pub enum ManifestDiagnostic {
  EmptyModulePath(Int)
  DuplicateModulePath(String, Int, Int)
  EmptyFilePath(Int, Int)
  DuplicateFilePath(String, Int, Int, Int)
} derive(Eq, Debug)

///|
pub struct CollectedProgram {
  module_id_base : ModuleId
  default_preamble : Bool
  module_paths : Array[String]
  module_lookup : Map[String, Int]
  modules : Array[CollectedModule]
  diagnostics : Array[ManifestDiagnostic]
}

///|
pub fn CollectedProgram::module_index(
  self : CollectedProgram,
  path : String,
) -> Int? {
  self.module_lookup.get(path)
}

///|
fn manifest_module_id(base : ModuleId, index : Int) -> ModuleId {
  let id = base + index.reinterpret_as_uint().to_uint64()
  guard id < 0xffff0000UL else {
    abort("manifest module ID overlaps compiler-owned standard modules")
  }
  id
}

///|
fn standard_library_module_id(slot : Int) -> ModuleId {
  guard slot >= 0 && slot < 256 else {
    abort("standard library module slot is outside the reserved range")
  }
  0xffff0000UL + slot.reinterpret_as_uint().to_uint64()
}

///|
pub fn standard_fixed_array_type_declaration() -> DeclId {
  make_semantic_id(standard_library_module_id(10), 0)
}

///|
fn standard_fixed_array_method_declaration(name : String) -> DeclId {
  let local_id = match name {
    "make" => 8
    "length" => 9
    "get" => 10
    "get_unchecked" => 11
    "set" => 12
    "set_unchecked" => 13
    _ => -1
  }
  if local_id < 0 {
    0UL
  } else {
    make_semantic_id(standard_library_module_id(10), local_id)
  }
}

///|
fn standard_fixed_array_index_declaration() -> DeclId {
  make_semantic_id(standard_library_module_id(10), 15)
}

///|
fn standard_fixed_array_index_set_declaration() -> DeclId {
  make_semantic_id(standard_library_module_id(10), 17)
}

///|
fn standard_fixed_array_callable_local(declaration : DeclId) -> Int {
  if semantic_id_module(declaration) == standard_library_module_id(10) {
    semantic_id_local(declaration)
  } else {
    -1
  }
}

///|
fn standard_fixed_array_operation(declaration : DeclId) -> Int {
  match standard_fixed_array_callable_local(declaration) {
    1 | 8 => 1
    2 | 9 => 2
    3 | 10 => 3
    4 | 11 | 15 => 4
    5 | 12 => 5
    6 | 13 | 17 => 6
    _ => 0
  }
}

///|
pub fn standard_map_type_declaration() -> DeclId {
  make_semantic_id(standard_library_module_id(11), 0)
}

///|
fn standard_map_method_declaration(name : String) -> DeclId {
  let local_id = match name {
    "singleton" => 9
    "length" => 10
    "get" => 11
    "get_unchecked" => 12
    "insert" => 13
    "set" => 14
    "contains_key" => 15
    "empty" => 16
    _ => -1
  }
  if local_id < 0 {
    0UL
  } else {
    make_semantic_id(standard_library_module_id(11), local_id)
  }
}

///|
fn standard_map_index_declaration() -> DeclId {
  make_semantic_id(standard_library_module_id(11), 18)
}

///|
fn standard_map_index_set_declaration() -> DeclId {
  make_semantic_id(standard_library_module_id(11), 20)
}

///|
fn standard_map_callable_local(declaration : DeclId) -> Int {
  if semantic_id_module(declaration) == standard_library_module_id(11) {
    semantic_id_local(declaration)
  } else {
    -1
  }
}

///|
fn standard_map_operation(declaration : DeclId) -> Int {
  match standard_map_callable_local(declaration) {
    1 | 9 => 1
    2 | 10 => 2
    3 | 11 => 3
    4 | 12 | 18 => 4
    5 | 13 => 5
    6 | 14 | 20 => 6
    7 | 15 => 7
    16 | 21 => 8
    _ => 0
  }
}

///|
pub fn standard_set_type_declaration() -> DeclId {
  make_semantic_id(standard_library_module_id(12), 0)
}

///|
fn standard_set_method_declaration(name : String) -> DeclId {
  let local_id = match name {
    "empty" => 10
    "singleton" => 11
    "length" => 12
    "is_empty" => 13
    "contains" => 14
    "insert" => 15
    "remove" => 16
    "clear" => 17
    _ => -1
  }
  if local_id < 0 {
    0UL
  } else {
    make_semantic_id(standard_library_module_id(12), local_id)
  }
}

///|
fn standard_set_callable_local(declaration : DeclId) -> Int {
  if semantic_id_module(declaration) == standard_library_module_id(12) {
    semantic_id_local(declaration)
  } else {
    -1
  }
}

///|
fn standard_set_operation(declaration : DeclId) -> Int {
  match standard_set_callable_local(declaration) {
    1 | 10 => 1
    2 | 11 => 2
    3 | 12 => 3
    4 | 13 => 4
    5 | 14 => 5
    6 | 15 => 6
    7 | 16 => 7
    8 | 17 => 8
    _ => 0
  }
}

///|
fn standard_option_type_declaration() -> DeclId {
  make_semantic_id(standard_library_module_id(2), 0)
}

///|
pub fn standard_option_none_variant() -> VariantId {
  make_semantic_id(standard_library_module_id(2), 0)
}

///|
pub fn standard_option_some_variant() -> VariantId {
  make_semantic_id(standard_library_module_id(2), 1)
}

///|
fn standard_lane_module_path(index : Int) -> String {
  match index {
    0 => "dew.std.i8x4"
    1 => "dew.std.u8x4"
    2 => "dew.std.i16x2"
    3 => "dew.std.u16x2"
    4 => "dew.std.i8x8"
    5 => "dew.std.u8x8"
    6 => "dew.std.i16x4"
    7 => "dew.std.u16x4"
    8 => "dew.std.i32x2"
    9 => "dew.std.u32x2"
    10 => "dew.std.i8x16"
    11 => "dew.std.u8x16"
    12 => "dew.std.i16x8"
    13 => "dew.std.u16x8"
    14 => "dew.std.i32x4"
    15 => "dew.std.u32x4"
    16 => "dew.std.i64x2"
    17 => "dew.std.u64x2"
    18 => "dew.std.f32x4"
    19 => "dew.std.f64x2"
    _ => abort("unknown standard lane module slot")
  }
}

///|
fn standard_preamble_source_paths() -> Array[String] {
  [
    "std/preamble/00-builtins.dew", "std/preamble/10-traits.dew", "std/preamble/20-i32.dew",
    "std/preamble/30-packed.dew", "std/preamble/40-numeric-builtins.dew", "std/preamble/50-numeric-impls.dew",
    "std/preamble/60-memory.dew", "std/preamble/70-into-builtins.dew", "std/preamble/80-into-impls.dew",
    "std/preamble/90-swar-core.dew", "std/preamble/100-v128.dew",
  ]
}

///|
/// Returns the complete canonical on-disk source registry without filesystem
/// enumeration. Callers resolve these paths beneath one selected `dew.std`
/// package directory.
pub fn standard_library_source_paths() -> Array[String] {
  let paths = standard_preamble_source_paths()
  paths.push("std/option.dew")
  paths.push("std/result.dew")
  paths.push("std/fixed_array.dew")
  paths.push("std/map.dew")
  paths.push("std/set.dew")
  paths.push("std/text_runtime.dew")
  paths.push("std/string.dew")
  paths.push("std/string_builder.dew")
  paths.push("std/bytes_builder.dew")
  paths.push("std/bytes.dew")
  paths.push("std/wasi.dew")
  paths.push("std/wasm/intrinsics.dew")
  for lane_index in 0..<20 {
    paths.push(
      "std/" + standard_lane_module_path(lane_index)[8:].to_owned() + ".dew",
    )
  }
  paths
}

///|
/// Computes the exact ordered source subset needed by one program. Selection
/// consumes only each file's leading import preamble and never enumerates disk.
pub fn required_standard_library_source_paths(
  manifest : ProgramManifest,
  default_preamble : Bool,
) -> Array[String] {
  let files : Array[ProgramFile] = []
  let mut next_file = 0
  let mut include_preamble = default_preamble
  let mut include_option = default_preamble
  let mut include_result = default_preamble
  for module_ in manifest.modules {
    for file in module_.files {
      files.push(
        ProgramFile::new(
          next_file.reinterpret_as_uint().to_uint64(),
          file.source,
        ),
      )
      next_file += 1
      let events = @parser.parse_bytes(file.source)
      let mut scanning = true
      while scanning {
        match events.next() {
          Some(@parser.Declaration(@parser.Import(import_))) =>
            if import_.wildcard &&
              import_.path.length() == 2 &&
              import_.path[0] == "dew" &&
              import_.path[1] == "std" {
              include_preamble = true
              include_option = true
              include_result = true
            } else if !import_.wildcard &&
              import_.path.length() == 3 &&
              import_.path[0] == "dew" &&
              import_.path[1] == "std" {
              match import_.path[2] {
                "preamble" => include_preamble = true
                "option" => include_option = true
                "result" => include_result = true
                _ => ()
              }
            }
          Some(@parser.Diagnostic(_)) => ()
          Some(@parser.Declaration(_)) | None => scanning = false
        }
      }
    }
  }
  let (
    text_mask,
    include_wasi,
    include_wasm_intrinsics,
    include_fixed_array,
    include_map,
    include_set,
    lane_mask,
  ) = selected_standard_modules(files)
  if text_mask != 0 ||
    include_wasi ||
    include_wasm_intrinsics ||
    include_fixed_array ||
    include_map ||
    include_set ||
    lane_mask != 0 {
    include_preamble = true
    include_option = true
    include_result = true
  } else if include_option || include_result {
    include_preamble = true
  }
  let required : Array[String] = []
  if include_preamble {
    for path in standard_preamble_source_paths() {
      required.push(path)
    }
  }
  if include_option {
    required.push("std/option.dew")
  }
  if include_result {
    required.push("std/result.dew")
  }
  if include_fixed_array {
    required.push("std/fixed_array.dew")
  }
  if include_map {
    required.push("std/map.dew")
  }
  if include_set {
    required.push("std/set.dew")
  }
  if text_mask != 0 {
    required.push("std/text_runtime.dew")
    let text_files = [
      "std/string.dew", "std/string_builder.dew", "std/bytes_builder.dew", "std/bytes.dew",
    ]
    for index, path in text_files {
      if (text_mask & (1 << index)) != 0 {
        required.push(path)
      }
    }
  }
  if include_wasi {
    required.push("std/wasi.dew")
  }
  if include_wasm_intrinsics {
    required.push("std/wasm/intrinsics.dew")
  }
  for lane_index in 0..<20 {
    if (lane_mask & (1 << lane_index)) != 0 {
      required.push(
        "std/" + standard_lane_module_path(lane_index)[8:].to_owned() + ".dew",
      )
    }
  }
  required
}

///|
fn standard_preamble_program_files(
  module_id : ModuleId,
  standard_sources : StandardLibrarySources,
) -> Array[ProgramFile] {
  let paths = standard_preamble_source_paths()
  let fallbacks = [
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
  ]
  let files : Array[ProgramFile] = []
  for index, path in paths {
    files.push(
      ProgramFile::named(
        make_program_file_id(module_id, index),
        path,
        standard_sources.source_or(path, fallbacks[index]),
      ),
    )
  }
  files
}

///|
fn standard_library_program_files(
  module_id : ModuleId,
  logical_path : String,
  source : Bytes,
  import_text_runtime : Bool,
  import_option : Bool,
) -> Array[ProgramFile] {
  let files : Array[ProgramFile] = []
  if import_text_runtime || import_option {
    let import_source = if import_text_runtime && import_option {
      b"open dew.std.text_runtime\nopen dew.std.option\n"
    } else if import_text_runtime {
      b"open dew.std.text_runtime\n"
    } else {
      b"open dew.std.option\n"
    }
    files.push(
      ProgramFile::named(
        make_program_file_id(module_id, 0),
        "__dew_std_imports.dew",
        import_source,
      ),
    )
  }
  files.push(
    ProgramFile::named(
      make_program_file_id(module_id, files.length()),
      logical_path,
      source,
    ),
  )
  files
}

///|
/// Collects modules and files in exact manifest order. Module IDs are the
/// caller-supplied base plus manifest index; file IDs use per-module manifest
/// order through `make_program_file_id`.
pub fn collect_program_manifest_with_standard_sources(
  module_id_base : ModuleId,
  manifest : ProgramManifest,
  standard_sources : StandardLibrarySources,
  default_preamble : Bool,
) -> CollectedProgram {
  let modules : Array[CollectedModule] = []
  let module_paths : Array[String] = []
  let diagnostics : Array[ManifestDiagnostic] = []
  let first_module : Map[String, Int] = Map::default()
  let mut selected_text_mask = 0
  let mut selected_wasi = false
  let mut selected_wasm_intrinsics = false
  let mut selected_fixed_array = false
  let mut selected_map = false
  let mut selected_set = false
  let mut selected_lane_mask = 0
  for module_index, module_ in manifest.modules {
    if module_.path.length() == 0 {
      diagnostics.push(EmptyModulePath(module_index))
    }
    match first_module.get(module_.path) {
      Some(first) =>
        diagnostics.push(DuplicateModulePath(module_.path, first, module_index))
      None => first_module[module_.path] = module_index
    }
    module_paths.push(module_.path)
    let first_file : Map[String, Int] = Map::default()
    let files : Array[ProgramFile] = []
    for file_index, file in module_.files {
      if file.path.length() == 0 {
        diagnostics.push(EmptyFilePath(module_index, file_index))
      }
      match first_file.get(file.path) {
        Some(first) =>
          diagnostics.push(
            DuplicateFilePath(file.path, module_index, first, file_index),
          )
        None => first_file[file.path] = file_index
      }
      let module_id = manifest_module_id(module_id_base, module_index)
      files.push(
        ProgramFile::named(
          make_program_file_id(module_id, file_index),
          file.path,
          file.source,
        ),
      )
    }
    let (
      text_mask,
      include_wasi,
      include_wasm_intrinsics,
      include_fixed_array,
      include_map,
      include_set,
      lane_mask,
    ) = selected_standard_modules(files)
    selected_text_mask = selected_text_mask | text_mask
    selected_wasi = selected_wasi || include_wasi
    selected_wasm_intrinsics = selected_wasm_intrinsics ||
      include_wasm_intrinsics
    selected_fixed_array = selected_fixed_array || include_fixed_array
    selected_map = selected_map || include_map
    selected_set = selected_set || include_set
    selected_lane_mask = selected_lane_mask | lane_mask
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        manifest_module_id(module_id_base, module_index),
        files,
      ),
    )
  }
  let preamble_module_id = standard_library_module_id(0)
  let preamble_module_index = modules.length()
  first_module["dew.std.preamble"] = preamble_module_index
  module_paths.push("dew.std.preamble")
  modules.push(
    collect_program_files_with_frozen_standard_imports(
      preamble_module_id,
      standard_preamble_program_files(preamble_module_id, standard_sources),
    ),
  )
  let option_module_id = standard_library_module_id(2)
  let option_module_index = modules.length()
  first_module["dew.std.option"] = option_module_index
  module_paths.push("dew.std.option")
  modules.push(
    collect_program_files_with_frozen_standard_imports(
      option_module_id,
      standard_library_program_files(
        option_module_id,
        "std/option.dew",
        standard_sources.source_or("std/option.dew", standard_option_source()),
        false,
        false,
      ),
    ),
  )
  let result_module_id = standard_library_module_id(8)
  let result_module_index = modules.length()
  first_module["dew.std.result"] = result_module_index
  module_paths.push("dew.std.result")
  modules.push(
    collect_program_files_with_frozen_standard_imports(
      result_module_id,
      standard_library_program_files(
        result_module_id,
        "std/result.dew",
        standard_sources.source_or("std/result.dew", standard_result_source()),
        false,
        false,
      ),
    ),
  )
  if selected_fixed_array {
    let module_id = standard_library_module_id(10)
    let module_index = modules.length()
    first_module["dew.std.fixed_array"] = module_index
    module_paths.push("dew.std.fixed_array")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id,
          "std/fixed_array.dew",
          standard_sources.source_or(
            "std/fixed_array.dew",
            standard_fixed_array_source(),
          ),
          false,
          false,
        ),
      ),
    )
  }
  if selected_map {
    let module_id = standard_library_module_id(11)
    let module_index = modules.length()
    first_module["dew.std.map"] = module_index
    module_paths.push("dew.std.map")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id,
          "std/map.dew",
          standard_sources.source_or("std/map.dew", standard_map_source()),
          false,
          false,
        ),
      ),
    )
  }
  if selected_set {
    let module_id = standard_library_module_id(12)
    let module_index = modules.length()
    first_module["dew.std.set"] = module_index
    module_paths.push("dew.std.set")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id,
          "std/set.dew",
          standard_sources.source_or("std/set.dew", standard_set_source()),
          false,
          false,
        ),
      ),
    )
  }
  let text_sources = standard_text_sources()
  if selected_text_mask != 0 {
    let module_id = standard_library_module_id(1)
    let module_index = modules.length()
    first_module["dew.std.text_runtime"] = module_index
    module_paths.push("dew.std.text_runtime")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id,
          "std/text_runtime.dew",
          standard_sources.source_or("std/text_runtime.dew", text_sources[0]),
          false,
          false,
        ),
      ),
    )
    let text_paths = [
      "dew.std.string", "dew.std.string_builder", "dew.std.bytes_builder", "dew.std.bytes",
    ]
    let text_files = [
      "std/string.dew", "std/string_builder.dew", "std/bytes_builder.dew", "std/bytes.dew",
    ]
    for source_index in 1..<text_sources.length() {
      if (selected_text_mask & (1 << (source_index - 1))) == 0 {
        continue
      }
      let module_id = standard_library_module_id(source_index + 2)
      let module_index = modules.length()
      first_module[text_paths[source_index - 1]] = module_index
      module_paths.push(text_paths[source_index - 1])
      modules.push(
        collect_program_files_with_frozen_standard_imports(
          module_id,
          standard_library_program_files(
            module_id,
            text_files[source_index - 1],
            standard_sources.source_or(
              text_files[source_index - 1],
              text_sources[source_index],
            ),
            true,
            source_index == 1 || source_index == 4,
          ),
        ),
      )
    }
  }
  if selected_wasi {
    let module_id = standard_library_module_id(7)
    let module_index = modules.length()
    first_module["dew.std.wasi"] = module_index
    module_paths.push("dew.std.wasi")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id,
          "std/wasi.dew",
          standard_sources.source_or("std/wasi.dew", standard_wasi_source()),
          false,
          false,
        ),
      ),
    )
  }
  if selected_wasm_intrinsics {
    let module_id = standard_library_module_id(9)
    let module_index = modules.length()
    first_module["dew.std.wasm.intrinsics"] = module_index
    module_paths.push("dew.std.wasm.intrinsics")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id,
          "std/wasm/intrinsics.dew",
          standard_sources.source_or(
            "std/wasm/intrinsics.dew",
            standard_wasm_intrinsics_source(),
          ),
          false,
          false,
        ),
      ),
    )
  }
  let lane_sources = standard_lane_sources()
  for lane_index, lane_source in lane_sources {
    if (selected_lane_mask & (1 << lane_index)) == 0 {
      continue
    }
    let module_id = standard_library_module_id(16 + lane_index)
    let path = standard_lane_module_path(lane_index)
    let module_index = modules.length()
    first_module[path] = module_index
    module_paths.push(path)
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id,
          "std/" + path[8:].to_owned() + ".dew",
          standard_sources.source_or(
            "std/" + path[8:].to_owned() + ".dew",
            lane_source,
          ),
          false,
          false,
        ),
      ),
    )
  }
  {
    module_id_base,
    default_preamble,
    module_paths,
    module_lookup: first_module,
    modules,
    diagnostics,
  }
}

///|
/// Collects with the portable generated bootstrap standard-library provider and
/// the ordinary implicit preamble/Option/Result imports.
pub fn collect_program_manifest(
  module_id_base : ModuleId,
  manifest : ProgramManifest,
) -> CollectedProgram {
  collect_program_manifest_with_standard_sources(
    module_id_base,
    manifest,
    StandardLibrarySources::bootstrap(),
    true,
  )
}

///|
pub enum ModuleGraphDiagnostic {
  MissingImportedModule(ModuleId, String, FileId, UInt64)
  DuplicateImportedModule(ModuleId, String, FileId, UInt64)
} derive(Eq, Debug)

///|
pub struct ModuleDependencyGraph {
  module_ids : Array[ModuleId]
  dependencies : Array[HirSpan]
  dependency_modules : Array[Int]
  sccs : Array[HirSpan]
  scc_modules : Array[Int]
  diagnostics : Array[ModuleGraphDiagnostic]
} derive(Eq, Debug)

///|
fn module_dependency_sccs(
  dependencies : Array[HirSpan],
  members : Array[Int],
) -> (Array[HirSpan], Array[Int]) {
  let count = dependencies.length()
  if count == 0 {
    return ([], [])
  }
  let visited = Array::make(count, false)
  let work : Array[Int] = []
  let finish_order : Array[Int] = []
  for start in 0..<count {
    if visited[start] {
      continue
    }
    work.push(start)
    while work.length() > 0 {
      let item = work.pop().unwrap()
      if item < 0 {
        finish_order.push(-item - 1)
        continue
      }
      if visited[item] {
        continue
      }
      visited[item] = true
      work.push(-item - 1)
      let edges = dependencies[item]
      let mut edge = edges.length
      while edge > 0 {
        edge -= 1
        let dependency = members[edges.start + edge]
        if !visited[dependency] {
          work.push(dependency)
        }
      }
    }
  }
  let reverse_counts = Array::make(count, 0)
  for source in 0..<count {
    let edges = dependencies[source]
    for edge in 0..<edges.length {
      reverse_counts[members[edges.start + edge]] += 1
    }
  }
  let reverse_offsets = Array::make(count + 1, 0)
  for index in 0..<count {
    reverse_offsets[index + 1] = reverse_offsets[index] + reverse_counts[index]
  }
  let reverse_cursor = Array::make(count, 0)
  for index in 0..<count {
    reverse_cursor[index] = reverse_offsets[index]
  }
  let reverse_edges = Array::make(reverse_offsets[count], 0)
  for source in 0..<count {
    let edges = dependencies[source]
    for edge in 0..<edges.length {
      let dependency = members[edges.start + edge]
      let destination = reverse_cursor[dependency]
      reverse_edges[destination] = source
      reverse_cursor[dependency] += 1
    }
  }
  let assigned = Array::make(count, false)
  let component : Array[Int] = []
  let raw_spans : Array[HirSpan] = []
  let raw_members : Array[Int] = []
  let mut order_index = finish_order.length()
  while order_index > 0 {
    order_index -= 1
    let start = finish_order[order_index]
    if assigned[start] {
      continue
    }
    component.clear()
    work.clear()
    work.push(start)
    assigned[start] = true
    while work.length() > 0 {
      let module_index = work.pop().unwrap()
      component.push(module_index)
      for
        edge in reverse_offsets[module_index]..<reverse_offsets[module_index + 1] {
        let dependent = reverse_edges[edge]
        if !assigned[dependent] {
          assigned[dependent] = true
          work.push(dependent)
        }
      }
    }
    component.sort()
    let component_start = raw_members.length()
    for module_index in component {
      raw_members.push(module_index)
    }
    raw_spans.push({
      start: component_start,
      length: raw_members.length() - component_start,
    })
  }
  let spans : Array[HirSpan] = []
  let ordered_members : Array[Int] = []
  let mut raw_index = raw_spans.length()
  while raw_index > 0 {
    raw_index -= 1
    let raw = raw_spans[raw_index]
    let start = ordered_members.length()
    for index in 0..<raw.length {
      ordered_members.push(raw_members[raw.start + index])
    }
    spans.push({ start, length: ordered_members.length() - start })
  }
  (spans, ordered_members)
}

///|
fn is_compiler_owned_ambient_import(path : String) -> Bool {
  path == "dew.std.preamble" ||
  path == "dew.std.option" ||
  path == "dew.std.result"
}

///|
fn wildcard_import_matches(prefix : String, candidate : String) -> Bool {
  candidate.has_prefix(prefix + ".") && candidate != "dew.std.text_runtime"
}

///|
fn import_diagnostic_path(import_ : CollectedImport) -> String {
  if import_.wildcard {
    import_.path + ".*"
  } else {
    import_.path
  }
}

///|
/// Resolves import paths to module indices and publishes dependency-first SCCs.
/// Embedded `dew.std` imports do not require manifest entries while the driver
/// still injects their compiler-owned declarations.
pub fn build_module_dependency_graph(
  program : CollectedProgram,
) -> ModuleDependencyGraph {
  let module_ids : Array[ModuleId] = []
  let dependencies : Array[HirSpan] = []
  let dependency_modules : Array[Int] = []
  let diagnostics : Array[ModuleGraphDiagnostic] = []
  let marks = Array::make(program.modules.length(), 0)
  let preamble_module = program.module_index("dew.std.preamble").unwrap()
  let option_module = program.module_index("dew.std.option").unwrap()
  let result_module = program.module_index("dew.std.result").unwrap()
  for module_index, module_ in program.modules {
    module_ids.push(module_.module_id)
    let start = dependency_modules.length()
    let local_dependencies : Array[Int] = []
    let generation = module_index + 1
    let defaults_enabled = program.default_preamble ||
      program.module_paths[module_index].has_prefix("dew.std.")
    if defaults_enabled && module_index != preamble_module {
      marks[preamble_module] = generation
      local_dependencies.push(preamble_module)
    }
    if defaults_enabled &&
      module_index != preamble_module &&
      module_index != option_module &&
      module_index != result_module {
      marks[option_module] = generation
      local_dependencies.push(option_module)
      marks[result_module] = generation
      local_dependencies.push(result_module)
    }
    for import_ in module_.imports {
      if defaults_enabled &&
        !import_.wildcard &&
        is_compiler_owned_ambient_import(import_.path) {
        continue
      }
      if import_.wildcard {
        let mut matched = false
        for dependency, candidate in program.module_paths {
          if dependency != module_index &&
            wildcard_import_matches(import_.path, candidate) {
            matched = true
            if marks[dependency] != generation {
              marks[dependency] = generation
              local_dependencies.push(dependency)
            }
          }
        }
        if !matched {
          diagnostics.push(
            MissingImportedModule(
              module_.module_id,
              import_diagnostic_path(import_),
              import_.file,
              import_.offset,
            ),
          )
        }
        continue
      }
      match program.module_index(import_.path) {
        Some(dependency) =>
          if marks[dependency] == generation {
            if dependency != preamble_module &&
              !import_.path.has_prefix("dew.std.") {
              diagnostics.push(
                DuplicateImportedModule(
                  module_.module_id,
                  import_.path,
                  import_.file,
                  import_.offset,
                ),
              )
            }
          } else {
            marks[dependency] = generation
            local_dependencies.push(dependency)
          }
        None =>
          diagnostics.push(
            MissingImportedModule(
              module_.module_id,
              import_.path,
              import_.file,
              import_.offset,
            ),
          )
      }
    }
    local_dependencies.sort()
    for dependency in local_dependencies {
      dependency_modules.push(dependency)
    }
    dependencies.push({ start, length: dependency_modules.length() - start })
  }
  let (sccs, scc_modules) = module_dependency_sccs(
    dependencies, dependency_modules,
  )
  {
    module_ids,
    dependencies,
    dependency_modules,
    sccs,
    scc_modules,
    diagnostics,
  }
}

///|
pub enum FrozenInterfaceDeclarationKind {
  FrozenTypeDeclaration
  FrozenTraitDeclaration
  FrozenValueDeclaration
} derive(Eq, Debug)

///|
pub struct FrozenInterfaceDeclaration {
  declaration : DeclId
  name : String
  kind : FrozenInterfaceDeclarationKind
  source_kind : CollectedDeclKind
  generic_parameter_count : Int
  generic_parameters : HirSpan
  semantic_type : ResolvedTypeId
  location : SourceLocation
} derive(Eq, Debug)

///|
pub enum FrozenInterfaceCallableKind {
  FrozenBuiltinCallable(Bytes)
  FrozenFunctionCallable
  FrozenTraitCallable(DeclId)
  FrozenImplCallable(DeclId)
} derive(Eq, Debug)

///|
pub struct FrozenInterfaceField {
  field : FieldId
  declaration : DeclId
  variant : VariantId?
  name : String
  type_ : ResolvedTypeId
  location : SourceLocation
} derive(Eq, Debug)

///|
pub struct FrozenInterfaceVariant {
  variant : VariantId
  declaration : DeclId
  kind : CollectedVariantKind
  name : String
  payload_types : HirSpan
  location : SourceLocation
} derive(Eq, Debug)

///|
pub struct FrozenInterfaceParameter {
  parameter : ParameterId
  name : String
  type_ : ResolvedTypeId
  shape : PlannedValueShape
  receiver : Bool
  location : SourceLocation
} derive(Eq, Debug)

///|
pub struct FrozenInterfaceCallable {
  declaration : DeclId
  name : String
  kind : FrozenInterfaceCallableKind
  generic_parameters : HirSpan
  parameters : HirSpan
  result_type : ResolvedTypeId
  result_shape : PlannedValueShape
  location : SourceLocation
} derive(Eq, Debug)

///|
pub struct FrozenInterfaceImplementation {
  declaration : DeclId
  trait_type : ResolvedTypeId
  target_type : ResolvedTypeId
  location : SourceLocation
} derive(Eq, Debug)

///|
pub struct FrozenModuleInterface {
  module_id : ModuleId
  path : String
  preamble_declaration_count : Int
  resolved_types : ResolvedModuleTypes
  declarations : Array[FrozenInterfaceDeclaration]
  fields : Array[FrozenInterfaceField]
  variants : Array[FrozenInterfaceVariant]
  variant_payload_types : Array[ResolvedTypeId]
  callables : Array[FrozenInterfaceCallable]
  parameters : Array[FrozenInterfaceParameter]
  implementations : Array[FrozenInterfaceImplementation]
} derive(Eq, Debug)

///|
fn frozen_declaration_semantic_type(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  declaration : CollectedDeclaration,
) -> ResolvedTypeId {
  if declaration.kind == TypeAliasDecl {
    for index, alias_info in collected.aliases {
      if alias_info.declaration == declaration.id {
        return resolved.alias_target_types[index]
      }
    }
  }
  resolved.declaration_type(declaration.id)
}

///|
fn frozen_declaration_kind(
  kind : CollectedDeclKind,
) -> FrozenInterfaceDeclarationKind {
  match kind {
    StructDecl | EnumDecl | TypeAliasDecl => FrozenTypeDeclaration
    TraitDecl => FrozenTraitDeclaration
    BuiltinDecl | LetDecl | FunctionDecl => FrozenValueDeclaration
    TestDecl => abort("test declarations are not module interface values")
    ImplDecl =>
      abort("impl declarations are evidence, not named interface declarations")
  }
}

///|
/// Freezes one public module interface without retaining parser ASTs or
/// executable body HIR. Resolved type IDs remain scoped by `module_id` and the
/// included immutable resolved-type arena.
pub fn freeze_module_interface(
  path : String,
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  functions : PlannedModuleFunctions,
) -> FrozenModuleInterface {
  guard collected.module_id == resolved.module_id &&
    collected.module_id == functions.module_id else {
    abort("module interface inputs belong to different modules")
  }
  let standard_module = path.has_prefix("dew.std.")
  let publish_standard_top_level = standard_module &&
    path != "dew.std.string" &&
    path != "dew.std.string_builder" &&
    path != "dew.std.bytes" &&
    path != "dew.std.bytes_builder"
  let declarations : Array[FrozenInterfaceDeclaration] = []
  let exported_declarations : Map[DeclId, Bool] = Map::default()
  for declaration in collected.declarations {
    if semantic_id_local(declaration.id) >= collected.preamble_declaration_count &&
      (publish_standard_top_level || declaration.visibility == Public) &&
      !collected.declaration_is_test_only(declaration.id) &&
      declaration.has_name() &&
      declaration.kind != ImplDecl {
      exported_declarations[declaration.id] = true
      declarations.push({
        declaration: declaration.id,
        name: collected.name(declaration.name),
        kind: frozen_declaration_kind(declaration.kind),
        source_kind: declaration.kind,
        generic_parameter_count: collected.generic_parameters_of(declaration.id).length,
        generic_parameters: collected.generic_parameters_of(declaration.id),
        semantic_type: frozen_declaration_semantic_type(
          collected, resolved, declaration,
        ),
        location: collected.declaration_location(declaration.id).unwrap(),
      })
    }
  }
  let fields : Array[FrozenInterfaceField] = []
  for field_index, field in collected.fields {
    if !exported_declarations.contains(field.declaration) {
      continue
    }
    fields.push({
      field: field.id,
      declaration: field.declaration,
      variant: field.variant,
      name: collected.name(field.name),
      type_: resolved.field_types[field_index],
      location: {
        file: collected.declaration_files[semantic_id_local(field.declaration)],
        offset: field.offset,
      },
    })
  }
  let variants : Array[FrozenInterfaceVariant] = []
  let variant_payload_types : Array[ResolvedTypeId] = []
  for variant_index, variant in collected.variants {
    if !exported_declarations.contains(variant.declaration) {
      continue
    }
    let payload_start = variant_payload_types.length()
    let payload = resolved.variant_payloads[variant_index]
    for index in 0..<payload.length {
      variant_payload_types.push(
        resolved.signature_type_lists[payload.start + index],
      )
    }
    variants.push({
      variant: variant.id,
      declaration: variant.declaration,
      kind: variant.kind,
      name: collected.name(variant.name),
      payload_types: {
        start: payload_start,
        length: variant_payload_types.length() - payload_start,
      },
      location: {
        file: collected.declaration_files[semantic_id_local(variant.declaration)],
        offset: variant.offset,
      },
    })
  }
  let parameters : Array[FrozenInterfaceParameter] = []
  let callables : Array[FrozenInterfaceCallable] = []
  for callable in functions.callables {
    if semantic_id_local(callable.declaration) <
      collected.preamble_declaration_count {
      continue
    }
    if collected.declaration_is_test_only(callable.declaration) {
      continue
    }
    let standard_impl_method = if standard_module {
      match callable.kind {
        PlannedImplMethodCallable(_, _) => true
        _ => false
      }
    } else {
      false
    }
    let exported = if publish_standard_top_level ||
      standard_impl_method ||
      callable.visibility == Public {
      true
    } else {
      match collected.declaration(callable.declaration) {
        Some(MethodReference(method_info)) =>
          if method_info.kind == TraitMethodDecl {
            match collected.declaration(method_info.parent) {
              Some(TopLevelReference(parent)) => parent.visibility == Public
              _ => false
            }
          } else {
            false
          }
        _ => false
      }
    }
    if !exported {
      continue
    }
    let parameter_start = parameters.length()
    for index in 0..<callable.parameters.length {
      let parameter = functions.parameters[callable.parameters.start + index]
      parameters.push({
        parameter: parameter.parameter,
        name: collected.name(
          collected.parameters[semantic_id_local(parameter.parameter)].name,
        ),
        type_: parameter.type_,
        shape: parameter.shape,
        receiver: parameter.receiver,
        location: {
          file: collected.declaration_files[semantic_id_local(
            parameter.declaration,
          )],
          offset: parameter.offset,
        },
      })
    }
    let kind = match callable.kind {
      PlannedBuiltinCallable(name) => FrozenBuiltinCallable(name)
      PlannedFunctionCallable(_) => FrozenFunctionCallable
      PlannedTraitMethodCallable(trait_) => FrozenTraitCallable(trait_)
      PlannedImplMethodCallable(implementation, _) =>
        FrozenImplCallable(implementation)
    }
    callables.push({
      declaration: callable.declaration,
      name: @utf8.decode_lossy(callable.name),
      kind,
      generic_parameters: callable.generic_parameters,
      parameters: {
        start: parameter_start,
        length: parameters.length() - parameter_start,
      },
      result_type: callable.result_type,
      result_shape: callable.result_shape,
      location: collected.declaration_location(callable.declaration).unwrap(),
    })
  }
  let implementations : Array[FrozenInterfaceImplementation] = []
  for implementation_index, implementation in collected.impls {
    if implementation.foreign_ ||
      collected.declaration_is_test_only(implementation.declaration) ||
      semantic_id_local(implementation.declaration) <
      collected.preamble_declaration_count {
      continue
    }
    implementations.push({
      declaration: implementation.declaration,
      trait_type: resolved.impl_trait_types[implementation_index],
      target_type: resolved.impl_target_types[implementation_index],
      location: collected
      .declaration_location(implementation.declaration)
      .unwrap(),
    })
  }
  {
    module_id: collected.module_id,
    path,
    preamble_declaration_count: collected.preamble_declaration_count,
    resolved_types: resolved,
    declarations,
    fields,
    variants,
    variant_payload_types,
    callables,
    parameters,
    implementations,
  }
}

///|
pub fn FrozenModuleInterface::declaration_named(
  self : FrozenModuleInterface,
  name : String,
  kind : FrozenInterfaceDeclarationKind,
) -> DeclId? {
  for declaration in self.declarations {
    if declaration.name == name && declaration.kind == kind {
      return Some(declaration.declaration)
    }
  }
  None
}

///|
pub fn FrozenModuleInterface::callables_named(
  self : FrozenModuleInterface,
  name : String,
) -> Array[FrozenInterfaceCallable] {
  let matches : Array[FrozenInterfaceCallable] = []
  for callable in self.callables {
    if callable.name == name {
      matches.push(callable)
    }
  }
  matches
}

///|
pub enum ImportScopeDiagnostic {
  UnavailableImportedInterface(ModuleId, String, FileId, UInt64)
  DuplicateImportedAlias(ModuleId, String, FileId, UInt64)
  AmbiguousImportedType(ModuleId, String, DeclId, DeclId)
  AmbiguousImportedTrait(ModuleId, String, DeclId, DeclId)
  AmbiguousImportedValue(ModuleId, String, DeclId, DeclId)
} derive(Eq, Debug)

///|
pub struct ImportedDeclarationBinding {
  declaration : DeclId
  source_kind : CollectedDeclKind
  generic_parameter_count : Int
  generic_parameters : HirSpan
  interface_index : Int
  semantic_type : ResolvedTypeId
} derive(Eq, Debug)

///|
pub struct ImportedCallableReference {
  interface_index : Int
  callable_index : Int
  mut next : Int
} derive(Eq, Debug)

///|
pub struct ImportedValueBinding {
  interface_index : Int
  head : Int
  mut tail : Int
  mut ambiguous : Bool
} derive(Eq, Debug)

///|
pub struct ModuleImportScope {
  module_id : ModuleId
  declarations : Array[ImportedDeclarationBinding]
  imported_interfaces : Array[Int]
  type_bindings : Map[String, Int]
  trait_bindings : Map[String, Int]
  value_bindings : Map[String, ImportedValueBinding]
  module_value_bindings : Array[Map[String, ImportedValueBinding]]
  callable_references : Array[ImportedCallableReference]
  alias_bindings : Map[String, Int]
  interfaces : Array[FrozenModuleInterface?]
  diagnostics : Array[ImportScopeDiagnostic]
}

///|
pub fn ModuleImportScope::lookup_type(
  self : ModuleImportScope,
  name : String,
) -> ImportedDeclarationBinding? {
  match self.type_bindings.get(name) {
    Some(index) if index >= 0 => Some(self.declarations[index])
    _ => None
  }
}

///|
pub fn ModuleImportScope::lookup_alias(
  self : ModuleImportScope,
  name : String,
) -> Int? {
  match self.alias_bindings.get(name) {
    Some(index) if index >= 0 => Some(index)
    _ => None
  }
}

///|
pub fn ModuleImportScope::lookup_module_callable(
  self : ModuleImportScope,
  interface_index : Int,
  name : String,
) -> Int? {
  guard interface_index >= 0 &&
    interface_index < self.module_value_bindings.length() else {
    return None
  }
  match self.module_value_bindings[interface_index].get(name) {
    Some(binding) if !binding.ambiguous => Some(binding.head)
    _ => None
  }
}

///|
pub fn ModuleImportScope::lookup_trait(
  self : ModuleImportScope,
  name : String,
) -> ImportedDeclarationBinding? {
  match self.trait_bindings.get(name) {
    Some(index) if index >= 0 => Some(self.declarations[index])
    _ => None
  }
}

///|
pub fn ModuleImportScope::type_is_ambiguous(
  self : ModuleImportScope,
  name : String,
) -> Bool {
  self.type_bindings.get(name).unwrap_or(-1) == -2
}

///|
pub fn ModuleImportScope::trait_is_ambiguous(
  self : ModuleImportScope,
  name : String,
) -> Bool {
  self.trait_bindings.get(name).unwrap_or(-1) == -2
}

///|
fn insert_imported_declaration(
  scope : ModuleImportScope,
  interface_index : Int,
  name : String,
  declaration : FrozenInterfaceDeclaration,
) -> Unit {
  let table = if declaration.kind == FrozenTraitDeclaration {
    scope.trait_bindings
  } else if declaration.kind == FrozenTypeDeclaration {
    scope.type_bindings
  } else {
    return
  }
  match table.get(name) {
    None => {
      let index = scope.declarations.length()
      scope.declarations.push({
        declaration: declaration.declaration,
        source_kind: declaration.source_kind,
        generic_parameter_count: declaration.generic_parameter_count,
        generic_parameters: declaration.generic_parameters,
        interface_index,
        semantic_type: declaration.semantic_type,
      })
      table[name] = index
    }
    Some(previous_index) if previous_index >= 0 => {
      let previous = scope.declarations[previous_index]
      if previous.declaration != declaration.declaration {
        table[name] = -2
        if declaration.kind == FrozenTraitDeclaration {
          scope.diagnostics.push(
            AmbiguousImportedTrait(
              scope.module_id,
              name,
              previous.declaration,
              declaration.declaration,
            ),
          )
        } else {
          scope.diagnostics.push(
            AmbiguousImportedType(
              scope.module_id,
              name,
              previous.declaration,
              declaration.declaration,
            ),
          )
        }
      }
    }
    _ => ()
  }
}

///|
fn expose_imported_value_binding(
  scope : ModuleImportScope,
  name : String,
  binding : ImportedValueBinding,
) -> Unit {
  match scope.value_bindings.get(name) {
    None =>
      scope.value_bindings[name] = {
        interface_index: binding.interface_index,
        head: binding.head,
        tail: binding.tail,
        ambiguous: false,
      }
    Some(opened) => {
      if opened.ambiguous {
        return
      }
      if opened.interface_index == binding.interface_index {
        opened.tail = binding.tail
        return
      }
      let previous_reference = scope.callable_references[opened.head]
      let next_reference = scope.callable_references[binding.head]
      let previous = scope.interfaces[previous_reference.interface_index].unwrap().callables[previous_reference.callable_index]
      let next = scope.interfaces[next_reference.interface_index].unwrap().callables[next_reference.callable_index]
      opened.ambiguous = true
      scope.diagnostics.push(
        AmbiguousImportedValue(
          scope.module_id,
          name,
          previous.declaration,
          next.declaration,
        ),
      )
    }
  }
}

///|
fn insert_imported_callable(
  scope : ModuleImportScope,
  interface_index : Int,
  callable_index : Int,
  callable : FrozenInterfaceCallable,
  open_names : Bool,
) -> Unit {
  match callable.kind {
    FrozenFunctionCallable | FrozenBuiltinCallable(_) => ()
    FrozenTraitCallable(_) | FrozenImplCallable(_) => return
  }
  let table = scope.module_value_bindings[interface_index]
  match table.get(callable.name) {
    None => {
      let candidate = scope.callable_references.length()
      scope.callable_references.push({
        interface_index,
        callable_index,
        next: -1,
      })
      let binding : ImportedValueBinding = {
        interface_index,
        head: candidate,
        tail: candidate,
        ambiguous: false,
      }
      table[callable.name] = binding
      if open_names {
        expose_imported_value_binding(scope, callable.name, binding)
      }
    }
    Some(binding) => {
      let candidate = scope.callable_references.length()
      scope.callable_references.push({
        interface_index,
        callable_index,
        next: -1,
      })
      scope.callable_references[binding.tail].next = candidate
      binding.tail = candidate
      if open_names {
        expose_imported_value_binding(scope, callable.name, binding)
      }
    }
  }
}

///|
fn open_frozen_interface_in_scope(
  scope : ModuleImportScope,
  interfaces : Array[FrozenModuleInterface?],
  dependency : Int,
) -> Unit {
  match interfaces[dependency] {
    Some(interface_) => {
      for declaration in interface_.declarations {
        insert_imported_declaration(
          scope,
          dependency,
          declaration.name,
          declaration,
        )
      }
      let table = scope.module_value_bindings[dependency]
      for name, binding in table {
        expose_imported_value_binding(scope, name, binding)
      }
    }
    None => ()
  }
}

///|
fn import_frozen_interface_into_scope(
  scope : ModuleImportScope,
  interfaces : Array[FrozenModuleInterface?],
  dependency : Int,
  open_names : Bool,
) -> Unit {
  scope.imported_interfaces.push(dependency)
  match interfaces[dependency] {
    Some(interface_) => {
      if open_names {
        for declaration in interface_.declarations {
          insert_imported_declaration(
            scope,
            dependency,
            declaration.name,
            declaration,
          )
        }
      }
      for callable_index, callable in interface_.callables {
        insert_imported_callable(
          scope, dependency, callable_index, callable, open_names,
        )
      }
    }
    None => ()
  }
}

///|
pub fn build_module_import_scope(
  program : CollectedProgram,
  interfaces : Array[FrozenModuleInterface?],
  module_index : Int,
) -> ModuleImportScope {
  guard module_index >= 0 && module_index < program.modules.length() else {
    abort("module import scope index is outside the manifest")
  }
  guard interfaces.length() == program.modules.length() else {
    abort("module import interfaces do not match the manifest")
  }
  let module_ = program.modules[module_index]
  let module_value_bindings : Array[Map[String, ImportedValueBinding]] = []
  for _ in program.modules {
    module_value_bindings.push(Map::default())
  }
  let scope : ModuleImportScope = {
    module_id: module_.module_id,
    declarations: [],
    imported_interfaces: [],
    type_bindings: Map::default(),
    trait_bindings: Map::default(),
    value_bindings: Map::default(),
    module_value_bindings,
    callable_references: [],
    alias_bindings: Map::default(),
    interfaces,
    diagnostics: [],
  }
  let imported = Array::make(program.modules.length(), false)
  let opened = Array::make(program.modules.length(), false)
  let preamble_module = program.module_index("dew.std.preamble").unwrap()
  let option_module = program.module_index("dew.std.option").unwrap()
  let result_module = program.module_index("dew.std.result").unwrap()
  let defaults_enabled = program.default_preamble ||
    program.module_paths[module_index].has_prefix("dew.std.")
  if defaults_enabled && module_index != preamble_module {
    imported[preamble_module] = true
    opened[preamble_module] = true
    import_frozen_interface_into_scope(scope, interfaces, preamble_module, true)
    if interfaces[preamble_module] is None {
      scope.diagnostics.push(
        UnavailableImportedInterface(
          module_.module_id,
          "dew.std.preamble",
          make_file_id(module_.module_id, 0),
          0UL,
        ),
      )
    }
  }
  if defaults_enabled &&
    module_index != preamble_module &&
    module_index != option_module &&
    module_index != result_module {
    imported[option_module] = true
    opened[option_module] = true
    import_frozen_interface_into_scope(scope, interfaces, option_module, true)
    imported[result_module] = true
    opened[result_module] = true
    import_frozen_interface_into_scope(scope, interfaces, result_module, true)
  }
  for import_ in module_.imports {
    if defaults_enabled &&
      import_.open_ &&
      !import_.wildcard &&
      is_compiler_owned_ambient_import(import_.path) {
      continue
    }
    if import_.wildcard {
      for dependency, candidate in program.module_paths {
        if dependency != module_index &&
          wildcard_import_matches(import_.path, candidate) {
          if imported[dependency] {
            if !opened[dependency] {
              opened[dependency] = true
              open_frozen_interface_in_scope(scope, interfaces, dependency)
            }
            continue
          }
          imported[dependency] = true
          opened[dependency] = true
          import_frozen_interface_into_scope(
            scope, interfaces, dependency, true,
          )
          if interfaces[dependency] is None {
            scope.diagnostics.push(
              UnavailableImportedInterface(
                module_.module_id,
                candidate,
                import_.file,
                import_.offset,
              ),
            )
          }
        }
      }
      continue
    }
    match program.module_index(import_.path) {
      Some(dependency) => {
        match import_.import_alias {
          Some(import_alias) =>
            match scope.alias_bindings.get(import_alias) {
              None => scope.alias_bindings[import_alias] = dependency
              Some(previous) if previous != dependency => {
                scope.alias_bindings[import_alias] = -1
                scope.diagnostics.push(
                  DuplicateImportedAlias(
                    module_.module_id,
                    import_alias,
                    import_.file,
                    import_.import_alias_offset,
                  ),
                )
              }
              _ => ()
            }
          None => ()
        }
        if imported[dependency] {
          if import_.open_ && !opened[dependency] {
            opened[dependency] = true
            open_frozen_interface_in_scope(scope, interfaces, dependency)
          }
          continue
        }
        imported[dependency] = true
        opened[dependency] = import_.open_
        import_frozen_interface_into_scope(
          scope,
          interfaces,
          dependency,
          import_.open_,
        )
        if interfaces[dependency] is None {
          scope.diagnostics.push(
            UnavailableImportedInterface(
              module_.module_id,
              import_.path,
              import_.file,
              import_.offset,
            ),
          )
        }
      }
      None => ()
    }
  }
  scope
}

///|
pub struct FrozenProgramInterfaces {
  graph : ModuleDependencyGraph
  interfaces : Array[FrozenModuleInterface]
  import_scopes : Array[ModuleImportScope]
  import_diagnostics : Array[ImportScopeDiagnostic]
}

///|
/// Resolves and freezes every manifest module in dependency-SCC order. The
/// returned interface array remains in manifest order for constant identity;
/// SCC order controls only job execution.
pub fn freeze_program_interfaces_with_cached(
  program : CollectedProgram,
  cached : Array[FrozenModuleInterface?],
) -> FrozenProgramInterfaces {
  guard cached.length() == program.modules.length() else {
    abort("cached interface slots do not match the collected program")
  }
  let graph = build_module_dependency_graph(program)
  let slots : Array[FrozenModuleInterface?] = Array::make(
    program.modules.length(),
    None,
  )
  let cached_slots = Array::make(program.modules.length(), false)
  for index, cached_interface in cached {
    match cached_interface {
      Some(interface_) => {
        guard interface_.module_id == program.modules[index].module_id &&
          interface_.path == program.module_paths[index] else {
          abort("cached interface identity does not match the collected module")
        }
        slots[index] = Some(interface_)
        cached_slots[index] = true
      }
      None => ()
    }
  }
  let scope_slots : Array[ModuleImportScope?] = Array::make(
    program.modules.length(),
    None,
  )
  let import_diagnostics : Array[ImportScopeDiagnostic] = []
  for scc in graph.sccs {
    for index in 0..<scc.length {
      let module_index = graph.scc_modules[scc.start + index]
      let collected = program.modules[module_index]
      let imports = build_module_import_scope(program, slots, module_index)
      scope_slots[module_index] = Some(imports)
      if !cached_slots[module_index] {
        let resolved = resolve_module_types_with_imports(collected, imports)
        let functions = plan_module_functions(collected, resolved)
        slots[module_index] = Some(
          freeze_module_interface(
            program.module_paths[module_index],
            collected,
            resolved,
            functions,
          ),
        )
      }
    }
    let mut repeat = scc.length > 1
    if !repeat {
      let module_index = graph.scc_modules[scc.start]
      let dependencies = graph.dependencies[module_index]
      for edge in 0..<dependencies.length {
        if graph.dependency_modules[dependencies.start + edge] == module_index {
          repeat = true
          break
        }
      }
    }
    for index in 0..<scc.length {
      let module_index = graph.scc_modules[scc.start + index]
      let collected = program.modules[module_index]
      let imports = if repeat {
        build_module_import_scope(program, slots, module_index)
      } else {
        scope_slots[module_index].unwrap()
      }
      if repeat && !cached_slots[module_index] {
        let resolved = resolve_module_types_with_imports(collected, imports)
        let functions = plan_module_functions(collected, resolved)
        slots[module_index] = Some(
          freeze_module_interface(
            program.module_paths[module_index],
            collected,
            resolved,
            functions,
          ),
        )
      }
      for diagnostic in imports.diagnostics {
        import_diagnostics.push(diagnostic)
      }
      scope_slots[module_index] = Some(imports)
    }
  }
  let interfaces : Array[FrozenModuleInterface] = []
  let import_scopes : Array[ModuleImportScope] = []
  for index in 0..<slots.length() {
    interfaces.push(slots[index].unwrap())
    import_scopes.push(scope_slots[index].unwrap())
  }
  { graph, interfaces, import_scopes, import_diagnostics }
}

///|
/// Resolves all interfaces without external cache inputs.
pub fn freeze_program_interfaces(
  program : CollectedProgram,
) -> FrozenProgramInterfaces {
  freeze_program_interfaces_with_cached(
    program,
    Array::make(program.modules.length(), None),
  )
}
