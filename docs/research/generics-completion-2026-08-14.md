# Generics completion — August 14, 2026

## Status

The remaining concrete generics roadmap tranches are implemented:

- trait and impl method-level generic parameters and bounds;
- exact explicit call-site type arguments;
- structural match-set overload specificity;
- regression enforcement that body-local inference variables never mutate the frozen resolved type interner;
- generic value-returning match joins with `Never` call arms;
- value-extracting Option/Result testing helpers.

Associated types, associated constants, and supertraits are explicitly excluded from the first stable edition. They require a later edition-gated design backed by concrete library requirements.

## Method-level generics and shadowing

Trait methods now use the same generic header as functions and impl methods:

```dew
trait Convert<t> {
  fn convert<u: Eq>(self, value: u) -> u
}
```

Collection assigns method parameters their own stable `GenericParameterId` span. Type lookup checks that span before the containing trait or impl span. Reusing a containing spelling is legal and the immediate method declaration shadows it without conflating identities. Trait implementation validation continues to compare method-generic arity and substitutes requirement parameters by source ordinal.

Runtime trait objects remain object-safe only when the selected requirement has no method-level generics and does not expose `Self` outside the receiver. The same generic requirement remains available through static dispatch.

## Explicit call-site type arguments

Dew uses unambiguous turbofish syntax:

```dew
identity::<I32>(value)
receiver.convert::<String>(value)
Type::make::<Bool>()
```

The list is exact rather than partial: its length must equal the selected declaration's generic count. For methods, the list fills only method-local parameters; generic parameters on the containing impl remain inferred from the receiver, ordinary arguments, and expected result. Explicit type expressions resolve in the enclosing declaration's rigid generic scope, so a generic body may forward `callee::<t>(...)`.

The parser retains explicit calls distinctly, while collection lowers them to ordinary call HIR plus aligned syntax spans. Declaration type resolution canonicalizes those syntax roots without adding body inference variables. Inference seeds candidate argument slots from the resolved explicit types before signature instantiation, candidate trials, trait-obligation validation, and specialization freezing. Exact arity mismatches use `CallTypeArgumentCountMismatch`.

Because Dewdrop is unreleased, the changed parser-event AST schema remains parser artifact V1; incompatible development artifacts are ignored by the current V1 key and codec. Frozen-interface and standard-interface artifacts retain canonical resolved explicit-call type arrays because root or imported consumer bodies may proceed into inference after in-memory freezing or cache restoration.

## Structural overload specificity

Ordinary function and builtin overloads no longer use declared generic-count tiers. After rollback-isolated viability trials, inference compares complete function signatures directionally:

- `A` contains `B` when `A` can be instantiated to `B`;
- `B` is strictly narrower when `A` contains `B` but `B` does not contain `A`;
- the unique undominated viable candidate wins.

Parameters and results participate, including nested applied and structural function types. This selects `Box<Box<t>>` over `Box<t>` for nested boxes and permits an expected nested result to select a zero-argument overload. Results are independent of declaration order. Alpha-equivalent candidates and overlapping-incomparable maxima remain ambiguous.

Containment checks reuse the body-local solver under snapshots. All temporary variables, applications, bindings, and diagnostics roll back before ordinary inference continues.

A first correct implementation trialed and pairwise-compared all 17 candidates in the existing 256-call wide benchmark and measured 57.70 ms release-native. A concrete viable signature is already a singleton match set, so the final implementation safely trials the zero-generic tier first and skips generic candidates when that tier has a winner; generic/generic candidates still use full structural containment when no concrete candidate is viable. The same benchmark then measured 865.65 us. Same-run release-native measurements were 688.60 us for direct calls, 683.04 us for generic calls, 815.90 us for overload pairs, 1.45 ms for the nested worklist, and 1.86 ms for the generic full pipeline. These are development observations rather than cross-machine regression budgets.

## Frozen interner boundary

`ResolvedModuleTypes` contains canonical declaration syntax, rigid generic parameters, and explicit source-written call arguments. Fresh call inference variables remain exclusively in `LocalTypeSolver` and compact inferred-body artifacts. Regression coverage copies the resolved type, argument, and syntax arenas before body inference and requires exact equality afterward, including unresolved and explicitly specialized generic calls.

## Generic `Never` match joins

A direct call whose complete visible candidate set returns `Never` is initialized as `Never` before structural match joins. A diverging arm therefore never aliases its expression type variable with a generic match result. The non-diverging arm determines the generic result as intended.

Backend emission also specializes generic match scrutinee/result scratch locals from the active function specialization rather than the unspecialized `GenericPlannedValueShape`. A direct no-result call typed as `Never` receives an explicit unreachable continuation, preserving Wasm stack polymorphism before surrounding result-local stores.

Runtime coverage exercises scalar, floating, and reference generic carriers through matches whose failure arm calls a separate `Never` function.

## Testing helpers

`dew.std.testing.fail` now returns `Never` while preserving the dynamic assertion message. The module adds:

```dew
expect_option_some<t>(Option<t>, String) -> t
expect_result_ok<t, e>(Result<t, e>, String) -> t
expect_result_err<t, e>(Result<t, e>, String) -> e
```

Success paths return the exact generic payload carrier. Failure paths call `fail`, and dedicated tests cover successful extraction plus every wrong-variant trap.

## Validation

Focused coverage includes:

- parser acceptance of bounded and multiline method generics;
- method/owner shadowing identity;
- matching trait implementation method generics and bounds;
- static versus runtime-trait object safety;
- direct, overloaded, enclosing-generic, instance, and qualified explicit arguments;
- explicit type-argument arity diagnostics;
- nested, result-driven, order-independent, equivalent, and incomparable structural overload sets;
- resolved-interner immutability;
- generic `Never` match inference and executable Wasm across `i32`, `i64`, `f64`, and reference carriers;
- Option/Result extraction success and trap behavior;
- Node and Wago execution snapshots.
