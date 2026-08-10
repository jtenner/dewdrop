///|
/// Resolves standard interfaces from the persistent cache when available,
/// analyzes all executable bodies normally, and stores one deterministic
/// standard-interface bundle after a miss.
pub fn analyze_program_with_interface_bundle_cache(
  program : @semantic.CollectedProgram,
  loaded : StandardLibraryLoad,
  root_module_index? : Int = 0,
) -> Result[CachedInterfaceBundleAnalysis, String] {
  let cached : Array[@semantic.FrozenModuleInterface?] = Array::make(
    program.modules.length(),
    None,
  )
  let mut status = InterfaceBundleCacheWasDisabled
  let mut miss = false
  let key = interface_bundle_cache_key(loaded)
  let policy = InterfaceBundlePolicy::for_compilation(loaded, root_module_index)
  match lookup_interface_bundle(program, key, policy) {
    Err(error) => return Err(error)
    Ok(InterfaceBundleCacheDisabled) => ()
    Ok(InterfaceBundleCacheMiss) => {
      status = InterfaceBundleCacheWasMiss
      miss = true
    }
    Ok(InterfaceBundleCacheHit(slots)) => {
      status = InterfaceBundleCacheWasHit
      for index, slot in slots {
        cached[index] = slot
      }
    }
  }
  let analyzed = @semantic.analyze_program_semantics_with_cached_interfaces(
    program, cached,
  )
  if miss && policy.store_on_miss {
    match
      store_interface_bundle(program, analyzed.frozen.interfaces, key, policy) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  Ok({ analyzed, status })
}
