///|
fn compile_wasi_parity(source : Bytes) -> Bytes {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("parity.wasi", [
      @semantic.ManifestFile::new("wasi_parity.dew", source),
    ]),
  ])
  let loaded = match
    @standard_loader.load_default_for_manifest_with_fingerprint(manifest, true) {
    Ok(loaded) => loaded
    Err(error) => abort(error)
  }
  let compiled = @compiler_driver.compile_manifest(
    manifest,
    loaded,
    @compiler_driver.CompilerPipelineOptions::production(2554UL, 0, true),
  ).unwrap()
  let diagnostics = compiled.source_diagnostics()
  if diagnostics.length() != 0 {
    for diagnostic in diagnostics {
      println(
        @semantic.render_compiler_source_diagnostic(
          compiled.program,
          diagnostic,
        ),
      )
    }
    abort(
      "WASI parity source produced \{diagnostics.length()} compiler diagnostics",
    )
  }
  compiled.emit_binary().unwrap()
}

///|
fn main {
  let source = @fs.read_file_to_bytes("tools/wasi-parity/generated_cases.dew") catch {
    @fs.IOError(message) => abort(message)
  }
  let binary = compile_wasi_parity(source)
  @fs.write_bytes_to_file("tools/wasi-parity/wasi_parity.wasm", binary) catch {
    @fs.IOError(message) => abort(message)
  }
  println("wrote tools/wasi-parity/wasi_parity.wasm")
}
