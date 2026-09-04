# Zero-arity variant recovery

This note covers the compiler-B failure in `array_at_index`. The self-hosted
inference pass kept the source name `None`, but lost its variant-selection
record. Lowering therefore marked the expression as poison.

## Rule

Let `name(e)` be the preserved source name. Let `V(n, 0)` return a physical
variant subtype only when the name and zero-field arity select one unique
subtype.

\[
\frac{
  \operatorname{name}(e)=n
  \qquad
  V(n,0)=\kappa_v
  \qquad
  \operatorname{fields}(\kappa_v)=0
}{
  \Phi;\mathcal C\vdash
  \langle e,S\rangle
  \Downarrow
  \langle\mathtt{struct.new}\;\kappa_v,S\cdot\mathtt{ref}\rangle
}
\quad\textsc{Recover-Unit-Variant}
\]

The uniqueness and zero-field checks are required. A name match alone is not
a certificate. `Option::None` uses its pinned run-time subtype, whose zero-field
layout is part of the version-1 run-time ABI. A payload variant needs payload
expressions and must not use this rule.

## Failure rule

\[
V(n,0)=\varnothing
\Longrightarrow
\operatorname{error}(\text{module},\text{body},e,n).
\]

The implementation keeps the existing poison diagnostic when recovery does
not have a unique physical type.

## Status

- Fixed at the source: `self_host_merge_append_expression_selection` writes
  each enum case directly to the merged array. It does not return the enum
  through a branch join.
- Open: name-only `None` recovery does not yet prove the enum owner. It must
  not be treated as a certificate until owner and uniqueness checks exist.
- Test open: the bootstrap must show that `Option::None` in `std/array.dew`
  keeps its semantic selection and does not need poison recovery.
- Tested: `semantic_inference_merge_test.dew` checks that a variant selection
  keeps its declaration, tag, and rebased type-argument span.
- Open: prove enum payload preservation for the concrete Dew lowering.
