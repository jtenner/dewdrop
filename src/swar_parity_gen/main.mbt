///|
fn compile_swar_parity(source : Bytes) -> Bytes {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("parity.swar", [
      @semantic.ManifestFile::new("swar_parity.dew", source),
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
    @compiler_driver.CompilerPipelineOptions::production(2550UL, 0, true),
  ).unwrap()
  if compiled.source_diagnostics().length() != 0 {
    abort("SWAR parity source produced semantic diagnostics")
  }
  compiled.emit_binary().unwrap()
}

///|
fn main {
  let source = @fs.read_file_to_bytes("tools/swar-parity/swar_parity.dew") catch {
    error => abort(error.to_string())
  }
  let typed = @fs.read_file_to_bytes("tools/swar-parity/typed_lane_parity.dew") catch {
    error => abort(error.to_string())
  }
  let combined = Buffer(size_hint=source.length() + typed.length() + 1)
  combined.write_bytes(typed)
  combined.write_byte(b'\n')
  combined.write_bytes(source)
  let binary = compile_swar_parity(combined.to_bytes())
  @fs.write_bytes_to_file("tools/swar-parity/swar_parity.wasm", binary) catch {
    error => abort(error.to_string())
  }
  println("wrote tools/swar-parity/swar_parity.wasm")
}
