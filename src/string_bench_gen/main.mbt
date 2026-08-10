///|
fn string_benchmark_fail(message : String) -> Unit {
  println("DEW_INTERNAL \{message}")
  @sys.exit(1)
}

///|
fn string_benchmark_error(message : String) -> Unit {
  println("DEW_ERROR")
  println(message)
  println("DEW_END")
}

///|
fn compile_string_benchmark(source : Bytes) -> Bytes {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("bench.main", [
      @semantic.ManifestFile::new("bench.dew", source),
    ]),
  ])
  let loaded = match
    @standard_loader.load_default_for_manifest_with_fingerprint(manifest, true) {
    Ok(loaded) => loaded
    Err(error) => {
      string_benchmark_fail(error)
      @standard_loader.StandardLibraryLoad::bootstrap()
    }
  }
  let compiled = match
    @compiler_driver.compile_manifest(
      manifest,
      loaded,
      @compiler_driver.CompilerPipelineOptions::production(2700UL, 0, true),
    ) {
    Ok(compiled) => compiled
    Err(error) => {
      string_benchmark_fail(error)
      abort("unreachable cache failure")
    }
  }
  let diagnostics = compiled.source_diagnostics()
  if diagnostics.length() != 0 {
    for diagnostic in diagnostics {
      string_benchmark_error(
        @semantic.render_compiler_source_diagnostic(
          compiled.program,
          diagnostic,
        ),
      )
    }
    string_benchmark_fail(
      "String benchmark source produced \{diagnostics.length()} compiler diagnostics",
    )
  }
  match compiled.emit_binary() {
    Ok(binary) => binary
    Err(error) => {
      string_benchmark_fail(@debug.to_string(error))
      b""
    }
  }
}

///|
fn main {
  let source = @fs.read_file_to_bytes(
    "tools/wago-string-bench/string_bench.dew",
  ) catch {
    error => abort(error.to_string())
  }
  let binary = compile_string_benchmark(source)
  @fs.write_bytes_to_file("tools/wago-string-bench/string_bench.wasm", binary) catch {
    error => abort(error.to_string())
  }
  println("wrote tools/wago-string-bench/string_bench.wasm")
}
