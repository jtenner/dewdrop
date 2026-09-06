///|
priv struct DeferredCleanup {
  name : String
  offset : UInt64
  using_name : String?
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
  BlockExpr({ items, offset, })
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
  { items, offset: block.offset, }
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
    ProductExpr(elements, offset) | ArrayExpr(elements, offset) => {
      let transformed : Array[Expr] = []
      for element in elements {
        transformed.push(
          defer_transform_expression(element, cleanups, loop_depth),
        )
      }
      match expression {
        ProductExpr(_, _) => ProductExpr(transformed, offset)
        ArrayExpr(_, _) => ArrayExpr(transformed, offset)
        _ => abort("collection expression changed shape")
      }
    }
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
    ReturnExpr(value, offset) => {
      let items : Array[BlockItem] = []
      match value {
        Some(source) => {
          let name = deferred_result_name(offset)
          items.push(
            LetItem(
              false,
              name,
              offset,
              defer_transform_expression(source, cleanups, loop_depth),
              offset,
            ),
          )
          append_deferred_cleanups(items, cleanups)
          items.push(
            ExpressionItem(
              ReturnExpr(Some(NameExpr(name, offset)), offset),
              offset,
            ),
          )
        }
        None => {
          append_deferred_cleanups(items, cleanups)
          items.push(ExpressionItem(ReturnExpr(None, offset), offset))
        }
      }
      BlockExpr({ items, offset, })
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
    ExplicitTypeCallExpr(callee, type_arguments, arguments, offset) => {
      let transformed : Array[Expr] = []
      for argument in arguments {
        transformed.push(
          defer_transform_expression(argument, cleanups, loop_depth),
        )
      }
      ExplicitTypeCallExpr(
        defer_transform_expression(callee, cleanups, loop_depth),
        type_arguments,
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
    ProductFieldExpr(base, index, arity, offset) =>
      ProductFieldExpr(
        defer_transform_expression(base, cleanups, loop_depth),
        index,
        arity,
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
    TypeBindingItem(_, _, _) => output.push(item)
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
    ExpressionItem(ReturnExpr(Some(value), return_offset), offset) => {
      let name = deferred_result_name(return_offset)
      output.push(
        LetItem(
          false,
          name,
          return_offset,
          defer_transform_expression(value, cleanups, loop_depth),
          return_offset,
        ),
      )
      append_deferred_cleanups(output, cleanups)
      output.push(
        ExpressionItem(
          ReturnExpr(Some(NameExpr(name, return_offset)), return_offset),
          offset,
        ),
      )
    }
    ExpressionItem(ReturnExpr(None, return_offset), offset) => {
      append_deferred_cleanups(output, cleanups)
      output.push(ExpressionItem(ReturnExpr(None, return_offset), offset))
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
    return { items, offset, }
  }
  match items[items.length() - 1] {
    ExpressionItem(ReturnExpr(_, _), _) => { items, offset, }
    ExpressionItem(CallExpr(NameExpr("unreachable", _), [], _), _) =>
      { items, offset, }
    ExpressionItem(BreakExpr(_, _), _)
    | ExpressionItem(ContinueExpr(_, _), _) => { items, offset, }
    ExpressionItem(value, item_offset) => {
      ignore(items.pop())
      let name = deferred_result_name(item_offset)
      items.push(LetItem(false, name, item_offset, value, item_offset))
      append_deferred_cleanups(items, cleanups)
      items.push(ExpressionItem(NameExpr(name, item_offset), item_offset))
      { items, offset, }
    }
    _ => {
      append_deferred_cleanups(items, cleanups)
      { items, offset, }
    }
  }
}

///|
fn deferred_pattern_binds_name(pattern : Pattern, name : String) -> Bool {
  match pattern {
    BindingPattern(bound, _) => bound == name
    QualifiedPattern(base, _, _) => deferred_pattern_binds_name(base, name)
    TuplePattern(base, items, _) => {
      if deferred_pattern_binds_name(base, name) {
        return true
      }
      for item in items {
        if deferred_pattern_binds_name(item, name) {
          return true
        }
      }
      false
    }
    StructPattern(base, fields, _, _) => {
      if deferred_pattern_binds_name(base, name) {
        return true
      }
      for field in fields {
        if deferred_pattern_binds_name(field.pattern, name) {
          return true
        }
      }
      false
    }
    AlternativePattern(first, alternatives, _) => {
      if deferred_pattern_binds_name(first, name) {
        return true
      }
      for alternative in alternatives {
        if deferred_pattern_binds_name(alternative, name) {
          return true
        }
      }
      false
    }
    WildcardPattern(_)
    | ImportAliasPattern(_, _)
    | RestPattern(_)
    | LiteralPattern(_, _) => false
  }
}

///|
fn deferred_block_dispose_offset(block : Block, name : String) -> UInt64? {
  let mut shadowed = false
  for item in block.items {
    if shadowed {
      continue
    }
    match item {
      TypeBindingItem(_, _, _) => ()
      LetItem(_, bound, _, value, _) => {
        match deferred_expression_dispose_offset(value, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
        if bound == name {
          shadowed = true
        }
      }
      ExpressionItem(value, _) =>
        match deferred_expression_dispose_offset(value, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
      AssignmentItem(target, value, _) | IndexSetItem(target, value, _) => {
        match deferred_expression_dispose_offset(target, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
        match deferred_expression_dispose_offset(value, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
      }
    }
  }
  None
}

///|
fn deferred_arm_dispose_offset(arm : PatternArm, name : String) -> UInt64? {
  if deferred_pattern_binds_name(arm.pattern, name) {
    return None
  }
  match arm.guard_condition {
    Some(value) =>
      match deferred_expression_dispose_offset(value, name) {
        Some(offset) => return Some(offset)
        None => ()
      }
    None => ()
  }
  deferred_expression_dispose_offset(arm.body, name)
}

///|
fn deferred_expression_dispose_offset(
  expression : Expr,
  name : String,
) -> UInt64? {
  match expression {
    CallExpr(FieldExpr(NameExpr(receiver, _), "dispose", _), arguments, offset) => {
      if receiver == name {
        return Some(offset)
      }
      for argument in arguments {
        match deferred_expression_dispose_offset(argument, name) {
          Some(found) => return Some(found)
          None => ()
        }
      }
      None
    }
    CallExpr(NameExpr("dispose", _), arguments, offset) => {
      match arguments {
        [NameExpr(argument, _)] if argument == name => return Some(offset)
        _ => ()
      }
      for argument in arguments {
        match deferred_expression_dispose_offset(argument, name) {
          Some(found) => return Some(found)
          None => ()
        }
      }
      None
    }
    ProductExpr(elements, _) | ArrayExpr(elements, _) => {
      for element in elements {
        match deferred_expression_dispose_offset(element, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
      }
      None
    }
    LambdaExpr(parameters, _, body, _) => {
      for parameter in parameters {
        if parameter.name == name {
          return None
        }
      }
      deferred_block_dispose_offset(body, name)
    }
    ObjectExpr(fields, _) | ConstructExpr(_, fields, _) => {
      match expression {
        ConstructExpr(base, _, _) =>
          match deferred_expression_dispose_offset(base, name) {
            Some(offset) => return Some(offset)
            None => ()
          }
        _ => ()
      }
      for field in fields {
        match deferred_expression_dispose_offset(field.value, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
      }
      None
    }
    BlockExpr(block) => deferred_block_dispose_offset(block, name)
    IfExpr(condition, then_block, alternative, _) => {
      match deferred_expression_dispose_offset(condition, name) {
        Some(offset) => return Some(offset)
        None => ()
      }
      match deferred_block_dispose_offset(then_block, name) {
        Some(offset) => return Some(offset)
        None => ()
      }
      match alternative {
        Some(value) => deferred_expression_dispose_offset(value, name)
        None => None
      }
    }
    MatchExpr(scrutinee, arms, _) | WhileExpr(scrutinee, arms, _) => {
      match deferred_expression_dispose_offset(scrutinee, name) {
        Some(offset) => return Some(offset)
        None => ()
      }
      for arm in arms {
        match deferred_arm_dispose_offset(arm, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
      }
      None
    }
    IsExpr(scrutinee, _, _)
    | PrefixExpr(_, scrutinee, _)
    | FieldExpr(scrutinee, _, _)
    | QualifiedExpr(scrutinee, _, _)
    | ProductFieldExpr(scrutinee, _, _, _) =>
      deferred_expression_dispose_offset(scrutinee, name)
    ReturnExpr(Some(value), _) | BreakExpr(value, _) | ContinueExpr(value, _) =>
      deferred_expression_dispose_offset(value, name)
    ReturnExpr(None, _) => None
    BinaryExpr(_, left, right, _) | IndexExpr(left, right, _) =>
      match deferred_expression_dispose_offset(left, name) {
        Some(offset) => Some(offset)
        None => deferred_expression_dispose_offset(right, name)
      }
    CallExpr(callee, arguments, _)
    | ExplicitTypeCallExpr(callee, _, arguments, _) => {
      match deferred_expression_dispose_offset(callee, name) {
        Some(offset) => return Some(offset)
        None => ()
      }
      for argument in arguments {
        match deferred_expression_dispose_offset(argument, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
      }
      None
    }
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
    | ImportAliasExpr(_, _) => None
  }
}

///|
fn deferred_block_escape_offset(block : Block, name : String) -> UInt64? {
  let mut shadowed = false
  for item in block.items {
    if shadowed {
      continue
    }
    match item {
      TypeBindingItem(_, _, _) => ()
      LetItem(_, bound, _, value, _) => {
        match deferred_expression_escape_offset(value, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
        if bound == name {
          shadowed = true
        }
      }
      ExpressionItem(value, _) =>
        match deferred_expression_escape_offset(value, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
      AssignmentItem(target, value, _) | IndexSetItem(target, value, _) => {
        match deferred_expression_escape_offset(target, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
        match deferred_expression_escape_offset(value, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
      }
    }
  }
  None
}

///|
fn deferred_expression_escape_offset(
  expression : Expr,
  name : String,
) -> UInt64? {
  match expression {
    LambdaExpr(_, _, _, _) => None
    ReturnExpr(Some(NameExpr(value, offset)), _) if value == name =>
      Some(offset)
    ReturnExpr(Some(value), _) => deferred_expression_escape_offset(value, name)
    ReturnExpr(None, _) => None
    BlockExpr(block) => deferred_block_escape_offset(block, name)
    IfExpr(condition, then_block, alternative, _) => {
      match deferred_expression_escape_offset(condition, name) {
        Some(offset) => return Some(offset)
        None => ()
      }
      match deferred_block_escape_offset(then_block, name) {
        Some(offset) => return Some(offset)
        None => ()
      }
      match alternative {
        Some(value) => deferred_expression_escape_offset(value, name)
        None => None
      }
    }
    MatchExpr(scrutinee, arms, _) | WhileExpr(scrutinee, arms, _) => {
      match deferred_expression_escape_offset(scrutinee, name) {
        Some(offset) => return Some(offset)
        None => ()
      }
      for arm in arms {
        if deferred_pattern_binds_name(arm.pattern, name) {
          continue
        }
        match deferred_expression_escape_offset(arm.body, name) {
          Some(offset) => return Some(offset)
          None => ()
        }
      }
      None
    }
    ObjectExpr(fields, _) | ConstructExpr(_, fields, _) => {
      for field in fields {
        match field.value {
          NameExpr(value, offset) if value == name => return Some(offset)
          _ => ()
        }
      }
      None
    }
    _ => None
  }
}

///|
fn deferred_using_violation(
  item : BlockItem,
  cleanups : Array[DeferredCleanup],
) -> ExpressionError? {
  for cleanup in cleanups {
    let name = match cleanup.using_name {
      Some(value) => value
      None => continue
    }
    let dispose_offset = match item {
      TypeBindingItem(_, _, _) => None
      LetItem(_, _, _, value, _) | ExpressionItem(value, _) =>
        deferred_expression_dispose_offset(value, name)
      AssignmentItem(target, value, _) | IndexSetItem(target, value, _) =>
        match deferred_expression_dispose_offset(target, name) {
          Some(offset) => Some(offset)
          None => deferred_expression_dispose_offset(value, name)
        }
    }
    match dispose_offset {
      Some(offset) => return Some(UsingDoubleDispose(name, offset))
      None => ()
    }
    let escape_offset = match item {
      TypeBindingItem(_, _, _) => None
      ExpressionItem(value, _) | LetItem(_, _, _, value, _) =>
        deferred_expression_escape_offset(value, name)
      AssignmentItem(target, value, _) | IndexSetItem(target, value, _) =>
        match deferred_expression_escape_offset(target, name) {
          Some(offset) => Some(offset)
          None => deferred_expression_escape_offset(value, name)
        }
    }
    match escape_offset {
      Some(offset) => return Some(UsingValueEscape(name, offset))
      None => ()
    }
  }
  None
}

///|
fn deferred_cleanup_registration(
  value : Expr,
  offset : UInt64,
  using_name : String?,
) -> (BlockItem, DeferredCleanup) {
  let name = deferred_cleanup_name(offset)
  let body = { items: [ExpressionItem(value, offset)], offset, }
  let lambda = LambdaExpr([], NamedType("Unit", offset), body, offset)
  (LetItem(false, name, offset, lambda, offset), { name, offset, using_name, })
}

///|
fn Parser::parse_block_using_items(
  self : Parser,
  open_offset : UInt64,
  using_offset : UInt64,
) -> Result[(BlockItem, BlockItem, DeferredCleanup), RecoveryFailure] {
  let (name, name_offset) = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Identifier(name) => {
          self.consume_lookahead()
          (name, token.offset())
        }
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          return Err(expression_failure(LexicalError(error, offset)))
        }
        _ =>
          return Err(expression_failure(ExpectedBlockBindingName(Some(token))))
      }
    None => return Err(expression_failure(ExpectedBlockBindingName(None)))
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Equal) => self.consume_lookahead()
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          return Err(expression_failure(LexicalError(error, offset)))
        }
        _ => return Err(expression_failure(ExpectedBlockEqual(Some(token))))
      }
    None => return Err(expression_failure(ExpectedBlockEqual(None)))
  }
  let value = match self.parse_expression_recoverable() {
    Ok(expression) => expression
    Err(error) => return Err(error)
  }
  match self.finish_block_item_line(open_offset) {
    Err(error) => Err(error)
    Ok(_) => {
      let binding = LetItem(false, name, name_offset, value, using_offset)
      let disposal = CallExpr(
        FieldExpr(NameExpr(name, name_offset), "dispose", using_offset),
        [],
        using_offset,
      )
      let (registration, cleanup) = deferred_cleanup_registration(
        disposal,
        using_offset,
        Some(name),
      )
      Ok((binding, registration, cleanup))
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
    Ok(_) => Ok(deferred_cleanup_registration(value, defer_offset, None))
  }
}
