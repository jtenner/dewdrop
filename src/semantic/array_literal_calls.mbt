///|
// Source sugar uses an ordinary exact import. The alias and local cannot be
// written as source identifiers, so lexical bindings cannot capture either.
fn CollectionBuilder::lower_array_literal_calls(
  self : CollectionBuilder,
  element_start : Int,
  element_count : Int,
  offset : UInt64,
) -> HirExpr {
  let alias = "$array_literal_library"
  if !self.name_lookup.contains(alias) {
    self.imports.push({
      path: "dew.std.array",
      open_: false,
      wildcard: false,
      import_alias: Some(alias),
      import_alias_offset: offset,
      file: self.current_file,
      offset,
    })
  }
  let alias_name = self.intern(alias)
  let local_name = self.intern(
    "$array_literal$" + self.expressions.length().to_string(),
  )
  let root = self.append_expr(HirImportAliasExpr(alias_name, offset))
  let factory = self.append_expr(
    HirQualifiedExpr(root, self.intern("array_with_capacity"), offset),
  )
  let capacity = self.append_expr(HirU32Expr(element_count.to_uint64(), offset))
  let arguments = self.expression_children.length()
  self.expression_children.push(capacity)
  let allocated = self.append_expr(
    HirCallExpr(factory, { start: arguments, length: 1, }, offset),
  )
  let item_start = self.block_items.length()
  self.block_items.push(
    HirLetItem(false, local_name, offset, allocated, offset),
  )
  self.block_item_files.push(self.current_file)
  for index in 0..<element_count {
    let receiver = self.append_expr(HirNameExpr(local_name, offset))
    let target = self.append_expr(
      HirFieldExpr(receiver, self.intern("push"), offset),
    )
    let arguments = self.expression_children.length()
    self.expression_children.push(self.body_expr_results[element_start + index])
    let call = self.append_expr(
      HirCallExpr(target, { start: arguments, length: 1, }, offset),
    )
    self.block_items.push(HirExpressionItem(call, offset))
    self.block_item_files.push(self.current_file)
  }
  let result = self.append_expr(HirNameExpr(local_name, offset))
  self.block_items.push(HirExpressionItem(result, offset))
  self.block_item_files.push(self.current_file)
  let block = self.blocks.length()
  self.blocks.push({
    items: { start: item_start, length: element_count + 2, },
    offset,
  })
  self.block_files.push(self.current_file)
  HirBlockExpr(block, offset)
}
