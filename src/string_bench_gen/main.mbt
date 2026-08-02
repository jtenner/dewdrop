///|
fn string_benchmark_fail(message : String) -> Unit {
  println("DEW_INTERNAL \{message}")
  @sys.exit(1)
}

///|
fn string_benchmark_error(message : String) -> Unit {
  println("DEW_ERROR")
  println(message)
  println("DEW_END")
}

///|
fn compile_string_benchmark(source : Bytes) -> Bytes {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("bench.main", [
      @semantic.ManifestFile::new("bench.dew", source),
    ]),
  ])
  let loaded = match
    @standard_loader.load_default_for_manifest_with_fingerprint(manifest, true) {
    Ok(loaded) => loaded
    Err(error) => {
      string_benchmark_fail(error)
      @standard_loader.StandardLibraryLoad::bootstrap()
    }
  }
  let program = @semantic.collect_program_manifest_with_standard_sources(
    2700UL,
    manifest,
    loaded.sources,
    true,
  )
  let analyzed = match
    @standard_loader.analyze_program_with_standard_cache(program, loaded) {
    Ok(cached) => cached.analyzed
    Err(error) => {
      string_benchmark_fail(error)
      abort("unreachable cache failure")
    }
  }
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  let mut diagnostics = program.diagnostics.length() +
    analyzed.frozen.graph.diagnostics.length() +
    analyzed.frozen.import_diagnostics.length() +
    link.diagnostics.length()
  for module_ in program.modules {
    diagnostics += module_.diagnostics.length()
  }
  for interface_ in analyzed.frozen.interfaces {
    diagnostics += interface_.resolved_types.diagnostics.length()
  }
  for module_ in analyzed.modules {
    diagnostics += module_.names.diagnostics.length() +
      module_.inferred.diagnostics.length()
  }
  for module_ in lowering.modules {
    diagnostics += module_.diagnostics.length()
  }
  if diagnostics != 0 {
    for diagnostic in program.diagnostics {
      string_benchmark_error(@debug.to_string(diagnostic))
    }
    for module_ in program.modules {
      for diagnostic in module_.diagnostics {
        string_benchmark_error(@debug.to_string(diagnostic))
      }
    }
    for diagnostic in analyzed.frozen.graph.diagnostics {
      string_benchmark_error(@debug.to_string(diagnostic))
    }
    for diagnostic in analyzed.frozen.import_diagnostics {
      string_benchmark_error(@debug.to_string(diagnostic))
    }
    for interface_ in analyzed.frozen.interfaces {
      for diagnostic in interface_.resolved_types.diagnostics {
        string_benchmark_error(@debug.to_string(diagnostic))
      }
    }
    for module_ in analyzed.modules {
      for diagnostic in module_.names.diagnostics {
        string_benchmark_error(@debug.to_string(diagnostic))
      }
      for diagnostic in module_.inferred.impl_index.diagnostics {
        string_benchmark_error(@debug.to_string(diagnostic))
      }
      for diagnostic in module_.inferred.diagnostics {
        string_benchmark_error(@debug.to_string(diagnostic))
      }
    }
    for module_ in lowering.modules {
      for diagnostic in module_.diagnostics {
        string_benchmark_error(@debug.to_string(diagnostic))
      }
    }
    for diagnostic in link.diagnostics {
      string_benchmark_error(@debug.to_string(diagnostic))
    }
    string_benchmark_fail(
      "String benchmark source produced \{diagnostics} compiler diagnostics",
    )
  }
  match @backend.emit_starshine_program_binary(lowering, link) {
    Ok(binary) => binary
    Err(error) => {
      string_benchmark_fail(@debug.to_string(error))
      b""
    }
  }
}

///|
fn main {
  let source = @fs.read_file_to_bytes(
    "tools/wago-string-bench/string_bench.dew",
  ) catch {
    error => abort(error.to_string())
  }
  let binary = compile_string_benchmark(source)
  @fs.write_bytes_to_file("tools/wago-string-bench/string_bench.wasm", binary) catch {
    error => abort(error.to_string())
  }
  println("wrote tools/wago-string-bench/string_bench.wasm")
}
