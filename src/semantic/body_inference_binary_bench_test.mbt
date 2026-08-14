///|
fn binary_body_benchmark_module() -> CollectedModule {
  let source = Buffer()
  for index in 0..<192 {
    source.write_string_utf8(
      "fn value_\{index}(input: I32) -> I32 {\n  let captured = input + \{index}\n  let apply = fn(value: I32) -> I32 {\n    value + captured\n  }\n  apply(input)\n}\n",
    )
  }
  collect_bytes(23900UL, source.to_bytes())
}

///|
fn binary_body_benchmark_inferred() -> InferredModuleBodies {
  let collected = binary_body_benchmark_module()
  infer_module_bodies(
    collected,
    resolve_module_types(collected),
    resolve_module_names(collected),
  )
}

///|
test "bench complete body binary encode 192 functions" (it : @bench.T) {
  let inferred = binary_body_benchmark_inferred()
  it.bench(fn() {
    let encoded = serialize_inferred_module_bodies(inferred).unwrap()
    it.keep(encoded.length())
  })
}

///|
test "bench complete body binary decode 192 functions" (it : @bench.T) {
  let encoded = serialize_inferred_module_bodies(
    binary_body_benchmark_inferred(),
  ).unwrap()
  it.bench(fn() {
    let decoded = deserialize_inferred_module_bodies(encoded).unwrap()
    it.keep(decoded.expression_types.length())
  })
}

///|
test "bench complete body legacy JSON encode 192 functions" (it : @bench.T) {
  let inferred = binary_body_benchmark_inferred()
  it.bench(fn() {
    let encoded = @utf8.encode(inferred.to_json().stringify())
    it.keep(encoded.length())
  })
}

///|
test "bench complete body legacy JSON decode 192 functions" (it : @bench.T) {
  let encoded = @utf8.encode(
    binary_body_benchmark_inferred().to_json().stringify(),
  )
  it.bench(fn() {
    let text = @utf8.decode(encoded) catch { _ => abort("valid UTF-8") }
    let json = @json.parse(text) catch { _ => abort("valid JSON") }
    let decoded : InferredModuleBodies = @json.from_json(json) catch {
      _ => abort("valid inferred-body JSON")
    }
    it.keep(decoded.expression_types.length())
  })
}

///|
test "bench fresh inference 192 functions" (it : @bench.T) {
  let collected = binary_body_benchmark_module()
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.expression_types.length())
  })
}

///|
fn binary_family_benchmark() -> (
  CollectedModule,
  ResolvedModuleTypes,
  ResolvedModuleNames,
  BodyInferenceFamilyAnalysis,
) {
  let collected = binary_body_benchmark_module()
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let cold = infer_module_bodies_with_family_cache(
    collected,
    resolved,
    names,
    Array::make(collected.bodies.length(), None),
  ).unwrap()
  (collected, resolved, names, cold)
}

///|
fn binary_family_benchmark_artifact() -> BodyInferenceFamilyArtifact {
  let (_, _, _, cold) = binary_family_benchmark()
  cold.families[191].unwrap()
}

///|
test "bench family artifact binary encode" (it : @bench.T) {
  let artifact = binary_family_benchmark_artifact()
  it.bench(fn() {
    let encoded = serialize_body_inference_family_artifact(artifact).unwrap()
    it.keep(encoded.length())
  })
}

///|
test "bench family artifact binary decode" (it : @bench.T) {
  let encoded = serialize_body_inference_family_artifact(
    binary_family_benchmark_artifact(),
  ).unwrap()
  it.bench(fn() {
    let artifact = deserialize_body_inference_family_artifact(encoded).unwrap()
    it.keep(artifact.root.expression_types.length())
  })
}

///|
test "bench family artifact legacy JSON encode" (it : @bench.T) {
  let artifact = binary_family_benchmark_artifact()
  it.bench(fn() {
    let encoded = @utf8.encode(artifact.to_json().stringify())
    it.keep(encoded.length())
  })
}

///|
test "bench family artifact legacy JSON decode" (it : @bench.T) {
  let encoded = @utf8.encode(
    binary_family_benchmark_artifact().to_json().stringify(),
  )
  it.bench(fn() {
    let text = @utf8.decode(encoded) catch { _ => abort("valid UTF-8") }
    let json = @json.parse(text) catch { _ => abort("valid JSON") }
    let artifact : BodyInferenceFamilyArtifact = @json.from_json(json) catch {
      _ => abort("valid family JSON")
    }
    it.keep(artifact.root.expression_types.length())
  })
}

///|
test "bench family bundle binary index lookup and decode" (it : @bench.T) {
  let (_, _, _, cold) = binary_family_benchmark()
  let fingerprints : Array[String] = []
  let artifacts : Array[BodyInferenceFamilyArtifact] = []
  for index, artifact in cold.families {
    match artifact {
      Some(value) => {
        fingerprints.push(
          @crypto.bytes_to_hex_string(
            @crypto.sha256(@utf8.encode("family-\{index}")),
          ),
        )
        artifacts.push(value)
      }
      None => ()
    }
  }
  let encoded = serialize_body_inference_family_bundle(
    make_body_inference_family_bundle(
      artifacts[0].module_id,
      fingerprints,
      artifacts,
    ).unwrap(),
  ).unwrap()
  let index = open_body_inference_family_bundle(encoded).unwrap()
  let wanted = @crypto.sha256(@utf8.encode("family-191"))
  it.bench(fn() {
    let artifact = index.lookup(wanted).unwrap().unwrap()
    it.keep(artifact.root.expression_types.length())
  })
}

///|
test "bench one family miss mixed with cached families" (it : @bench.T) {
  let (collected, resolved, names, cold) = binary_family_benchmark()
  let cached = cold.families.copy()
  cached[191] = None
  it.bench(fn() {
    let mixed = infer_module_bodies_with_family_cache(
      collected, resolved, names, cached,
    ).unwrap()
    it.keep(mixed.family_hits)
  })
}
