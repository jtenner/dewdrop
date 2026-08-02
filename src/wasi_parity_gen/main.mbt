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
  let program = @semantic.collect_program_manifest_with_standard_sources(
    2554UL,
    manifest,
    loaded.sources,
    true,
  )
  let analyzed = match
    @standard_loader.analyze_program_with_standard_cache(program, loaded) {
    Ok(cached) => cached.analyzed
    Err(error) => abort(error)
  }
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  let diagnostics = program.diagnostics.length() +
    program.modules[0].diagnostics.length() +
    analyzed.frozen.graph.diagnostics.length() +
    analyzed.frozen.import_diagnostics.length() +
    analyzed.frozen.interfaces[0].resolved_types.diagnostics.length() +
    analyzed.modules[0].names.diagnostics.length() +
    analyzed.modules[0].inferred.diagnostics.length() +
    lowering.modules[0].diagnostics.length() +
    link.diagnostics.length()
  if diagnostics != 0 {
    abort("WASI parity source produced semantic diagnostics")
  }
  @backend.emit_starshine_program_binary(lowering, link).unwrap()
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
