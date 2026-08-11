///|
priv struct DeferredCleanup {
  name : String
  offset : UInt64
}

///|
fn deferred_cleanup_name(offset : UInt64) -> String {
  "\u0000dew_defer_" + offset.to_string()
}

///|
fn deferred_result_name(offset : UInt64) -> String {
  "\u0000dew_defer_result_" + offset.to_string()
}

///|
fn deferred_cleanup_call(cleanup : DeferredCleanup) -> Expr {
  CallExpr(NameExpr(cleanup.name, cleanup.offset), [], cleanup.offset)
}

///|
fn append_deferred_cleanups(
  items : Array[BlockItem],
  cleanups : Array[DeferredCleanup],
) -> Unit {
  let mut index = cleanups.length()
  while index > 0 {
    index -= 1
    let cleanup = cleanups[index]
    items.push(ExpressionItem(deferred_cleanup_call(cleanup), cleanup.offset))
  }
}

///|
fn deferred_wrap_value(
  value : Expr,
  cleanups : Array[DeferredCleanup],
  offset : UInt64,
) -> Expr {
  if cleanups.length() == 0 {
    return value
  }
  let name = deferred_result_name(offset)
  let items : Array[BlockItem] = [LetItem(false, name, offset, value, offset)]
  append_deferred_cleanups(items, cleanups)
  items.push(ExpressionItem(NameExpr(name, offset), offset))
  BlockExpr({ items, offset })
}

///|
fn defer_transform_block_exits(
  block : Block,
  cleanups : Array[DeferredCleanup],
  loop_depth : Int,
) -> Block {
  if cleanups.length() == 0 {
    return block
  }
  let items : Array[BlockItem] = []
  for item in block.items {
    defer_transform_block_item(items, item, cleanups, loop_depth)
  }
  { items, offset: block.offset }
}

///|
fn defer_transform_arm(
  arm : PatternArm,
  cleanups : Array[DeferredCleanup],
  loop_depth : Int,
) -> PatternArm {
  let guard_condition = match arm.guard_condition {
    Some(value) => Some(defer_transform_expression(value, cleanups, loop_depth))
    None => None
  }
  {
    pattern: arm.pattern,
    guard_condition,
    body: defer_transform_expression(arm.body, cleanups, loop_depth),
    offset: arm.offset,
  }
}

///|
fn defer_transform_expression(
  expression : Expr,
  cleanups : Array[DeferredCleanup],
  loop_depth : Int,
) -> Expr {
  match expression {
    I8Expr(_, _)
    | I16Expr(_, _)
    | I32Expr(_, _)
    | I64Expr(_, _)
    | U8Expr(_, _)
    | U16Expr(_, _)
    | U32Expr(_, _)
    | U64Expr(_, _)
    | F32Expr(_, _)
    | F64Expr(_, _)
    | BoolExpr(_, _)
    | StringExpr(_, _)
    | BytesExpr(_, _)
    | NameExpr(_, _)
    | ImportAliasExpr(_, _)
    | LambdaExpr(_, _, _, _) => expression
    ObjectExpr(fields, offset) => {
      let transformed : Array[ObjectField] = []
      for field in fields {
        transformed.push({
          name: field.name,
          value: defer_transform_expression(field.value, cleanups, loop_depth),
          offset: field.offset,
        })
      }
      ObjectExpr(transformed, offset)
    }
    ConstructExpr(base, fields, offset) => {
      let transformed : Array[ObjectField] = []
      for field in fields {
        transformed.push({
          name: field.name,
          value: defer_transform_expression(field.value, cleanups, loop_depth),
          offset: field.offset,
        })
      }
      ConstructExpr(
        defer_transform_expression(base, cleanups, loop_depth),
        transformed,
        offset,
      )
    }
    BlockExpr(block) =>
      BlockExpr(defer_transform_block_exits(block, cleanups, loop_depth))
    IfExpr(condition, then_block, alternative, offset) => {
      let transformed_alternative = match alternative {
        Some(value) =>
          Some(defer_transform_expression(value, cleanups, loop_depth))
        None => None
      }
      IfExpr(
        defer_transform_expression(condition, cleanups, loop_depth),
        defer_transform_block_exits(then_block, cleanups, loop_depth),
        transformed_alternative,
        offset,
      )
    }
    MatchExpr(scrutinee, arms, offset) => {
      let transformed : Array[PatternArm] = []
      for arm in arms {
        transformed.push(defer_transform_arm(arm, cleanups, loop_depth))
      }
      MatchExpr(
        defer_transform_expression(scrutinee, cleanups, loop_depth),
        transformed,
        offset,
      )
    }
    IsExpr(scrutinee, pattern, offset) =>
      IsExpr(
        defer_transform_expression(scrutinee, cleanups, loop_depth),
        pattern,
        offset,
      )
    WhileExpr(initial, arms, offset) => {
      let transformed : Array[PatternArm] = []
      for arm in arms {
        transformed.push(defer_transform_arm(arm, cleanups, loop_depth + 1))
      }
      WhileExpr(
        defer_transform_expression(initial, cleanups, loop_depth),
        transformed,
        offset,
      )
    }
    BreakExpr(value, offset) => {
      let transformed = defer_transform_expression(value, cleanups, loop_depth)
      if loop_depth == 0 {
        BreakExpr(deferred_wrap_value(transformed, cleanups, offset), offset)
      } else {
        BreakExpr(transformed, offset)
      }
    }
    ContinueExpr(value, offset) => {
      let transformed = defer_transform_expression(value, cleanups, loop_depth)
      if loop_depth == 0 {
        ContinueExpr(deferred_wrap_value(transformed, cleanups, offset), offset)
      } else {
        ContinueExpr(transformed, offset)
      }
    }
    PrefixExpr(operator, value, offset) =>
      PrefixExpr(
        operator,
        defer_transform_expression(value, cleanups, loop_depth),
        offset,
      )
    BinaryExpr(operator, left, right, offset) =>
      BinaryExpr(
        operator,
        defer_transform_expression(left, cleanups, loop_depth),
        defer_transform_expression(right, cleanups, loop_depth),
        offset,
      )
    CallExpr(callee, arguments, offset) => {
      let transformed : Array[Expr] = []
      for argument in arguments {
        transformed.push(
          defer_transform_expression(argument, cleanups, loop_depth),
        )
      }
      CallExpr(
        defer_transform_expression(callee, cleanups, loop_depth),
        transformed,
        offset,
      )
    }
    FieldExpr(base, name, offset) =>
      FieldExpr(
        defer_transform_expression(base, cleanups, loop_depth),
        name,
        offset,
      )
    QualifiedExpr(base, name, offset) =>
      QualifiedExpr(
        defer_transform_expression(base, cleanups, loop_depth),
        name,
        offset,
      )
    IndexExpr(base, index, offset) =>
      IndexExpr(
        defer_transform_expression(base, cleanups, loop_depth),
        defer_transform_expression(index, cleanups, loop_depth),
        offset,
      )
  }
}

///|
fn defer_transform_block_item(
  output : Array[BlockItem],
  item : BlockItem,
  cleanups : Array[DeferredCleanup],
  loop_depth : Int,
) -> Unit {
  if cleanups.length() == 0 {
    output.push(item)
    return
  }
  match item {
    LetItem(mutable_, name, name_offset, value, offset) =>
      output.push(
        LetItem(
          mutable_,
          name,
          name_offset,
          defer_transform_expression(value, cleanups, loop_depth),
          offset,
        ),
      )
    ReturnItem(Some(value), offset) => {
      let name = deferred_result_name(offset)
      output.push(
        LetItem(
          false,
          name,
          offset,
          defer_transform_expression(value, cleanups, loop_depth),
          offset,
        ),
      )
      append_deferred_cleanups(output, cleanups)
      output.push(ReturnItem(Some(NameExpr(name, offset)), offset))
    }
    ReturnItem(None, offset) => {
      append_deferred_cleanups(output, cleanups)
      output.push(ReturnItem(None, offset))
    }
    AssignmentItem(target, value, offset) =>
      output.push(
        AssignmentItem(
          defer_transform_expression(target, cleanups, loop_depth),
          defer_transform_expression(value, cleanups, loop_depth),
          offset,
        ),
      )
    IndexSetItem(target, value, offset) =>
      output.push(
        IndexSetItem(
          defer_transform_expression(target, cleanups, loop_depth),
          defer_transform_expression(value, cleanups, loop_depth),
          offset,
        ),
      )
    ExpressionItem(value, offset) =>
      output.push(
        ExpressionItem(
          defer_transform_expression(value, cleanups, loop_depth),
          offset,
        ),
      )
  }
}

///|
fn finalize_deferred_block(
  items : Array[BlockItem],
  cleanups : Array[DeferredCleanup],
  offset : UInt64,
) -> Block {
  if cleanups.length() == 0 || items.length() == 0 {
    return { items, offset }
  }
  match items[items.length() - 1] {
    ReturnItem(_, _) => { items, offset }
    ExpressionItem(CallExpr(NameExpr("unreachable", _), [], _), _) =>
      { items, offset }
    ExpressionItem(BreakExpr(_, _), _)
    | ExpressionItem(ContinueExpr(_, _), _) => { items, offset }
    ExpressionItem(value, item_offset) => {
      ignore(items.pop())
      let name = deferred_result_name(item_offset)
      items.push(LetItem(false, name, item_offset, value, item_offset))
      append_deferred_cleanups(items, cleanups)
      items.push(ExpressionItem(NameExpr(name, item_offset), item_offset))
      { items, offset }
    }
    _ => {
      append_deferred_cleanups(items, cleanups)
      { items, offset }
    }
  }
}

///|
fn Parser::parse_block_defer_item(
  self : Parser,
  open_offset : UInt64,
  defer_offset : UInt64,
) -> Result[(BlockItem, DeferredCleanup), RecoveryFailure] {
  let value = match self.parse_expression_recoverable() {
    Ok(expression) => expression
    Err(error) => return Err(error)
  }
  match self.finish_block_item_line(open_offset) {
    Err(error) => Err(error)
    Ok(_) => {
      let name = deferred_cleanup_name(defer_offset)
      let body = {
        items: [ExpressionItem(value, defer_offset)],
        offset: defer_offset,
      }
      let lambda = LambdaExpr(
        [],
        NamedType("Unit", defer_offset),
        body,
        defer_offset,
      )
      Ok(
        (
          LetItem(false, name, defer_offset, lambda, defer_offset),
          { name, offset: defer_offset },
        ),
      )
    }
  }
}
