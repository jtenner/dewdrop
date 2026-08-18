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

Generic enum payloads use a compact physical subtype for each carrier form that the program needs. Each subtype stores the enum tag and only the payload fields for that form. For example, `Result<I32, I32>::Err` stores `(tag: i32, value: i32)`. It does not reserve unused `i64`, `f32`, `f64`, `v128`, or reference fields. Scalar, SIMD, and reference forms remain unboxed. Program-wide planning gives each needed form a stable type index. Dead generic enums and dead signatures are pruned before final type linking.

Generic functions and generic structs remain separately unsupported. This slice intentionally enables generic enum construction, transport, and pattern matching without claiming the later generic callable ABI.
