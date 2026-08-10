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
  if compiled.source_diagnostics().length() != 0 {
    abort("WASI parity source produced semantic diagnostics")
  }
  compiled.emit_binary().unwrap()
}

///|
fn main {
  let source = @fs.read_file_to_bytes("tools/wasi-parity/generated_cases.dew") catch {
    error => abort(error.to_string())
  }
  let binary = compile_wasi_parity(source)
  @fs.write_bytes_to_file("tools/wasi-parity/wasi_parity.wasm", binary) catch {
    error => abort(error.to_string())
  }
  println("wrote tools/wasi-parity/wasi_parity.wasm")
}
