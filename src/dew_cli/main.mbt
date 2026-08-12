///|
fn cli_fail(message : String) -> Unit {
  println("dew: \{message}")
  @sys.exit(2)
}

///|
fn cli_error(message : String) -> Unit {
  println(message)
}

///|
fn cli_warning(message : String) -> Unit {
  println(message)
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
  lowering : @semantic.PlannedProgramLowering,
  link : @semantic.PlannedProgramWasmGCLink,
) -> Bool {
  let mut has_errors = false
  for
    diagnostic in @semantic.collect_compiler_source_diagnostics(
      program, analyzed, lowering, link,
    ) {
    let rendered = @semantic.render_compiler_source_diagnostic(
      program, diagnostic,
    )
    match diagnostic.severity {
      @semantic.CompilerError => {
        cli_error(rendered)
        has_errors = true
      }
      @semantic.CompilerWarning => cli_warning(rendered)
    }
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
  println("  internal manifest option: --dependency-interface MODULE SHA256")
  println(
    "  driver options: --package-root ROOT, --bootstrap-std, --no-default-preamble, --no-parse-event-cache, --no-interface-cache, --no-body-cache, --cache-report",
  )
}

///|
fn main {
  let process_args = @sys.get_cli_args()
  let args = if process_args.length() == 3 &&
    process_args[1] == "--compile-request" {
    let request = match parse_compile_request(cli_read_file(process_args[2])) {
      Ok(value) => value
      Err(error) => {
        cli_fail(error)
        abort("unreachable compile request failure")
      }
    }
    @sys.set_env_var(
      "DEW_INTERFACE_CACHE",
      if request.interface_cache {
        "1"
      } else {
        "0"
      },
    )
    @sys.set_env_var(
      "DEW_DEPENDENCY_INTERFACE_KEY",
      request.dependency_cache_key,
    )
    @sys.set_env_var(
      "DEW_PARSE_EVENT_CACHE",
      if request.parse_event_cache {
        "1"
      } else {
        "0"
      },
    )
    @sys.set_env_var(
      "DEW_BODY_CACHE",
      if request.body_cache {
        "1"
      } else {
        "0"
      },
    )
    let arguments : Array[String] = [process_args[0]]
    for argument in request.cli_arguments() {
      arguments.push(argument)
    }
    arguments
  } else {
    process_args
  }
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
  let dependency_interface_modules : Array[String] = []
  let dependency_interface_fingerprints : Array[String] = []
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
    } else if argument == "--dependency-interface" {
      if index + 2 >= args.length() {
        cli_fail("missing module or fingerprint for --dependency-interface")
      }
      dependency_interface_modules.push(args[index + 1])
      dependency_interface_fingerprints.push(args[index + 2])
      index += 3
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
    } else if argument == "--no-parse-event-cache" {
      @sys.set_env_var("DEW_PARSE_EVENT_CACHE", "0")
      index += 1
    } else if argument == "--no-interface-cache" {
      @sys.set_env_var("DEW_INTERFACE_CACHE", "0")
      index += 1
    } else if argument == "--no-body-cache" {
      @sys.set_env_var("DEW_BODY_CACHE", "0")
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
  let prepared_manifest = match
    @standard_loader.prepare_manifest_parse_event_cache(manifest) {
    Ok(value) => value
    Err(error) => {
      cli_fail(error)
      abort("unreachable parse-event cache failure")
    }
  }
  let manifest = prepared_manifest.manifest
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
  let compiled = match
    @compiler_driver.compile_manifest(
      manifest,
      loaded,
      @compiler_driver.CompilerPipelineOptions::production(
        4000UL, root_module_index, default_preamble,
      ),
      prior_parse_event_cache_status=prepared_manifest.status,
    ) {
    Ok(compiled) => compiled
    Err(error) => {
      cli_fail(error)
      abort("unreachable cache failure")
    }
  }
  for expected_index, dependency_path in dependency_interface_modules {
    let mut dependency_index = -1
    for candidate, path in module_names {
      if path == dependency_path {
        dependency_index = candidate
        break
      }
    }
    if dependency_index < 0 {
      cli_fail("unavailable dependency interface module \{dependency_path}")
    }
    let expected = dependency_interface_fingerprints[expected_index]
    let actual = compiled.analyzed.frozen.interfaces[dependency_index].interface_fingerprint
    if actual != expected {
      cli_fail(
        "dependency interface mismatch for \{dependency_path}: expected \{expected}, got \{actual}",
      )
    }
  }
  let cache_status = compiled.cache_status.label()
  let body_cache_status = compiled.body_cache_status.label()
  let parse_event_cache_status = compiled.parse_event_cache_status.label()
  if report_compilation_diagnostics(
      compiled.program,
      compiled.analyzed,
      compiled.lowering,
      compiled.link,
    ) {
    @sys.exit(1)
  }
  if cache_report {
    println("parse event cache: \{parse_event_cache_status}")
    println("standard interface cache: \{cache_status}")
    println("body inference cache: \{body_cache_status}")
  }
  if command == "check" {
    println(
      "checked \{total_file_count} Dew source file(s) in \{modules.length()} module(s)",
    )
    return
  }
  if emit == "hir" {
    write_cli_output(output, render_program_hir(compiled.program))
    return
  }
  if emit == "lowering" {
    write_cli_output(
      output,
      render_program_lowering(compiled.program, compiled.lowering),
    )
    return
  }
  let encoded = match compiled.emit_binary() {
    Ok(binary) => binary
    Err(error) => {
      cli_error(@debug.to_string(error))
      @sys.exit(1)
      b""
    }
  }
  let with_abi = @backend.append_wasm_abi_section(
    encoded,
    compiled.analyzed.frozen.interfaces[root_module_index],
  )
  let binary = @backend.append_wasm_metrics_section(
    with_abi,
    compiled.link.materialized_specialization_count(),
  )
  write_cli_output(output, binary)
}
