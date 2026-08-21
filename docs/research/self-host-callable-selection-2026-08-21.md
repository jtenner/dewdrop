# Self-host callable selection

Date: 2026-08-21

## Scope

The Dew self-host inference layer now instantiates generic signatures and selects local direct calls.

Implemented behavior:

- iterative generic substitution through product, applied, and function types;
- fresh generic variables for each call;
- selected call targets with zonked type arguments;
- unique non-generic and generic direct calls;
- argument-count diagnostics;
- delayed direct-call selection after basic expression and root constraints;
- rollback-isolated overload candidate tests;
- argument-type and expected-result overload selection;
- deterministic preference for concrete candidates over generic candidates;
- deterministic ambiguous-call and no-match diagnostics;
- explicit resolved-signature evidence traversal for generic variables nested in rigid product, application, and function arguments.

`Self` substitution is represented by the instantiator and will be activated by method and implementation candidate selection, where the implementation owner and receiver type are known.

## Compiler-shaped aggregate safety

A focused applied-signature test exposed an unsafe stack-carried Array write in `initialize_locals`. A global parameter index replaced the loop-local destination index after local-slot coalescing, causing an out-of-bounds trap. The source now computes the branch-selected type first and performs the Array write afterward through a staged store helper.

This keeps production optimization enabled and follows the existing rule: compute branch-selected values before mutable aggregate writes.

## Tests

Focused tests cover:

- fresh primitive generic calls;
- generic substitution through products, applications, and function signatures;
- resolved applications on either side of local unification;
- non-generic direct call targets;
- direct-call arity failures;
- overload selection by argument type;
- overload selection by expected result type;
- concrete-over-generic preference;
- ambiguous overloads;
- missing overloads.

## Remaining selection work

The next layer is member, method, field, constructor, variant, indexing, and trait-operator selection. It must reuse solver snapshots, signature instantiation, selected type arguments, and deterministic candidate ordering from this tranche.
