# Standard `Option` and `Result`

Dew provides generic sum types from independently frozen compiler-owned modules:

```dew
pub enum Option<t> {
  None
  Some(t)
}

pub enum Result<t, e> {
  Ok(t)
  Err(e)
}
```

`dew.std.option` and `dew.std.result` are ambient standard interfaces alongside `dew.std.preamble`. Text and byte search APIs return `Option<U32>`; the raw `0xffffffff` search sentinel remains private to runtime builtins.

Generic enum payloads use one deterministic erased aggregate layout per declaration. Each generic payload position reserves physical carrier fields for `i32`, `i64`, `f32`, `f64`, `v128`, and nullable `eqref`; construction initializes the selected carrier and zero/null-initializes the others, while pattern lowering reads only the carrier selected by the inferred payload shape. This supports mixed scalar, SIMD, and reference instantiations without runtime wrapper objects or per-instantiation type-index nondeterminism. Dead generic enums and dead signatures are pruned before final type linking.

Generic functions and generic structs remain separately unsupported. This slice intentionally enables generic enum construction, transport, and pattern matching without claiming the later generic callable ABI.
