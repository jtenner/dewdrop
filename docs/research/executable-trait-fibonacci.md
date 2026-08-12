# Executable trait-based Fibonacci

## Status

Implemented end to end for the scalar operations required by recursive `fib(I32) -> I32`.

The production-oriented collector supplies homogeneous `Add`, `Sub`, and `Lte` traits, their `I32` implementations, and their tiny standard-builtin wrappers through the compiler-owned `dew.std.preamble` module. The complete user source is therefore:

```dew
pub fn fib(value: I32) -> I32 {
  if value <= 1 {
    value
  } else {
    fib(value - 1) + fib(value - 2)
  }
}
```

`collect_program_bytes` parses `dew.std.preamble` and user source as separate event streams, preserving user byte offsets while assigning a deterministic preamble semantic-ID prefix. Details are recorded in `docs/research/standard-operator-preamble.md`.

## Frozen operator evidence

Body inference maps each non-logical binary operator to a standard homogeneous trait and method name. Both operand types are unified before candidate selection. The selected implementation method and inferred type arguments are frozen in `operator_targets` and become `PlannedOperatorCall` during deterministic lowering.

The backend never searches for an implementation. It receives the exact selected declaration.

## Inline builtins and wrapper directization

The initial inline builtin registry recognizes:

- `i32_add` as `i32.add`;
- `i32_sub` as `i32.sub`;
- `i32_lt` as `i32.lt_s`;
- `i32_lte` as `i32.le_s`.

WasmGC fragment planning identifies an eligible wrapper only when its frozen body is exactly one direct call to an inline builtin and forwards all callable parameters, in order, without type arguments or other work. The fragment records the builtin name in `direct_builtin`. This inspection happens before Starshine emission and does not repeat trait selection.

Calls to a directizable wrapper emit the primitive instruction directly. A module-visible directizable wrapper is marked `elided`, receives no function index, and contributes no function or code-section entry. Public wrappers remain materialized so their exports remain callable, although internal calls may still directize.

For Fibonacci, all three primitive impl wrappers are elided. Only `fib` remains in the function and code sections.

## Body emission

`src/backend/starshine_code.mbt` uses an explicit task stack and result-fragment stack. It currently emits the scalar subset needed by Fibonacci:

- `i32.const` and Boolean constants;
- `local.get` and body-local `local.set`;
- direct calls;
- directized inline builtins;
- result-producing `if`;
- block roots, dropped intermediate values, and explicit returns.

Parameter and body-local indices come exclusively from frozen `PlannedLocal` spans and runtime shapes.

## Complete module and binary APIs

The backend now emits:

- `TypeSec`;
- `ImportSec`;
- `FuncSec`;
- `ExportSec`;
- `CodeSec`;
- a complete Starshine `Module`.

`emit_starshine_binary` constructs the complete module, validates it with Starshine, and encodes it with `jtenner/starshine/binary::encode_module` without repeating semantic analysis.

## Result

The directized module has one defined function and exports it as `fib`. Its executable body is equivalent to:

```wat
local.get 0
i32.const 1
i32.le_s
if (result i32)
  local.get 0
else
  local.get 0
  i32.const 1
  i32.sub
  call 0
  local.get 0
  i32.const 2
  i32.sub
  call 0
  i32.add
end
```

On July 30, 2026, the generated module:

- passed compiler-side Starshine validation;
- encoded through Starshine successfully;
- instantiated in Node;
- returned `fib(10) == 55` and `fib(15) == 610`.

## Current boundary

The scalar, aggregate, control-flow, module-state, generic, closure, trait-object,
dictionary, and dead-signature milestones originally listed here are implemented.
This note remains the first executable trait-dispatch milestone record. Current
backend and language priorities are tracked in `docs/roadmap.md`.
