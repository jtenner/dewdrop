///|
/// Keep the selected package's source bytes available for imports that a
/// transform can add. Collection and parse-event preparation still select only
/// the modules required by the expanded program.
pub fn load_compilation_standard_sources(
  root : String,
  manifest : @semantic.ProgramManifest,
  default_preamble : Bool,
) -> Result[@standard_loader.StandardLibraryLoad, String] {
  let has_transforms = manifest.modules.any(fn(module_) {
    module_.files.any(fn(file) {
      @transforms.contains_transform_syntax(file.source)
    })
  })
  @standard_loader.load_for_manifest_with_fingerprint(
    root,
    transform_loading_manifest(manifest),
    default_preamble,
    include_all_sources=has_transforms,
  )
}
