# Match result carrier

This note records the carrier join for a value-producing `match` expression.

## Join rule

Let `F` be the set of arms that can fall through with a value. Then:

\[
\frac{
  F\neq\varnothing
  \qquad
  \forall a\in F.\;\Gamma\vdash\operatorname{body}(a):\tau
}{
  \Gamma\vdash\mathsf{match}\ e\ \{a_1,\ldots,a_n\}:\tau
}
\;\textsc{Match-Result}
\]

At the physical boundary, all fallthrough arms must agree on one carrier:

\[
\exists!\kappa.\;
\forall a\in F.\;
\operatorname{ExactCarrier}(\operatorname{body}(a))=\kappa.
\]

Therefore:

\[
\operatorname{ExactCarrier}(\mathsf{match}\ e\ \{a_1,\ldots,a_n\})
=\kappa.
\]

If two fallthrough arms have different carriers, or no arm has a proved
carrier, the result is `unresolved`. Constructor, local, call, and return
assertions then stop compilation before invalid Wasm is emitted.

## Compiler case

The failing compiler expression selected a `U32` in both arms:

\[
\begin{aligned}
\Gamma\vdash e_{\mathsf{Some}} &: \mathsf{U32}, \\
\Gamma\vdash e_{\mathsf{None}} &: \mathsf{U32}, \\
\mathcal C(\mathsf{U32}) &= \mathtt{i32}, \\
\therefore\quad
\operatorname{ExactCarrier}(\mathsf{match}) &= \mathtt{i32}.
\end{aligned}
\]

Status: **Checked**. `self_host_linked_scoped_match_result_shape` checks the
fallthrough-arm carrier join. Constructor scheduling checks the joined carrier
against the physical field.

## Canonical physical result

When an enclosing field, return, call parameter, or local proves the physical
result carrier, that proof has precedence over semantic recovery:

```text
canonical(match e { pᵢ ⇒ eᵢ }) = κ    κ ≠ unresolved
────────────────────────────────────────────────────
exact_emitted_carrier(match e { pᵢ ⇒ eᵢ }) = κ
```

Arm recovery is used only when the canonical carrier is unresolved. This is
required when an old semantic type is `error` or `ref`, but a constructor field
proves that the match must produce `i64`.
