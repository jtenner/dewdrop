# Wave 1 item 05: hex bytes

Base: 8c3b047fe633aa11c6634b929045376e9dfc7d6c.
Test checkpoint: five new tests specify empty input, case, offsets, odd length,
all bytes, size limits, views, and SHA-256 text. Not run at this checkpoint.

Contract: encode(Bytes) -> Bytes emits lower-case ASCII. Decode accepts both
ASCII cases. Odd length takes precedence. InvalidByte offsets are zero-based
and relative to the input view. No whitespace or prefixes are allowed.
encoded_length(U32) -> Option<U32> checks doubling before allocation;
encode traps on overflow. Decode halves an even U32 length without overflow.

Implementation draft: ordinary Dew loops; no new builtins, host calls, or
semantic/emission exceptions. Module slot 81 is reserved for hex. The explicit
import selects only its bytes/builder dependencies. Wildcard registration adds
one module and one source path. Bootstrap bytes come from the generator.

Example:

```dew
import dew.std.encoding.hex as @hex
// @hex.encode(b"\xAB\x01") produces b"ab01".
// @hex.decode(b"Ab01") produces Ok(b"\xAB\x01").
```

Space model: encode reserves exactly 2*n bytes, decode reserves n/2 bytes.
Storage rounds each result up to a 16-byte chunk. There is no temporary array,
text copy, or per-byte object. Decode makes one validation pass before output
allocation and one conversion pass. Invalid and odd inputs allocate no output
buffer. Each valid codec uses O(n) time and O(output size) space. The size check
is tested without attempting a multi-gigabyte allocation; fitting U32 does not
promise that the host has enough memory for that allocation.

Node reference: tools/hex-reference.mjs uses xorshift32 seed 0x51a7c0de and
Buffer.toString('hex') for 64 cases, including empty, all 256 byte values, and
4096 bytes. The benchmark repeats the 4096-byte reference case 1000 times after
100 warmups. Each iteration encodes, decodes, and checks both results. It reports
elapsed time and Node process memory before/after explicit GC; process memory
is not an exact measure of Wasm GC storage.

Attempt 1 (logs: `stdlib-wave1-05/attempt1/*.log.gz`): no Dew test ran.
The C wrapper name caused MoonBit to seek `.tmp/hex-ar`; that local archiver
link was missing. Focused compile failed in 0.08s; random compile 0.04s;
registry lane 0.05s; integration lane 0.10s; production compile 0.05s;
check-generated stopped at the same build-plan error in 4.63s.
Hex generator 0.01s and identity generator 0.02s both passed.
`moon info --target native` failed in 9.33s (746076 KiB peak RSS), with 18
unbound native platform helper errors in the existing bootstrap package.
These failures remain in the logs. The local archiver link was then added.
No cold C compile ran, and no command exceeded 30s in this attempt.
The first queued session was stopped before it acquired the build lock; it
produced no build or test result.

Attempt 2 (logs: `stdlib-wave1-05/attempt2/*.log.gz`): cold focused compile
failed after 32.55s, peak RSS 1076424 KiB. **Over 30s: cold build performance
bug.** Dew requires a value after `break`; the validation loop and test input
loop used a bare break. Option has no equality implementation, so the boundary
tests also needed `is` patterns. Both are corrected in the next attempt.
Random compile failed in 0.92s; production compile failed in 23.22s on the same
Dew break syntax. Registry: 1 passed, 0 failed (0.80s). Source-path/identity
integration: 24 passed, 0 failed (15.660s). Module integration: 25 passed,
1 failed (7.730s): the wildcard dependency edge count needed 77 -> 78.
This registry fact is also corrected. Scoped `moon info --target native
src/standard_sources` passed in 0.22s and produced the new export interface.
Full `bash tools/check-generated.sh` passed in 38.08s (836808 KiB peak RSS),
including 14 bootstrap tests and 3 CLI fixtures. This aggregate compiler/check
activity exceeded 30s and is recorded plainly; no check was suppressed.

## Final focused gates: READY candidate

Attempt 3 passed, exit 0. Complete logs: `stdlib-wave1-05/final/*.log.gz`.
`stdlib-wave1-05/final/summary.json` lists times and counts without warnings.

| Gate | Seconds | Peak RSS KiB | Result |
| --- | ---: | ---: | --- |
| Hex generator --check | 0.02 | 12112 | pass |
| Identity generator --check | 0.02 | 12036 | pass |
| Focused cold compile | 29.00 | 1076392 | pass |
| Focused Node run | 0.03 | 46400 | 5 passed, 0 failed |
| Scoped native interface generation | 0.19 | 34776 | pass |
| Node-reference compile | 0.92 | 70068 | pass |
| Node-reference run | 0.03 | 50480 | 64 passed, 0 failed |
| Benchmark process | 0.35 | 56828 | pass |
| Native registry lane | 0.76 | 98592 | 1 passed, 0 failed |
| Focused native integration lanes | 24.91 | 1138132 | 50 passed, 0 failed |
| Production consumer compile | 21.24 | 748416 | pass, 6827 bytes |
| Production consumer runtime | 0.02 | 46900 | result 10, pass |
| Full check-generated.sh | 35.57 | 837028 | pass |

The two integration files ran in 15.467s and 9.436s. The generated check also
passed 14 bootstrap tests and 3 CLI fixtures, plus its policy/generation checks.
The 35.57s aggregate check exceeded 30s; this is a measured performance issue.
No final single compile exceeded 30s. The accepted baseline cold 67.88s is
unchanged. Tests were not run with a raw workspace-wide `moon test`.

New tests: 5 committed Dew tests, 64 generated Node-oracle tests, and 1 committed
MoonBit registry test. The 50 integration tests are existing tests, with updated
registry facts and new hex source-closure/identity assertions. Do not add them
or the baseline provider tests to the count of new tests. Final item test total:
120 passed, 0 failed (5 + 64 + 1 + 50), plus one production runtime check.
The standard 355-test baseline and the separate private B-tree suite were not
rerun here; the orchestrator owns the combined standard run. No snapshot changed.

The benchmark body took 267.358ms for 1000 checked 4096-byte round trips:
14.611 MiB input/s, including encoding, decoding and two equality checks.
After explicit GC, Node heapUsed changed from 4241152 to 4246160 bytes (+5008),
external memory from 1842367 to 1842371 bytes (+4), and arrayBuffers stayed at
10475 bytes. RSS changed from 55046144 to 57458688 bytes (+2412544). These are
process measurements, not an exact Wasm GC heap size. Output payload per codec
call is 8192 bytes for encode and 4096 bytes for decode at this input size;
source inspection shows one exact-capacity buffer per successful call, no
per-byte allocation, no staging copy, and no output allocation on invalid input.

The compiler still reports `UnreachableBlockItem` for the dead `0u32` fallback
after the explicit overflow trap in hex.dew. It is preserved in the logs and
does not affect behavior. All required behavior passed; there is no blocker.

## Exact commands and environment

Run from `/data/workspace/wave1-item-05` on `worker/wave1-item-05`.
The SDK is `/data/home/.moon`: moon 0.1.20261023, moonc/core
0.10.17+d971670cd. No global SDK file or setting changed. The process-local
C wrapper uses Clang with `-fbracket-depth=4096 -g0 -O0`; its matching local
`hex-ar` points to `/usr/bin/ar`. Focused generator compiles use `-j 1`.
The normal repository runners retain their own job flags. Bun 1.4.3 is an
existing installed tool at `/tmp/burn-starshine-fix-tools/bun`.

```sh
mkdir -p .tmp
cp docs/research/stdlib-wave1-05/hex-cc.sh .tmp/hex-cc
chmod +x .tmp/hex-cc
ln -sf /usr/bin/ar .tmp/hex-ar
cp docs/research/stdlib-wave1-05/consumer.dew .tmp/hex-consumer.dew
node tools/hex-reference.mjs .tmp/hex-reference_test.dew
cp docs/research/stdlib-wave1-05/gates.sh .tmp/gates.sh
flock /data/workspace/wave1-control/build.lock bash .tmp/gates.sh
```

The saved gate script contains each exact timed command. It preserves every
failure and returns nonzero if any gate fails. Its EXIT trap removes `_build`,
`.mooncakes`, `.dew/cache`, and generated `.tmp/*.wasm`/`.wat` files before
releasing the lock, including on failure. No build output is shared. All
compiler, build and test commands ran under this lock. Generator edits and
Node reference source generation ran without the lock and use no compiler.

No push, B-tree edit, SHA state change, held fix, or unrelated source change.
READY means ready for review and integration; it does not mean landed.

## Checkpoints and changed files

First test/doc checkpoint: `35c62aa8` (five new Dew tests; not run at that point).
The implementation/evidence commit follows that checkpoint on the same branch.
`stdlib-wave1-05/changed-files.txt` is the exact changed-file list against the
dependency checkpoint, including each compact evidence file.

Cleanup checked after the final lock exited: `_build`, `.mooncakes`,
`.dew/cache`, generated Wasm, WAT and harness files are absent. The pinned
Starshine submodule is unchanged. Source checks (`git diff --check`) pass.

## Combined-tree correction

The first combined full standard compile failed (28.78 s): both UTF-8 and
hex tests opened a `decode(Bytes)` function in the shared `dew.std` test
module. Diagnostics at `std/tests/12_utf8_test.dew:7` and
`std/tests/hex_test.dew:9` report `AmbiguousCallOverload`. No runtime test
ran. The native loader lane passed 31 tests in 13.93 s.
The hex tests now import the module as `@hex` and qualify codec calls and
errors. Existing UTF-8 tests and codec APIs are unchanged. This uses normal
module namespacing; no compiler rule changes. Failed logs:
`data/stdlib-wave1/landing-05-{std,native}-attempt1.log.gz`.

## Combined landing gate

After the alias correction, `bash tools/dew-test/run.sh` exited 0 in
159.00 s: 379 public tests (374 prior + 5 hex), 41 private tests,
builtin traps and all 42 operation check scripts passed. Repeat bytes match.
The native loader lane passed 31/31 in 14.22 s. Local Clang -g0 -O0
uses the pinned SDK; long compiler calls are recorded in the full logs.
New module slot 81 and text-selection bit 128 are reserved for hex.
Orchestrator review confirms source closure, generated source/export interface,
canonical identity mirrors, wildcard facts, and generator check wiring.
Full logs: `data/stdlib-wave1/landing-05-{std,native}.log.gz`. Build output removed.
