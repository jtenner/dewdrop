# Runtime trait values

## Status

The first semantic and lowering tranche is implemented. Bare trait names in value positions are retained as erased runtime trait types. A concrete expression assigned to an expected trait type now freezes the exact coherent implementation evidence instead of unifying the concrete nominal type with the trait type. Calls on a trait-typed receiver freeze a distinct dynamic target containing the trait declaration, requirement declaration, deterministic source-order method slot, and instantiated type arguments.

Backend execution is the next tranche. Until physical trait-object layouts and dictionary functions land, Starshine rejects `PlannedDynamicTraitCall` as unsupported rather than emitting an incorrect direct call.

## Source and inference model

The initial source form uses an existing bare trait type:

```dew
fn invoke(value: Read) -> I32 {
  value.read()
}
```

Concrete-to-trait conversion is implicit only where an expected trait type exists. Inference records `SelectedInferredTraitObjectCoercion(trait, evidence)` on the source expression. Evidence is selected through ordinary visible coherent implementation lookup and retains the same recursive prerequisite tree used by static generic dispatch. Speculative implementation-selection diagnostics are rolled back so successful coercions do not leak candidate mismatches.

Calls on trait receivers record `SelectedDynamicTraitCallTarget(trait, requirement, slot, type_arguments)`. Slots count receiver-bearing trait requirements in deterministic trait source order. Concrete receivers continue to use `SelectedInferredCallTarget` and static implementation methods.

## Lowering contract

`PlannedExpression` retains its optional trait-object coercion independently of its ordinary expression kind, allowing a struct construction, call, local read, branch, or other value-producing expression to be wrapped without losing its original operation. Dynamic calls lower to `PlannedDynamicTraitCall` with exact trait, requirement, slot, receiver, ordinary arguments, and type arguments.

Backend planning must consume this frozen evidence and must not repeat trait resolution.

## Planned WasmGC representation

The execution tranche will use immutable typed dictionaries rather than dedicated mutable Wasm tables:

```text
TraitVTable = struct {
  method_0: ref Method0Signature
  method_1: ref Method1Signature
}

TraitObject = struct {
  receiver: eqref
  vtable: ref TraitVTable
}
```

Each demanded trait receives deterministic object and vtable physical types. Each demanded coherent implementation receives one dictionary and ABI adapters where its concrete receiver signature differs from the erased requirement signature. Dynamic calls load the source-ordered typed function-reference field and invoke it with `call_ref`. Static concrete calls remain direct and allocate no trait object or dictionary.

## Validation

Semantic coverage proves:

- implicit nominal-to-trait coercion freezes concrete implementation evidence;
- calls on trait receivers freeze dynamic requirement and slot identity;
- concrete calls remain statically selected with no trait coercion;
- lowering preserves coercions independently of source expression construction;
- body-job scheduling remains deterministic through the ordinary frozen inference merge.
