# Disposable foundation

Date: 2026-08-11

`dew.std.disposable` defines non-ambient cleanup evidence:

```dew
pub trait Disposable {
  fn dispose(self) -> Unit
}
```

The generic `dispose(value)` helper dispatches through ordinary coherent `Disposable` evidence. The operation returns `Unit`; cleanup errors are not a second implicit control-flow channel. An implementation may trap, and deterministic trap unwinding is explicitly excluded from the initial cleanup model.

Dew does not yet have linear or affine ownership. Passing a mutable reference object as `self` does not invalidate aliases or prevent a later manual call. Direct `dispose` calls therefore remain the caller's responsibility, including idempotence and double-disposal policy. The implemented `using` form provides compiler-controlled exactly-once disposal for one lexical binding across fallthrough, return, break, and continue without claiming that arbitrary aliases are statically consumed.

`Disposable` remains outside the ambient preamble so ordinary modules pay no trait/evidence surface unless cleanup APIs are imported.
