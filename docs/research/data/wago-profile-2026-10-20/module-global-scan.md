# Module-global register scan, 2026-10-20

Read-only source review. No build, test, or compiler change was made. All Wago paths below are under `/home/dev/Projects/dewdrop/.tmp/wago-transform-host/build-y_uuvb8q/wago`.

## Result

The observed global load/store is the module-global pin policy. Use `WAGO_PIN_GLOBAL_K=0` before a fresh Wago native compile for a focused policy A/B. It does not need a source edit or a new binary. Use a separate empty cache or force a compile: this environment switch is not represented in the artifact cache key.

The sample data makes this a strong lead, but it does not establish saved CPU time. The native probe takes leaf PCs with ptrace, not hardware CPU samples. Its block ranges include wrappers and padding. The hottest array-get block has 328 of 2,885 native probes, and the store at offset 16,829 (`0x41bd`) has 123 observations. Do not turn these counts into exact CPU-time percentages.

## Exact source path

- `src/core/compiler/backend/railshot/amd64/stats.go:36-41` reads `WAGO_DEBUG_MODGLOBALS` and `WAGO_PIN_GLOBAL_K` at process start. `stats.go:138-149` accepts K=0, 1, 2, or 3; empty/auto/unknown uses the heuristic.
- `amd64/compile.go:2469-2481` explains the module-wide reservation. R14 is the first pin, then R13 and R12. The selected registers are removed from every function's local register pool.
- `compile.go:3068-3120` picks hot mutable integer globals from aggregate loop-weighted scores across the whole module. The first requires `3 * loopWeight(1)`; extra pins require `50 * loopWeight(1)` in auto mode. K=0 sets the limit to zero. `WAGO_DEBUG_MODGLOBALS=1` prints selected global IDs and registers on fresh compile (`3113-3118`).
- `compile.go:3965-3978` installs exactly the same module pin assignment on every function. This is not limited to functions that read the global.
- `compile.go:3995-4007` emits three dependent loads for every pin: the global-directory pointer, the global-cell pointer, then the value.
- `compile.go:4017-4028` stores every module pin. It does not require a dirty bit for module pins. Function-local value pins have a separate dirty-only policy.
- Wrapper prologue `compile.go:4142-4144` calls the global-load emitter. Wrapper epilogue `compile.go:4426-4428` calls the global-store emitter. These match the array-get disassembly at `0x40c7-0x40ce` and `0x41b6-0x41bd`.
- Caller wrapper setup also flushes module globals before the call (`amd64/call.go:2969-2971`). Thus wrapper-heavy code can pay the stores both before calls and on returns.

## Why the array getter has this path

`/home/dev/Projects/dewdrop/std/array.dew:36-38` defines `array_get_unchecked` with an array parameter. Its source does not explicitly touch globals. The observed native entry is the wrapper format: it takes an argument buffer, loads locals from it, and later writes a result buffer.

Ordinary `sigFitsRegABI` only admits numeric parameters and results (`amd64/call.go:125-155`). A reference parameter fails. The function-level choice is at `amd64/compile.go:3324`; the staged extra shape there has numeric parameters with one reference result (`call.go:175-194`), so it does not admit this array parameter. A different physical-reference predicate at `call.go:197-230` supports typed tail calls; it does not extend the ordinary function choice used here.

The per-region module-global lease is a different policy. It requires register ABI, no calls, an interval-storage region, and no control flow (`compile.go:4375-4385`). `WAGO_AMD64_NO_MODULE_GLOBAL_REGIONAL_LEASE=1` disables that borrowing policy, not module-global pins. It will not remove this wrapper load/store.

## Safety limits

The module register holds the current global across register-ABI calls; those calls and returns need no cell synchronization (`compile.go:425-432`, `3990-3993`). Therefore a wrapper function with no direct global access can still return a changed register after a callee writes it. Removing its exit store based only on its own source/global hint can lose a callee's write. Host and cross-instance calls also synchronize and reload global cells (`call.go:1428`, `1509`; normal host reload at `1145-1146`). Trap and tail exits need the same analysis.

A narrower future optimization can use a proven transitive read/write effect, including host/dynamic calls, and keep the module-register contract. It needs more proof than the function's direct global accesses. Do the existing K=0 A/B first.

## A/B controls

1. Run the exact same successful serial workload and same host binary, with default K and K=0. Set the switch before process start. Use fresh native compilation in both cases.
2. Capture `WAGO_DEBUG_MODGLOBALS=1` output and confirm K=0 selected no pins. Save generated native size and the array-get disassembly; the unrelated directory/cell/value load and exit store must be absent.
3. Compare successful output identity, compiler guest invocation time, user CPU, peak RSS, Wago native compile time, and native code bytes. Separate setup/native compile from guest execution. Use a matched normal run for the main timing result; leave ptrace/diagnostic counter runs separate.
4. If K=0 helps, repeat a small matched baseline/candidate set in one lane before claiming a gain. K=0 frees registers and can change local allocation/spills and direct-prepared eligibility (`compile.go:3361`), so it measures the whole pin policy, not only the three store instructions.

`cli/runtime/internal/artifactcache/cache.go:124-134` includes `OptimizationInfos()` booleans in the cache key. `WAGO_PIN_GLOBAL_K` is not a bound optimization in `amd64/knobs.go`. Therefore reusing the same cached artifact can silently keep the old pin policy even after the environment changes.

## Handle-batch result supplied by the parent

The counters now show 542,651,936 reserved handles, 240,847,543 consumed, and 301,804,361 canceled. More than half of reserved identities are returned unused. There are 5,386,486 zero-use batches and 6,042,945 full 32-use batches. The full nursery-compaction fallback count is zero.

These counts confirm unused batch work as a separate measured lead. They rule out full nursery-list compaction as the cause for this run. The supplied totals also show 232,650,205 helper calls, 317,075,456 actual allocations, 145 minor collections, and no full collection. High helper/refill work and native execution therefore remain important alongside collection work; the exact costs still need the matched policy experiments.
