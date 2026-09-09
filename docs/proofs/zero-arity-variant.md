# Zero-arity variant identity

The original compiler-B failure in `array_at_index` lost the variant-selection
record while retaining the name `None`. The merge defect is fixed. Physical
selection must not repair another missing record by reading its spelling.

## Rule

Let `selected(e)` be the retained variant declaration, and let `V(d)` be its
linked source fragment. Neither the source name nor a guessed nominal owner
is evidence of the physical target.

\[
\frac{
  \operatorname{selected}(e)=d
  \qquad
  V(d)=\kappa_v
  \qquad
  \operatorname{fields}(\kappa_v)=0
}{
  \Phi;\mathcal C\vdash
  \langle e,S\rangle
  \Downarrow
  \langle\mathtt{struct.new}\;\kappa_v,S\cdot\mathtt{ref}\rangle
}
\quad\textsc{Declared-Zero-Arity-Variant}
\]

Exact declaration identity and zero fields are required. A unique spelling is
still not a certificate. `Option::None` now uses its declared source fragment;
there is no private Option runtime type group. Object-form construction also
retains the selected target and empty operand recipe in the freeze witness.
Payload variants require a separate, complete operand recipe.

## Failure rule

\[
\operatorname{selected}(e)=\varnothing\;\lor\;V(d)=\varnothing
\Longrightarrow
\operatorname{error}(\text{module},\text{body},e,d).
\]

No source-name recovery is permitted after this failure.

## Status

- Fixed at the source: `self_host_merge_append_expression_selection` writes
  each enum case directly to the merged array. It does not return the enum
  through a branch join.
- Removed: name-based Some/None physical recovery and the private Option types.
- Tested: imported qualified and unqualified Option patterns retain their
  selected declaration and use its exact source fragment. Shared Array,
  FixedArray, ring, and Unit execution cases pass with declared Option storage.
- Tested: `semantic_inference_merge_test.dew` checks that a variant selection
  keeps its declaration, tag, and rebased type-argument span.
- Open: prove enum payload preservation for the concrete Dew lowering.

See [the Option migration record](../research/option-declared-layout-2026-09-09.md)
for executable tests and bootstrap results. This note is an obligation, not a
claim of a machine-checked proof.
