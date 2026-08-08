# Derived Debug and ambient output

## Status

Dew now accepts postfix `derive(Debug)` on structs and enums. Expansion is parser-owned synthetic AST, so generated implementations pass through the ordinary trait, coherence, inference, lowering, reachability, specialization, and backend pipelines.

The ambient preamble defines:

```dew
pub trait Debug {
  fn debug(self) -> U32
}

pub builtin debug<t: Debug>(value: t) -> U32 = "dew_debug_dispatch"
```

`debug(value)` is an inference-time facade. After ordinary call constraints settle, the compiler replaces it with the unique coherent instance method selected for the argument type. The facade itself is therefore not emitted as a generic runtime call and does not introduce a special aggregate backend path.

## Current formatting contract

The first implementation intentionally establishes deterministic streaming and dispatch before recursive formatting:

- structs write `Type { field, ... }` in source field order;
- unit variants write `Type::Variant`;
- tuple variants write `Type::Variant(_, ...)` in payload order;
- struct variants write `Type::Variant { field, ... }` in source field order;
- empty structs and empty struct variants retain explicit braces;
- no newline is appended;
- output goes to file descriptor 1 through the existing bounded WASI `Bytes` writer;
- the return value is the underlying `U32` WASI result.

Recursive primitive and payload-value formatting remains follow-up work. Generic derived methods currently remain valid because this initial shape-only form does not require runtime dictionaries for their type parameters.

## Generic method specialization fix

A generic derived implementation owns the target type parameters while its method has no method-local parameters. Program linking previously selected the empty method-local span and could not materialize the derived method specialization. Callable generic selection now prefers owner implementation parameters, then falls back to method-local parameters. The runtime fixture exercises `Wrapper<I32>` to keep this ABI path covered.

## Validation

`tests/module-snapshots/types/derive-debug-runtime.dew` covers structs, tuple and named enum variants, generic nominal specialization, ambient `debug(value)` dispatch, bounded stdout, deterministic WAT, and identical Node/Wago execution.
