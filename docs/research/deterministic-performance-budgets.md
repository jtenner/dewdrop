# Deterministic Wasm performance budgets

Date: 2026-08-03

## Status

`tools/wasm-metrics.mjs` measures compiler-owned static output costs from one pinned WAT snapshot and its generated Wasm binary. An optional JSON budget fails visibly when a metric leaves its declared exact/minimum/maximum range.

The initial deterministic metrics are:

- encoded Wasm and printed WAT byte size;
- type, function, global, import, and export counts;
- deterministic `$dew$<carrier,...>` adapter export count;
- direct `call`, `call_ref`, and `return_call_ref` counts;
- `struct.new` and `array.new*` allocation-site counts;
- `ref.cast` and `ref.test` counts;
- local read/write instruction counts.

The tool reports JSON in a fixed field order. Budgets use non-negative integer bounds and reject unknown metrics or malformed constraints rather than silently skipping them.

## Initial gates

`tests/performance-budgets/closure-directization.json` requires the allocation-free callback path to retain zero `call_ref`, `return_call_ref`, `ref.cast`, and `ref.test` instructions. It also bounds binary/text size, function/type counts, and the remaining standard assertion string allocation sites.

`tests/performance-budgets/generic-erased-scalar-adapter.json` requires exactly five scalar adapter exports and bounds the box allocation, dynamic closure call, cast/test, type, function, and output-size costs of the erased generic scalar ABI.

`tools/check.sh` builds both production modules and validates the budgets. The generated JSON metric reports remain under `.tmp/` for diagnosis.

## Interpretation

Static instruction counts are compiler regression gates, not runtime timing claims. One instruction site may execute zero, one, or many times. The initial budgets intentionally cover two high-value invariants:

1. transparent callback directization must not reintroduce closure dispatch;
2. scalar erased-boundary support must not grow adapter count, box sites, or cast/call machinery without an explicit budget update.

Budget changes should be reviewed with the implementation and snapshots in the same atomic commit. A semantic improvement may intentionally increase one count while reducing runtime work elsewhere; in that case the rationale belongs in this document.

## Remaining work

- Add recursive aggregate, enum, callback-wrapper, mutable-cell, imported specialization, and package-consumer budgets.
- Distinguish compiler-generated generic box/allocation sites from standard-library assertion/string sites using stable producer metadata or named custom sections.
- Record materialized specialization count directly instead of inferring only exported adapter count.
- Add deterministic compile/validation/encoding timing harnesses with warmup and variance reporting.
- Add Node and Wago runtime workloads after focused Wago closure compatibility is green.
- Track peak compiler and runtime memory separately from static binary metrics.
