# Standard operator preamble

## Status

Implemented for the initial recursive-Fibonacci operator set in the implicit standard module `dew.std.preamble`:

- `Add` for `I32`;
- `Sub` for `I32`;
- `Lte` for `I32`;
- inline builtin declarations for `i32_add`, `i32_sub`, and `i32_lte`.

A program can compile this source without declaring numeric traits or implementations:

```dew
pub fn fib(value: I32) -> I32 {
  if value <= 1 {
    value
  } else {
    fib(value - 1) + fib(value - 2)
  }
}
```

## Standard module naming

The standard-library root is `dew.std`. Modules use short, role-based names:

```text
dew.std.preamble
dew.std.map
dew.std.queue
```

`dew.std.preamble` is implicitly globally imported into ordinary modules. Collection modules such as `dew.std.map` and `dew.std.queue` remain ordinary explicit imports unless the preamble deliberately re-exports selected declarations.

## APIs

The production-oriented byte entry point includes `dew.std.preamble`:

```moonbit
pub fn collect_program_bytes(ModuleId, Bytes) -> CollectedModule
```

The explicit equivalent is:

```moonbit
pub fn collect_bytes_with_standard_preamble(
  ModuleId,
  Bytes,
) -> CollectedModule
```

The existing `collect_bytes` API remains a raw no-preamble phase helper. Keeping it raw avoids perturbing focused collection, resolution, inference, stress, and benchmark fixtures that intentionally construct minimal semantic worlds.

## Separate event streams

The implementation does not prepend or concatenate source bytes. It creates one parser event stream for the compiler-owned `dew.std.preamble` source and a second parser event stream for the user source. `CollectionBuilder` consumes both streams in order:

```text
dew.std.preamble parse events
→ freeze semantic prefix length
→ user parse events
→ CollectedModule
```

This preserves the user's physical byte offsets. A user declaration at byte zero still has offset zero even though its semantic identity follows all preamble declarations and methods.

The preamble currently consumes a stable prefix of 15 declaration identities:

- 3 builtin declarations;
- 3 trait declarations;
- 3 trait requirement method declarations;
- 3 impl declarations;
- 3 impl method declarations.

`CollectedModule.preamble_declaration_count` records this semantic-ID boundary explicitly. Downstream phases therefore need not infer preamble provenance from source offsets or names.

## Initial preamble source

The compiler-owned module is mirrored as three deterministic source files:

```text
std/preamble/00-builtins.dew
std/preamble/10-traits.dew
std/preamble/20-i32.dew
```

The current library embeds equivalent byte literals so every MoonBit target can compile without host file I/O. The future driver will load these files directly and cache the resulting frozen module interface.

The combined module is equivalent to:

```dew
pub builtin i32_add(left: I32, right: I32) -> I32 = "i32_add"
pub builtin i32_sub(left: I32, right: I32) -> I32 = "i32_sub"
pub builtin i32_lte(left: I32, right: I32) -> Bool = "i32_lte"

pub trait Add {
  fn add(self, right: Self) -> Self
}

pub trait Sub {
  fn sub(self, right: Self) -> Self
}

pub trait Lte {
  fn lte(self, right: Self) -> Bool
}

impl Add for I32 {
  fn add(self, right: I32) -> I32 {
    i32_add(self, right)
  }
}

impl Sub for I32 {
  fn sub(self, right: I32) -> I32 {
    i32_sub(self, right)
  }
}

impl Lte for I32 {
  fn lte(self, right: I32) -> Bool {
    i32_lte(self, right)
  }
}
```

These declarations pass through the ordinary parser, collector, type resolver, impl validator, coherence index, body inference, lowering, and directization phases. There is no separate hard-coded operator implementation table in type inference.

## Determinism

Preamble identities are assigned before user identities in one fixed source order. They do not depend on hash iteration, allocation addresses, worker schedules, or user source length.

The backend's selected operator targets point at the exact `dew.std.preamble` impl method declarations. WasmGC fragment planning recognizes the tiny wrappers, freezes their inline builtin evidence, and elides the module-visible wrapper functions. The resulting Fibonacci module still contains only one defined function.

## Current boundary

The initial implementation uses a per-program semantic prefix in the same collected module. This is intentionally smaller than a full cross-module standard-library interface and avoids introducing unstable cross-module evidence before Dew's module import ABI is specified.

The preamble is reparsed for each program compilation. It is small and remains outside hot body inference, but a future package/module layer should cache a frozen `dew.std.preamble` interface under a reserved module identity and import its names and evidence without reparsing.

## Next steps

1. Add the remaining homogeneous numeric and comparison traits.
2. Add signed, unsigned, and floating primitive implementations.
3. Remove the raw primitive binary-typing fallback from production inference once every standard operator has preamble coverage.
4. Add token/file-descriptor production entry points parallel to `collect_program_bytes`.
5. Move `dew.std.preamble` to a cached frozen module interface when cross-module evidence import is implemented.
