# Self-hosted imported value types

The Dew compiler rejected `@constants.factor` in a module value initializer.
The native compiler accepted the same program. The Dew compiler reported
`INV-002` with `UnsupportedExpressionInference`.

Two missing steps caused this fault:

- Dew selected qualified import members only for calls and constructors. A
  qualified module value did not get its imported declaration or type.
- Dew froze public `let` declarations with `resolved.declaration_type()`. That
  table contains signature types, so a value initializer exported an error
  type. Native code freezes the inferred initializer type instead.

The fix selects public values through the module import scope and records their
declaration identities. Lowering uses those identities for `PlannedModuleValueGet`.
The import alias is consumed only after both the declaration and type are found.
Public initializer types are inferred before the final module interface is
frozen, in the existing dependency order. Primitive types remain direct type
references. Compound types use the existing type interner. Modules with no public
values skip this extra inference step.

The new regressions check:

- An imported I32 constant in a module initializer and function body, including
  both declaration reads in the lowered plan.
- Imported product and callback values that become public module values. Their
  exported types must retain their field, parameter, and result types.

## Validation

The local test harness is `.tmp/imported-constant-regression/run.sh`. It runs the
release native `dew_test_gen` and `self_host_link_fixture` binaries, then runs
`node tools/dew-test/run.mjs` on the resulting Wasm module. The harness uses all
production Dew compiler sources, the Starshine FFI source, and the five test
files below:

```text
self_host/compiler/semantic_imported_semantics_test.dew
self_host/compiler/semantic_imported_selection_test.dew
self_host/compiler/semantic_module_interfaces_test.dew
self_host/compiler/semantic_module_value_inference_test.dew
self_host/compiler/semantic_variant_selection_test.dew
```

The first regression failed before the fix with
`constant initializer has a resolved type`. Test generation took 4.943 seconds,
linking took 1.103 seconds, and execution took 0.066 seconds.

After the fix, the focused regression passed. Test generation took 4.981 seconds,
linking took 1.105 seconds, and execution took 0.062 seconds. The full related
set then passed all 57 tests. Test generation took 5.096 seconds, linking took
1.117 seconds, and execution took 0.150 seconds. These single runs establish
correct behavior; they do not establish a performance gain or memory bound.

No Moon build command was needed, so these checks had no Moon lock delay. The
separate final bootstrap and real transform request checks cover the complete
self-hosted compiler build.
