# Derived Debug and ambient output

## Status

Dew now accepts postfix `derive(Debug)` on structs and enums. Expansion is parser-owned synthetic AST, so generated implementations pass through the ordinary trait, coherence, inference, lowering, reachability, specialization, and backend pipelines.

The ambient preamble defines:

```dew
pub trait Debug {
  fn debug(self) -> Unit
}

pub builtin debug<t: Debug>(value: t) -> Unit = "dew_debug_dispatch"
```

`debug(value)` is an inference-time facade. After ordinary call constraints settle, the compiler replaces it with the unique coherent instance method selected for the argument type. The facade itself is therefore not emitted as a generic runtime call and does not introduce a special aggregate backend path.

## Current formatting contract

Derived output is deterministic and streaming:

- structs write `Type { field: value, ... }` in source field order;
- unit variants write `Type::Variant`;
- tuple variants write `Type::Variant(value, ...)` in payload order;
- struct variants write `Type::Variant { field: value, ... }` in source field order;
- nested generic and non-generic derived values recurse through the same ordinary ambient dispatch;
- empty structs and empty struct variants retain explicit braces;
- `Bool` writes `true` or `false`;
- all eight fixed-width integer types write exact decimal values, including signed minima and unsigned maxima;
- `F32` and `F64` write exact lowercase IEEE-bit forms such as `f32(0x3fc00000)`, preserving signed zero and NaN payload identity;
- `Unit` writes `()`;
- `String` writes quoted valid UTF-8, escaping quote, backslash, newline, carriage return, tab, remaining ASCII controls, and DEL;
- `Bytes` writes `b"..."`, preserving printable ASCII and escaping all other bytes as lowercase `\\xNN`;
- `Swar32` and `Swar64` write their exact unsigned carrier bits in decimal wrappers;
- `V128` writes one high-lane-first 128-bit lowercase hexadecimal wrapper;
- no newline is appended;
- output goes to file descriptor 1 through bounded WASI writes;
- both the trait method and ambient `debug(value)` return `Unit`; internal byte counts are consumed at the preamble boundary.

Generic derives add a `Debug` prerequisite to every owner parameter referenced by
a field or payload type, preserve source bounds, avoid duplicate `Debug` bounds,
and leave phantom parameters unconstrained. Concrete fields are validated by the
ordinary generated formatter body. Ambient `debug(field)` now selects
source-ordered symbolic body evidence before concrete implementation candidates,
and closed-call specialization resolves that evidence to the exact formatter.
Typed lane formats, recursion limits, dynamic dictionary boundaries, and
non-WASI behavior remain follow-up work.

## Generic method specialization fix

A generic derived implementation owns the target type parameters while its method has no method-local parameters. Program linking previously selected the empty method-local span and could not materialize the derived method specialization. Callable generic selection now prefers owner implementation parameters, then falls back to method-local parameters. The runtime fixture exercises `Wrapper<I32>` to keep this ABI path covered.

## Performance and code size

Native collection benchmarks on August 8, 2026:

| workload | mean |
|---|---:|
| 512 structs without derives | 658.17 µs |
| 128 structs with `derive(Eq)` | 593.75 µs |
| 128 structs with `derive(Debug)` | 645.71 µs |
| 128 structs with `derive(Hash)` | 589.79 µs |

The comprehensive Debug runtime fixture is 3,350 WAT lines and 73,116 bytes. It runs with a three-byte simulated host write limit, so every formatter's partial-write loop is exercised under both Node and Wago. Its size intentionally includes all eight integer formatting routines because every width is reached by the boundary matrix; ordinary reachability keeps unused formatting routines and the WASI import out of modules that do not call them.

## Validation

`tests/module-snapshots/types/derive-debug-runtime.dew` covers recursive structs, tuple and named enum variants, recursive generic nominal specialization, Bool, Unit, every integer width at boundary values, exact floating-point and packed-carrier output, escaped String/Bytes output, ambient `debug(value)` dispatch, bounded stdout, deterministic WAT, and identical Node/Wago execution. `derive-debug-missing-field-impl.dew` pins the source-located failure when a concrete recursively formatted field has no visible coherent `Debug` implementation; `derive-debug-generic-missing.dew` pins rejection when a concrete generic argument cannot satisfy the generated prerequisite.
