# Common closure type checks

Date: 2026-10-19. Baseline: `f427d03938`.

## Scope

The native MoonBit compiler now checks the common closure type before it reads
that type during linking or emission. The module-only code and module emission
paths use the same check. This change does not add a Dew self-host check.

`verify_module_closure_type` checks these rules:

- `closure_type_index` is `-1` when the module has no common closure type.
- A present index is in the physical type array. Its kind is exactly
  `PlannedWasmClosureType`. Its stored type index equals the array index.
- Its field span is valid and has one field.
- The field has physical index zero, role `WasmClosureEntryField`, exact storage
  `WasmNullableFunctionRefStorage`, and no write access.
- Each declared common closure type has the exact lookup. An orphan or duplicate
  common closure type is an error.

Each bound is checked before the related array read. Field-span bounds use
subtraction after the start bound, so an added span length cannot overflow.

The helper scans physical types once. It creates no arrays, maps, or worklists.
Closure and `Result` allocation have not been measured in isolation. The parent
change records combined native compiler time, RSS, and size evidence.

## Error records

Planning errors retain all nine `ProgramPhysicalTypeFailure` fields, with phase
5. Backend errors copy the same fields, with phase 7, through
`starshine_physical_type_invariant_error`.

| Detail role | Check |
| --- | --- |
| 90 | Common closure index bound |
| 91 | Exact common closure kind |
| 92 | Stored physical type index |
| 93 | Field span bound |
| 94 | One entry field |
| 95 | Entry physical index |
| 96 | Entry field role |
| 97 | Immutable entry |
| 98 | Exact nullable function reference storage |
| 99 | Reverse common closure lookup |

Roles 91, 96, and 98 report expected `1` and actual `0`: the exact required kind
or role is absent. The field storage test covers every other storage variant.

Earlier tests of canonical common closure aliases now expect the module check
first. They use roles 94, 96, 97, and 98.

## Focused evidence

Logs are in `.tmp/closure-type-contracts`.

The first useful red run was:

```sh
DEW_NATIVE_TEST_PACKAGES=semantic tools/test-native.sh --filter 'common closure lookup rejects a wrong in-range physical type'
```

Before the fix, it failed because the corrupted lookup returned `Ok(())` instead
of the complete expected phase-5 error record. One test failed in 0.328 s. See
`red-semantic.log`. The first fixed run passed in 8.878 s. See
`green-semantic-initial.log`.

The full common closure semantic test file passed 8/8 in 10.886 s:

```sh
DEW_NATIVE_TEST_PACKAGES=semantic/closure_type_invariants_wbtest.mbt tools/test-native.sh
```

See `green-semantic.log`. Tests cover bad negative and upper bounds, exact type
identity, stored indices, orphan and duplicate types, invalid field spans, field
counts, physical field indices, roles, write access, and every other storage
variant. Valid inputs cover absent closures, named function values, captured
closures, generic templates, selected generics, and all three planning options.

The existing alias test file passed 8/8 in 2.433 s:

```sh
DEW_NATIVE_TEST_PACKAGES=semantic/program_physical_alias_invariants_wbtest.mbt tools/test-native.sh
```

See the alias part of `green-backend-alias.log`. That log also records a failed
backend test compilation caused by test code that tried to update read-only
semantic records from another package. The final backend tests use array changes
and donor records instead.

An earlier mistaken `-f` file-name filter ran zero tests. It is not evidence of
correctness. Moon uses `-f` for test-name globs. The package variable can name an
exact test file, as shown above.

## Final focused checks

The final shared gates include common closure, lambda function, and lambda
closure checks. All common closure tests passed with those gates in place:

| Exact test file | Passed | Wall time |
| --- | --- | --- |
| `src/backend/starshine_closure_type_contract_wbtest.mbt` | 7/7 | 2.666 s |
| `src/semantic/closure_type_invariants_wbtest.mbt` | 8/8 | 2.280 s |
| `src/semantic/program_physical_alias_invariants_wbtest.mbt` | 8/8 | 2.671 s |

Each file used `DEW_NATIVE_TEST_PACKAGES=<package>/<file>` with
`tools/test-native.sh`. All three exit codes were zero. Raw stdout, stderr, and
command/time/status JSON records were copied to `final-backend.*`,
`final-semantic.*`, and `final-alias.*` in `.tmp/closure-type-contracts`.

The backend tests validate valid present and absent closure modules with
Starshine. They compare every error field at program, module, and code-section
entry points. Corruptions cover wrong in-range type targets, bounds, stored
indices, entry positions and roles, duplicate types, and selected generic types.
The semantic tests cover the other immutable record fields directly.

An intermediate backend run found that the separate new lambda capture check
rejected a valid public generic export. Its diagnostic is in
`selected-generic-diagnostic.log`: code 301, phase 7, role 117. The lambda closure
change fixed that valid case. The final backend test validates that export before
it changes the common closure table.

## Related checks

The lambda closure change owns the relation between a lambda subtype and its
common closure base. The lambda function change owns function and entry-signature
maps. The shared gates run the common closure check before those lambda checks.
Their evidence is recorded with their own changes.
