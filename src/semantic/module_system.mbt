///|
pub struct ManifestFile {
  path : String
  source : Bytes
  parse_events : Array[@parser.ParseEvent]?
} derive(Eq, Debug)

///|
pub fn ManifestFile::new(path : String, source : Bytes) -> ManifestFile {
  { path, source, parse_events: None, }
}

///|
pub fn ManifestFile::with_parse_events(
  self : ManifestFile,
  parse_events : Array[@parser.ParseEvent],
) -> ManifestFile {
  { ..self, parse_events: Some(parse_events), }
}

///|
fn ManifestFile::events(self : ManifestFile) -> Iter[@parser.ParseEvent] {
  match self.parse_events {
    Some(events) => events.iter()
    None => @parser.parse_bytes(self.source)
  }
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
  { path, files, }
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
  parse_events : Array[Array[@parser.ParseEvent]?]
  lookup : Map[String, Int]
}

///|
pub fn StandardLibrarySources::new(
  files : Array[ManifestFile],
) -> StandardLibrarySources {
  let paths : Array[String] = []
  let sources : Array[Bytes] = []
  let parse_events : Array[Array[@parser.ParseEvent]?] = []
  let lookup : Map[String, Int] = Map::default()
  for file in files {
    guard !lookup.contains(file.path) else {
      abort("duplicate standard-library source path")
    }
    lookup[file.path] = paths.length()
    paths.push(file.path)
    sources.push(file.source)
    parse_events.push(file.parse_events)
  }
  { paths, sources, parse_events, lookup, }
}

///|
pub fn StandardLibrarySources::bootstrap() -> StandardLibrarySources {
  let files : Array[ManifestFile] = []
  for path in @standard_sources.standard_source_paths() {
    let source = match @standard_sources.bootstrap_standard_source(path) {
      Some(value) => value
      None => abort("bootstrap standard source registry is incomplete")
    }
    files.push(ManifestFile::new(path, source))
  }
  StandardLibrarySources::new(files)
}

///|
fn StandardLibrarySources::file(
  self : StandardLibrarySources,
  path : String,
) -> ManifestFile {
  match self.lookup.get(path) {
    Some(index) =>
      {
        path: self.paths[index],
        source: self.sources[index],
        parse_events: self.parse_events[index],
      }
    None =>
      match @standard_sources.bootstrap_standard_source(path) {
        Some(source) => ManifestFile::new(path, source)
        None => abort("standard source provider is missing \{path}")
      }
  }
}

///|
pub fn StandardLibrarySources::with_parse_events(
  self : StandardLibrarySources,
  parse_events : Array[Array[@parser.ParseEvent]?],
) -> StandardLibrarySources {
  guard parse_events.length() == self.sources.length() else {
    abort("standard source parse-event count mismatch")
  }
  { ..self, parse_events, }
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
  // The manifest prefix is followed by modules supplied by the source loader.
  manifest_module_count : Int
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
fn standard_preamble_source_paths() -> Array[String] {
  [
    "std/preamble/00-builtins.dew", "std/preamble/10-traits.dew", "std/preamble/20-i32.dew",
    "std/preamble/30-packed.dew", "std/preamble/40-numeric-builtins.dew", "std/preamble/50-numeric-impls.dew",
    "std/preamble/60-memory.dew", "std/preamble/70-into-builtins.dew", "std/preamble/80-into-impls.dew",
    "std/preamble/90-swar-core.dew", "std/preamble/100-v128.dew", "std/preamble/110-debug.dew",
  ]
}

///|
/// Returns the complete canonical on-disk source registry without filesystem
/// enumeration. Callers resolve these paths beneath one selected `dew.std`
/// package directory.
pub fn standard_library_source_paths() -> Array[String] {
  @standard_sources.standard_source_paths()
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
      let events = file.events()
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
    include_show,
    include_disposable,
    include_math,
    include_io,
    include_testing,
    include_wasi,
    include_wasm_intrinsics,
    include_fixed_array,
    include_array,
    include_map,
    include_set,
    collection_mask,
    facet_mask,
    lane_mask,
  ) = selected_standard_modules(files)
  if text_mask != 0 ||
    include_show ||
    include_disposable ||
    include_math ||
    include_io ||
    include_testing ||
    include_wasi ||
    include_wasm_intrinsics ||
    include_fixed_array ||
    include_array ||
    include_map ||
    include_set ||
    collection_mask != 0 ||
    facet_mask != 0 ||
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
  if include_fixed_array || include_array {
    required.push("std/fixed_array.dew")
  }
  if include_array {
    required.push("std/array.dew")
  }
  if include_map {
    required.push("std/map.dew")
  }
  if include_set {
    required.push("std/set.dew")
  }
  if (collection_mask & 1) != 0 {
    required.push("std/collections/stack.dew")
  }
  if (collection_mask & 2) != 0 {
    required.push("std/queue.dew")
  }
  if (collection_mask & 4) != 0 {
    required.push("std/collections/circular_buffer.dew")
  }
  if (collection_mask & 8) != 0 {
    required.push("std/collections/deque.dew")
  }
  if (collection_mask & 16) != 0 {
    required.push("std/ordering.dew")
  }
  if (collection_mask & 32) != 0 {
    required.push("std/collections/binary_heap.dew")
  }
  if (collection_mask & 64) != 0 {
    required.push("std/collections/priority_queue.dew")
  }
  if (collection_mask & 128) != 0 {
    required.push("std/collections/red_black_tree.dew")
  }
  if (collection_mask & 256) != 0 {
    required.push("std/collections/ordered_map.dew")
  }
  if (collection_mask & 512) != 0 {
    required.push("std/collections/ordered_set.dew")
  }
  if include_show {
    required.push("std/show.dew")
  }
  if include_disposable {
    required.push("std/disposable.dew")
  }
  if (collection_mask & 1024) != 0 {
    required.push("std/iter.dew")
  }
  if include_math {
    required.push("std/math.dew")
  }
  if include_io {
    required.push("std/io.dew")
  }
  if include_testing {
    required.push("std/testing.dew")
  }
  if (collection_mask & 2048) != 0 {
    required.push("std/json.dew")
  }
  if (collection_mask & 134217728) != 0 {
    required.push("std/encode.dew")
  }
  if (collection_mask & 268435456) != 0 {
    required.push("std/decode.dew")
  }
  if (collection_mask & 8388608) != 0 {
    required.push("std/format.dew")
  }
  if (collection_mask & 16777216) != 0 {
    required.push("std/semver.dew")
  }
  if (collection_mask & 33554432) != 0 {
    required.push("std/package.dew")
  }
  if (collection_mask & 67108864) != 0 {
    required.push("std/package/artifact.dew")
  }
  if (collection_mask & 4096) != 0 {
    required.push("std/bloom_filter.dew")
  }
  if (collection_mask & 8192) != 0 {
    required.push("std/blake3.dew")
  }
  if (collection_mask & 32768) != 0 {
    required.push("std/integrity/sha256.dew")
  }
  if (collection_mask & 65536) != 0 {
    required.push("std/path.dew")
  }
  if (collection_mask & 131072) != 0 {
    required.push("std/fs.dew")
  }
  if (collection_mask & 262144) != 0 {
    required.push("std/process.dew")
  }
  if (collection_mask & 524288) != 0 {
    required.push("std/fs/wasi.dew")
  }
  if (collection_mask & 2097152) != 0 {
    required.push("std/process/wasi.dew")
  }
  let facet_paths = [
    "std/facet.dew", "std/facet/imports.dew", "std/facet/core.dew", "std/facet/fs.dew",
    "std/facet/process.dew", "std/facet/clock.dew", "std/facet/random.dew", "std/facet/poll.dew",
    "std/facet/net.dew",
  ]
  for index, path in facet_paths {
    if (facet_mask & (1 << index)) != 0 {
      required.push(path)
    }
  }
  if text_mask != 0 {
    required.push("std/text_runtime.dew")
    let text_files = [
      "std/string.dew", "std/string_builder.dew", "std/bytes_builder.dew", "std/bytes.dew",
    ]
    for index, path in text_files {
      if (text_mask & (1 << index)) != 0 {
        required.push(path)
        if index == 0 {
          required.push("std/string_fixed_array.dew")
        }
      }
    }
    if (text_mask & 16) != 0 {
      required.push("std/text.dew")
    }
    if (text_mask & 32) != 0 {
      required.push("std/encoding/utf8.dew")
    }
  }
  if (collection_mask & (16384 | 524288 | 2097152)) != 0 {
    required.push("std/wasm/wasi.dew")
  }
  if include_wasi {
    required.push("std/wasi.dew")
  }
  if include_wasm_intrinsics ||
    include_fixed_array ||
    include_array ||
    collection_mask != 0 ||
    facet_mask != 0 {
    required.push("std/wasm/intrinsics.dew")
  }
  for lane_index in 0..<20 {
    if (lane_mask & (1 << lane_index)) != 0 {
      required.push(
        "std/" + standard_lane_module_path(lane_index)[8:].to_owned() + ".dew",
      )
    }
  }
  if standard_types_requested(files) || include_map {
    required.push("std/types.dew")
  }
  required
}

///|
fn standard_preamble_program_files(
  module_id : ModuleId,
  standard_sources : StandardLibrarySources,
) -> Array[ProgramFile] {
  let paths = standard_preamble_source_paths()
  let files : Array[ProgramFile] = []
  for index, path in paths {
    files.push(
      ProgramFile::from_manifest(
        make_program_file_id(module_id, index),
        standard_sources.file(path),
      ),
    )
  }
  files
}

///|
fn standard_library_program_files(
  module_id : ModuleId,
  logical_path : String,
  standard_sources : StandardLibrarySources,
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
    ProgramFile::from_manifest(
      make_program_file_id(module_id, files.length()),
      standard_sources.file(logical_path),
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
  let mut selected_show = false
  let mut selected_disposable = false
  let mut selected_math = false
  let mut selected_io = false
  let mut selected_testing = false
  let mut selected_wasi = false
  let mut selected_wasm_intrinsics = false
  let mut selected_fixed_array = false
  let mut selected_array = false
  let mut selected_map = false
  let mut selected_set = false
  let mut selected_collection_mask = 0
  let mut selected_facet_mask = 0
  let mut selected_lane_mask = 0
  let mut selected_types = false
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
        ProgramFile::from_manifest(
          make_program_file_id(module_id, file_index),
          file,
        ),
      )
    }
    let (
      text_mask,
      include_show,
      include_disposable,
      include_math,
      include_io,
      include_testing,
      include_wasi,
      include_wasm_intrinsics,
      include_fixed_array,
      include_array,
      include_map,
      include_set,
      collection_mask,
      facet_mask,
      lane_mask,
    ) = selected_standard_modules(files)
    selected_types = selected_types ||
      standard_types_requested(files) ||
      include_map
    selected_text_mask = selected_text_mask | text_mask
    selected_show = selected_show || include_show
    selected_disposable = selected_disposable || include_disposable
    selected_math = selected_math || include_math
    selected_io = selected_io || include_io
    selected_testing = selected_testing || include_testing
    selected_wasi = selected_wasi || include_wasi
    selected_wasm_intrinsics = selected_wasm_intrinsics ||
      include_wasm_intrinsics
    selected_fixed_array = selected_fixed_array ||
      include_fixed_array ||
      include_array ||
      collection_mask != 0
    selected_array = selected_array || include_array || collection_mask != 0
    selected_map = selected_map || include_map
    selected_set = selected_set || include_set
    selected_collection_mask = selected_collection_mask | collection_mask
    selected_facet_mask = selected_facet_mask | facet_mask
    selected_lane_mask = selected_lane_mask | lane_mask
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        manifest_module_id(module_id_base, module_index),
        files,
      ),
    )
  }
  if selected_fixed_array {
    selected_wasm_intrinsics = true
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
        option_module_id, "std/option.dew", standard_sources, false, false,
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
        result_module_id, "std/result.dew", standard_sources, false, false,
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
          module_id, "std/fixed_array.dew", standard_sources, false, true,
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
          module_id, "std/map.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if selected_array {
    let module_id = standard_library_module_id(13)
    let module_index = modules.length()
    first_module["dew.std.array"] = module_index
    module_paths.push("dew.std.array")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/array.dew", standard_sources, false, false,
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
          module_id, "std/set.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 1) != 0 {
    let module_id = standard_library_module_id(14)
    let module_index = modules.length()
    first_module["dew.std.collections.stack"] = module_index
    module_paths.push("dew.std.collections.stack")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/collections/stack.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 2) != 0 {
    let module_id = standard_library_module_id(15)
    let module_index = modules.length()
    first_module["dew.std.queue"] = module_index
    module_paths.push("dew.std.queue")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/queue.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 4) != 0 {
    let module_id = standard_library_module_id(36)
    let module_index = modules.length()
    first_module["dew.std.collections.circular_buffer"] = module_index
    module_paths.push("dew.std.collections.circular_buffer")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/collections/circular_buffer.dew", standard_sources, false,
          false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 8) != 0 {
    let module_id = standard_library_module_id(37)
    let module_index = modules.length()
    first_module["dew.std.collections.deque"] = module_index
    module_paths.push("dew.std.collections.deque")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/collections/deque.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 16) != 0 {
    let module_id = standard_library_module_id(38)
    let module_index = modules.length()
    first_module["dew.std.ordering"] = module_index
    module_paths.push("dew.std.ordering")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/ordering.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 32) != 0 {
    let module_id = standard_library_module_id(39)
    let module_index = modules.length()
    first_module["dew.std.collections.binary_heap"] = module_index
    module_paths.push("dew.std.collections.binary_heap")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/collections/binary_heap.dew", standard_sources, false,
          false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 64) != 0 {
    let module_id = standard_library_module_id(40)
    let module_index = modules.length()
    first_module["dew.std.collections.priority_queue"] = module_index
    module_paths.push("dew.std.collections.priority_queue")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/collections/priority_queue.dew", standard_sources, false,
          false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 128) != 0 {
    let module_id = standard_library_module_id(41)
    let module_index = modules.length()
    first_module["dew.std.collections.red_black_tree"] = module_index
    module_paths.push("dew.std.collections.red_black_tree")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/collections/red_black_tree.dew", standard_sources, false,
          false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 256) != 0 {
    let module_id = standard_library_module_id(42)
    let module_index = modules.length()
    first_module["dew.std.collections.ordered_map"] = module_index
    module_paths.push("dew.std.collections.ordered_map")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/collections/ordered_map.dew", standard_sources, false,
          false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 512) != 0 {
    let module_id = standard_library_module_id(43)
    let module_index = modules.length()
    first_module["dew.std.collections.ordered_set"] = module_index
    module_paths.push("dew.std.collections.ordered_set")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/collections/ordered_set.dew", standard_sources, false,
          false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 1024) != 0 {
    let module_id = standard_library_module_id(47)
    let module_index = modules.length()
    first_module["dew.std.iter"] = module_index
    module_paths.push("dew.std.iter")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/iter.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if selected_math {
    let module_id = standard_library_module_id(48)
    let module_index = modules.length()
    first_module["dew.std.math"] = module_index
    module_paths.push("dew.std.math")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/math.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if selected_io {
    let module_id = standard_library_module_id(49)
    let module_index = modules.length()
    first_module["dew.std.io"] = module_index
    module_paths.push("dew.std.io")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/io.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if selected_testing {
    let module_id = standard_library_module_id(50)
    let module_index = modules.length()
    first_module["dew.std.testing"] = module_index
    module_paths.push("dew.std.testing")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/testing.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 4096) != 0 {
    let module_id = standard_library_module_id(52)
    let module_index = modules.length()
    first_module["dew.std.bloom_filter"] = module_index
    module_paths.push("dew.std.bloom_filter")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/bloom_filter.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 8192) != 0 {
    let module_id = standard_library_module_id(53)
    let module_index = modules.length()
    first_module["dew.std.blake3"] = module_index
    module_paths.push("dew.std.blake3")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/blake3.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 32768) != 0 {
    let module_id = standard_library_module_id(55)
    let module_index = modules.length()
    first_module["dew.std.integrity.sha256"] = module_index
    module_paths.push("dew.std.integrity.sha256")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/integrity/sha256.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 65536) != 0 {
    let module_id = standard_library_module_id(56)
    let module_index = modules.length()
    first_module["dew.std.path"] = module_index
    module_paths.push("dew.std.path")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/path.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 131072) != 0 {
    let module_id = standard_library_module_id(57)
    let module_index = modules.length()
    first_module["dew.std.fs"] = module_index
    module_paths.push("dew.std.fs")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/fs.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 262144) != 0 {
    let module_id = standard_library_module_id(58)
    let module_index = modules.length()
    first_module["dew.std.process"] = module_index
    module_paths.push("dew.std.process")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/process.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 524288) != 0 {
    let module_id = standard_library_module_id(59)
    let module_index = modules.length()
    first_module["dew.std.fs.wasi"] = module_index
    module_paths.push("dew.std.fs.wasi")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/fs/wasi.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 2097152) != 0 {
    let module_id = standard_library_module_id(61)
    let module_index = modules.length()
    first_module["dew.std.process.wasi"] = module_index
    module_paths.push("dew.std.process.wasi")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/process/wasi.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  let facet_source_paths = [
    "std/facet.dew", "std/facet/imports.dew", "std/facet/core.dew", "std/facet/fs.dew",
    "std/facet/process.dew", "std/facet/clock.dew", "std/facet/random.dew", "std/facet/poll.dew",
    "std/facet/net.dew",
  ]
  let facet_module_paths = [
    "dew.std.facet", "dew.std.facet.imports", "dew.std.facet.core", "dew.std.facet.fs",
    "dew.std.facet.process", "dew.std.facet.clock", "dew.std.facet.random", "dew.std.facet.poll",
    "dew.std.facet.net",
  ]
  for index, source_path in facet_source_paths {
    if (selected_facet_mask & (1 << index)) != 0 {
      let module_id = standard_library_module_id(70 + index)
      let module_index = modules.length()
      first_module[facet_module_paths[index]] = module_index
      module_paths.push(facet_module_paths[index])
      modules.push(
        collect_program_files_with_frozen_standard_imports(
          module_id,
          standard_library_program_files(
            module_id, source_path, standard_sources, false, false,
          ),
        ),
      )
    }
  }
  if (selected_collection_mask & 2048) != 0 {
    let module_id = standard_library_module_id(51)
    let module_index = modules.length()
    first_module["dew.std.json"] = module_index
    module_paths.push("dew.std.json")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/json.dew", standard_sources, true, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 134217728) != 0 {
    let module_id = standard_library_module_id(67)
    let module_index = modules.length()
    first_module["dew.std.encode"] = module_index
    module_paths.push("dew.std.encode")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/encode.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 268435456) != 0 {
    let module_id = standard_library_module_id(68)
    let module_index = modules.length()
    first_module["dew.std.decode"] = module_index
    module_paths.push("dew.std.decode")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/decode.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 8388608) != 0 {
    let module_id = standard_library_module_id(63)
    let module_index = modules.length()
    first_module["dew.std.format"] = module_index
    module_paths.push("dew.std.format")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/format.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 16777216) != 0 {
    let module_id = standard_library_module_id(64)
    let module_index = modules.length()
    first_module["dew.std.semver"] = module_index
    module_paths.push("dew.std.semver")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/semver.dew", standard_sources, true, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 33554432) != 0 {
    let module_id = standard_library_module_id(65)
    let module_index = modules.length()
    first_module["dew.std.package"] = module_index
    module_paths.push("dew.std.package")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/package.dew", standard_sources, true, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & 67108864) != 0 {
    let module_id = standard_library_module_id(66)
    let module_index = modules.length()
    first_module["dew.std.package.artifact"] = module_index
    module_paths.push("dew.std.package.artifact")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/package/artifact.dew", standard_sources, true, false,
        ),
      ),
    )
  }
  if selected_text_mask != 0 {
    let module_id = standard_library_module_id(1)
    let module_index = modules.length()
    first_module["dew.std.text_runtime"] = module_index
    module_paths.push("dew.std.text_runtime")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/text_runtime.dew", standard_sources, false, false,
        ),
      ),
    )
    let text_paths = [
      "dew.std.string", "dew.std.string_builder", "dew.std.bytes_builder", "dew.std.bytes",
    ]
    let text_files = [
      "std/string.dew", "std/string_builder.dew", "std/bytes_builder.dew", "std/bytes.dew",
    ]
    for source_index in 1..<5 {
      if (selected_text_mask & (1 << (source_index - 1))) == 0 {
        continue
      }
      let module_id = standard_library_module_id(source_index + 2)
      let module_index = modules.length()
      first_module[text_paths[source_index - 1]] = module_index
      module_paths.push(text_paths[source_index - 1])
      let text_module_files = standard_library_program_files(
        module_id,
        text_files[source_index - 1],
        standard_sources,
        true,
        source_index == 1 || source_index == 4,
      )
      if source_index == 1 {
        text_module_files.push(
          ProgramFile::from_manifest(
            make_program_file_id(module_id, text_module_files.length()),
            standard_sources.file("std/string_fixed_array.dew"),
          ),
        )
      }
      modules.push(
        collect_program_files_with_frozen_standard_imports(
          module_id, text_module_files,
        ),
      )
    }
  }
  if (selected_text_mask & 16) != 0 {
    let module_id = standard_library_module_id(46)
    let module_index = modules.length()
    first_module["dew.std.text"] = module_index
    module_paths.push("dew.std.text")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/text.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_text_mask & 32) != 0 {
    let module_id = standard_library_module_id(69)
    let module_index = modules.length()
    first_module["dew.std.encoding.utf8"] = module_index
    module_paths.push("dew.std.encoding.utf8")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/encoding/utf8.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if selected_show {
    let module_id = standard_library_module_id(44)
    let module_index = modules.length()
    first_module["dew.std.show"] = module_index
    module_paths.push("dew.std.show")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/show.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if selected_disposable {
    let module_id = standard_library_module_id(45)
    let module_index = modules.length()
    first_module["dew.std.disposable"] = module_index
    module_paths.push("dew.std.disposable")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/disposable.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  if (selected_collection_mask & (16384 | 524288 | 2097152)) != 0 {
    let module_id = standard_library_module_id(54)
    let module_index = modules.length()
    first_module["dew.std.wasm.wasi"] = module_index
    module_paths.push("dew.std.wasm.wasi")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/wasm/wasi.dew", standard_sources, false, false,
        ),
      ),
    )
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
          module_id, "std/wasi.dew", standard_sources, false, false,
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
          module_id, "std/wasm/intrinsics.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  for lane_index in 0..<20 {
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
          standard_sources,
          false,
          false,
        ),
      ),
    )
  }
  if selected_types {
    let module_id = standard_library_module_id(79)
    first_module["dew.std.types"] = modules.length()
    module_paths.push("dew.std.types")
    modules.push(
      collect_program_files_with_frozen_standard_imports(
        module_id,
        standard_library_program_files(
          module_id, "std/types.dew", standard_sources, false, false,
        ),
      ),
    )
  }
  {
    module_id_base,
    default_preamble,
    manifest_module_count: manifest.modules.length(),
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
    spans.push({ start, length: ordered_members.length() - start, })
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
  candidate.has_prefix(prefix + ".") &&
  candidate != "dew.std.text_runtime" &&
  candidate != "dew.std.wasm.wasi"
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
    dependencies.push({ start, length: dependency_modules.length() - start, })
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
  mutable_ : Bool
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
  abi_fingerprint : String
  location : SourceLocation
} derive(Eq, Debug)

///|
pub struct FrozenInterfaceImplementation {
  declaration : DeclId
  generic_parameters : HirSpan
  trait_type : ResolvedTypeId
  target_type : ResolvedTypeId
  location : SourceLocation
} derive(Eq, Debug)

///|
pub struct FrozenInterfaceDependency {
  path : String
  content_fingerprint : String
} derive(Eq, Debug)

///|
pub struct FrozenModuleInterface {
  module_id : ModuleId
  path : String
  preamble_declaration_count : Int
  resolved_types : ResolvedModuleTypes
  generic_parameter_bounds : Array[HirSpan]
  declarations : Array[FrozenInterfaceDeclaration]
  declaration_abi_fingerprints : Array[String]
  fields : Array[FrozenInterfaceField]
  variants : Array[FrozenInterfaceVariant]
  variant_payload_types : Array[ResolvedTypeId]
  callables : Array[FrozenInterfaceCallable]
  parameters : Array[FrozenInterfaceParameter]
  implementations : Array[FrozenInterfaceImplementation]
  content_fingerprint : String
  interface_fingerprint : String
  dependencies : Array[FrozenInterfaceDependency]
} derive(Eq, Debug)

///|
fn callable_abi_write_int(output : Buffer, value : Int) -> Unit {
  let bits = value.reinterpret_as_uint()
  output.write_byte((bits & 0xffU).to_byte())
  output.write_byte(((bits >> 8) & 0xffU).to_byte())
  output.write_byte(((bits >> 16) & 0xffU).to_byte())
  output.write_byte(((bits >> 24) & 0xffU).to_byte())
}

///|
fn callable_abi_write_u64(output : Buffer, value : UInt64) -> Unit {
  for shift in 0..<8 {
    output.write_byte(((value >> (shift * 8)) & 0xffUL).to_byte())
  }
}

///|
fn callable_abi_write_string(output : Buffer, value : String) -> Unit {
  let bytes = Buffer()
  bytes.write_string_utf8(value)
  let encoded = bytes.to_bytes()
  callable_abi_write_int(output, encoded.length())
  output.write_bytes(encoded)
}

///|
fn callable_abi_write_shape(output : Buffer, shape : PlannedValueShape) -> Unit {
  let tag = match shape {
    UnitPlannedValueShape => 0
    NeverPlannedValueShape => 1
    I8PlannedValueShape => 2
    U8PlannedValueShape => 3
    I16PlannedValueShape => 4
    U16PlannedValueShape => 5
    I32PlannedValueShape => 6
    U32PlannedValueShape => 7
    I64PlannedValueShape => 8
    U64PlannedValueShape => 9
    F32PlannedValueShape => 10
    F64PlannedValueShape => 11
    RefPlannedValueShape => 12
    GenericPlannedValueShape => 13
    ErrorPlannedValueShape => 14
    V128PlannedValueShape => 15
    Swar32PlannedValueShape => 16
    Swar64PlannedValueShape => 17
    ProductPlannedValueShape(_) => 18
  }
  callable_abi_write_int(output, tag)
  match shape {
    ProductPlannedValueShape(fields) => {
      callable_abi_write_int(output, fields.length())
      for field in fields {
        callable_abi_write_shape(output, field)
      }
    }
    _ => ()
  }
}

///|
priv struct CallableAbiDeclarationIdentity {
  path : String
  name : String
  generic_parameter_count : Int
}

///|
fn callable_abi_declaration_identities(
  path : String,
  collected : CollectedModule,
  imports : ModuleImportScope?,
) -> Map[DeclId, CallableAbiDeclarationIdentity] {
  let identities : Map[DeclId, CallableAbiDeclarationIdentity] = Map::default()
  for value in collected.declarations {
    if value.has_name() {
      identities[value.id] = {
        path,
        name: collected.name(value.name),
        generic_parameter_count: collected.generic_parameters_of(value.id).length,
      }
    }
  }
  match imports {
    Some(scope) =>
      for candidate in scope.interfaces {
        match candidate {
          Some(interface_) =>
            for value in interface_.declarations {
              identities[value.declaration] = {
                path: interface_.path,
                name: value.name,
                generic_parameter_count: value.generic_parameter_count,
              }
            }
          None => ()
        }
      }
    None => ()
  }
  identities
}

///|
fn callable_abi_write_declaration_identity(
  output : Buffer,
  identities : Map[DeclId, CallableAbiDeclarationIdentity],
  declaration : DeclId,
) -> Unit {
  match identities.get(declaration) {
    Some(value) => {
      callable_abi_write_int(output, 0)
      callable_abi_write_string(output, value.path)
      callable_abi_write_string(output, value.name)
      callable_abi_write_int(output, value.generic_parameter_count)
    }
    None => {
      callable_abi_write_int(output, 1)
      callable_abi_write_u64(output, declaration)
    }
  }
}

///|
fn callable_abi_write_type(
  output : Buffer,
  identities : Map[DeclId, CallableAbiDeclarationIdentity],
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  generic_parameters : HirSpan,
) -> Unit {
  let types : Array[ResolvedTypeId] = [root]
  while types.length() > 0 {
    let current = types.pop().unwrap()
    if current < 0 || current >= resolved.types.length() {
      callable_abi_write_int(output, -1)
      continue
    }
    match resolved.types[current] {
      ErrorType => callable_abi_write_int(output, 0)
      MemberTypeProjection(owner, operation, selector) => {
        callable_abi_write_int(output, 9)
        callable_abi_write_int(output, operation.length())
        output.write_bytes(operation)
        let bytes = @utf8.encode(selector)
        callable_abi_write_int(output, bytes.length())
        output.write_bytes(bytes)
        types.push(owner)
      }
      PrimitiveType(primitive) => {
        callable_abi_write_int(output, 1)
        callable_abi_write_int(output, primitive.rank())
      }
      GenericParameterType(parameter) => {
        callable_abi_write_int(output, 2)
        let parameter_index = semantic_id_local(parameter)
        if parameter_index >= generic_parameters.start &&
          parameter_index < generic_parameters.start + generic_parameters.length {
          callable_abi_write_int(
            output,
            parameter_index - generic_parameters.start,
          )
        } else {
          callable_abi_write_int(output, -1)
          callable_abi_write_u64(output, parameter)
        }
      }
      NominalType(declaration) => {
        callable_abi_write_int(output, 3)
        callable_abi_write_declaration_identity(output, identities, declaration)
      }
      TraitType(declaration) => {
        callable_abi_write_int(output, 4)
        callable_abi_write_declaration_identity(output, identities, declaration)
      }
      SelfType(declaration) => {
        callable_abi_write_int(output, 5)
        callable_abi_write_declaration_identity(output, identities, declaration)
      }
      ProductType(fields) => {
        callable_abi_write_int(output, 8)
        callable_abi_write_int(output, fields.length)
        let mut index = fields.length
        while index > 0 {
          index -= 1
          types.push(resolved.type_arguments[fields.start + index])
        }
      }
      AppliedType(base, arguments) => {
        callable_abi_write_int(output, 6)
        callable_abi_write_int(output, arguments.length)
        let mut index = arguments.length
        while index > 0 {
          index -= 1
          types.push(resolved.type_arguments[arguments.start + index])
        }
        types.push(base)
      }
      FunctionType(parameters, result) => {
        callable_abi_write_int(output, 7)
        callable_abi_write_int(output, parameters.length)
        types.push(result)
        let mut index = parameters.length
        while index > 0 {
          index -= 1
          types.push(resolved.type_arguments[parameters.start + index])
        }
      }
    }
  }
}

///|
fn callable_abi_write_generic_bounds(
  output : Buffer,
  identities : Map[DeclId, CallableAbiDeclarationIdentity],
  resolved : ResolvedModuleTypes,
  generic_parameter_bounds : Array[HirSpan],
  generic_parameters : HirSpan,
) -> Unit {
  callable_abi_write_int(output, generic_parameters.length)
  for parameter_offset in 0..<generic_parameters.length {
    let parameter_index = generic_parameters.start + parameter_offset
    if parameter_index < 0 ||
      parameter_index >= generic_parameter_bounds.length() {
      callable_abi_write_int(output, 0)
      continue
    }
    let bounds = generic_parameter_bounds[parameter_index]
    callable_abi_write_int(output, bounds.length)
    for bound_offset in 0..<bounds.length {
      callable_abi_write_type(
        output,
        identities,
        resolved,
        resolved.generic_bound_types[bounds.start + bound_offset],
        generic_parameters,
      )
    }
  }
}

///|
fn frozen_callable_abi_fingerprint(
  path : String,
  identities : Map[DeclId, CallableAbiDeclarationIdentity],
  resolved : ResolvedModuleTypes,
  generic_parameter_bounds : Array[HirSpan],
  functions : PlannedModuleFunctions,
  callable : PlannedCallable,
) -> String {
  let output = Buffer(size_hint=256 + callable.parameters.length * 64)
  output.write_bytes(b"DEW_CALLABLE_ABI_V1\x00")
  output.write_bytes(b"DEW_ERASED_BOX_ABI_V1\x00")
  output.write_bytes(b"DEW_FLAT_CLOSURE_ABI_V1\x00")
  output.write_bytes(b"DEW_RUNTIME_TRAIT_EVIDENCE_ABI_V1\x00")
  callable_abi_write_string(output, path)
  callable_abi_write_string(output, @utf8.decode_lossy(callable.name))
  callable_abi_write_generic_bounds(
    output,
    identities,
    resolved,
    generic_parameter_bounds,
    callable.generic_parameters,
  )
  callable_abi_write_int(output, callable.parameters.length)
  for index in 0..<callable.parameters.length {
    let parameter = functions.parameters[callable.parameters.start + index]
    callable_abi_write_type(
      output,
      identities,
      resolved,
      parameter.type_,
      callable.generic_parameters,
    )
    callable_abi_write_shape(output, parameter.shape)
  }
  callable_abi_write_type(
    output,
    identities,
    resolved,
    callable.result_type,
    callable.generic_parameters,
  )
  callable_abi_write_shape(output, callable.result_shape)
  @crypto.bytes_to_hex_string(@crypto.sha256(output.to_bytes()))
}

///|
fn frozen_abi_collected_kind_rank(kind : CollectedDeclKind) -> Int {
  match kind {
    BuiltinDecl => 0
    LetDecl => 1
    TraitDecl => 2
    FunctionDecl => 3
    TestDecl => 4
    ImplDecl => 5
    StructDecl => 6
    EnumDecl => 7
    TypeAliasDecl => 8
    ForeignTypeDecl => 9
    ForeignLibraryDecl => 10
  }
}

///|
fn frozen_abi_variant_kind_rank(kind : CollectedVariantKind) -> Int {
  match kind {
    UnitVariantDecl => 0
    TupleVariantDecl => 1
    StructVariantDecl => 2
  }
}

///|
fn frozen_interface_declaration_identities(
  interfaces : Array[FrozenModuleInterface],
) -> Map[DeclId, CallableAbiDeclarationIdentity] {
  let identities : Map[DeclId, CallableAbiDeclarationIdentity] = Map::default()
  for interface_ in interfaces {
    for declaration in interface_.declarations {
      identities[declaration.declaration] = {
        path: interface_.path,
        name: declaration.name,
        generic_parameter_count: declaration.generic_parameter_count,
      }
    }
  }
  identities
}

///|
fn frozen_declaration_abi_fingerprint(
  interface_ : FrozenModuleInterface,
  identities : Map[DeclId, CallableAbiDeclarationIdentity],
  declaration : FrozenInterfaceDeclaration,
) -> String {
  let output = Buffer(size_hint=256)
  output.write_bytes(b"DEW_NOMINAL_DECLARATION_ABI_V1\x00")
  output.write_bytes(b"DEW_GENERIC_AGGREGATE_ABI_V1\x00")
  output.write_bytes(b"DEW_ENUM_SUBTYPE_ABI_V1\x00")
  output.write_bytes(b"DEW_ERASED_BOX_ABI_V1\x00")
  output.write_bytes(b"DEW_FLAT_CLOSURE_ABI_V1\x00")
  callable_abi_write_string(output, interface_.path)
  callable_abi_write_string(output, declaration.name)
  callable_abi_write_int(
    output,
    frozen_abi_collected_kind_rank(declaration.source_kind),
  )
  callable_abi_write_generic_bounds(
    output,
    identities,
    interface_.resolved_types,
    interface_.generic_parameter_bounds,
    declaration.generic_parameters,
  )
  callable_abi_write_type(
    output,
    identities,
    interface_.resolved_types,
    declaration.semantic_type,
    declaration.generic_parameters,
  )
  let mut field_count = 0
  for field in interface_.fields {
    if field.declaration == declaration.declaration {
      field_count += 1
    }
  }
  callable_abi_write_int(output, field_count)
  for field in interface_.fields {
    if field.declaration != declaration.declaration {
      continue
    }
    match field.variant {
      Some(variant) => {
        callable_abi_write_int(output, 1)
        callable_abi_write_u64(output, variant)
      }
      None => callable_abi_write_int(output, 0)
    }
    callable_abi_write_int(output, if field.mutable_ { 1 } else { 0 })
    callable_abi_write_string(output, field.name)
    callable_abi_write_type(
      output,
      identities,
      interface_.resolved_types,
      field.type_,
      declaration.generic_parameters,
    )
  }
  let mut variant_count = 0
  for variant in interface_.variants {
    if variant.declaration == declaration.declaration {
      variant_count += 1
    }
  }
  callable_abi_write_int(output, variant_count)
  for variant in interface_.variants {
    if variant.declaration != declaration.declaration {
      continue
    }
    callable_abi_write_int(output, frozen_abi_variant_kind_rank(variant.kind))
    callable_abi_write_string(output, variant.name)
    callable_abi_write_int(output, variant.payload_types.length)
    for index in 0..<variant.payload_types.length {
      callable_abi_write_type(
        output,
        identities,
        interface_.resolved_types,
        interface_.variant_payload_types[variant.payload_types.start + index],
        declaration.generic_parameters,
      )
    }
  }
  let mut requirement_count = 0
  for callable in interface_.callables {
    match callable.kind {
      FrozenTraitCallable(trait_) if trait_ == declaration.declaration =>
        requirement_count += 1
      _ => ()
    }
  }
  callable_abi_write_int(output, requirement_count)
  for callable in interface_.callables {
    match callable.kind {
      FrozenTraitCallable(trait_) if trait_ == declaration.declaration => {
        callable_abi_write_string(output, callable.name)
        callable_abi_write_string(output, callable.abi_fingerprint)
      }
      _ => ()
    }
  }
  @crypto.bytes_to_hex_string(@crypto.sha256(output.to_bytes()))
}

///|
fn frozen_interface_content_fingerprint(
  interface_ : FrozenModuleInterface,
  identities : Map[DeclId, CallableAbiDeclarationIdentity],
  declaration_fingerprints : Array[String],
) -> String {
  let output = Buffer(
    size_hint=128 +
      interface_.declarations.length() * 96 +
      interface_.callables.length() * 96 +
      interface_.implementations.length() * 128,
  )
  output.write_bytes(b"DEW_MODULE_INTERFACE_CONTENT_V1\x00")
  callable_abi_write_string(output, interface_.path)
  callable_abi_write_int(output, interface_.declarations.length())
  for index, declaration in interface_.declarations {
    callable_abi_write_string(output, declaration.name)
    callable_abi_write_string(output, declaration_fingerprints[index])
  }
  callable_abi_write_int(output, interface_.callables.length())
  for callable in interface_.callables {
    callable_abi_write_string(output, callable.name)
    callable_abi_write_string(output, callable.abi_fingerprint)
  }
  callable_abi_write_int(output, interface_.implementations.length())
  for implementation in interface_.implementations {
    callable_abi_write_generic_bounds(
      output,
      identities,
      interface_.resolved_types,
      interface_.generic_parameter_bounds,
      implementation.generic_parameters,
    )
    callable_abi_write_type(
      output,
      identities,
      interface_.resolved_types,
      implementation.trait_type,
      implementation.generic_parameters,
    )
    callable_abi_write_type(
      output,
      identities,
      interface_.resolved_types,
      implementation.target_type,
      implementation.generic_parameters,
    )
  }
  @crypto.bytes_to_hex_string(@crypto.sha256(output.to_bytes()))
}

///|
fn frozen_interface_with_content_fingerprint(
  interface_ : FrozenModuleInterface,
  identities : Map[DeclId, CallableAbiDeclarationIdentity],
) -> FrozenModuleInterface {
  let declaration_abi_fingerprints : Array[String] = []
  for declaration in interface_.declarations {
    declaration_abi_fingerprints.push(
      frozen_declaration_abi_fingerprint(interface_, identities, declaration),
    )
  }
  {
    ..interface_,
    declaration_abi_fingerprints,
    content_fingerprint: frozen_interface_content_fingerprint(
      interface_, identities, declaration_abi_fingerprints,
    ),
  }
}

///|
fn frozen_program_interface_fingerprint_with_records(
  module_index : Int,
  graph : ModuleDependencyGraph,
  record_order : Array[Int],
  records : Array[String],
) -> String {
  let reachable = Array::make(records.length(), false)
  let pending : Array[Int] = [module_index]
  let mut reachable_count = 0
  while pending.length() > 0 {
    let current = pending.pop().unwrap()
    if reachable[current] {
      continue
    }
    reachable[current] = true
    reachable_count += 1
    let dependencies = graph.dependencies[current]
    for index in 0..<dependencies.length {
      pending.push(graph.dependency_modules[dependencies.start + index])
    }
  }
  let output = Buffer(size_hint=64 + reachable_count * 96)
  output.write_bytes(b"DEW_MODULE_INTERFACE_GRAPH_V1\x00")
  for index in record_order {
    if reachable[index] {
      callable_abi_write_string(output, records[index])
    }
  }
  @crypto.bytes_to_hex_string(@crypto.sha256(output.to_bytes()))
}

///|
/// Recomputes declaration, content, dependency, and transitive graph
/// fingerprints for a manifest-indexed frozen interface set.
pub fn frozen_program_interfaces_with_fingerprints(
  graph : ModuleDependencyGraph,
  initial : Array[FrozenModuleInterface],
) -> Array[FrozenModuleInterface] {
  let identities = frozen_interface_declaration_identities(initial)
  let content : Array[FrozenModuleInterface] = []
  let records : Array[String] = []
  let record_order : Array[Int] = []
  for index, interface_ in initial {
    let interface_ = frozen_interface_with_content_fingerprint(
      interface_, identities,
    )
    content.push(interface_)
    records.push(interface_.path + "\u0000" + interface_.content_fingerprint)
    record_order.push(index)
  }
  record_order.sort_by(fn(left, right) { records[left].compare(records[right]) })
  let output : Array[FrozenModuleInterface] = []
  for module_index, interface_ in content {
    let dependency_indices : Array[Int] = []
    let dependencies = graph.dependencies[module_index]
    for index in 0..<dependencies.length {
      dependency_indices.push(
        graph.dependency_modules[dependencies.start + index],
      )
    }
    dependency_indices.sort_by(fn(left, right) {
      content[left].path.compare(content[right].path)
    })
    let frozen_dependencies : Array[FrozenInterfaceDependency] = []
    for dependency_index in dependency_indices {
      let dependency = content[dependency_index]
      frozen_dependencies.push({
        path: dependency.path,
        content_fingerprint: dependency.content_fingerprint,
      })
    }
    output.push({
      ..interface_,
      interface_fingerprint: frozen_program_interface_fingerprint_with_records(
        module_index, graph, record_order, records,
      ),
      dependencies: frozen_dependencies,
    })
  }
  output
}

///|
fn frozen_available_interfaces_with_fingerprints(
  graph : ModuleDependencyGraph,
  slots : Array[FrozenModuleInterface?],
) -> Array[FrozenModuleInterface?] {
  let available : Array[FrozenModuleInterface] = []
  for slot in slots {
    match slot {
      Some(interface_) => available.push(interface_)
      None => ()
    }
  }
  let identities = frozen_interface_declaration_identities(available)
  let content : Array[FrozenModuleInterface?] = Array::make(
    slots.length(),
    None,
  )
  for index, slot in slots {
    match slot {
      Some(interface_) =>
        content[index] = Some(
          frozen_interface_with_content_fingerprint(interface_, identities),
        )
      None => ()
    }
  }
  let output : Array[FrozenModuleInterface?] = Array::make(slots.length(), None)
  for module_index, slot in content {
    let interface_ = match slot {
      Some(value) => value
      None => continue
    }
    let dependency_indices : Array[Int] = []
    let dependencies = graph.dependencies[module_index]
    let mut complete = true
    for edge in 0..<dependencies.length {
      let dependency_index = graph.dependency_modules[dependencies.start + edge]
      if content[dependency_index] is None {
        complete = false
        break
      }
      dependency_indices.push(dependency_index)
    }
    if !complete {
      continue
    }
    dependency_indices.sort_by(fn(left, right) {
      content[left].unwrap().path.compare(content[right].unwrap().path)
    })
    let frozen_dependencies : Array[FrozenInterfaceDependency] = []
    for dependency_index in dependency_indices {
      let dependency = content[dependency_index].unwrap()
      frozen_dependencies.push({
        path: dependency.path,
        content_fingerprint: dependency.content_fingerprint,
      })
    }
    let reachable = Array::make(content.length(), false)
    let pending : Array[Int] = [module_index]
    let records : Array[String] = []
    while pending.length() > 0 {
      let current = pending.pop().unwrap()
      if reachable[current] {
        continue
      }
      let current_interface = match content[current] {
        Some(value) => value
        None => {
          complete = false
          break
        }
      }
      reachable[current] = true
      records.push(
        current_interface.path +
        "\u0000" +
        current_interface.content_fingerprint,
      )
      let current_dependencies = graph.dependencies[current]
      for edge in 0..<current_dependencies.length {
        pending.push(
          graph.dependency_modules[current_dependencies.start + edge],
        )
      }
    }
    if !complete {
      continue
    }
    records.sort()
    let fingerprint = Buffer(size_hint=64 + records.length() * 96)
    fingerprint.write_bytes(b"DEW_MODULE_INTERFACE_GRAPH_V1\x00")
    for record in records {
      callable_abi_write_string(fingerprint, record)
    }
    output[module_index] = Some({
      ..interface_,
      interface_fingerprint: @crypto.bytes_to_hex_string(
        @crypto.sha256(fingerprint.to_bytes()),
      ),
      dependencies: frozen_dependencies,
    })
  }
  output
}

///|
fn frozen_module_interface_with_available_fingerprints(
  graph : ModuleDependencyGraph,
  module_index : Int,
  slots : Array[FrozenModuleInterface?],
) -> FrozenModuleInterface {
  frozen_available_interfaces_with_fingerprints(graph, slots)[module_index].unwrap()
}

///|
fn frozen_body_type_to_resolved(
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleValues,
  root : BodyTypeId,
) -> ResolvedTypeId {
  match inferred.type_term(root) {
    BodyMemberTypeProjection(owner, operation, selector) => {
      let owner = frozen_body_type_to_resolved(resolved, inferred, owner)
      let projected = MemberTypeProjection(owner, operation, selector)
      for index, candidate in resolved.types {
        if candidate == projected {
          return index
        }
      }
      let index = resolved.types.length()
      resolved.types.push(projected)
      index
    }
    BodyErrorType | BodyVariableType(_) => resolved.error_type
    BodyResolvedType(type_) => type_
    BodyProductType(fields) => {
      let resolved_fields : Array[ResolvedTypeId] = []
      for index in 0..<fields.length {
        resolved_fields.push(
          frozen_body_type_to_resolved(
            resolved,
            inferred,
            inferred.type_arguments[fields.start + index],
          ),
        )
      }
      for index, existing in resolved.types {
        match existing {
          ProductType(candidate_fields) if candidate_fields.length ==
            resolved_fields.length() => {
            let mut same = true
            for field_index in 0..<candidate_fields.length {
              if resolved.type_arguments[candidate_fields.start + field_index] !=
                resolved_fields[field_index] {
                same = false
                break
              }
            }
            if same {
              return index
            }
          }
          _ => ()
        }
      }
      let start = resolved.type_arguments.length()
      for field in resolved_fields {
        resolved.type_arguments.push(field)
      }
      let result = resolved.types.length()
      resolved.types.push(
        ProductType({ start, length: resolved_fields.length(), }),
      )
      result
    }
    BodyAppliedType(base, arguments) => {
      let resolved_base = frozen_body_type_to_resolved(resolved, inferred, base)
      let resolved_arguments : Array[ResolvedTypeId] = []
      for index in 0..<arguments.length {
        resolved_arguments.push(
          frozen_body_type_to_resolved(
            resolved,
            inferred,
            inferred.type_arguments[arguments.start + index],
          ),
        )
      }
      for index, existing in resolved.types {
        match existing {
          AppliedType(candidate_base, candidate_arguments) if candidate_base ==
            resolved_base &&
            candidate_arguments.length == resolved_arguments.length() => {
            let mut same = true
            for argument_index in 0..<candidate_arguments.length {
              if resolved.type_arguments[candidate_arguments.start +
                argument_index] !=
                resolved_arguments[argument_index] {
                same = false
                break
              }
            }
            if same {
              return index
            }
          }
          _ => ()
        }
      }
      let start = resolved.type_arguments.length()
      for argument in resolved_arguments {
        resolved.type_arguments.push(argument)
      }
      let result = resolved.types.length()
      resolved.types.push(
        AppliedType(resolved_base, {
          start,
          length: resolved_arguments.length(),
        }),
      )
      result
    }
    BodyFunctionType(parameters, body_result) => {
      let resolved_parameters : Array[ResolvedTypeId] = []
      for index in 0..<parameters.length {
        resolved_parameters.push(
          frozen_body_type_to_resolved(
            resolved,
            inferred,
            inferred.type_arguments[parameters.start + index],
          ),
        )
      }
      let resolved_result = frozen_body_type_to_resolved(
        resolved, inferred, body_result,
      )
      for index, existing in resolved.types {
        match existing {
          FunctionType(candidate_parameters, candidate_result) if candidate_result ==
            resolved_result &&
            candidate_parameters.length == resolved_parameters.length() => {
            let mut same = true
            for parameter_index in 0..<candidate_parameters.length {
              if resolved.type_arguments[candidate_parameters.start +
                parameter_index] !=
                resolved_parameters[parameter_index] {
                same = false
                break
              }
            }
            if same {
              return index
            }
          }
          _ => ()
        }
      }
      let start = resolved.type_arguments.length()
      for parameter in resolved_parameters {
        resolved.type_arguments.push(parameter)
      }
      let result = resolved.types.length()
      resolved.types.push(
        FunctionType(
          { start, length: resolved_parameters.length(), },
          resolved_result,
        ),
      )
      result
    }
  }
}

///|
fn frozen_declaration_semantic_type(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  declaration : CollectedDeclaration,
  module_values : InferredModuleValues?,
) -> ResolvedTypeId {
  if declaration.kind == LetDecl {
    match module_values {
      Some(values) =>
        for let_index, candidate in values.let_declarations {
          if candidate == declaration.id {
            return frozen_body_type_to_resolved(
              resolved,
              values,
              values.let_types[let_index],
            )
          }
        }
      None => ()
    }
  }
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
    StructDecl | EnumDecl | TypeAliasDecl | ForeignTypeDecl =>
      FrozenTypeDeclaration
    TraitDecl => FrozenTraitDeclaration
    BuiltinDecl | LetDecl | FunctionDecl => FrozenValueDeclaration
    TestDecl => abort("test declarations are not module interface values")
    ImplDecl =>
      abort("impl declarations are evidence, not named interface declarations")
    ForeignLibraryDecl =>
      abort("foreign library namespaces are module-local link declarations")
  }
}

///|
fn frozen_interface_type_span_is_valid(
  values : Array[ResolvedTypeId],
  span : HirSpan,
) -> Bool {
  span.start >= 0 &&
  span.length >= 0 &&
  span.start <= values.length() &&
  span.length <= values.length() - span.start
}

///|
fn frozen_interface_impl_trait_head(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
) -> DeclId? {
  let mut type_ = root
  let mut remaining = resolved.types.length() + 1
  while remaining > 0 {
    if type_ < 0 || type_ >= resolved.types.length() {
      return None
    }
    remaining -= 1
    match resolved.types[type_] {
      TraitType(declaration) => return Some(declaration)
      AppliedType(base, arguments) => {
        if !frozen_interface_type_span_is_valid(
            resolved.type_arguments,
            arguments,
          ) {
          return None
        }
        type_ = base
      }
      _ => return None
    }
  }
  None
}

///|
fn frozen_interface_impl_target_head(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
) -> ImplTargetHead? {
  let mut type_ = root
  let mut remaining = resolved.types.length() + 1
  while remaining > 0 {
    if type_ < 0 || type_ >= resolved.types.length() {
      return None
    }
    remaining -= 1
    match resolved.types[type_] {
      PrimitiveType(primitive) =>
        return Some(PrimitiveImplTargetHead(primitive))
      NominalType(declaration) =>
        return Some(NominalImplTargetHead(declaration))
      AppliedType(base, arguments) => {
        if !frozen_interface_type_span_is_valid(
            resolved.type_arguments,
            arguments,
          ) {
          return None
        }
        type_ = base
      }
      _ => return None
    }
  }
  None
}

///|
fn frozen_interface_implementation_evidence_error(
  interface_ : FrozenModuleInterface,
) -> String? {
  for implementation in interface_.implementations {
    if implementation.trait_type < 0 {
      continue
    }
    if semantic_id_module(implementation.declaration) != interface_.module_id ||
      implementation.generic_parameters.start < 0 ||
      implementation.generic_parameters.length < 0 ||
      implementation.generic_parameters.start >
      interface_.generic_parameter_bounds.length() ||
      implementation.generic_parameters.length >
      interface_.generic_parameter_bounds.length() -
      implementation.generic_parameters.start {
      return Some(
        "frozen-interface cache contains invalid implementation evidence",
      )
    }
    let target_head = match
      frozen_interface_impl_target_head(
        interface_.resolved_types,
        implementation.target_type,
      ) {
      Some(value) => value
      None =>
        return Some(
          "frozen-interface cache contains invalid implementation evidence",
        )
    }
    let trait_declaration = match
      frozen_interface_impl_trait_head(
        interface_.resolved_types,
        implementation.trait_type,
      ) {
      Some(value) => value
      None =>
        return Some(
          "frozen-interface cache contains invalid implementation evidence",
        )
    }
    if !trait_impl_is_package_owned(
        interface_.module_id,
        trait_declaration,
        target_head,
      ) {
      return Some(
        "frozen-interface cache contains orphan implementation evidence",
      )
    }
  }
  None
}

///|
fn frozen_impl_type_is_visible(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  exported : Map[DeclId, Bool],
) -> Bool {
  let mut current = root
  while true {
    if current < 0 || current >= resolved.types.length() {
      return false
    }
    match resolved.types[current] {
      NominalType(declaration) | TraitType(declaration) =>
        return semantic_id_module(declaration) != resolved.module_id ||
          exported.contains(declaration)
      MemberTypeProjection(owner, _, _) => current = owner
      ProductType(fields) => {
        for index in 0..<fields.length {
          if !frozen_impl_type_is_visible(
              resolved,
              resolved.type_arguments[fields.start + index],
              exported,
            ) {
            return false
          }
        }
        return true
      }
      AppliedType(base, arguments) => {
        for index in 0..<arguments.length {
          if !frozen_impl_type_is_visible(
              resolved,
              resolved.type_arguments[arguments.start + index],
              exported,
            ) {
            return false
          }
        }
        current = base
      }
      FunctionType(parameters, result) => {
        for index in 0..<parameters.length {
          if !frozen_impl_type_is_visible(
              resolved,
              resolved.type_arguments[parameters.start + index],
              exported,
            ) {
            return false
          }
        }
        return frozen_impl_type_is_visible(resolved, result, exported)
      }
      ErrorType => return false
      PrimitiveType(_) | GenericParameterType(_) | SelfType(_) => return true
    }
  }
  false
}

///|
/// Freezes one public module interface without retaining parser ASTs or
/// executable body HIR. Resolved type IDs remain scoped by `module_id` and the
/// included immutable resolved-type arena.
fn freeze_module_interface(
  path : String,
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  functions : PlannedModuleFunctions,
  module_values? : InferredModuleValues? = None,
  imports? : ModuleImportScope? = None,
) -> FrozenModuleInterface {
  guard collected.module_id == resolved.module_id &&
    collected.module_id == functions.module_id else {
    abort("module interface inputs belong to different modules")
  }
  let publish_standard_top_level = frozen_module_publishes_standard_top_level(
    path,
  )
  let declarations : Array[FrozenInterfaceDeclaration] = []
  let exported_declarations : Map[DeclId, Bool] = Map::default()
  for declaration in collected.declarations {
    if semantic_id_local(declaration.id) >= collected.preamble_declaration_count &&
      (publish_standard_top_level || declaration.visibility == Public) &&
      !collected.declaration_is_test_only(declaration.id) &&
      declaration.has_name() &&
      declaration.kind != ImplDecl &&
      declaration.kind != ForeignLibraryDecl {
      exported_declarations[declaration.id] = true
      declarations.push({
        declaration: declaration.id,
        name: collected.name(declaration.name),
        kind: frozen_declaration_kind(declaration.kind),
        source_kind: declaration.kind,
        generic_parameter_count: collected.generic_parameters_of(declaration.id).length,
        generic_parameters: collected.generic_parameters_of(declaration.id),
        semantic_type: frozen_declaration_semantic_type(
          collected, resolved, declaration, module_values,
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
      mutable_: field.mutable_,
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
  let evidence_visible_declarations : Map[DeclId, Bool] = Map::default()
  for declaration, _ in exported_declarations {
    evidence_visible_declarations[declaration] = true
  }
  for declaration in collected.declarations {
    if semantic_id_local(declaration.id) < collected.preamble_declaration_count {
      evidence_visible_declarations[declaration.id] = true
    }
  }
  let exported_implementations : Map[DeclId, Bool] = Map::default()
  for implementation_index, implementation in collected.impls {
    if implementation.foreign_ ||
      collected.declaration_is_test_only(implementation.declaration) ||
      semantic_id_local(implementation.declaration) <
      collected.preamble_declaration_count {
      continue
    }
    let trait_type = resolved.impl_trait_types[implementation_index]
    if trait_type >= 0 {
      let (trait_head, _) = resolved_impl_trait_head(resolved, trait_type)
      let (target_head, _) = resolved_impl_target_head(
        resolved,
        resolved.impl_target_types[implementation_index],
      )
      match trait_head {
        Some(trait_declaration) if target_head != ErrorImplTargetHead &&
          !trait_impl_is_package_owned(
            collected.module_id,
            trait_declaration,
            target_head,
          ) => continue
        _ => ()
      }
    }
    let target_visible = frozen_impl_type_is_visible(
      resolved,
      resolved.impl_target_types[implementation_index],
      evidence_visible_declarations,
    )
    let trait_visible = trait_type < 0 ||
      frozen_impl_type_is_visible(
        resolved, trait_type, evidence_visible_declarations,
      )
    if target_visible && trait_visible {
      exported_implementations[implementation.declaration] = true
    }
  }
  let generic_parameter_bounds : Array[HirSpan] = []
  for parameter in collected.generic_parameters {
    generic_parameter_bounds.push(parameter.bounds)
  }
  let parameters : Array[FrozenInterfaceParameter] = []
  let callables : Array[FrozenInterfaceCallable] = []
  let callable_abi_identities = callable_abi_declaration_identities(
    path, collected, imports,
  )
  for callable in functions.callables {
    if semantic_id_local(callable.declaration) <
      collected.preamble_declaration_count {
      continue
    }
    if collected.declaration_is_test_only(callable.declaration) {
      continue
    }
    let exported_impl_method = match callable.kind {
      PlannedImplMethodCallable(implementation, _) =>
        exported_implementations.contains(implementation)
      _ => false
    }
    let exported = if publish_standard_top_level ||
      exported_impl_method ||
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
      PlannedForeignCallable(_, _) => FrozenFunctionCallable
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
      abi_fingerprint: frozen_callable_abi_fingerprint(
        path, callable_abi_identities, resolved, generic_parameter_bounds, functions,
        callable,
      ),
      location: collected.declaration_location(callable.declaration).unwrap(),
    })
  }
  let implementations : Array[FrozenInterfaceImplementation] = []
  for implementation_index, implementation in collected.impls {
    if !exported_implementations.contains(implementation.declaration) {
      continue
    }
    implementations.push({
      declaration: implementation.declaration,
      generic_parameters: collected.generic_parameters_of(
        implementation.declaration,
      ),
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
    generic_parameter_bounds,
    declarations,
    declaration_abi_fingerprints: [],
    fields,
    variants,
    variant_payload_types,
    callables,
    parameters,
    implementations,
    content_fingerprint: "",
    interface_fingerprint: "",
    dependencies: [],
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
pub struct ImportedModuleValueBinding {
  interface_index : Int
  declaration_index : Int
  mut ambiguous : Bool
} derive(Eq, Debug)

///|
pub struct ModuleImportScope {
  module_id : ModuleId
  declarations : Array[ImportedDeclarationBinding]
  declaration_bindings : Map[DeclId, Int]
  imported_interfaces : Array[Int]
  type_bindings : Map[String, Int]
  trait_bindings : Map[String, Int]
  module_type_bindings : Array[Map[String, Int]]
  module_trait_bindings : Array[Map[String, Int]]
  value_bindings : Map[String, ImportedValueBinding]
  module_value_bindings : Array[Map[String, ImportedValueBinding]]
  module_let_bindings : Array[Map[String, ImportedModuleValueBinding]]
  let_bindings : Map[String, ImportedModuleValueBinding]
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
pub fn ModuleImportScope::lookup_module_declaration(
  self : ModuleImportScope,
  interface_index : Int,
  name : String,
  kind : FrozenInterfaceDeclarationKind,
) -> ImportedDeclarationBinding? {
  guard interface_index >= 0 &&
    interface_index < self.module_type_bindings.length() else {
    return None
  }
  let table = if kind == FrozenTraitDeclaration {
    self.module_trait_bindings[interface_index]
  } else if kind == FrozenTypeDeclaration {
    self.module_type_bindings[interface_index]
  } else {
    return None
  }
  match table.get(name) {
    Some(index) if index >= 0 && index < self.declarations.length() =>
      Some(self.declarations[index])
    _ => None
  }
}

///|
pub fn ModuleImportScope::lookup_module_type(
  self : ModuleImportScope,
  interface_index : Int,
  name : String,
) -> ImportedDeclarationBinding? {
  self.lookup_module_declaration(interface_index, name, FrozenTypeDeclaration)
}

///|
pub fn ModuleImportScope::lookup_module_trait(
  self : ModuleImportScope,
  interface_index : Int,
  name : String,
) -> ImportedDeclarationBinding? {
  self.lookup_module_declaration(interface_index, name, FrozenTraitDeclaration)
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
pub fn ModuleImportScope::lookup_module_value(
  self : ModuleImportScope,
  interface_index : Int,
  name : String,
) -> DeclId? {
  guard interface_index >= 0 &&
    interface_index < self.module_let_bindings.length() else {
    return None
  }
  match self.module_let_bindings[interface_index].get(name) {
    Some(binding) if !binding.ambiguous => {
      let interface_ = self.interfaces[binding.interface_index].unwrap()
      Some(interface_.declarations[binding.declaration_index].declaration)
    }
    _ => None
  }
}

///|
pub fn ModuleImportScope::lookup_opened_value(
  self : ModuleImportScope,
  name : String,
) -> DeclId? {
  match self.let_bindings.get(name) {
    Some(binding) if !binding.ambiguous => {
      let interface_ = self.interfaces[binding.interface_index].unwrap()
      Some(interface_.declarations[binding.declaration_index].declaration)
    }
    _ => None
  }
}

///|
pub fn ModuleImportScope::opened_value_is_ambiguous(
  self : ModuleImportScope,
  name : String,
) -> Bool {
  match self.let_bindings.get(name) {
    Some(binding) => binding.ambiguous
    None => false
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
fn register_imported_declaration(
  scope : ModuleImportScope,
  interface_index : Int,
  declaration : FrozenInterfaceDeclaration,
) -> Int {
  match scope.declaration_bindings.get(declaration.declaration) {
    Some(index) => index
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
      scope.declaration_bindings[declaration.declaration] = index
      if declaration.kind == FrozenTypeDeclaration {
        scope.module_type_bindings[interface_index][declaration.name] = index
      } else if declaration.kind == FrozenTraitDeclaration {
        scope.module_trait_bindings[interface_index][declaration.name] = index
      }
      index
    }
  }
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
    None =>
      table[name] = register_imported_declaration(
        scope, interface_index, declaration,
      )
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
fn imported_callable_binding_declaration(
  scope : ModuleImportScope,
  binding : ImportedValueBinding,
) -> DeclId {
  let reference = scope.callable_references[binding.head]
  scope.interfaces[reference.interface_index].unwrap().callables[reference.callable_index].declaration
}

///|
fn imported_module_value_binding_declaration(
  scope : ModuleImportScope,
  binding : ImportedModuleValueBinding,
) -> DeclId {
  scope.interfaces[binding.interface_index].unwrap().declarations[binding.declaration_index].declaration
}

///|
fn expose_imported_module_value_binding(
  scope : ModuleImportScope,
  name : String,
  binding : ImportedModuleValueBinding,
) -> Unit {
  match scope.value_bindings.get(name) {
    Some(callables) if !callables.ambiguous => {
      callables.ambiguous = true
      let opened : ImportedModuleValueBinding = { ..binding, ambiguous: true, }
      scope.let_bindings[name] = opened
      scope.diagnostics.push(
        AmbiguousImportedValue(
          scope.module_id,
          name,
          imported_callable_binding_declaration(scope, callables),
          imported_module_value_binding_declaration(scope, binding),
        ),
      )
      return
    }
    _ => ()
  }
  match scope.let_bindings.get(name) {
    None => scope.let_bindings[name] = { ..binding, ambiguous: false, }
    Some(opened) => {
      if opened.ambiguous || opened.interface_index == binding.interface_index {
        return
      }
      let previous = imported_module_value_binding_declaration(scope, opened)
      let next = imported_module_value_binding_declaration(scope, binding)
      opened.ambiguous = true
      scope.diagnostics.push(
        AmbiguousImportedValue(scope.module_id, name, previous, next),
      )
    }
  }
}

///|
fn insert_imported_module_value(
  scope : ModuleImportScope,
  interface_index : Int,
  declaration_index : Int,
  declaration : FrozenInterfaceDeclaration,
  open_names : Bool,
) -> Unit {
  if declaration.source_kind != LetDecl {
    return
  }
  let binding : ImportedModuleValueBinding = {
    interface_index,
    declaration_index,
    ambiguous: false,
  }
  scope.module_let_bindings[interface_index][declaration.name] = binding
  if open_names {
    expose_imported_module_value_binding(scope, declaration.name, binding)
  }
}

///|
fn expose_imported_value_binding(
  scope : ModuleImportScope,
  name : String,
  binding : ImportedValueBinding,
) -> Unit {
  match scope.let_bindings.get(name) {
    Some(value) if !value.ambiguous => {
      let opened : ImportedValueBinding = { ..binding, ambiguous: true, }
      scope.value_bindings[name] = opened
      value.ambiguous = true
      scope.diagnostics.push(
        AmbiguousImportedValue(
          scope.module_id,
          name,
          imported_module_value_binding_declaration(scope, value),
          imported_callable_binding_declaration(scope, binding),
        ),
      )
      return
    }
    _ => ()
  }
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
      if opened.interface_index != binding.interface_index {
        scope.callable_references[opened.tail].next = binding.head
      }
      opened.tail = binding.tail
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
      let values = scope.module_let_bindings[dependency]
      for name, binding in values {
        expose_imported_module_value_binding(scope, name, binding)
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
      for declaration_index, declaration in interface_.declarations {
        if declaration.kind == FrozenTypeDeclaration ||
          declaration.kind == FrozenTraitDeclaration {
          ignore(register_imported_declaration(scope, dependency, declaration))
        }
        insert_imported_module_value(
          scope, dependency, declaration_index, declaration, open_names,
        )
        if open_names {
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
fn build_module_import_scope(
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
  let module_type_bindings : Array[Map[String, Int]] = []
  let module_trait_bindings : Array[Map[String, Int]] = []
  let module_value_bindings : Array[Map[String, ImportedValueBinding]] = []
  let module_let_bindings : Array[Map[String, ImportedModuleValueBinding]] = []
  for _ in program.modules {
    module_type_bindings.push(Map::default())
    module_trait_bindings.push(Map::default())
    module_value_bindings.push(Map::default())
    module_let_bindings.push(Map::default())
  }
  let scope : ModuleImportScope = {
    module_id: module_.module_id,
    declarations: [],
    declaration_bindings: Map::default(),
    imported_interfaces: [],
    type_bindings: Map::default(),
    trait_bindings: Map::default(),
    module_type_bindings,
    module_trait_bindings,
    value_bindings: Map::default(),
    module_value_bindings,
    module_let_bindings,
    let_bindings: Map::default(),
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
fn frozen_module_publishes_standard_top_level(path : String) -> Bool {
  path.has_prefix("dew.std.") &&
  path != "dew.std.string" &&
  path != "dew.std.string_builder" &&
  path != "dew.std.bytes" &&
  path != "dew.std.bytes_builder"
}

///|
fn frozen_module_requires_value_inference(
  path : String,
  collected : CollectedModule,
) -> Bool {
  let publish_standard_top_level = frozen_module_publishes_standard_top_level(
    path,
  )
  for declaration in collected.declarations {
    if declaration.kind == LetDecl &&
      semantic_id_local(declaration.id) >= collected.preamble_declaration_count &&
      (publish_standard_top_level || declaration.visibility == Public) &&
      !collected.declaration_is_test_only(declaration.id) &&
      declaration.has_name() {
      return true
    }
  }
  false
}

///|
fn infer_frozen_module_values(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ModuleImportScope,
) -> InferredModuleValues {
  let names = resolve_module_names_with_imports(collected, imports)
  for interface_index in imports.imported_interfaces {
    if imports.interfaces[interface_index] is None {
      return infer_module_values(collected, resolved, names)
    }
  }
  infer_module_values_with_imports(
    collected,
    resolved,
    resolve_module_imports(resolved, imports),
    names,
  )
}

///|
/// Resolves and freezes every manifest module in dependency-SCC order. The
/// returned interface array remains in manifest order for constant identity;
/// SCC order controls only job execution.
fn freeze_program_interfaces_with_cached_hook(
  program : CollectedProgram,
  cached : Array[FrozenModuleInterface?],
  resolve_cached : (Int, Array[FrozenModuleInterface?]) -> FrozenModuleInterface?,
  on_frozen : (Int, FrozenModuleInterface) -> Unit,
  resolve_cached_scc : (HirSpan, Array[Int], Array[FrozenModuleInterface?]) -> Unit,
  on_frozen_scc : (HirSpan, Array[Int], Array[FrozenModuleInterface?]) -> Unit,
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
    let mut scc_was_cached = false
    if repeat {
      resolve_cached_scc(scc, graph.scc_modules, slots)
      let mut cached_count = 0
      for index in 0..<scc.length {
        let module_index = graph.scc_modules[scc.start + index]
        match slots[module_index] {
          Some(interface_) => {
            guard interface_.module_id ==
              program.modules[module_index].module_id &&
              interface_.path == program.module_paths[module_index] else {
              abort(
                "resolved cached SCC interface identity does not match the collected module",
              )
            }
            cached_slots[module_index] = true
            cached_count += 1
          }
          None => ()
        }
      }
      guard cached_count == 0 || cached_count == scc.length else {
        abort("resolved cached SCC must be complete")
      }
      scc_was_cached = cached_count == scc.length
    }
    for index in 0..<scc.length {
      let module_index = graph.scc_modules[scc.start + index]
      let collected = program.modules[module_index]
      if !repeat && !cached_slots[module_index] {
        match resolve_cached(module_index, slots) {
          Some(interface_) => {
            guard interface_.module_id == collected.module_id &&
              interface_.path == program.module_paths[module_index] else {
              abort(
                "resolved cached interface identity does not match the collected module",
              )
            }
            slots[module_index] = Some(interface_)
            cached_slots[module_index] = true
          }
          None => ()
        }
      }
      let imports = build_module_import_scope(program, slots, module_index)
      scope_slots[module_index] = Some(imports)
      if !cached_slots[module_index] {
        let resolved = resolve_module_types_with_imports(collected, imports)
        let functions = plan_module_functions(collected, resolved)
        let module_values = if frozen_module_requires_value_inference(
            program.module_paths[module_index],
            collected,
          ) {
          Some(infer_frozen_module_values(collected, resolved, imports))
        } else {
          None
        }
        let interface_ = freeze_module_interface(
          program.module_paths[module_index],
          collected,
          resolved,
          functions,
          module_values~,
          imports=Some(imports),
        )
        slots[module_index] = Some(interface_)
        if !repeat {
          let fingerprinted = frozen_module_interface_with_available_fingerprints(
            graph, module_index, slots,
          )
          slots[module_index] = Some(fingerprinted)
          on_frozen(module_index, fingerprinted)
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
        let module_values = if frozen_module_requires_value_inference(
            program.module_paths[module_index],
            collected,
          ) {
          Some(infer_frozen_module_values(collected, resolved, imports))
        } else {
          None
        }
        let interface_ = freeze_module_interface(
          program.module_paths[module_index],
          collected,
          resolved,
          functions,
          module_values~,
          imports=Some(imports),
        )
        slots[module_index] = Some(interface_)
      }
      for diagnostic in imports.diagnostics {
        import_diagnostics.push(diagnostic)
      }
      scope_slots[module_index] = Some(imports)
    }
    if repeat && !scc_was_cached {
      let fingerprinted = frozen_available_interfaces_with_fingerprints(
        graph, slots,
      )
      for index in 0..<scc.length {
        let module_index = graph.scc_modules[scc.start + index]
        slots[module_index] = fingerprinted[module_index]
      }
      on_frozen_scc(scc, graph.scc_modules, slots)
    }
  }
  let interfaces : Array[FrozenModuleInterface] = []
  let import_scopes : Array[ModuleImportScope] = []
  for index in 0..<slots.length() {
    interfaces.push(slots[index].unwrap())
    import_scopes.push(scope_slots[index].unwrap())
  }
  let interfaces = frozen_program_interfaces_with_fingerprints(
    graph, interfaces,
  )
  { graph, interfaces, import_scopes, import_diagnostics, }
}

///|
pub fn freeze_program_interfaces_with_cached(
  program : CollectedProgram,
  cached : Array[FrozenModuleInterface?],
) -> FrozenProgramInterfaces {
  freeze_program_interfaces_with_cached_hook(
    program,
    cached,
    fn(_, _) { None },
    fn(_, _) { () },
    fn(_, _, _) { () },
    fn(_, _, _) { () },
  )
}

///|
pub fn freeze_program_interfaces_with_cache_hooks(
  program : CollectedProgram,
  cached : Array[FrozenModuleInterface?],
  resolve_cached : (Int, Array[FrozenModuleInterface?]) -> FrozenModuleInterface?,
  on_frozen : (Int, FrozenModuleInterface) -> Unit,
  resolve_cached_scc : (HirSpan, Array[Int], Array[FrozenModuleInterface?]) -> Unit,
  on_frozen_scc : (HirSpan, Array[Int], Array[FrozenModuleInterface?]) -> Unit,
) -> FrozenProgramInterfaces {
  freeze_program_interfaces_with_cached_hook(
    program, cached, resolve_cached, on_frozen, resolve_cached_scc, on_frozen_scc,
  )
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
