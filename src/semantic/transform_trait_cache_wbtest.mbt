///|
fn trait_cache_fixture() -> (
  CollectedModule,
  ResolvedModuleTypes,
  ResolvedModuleNames,
  BodyInferenceFamilyAnalysis,
) raise {
  let collected = collect_bytes(
    23802UL, b"trait Read<t> {\n fn read(self) -> I32\n}\nstruct Value {}\nimpl Read<I32> for Value {\n fn read(self) -> I32 {\n 42i32\n }\n}\nfn invoke(value: Read<I32>) -> I32 {\n value.read()\n}\nfn main() -> I32 {\n invoke(Value::{})\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let cold = infer_module_bodies_with_family_cache(
    collected,
    resolved,
    names,
    Array::make(collected.bodies.length(), None),
  ).unwrap()
  assert_eq(cold.inferred.diagnostics, [])
  (collected, resolved, names, cold)
}

///|
test "trait target types survive module and family serialization" {
  let (collected, resolved, names, cold) = trait_cache_fixture()
  let encoded = serialize_inferred_module_bodies(cold.inferred).unwrap()
  assert_eq(deserialize_inferred_module_bodies(encoded).unwrap(), cold.inferred)
  let mut found = false
  let families = cold.families.copy()
  for index, saved in families {
    if saved is Some(family) &&
      family.root.trait_object_coercions.any(coercion => {
        coercion is SelectedInferredTraitObjectCoercion(_, _, _)
      }) {
      found = true
      let bytes = serialize_body_inference_family_artifact(family).unwrap()
      let decoded = deserialize_body_inference_family_artifact(bytes).unwrap()
      assert_eq(decoded, family)
      families[index] = Some(decoded)
    }
  }
  assert_true(found)
  let hit = infer_module_bodies_with_family_cache(
    collected, resolved, names, families,
  ).unwrap()
  assert_eq(hit.inferred, cold.inferred)
  assert_eq(hit.family_misses, 0)
}

///|
test "a trait target alone retains its applied type through family merge" {
  let (collected, resolved, names, cold) = trait_cache_fixture()
  let mut found = false
  for family_index, saved in cold.families {
    if saved is Some(family) {
      for index, coercion in family.root.trait_object_coercions {
        if coercion is SelectedInferredTraitObjectCoercion(trait_, evidence, _) {
          found = true
          let mut base = -1
          for id, type_ in resolved.types {
            if type_ is TraitType(declaration) && declaration == trait_ {
              base = -id - 2
            }
          }
          assert_true(base < -1)
          let arguments = family.root.type_arguments.copy()
          let start = arguments.length()
          arguments.push(-resolved.primitive(I32Type) - 2)
          let types = family.root.types.copy()
          let expected = types.length()
          types.push(BodyAppliedType(base, { start, length: 1, }))
          let coercions = family.root.trait_object_coercions.copy()
          coercions[index] = SelectedInferredTraitObjectCoercion(
            trait_, evidence, expected,
          )
          let changed = {
            ..family,
            root: {
              ..family.root,
              types,
              type_arguments: arguments,
              trait_object_coercions: coercions,
            },
          }
          let decoded = deserialize_body_inference_family_artifact(
            serialize_body_inference_family_artifact(changed).unwrap(),
          ).unwrap()
          assert_eq(decoded, changed)
          let families = cold.families.copy()
          families[family_index] = Some(decoded)
          let hit = infer_module_bodies_with_family_cache(
            collected, resolved, names, families,
          ).unwrap()
          assert_eq(hit.family_misses, 0)
          assert_eq(hit.inferred.diagnostics, [])
          assert_true(
            hit.inferred.trait_object_coercions.any(coercion => {
              match coercion {
                SelectedInferredTraitObjectCoercion(_, _, target) =>
                  target >= 0 &&
                  hit.inferred.type_term(target) is BodyAppliedType(_, _)
                _ => false
              }
            }),
          )
        }
      }
    }
  }
  assert_true(found)
}

///|
test "trait target types reject invalid module and family indexes" {
  let (collected, resolved, names, cold) = trait_cache_fixture()
  let mut found = false
  for index, coercion in cold.inferred.trait_object_coercions {
    if coercion is SelectedInferredTraitObjectCoercion(trait_, evidence, _) {
      found = true
      for bad in [-1, 2147483647] {
        let coercions = cold.inferred.trait_object_coercions.copy()
        coercions[index] = SelectedInferredTraitObjectCoercion(
          trait_, evidence, bad,
        )
        let invalid = { ..cold.inferred, trait_object_coercions: coercions, }
        assert_true(
          deserialize_inferred_module_bodies(
            serialize_inferred_module_bodies(invalid).unwrap(),
          )
          is Err(_),
        )
      }
    }
  }
  assert_true(found)
  for family_index, saved in cold.families {
    if saved is Some(family) {
      for index, coercion in family.root.trait_object_coercions {
        if coercion is SelectedInferredTraitObjectCoercion(trait_, evidence, _) {
          for bad in [-1, 2147483647, -2147483648] {
            let coercions = family.root.trait_object_coercions.copy()
            coercions[index] = SelectedInferredTraitObjectCoercion(
              trait_, evidence, bad,
            )
            let invalid = {
              ..family,
              root: { ..family.root, trait_object_coercions: coercions, },
            }
            let families = cold.families.copy()
            families[family_index] = Some(
              deserialize_body_inference_family_artifact(
                serialize_body_inference_family_artifact(invalid).unwrap(),
              ).unwrap(),
            )
            assert_true(
              infer_module_bodies_with_family_cache(
                collected, resolved, names, families,
              )
              is Err(_),
            )
          }
        }
      }
    }
  }
}
