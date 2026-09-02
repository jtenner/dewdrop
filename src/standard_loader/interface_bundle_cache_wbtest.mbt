///|
test "bootstrap and on-disk standard providers are byte identical" {
  let bootstrap = bootstrap_standard_library_sources()
  let on_disk = load(".").unwrap()
  assert_eq(bootstrap.paths, on_disk.paths)
  assert_eq(bootstrap.sources.length(), on_disk.sources.length())
  for index = 0; index < bootstrap.sources.length(); index = index + 1 {
    if bootstrap.sources[index] != on_disk.sources[index] {
      fail("bootstrap source differs: \{bootstrap.paths[index]}")
    }
  }
}

///|
test "interface bundle envelopes preserve payload, kind, and provenance" {
  let payload = b"frozen interfaces"
  let standard = wrap_standard_interface_cache_payload("standard", payload).unwrap()
  assert_eq(
    unwrap_standard_interface_cache_payload(standard, "standard"),
    Ok(payload),
  )
  assert_true(
    unwrap_standard_interface_cache_payload(standard, "changed") is Err(_),
  )
  assert_true(
    unwrap_workspace_interface_cache_payload(standard, "standard") is Err(_),
  )
  assert_true(
    unwrap_standard_interface_cache_payload(b"bad", "standard") is Err(_),
  )
  for cut in 0..<standard.length() {
    let truncated = Buffer(size_hint=cut)
    for index in 0..<cut {
      truncated.write_byte(standard[index])
    }
    assert_true(
      unwrap_standard_interface_cache_payload(truncated.to_bytes(), "standard")
      is Err(_),
    )
  }
  for selected in 0..<standard.length() {
    let mutated = Buffer(size_hint=standard.length())
    for index in 0..<standard.length() {
      mutated.write_byte(
        if index == selected {
          standard[index] ^ 0x80
        } else {
          standard[index]
        },
      )
    }
    assert_true(
      unwrap_standard_interface_cache_payload(mutated.to_bytes(), "standard")
      is Err(_),
    )
  }
  let workspace = wrap_workspace_interface_cache_payload("workspace", payload).unwrap()
  assert_eq(
    unwrap_workspace_interface_cache_payload(workspace, "workspace"),
    Ok(payload),
  )
  for cut in 0..<workspace.length() {
    let truncated = Buffer(size_hint=cut)
    for index in 0..<cut {
      truncated.write_byte(workspace[index])
    }
    assert_true(
      unwrap_workspace_interface_cache_payload(
        truncated.to_bytes(),
        "workspace",
      )
      is Err(_),
    )
  }
  for selected in 0..<workspace.length() {
    let mutated = Buffer(size_hint=workspace.length())
    for index in 0..<workspace.length() {
      mutated.write_byte(
        if index == selected {
          workspace[index] ^ 0x40
        } else {
          workspace[index]
        },
      )
    }
    assert_true(
      unwrap_workspace_interface_cache_payload(mutated.to_bytes(), "workspace")
      is Err(_),
    )
  }
}

///|
test "interface bundle policy selects standard and dependency modules explicitly" {
  let program = @semantic.collect_program_manifest(
    23000UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("dep.value", [
        @semantic.ManifestFile::new(
          "dep.dew", b"pub fn value() -> I32 {\n  1\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dep.value\npub fn run() -> I32 {\n  value()\n}\n",
        ),
      ]),
    ]),
  )
  let policy : InterfaceBundlePolicy = {
    enabled: true,
    store_on_miss: true,
    root_module_index: 1,
    include_dependencies: true,
  }
  assert_true(interface_bundle_module_is_cacheable(program, 0, policy))
  assert_false(interface_bundle_module_is_cacheable(program, 1, policy))
  for index in 2..<program.modules.length() {
    assert_true(interface_bundle_module_is_cacheable(program, index, policy))
  }
}

///|
test "workspace interface keys include exact source and dependency evidence" {
  let program = @semantic.collect_program_manifest(
    23010UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("dep.value", [
        @semantic.ManifestFile::new(
          "dep.dew", b"pub fn value() -> I32 {\n  1\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.library", [
        @semantic.ManifestFile::new(
          "library.dew", b"open dep.value\npub fn read() -> I32 {\n  value()\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.library\npub fn main() -> I32 {\n  read()\n}\n",
        ),
      ]),
    ]),
  )
  let frozen = @semantic.freeze_program_interfaces(program)
  let graph = frozen.graph
  let cached : Array[@semantic.FrozenModuleInterface?] = Array::make(
    program.modules.length(),
    None,
  )
  for index, interface_ in frozen.interfaces {
    cached[index] = Some(interface_)
  }
  cached[1] = None
  let source_fingerprint = workspace_interface_source_fingerprint(program, 1)
  let dependency_records : Array[String] = []
  let dependencies = graph.dependencies[1]
  for edge in 0..<dependencies.length {
    let dependency = frozen.interfaces[graph.dependency_modules[dependencies.start +
      edge]]
    dependency_records.push(
      dependency.path + "\u0000" + dependency.content_fingerprint,
    )
  }
  let key = workspace_interface_cache_key_from_dependency_records(
    source_fingerprint, dependency_records,
  )
  dependency_records.push("changed\u0000fingerprint")
  assert_true(
    workspace_interface_cache_key_from_dependency_records(
      source_fingerprint, dependency_records,
    ) !=
    key,
  )
  assert_eq(
    workspace_interface_cache_key(program, graph, 1, cached).unwrap(),
    key,
  )
  cached[0] = None
  assert_true(workspace_interface_cache_key(program, graph, 1, cached) is None)
}

///|
test "workspace cache routes cyclic SCCs through aggregate eligibility" {
  let program = @semantic.collect_program_manifest(
    23020UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.left", [
        @semantic.ManifestFile::new(
          "left.dew", b"open app.right\npub fn left() -> I32 {\n  1\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.right", [
        @semantic.ManifestFile::new(
          "right.dew", b"open app.left\npub fn right() -> I32 {\n  2\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.left\npub fn main() -> I32 {\n  left()\n}\n",
        ),
      ]),
    ]),
  )
  let graph = @semantic.build_module_dependency_graph(program)
  let policy : InterfaceBundlePolicy = {
    enabled: true,
    store_on_miss: true,
    root_module_index: 2,
    include_dependencies: false,
  }
  assert_false(workspace_module_cache_is_eligible(program, graph, 0, policy))
  assert_false(workspace_module_cache_is_eligible(program, graph, 1, policy))
  assert_false(workspace_module_cache_is_eligible(program, graph, 2, policy))
  let mut found_cycle = false
  for scc in graph.sccs {
    if scc.length == 2 {
      found_cycle = true
      assert_true(
        workspace_interface_scc_cache_is_eligible(
          program,
          scc,
          graph.scc_modules,
          policy,
        ),
      )
      let frozen = @semantic.freeze_program_interfaces(program)
      let cached : Array[@semantic.FrozenModuleInterface?] = Array::make(
        program.modules.length(),
        None,
      )
      for index in 3..<program.modules.length() {
        cached[index] = Some(frozen.interfaces[index])
      }
      assert_true(
        workspace_interface_scc_cache_key(
          program,
          graph,
          scc,
          graph.scc_modules,
          cached,
        )
        is Some(_),
      )
    }
  }
  assert_true(found_cycle)
  for index in 3..<program.modules.length() {
    assert_false(
      workspace_module_cache_is_eligible(program, graph, index, policy),
    )
  }
}

///|
test "interface bundle cache key includes dependency provenance" {
  let base : StandardLibraryLoad = {
    sources: @semantic.StandardLibrarySources::bootstrap(),
    fingerprint: "standard",
    dependency_fingerprint: "",
    cacheable: true,
  }
  let dependency = { ..base, dependency_fingerprint: "dependency", }
  assert_eq(interface_bundle_cache_key(base).fingerprint, "standard")
  assert_true(interface_bundle_cache_key(dependency).fingerprint != "standard")
}
