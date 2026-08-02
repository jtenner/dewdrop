///|
fn snapshot_fail(message : String) -> Unit {
  println("DEW_INTERNAL \{message}")
  @sys.exit(1)
}

///|
fn snapshot_error(message : String) -> Unit {
  println("DEW_ERROR")
  println(message)
  println("DEW_END")
}

///|
fn snapshot_read_file(path : String) -> Bytes {
  @fs.read_file_to_bytes(path) catch {
    error => {
      println("DEW_INTERNAL cannot read \{path}: \{error}")
      @sys.exit(1)
      b""
    }
  }
}

///|
fn main {
  let args = @sys.get_cli_args()
  let mut output = ""
  let mut mode = "production"
  let modules : Array[@semantic.ManifestModule] = []
  if args.length() == 3 {
    output = args[1]
    mode = "production"
    modules.push(
      @semantic.ManifestModule::new("snapshot.main", [
        @semantic.ManifestFile::new("fixture.dew", snapshot_read_file(args[2])),
      ]),
    )
  } else {
    if args.length() < 6 || (args.length() - 3) % 3 != 0 {
      snapshot_fail(
        "usage: module_snapshot_gen OUTPUT MODE MODULE FILE PATH [MODULE FILE PATH ...]",
      )
    }
    output = args[1]
    mode = args[2]
    if mode != "production" && mode != "test" {
      snapshot_fail("mode must be production or test")
    }
    let mut current_module = args[3]
    let mut files : Array[@semantic.ManifestFile] = []
    let mut index = 3
    while index < args.length() {
      let module_name = args[index]
      let file_name = args[index + 1]
      let path = args[index + 2]
      if module_name != current_module {
        modules.push(@semantic.ManifestModule::new(current_module, files))
        current_module = module_name
        files = []
      }
      files.push(
        @semantic.ManifestFile::new(file_name, snapshot_read_file(path)),
      )
      index += 3
    }
    modules.push(@semantic.ManifestModule::new(current_module, files))
  }
  let manifest = @semantic.ProgramManifest::new(modules)
  let loaded = match
    @standard_loader.load_default_for_manifest_with_fingerprint(manifest, true) {
    Ok(loaded) => loaded
    Err(error) => {
      snapshot_fail(error)
      @standard_loader.StandardLibraryLoad::bootstrap()
    }
  }
  let program = @semantic.collect_program_manifest_with_standard_sources(
    3000UL,
    manifest,
    loaded.sources,
    true,
  )
  let analyzed = match
    @standard_loader.analyze_program_with_standard_cache(program, loaded) {
    Ok(cached) => cached.analyzed
    Err(error) => {
      snapshot_fail(error)
      abort("unreachable cache failure")
    }
  }
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = if mode == "test" {
    @semantic.plan_program_wasmgc_link_with_options(
      analyzed,
      lowering,
      0,
      @semantic.WasmGCPlanningOptions::test_mode(),
    )
  } else {
    @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  }
  let mut has_errors = false
  for diagnostic in program.diagnostics {
    snapshot_error(@debug.to_string(diagnostic))
    has_errors = true
  }
  for module_ in program.modules {
    for diagnostic in module_.diagnostics {
      snapshot_error(@debug.to_string(diagnostic))
      has_errors = true
    }
  }
  for diagnostic in analyzed.frozen.graph.diagnostics {
    snapshot_error(@debug.to_string(diagnostic))
    has_errors = true
  }
  for diagnostic in analyzed.frozen.import_diagnostics {
    snapshot_error(@debug.to_string(diagnostic))
    has_errors = true
  }
  for interface_ in analyzed.frozen.interfaces {
    for diagnostic in interface_.resolved_types.diagnostics {
      snapshot_error(@debug.to_string(diagnostic))
      has_errors = true
    }
  }
  for module_ in analyzed.modules {
    for diagnostic in module_.names.diagnostics {
      snapshot_error(@debug.to_string(diagnostic))
      has_errors = true
    }
    for diagnostic in module_.inferred.diagnostics {
      snapshot_error(@debug.to_string(diagnostic))
      has_errors = true
    }
  }
  for diagnostic in link.diagnostics {
    snapshot_error(@debug.to_string(diagnostic))
    has_errors = true
  }
  if has_errors {
    @sys.exit(1)
  }
  let binary = match @backend.emit_starshine_program_binary(lowering, link) {
    Ok(binary) => binary
    Err(error) => {
      snapshot_error(@debug.to_string(error))
      @sys.exit(1)
      b""
    }
  }
  @fs.write_bytes_to_file(output, binary) catch {
    error => snapshot_fail("cannot write \{output}: \{error}")
  }
}
