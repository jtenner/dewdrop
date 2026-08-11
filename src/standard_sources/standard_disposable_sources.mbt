///|
pub fn standard_disposable_source() -> Bytes {
  b"pub trait Disposable {\n  fn dispose(self) -> Unit\n}\n\npub fn dispose<t: Disposable>(value: t) -> Unit {\n  value.dispose()\n}\n"
}
