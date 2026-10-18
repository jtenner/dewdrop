///|
test "bench f32 decimal old narrowing" (it : @bench.T) {
  let sources = ["1.25", "1.1", "0.01", "3.14159265", "1.0e-30"]
  it.bench(fn() {
    for source in sources {
      let value = @string.parse_double(source) catch {
        _ => abort("bad benchmark decimal")
      }
      it.keep(Float::from_double(value))
    }
  })
}

///|
test "bench f32 decimal midpoint correction" (it : @bench.T) {
  let sources = ["1.25", "1.1", "0.01", "3.14159265", "1.0e-30"]
  it.bench(fn() {
    for source in sources {
      let value = @string.parse_double(source) catch {
        _ => abort("bad benchmark decimal")
      }
      it.keep(round_f32_decimal(source, value))
    }
  })
}
