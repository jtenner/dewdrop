# Specialization Receiver Proof

## Target normalization

An unresolved method call can retain a consumed wrapper around its field
target. The wrapper has no type meaning:

```text
normalize(consumed(e)) = normalize(e)
normalize(field(r, n)) = field(r, n)
```

Receiver extraction is then:

```text
normalize(target) = field(r, n)
────────────────────────────────
receiver(target) = r
```

The receiver can also carry a consumed wrapper. Receiver normalization removes
it before reading applied type arguments:

```text
receiver(target) = consumed(r)
────────────────────────────────
normalized_receiver(target) = r
```

It is invalid to stop after removing `consumed`:

```text
target = consumed(field(r, n))
───────────────────────────────  invalid
receiver(target) = field(r, n)
```

## Generic specialization

For a receiver with applied type arguments:

```text
Γ ⊢ r : C<τ₀, …, τₙ₋₁>    0 ≤ i < n
────────────────────────────────────────
receiver_shape(target, i) = carrier(τᵢ)
```

For `Map<K,V>.get`, this gives:

```text
Γ ⊢ r : Map<K,V>
────────────────────────────
specialize(r.get, 0) = carrier(K)
specialize(r.get, 1) = carrier(V)
```

Thus `Map<U32,U32>.get` must use specialization `<i32,i32>`. Reading generic
arguments from the intermediate field expression can select an unrelated
specialization such as `<i32,i64>`.

## Receiver field recovery

When the receiver expression has stale inference, its selected or declared
field is exact evidence. The unresolved case requires both owner and name:

```text
owner(caller) = D    field.declaration = D    field.name = n
field.type = C<τ₀, …, τₙ₋₁>    0 ≤ i < n
─────────────────────────────────────────────────────────
receiver_argument_shape(self.n, i) = carrier(τᵢ)
```

The conjunction `field.declaration = D ∧ field.name = n` prevents a field with
the same spelling on another type from being selected.

If the caller owner is not available at this early phase, the module can still
provide exact evidence when the field name is unique:

```text
∃! f ∈ module.fields, f.name = n
───────────────────────────────
unique_field(module, n) = f
```

For zero matches or more than one match, recovery returns `none`. It never picks
the first name match.

## Physical link refinement

Before the body planner accepts a linked specialization, it checks every known
receiver argument:

```text
known = { i | receiver_argument_shape(r, i) = κᵢ }
known ≠ ∅
∀i ∈ known, specialization_shape(f, i) = κᵢ
────────────────────────────────────────────────────
receiver_matches(r, f)
```

If the recorded function does not match, the planner searches only functions
with the same declaration. It replaces the function only when exactly one
candidate matches. Zero or multiple candidates keep the original bad value so
the runtime carrier assertion remains visible and diagnostic.

## Final call normalization

All discovery paths converge on one normalization step before specialized
request bodies are scanned:

```text
call.target = f    generics(f) = <α₀, …, αₙ₋₁>
∀i < n, receiver_argument_shape(call.receiver, i) = κᵢ
request(f, <κ₀, …, κₙ₋₁>) = σ
──────────────────────────────────────────────────────
normalize(call).target_specialization = σ
```

Request insertion is deduplicated. Therefore two scans that discover the same
receiver shapes use the same request index.

Calls can be discovered while specialized request bodies are scanned. The
normalization cursor preserves linear work:

```text
0 ≤ cursor ≤ |calls|
normalize(calls[cursor … |calls|])
──────────────────────────────────
cursor′ = |calls|
```

Each appended call is normalized once. A normalized call can append a request,
and the dynamic request worklist then scans that request.
