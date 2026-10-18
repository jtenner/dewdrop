# Imported generic evidence fixture scope

The imported implementation-bound regression used every imported generic
implementation when it checked the test library's one `Marker` bound. Imports
also include compiler support modules. A generic inherent implementation from
one such module correctly has no trait bounds, so the unrelated fixture check
failed before it reached the test library.

The check now uses the implementation's owning semantic module ID. It still
requires exactly two implementations from the test library, exactly one bounded
implementation there, the exact imported `Marker` identity, and a visible
`NoMatchingMethod` error for `Box<No>`. No compiler behavior changed.

The focused failing test was reproduced in 7.676 seconds. After the scope fix,
all 17 tests in `generic_bounds_wbtest.mbt` pass in 8.277 seconds:

```sh
DEW_NATIVE_TEST_PACKAGES=semantic/generic_bounds_wbtest.mbt tools/test-native.sh
```

Exact commands and full output are retained in
`/tmp/dewdrop-review-2026-10-18/semantics/imported-bounds-investigation.json` and
`imported-bounds-green.json`.
