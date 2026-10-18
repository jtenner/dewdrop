# Match coverage for generic and trait values

The native flow checker grouped valid generic, trait, Self, and projected types
with error types. That skipped the complete coverage check. For example:

```dew
fn bad<t>(value: t) -> I32 {
  match value {
    _ if false => 42
  }
}
```

The old native compiler accepted this function. Calling `bad(7)` produced a
WebAssembly `unreachable` trap. The same match over Bool was rejected.

Valid opaque types now use the open coverage domain. They need an unguarded
catch-all pattern. Actual error and unresolved inference-variable types still
suppress dependent coverage errors. Invalid pattern suppression is unchanged.
The Dew compiler already used the open domain for valid opaque types; explicit
arms and shared regression cases now record that rule in both compilers.

The tests cover empty generic matches, guarded-only generic and trait matches,
guarded-only generic loops, and valid unconditional catch-all cases. The existing
invalid-pattern test checks that error suppression remains in place.

## Validation

The new native regression failed before the fix (one of two tests failed in
7.433 seconds). After the fix, both tests passed in 7.583 seconds. The complete
native flow file passed all 25 tests in 0.040 seconds, including the existing
invalid-pattern suppression case:

```sh
DEW_NATIVE_TEST_PACKAGES=semantic/body_flow_wbtest.mbt tools/test-native.sh
```

The two Dew parity tests pass in 0.061 seconds. Their test module was generated
in 4.545 seconds and linked in 1.068 seconds with the prebuilt native tools.
No Dew behavior change was needed.
The original failing program and measured command output are stored in the
language improvement review evidence for 2026-10-18.
