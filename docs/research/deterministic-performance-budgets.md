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

`tests/performance-budgets/generic-structural-callback-adapter.json` requires exactly three callback-bearing adapter exports, including a callback nested in another callback signature, retains the expected direct/environment-first wrapper dispatch sites, and bounds wrapper closure allocations, box sites, casts/tests, type/function growth, and output size.

`tests/performance-budgets/generic-aggregate-callback-adapter.json` requires exactly two adapter exports whose struct and enum payload conversion inserts callback wrappers. The runtime fixture also invokes callbacks loaded from an instantiated struct field and enum tuple/struct pattern bindings. The budget bounds synthetic callback signatures, wrapper and aggregate reconstruction sites, casts/tests, indirect calls, and output size.

`tests/performance-budgets/imported-package-callback-adapter.json` requires one root-owned adapter over an imported generic callback aggregate, retains zero indirect dispatch sites in the identity provider, and bounds linked type/function growth, direct calls, reconstruction sites, casts, and output size.

`tools/check.sh` builds all five production modules and validates the budgets. It also parses focused WasmGC struct and enum callback consumers, a standalone `eqref` identity consumer, and a `v128` identity consumer, links them against generated single- and multi-module providers, and requires every fully in-Wasm path to return `42`. Generated JSON metric and consumer reports remain under `.tmp/` for diagnosis.

## Interpretation

Static instruction counts are compiler regression gates, not runtime timing claims. One instruction site may execute zero, one, or many times. The initial budgets intentionally cover two high-value invariants:

1. transparent callback directization must not reintroduce closure dispatch;
2. scalar erased-boundary support must not grow adapter count, box sites, or cast/call machinery without an explicit budget update;
3. imported-package adapter linkage must remain compact and allocation-bounded while its external Wasm consumer stays executable.

Budget changes should be reviewed with the implementation and snapshots in the same atomic commit. A semantic improvement may intentionally increase one count while reducing runtime work elsewhere; in that case the rationale belongs in this document.

## Remaining work

- Add dedicated recursive aggregate, enum, cyclic-helper, mutable-cell, and direct specialization-count budgets.
- Distinguish compiler-generated generic box/allocation sites from standard-library assertion/string sites using stable producer metadata or named custom sections.
- Record materialized specialization count directly instead of inferring only exported adapter count.
- Add deterministic compile/validation/encoding timing harnesses with warmup and variance reporting.
- Add Node and Wago runtime workloads after focused Wago closure compatibility is green.
- Track peak compiler and runtime memory separately from static binary metrics.
