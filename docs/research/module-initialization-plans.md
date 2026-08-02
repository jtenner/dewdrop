# Module initialization plans

## Status

Implemented for Dew's current eager module-level `let` semantics.

Type inference may accept constrained recursive module-value equations, but runtime initialization planning now diagnoses every eager dependency SCC that cannot be evaluated in dependency-first order.

## API

```moonbit
pub fn plan_module_initialization(
  CollectedModule,
  InferredModuleValues,
) -> PlannedModuleInitialization
```

The result is an immutable input to `plan_module_lowering`.

## Steps

Acyclic singleton SCCs become:

```moonbit
PlannedInitializeModuleValue(DeclId, BodyId, BodyTypeId)
```

The step retains the exact declaration, executable initializer body, and frozen inferred module-value type.

Recursive SCCs become one:

```moonbit
PlannedCyclicModuleValues(HirSpan)
```

whose span points into source-ordered `cycle_declarations`. Every member maps to the same step through `declaration_steps`.

Steps preserve the dependency-first SCC order already established by `ModuleValueDependencies`. Independent components remain deterministic under the dependency analyzer's source-order tie breaking.

## Runtime legality

Dew module lets are currently eager values. There are no lazy module values, thunks, or function-value closures that could guard a read. Therefore:

- a multi-declaration SCC is runtime-illegal;
- a singleton SCC is illegal only when it has an explicit self edge;
- an acyclic singleton is initialized normally.

This runtime rule is intentionally separate from type inference. For example:

```dew
let first = second
let second = first + 1
```

has a constrained `I32` type solution but still reads an uninitialized value at runtime. It receives:

```moonbit
EagerModuleInitializationCycle(HirSpan, UInt64)
```

The diagnostic offset is the earliest source offset among cycle members. Diagnostics are source sorted, while steps remain dependency first.

## Determinism and performance

Planning reuses frozen SCC and dependency arenas. It performs one iterative pass over dependency-first SCCs and scans a singleton's edges only to distinguish an ordinary value from self recursion. No graph traversal is repeated.

A 1,024-value dependency chain remains iterative.

Release-mode measurements:

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| Plan 1,024-value chain | 35.99 µs | 22.64 µs | 88.10 µs | 152.64 µs |
| Plan 512 independent values | 17.59 µs | 10.65 µs | 42.50 µs | 77.64 µs |
| Plan 256 two-value cycles | 18.00 µs | 11.31 µs | 38.56 µs | 73.67 µs |
| Full pipeline, 512-value chain | 1.43 ms | 1.06 ms | 2.65 ms | 4.82 ms |

## Remaining work

- Emit the acyclic steps into a deterministic Starshine module initializer.
- Define imported-module initialization ordering.
- Add lazy/static storage classes if Dew later introduces them.
- Decide whether compile-time constants may bypass runtime storage.
- Integrate host-provided builtin initialization and startup entry points.
