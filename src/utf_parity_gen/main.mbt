///|
fn compile_utf_parity(source : Bytes) -> Bytes {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("parity.utf", [
      @semantic.ManifestFile::new("utf_parity.dew", source),
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
    @compiler_driver.CompilerPipelineOptions::production(2551UL, 0, true),
  ).unwrap()
  if compiled.source_diagnostics().length() != 0 {
    abort("UTF parity source produced semantic diagnostics")
  }
  compiled.emit_binary().unwrap()
}

///|
fn main {
  let source = @fs.read_file_to_bytes("tools/utf-parity/utf_parity.dew") catch {
    error => abort(@debug.to_string(error))
  }
  let generated = @fs.read_file_to_bytes("tools/utf-parity/generated_cases.dew") catch {
    error => abort(@debug.to_string(error))
  }
  let combined = Buffer(size_hint=source.length() + generated.length() + 1)
  combined.write_bytes(source)
  combined.write_byte(b'\n')
  combined.write_bytes(generated)
  let binary = compile_utf_parity(combined.to_bytes())
  @fs.write_bytes_to_file("tools/utf-parity/utf_parity.wasm", binary) catch {
    error => abort(@debug.to_string(error))
  }
  println("wrote tools/utf-parity/utf_parity.wasm")
}
