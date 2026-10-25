# Intrinsic source coverage gate, 2026-10-25

## Scope and base

Branch: `feat/btree-step-2-plans-providers`.
Follow-up base: `dce4fd0e36f6e0643e88f554e435af2617dc4e3c`.
The worktree was clean at `6b902057c4679414d43c1031320b4623e5250d44`.
`git merge --ff-only feat/btree-integration` took only parent status updates.
The original step-2 implementation base remains
`5f8bfb43e034ecbfd7cf6c11542c9a46239b63eb`.

This change repairs ordinary intrinsic declaration generation. It changes no
compiler algorithm, runtime algorithm, B-tree source, design, layout, module
identity, or parent status file. It does not build Starshine or run the parent's
B-tree or Starshine test suites. No master merge, push, or PR was done.

## Baseline and source truth

`python3 tools/test_debug_float_policy.py` failed in 0.058 s at the base.
The generator reported 28 backend instructions without public declarations:

```
f32.copysign f32.max f32.min f64.copysign f64.max f64.min
i32.clz i32.eqz i32.rotl i32.rotr
i32.trunc_sat_f32_s i32.trunc_sat_f32_u i32.trunc_sat_f64_s i32.trunc_sat_f64_u
i64.clz i64.ctz i64.eqz i64.extend16_s i64.extend32_s i64.extend8_s
i64.popcnt i64.rotl i64.rotr
i64.trunc_sat_f32_s i64.trunc_sat_f32_u i64.trunc_sat_f64_s i64.trunc_sat_f64_u
ref.eq
```

The independent numeric authority is `tools/wasm_scalar_intrinsics.py`:
136 unique rows with opcode, emitter method, input carriers, and result carrier.
`tools/generate_wasm_scalar_intrinsics.py` uses those rows for one-instruction
native emitters and native/self-host raw signatures.
`tools/generate_scalar_intrinsic_tests.py` already maps numeric predicates to
logical `Bool`. Other raw numeric results use their uppercase carrier.
The repair reuses those rules for scalar opcodes with no public source binding.
Existing public aliases retain their source signatures and names.

`src/semantic/raw_wasm_intrinsics.mbt:32` defines `ref.eq` as two equality
references with an i32 result. Existing
`src/backend/starshine_generic_raw_builtins_wbtest.mbt` and
`src/backend/starshine_ref_eq_wbtest.mbt` cover source-declared generic or typed
reference equality, checked outlined instances, and invalid stack signatures.
The new public declaration is generic:

```dew
pub builtin wasm_ref_eq<a, b>(left: a, right: b) -> Bool = "ref.eq"
```

It names no private representation. Ordinary raw signature validation rejects
scalar inputs. There is no special module/name dispatch or new builtin kind.

## Repair and regression checks

The intrinsic generator now fills the 27 missing numeric bindings from the
scalar catalog and supplies the generic reference binding above. It still
checks backend coverage and duplicate aliases. An unknown backend opcode still
fails with its name. No ignore list was added. Generated output is not an
input to the inventory.

The source scan now accepts only public, non-`__` builtin declarations and
public, non-`__` unsafe-bitcast wrappers. Private helper signatures cannot leak
into the generated public module. A baseline inventory found zero previously
selected ordinary private builtins and zero private wrappers, so this removes
no current public alias. Tests use a separate temporary source root with a
private nominal type, private helpers, generated output, and test-only input.

Four new Python regression tests failed before the fix (two errors and two
failures, 0.121 s). After the fix they pass. They check all 28 exact signatures,
all 136 scalar opcodes, existing carrier aliases, private/source boundaries,
and the unknown-opcode diagnostic. `tools/check-generated.sh` now runs them.
Two added Dew tests in `std/tests/04_wasm_intrinsics_test.dew` call all 27
numeric additions and check same/separate/different-private-type references.
All five tests in that file pass.

## Commands and measured results

All times are wall seconds. Generator/policy commands use `self_host_measure`
from `tools/self-host-common.sh`. Compiler probes use Python `time.monotonic`,
save arguments/stdout/stderr/status, and assert the expected exit code.
Artifacts and raw logs are in `.tmp/intrinsic-source-coverage/`.

| Command | Result | Seconds |
| --- | --- | ---: |
| `python3 tools/test_wasm_intrinsics_std.py` | 4 passed; final diagnostic regex check | 0.096; 0.098 |
| `python3 tools/test_debug_float_policy.py` | 3 passed | 0.046 |
| `python3 tools/test_scalar_builtin_policy.py` | 2 passed | 0.033 |
| `python3 tools/test_arithmetic_builtin_policy.py` | 2 passed | 0.030 |
| `python3 tools/test_math_builtin_policy.py` | 2 passed | 0.029 |
| `python3 tools/generate_wasm_intrinsics_std.py --check` | 1065 declarations, 523 backend names; final repeat | 0.048; 0.051 |
| `python3 tools/generate_wasm_scalar_intrinsics.py --check` | 136 opcodes, 4 tables | 0.022 |
| `python3 tools/generate_self_host_numeric_builtins.py --check` | passed | 0.022 |
| `python3 tools/generate_scalar_intrinsic_tests.py --check` | 136 cases | 0.020 |
| `tools/check-generated.sh` | full gate passed | 39.690 |
| `tools/check-generated.sh`, warm, per-compiler timers | full gate passed | 10.568 |
| Existing native `dew_test_gen.exe`, public test file | passed | 0.224 |
| `node tools/dew-test/run.mjs --wasm .tmp/intrinsic-source-coverage/tests.wasm --label 'intrinsic source coverage'` | 5 passed | 0.033 |
| Existing native `dew_cli.exe build`, 28 thin wrappers | passed | 0.206 |
| `wasm-tools validate .tmp/intrinsic-source-coverage/physical.wasm` | passed | 0.015 |
| `wasm-tools print .tmp/intrinsic-source-coverage/physical.wasm` | passed | 0.012 |
| Existing native `dew_cli.exe build`, scalar `ref.eq` | expected exit 1, `InvalidBuiltinSignature` | 0.202 |

Generation took 0.051 s, and the final generated header update took 0.048 s.
Native CLI help took 0.002 s (see `cli-help.stderr`). Initial test-source
syntax corrections failed in 0.292, 0.223, and 0.240 s. Those are test-authoring
errors, not compiler defects. A later callback test failed in 0.217 s; see the
separate limit below. Test failures were not caught into passes.

The 39.690 s gate is an open build-cost result above the 30 s limit. Its log
contains native bootstrap build warnings. It has only an outer timer, so no
single cold phase cost can be assigned. A warm repeat used scratch PATH
wrappers to time every `moon` and `wasm-tools` invocation. Fourteen commands
were captured; every command was below 1.773 s. They include the nested WasmGC
CLI build (0.026 s), Facet bootstrap/build (1.341 s), native bootstrap tests
(0.166 s), and three CLI fixture calls (1.530, 1.303, 1.772 s). The compile-fail
fixture's exit 1 is expected and checked by the gate. This does not prove that
the cold cost is fixed. No Starshine CLI build was run. The warm gate set
`DEW_STARSHINE` to the parent's existing binary as a guard; this raw gate did
not use the optimizer.

To repeat the signature probe without a build, use:

```sh
python3 .tmp/intrinsic-source-coverage/probe.py
```

The saved `probe-commands.json` gives exact commands. The compiler prefix is
`_build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe build --root probe.intrinsic --module probe.intrinsic`.
The test generator command is
`_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe .tmp/intrinsic-source-coverage/tests.wasm probe.tests probe.tests std/tests/04_wasm_intrinsics_test.dew "$PWD/std/tests/04_wasm_intrinsics_test.dew"`.
Both use `DEW_STD_ROOT="$PWD" DEW_PROGRAM_CACHE=0`. The probe is scratch evidence,
not a production dependency. The checked-in Dew and policy tests are permanent.

## Emitted code, source size, and limits

The raw 28-wrapper module is 2,509 bytes. Every exported body is exactly its
argument `local.get` instructions followed by the expected opcode, including
`ref.eq` on distinct private reference types. There are no imports, calls,
or allocation instructions. `physical.wat` and `physical-checks.json` save the
full bodies. The five-test module is 13,803 bytes. This checks instruction
selection and the absence of wrapper overhead. It is not a throughput benchmark
or an actual heap-size/alignment claim.

The source module grows from 96,182 to 98,195 bytes (+2,013). The embedded mirror
grows from 99,465 to 101,566 bytes (+2,101). Existing declaration order is
preserved; the two public nominal carrier declarations keep their indices.
An independent base/current source comparison preserved all 898 previous
builtin signatures and all 141 previous wrapper bodies. Exactly 28 builtin
declarations were added (`compatibility.json`).

Host: Linux x86_64, kernel `6.12.113+deb13-amd64`, glibc 2.41.
Existing native tool SHA-256 values:

- `dew_cli.exe`: `2ab0af90e7c032f456a15b3a3d29ece16a6f38842142783be883480eb371846d`
- `dew_test_gen.exe`: `830a6a203602146679d4743ce2a97a93a6984bb3ad224c4daab6d1ac5f5499fa`

`identity.json` saves complete paths, binary/source sizes, and hashes. The tools
were reused, not rebuilt. The current on-disk standard source was loaded.

## Separate imported-callback compiler limit

An extra test that obtains generic `ref.eq` as a returned function value from
an imported module fails with `StarshineProgramCodeError(MissingFunction(...))`.
Direct calls, including distinct private reference types, pass. The same
callback pattern compiles with a local builtin declaration (0.209 s). An
ordinary imported module reproduces the failure (0.204 s), so it is independent
of the intrinsic module or any B-tree representation:

```dew
// Module probe.api
pub builtin same<a, b>(left: a, right: b) -> Bool = "ref.eq"
```

```dew
// Module probe.callback
import probe.api as @api
struct Box {
  value: I32
}
fn callback() -> fn(Box, Box) -> Bool {
  @api.same
}
pub fn run(left: Box, right: Box) -> Bool {
  let compare = callback()
  compare(left, right)
}
```

Exact command, with `DEW_STD_ROOT="$PWD" DEW_PROGRAM_CACHE=0`:

```sh
_build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe build \
  --root probe.callback \
  --module probe.api .tmp/intrinsic-source-coverage/callback-api.dew \
  --module probe.callback .tmp/intrinsic-source-coverage/import-callback.dew \
  -o .tmp/intrinsic-source-coverage/import-callback.wasm
```

This returns exit 1 and `MissingFunction(17179869184000)`. The public intrinsic
control returns exit 1 and `MissingFunction(18446462637387546629)` in 0.209 s.
The ordinary imported-module control was also run with a separate standard
root whose intrinsic source is the exact base version. It has the same exit 1
and `MissingFunction(17179869184000)` in 0.230 s. The current standard source
was not changed for that control (`base-import-callback-command.json`).
`callback-control-commands.json`, the Dew inputs, and stdout/stderr preserve
both runs. This extra returned-callback test is not part of the positive direct
instruction tests. No runtime fix or support claim for that pattern is made.
The generated-source gate does not fail on it. Fixing the compiler is outside
this bounded declaration repair. No design change is required for the repaired
direct intrinsic signatures.

## Independent review

Claude Code was invoked from this worktree with normal authentication,
`--model opus --effort high --tools Read,Glob,Grep --disallowedTools 'mcp__*'
--permission-mode dontAsk --output-format text`. No `--bare`, shell/edit/MCP
tools, credential changes, or permission bypasses were used. The prompt names
the exact base, all eight changed files, independent authority sources, source
diff/snapshots, measured raw evidence, and review requirements. The generated
mirror also has an independently decoded readable copy and byte-equality proof.

The attempt exited 1 in 1.130 s. Its complete stdout is:

```
You've hit your session limit · resets 11:50pm (UTC)
```

Stderr is empty. Claude inspected no files and supplied no assessment. No
independent Claude coverage is claimed. Prompt/stdout/stderr/status/time are
saved in `.tmp/intrinsic-source-coverage/review/claude.*`. Review remains open
until normal session usage is available. No extra agent was started.

## Exit state

The full generated-source gate passes. No further inventory failure was
exposed, and no second repair commit is needed. The declaration repair and its
direct instruction/runtime checks are complete. The cold gate cost, imported
generic returned-callback compiler limit, and unavailable Claude review remain
explicit limits. None requires a B-tree design or layout change.
