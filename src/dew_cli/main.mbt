///|
fn cli_fail(message : String) -> Unit {
  println("dew: \{message}")
  @sys.exit(2)
}

///|
fn cli_fs_error_message(error : @fs.IOError) -> String {
  match error {
    @fs.IOError(message) => message
  }
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
      cli_fail("cannot read \{path}: \{cli_fs_error_message(error)}")
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
) -> (Bool, Int) {
  let mut has_errors = false
  let mut count = 0
  for
    diagnostic in @semantic.collect_compiler_source_diagnostics(
      program, analyzed, lowering, link,
    ) {
    count += 1
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
  (has_errors, count)
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
    error => cli_fail("cannot write \{path}: \{cli_fs_error_message(error)}")
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
  println("  repeat --link-wasm PROVIDER FILE to statically link Core Wasm")
  println("  internal manifest option: --dependency-interface MODULE SHA256")
  println(
    "  driver options: --package-root ROOT, --bootstrap-std, --no-default-preamble, --no-parse-event-cache, --no-interface-cache, --body-cache, --body-family-cache, --no-body-cache, --plan-cache, --no-plan-cache, --cache-pack, --no-cache-pack, --program-cache, --no-program-cache, --cache-report",
  )
}

///|
fn compile_request_root_index(
  request : @compile_request.CompilerRequest,
) -> Int {
  for index, module_ in request.modules {
    if module_.name == request.root_module {
      return index
    }
  }
  abort("validated compile request has no root module")
}

///|
fn compile_request_manifest(
  request : @compile_request.CompilerRequest,
) -> @semantic.ProgramManifest {
  let modules : Array[@semantic.ManifestModule] = []
  for module_ in request.modules {
    let files : Array[@semantic.ManifestFile] = []
    for file in module_.files {
      files.push(@semantic.ManifestFile::new(file.logical_path, file.source))
    }
    modules.push(@semantic.ManifestModule::new(module_.name, files))
  }
  @semantic.ProgramManifest::new(modules)
}

///|
fn run_source_compile_request(
  request : @compile_request.CompilerRequest,
) -> Unit {
  let expected_standard = match request.standard_library {
    @compile_request.CompilerBootstrapStandard(identity) => identity
  }
  let actual_standard = @compile_request.bootstrap_standard_library_identity()
  if !@compile_request.bytes_equal(expected_standard, actual_standard) {
    cli_fail("compile request bootstrap standard identity mismatch")
  }
  let manifest = compile_request_manifest(request)
  let root_module_index = compile_request_root_index(request)
  let options = if request.config.test_mode {
    @compiler_driver.CompilerPipelineOptions::test_mode(
      4000UL,
      root_module_index,
      request.config.default_preamble,
    )
  } else {
    @compiler_driver.CompilerPipelineOptions::production(
      4000UL,
      root_module_index,
      request.config.default_preamble,
    )
  }
  let compiled = @compiler_driver.compile_manifest_uncached(
    manifest,
    @semantic.StandardLibrarySources::bootstrap(),
    options,
  )
  for dependency in request.dependency_interfaces {
    let mut dependency_index = -1
    for candidate, module_ in request.modules {
      if module_.name == dependency.module_name {
        dependency_index = candidate
        break
      }
    }
    if dependency_index < 0 {
      cli_fail(
        "unavailable dependency interface module \{dependency.module_name}",
      )
    }
    let actual = compiled.analyzed.frozen.interfaces[dependency_index].interface_fingerprint
    if actual != dependency.fingerprint {
      cli_fail(
        "dependency interface mismatch for \{dependency.module_name}: expected \{dependency.fingerprint}, got \{actual}",
      )
    }
  }
  let diagnostic_status = report_compilation_diagnostics(
    compiled.program,
    compiled.analyzed,
    compiled.lowering,
    compiled.link,
  )
  if diagnostic_status.0 {
    @sys.exit(1)
  }
  if request.config.cache_report {
    println("parse event cache: disabled")
    println("standard interface cache: disabled")
    println("body inference cache: disabled")
    println("layout and fragment cache: disabled")
    println("compilation cache pack: disabled")
  }
  match request.command {
    @compile_request.CompilerCheck =>
      println(
        "checked \{request.modules.fold(init=0, fn(total, module_) { total + module_.files.length() })} Dew source file(s) in \{request.modules.length()} module(s)",
      )
    @compile_request.CompilerBuild => {
      let result = match request.output_kind {
        @compile_request.CompilerHirOutput =>
          render_program_hir(compiled.program)
        @compile_request.CompilerLoweringOutput =>
          render_program_lowering(compiled.program, compiled.lowering)
        @compile_request.CompilerWasmOutput => {
          let libraries : Array[@core_linker.CoreWasmLibrary] = []
          for provider in request.static_providers {
            libraries.push({ provider: provider.name, bytes: provider.wasm, })
          }
          let encoded = match compiled.emit_linked_binary(libraries) {
            Ok(binary) => binary
            Err(error) => {
              cli_error(error)
              @sys.exit(1)
              b""
            }
          }
          let with_abi = @backend.append_wasm_abi_section(
            encoded,
            compiled.analyzed.frozen.interfaces[root_module_index],
          )
          @backend.append_wasm_metrics_section(
            with_abi,
            compiled.link.materialized_specialization_count(),
          )
        }
      }
      match request.response {
        @compile_request.CompilerOutputFile(path) =>
          write_cli_output(path, result)
        @compile_request.CompilerStatusOnly =>
          abort("validated build request has no output file")
      }
    }
  }
  ignore(request.compiler_fingerprint)
}

///|
fn main {
  let process_args = @sys.get_cli_args()
  if process_args.length() == 3 && process_args[1] == "--compile-request" {
    let request = match
      @compile_request.decode(cli_read_file(process_args[2])) {
      Ok(value) => value
      Err(error) => {
        cli_fail(error)
        abort("unreachable compile request failure")
      }
    }
    run_source_compile_request(request)
    return
  }
  let args = process_args
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
  let static_link_providers : Array[String] = []
  let static_link_modules : Array[Bytes] = []
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
    } else if argument == "--link-wasm" {
      if index + 2 >= args.length() {
        cli_fail("missing provider or file for --link-wasm")
      }
      let provider = args[index + 1]
      if provider == "" || provider.contains(":") {
        cli_fail("--link-wasm provider must be a non-empty simple name")
      }
      static_link_providers.push(provider)
      static_link_modules.push(cli_read_file(args[index + 2]))
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
    } else if argument == "--body-cache" {
      @sys.set_env_var("DEW_BODY_CACHE", "1")
      index += 1
    } else if argument == "--body-family-cache" {
      @sys.set_env_var("DEW_BODY_CACHE", "1")
      @sys.set_env_var("DEW_BODY_FAMILY_CACHE", "1")
      index += 1
    } else if argument == "--no-body-cache" {
      @sys.set_env_var("DEW_BODY_CACHE", "0")
      @sys.set_env_var("DEW_BODY_FAMILY_CACHE", "0")
      index += 1
    } else if argument == "--plan-cache" {
      @sys.set_env_var("DEW_PLAN_CACHE", "1")
      index += 1
    } else if argument == "--no-plan-cache" {
      @sys.set_env_var("DEW_PLAN_CACHE", "0")
      index += 1
    } else if argument == "--cache-pack" {
      @sys.set_env_var("DEW_CACHE_PACK", "1")
      index += 1
    } else if argument == "--no-cache-pack" {
      @sys.set_env_var("DEW_CACHE_PACK", "0")
      index += 1
    } else if argument == "--program-cache" {
      @sys.set_env_var("DEW_PROGRAM_CACHE", "1")
      index += 1
    } else if argument == "--no-program-cache" {
      @sys.set_env_var("DEW_PROGRAM_CACHE", "0")
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
  let cache_pack = match
    @standard_loader.open_compilation_cache_pack(
      manifest, root_module_index, default_preamble, 0,
    ) {
    Ok(value) => value
    Err(error) => {
      cli_fail(error)
      abort("unreachable cache-pack failure")
    }
  }
  let command_tag = if command == "check" { 0 } else { 1 }
  let emit_tag = match emit {
    "hir" => 1
    "lowering" => 2
    _ => 0
  }
  match
    @standard_loader.lookup_program_output_cache(
      cache_pack,
      manifest,
      root_module_index,
      default_preamble,
      command_tag,
      emit_tag,
      dependency_interface_modules,
      dependency_interface_fingerprints,
      static_link_providers~,
      static_link_modules~,
    ) {
    Err(error) => cli_fail("corrupt compilation cache pack: \{error}")
    Ok(Some(cached_output)) => {
      if cache_report {
        println("parse event cache: bypassed by exact program hit")
        println("standard interface cache: bypassed by exact program hit")
        println("body inference cache: bypassed by exact program hit")
        println("layout and fragment cache: bypassed by exact program hit")
        println("compilation cache pack: exact hit, \{cache_pack.status()}")
      }
      if command == "check" {
        println(
          "checked \{total_file_count} Dew source file(s) in \{modules.length()} module(s)",
        )
      } else {
        write_cli_output(output, cached_output)
      }
      return
    }
    Ok(None) => ()
  }
  let prepared_manifest = match
    @standard_loader.prepare_manifest_parse_event_cache(
      manifest,
      pack=Some(cache_pack),
    ) {
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
      pack=Some(cache_pack),
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
  let planning_cache_status = compiled.planning_cache_status.label()
  let parse_event_cache_status = compiled.parse_event_cache_status.label()
  let cache_pack_status = compiled.cache_pack_status
  let diagnostic_status = report_compilation_diagnostics(
    compiled.program,
    compiled.analyzed,
    compiled.lowering,
    compiled.link,
  )
  if diagnostic_status.0 {
    @sys.exit(1)
  }
  if cache_report {
    println("parse event cache: \{parse_event_cache_status}")
    println("standard interface cache: \{cache_status}")
    println("body inference cache: \{body_cache_status}")
    println("layout and fragment cache: \{planning_cache_status}")
    println("compilation cache pack: \{cache_pack_status}")
  }
  if command == "check" {
    if diagnostic_status.1 == 0 {
      match
        @standard_loader.store_program_output_cache(
          cache_pack,
          manifest,
          root_module_index,
          default_preamble,
          command_tag,
          emit_tag,
          dependency_interface_modules,
          dependency_interface_fingerprints,
          b"",
          static_link_providers~,
          static_link_modules~,
        ) {
        Ok(_) => ()
        Err(error) => cli_fail(error)
      }
      match cache_pack.commit() {
        Ok(_) => ()
        Err(error) => cli_fail(error)
      }
    }
    println(
      "checked \{total_file_count} Dew source file(s) in \{modules.length()} module(s)",
    )
    return
  }
  let result = if emit == "hir" {
    render_program_hir(compiled.program)
  } else if emit == "lowering" {
    render_program_lowering(compiled.program, compiled.lowering)
  } else {
    let libraries : Array[@core_linker.CoreWasmLibrary] = []
    for index, provider in static_link_providers {
      libraries.push({ provider, bytes: static_link_modules[index], })
    }
    let encoded = match compiled.emit_linked_binary(libraries) {
      Ok(binary) => binary
      Err(error) => {
        cli_error(error)
        @sys.exit(1)
        b""
      }
    }
    let with_abi = @backend.append_wasm_abi_section(
      encoded,
      compiled.analyzed.frozen.interfaces[root_module_index],
    )
    @backend.append_wasm_metrics_section(
      with_abi,
      compiled.link.materialized_specialization_count(),
    )
  }
  if diagnostic_status.1 == 0 {
    match
      @standard_loader.store_program_output_cache(
        cache_pack,
        manifest,
        root_module_index,
        default_preamble,
        command_tag,
        emit_tag,
        dependency_interface_modules,
        dependency_interface_fingerprints,
        result,
        static_link_providers~,
        static_link_modules~,
      ) {
      Ok(_) => ()
      Err(error) => cli_fail(error)
    }
    match cache_pack.commit() {
      Ok(_) => ()
      Err(error) => cli_fail(error)
    }
  }
  write_cli_output(output, result)
}
