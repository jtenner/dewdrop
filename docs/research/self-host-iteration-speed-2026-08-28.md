# Self-host iteration speed

## Result

The strict Wago execution lane took 1,930 seconds to reach the current Starshine module rejection. This made one compiler edit cost more than 30 minutes.

An opt-in Node Facet lane now reaches the same rejection in 27.430 seconds. The complete stage, including compiler A build and request generation, takes 48 seconds.

This is a 70x execution speedup. No compiler validation was disabled.

## Cause

CPU profiles show that Wago spends about 56% of execution time crossing synchronous WasmGC helper boundaries. Dynamic reference casts, typed struct access, collector locking, and host-loop transitions dominate that time.

The Dewdrop workload also builds a large Starshine module one instruction at a time. Wago needed about 15 minutes for function body emission in a reduced-pass diagnostic run. Node's native WasmGC engine completes the full canonical eight-pass planner and the same emission work in less than 30 seconds.

The Starshine validation failure is unchanged. The faster lane is therefore an execution change, not a semantic bypass.

## Fast lane

Run:

```bash
tools/check-self-host-bootstrap.sh --fast
```

The lane:

1. Builds compiler A with Starshine, the Facet adapter, and the MoonBit time provider.
2. Adds a cached export for memory 0. This lets the exact scalar Memory32 Facet host copy process and filesystem bytes.
3. Runs the compiler with `tools/run-dew-facet.mjs`.
4. Keeps normal Starshine validation and all later linker validation enabled.

The Node host implements only the twelve canonical Facet imports used by the compiler artifact:

- `handle_close`
- `proc_exit`
- `stdio_stderr`
- `args_count`
- `args_len_i8`
- `args_read_mem32_i8`
- `fs_preopen_get`
- `fd_stat`
- `fd_read_mem32`
- `fd_write_mem32`
- `fd_sync`
- `path_open_mem32_i8`

Paths are contained inside the current project directory. Handles, result tuples, error values, open flags, and file types follow the audited Facet 0.1 ABI.

## Strict lane

The default command remains the strict Wago lane:

```bash
tools/check-self-host-bootstrap.sh
```

It uses:

```text
Core 3
2 GiB throughput heap
512 MiB nursery
normal collection
local locked plugins
```

The fast lane is for edit-test iteration. The final fixed-point proof must still pass under upstream Wago.

## Measurements

| Lane | Compiler execution | Full attempted stage | Result |
|---|---:|---:|---|
| Wago, 64 MiB nursery | 1,930 s | not completed | Starshine rejected module |
| Wago diagnostic, 512 MiB nursery plus local final-ref load experiment | 1,704 s | not completed | Starshine rejected module |
| Node Facet, canonical eight-pass planner | 27.430 s | 48 s | Same Starshine rejection |

The local Wago final-reference load experiment is not installed and is not part of the fast-lane result.

## FixedArray follow-up

After exact `FixedArray::make` selection and raw WasmGC array method lowering were repaired, the fast lane moved past the former compiler B `illegal cast` failures in `blake3_iv` and `blake3_copy_u32`.

The clean strict-validation timing on August 28, 2026 was:

| Action | Time |
|---|---:|
| Compiler A build | 17.002 s |
| Compiler A validation | 0.017 s |
| Compiler A request build | 0.105 s |
| Compiler A execution under Node Facet | 28.863 s |
| Complete attempted stage | 50.173 s |

Compiler A execution is again below the 30-second performance threshold. The next blocker is no longer `FixedArray::make`.

The `relative_path` mismatch was then isolated to `arguments.get_unchecked(1u32)`, not `SelfHostCompileRequest.output_path`. A pattern-bound `Array<String>` had lost its imported generic payload owner and was incorrectly admitted by the early `FixedArray` lowering. The fix now:

- accepts inferred `BodyAppliedType` values during imported nominal pattern instantiation;
- recovers pattern-local container ownership from the canonical physical body plan;
- does not route canonical `Array` pattern payloads through the raw `FixedArray` path;
- uses the canonical parent call ABI when selecting the result carrier for lowered `Array::get_unchecked`.

The strict fast lane now builds, links, and validates compiler B. Compiler B starts execution and reaches the later `compiler fingerprint mismatch` check. The former `expected eqref, actual i32` validation failure is gone.

The final clean verification measured:

| Action | Time |
|---|---:|
| Compiler A build | 17.557 s |
| Compiler A validation | 0.017 s |
| Compiler A request build | 0.103 s |
| Compiler A execution under Node Facet | 28.889 s |
| Compiler A output link | 14.659 s |
| Compiler B validation | 0.016 s |
| Compiler B request build | 0.107 s |
| Compiler B execution to fingerprint check | 0.769 s |

## Node CPU profile

A 100-microsecond Node CPU profile was recorded after the type fix:

```text
.tmp/node-cpu-profile/CPU.20260830.003820.1677444.0.001.cpuprofile
```

The 30.578-second profile divides as follows:

| Work | Time | Share |
|---|---:|---:|
| Dewdrop compiler Wasm | 29.301 s | 95.83% |
| V8 garbage collection | 1.223 s | 4.00% |
| JavaScript and native host code | 0.053 s | 0.17% |

The Facet Node host is not the source of the delay. Almost all time is inside the compiler Wasm.

Two compiler phases dominate:

| Compiler function | Inclusive time | Share |
|---|---:|---:|
| `self_host_emit_linked_i32_expression` | 13.689 s | 44.77% |
| `self_host_plan_program_wasm_bodies` | 9.493 s | 31.05% |

Together, canonical body planning and expression emission use about 76% of the complete profile.

The largest sampled self-time costs inside emission are repeated lookup and name comparison:

| Hot operation | Self time | Share |
|---|---:|---:|
| `self_host_linked_declaration_name` lookup path | 4.019 s | 13.14% |
| vectorized `Bytes`/name equality | 2.982 s | 9.75% |
| `self_host_linked_callable_parameter_nominal` | 2.222 s | 7.27% |

`self_host_linked_callable_parameter_nominal` first uses the declaration-owner index, but then has a fallback that scans every module and callable. Expected-type recovery also scans later expressions to find parent uses. These repeated scans occur inside the per-expression emitter loop. The current fast-lane slowness is therefore an algorithmic compiler cost: repeated declaration, callable, parent-expression, and string-name lookup during planning and emission. It is not Facet I/O, Node hosting, or primarily garbage collection.

The separate strict-Wago slowdown is documented in `docs/research/wago-wasmgc-helper-bottleneck-2026-08-28.md`. Current upstream Wago `595a0d7e` still sends the default body-emission workload through synchronous helpers: 61.755% non-final `ref.cast` and 35.151% `struct.get`. PR #549 makes an exact-fact scalar non-final `struct.get` fast, but does not cover general non-final casts or reference-valued fields.

The refreshed strict runs now reach a later fixed-stack limit. Default Wago executes compiler A for 2,053.997 seconds and `gc-ref-facts` executes it for 3,858.760 seconds; both trap at recursive function 2371 with `stack fence breached`. That generated instruction encoder has local indexes through 2114 and five self-calls. Wago's native execution stack is fixed at 4 MiB. Strict B/C fixed-point verification remains blocked until the encoder frame/recursion or Wago stack capacity is corrected.
