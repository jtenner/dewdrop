# Do not retain callback types from unreachable bodies

The aggregate callback performance case grew to 4,227 bytes and exceeded its
4,100-byte Wasm limit after Option/Result value helpers were added. It also
had 39 types against a 38-type limit. The extra helper body `unwrap_or_else`
introduced a callback of type `fn() -> t` even when that helper was unused.

A controlled same-CLI comparison uses the current standard files in one run
and Option/Result from the parent of `a747c7c6` in the other. The current files
produce 4,227 bytes; the old files produce 4,046 bytes. Both have 15 functions,
23 struct allocations, one array allocation, 14 indirect calls, 69 reference
casts, and identical 1,069-byte code sections. This is metadata growth, not a
new runtime allocation or an extra call in this program. The baseline source
snapshot at `9d86b829` has the same counts, but strips ABI/metrics custom
sections, so it is not used as the raw binary-size control.

The native fragment planner previously rooted callback types from every
expression and every callable signature before it removed unreachable bodies.
The closure-ABI decision used the same unfiltered inputs. Unused Option/Result
methods therefore added module closure bases. More than one module closure base
selects recursive program type linking; that changed type ordering and added
163 bytes of compiler facts in this fixture. Removing just the callback type
saved four bytes (4,223 bytes total), so it was insufficient. The final rule
also keeps the closure-ABI decision tied to live roots.
It now visits the owned spans of reachable callable bodies and module
initializers. Existing non-elided lambda entries keep their roots. Callable
signature roots retain reachability, runtime trait requirements, and local or
program function-value demand. Export and module-visible ABI root policy is
unchanged. The rule uses existing declaration and reachability tables; it adds
no expression mask or retained index. It treats user and standard bodies by
the same frozen liveness data.

The focused regression supplies an explicit root set. It demonstrates that
an unreachable generic callback body retained two physical callback signatures
before the fix. Existing default planning intentionally retains module-visible
user ABI functions, so the regression does not redefine that public contract.
Positive tests retain nested exported callback signatures, module initializer
function references, generic applications, module-visible user ABI, live
lambdas, dynamic trait callback fields, and ordinary callback struct fields.
A directized lambda can take a callback read from a struct field without any
function-value call in its body. A new control confirmed that this needs the
closure ABI. Live lambda parameter/result signatures now keep that ABI; each
non-direct, non-elided lambda also keeps its closure base. The final old-source run passed 19 of 20 tests in 13.644 seconds; only
the dead callback regression failed. The fixed source passed all 20 tests in
13.602 seconds.

The Dew backend has no matching eager source callback-type table. Its
`self_host_program_link_append_function_class` uses
`self_host_program_link_is_emitted` to exclude elided functions. The linked
emitter creates function signatures by iterating that filtered `link.functions`
list (`starshine_module.dew`, linked function emission). No Dew production
change is needed for this native type-table defect. This is a source audit,
not a claim that both compilers use the same closure ABI.

Raw commands, source snapshots, binary identities, WAT, section sizes, and test
logs are under `/tmp/dewdrop-review-2026-10-18/semantics/callback-size/`.
The fragment context now includes `callback-signature-liveness-v1` so old
physical plans cannot share a key with the changed planner. The envelope and
codec stay at version 1. A narrow test proves that the pre-policy and current
contexts produce different fragment keys. Type-layout inputs are unchanged.
The existing whole-program output cache separately requires a compiler
fingerprint; this fix adds no new cache framework or fingerprint source.

The old cache seeded by the before CLI had three warm fragment hits. The first
partial-filter CLI produced byte-identical fresh/warm artifacts at 4,223 bytes.
The affected generic modules bypass that fragment cache, so this probe does
not prove a stale aggregate result. The explicit policy guard covers the
changed planner contract. Final post-build binary size, runtime, cache, and
compiler-time results follow below.
