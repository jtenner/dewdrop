///|
fn cli_fail(message : String) -> Unit {
  println("dew: \{message}")
  @sys.exit(2)
}

///|
fn cli_error(message : String) -> Unit {
  println("DEW_ERROR")
  println(message)
  println("DEW_END")
}

///|
fn cli_read_file(path : String) -> Bytes {
  @fs.read_file_to_bytes(path) catch {
    error => {
      cli_fail("cannot read \{path}: \{error}")
      b""
    }
  }
}

///|
fn report_compilation_diagnostics(
  program : @semantic.CollectedProgram,
  analyzed : @semantic.AnalyzedProgramSemantics,
  link : @semantic.PlannedProgramWasmGCLink,
) -> Bool {
  let mut has_errors = false
  for diagnostic in program.diagnostics {
    cli_error(@debug.to_string(diagnostic))
    has_errors = true
  }
  for module_ in program.modules {
    for diagnostic in module_.diagnostics {
      cli_error(@debug.to_string(diagnostic))
      has_errors = true
    }
  }
  for diagnostic in analyzed.frozen.graph.diagnostics {
    cli_error(@debug.to_string(diagnostic))
    has_errors = true
  }
  for diagnostic in analyzed.frozen.import_diagnostics {
    cli_error(@debug.to_string(diagnostic))
    has_errors = true
  }
  for interface_ in analyzed.frozen.interfaces {
    for diagnostic in interface_.resolved_types.diagnostics {
      cli_error(@debug.to_string(diagnostic))
      has_errors = true
    }
  }
  for module_ in analyzed.modules {
    for diagnostic in module_.names.diagnostics {
      cli_error(@debug.to_string(diagnostic))
      has_errors = true
    }
    for diagnostic in module_.inferred.diagnostics {
      cli_error(@debug.to_string(diagnostic))
      has_errors = true
    }
  }
  for diagnostic in link.diagnostics {
    cli_error(@debug.to_string(diagnostic))
    has_errors = true
  }
  has_errors
}

///|
fn render_program_hir(program : @semantic.CollectedProgram) -> Bytes {
  let output = Buffer(size_hint=4096)
  for index, module_ in program.modules {
    output.write_string_utf8("module ")
    output.write_string_utf8(program.module_paths[index])
    output.write_byte(b'\n')
    output.write_string_utf8("declarations ")
    output.write_string_utf8(@debug.to_string(module_.declarations))
    output.write_byte(b'\n')
    output.write_string_utf8("types ")
    output.write_string_utf8(@debug.to_string(module_.type_syntax))
    output.write_byte(b'\n')
    output.write_string_utf8("bodies ")
    output.write_string_utf8(@debug.to_string(module_.bodies))
    output.write_byte(b'\n')
    output.write_string_utf8("expressions ")
    output.write_string_utf8(@debug.to_string(module_.expressions))
    output.write_byte(b'\n')
    output.write_string_utf8("blocks ")
    output.write_string_utf8(@debug.to_string(module_.blocks))
    output.write_byte(b'\n')
    output.write_string_utf8("block-items ")
    output.write_string_utf8(@debug.to_string(module_.block_items))
    output.write_byte(b'\n')
    output.write_string_utf8("patterns ")
    output.write_string_utf8(@debug.to_string(module_.patterns))
    output.write_byte(b'\n')
    output.write_string_utf8("pattern-arms ")
    output.write_string_utf8(@debug.to_string(module_.pattern_arms))
    output.write_byte(b'\n')
  }
  output.to_bytes()
}

///|
fn render_program_lowering(
  program : @semantic.CollectedProgram,
  lowering : @semantic.PlannedProgramLowering,
) -> Bytes {
  let output = Buffer(size_hint=4096)
  for index, module_ in lowering.modules {
    output.write_string_utf8("module ")
    output.write_string_utf8(program.module_paths[index])
    output.write_byte(b'\n')
    output.write_string_utf8(@debug.to_string(module_))
    output.write_byte(b'\n')
  }
  output.to_bytes()
}

///|
fn write_cli_output(path : String, bytes : Bytes) -> Unit {
  @fs.write_bytes_to_file(path, bytes) catch {
    error => cli_fail("cannot write \{path}: \{error}")
  }
  println("wrote \{path} (\{bytes.length()} bytes)")
}

///|
fn print_usage() -> Unit {
  println("usage:")
  println(
    "  dew check [--root NAME] [--module NAME] [--no-default-preamble] FILE ...",
  )
  println(
    "  dew build [--root NAME] [--module NAME] [--no-default-preamble] [--emit hir|lowering|wasm] -o OUTPUT FILE ...",
  )
  println("  repeat --module NAME to begin another statically linked module")
  println(
    "  driver options: --package-root ROOT, --bootstrap-std, --no-default-preamble, --no-interface-cache, --cache-report",
  )
}

///|
fn main {
  let args = @sys.get_cli_args()
  if args.length() < 3 {
    print_usage()
    @sys.exit(2)
  }
  let command = args[1]
  if command != "check" && command != "build" {
    print_usage()
    @sys.exit(2)
  }
  let mut module_name = "main"
  let mut root_name = ""
  let mut output = ""
  let mut emit = "wasm"
  let mut standard_root = @sys.get_env_var("DEW_STD_ROOT").unwrap_or(".")
  let mut bootstrap_standard_library = @sys.get_env_var("DEW_BOOTSTRAP_STD") ==
    Some("1")
  let mut default_preamble = true
  let mut cache_report = false
  let modules : Array[@semantic.ManifestModule] = []
  let module_names : Array[String] = []
  let mut files : Array[@semantic.ManifestFile] = []
  let mut total_file_count = 0
  let mut index = 2
  while index < args.length() {
    let argument = args[index]
    if argument == "--module" {
      if index + 1 >= args.length() {
        cli_fail("missing value for --module")
      }
      if files.length() > 0 {
        modules.push(@semantic.ManifestModule::new(module_name, files))
        module_names.push(module_name)
        files = []
      }
      module_name = args[index + 1]
      index += 2
    } else if argument == "--root" {
      if index + 1 >= args.length() {
        cli_fail("missing value for --root")
      }
      root_name = args[index + 1]
      index += 2
    } else if argument == "--emit" {
      if index + 1 >= args.length() {
        cli_fail("missing value for --emit")
      }
      emit = args[index + 1]
      if emit != "hir" && emit != "lowering" && emit != "wasm" {
        cli_fail("--emit must be hir, lowering, or wasm")
      }
      index += 2
    } else if argument == "--std-root" {
      if index + 1 >= args.length() {
        cli_fail("missing value for --std-root")
      }
      standard_root = args[index + 1]
      index += 2
    } else if argument == "--bootstrap-std" {
      bootstrap_standard_library = true
      index += 1
    } else if argument == "--no-default-preamble" {
      default_preamble = false
      index += 1
    } else if argument == "--no-interface-cache" {
      @sys.set_env_var("DEW_INTERFACE_CACHE", "0")
      index += 1
    } else if argument == "--cache-report" {
      cache_report = true
      index += 1
    } else if argument == "-o" || argument == "--output" {
      if index + 1 >= args.length() {
        cli_fail("missing output path")
      }
      output = args[index + 1]
      index += 2
    } else {
      files.push(@semantic.ManifestFile::new(argument, cli_read_file(argument)))
      total_file_count += 1
      index += 1
    }
  }
  if files.length() > 0 {
    modules.push(@semantic.ManifestModule::new(module_name, files))
    module_names.push(module_name)
  }
  if total_file_count == 0 {
    cli_fail("at least one Dew source file is required")
  }
  if command == "check" && output != "" {
    cli_fail("check does not accept an output path")
  }
  if command == "check" && emit != "wasm" {
    cli_fail("check does not accept --emit")
  }
  if command == "build" && output == "" {
    cli_fail("build requires -o OUTPUT")
  }
  let mut root_module_index = 0
  if root_name != "" {
    root_module_index = -1
    for candidate, name in module_names {
      if name == root_name {
        root_module_index = candidate
        break
      }
    }
    if root_module_index < 0 {
      cli_fail("unknown root module \{root_name}")
    }
  }
  let manifest = @semantic.ProgramManifest::new(modules)
  let loaded = if bootstrap_standard_library {
    @standard_loader.StandardLibraryLoad::bootstrap()
  } else {
    match
      @standard_loader.load_for_manifest_with_fingerprint(
        standard_root, manifest, default_preamble,
      ) {
      Ok(loaded) => loaded
      Err(error) => {
        cli_fail(error)
        @standard_loader.StandardLibraryLoad::bootstrap()
      }
    }
  }
  let program = @semantic.collect_program_manifest_with_standard_sources(
    4000UL,
    manifest,
    loaded.sources,
    default_preamble,
  )
  let cached_analysis = match
    @standard_loader.analyze_program_with_standard_cache(program, loaded) {
    Ok(cached) => cached
    Err(error) => {
      cli_fail(error)
      abort("unreachable cache failure")
    }
  }
  let analyzed = cached_analysis.analyzed
  let cache_status = cached_analysis.status.label()
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(
    analyzed, lowering, root_module_index,
  )
  if report_compilation_diagnostics(program, analyzed, link) {
    @sys.exit(1)
  }
  if cache_report {
    println("standard interface cache: \{cache_status}")
  }
  if command == "check" {
    println(
      "checked \{total_file_count} Dew source file(s) in \{modules.length()} module(s)",
    )
    return
  }
  if emit == "hir" {
    write_cli_output(output, render_program_hir(program))
    return
  }
  if emit == "lowering" {
    write_cli_output(output, render_program_lowering(program, lowering))
    return
  }
  let binary = match @backend.emit_starshine_program_binary(lowering, link) {
    Ok(binary) => binary
    Err(error) => {
      cli_error(@debug.to_string(error))
      @sys.exit(1)
      b""
    }
  }
  write_cli_output(output, binary)
}
