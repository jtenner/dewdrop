# B-tree step 1: storage primitives

Status: primitive exit checks passed. No B-tree engine or step-2 plan code.
No compiler change and no change to departures D1-D6.

Branch: `feat/btree-step-1-storage-primitives`.
Base and compiler source: `274ea5873deb4b239914ac76e89b6679ba34ac84`.
Design: `5922ea1a12ede3913f97b9b7bdac1f90343240f1`, with bbtree pinned at
`8adae97a0ed97e5c98fa2790312eb0aec9719846`.
All work and builds ran in `/home/dev/.t3/worktrees/dewdrop/t3-de40f005`.
The owner's main checkout was not used. The build-status document is unchanged.

## Repeat the checks

Build the tools separately so their costs stay visible:

```bash
source tools/self-host-common.sh
self_host_measure 'native CLI build' moon build --target native --release -j 8 src/dew_cli
self_host_measure 'native test generator build' moon build --target native --release -j 8 src/dew_test_gen
DEW_NATIVE_TEST_PACKAGES=semantic/module_private_fields_wbtest.mbt tools/test-native.sh
DEW_NATIVE_TEST_PACKAGES=semantic/compile_time_types_wbtest.mbt tools/test-native.sh --filter '*bitcast*'
DEW_NATIVE_TEST_PACKAGES=backend/starshine_raw_intrinsics_wbtest.mbt tools/test-native.sh --filter '*raw bit casts*'
DEW_INTEGRATION_TEST_FILES=src/backend/btree_storage_primitives_wbtest.mbt tools/test-integration-native.sh
python3 tools/test-btree-storage-primitives.py \
  _build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe \
  _build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe \
  --output .tmp/btree-step-1/acceptance
```

The integration runner now accepts `DEW_INTEGRATION_TEST_FILES` for a focused
run. Its default list still runs the full lane, including the new test.
The probe runner times each compiler/assembler/validator command and saves
its exact arguments, stdout, stderr and exit code. Positive test failures
stop the run. Negative compiler cases must return exit 1 with the named
privacy/cast diagnostic. No runtime assertion failure is caught as a pass.

## Coverage and emitted storage

- Generic raw arrays: I32, I64/U64, F32, F64, V128, Bool, U8, I16, String,
  Option<I64> and nested Option. No Default bound. The native integration
  test also verifies that no erased scalar-box heap is demanded.
- Overlap: shifts in both directions. A reference pair probe uses element
  indices 0/2 with a stride of two. It clears vacated elements 4/5 from the
  permanent default pair at 6/7. A Wasm inspector confirms four live slots
  and four null slots, including both untouched default slots.
- Same-type pairs use one homogeneous array, including String references.
  Common I32/U32, Bool/U8 and I16/U8 pairs use adjacent U32 elements. The
  Bool path writes 0/1. Signed narrow load restores I16 width.
- U32/F64 and I32/F32 use one V128 block per pair. Key bits occupy low 64,
  value bits occupy high 64, with unused bits zero. V128/U64 uses two blocks.
  Tests preserve negative zero, signalling and quiet NaNs, and all-ones bits.
  Extra default pairs stay zero. No scalar float/integer `unsafe_bitcast`
  is used for these pairs.
- Heterogeneous String/U64 and String/OtherReference use two typed columns.
  Each column pair has one body object, with no entry wrapper per position.
- The selected Unit body contains one key reference field. It allocates one
  key array, one body object and one enum object. The non-Unit body has two
  reference fields, two arrays and the same two wrapper objects. Its public
  Unit argument is physically absent from the Wasm function signature.
  A separate ordinary test proves that the caller's Unit value effect runs
  exactly once. A bare WasmArray<Unit> is not treated as free storage.
- The public opaque probe has private immutable storage and private mutable
  count. Valid cross-module getters and source-declared typed `ref.eq` work.
  Same-object identity is true; separate equal objects compare false.
  Imported reads, writes, construction and named private patterns fail.
- An imported optional trait is implemented by one consumer-defined provider
  and absent for another. Guarded calls specialize normally. Emitted code has
  direct calls and no `call_ref` lookup for either selected path.
- All 8/4/2 constant lane choices work for 16/32/64-bit lanes. There are 1,450
  independent scalar-oracle mask checks. These include empty live masks,
  all-ones queries, padding/tag bytes outside the mask, and U64 values on
  both sides of bit 63. Emission contains `i16x8.lt_u`, `i32x4.lt_u`,
  `i64x2.lt_s`, sign-bit XORs and lane bitmasks. It has no `array.get` scan,
  per-window struct allocation, or linear-memory vector load.

Raw GC array types include `(array (mut i32))`, `i64`, `f32`, `f64`, `v128`
and `eqref`. Reference arrays use nullable traced `eqref` slots physically;
Dew still checks their logical element type. Reads add the normal reference
checks. The default clear probe never reads null as a live Dew String.

For each carrier/pair constructor, `allocations.json` finds one backing-array
allocation site and zero `struct.new` sites in its reachable function body.
SIMD helpers have zero array/struct allocation sites. The column and Unit
wrapper costs above are explicit. These are emitted instruction/site counts,
not engine heap-byte or GC-pause measurements. The walker counts each
reachable function once; it is not a dynamic allocation profiler. The paths
used for the one-array claims call their allocating helper once and have no
allocation loop. Existing key/value objects and Option payload objects are
caller data, not boxes added to every storage slot.

The inspector adds read-only Wasm functions to a copy of the raw module.
It checks the expected heap types before it adds them. Original `.wasm` and
`.wat` files are retained next to the `-inspect` copies. Inspector functions
are not part of the compiler or standard library.

## Times, host and raw evidence

Host: native x86_64, AMD Ryzen 7 8845HS, Linux 6.12.113+deb13-amd64.
Moon 0.1.20261012 (`748b63c`), wasm-tools 1.262.0, Node v24.21.0.
Node used its default WasmGC mode, with no custom GC flags. Native release
compiler emission was raw; program cache was off in the probe runner.
No cross-compilation or emulation was used.

| Command/activity | Outcome | Wall seconds |
| --- | --- | ---: |
| Cold native CLI build | 42 tasks, passed; performance bug | 40.114 |
| Warm native CLI build | no work, passed | 0.030 |
| Native test-generator build | 3 tasks, passed | 27.678 |
| Focused private-field native lane | 9 tests passed | 9.574 |
| Focused compile-time bitcast lane | 1 test passed | 8.526 |
| Focused backend raw-bit-cast lane | 3 tests passed | 1.509 |
| New carrier integration lane | 1 test, 8 carrier cases passed | 10.341 |
| Raw probe module compile | each passed | 0.15–0.29 per module |
| Ordinary Dew test generation | passed | 0.21–0.34 |
| Ordinary Dew tests in Node | 2 passed | 0.03–0.04 |
| Wasm inspect/validate command | each passed | 0.01–0.02 |

Every final command and exact sample is in the JSON file below. The ranges
cover repeated runs after scoped source changes. They are not benchmarks or
speedup claims. Earlier attempts with a wrong package path and incompatible
`--file` arguments gave no test evidence. A first backend filter selected
zero tests (12.180 s); it was corrected to the three-test command above.

All detailed artifacts are outside production source at this exact root:

`/home/dev/.t3/worktrees/dewdrop/t3-de40f005/.tmp/btree-step-1/`

- `acceptance/commands.json`: exact final commands, times and exit codes.
- `acceptance/identity.json`: compiler/generator/source/module SHA-256 hashes,
  module sizes, source HEAD, CPU/OS and engine mode.
- `acceptance/{carriers,representation,simd,opaque}.{wasm,wat}`: raw emission.
- `acceptance/allocations.json`: reachable allocation instruction sites.
- `acceptance/runtime.stdout`, `acceptance/std-runtime.stdout`: runtime results.
- `acceptance/privacy-*.stdout` and `cast-limit-*.stdout`: full diagnostics;
  each command's separate stderr is retained too.
- `build-cli.log`, `build-cli-warm.log`, `build-generator.log`: build records.
- `native-privacy.log`, `native-cast.log`, `native-backend-raw-casts.log`,
  `integration.log`: focused lane records with times.
- `tool-versions.log`: exact tool versions.
- `claude{,-followup}-prompt.txt`, `.stdout`, `.stderr`, `.status`: read-only
  Opus/high review inputs, reports, errors and exit codes.

### The over-30-second build

The cold CLI build is the only compiler command above 30 seconds. It is an
open tool-build performance bug. Investigation found 42 cold tasks versus
zero warm tasks and an 80,984,071-byte generated CLI C file. The CLI uses
`-Og`; this is a possible cost source, not a measured phase attribution.
There are no phase samples that prove a cause. No primitive source compile
approached 30 seconds. This step does not hide the cold cost in a total or
claim to fix the native build system.

## Review resolution and limits

The first float probe wrongly required F32/U32 and F64/U64 scalar casts.
Both queries are false and both casts correctly fail. A read-only Claude
review first treated this as a design defect. Independent source inspection
then checked the design's explicit V128 fallback: typed vector views and
float lane replace/extract follow that layout without a scalar cast. The
follow-up review withdrew the design findings and confirmed the fallback.
Its missing-guard finding was fixed with static assertions. Its requested
runtime float/Bool/narrow tests are now covered. No design text or departure
was changed. The review read the scoped sources/logs; it did not read binary
Wasm or run tests. The raw module inspection and runtime checks above are
separate evidence.

No design-fact blocker remains. Section 3's storage, section 4's optional
trait selection, section 6's overlap/identity primitives, and section 13's
physical-evidence requirements are feasible through the tested native path.
The self-host compiler, full std suite, tree balancing, real node plans,
engine heap bytes, retained heap after GC, and throughput controls were not
run or implemented here. They are not claimed as step-1 evidence. This step
proves the current native compiler lanes and raw Wasm representation only.
The parent must run its own focused checks before it merges this commit.
