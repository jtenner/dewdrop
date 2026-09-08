///|
test "derived Debug literal text uses bounded ordinary stores" {
  guard derived_debug_write(b"abcdefghi", 42UL) is BlockExpr(block) else {
    fail("derived literal output must be ordinary Dew control flow")
  }
  assert_eq(block.items.length(), 4)
  assert_eq(
    block.items[0],
    ExpressionItem(
      CallExpr(
        NameExpr("u64_store", 42UL),
        [U32Expr(16UL, 42UL), U64Expr(0x6867666564636261UL, 42UL)],
        42UL,
      ),
      42UL,
    ),
  )
  assert_eq(
    block.items[1],
    ExpressionItem(
      CallExpr(
        NameExpr("u64_store", 42UL),
        [U32Expr(24UL, 42UL), U64Expr(0x69UL, 42UL)],
        42UL,
      ),
      42UL,
    ),
  )
  assert_eq(block.tail_expression(), Some(U32Expr(9UL, 42UL)))
}

///|
test "derived Debug empty text does not call the host" {
  assert_eq(
    derived_debug_write(b"", 17UL),
    BlockExpr({
      items: [ExpressionItem(U32Expr(0UL, 17UL), 17UL)],
      offset: 17UL,
    }),
  )
}

///|
test "derived Debug text resets the bounded staging window" {
  let bytes = Buffer(size_hint=65521)
  for _ in 0..<65521 {
    bytes.write_byte(b'x')
  }
  guard derived_debug_write(bytes.to_bytes(), 0UL) is BlockExpr(block) else {
    fail("large literal output must use ordinary Dew blocks")
  }
  assert_eq(block.items.length(), 8194)
  assert_eq(
    block.items[8190],
    ExpressionItem(
      CallExpr(
        NameExpr("__dew_debug_write_scratch", 0UL),
        [U32Expr(16UL, 0UL), U32Expr(65520UL, 0UL)],
        0UL,
      ),
      0UL,
    ),
  )
  assert_eq(
    block.items[8192],
    ExpressionItem(
      CallExpr(
        NameExpr("__dew_debug_write_scratch", 0UL),
        [U32Expr(16UL, 0UL), U32Expr(1UL, 0UL)],
        0UL,
      ),
      0UL,
    ),
  )
  assert_eq(block.tail_expression(), Some(U32Expr(65521UL, 0UL)))
}
