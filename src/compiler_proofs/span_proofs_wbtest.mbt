///|
test "proved span end accepts the largest non-overflowing span" {
  assert_eq(proven_span_end(2147483646, 1), 2147483647)
}
