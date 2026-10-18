///|
test "malformed escapes do not expose local declarations during module recovery" {
  for source in [
    b"fn broken() -> Unit {\n  f(\"\\q\", fn() {\n    let inner = 1\n  })\n  let leaked = 2\n}\ntype After = I32\n",
    b"fn broken() -> Unit {\n  f(\"\\xG0\", fn() {\n    let inner = 1\n  })\n  let leaked = 2\n}\ntype After = I32\n",
    b"fn broken() -> Unit {\n  f(b\"\\x0\", fn() {\n    let inner = 1\n  })\n  let leaked = 2\n}\ntype After = I32\n",
  ] {
    let events = parse_bytes(source).to_array()
    assert_eq(events.length(), 2)
    assert_true(events[0] is Diagnostic(_))
    match events[1] {
      Declaration(TypeAlias(value)) => assert_eq(value.name, "After")
      _ => fail("expected only the valid declaration after the broken function")
    }
  }
}
