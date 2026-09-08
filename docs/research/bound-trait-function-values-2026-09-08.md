# Generic function values must retain trait evidence

The same-name trait regression exposed another valid source that native
specialization rejects as `UnsupportedProgramGenericCall`. A generic function
`forward<t: Read>(value: t) -> I64` calls its bound method. A generic factory
`reader<t: Read>() -> fn(t) -> I64` returns `forward`; its caller fixes `t` to
I64. The function value must retain the concrete logical trait witness, just as
a direct call does. Minimal reproducer:

```dew
trait Read {
  fn read(self) -> I64
}
impl Read for I64 {
  fn read(self) -> I64 {
    self
  }
}
fn forward<t: Read>(value: t) -> I64 {
  value.read()
}
fn reader<t: Read>() -> fn(t) -> I64 {
  forward
}
pub fn main(value: I64) -> I64 {
  let callback = reader::<I64>()
  callback(value)
}
```

The first shared fixture rejects two such factories in 8.327 seconds. That
fixture now uses explicit lambda bodies to isolate the emitter name-fallback
removal from this separate function-value specialization gap. This is not a
passing negative test. Preserve the rejected source and fix both compiler paths
before closing the call-target/call-recipe work. Returning a generic lambda
that calls `forward(value)` also loses the target: native emission reports
`MissingFunction` in 0.389 seconds. The isolated emitter fixture therefore
uses non-generic callback factories; the direct generic bound calls still
select between two same-named requirements.
