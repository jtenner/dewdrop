///|
fn dew_test_fail(message : String) -> Unit {
  println(message)
  @sys.exit(1)
}

///|
fn dew_test_runtime_source() -> Bytes {
  b"open dew.std.string\nopen dew.std.wasi\nbuiltin dew_test_assert_runtime(condition: Bool, message: String) -> Unit = \"dew_test_assert\"\n"
}

///|
fn report_dew_test_diagnostics(
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
    println(@semantic.render_compiler_source_diagnostic(program, diagnostic))
    match diagnostic.severity {
      @semantic.CompilerError => has_errors = true
      @semantic.CompilerWarning => ()
    }
  }
  has_errors
}

///|
fn metadata_hex_digit(value : Int) -> Byte {
  if value < 10 {
    (0x30 + value).to_byte()
  } else {
    (0x61 + value - 10).to_byte()
  }
}

///|
fn write_metadata_hex(output : Buffer, value : Bytes) -> Unit {
  for byte in value {
    let number = byte.to_uint().reinterpret_as_int()
    output.write_byte(metadata_hex_digit(number >> 4))
    output.write_byte(metadata_hex_digit(number & 15))
  }
}

///|
fn build_dew_test_metadata(
  program : @semantic.CollectedProgram,
  logical_names : Array[Array[String]],
) -> Bytes {
  let output = Buffer(size_hint=128)
  output.write_string_utf8("DEW_TESTS_V3\n")
  let mut ordinal = 0
  for module_index, collected in program.modules {
    for test_ in collected.tests {
      let mut file_index = -1
      for candidate in 0..<logical_names[module_index].length() {
        if test_.file ==
          @semantic.make_program_file_id(collected.module_id, candidate) {
          file_index = candidate
          break
        }
      }
      if file_index < 0 {
        dew_test_fail("test metadata references an unknown source file")
      }
      output.write_string_utf8("__dew_test_" + ordinal.to_string())
      output.write_byte(b'\t')
      output.write_string_utf8(program.module_paths[module_index])
      output.write_byte(b'\t')
      output.write_string_utf8(logical_names[module_index][file_index])
      output.write_byte(b'\t')
      write_metadata_hex(output, test_.display_name)
      output.write_byte(b'\t')
      match test_.expected_trap {
        Some(expected) => write_metadata_hex(output, expected)
        None => ()
      }
      output.write_byte(b'\n')
      ordinal += 1
    }
  }
  output.to_bytes()
}

///|
fn main {
  let args = @sys.get_cli_args()
  if args.length() < 6 || (args.length() - 3) % 3 != 0 {
    dew_test_fail(
      "usage: dew_test_gen OUTPUT ROOT_MODULE MODULE LOGICAL_NAME PATH [MODULE LOGICAL_NAME PATH ...]",
    )
  }
  let output_path = args[1]
  let root_module = args[2]
  let manifest_modules : Array[@semantic.ManifestModule] = []
  let module_names : Array[String] = []
  let logical_names : Array[Array[String]] = []
  let mut current_module = args[3]
  let mut files : Array[@semantic.ManifestFile] = [
    @semantic.ManifestFile::new(
      "__dew_test_runtime.dew",
      dew_test_runtime_source(),
    ),
  ]
  let mut current_logical_names : Array[String] = ["__dew_test_runtime.dew"]
  let mut argument = 3
  while argument < args.length() {
    let module_name = args[argument]
    let logical_name = args[argument + 1]
    let path = args[argument + 2]
    if module_name != current_module {
      manifest_modules.push(
        @semantic.ManifestModule::new(current_module, files),
      )
      module_names.push(current_module)
      logical_names.push(current_logical_names)
      current_module = module_name
      files = [
        @semantic.ManifestFile::new(
          "__dew_test_runtime.dew",
          dew_test_runtime_source(),
        ),
      ]
      current_logical_names = ["__dew_test_runtime.dew"]
    }
    if module_name.contains("\t") ||
      module_name.contains("\n") ||
      module_name.contains("\r") ||
      logical_name.contains("\t") ||
      logical_name.contains("\n") ||
      logical_name.contains("\r") {
      dew_test_fail("unsupported test module or logical file name")
    }
    let source = @fs.read_file_to_bytes(path) catch {
      error => {
        dew_test_fail("cannot read \{path}: \{error}")
        b""
      }
    }
    files.push(@semantic.ManifestFile::new(logical_name, source))
    current_logical_names.push(logical_name)
    argument += 3
  }
  manifest_modules.push(@semantic.ManifestModule::new(current_module, files))
  module_names.push(current_module)
  logical_names.push(current_logical_names)
  let mut root_module_index = -1
  for index, module_name in module_names {
    if module_name == root_module {
      root_module_index = index
      break
    }
  }
  if root_module_index < 0 {
    dew_test_fail("unknown test root module \{root_module}")
  }
  let manifest = @semantic.ProgramManifest::new(manifest_modules)
  let loaded = match
    @standard_loader.load_default_for_manifest_with_fingerprint(manifest, true) {
    Ok(loaded) => loaded
    Err(error) => {
      dew_test_fail(error)
      @standard_loader.StandardLibraryLoad::bootstrap()
    }
  }
  let program = @semantic.collect_program_manifest_with_standard_sources(
    2600UL,
    manifest,
    loaded.sources,
    true,
  )
  let analyzed = match
    @standard_loader.analyze_program_with_standard_cache(program, loaded) {
    Ok(cached) => cached.analyzed
    Err(error) => {
      dew_test_fail(error)
      abort("unreachable cache failure")
    }
  }
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    root_module_index,
    @semantic.WasmGCPlanningOptions::test_mode(),
  )
  if report_dew_test_diagnostics(program, analyzed, lowering, link) {
    abort("Dew test source produced semantic diagnostics")
  }
  let binary = match @backend.emit_starshine_program_binary(lowering, link) {
    Ok(binary) => binary
    Err(error) => {
      dew_test_fail(@debug.to_string(error))
      b""
    }
  }
  let metadata = build_dew_test_metadata(program, logical_names)
  let self_describing_binary = @backend.append_wasm_custom_section(
    binary, "dew.tests", metadata,
  )
  @fs.write_bytes_to_file(output_path, self_describing_binary) catch {
    error => dew_test_fail("cannot write Dew test module: \{error}")
  }
  println("wrote self-describing Dew test module")
}
