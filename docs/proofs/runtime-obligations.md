# Runtime proof obligations

Formal proofs use ideal values. Compiler data uses bounded arrays, machine
integers, mutable arenas, and linked indices. Runtime assertions guard that
gap.

## Arena access

For arena \(A\) and index \(i\):

\[
\operatorname{SafeGet}(A,i) \iff 0\le i<|A|.
\]

For span \([s,s+\ell)\):

\[
\operatorname{SafeSpan}(A,s,\ell)
\iff
0\le s\land0\le\ell\land s+\ell\le|A|.
\]

The implementation uses `self_host_array_index_is_valid`,
`self_host_assert_array_index`, and `self_host_assert_array_span`.

The index predicate is a typed `U32` boundary. This matters because the
self-host backend stores signed and unsigned 32-bit values in the same Wasm
`i32` carrier. The typed boundary keeps the unsigned comparison proof:

\[
i:\mathtt{U32}\land n:\mathtt{U32}
\Longrightarrow
\operatorname{Index}(i,n)=(i<_{u}n).
\]

In particular, the missing-index sentinel is rejected for every practical
arena length:

\[
\operatorname{Index}(2^{32}-1,n)=\bot
\qquad(0\le n<2^{32}).
\]

The low-level typed comparisons are in `compiler_value_primitives.dew`.
Parser, semantic, and emitter code can use them without a dependency on a
later compiler phase.

Fragment payload indices also require ownership within their declared payload
span, not just membership in the shared type array. Both compilers first check
equal type/shape array lengths, then `start <= arena_length` and
`length <= arena_length - start`, then `ordinal < length`. Only then do they
compute `start + ordinal`. Failures retain phase 4, module, and variant identity;
an ordinal outside the payload reports `FRG-403`. See the
[payload checks](../research/fragment-payload-spans-2026-09-08.md).

## Lowered syntax is acyclic

Owned indices alone do not exclude cycles. Before physical work-graph creation
and emission, the lowered-body checker also visits expression, block, pattern,
and arm edges with an explicit depth-first stack. Node states are unseen,
active, and done. An edge to an active ancestor reports `ARN-108` with the child
arena tag and global ID. A done child can be shared by more than one parent.

Each node enters at most once and receives one leave event. Each visited edge
can add at most one enter event; a duplicate event for a done node is skipped.
Thus a finite acyclic syntax graph finishes without recursion or a depth cap.
Total node-count addition is checked before allocation, and child ownership
is checked before relative-index subtraction. One U64 stores each event's node
and enter/leave bit, avoiding parallel event arrays.

Control labels, local/capture references, and constructor source metadata are
not syntax edges. A valid loop may therefore have cyclic control flow without
having cyclic syntax. See the [tests and implementation log](../research/lowered-body-cycles-2026-09-08.md).

## Unit boundaries discard emitted values

A Unit expression has no result, but a selected child block can still evaluate
a value-producing tail. If that tail emits the sequence `V`, the enclosing
Unit boundary appends one drop per physical value in `V`. The drop count comes
from the selected, specialized tail shape, not from the enclosing Unit type.
Scalar/reference values count once; native flattened products count their
non-erased leaves. Unit and Never count zero. Branch evaluation and its side
effects are unchanged. This also applies when compile-time selection replaces
an `if` with a block. The self-host carrier worklist does not equate the Unit
parent with its live child: each retains its own evidence. The native
instruction worklist enforces the corresponding drop boundary;
shared tests check both compilers. See the
[branch result log](../research/unit-branch-results-2026-09-08.md).

## Parallel arenas

Native physical type fragments and linked tables are checked before linking
reads and before section emission. Recursive-group spans partition the owned
types; relocations preserve their source identity; canonical signatures own
valid operand/result spans. A second walk reconstructs the emitted type prefix
and requires one assignment per index and an exact final count. Canonical
source aliases may share one emitted signature record, but two emitted records
cannot claim the same index. These are runtime checks and regression tests,
not a proof of all late synthetic adapter or reference-subtyping rules. See
the [type-table checks](../research/physical-type-tables-2026-09-08.md).

Native shared closure and trait layouts now require equal field identities,
mutability, and relocated storage types. Signature aliases require equal
ordered operands and results, with full heap identity and nullability. Source
field references have checked local and recursive ownership. These are runtime
certificates, not a proof that every plan is immutable or every emitted call
preserves Wasm subtyping. See the
[alias checks](../research/physical-type-aliases-2026-09-08.md).

Source function lookup has its own boundary checks. A missing local slot does
not scan other fragments. Present slots retain declaration and plain-instance
identity; imported plain fragments must be unique. Native link preflight checks
table coverage before a later type or call lookup reads it. The self-host
builtin lookup uses checked source indices and no malformed-plan recovery scan.
See the [source lookup checks](../research/source-function-lookups-2026-09-08.md).

For arrays that use the same expression index:

\[
\operatorname{Parallel}(A_1,\ldots,A_n)
\iff
\forall i,j.\;|A_i|=|A_j|.
\]

The implementation uses `self_host_assert_parallel_array_lengths`.

## Carrier agreement

For source type \(\tau\), planned carrier \(\kappa_p\), and emitted carrier
\(\kappa_e\):

\[
\operatorname{CarrierAgreement}(\tau,\kappa_p,\kappa_e)
\iff
\mathcal C(\tau)=\kappa_p\land\kappa_p=\kappa_e.
\]

Call, field, local, branch join, and return emission must check this condition
at their boundary. An unresolved, generic, poison, or consumed value is not a
valid physical carrier certificate.

A concrete planned expression shape can certify its matching Wasm carrier
after scalar canonicalization:

\[
\tau\in\{\mathtt{I32},\mathtt{I64},\mathtt{F32},\mathtt{F64},
\mathtt{V128},\mathtt{Ref}\}
\Longrightarrow
\mathcal C(\tau)=\kappa_\tau.
\]

A product is also a concrete reference value:

\[
\tau=\mathsf{Product}\langle\tau_1,\ldots,\tau_n\rangle
\Longrightarrow
\mathcal C(\tau)=\mathtt{eqref}.
\]

A product projection uses its selected physical pair field:

\[
\frac{
  \Gamma\vdash p:\tau_0\times\tau_1
  \qquad
  j\in\{0,1\}
}{
  \Gamma\vdash p.j:\tau_j
}
\;\textsc{Product-Projection}
\]

If the early projection shape is missing, the linked pair type and field index
provide `τⱼ`. The exact carrier is then `𝒞(τⱼ)`.

This rule covers typed operator expressions such as a `U32` bitwise `or`.
Constructor scheduling rejects an unresolved field carrier before it emits
`struct.new`.

Call lowering uses an ordered carrier certificate:

\[
\operatorname{LinkedResult}(e)
\succ
\operatorname{CanonicalResult}(e)
\succ
\operatorname{ConcreteStaticResult}(e).
\]

Thus, a missing linked call index does not erase a concrete source result:

\[
\frac{
  \Gamma\vdash e:\tau
  \qquad
  \mathcal C(\tau)=\kappa
  \qquad
  \kappa\neq\mathsf{unresolved}
}{
  \operatorname{LinkedResult}(e)=\varnothing
  \Longrightarrow
  \operatorname{ExactCarrier}(e)=\kappa
}
\;\textsc{Static-Call-Fallback}
\]

`self_host_linked_canonical_or_static_expression_carrier` implements the
shared fallback for direct and unresolved calls.

Binary arithmetic preserves the common operand type:

\[
\frac{
  \Gamma\vdash e_1:\tau
  \qquad
  \Gamma\vdash e_2:\tau
  \qquad
  \odot\in\{+,-,\times,\div,\bmod,\land,\lor,\oplus,\ll,\gg\}
}{
  \Gamma\vdash e_1\odot e_2:\tau
}
\;\textsc{Binary-Carrier}
\]

Comparisons and logical operators always produce the Boolean carrier:

\[
\bowtie\in\{=,\neq,<,\le,>,\ge,\land_L,\lor_L\}
\Longrightarrow
\mathcal C(e_1\bowtie e_2)=\mathtt{i32}.
\]

`self_host_linked_concrete_shape_carrier` is the single checked conversion
from a concrete planned shape to a Wasm carrier.

A local read preserves its initializer carrier:

\[
\frac{
  \operatorname{LocalInit}(x)=e
  \qquad
  \operatorname{ExactCarrier}(e)=\kappa
  \qquad
  \kappa\neq\mathsf{unresolved}
}{
  \operatorname{ExactCarrier}(\mathsf{LocalGet}(x))=\kappa
}
\;\textsc{Local-Initializer}
\]

This rule applies to every initializer kind. It replaces the old array-read
special case.

If a local has no initializer carrier, its declared type is the final
certificate:

\[
\frac{
  \operatorname{LocalType}(x)=\tau
  \qquad
  \mathcal C(\tau)=\kappa
  \qquad
  \kappa\neq\mathsf{unresolved}
}{
  \operatorname{ExactCarrier}(\mathsf{LocalGet}(x))=\kappa
}
\;\textsc{Declared-Local}
\]

The full evidence order is:

\[
\operatorname{ConcreteUseExpectedType}
\succ
\operatorname{ConcreteScalarInitializerCarrier}
\succ
\operatorname{CanonicalLocalCarrier}
\succ
\operatorname{BroadReferenceInitializerCarrier}
\succ
\operatorname{DeclaredLocalCarrier}.
\]

The body planner visits expression parents before children. Dewdrop expression
IDs increase from children to parents, so the planner scans the body in reverse
ID order:

\[
\operatorname{id}(child)<\operatorname{id}(parent)
\Longrightarrow
parent\prec_{scan}child.
\]

Thus, one pass can propagate:

\[
\mathsf{if}\to\mathsf{branch\ tail}\to\mathsf{local\ get}
\to\mathsf{local\ slot}\to\mathsf{initializer}.
\]

Child-to-parent joins settle on the next bounded pass.

The planner uses a typed selector for logical type provenance:

\[
\operatorname{PreferredLogicalType}:
\mathtt{I32}\times\mathtt{I32}\to\mathtt{I32}.
\]

\[
\operatorname{PreferredLogicalType}(p,f)=
\begin{cases}
p & p\neq-1,\\
f & p=-1.
\end{cases}
\]

Therefore its result carrier is always `i32`, even when an earlier plan lost
the shapes of the two field-read expressions.

An unresolved source field can still have an exact linked selection:

\[
\frac{
  \operatorname{SelectedStorage}(e)=s
  \qquad
  \operatorname{StorageShape}(s)=\tau
}{
  \operatorname{ExactCarrier}(e)=\mathcal C(\tau)
}
\;\textsc{Selected-Field-Storage}
\]

If storage is not retained directly, the selected physical field is an
equivalent certificate:

\[
\frac{
  \operatorname{SelectedField}(e)=f
  \qquad
  \operatorname{FieldShape}(f)=\tau
}{
  \operatorname{ExactCarrier}(e)=\mathcal C(\tau)
}
\;\textsc{Selected-Field}
\]

For an unresolved field node, an exact field resolved from the receiver's
nominal type has precedence over a broad cached reference selection:

\[
\frac{
  \operatorname{Nominal}(b)=D
  \qquad
  \operatorname{Field}(D,n)=f
  \qquad
  \operatorname{FieldShape}(f)=\tau
}{
  \operatorname{ExactCarrier}(b.n)=\mathcal C(\tau)
}
\;\textsc{Nominal-Field}
\]

Thus:

\[
\operatorname{NominalField}
\succ
\operatorname{ConcreteExpectedType}
\succ
\operatorname{CanonicalCachedField}.
\]

The expected-type step is valid only for a concrete non-reference carrier:

\[
\frac{
  \Gamma\vdash e\Leftarrow\tau
  \qquad
  \mathcal C(\tau)\in
  \{\mathtt{i32},\mathtt{i64},\mathtt{f32},\mathtt{f64},\mathtt{v128}\}
}{
  \operatorname{ExactCarrier}(e)=\mathcal C(\tau)
}
\;\textsc{Concrete-Expected-Carrier}
\]

## Diagnostic rule

An assertion failure is part of the compiler interface:

\[
\neg P(x)
\Longrightarrow
\operatorname{error}(
  \operatorname{phase},
  \operatorname{module},
  \operatorname{body},
  \operatorname{expression},
  \operatorname{expected},
  \operatorname{actual}
).
\]

Do not replace a failed compiler invariant with `unreachable` unless the full
diagnostic has already been made visible.

## Sentinel logical-type selection

The logical-type sentinel is `−1`. All valid logical type indices are
non-negative. Define:

```text
m = preferred ≫ₛ 31
choose(preferred, fallback) =
  (preferred ∧ (m ⊕ −1)) ∨ (fallback ∧ m)
```

The two cases are exhaustive:

```text
preferred = −1
──────────────────────────────
m = −1 ∧ choose(preferred, fallback) = fallback

preferred ≥ 0
──────────────────────────────
m = 0 ∧ choose(preferred, fallback) = preferred
```

Therefore:

```text
preferred ∈ {−1} ∪ ℕ
────────────────────────────────────────────────────────
choose(preferred, fallback) = if preferred ≠ −1 then preferred else fallback
```

The branch-free form also avoids asking an unproved `if` carrier merge to
compile the body planner that is responsible for that same carrier merge.
## Function signature expansion

Before native interning, source signatures have checked spans and reference
indices. An enter/leave traversal rejects an edge to an active structural
signature with ARN-108. Finished nodes can be reused. Thus the structural graph
expanded by signature equality is acyclic and each expansion path is finite.
Nominal references are leaves; their recursive groups are checked separately.
Forward/reverse logical signature tables and callback maps must agree before
they can select a signature. See
[the preflight log](../research/function-type-preflight-2026-09-08.md).

## Physical body freeze witness

The self-host body plan copies its mutable array containers after verification.
Their elements are immutable, so later live-array changes cannot change the
witness. Before and after emission, exact metadata and table-field comparisons
report BOD-605 using the frozen owner. No digest equality substitutes for these
checks. The old post-verification Array target search is removed. This boundary
does not yet prove complete temporary-local coverage or a post-fixed-point audit
of every transfer. See [the freeze log](../research/physical-body-freeze-2026-09-08.md).

The subsequent work-queue audit now executes every existing transfer once more
and requires no change before completion. It uses the same transfer code, not
a second approximation. Queue closure also requires the full audit count and
no active transfer. Strictly decreasing adjacency links prove finite graph
walks; wide node totals and an explicit progress resource diagnostic prevent
machine overflow or silent early completion. This does not prove every transfer
monotone or every physical type sound. See
[the work-queue audit](../research/carrier-work-queue-audit-2026-09-08.md).

## Physical call target updates

A missing call target can become known. A known target can only be repeated;
a different known proposal reports SPC-303. A missing proposal leaves the
current fact unchanged. The setter checks body ownership, complete table length,
and stored expression identity before reading or writing the selected slot.
Thus a successful update preserves the functional call-site mapping. This does
not prove the target selection itself. See
[the target update log](../research/physical-call-target-updates-2026-09-08.md).

The body planner's subsequent receiver-refinement and carrier-based recovery
rules are removed. Carrier equality cannot replace or reconstruct the retained
logical call target. Missing method mappings stay missing at seeding and report
BOD-607 at verification. This is not yet a proof of every earlier selector. See
[the recovery log](../research/body-target-recovery-removal-2026-09-08.md).

## Fixed specialization demand

Query, projection, and bound-call demand is closed over the source caller graph
before specialization requests are created. Resolving selected ordinary calls
or trait implementations cannot add new demand. Thus processing one request
cannot retroactively require logical arguments omitted by an earlier valid
carrier-only request. Generic arity alone does not imply query dependence.
The concrete-Self invariant remains in force. See
[the demand log](../research/frozen-query-demand-2026-09-08.md).

## Unit pattern storage

A missing physical local is valid for a Unit pattern only when the specialized
child type is Unit and its selected payload has a storage certificate. Declared
fields use their checked null-marker record. Existing runtime variant adapters
must match the selected declaration, the exact Unit heap type, and the payload
field. An eqref carrier alone is not proof. See
[the Unit iteration log](../research/generic-array-unit-iteration-2026-09-08.md).
