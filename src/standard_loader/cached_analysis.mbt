///|
/// Resolves standard/dependency and ordinary workspace interfaces from the
/// persistent cache when available, analyzes all executable bodies normally,
/// and publishes deterministic interface artifacts after misses.
pub fn analyze_program_with_interface_bundle_cache(
  program : @semantic.CollectedProgram,
  loaded : StandardLibraryLoad,
  root_module_index? : Int = 0,
  pack? : CompilationCachePack? = None,
) -> Result[CachedInterfaceBundleAnalysis, String] {
  let cached : Array[@semantic.FrozenModuleInterface?] = Array::make(
    program.modules.length(),
    None,
  )
  let key = interface_bundle_cache_key(loaded, program=Some(program))
  let policy = InterfaceBundlePolicy::for_compilation(loaded, root_module_index)
  let mut hits = 0
  let mut misses = 0
  let mut bundle_miss = false
  match lookup_interface_bundle(program, key, policy, pack~) {
    Err(error) => return Err(error)
    Ok(InterfaceBundleCacheDisabled) => ()
    Ok(InterfaceBundleCacheMiss) => {
      for index, _ in program.modules {
        if interface_bundle_module_is_cacheable(program, index, policy) {
          misses += 1
        }
      }
      bundle_miss = true
    }
    Ok(InterfaceBundleCacheHit(slots)) =>
      for index, slot in slots {
        match slot {
          Some(interface_) => {
            cached[index] = Some(interface_)
            hits += 1
          }
          None => ()
        }
      }
  }
  let graph = @semantic.build_module_dependency_graph(program)
  let workspace_keys : Array[String?] = Array::make(
    program.modules.length(),
    None,
  )
  let workspace_attempted = Array::make(program.modules.length(), false)
  let workspace_scc_keys : Array[String?] = Array::make(
    program.modules.length(),
    None,
  )
  let workspace_scc_attempted = Array::make(program.modules.length(), false)
  let mut cache_error : String? = None
  let frozen = @semantic.freeze_program_interfaces_with_cache_hooks(
    program,
    cached,
    fn(module_index, slots) {
      if cache_error is Some(_) ||
        !workspace_module_cache_is_eligible(
          program, graph, module_index, policy,
        ) {
        return None
      }
      let workspace_key = match
        workspace_interface_cache_key(program, graph, module_index, slots) {
        Some(value) => value
        None => return None
      }
      workspace_keys[module_index] = Some(workspace_key)
      workspace_attempted[module_index] = true
      match
        lookup_workspace_interface(
          program,
          graph,
          module_index,
          slots,
          workspace_key,
          pack~,
        ) {
        Err(error) => {
          cache_error = Some(error)
          None
        }
        Ok(Some(interface_)) => {
          hits += 1
          Some(interface_)
        }
        Ok(None) => {
          misses += 1
          None
        }
      }
    },
    fn(module_index, interface_) {
      if cache_error is Some(_) || !workspace_attempted[module_index] {
        return
      }
      match workspace_keys[module_index] {
        Some(workspace_key) =>
          match store_workspace_interface(workspace_key, interface_, pack~) {
            Ok(_) => ()
            Err(error) => cache_error = Some(error)
          }
        None => ()
      }
    },
    fn(scc, members, slots) {
      if cache_error is Some(_) ||
        !workspace_interface_scc_cache_is_eligible(
          program, scc, members, policy,
        ) {
        return
      }
      let representative = members[scc.start]
      let workspace_key = match
        workspace_interface_scc_cache_key(program, graph, scc, members, slots) {
        Some(value) => value
        None => return
      }
      workspace_scc_keys[representative] = Some(workspace_key)
      workspace_scc_attempted[representative] = true
      match
        lookup_workspace_interface_scc(
          program,
          graph,
          scc,
          members,
          slots,
          workspace_key,
          pack~,
        ) {
        Err(error) => cache_error = Some(error)
        Ok(true) => hits += scc.length
        Ok(false) => misses += scc.length
      }
    },
    fn(scc, members, slots) {
      let representative = members[scc.start]
      if cache_error is Some(_) || !workspace_scc_attempted[representative] {
        return
      }
      match workspace_scc_keys[representative] {
        Some(workspace_key) =>
          match
            store_workspace_interface_scc(
              workspace_key,
              scc,
              members,
              slots,
              pack~,
            ) {
            Ok(_) => ()
            Err(error) => cache_error = Some(error)
          }
        None => ()
      }
    },
  )
  match cache_error {
    Some(error) => return Err(error)
    None => ()
  }
  let body_cached = match
    analyze_program_semantics_with_body_cache(program, frozen, pack~) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let analyzed = body_cached.analyzed
  if bundle_miss && policy.store_on_miss {
    match
      store_interface_bundle(program, frozen.interfaces, key, policy, pack~) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  Ok({
    analyzed,
    status: { enabled: policy.enabled && key.fingerprint != "", hits, misses, },
    body_cache_status: body_cached.status,
  })
}
