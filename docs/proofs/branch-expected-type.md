# Branch expected type

This note covers a self-host failure where `Result::Ok` kept its constructor
name but lost the nominal `Result` declaration inside an `if` branch.

## Rule

If an `if` expression has type `T`, its value-producing branches are checked
with expected type `T`.

\[
\frac{
  \Gamma\vdash c:\mathtt{Bool}
  \qquad
  \Gamma\vdash \mathtt{if}\ c\ \{e_t\}\ \mathtt{else}\ \{e_f\}:T
}{
  \Gamma\vdash e_t\Leftarrow T
  \qquad
  \Gamma\vdash e_f\Leftarrow T
}
\quad\textsc{If-Expected}
\]

The compiler can use this rule only when `e_t` is the tail expression of the
then block or `e_f` is the recorded else expression. Other child expressions
do not inherit `T`.

## Constructor consequence

If a branch value is a constructor and `T` has nominal declaration `D`, the
constructor receives `D` as its expected nominal declaration.

\[
\frac{
  \Gamma\vdash e\Leftarrow T
  \qquad
  \operatorname{nominal}(T)=D
  \qquad
  e=K(\bar v)
}{
  \Gamma\vdash K(\bar v):D
}
\quad\textsc{Branch-Constructor}
\]

For a generic variant call, the argument is checked after the result type
substitutes the enum's type arguments. For example, `Err` selects result type
argument 1 and `Ok` selects result type argument 0.

\[
\frac{
  \Gamma\vdash \mathtt{Err}:\forall E.\ E\to\mathtt{Result}\langle S,E\rangle
  \qquad
  \theta(E)=D
  \qquad
  \Gamma\vdash e\Leftarrow E
}{
  \Gamma\vdash e\Leftarrow\theta(E)=D
}
\quad\textsc{Variant-Argument-Expected}
\]

If the `if` expression is on the function result path, the declared function
result supplies `T` even when the planned `if` expression lost its type.

\[
\frac{
  \Gamma\vdash f():R
  \qquad
  \operatorname{resultPath}(f)=\mathtt{if}\ c\ \{e_t\}\ \mathtt{else}\ \{e_f\}
}{
  \Gamma\vdash e_t\Leftarrow R
  \qquad
  \Gamma\vdash e_f\Leftarrow R
}
\quad\textsc{Function-If-Expected}
\]

## Runtime checks

`self_host_linked_expression_expected_nominal` checks that the child is the
then tail or the else expression. It first accepts a nonzero nominal from the
parent type. If that evidence is absent,
`self_host_linked_is_body_result_expression` follows block-tail and `if`
then-block ownership edges. It also follows an `if` node's direct else
expression. It uses the callable's declared result nominal only when those
edges reach the body result.
`self_host_linked_callable_result_nominal_declaration` checks the declaration
owner index, the specialization callable table, and the module function table.
`self_host_linked_variant_argument_expected_nominal` accepts only unary
`Some`, `Ok`, and `Err` calls. It reads the nominal from the matching applied
result type argument. If the call lost that applied type, it can use the same
argument from the declared function result only when the call is on the body
result path.

The lowering can represent the same unary variant payload in an object-field
arena. `self_host_linked_variant_constructor_field_expected_nominal` checks
that there is exactly one field, that its span is valid, that the field wraps
the child expression, and that the selected variant is `Some`, `Ok`, or `Err`.
It then applies the same substitution rule.

If the variant selection is absent, a source name is not enough. Recovery also
requires the constructor to be on the function result path and requires the
declared result owner to agree: `Err` and `Ok` require `Result`; `Some`
requires `Option`.

The helper does not return `(target, fields, variant)` through a `match` join.
The current self-host compiler can leave tuple-result locals uninitialized at
that join. Each selected-variant arm passes its values directly to the checked
helper.

## Carrier join

A value-producing `if` also has one physical result carrier:

\[
\frac{
  \Gamma\vdash c:\mathtt{Bool}
  \qquad
  \Gamma\vdash e_t:\tau
  \qquad
  \Gamma\vdash e_f:\tau
}{
  \Gamma\vdash\mathtt{if}\ c\ \{e_t\}\ \mathtt{else}\ \{e_f\}:\tau
}
\quad\textsc{If-Carrier-Join}
\]

If one branch never returns, the other branch supplies the carrier:

\[
\frac{
  \Gamma\vdash e_t:\mathtt{Never}
  \qquad
  \Gamma\vdash e_f:\tau
}{
  \mathcal C(\mathtt{if}\ c\ \{e_t\}\ \mathtt{else}\ \{e_f\})
  =\mathcal C(\tau)
}
\]

`self_host_linked_if_result_shape` checks this join. The exact-carrier API now
uses that result before constructor emission.

When a branch tail lost its source shape, the canonical parent result supplies
the expected carrier only across an exact control-flow edge:

\[
\frac{
  \operatorname{Tail}(\operatorname{Then}(p))=e
  \;\lor\;
  \operatorname{Else}(p)=e
  \qquad
  \operatorname{CanonicalCarrier}(p)=\kappa
}{
  \operatorname{ExpectedCarrier}(e)=\kappa
}
\quad\textsc{If-Canonical-Edge}
\]

No non-tail child inherits this carrier.

## Status

- Checked: the linked emitter checks the exact parent-child branch relation
  and the function result path.
- Bootstrap target: `Result::Ok` in `facet_runtime.dew`.
- Open: the semantic plan should preserve this expected nominal directly.

## Binary operand type is not the binary result type

Comparison instructions return `i32`, but their operands can use another
carrier. For example, reference equality has this form:

```text
Γ ⊢ e₁ : eqref    Γ ⊢ e₂ : eqref
─────────────────────────────────
Γ ⊢ e₁ = e₂ : i32
```

Thus this rule is invalid:

```text
Γ ⊢ e₁ op e₂ : i32
───────────────────  invalid
Γ ⊢ e₁ : i32
```

Operand recovery first uses the concrete sibling carrier:

```text
Γ ⊢ e₂ : τ    τ ∉ {error, generic, unit, never}
──────────────────────────────────────────────
Γ ⊢ e₁ op e₂ requires e₁ : τ
```

Only logical conjunction and disjunction always require `i32` operands. When a
comparison sibling is unresolved, the compiler keeps the operand unresolved
instead of inventing `i32`.

## Canonical carrier precedence

The physical body plan is the canonical carrier proof used by emission:

```text
canonical(e) = κ    κ ≠ unresolved
──────────────────────────────────
exact_emitted_carrier(e) = κ
```

This rule applies to `if` expressions too. Branch-shape recovery is a fallback:

```text
canonical(e) = unresolved    recover_if(e) = κ
────────────────────────────────────────────
exact_emitted_carrier(e) = κ
```

Re-running semantic shape recovery after a canonical carrier exists can replace
an `eqref` carrier with the `i32` result carrier of a nearby comparison. That is
not sound.
