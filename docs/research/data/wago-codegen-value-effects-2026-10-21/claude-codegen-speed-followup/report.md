# GC codegen follow-up: next two changes (read-only)

I read only `classification.json`, `run.json`, the disassembly for functions 2293, 2306 and 2322, and source. I did not open the CPU profile, so I have **not checked** the 13.66% `CollectMinor` figure. I did not find the compiler WAT, so I rely on your description of `intern_function` and `span_matches`.

**Labels:** **[M]** = measured. **[S]** = from source or disassembly. **[I]** = my inference.

## What the new evidence shows

- **[M]** Most sampled native instructions sit in the final-cast struct-ref resolver (402 of 1,090, 36.88%) and type-test/first-field (209, 19.17%). These are sample locations, not removable time.
- **[S]** In 2293, 2306 and 2322 the hottest instruction is the `test` just after `movzx r10d, byte [r9+0xe]`. That is the load of the handle entry's space byte. The next hot spot is the header type load `mov ecx,[r11]`.
- **[I]** So the cost is the chain of dependent loads, which a reordering cannot hide. Only skipping repeat checks helps. A chase that reaches a new object each time cannot benefit.
- **[S]** 2293 shows the chain directly. The code calls the resolver stub, loads `mov edi,[rdx+0x10]` (a child reference), then calls the resolver at once on that child (type `0xe2b`, extent `0x20`).
- **[S]** In 2306, hot samples also sit at `mov eax,[r10+0xc]; shr 16; and 0xff`. That is the reference-field check inside native `struct.new` (`gc_direct.go:1831-1833`).

## Can cheap region transparency reach these chains?

No. It reaches only the first hop.

- **[S]** `gcLocalProvenance` (`gc_resolver.go:76`) accepts only borrowed local reads. In `local0.field0(3631).field1(4281)`, the child and the array come from field loads, so no local key exists for them.
- **[S]** These wrapper fields are mutable. So "local is unchanged" does not prove the child is unchanged.
- **[I]** We need value IDs first:
  - Key each field result as (base value ID, type, field).
  - A `struct.set` to the same (type, field), or any unknown call, ends that value fact.
  - That write does **not** end the base object's address certificate. Keep the two kinds of fact separate.
  - A child gets its own certificate only at its first checked dereference.
- **[I]** Transitive effect summaries are needed only to carry facts across real calls. Inside one call-free interval, local effects are enough. Hot scan loops probably contain calls, so summaries come second.

## Change A (do next): per-function value/effect graph, then cross-splice reuse

- **Where:** a pre-pass in the per-function compile path, `gc_resolver.go` (replace the single certificate slot), `inline.go:1092-1121` (seed and keep facts across region splices), `gc_test_field.go`, `gc_direct.go:emitDirectGCObjectWithStub`.
- **Removes:**
  - A repeat check of the same value in one call-free interval, including across region splices.
  - A repeat field load when no aliasing write happened in between.
  - **[I]** Maybe also the `struct.new` field check, when that value already has a valid certificate in the same no-Go interval. This replaces my earlier constructor lead.
- **Proof obligations:**
  - Never move the first trap.
  - Never make a larger extent from a smaller check.
  - Branch-created facts do not leave a join.
  - Kill facts at every Go entry, helper, safepoint, allocation fallback and host boundary.
  - Keep root-mask consumption exactly as it is.
- **Smallest gate:** a shadow counter build.
  - Always run the original resolver and never use the saved result (the epoch-audit probe design).
  - At each site, count executions where a dominating fact with the same value ID existed. Split the count into: local-only, field-value, and killed (by aliasing write or by call).
  - Go ahead if the field-value class is a real share of resolver executions in 2293, 2294, 2306 and 2322. If it is mostly "killed by call", do Change B first.

## Change B: lazy loop-carried facts plus effect summaries

- **Lazy, not eager.** At loop entry, store 0 to a private non-root home. That store is the only new work on zero-iteration or untaken paths. The first executed site does the normal full check and fills the home. Later sites do `test home; jz full_check`. Any kill inside the loop sets the home back to 0.
- **Effect summaries:** per function, one "never enters Go" bit plus a compact write set of (type, field) pairs. These let a fact survive a call. They do **not** remove root masks. My earlier report mixed the two up.
- **Smallest gate:**
  - Static: in the `intern_function` and `span_matches` loops, check that every call in the body is summary-closed and writes neither 3631.f0 nor 4281.f1.
  - Dynamic: a shadow count of the same value ID being checked across iterations.

## Corrections to my earlier report

1. **No-call loops:** coverage is probably poor, because hot loops likely make calls. Do not prototype this first.
2. **Eager loop-entry probe:** replace it with the lazy first-executed check above.
3. **Effect summaries:** keep them separate from root-mask removal. Masks stay as they are for now.
4. **Fresh-constructor lead:** this is secondary. Value-ID certificate reuse may cover the hot 2306 `struct.new` field checks better. Count it before building anything.
5. **Region transparency:** on its own it covers only the first hop of these chains.

## Keeping compiler RSS low

- Use one reusable arena per worker. Reset it for each function. Size it by instruction count, with a fixed node size. Measure its high-water mark.
- Keep no whole-module SSA. Across functions, keep only the summary bit and write set. Compute the summaries by streaming over function bodies, not from a stored graph.
- Limit worker concurrency by a byte budget, not a fixed count. Large functions then run alone.
- Record compile seconds and peak RSS for each step. **[M]** The attribution run's own figures (0.468 s compile, 514,620 KiB peak RSS) come from the metadata-overlay tool. They are not a production baseline.

I make no promise of any speed gain.
