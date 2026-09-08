///|
test "raw forwarding cannot replace a declared result with Never" {
  let lowering = syntax_cycle_test_lowering(
    b"builtin trap() -> Never = \"unreachable\"\nstruct Box {}\nfn scalar() -> I64 {\n  trap()\n}\nfn reference() -> Box {\n  trap()\n}\nfn effect() -> Unit {\n  trap()\n}\nfn never() -> Never {\n  trap()\n}\npub fn main() -> I64 {\n  42i64\n}\n",
  )
  let names : Map[DeclId, Bytes] = {}
  for callable in lowering.functions.callables {
    if callable.kind is PlannedBuiltinCallable(name) {
      names[callable.declaration] = name
    }
  }
  let mut checked = 0
  for callable in lowering.functions.callables {
    if callable.name == b"scalar" ||
      callable.name == b"reference" ||
      callable.name == b"effect" {
      assert_eq(wasmgc_direct_builtin_of(lowering, callable, names), b"")
      checked += 1
    } else if callable.name == b"never" {
      assert_eq(
        wasmgc_direct_builtin_of(lowering, callable, names),
        b"unreachable",
      )
      checked += 1
    }
  }
  assert_eq(checked, 4)
}
