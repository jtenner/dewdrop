# Native erased Unit pattern bindings

A valid generic functional loop failed native emission:

```dew
fn identity<t>(value: t) -> t {
  while value {
    current => break current
  }
}
pub fn main() -> I32 {
  identity(())
  42i32
}
```

The compiler reported `InvalidLocal` for the `current` binding. Planning correctly
removed its physical local after specializing `t` to Unit. The simple pattern
emitter checked for a physical slot before checking the specialized type. The
full pattern emitter already handled Unit correctly.

The simple emitter now validates the logical local ID, obtains its specialized
shape, and emits no binding instructions for Unit. It still reports
`InvalidLocal` if a scalar or reference binding has no physical local. It adds
no local, allocation, or generated runtime instruction for Unit. Initial-state
evaluation remains in the existing loop emitter.

Two new native tests cover generic Unit loops, generic Unit matches, concrete
Unit loops, and I32/I64/F32/F64/reference controls. The Unit cases encode real
Wasm bytes, decode them, and validate the decoded module. Both tests pass in
7.904 seconds. All seven existing functional-loop backend tests pass in 2.061
seconds. The new Unit test failed before the correction with the original
`InvalidLocal` emission error. No compiler activity exceeded 30 seconds.

Evidence logs are `.tmp/unit-loop-native-red.log` and
`.tmp/unit-loop-native-green.log`. Backend source, test source, executable, and
log hashes are in `data/native-unit-pattern-bindings-2026-10-18/validation.json`.
These isolated checks cover the binding change. The source identity of a
concurrent semantic callback-liveness change was not captured during this build,
so these results do not establish joint callback-filter validation.
