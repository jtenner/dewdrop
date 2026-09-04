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
fn snapshot_warning(message : String) -> Unit {
  println("DEW_WARNING")
  println(message)
  println("DEW_END")
}

///|
fn snapshot_io_error_message(error : @fs.IOError) -> String {
  match error {
    @fs.IOError(message) => message
  }
}

///|
fn snapshot_read_file(path : String) -> Bytes {
  @fs.read_file_to_bytes(path) catch {
    error => {
      println(
        "DEW_INTERNAL cannot read \{path}: \{snapshot_io_error_message(error)}",
      )
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
  let options = if mode == "test" {
    @compiler_driver.CompilerPipelineOptions::test_mode(3000UL, 0, true)
  } else {
    @compiler_driver.CompilerPipelineOptions::production(3000UL, 0, true)
  }
  let compiled = match
    @compiler_driver.compile_manifest(manifest, loaded, options) {
    Ok(compiled) => compiled
    Err(error) => {
      snapshot_fail(error)
      abort("unreachable cache failure")
    }
  }
  let mut has_errors = false
  for diagnostic in compiled.source_diagnostics() {
    let rendered = @semantic.render_compiler_source_diagnostic(
      compiled.program,
      diagnostic,
    )
    match diagnostic.severity {
      @semantic.CompilerError => {
        snapshot_error(rendered)
        has_errors = true
      }
      @semantic.CompilerWarning => snapshot_warning(rendered)
    }
  }
  if has_errors {
    @sys.exit(1)
  }
  let binary = match compiled.emit_binary() {
    Ok(binary) => binary
    Err(error) => {
      snapshot_error(@debug.to_string(error))
      @sys.exit(1)
      b""
    }
  }
  @fs.write_bytes_to_file(output, binary) catch {
    error =>
      snapshot_fail(
        "cannot write \{output}: \{snapshot_io_error_message(error)}",
      )
  }
}
