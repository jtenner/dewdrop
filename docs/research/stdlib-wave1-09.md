# Item 09: sorted array bounds

Dependency: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Test/doc checkpoint `19de7ff3` adds four tests before the APIs exist.
That checkpoint is red. The implementation candidate below is green.

Contract: `array_lower_bound`, `array_upper_bound`, `array_binary_search`
take `(values, key, comparator)`. Their `_range` forms take
`(values, key, start, end, comparator)`. Ranges are `[start, end)`;
invalid ranges trap. Bounds return absolute indices, including `end`.
Empty ranges return `start` (search returns None) without comparisons.
Input must be sorted by the same strict weak order. The comparator must
not change the array or its ordering during a call. Equivalence means
neither key precedes the other; search selects the first equivalent index
in the range. Sortedness is a caller requirement, not an O(n) check.
Natural `Array<t: Lt>` methods use `<`. No new ordering trait is added.

Tests cover both orders, every small range, duplicates, reference keys,
empty/singleton inputs, and a linear oracle plus comparison limits.
The completed candidate passes all focused gates below. No source blocker remains.

## Baseline and scope

Owner G0: PASS WITH KNOWN RED on 2026-11-01. Modern SDK compatibility
was fixed in `b9fcc8ea`. Accepted baseline: 355 standard tests, 41 separate
private B-tree tests, 42 trap probes and 4,121 operation probes. The eight
public provider tests are not counted again. Mission A reviewed the eight
historical snapshot differences at this dependency checkpoint. This item
changes no snapshot, B-tree file, compiler rule, registration slot, or SDK.
The accepted 67.88-second baseline cold build is outside this item.
No full suite result is claimed for this private candidate; the owner runs
that gate at integration. Four new focused tests belong to this item.

## Results (2026-11-01 UTC)

Branch: `worker/wave1-item-09`. Test/doc checkpoint: `19de7ff3`.
Implementation adds six comparator functions and six natural methods.
The generated bootstrap source matches the on-disk array source.
No compiler or native test code changed; no native or integration compiler
lane was needed. The orchestrator runs the complete standard suite at landing.

All compiler commands used the required exclusive lock. The first queued
attempt before the session pause never entered the lock and produced no
compile log. After resume, these attempts ran:

| Attempt | Result | Seconds | Peak KiB |
| --- | --- | ---: | ---: |
| 1: local tool setup | exit 255, archiver absent; no compilation | 0.09 | 70,132 |
| 2: cold focused build | exit 1, test-source errors; no tests ran | 30.48 | 1,077,532 |
| 3: cold focused compile | exit 0 | 29.19 | 1,079,172 |
| 3: focused runtime | 4 new tests passed, 0 failed | 0.03 | 50,128 |
| 3: generator check | exit 0 | 0.02 | 12,172 |
| 3: production consumer compile | exit 0, 5,382-byte Wasm | 24.05 | 748,424 |
| 3: traps, consumer result, benchmark | exit 0 | 0.25 | 50,612 |

Attempt 1 reported `failed to resolve native archiver executable
/data/workspace/wave1-item-09/.tmp/ar`; a local symlink fixed it.
Attempt 2 reported `ExpectedValue(Some(Token(Keyword(Else), ...)))`,
`NoMatchingMethod` for explicit generic method construction and Option
comparison, plus related unresolved-type errors. The tests now use
`array_new::<U32>()`, a multiline `} else {` block, pattern checks for None,
and a match helper for Some. These were test-source errors, not a blocked
library implementation. The raw logs remain in `.tmp/attempt1.log` and
`.tmp/attempt2.log`. Final logs are `.tmp/focused.log`, `.tmp/generator.log`,
`.tmp/consumer.log`, and `.tmp/runtime.log`.

**Performance bug:** attempt 2 took 30.48 seconds, above the 30-second limit.
This is recorded without changing compiler scope. Final cold commands are
below that limit. No global SDK setting changed. Every attempt used an
EXIT cleanup trap before releasing the lock. Final build directories and
all generated Wasm/harness files are removed.

The four test cases check 231 key/range pairs in each order (all 21 valid
ranges of a five-element array, with 11 keys), first-equal selection,
empty/singleton arrays, reference-key equivalence, and natural methods.
For lengths `2^p`, `p=0..14`, three keys test all-equal duplicate runs.
Each bound must use at most `p+1` comparisons; binary search at most `p+2`.
The same results must agree with a linear scan. Nonzero empty ranges also
must use zero comparisons. Three separate production exports must trap
for reversed, past-end, and empty-but-past-end ranges. Production `main`
must return 4. All these checks pass. No baseline test count is added to
the four new tests, and no full-suite pass is claimed here.

## Runtime and memory

Node runs one allocation of the input array per batch of 1,000 searches
for both binary and linear paths. It warms each case with five batches
and takes the median of 15 timed batches. All 120 timed batch results
match the expected index sum. Values are all 4 and the key is 5, so a
linear scan visits the whole array. These measurements describe that case,
not all workloads. Small scans can be faster, and JIT warmup affects short
runs; no blanket speedup is claimed.

| Length | Binary ms / 1,000 | Linear ms / 1,000 | Binary retained heap delta, bytes | Linear retained heap delta, bytes |
| ---: | ---: | ---: | ---: | ---: |
| 16 | 0.05242 | 0.00873 | -2,912 | 24 |
| 256 | 0.00950 | 0.12644 | 64 | 15,384 |
| 4,096 | 0.04438 | 1.98089 | 384 | 680 |
| 16,384 | 0.07251 | 7.81205 | 64 | 64 |

Heap deltas use `heapUsed` after forced GC on both sides of the timed
batches. They include process/JIT noise, not an exact allocation count.
There is no retained heap growth with array length in this run. The bounds
loops use only a fixed number of U32 locals and array reads; no scratch
array, recursion, or per-step allocation is present. The natural wrapper
constructs a constant-size comparator; binary search returns an Option.
Extra working space is O(1), excluding caller comparator work. The test
fixture's input array uses O(n) memory. The whole runtime process peaked
at 50,612 KiB. Compiler peaks are separate in the gate table.

Existing stable sort remains unchanged. No B-tree edits, new module,
ordering trait, builtin, source-path dispatch, snapshot refresh, push, or
global SDK change is part of this candidate. Remaining blockers: none.

## Reproduce the gates

Run from `/data/workspace/wave1-item-09`. Create `.tmp` and the following
files. Use the pinned SDK `/data/home/.moon` (moon 0.1.20261023,
moonc/core 0.10.17+d971670cd).

Local compiler wrapper (`.tmp/cc`, executable) and archiver link:

```sh
#!/bin/sh
exec /usr/bin/clang "$@" -fbracket-depth=4096 -g0 -O0
```

```sh
chmod +x .tmp/cc
ln -s /usr/bin/ar .tmp/ar
flock /data/workspace/wave1-control/build.lock bash .tmp/gates.sh
```

Exact final gate script (`.tmp/gates.sh`):

```sh
set -euo pipefail
cd /data/workspace/wave1-item-09
export PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
export MOON_CC="$PWD/.tmp/cc"
cleanup() {
 find .tmp -name '*.wasm' -delete
 rm -rf _build .mooncakes .dew/cache .tmp/consumer.wasm
 find tools/dew-test -maxdepth 1 -name '*.wasm' -delete
 rm -f tools/dew-test/stdlib_test.dew tools/dew-test/stdlib_tests.json
}
trap cleanup EXIT
/usr/bin/time -f 'focused seconds=%e peak_kib=%M' moon run -j 1 --target native src/dew_test_gen -- .tmp/search.wasm dew.std dew.std std/tests/array_search_test.dew std/tests/array_search_test.dew > .tmp/focused.log 2>&1
/usr/bin/time -f 'tests seconds=%e peak_kib=%M' node tools/dew-test/run.mjs --wasm .tmp/search.wasm >> .tmp/focused.log 2>&1
/usr/bin/time -f 'generator seconds=%e peak_kib=%M' python3 tools/generate_array_std.py --check > .tmp/generator.log 2>&1
/usr/bin/time -f 'consumer seconds=%e peak_kib=%M' env DEW_WORKING_DIRECTORY="$PWD" DEW_REPOSITORY_ROOT="$PWD" moon run --target native --release -j 1 src/dew_bootstrap -- build .tmp/consumer.dew -o .tmp/consumer.wasm > .tmp/consumer.log 2>&1
/usr/bin/time -f 'runtime seconds=%e peak_kib=%M' node --expose-gc .tmp/measure.cjs > .tmp/runtime.log 2>&1
```

Production consumer and benchmark (`.tmp/consumer.dew`):

```dew
open dew.std.array
pub fn main() -> U32 {
  let values = [2u32, 4u32, 4u32, 8u32]
  values.lower_bound(4u32) + values.upper_bound(4u32)
}
pub fn search(size: U32, linear: Bool) -> U32 {
  let values = Array::make(size, 4u32)
  let mut sum = 0u32
  let mut repeat = 0u32
  while true {
    true if repeat < 1000u32 => {
      let result = if linear {
        while 0u32 {
          i if i < size => {
            if values[i] < 5u32 {
              continue i + 1u32
            } else {
              break i
            }
          }
          _ => break size
        }
      } else {
        values.lower_bound(5u32)
      }
      sum = sum + result
      repeat = repeat + 1u32
      continue true
    }
    _ => break sum
  }
}
pub fn bad_reversed() -> U32 {
  [1u32].lower_bound_range(1u32, 1u32, 0u32)
}
pub fn bad_end() -> U32 {
  [1u32].upper_bound_range(1u32, 0u32, 2u32)
}
pub fn bad_search() -> Option<U32> {
  [1u32].binary_search_range(1u32, 2u32, 2u32)
}
```

Runtime checks (`.tmp/measure.cjs`):

```js
const fs=require('fs'); const {performance}=require('perf_hooks');
(async()=>{const {instance}=await WebAssembly.instantiate(fs.readFileSync('.tmp/consumer.wasm'),{}); const x=instance.exports; x.__dew_init?.();
if(x.main()!==4)throw Error('consumer result');
for(const name of ['bad_reversed','bad_end','bad_search']) {let trapped=false;try{x[name]()}catch(e){if(!(e instanceof WebAssembly.RuntimeError))throw e;trapped=true}if(!trapped)throw Error(name);console.log(name+' PASS trap');}
for(const n of [16,256,4096,16384])for(const linear of [false,true]){for(let i=0;i<5;i++)x.search(n,linear); const times=[];global.gc(); const before=process.memoryUsage().heapUsed;for(let i=0;i<15;i++){const t=performance.now();if(x.search(n,linear)!==n*1000)throw Error('oracle');times.push(performance.now()-t);}global.gc();const after=process.memoryUsage().heapUsed;times.sort((a,b)=>a-b);console.log(JSON.stringify({n,linear,median_ms_1000:times[7],retained_heap_delta:after-before}));}
})();
```
