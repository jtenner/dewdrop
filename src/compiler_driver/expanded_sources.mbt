///|
/// Expand checked transform source without physical planning or code emission.
/// Generated source remains available when its later type check would fail.
pub fn expand_manifest_sources(
  manifest : @semantic.ProgramManifest,
  sources : @semantic.StandardLibrarySources,
  options : CompilerPipelineOptions,
  source_pool~ : @semantic.ProgramManifest = @semantic.ProgramManifest::new([]),
) -> Result[@semantic.ProgramManifest, CompilerCompilationError] {
  compiler_expand_transform_import_closure(
    manifest, source_pool, sources, options,
  )
}
