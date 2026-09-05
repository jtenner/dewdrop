///|
let body_visit_expr = 0

///|
let body_finish_expr = 1

///|
let body_visit_block = 2

///|
let body_finish_block = 3

///|
let body_visit_pattern = 4

///|
let body_finish_pattern = 5

///|
let body_visit_arm = 6

///|
let body_finish_arm = 7

///|
fn CollectionBuilder::push_body_task(
  self : CollectionBuilder,
  kind : Int,
  source : Int,
  first_start : Int,
  second_start : Int,
) -> Unit {
  self.body_task_kinds.push(kind)
  self.body_task_sources.push(source)
  self.body_task_first_starts.push(first_start)
  self.body_task_second_starts.push(second_start)
}

///|
fn CollectionBuilder::schedule_expr(
  self : CollectionBuilder,
  source : @parser.Expr,
) -> Unit {
  let index = self.body_expr_sources.length()
  self.body_expr_sources.push(source)
  self.push_body_task(body_visit_expr, index, 0, 0)
}

///|
fn CollectionBuilder::schedule_block(
  self : CollectionBuilder,
  source : @parser.Block,
) -> Unit {
  let index = self.body_block_sources.length()
  self.body_block_sources.push(source)
  self.push_body_task(body_visit_block, index, 0, 0)
}

///|
fn CollectionBuilder::schedule_pattern(
  self : CollectionBuilder,
  source : @parser.Pattern,
) -> Unit {
  let index = self.body_pattern_sources.length()
  self.body_pattern_sources.push(source)
  self.push_body_task(body_visit_pattern, index, 0, 0)
}

///|
fn CollectionBuilder::schedule_arm(
  self : CollectionBuilder,
  source : @parser.PatternArm,
) -> Unit {
  let index = self.body_arm_sources.length()
  self.body_arm_sources.push(source)
  self.push_body_task(body_visit_arm, index, 0, 0)
}

///|
fn CollectionBuilder::append_expr(
  self : CollectionBuilder,
  expression : HirExpr,
) -> ExprId {
  let id = self.expressions.length()
  guard self.expression_files.length() == id &&
    self.explicit_call_type_argument_spans.length() == id else {
    abort("ARN-103: collection expression arenas have different lengths")
  }
  self.expressions.push(expression)
  self.expression_files.push(self.current_file)
  self.explicit_call_type_argument_spans.push({ start: 0, length: 0, })
  id
}

///|
fn CollectionBuilder::emit_expr(
  self : CollectionBuilder,
  expression : HirExpr,
) -> ExprId {
  let id = self.append_expr(expression)
  self.body_expr_results.push(id)
  id
}

///|
fn CollectionBuilder::record_lambda(
  self : CollectionBuilder,
  parameters : Array[@parser.FnParameter],
  return_type : @parser.TypeExpr,
  body : @parser.Block,
  offset : UInt64,
) -> LambdaId {
  let id = self.lambda_sources.length()
  let parameter_start = self.lambda_parameters.length()
  for parameter in parameters {
    self.lambda_parameters.push({
      name: self.intern(parameter.name),
      type_: self.lower_type(parameter.type_),
      offset: parameter.offset,
    })
    self.lambda_parameter_files.push(self.current_file)
  }
  self.lambda_parameter_spans.push({
    start: parameter_start,
    length: self.lambda_parameters.length() - parameter_start,
  })
  self.lambda_return_types.push(self.lower_type(return_type))
  self.lambda_sources.push(body)
  self.lambda_files.push(self.current_file)
  self.lambda_offsets.push(offset)
  self.lambda_parents.push(self.current_lambda)
  self.lambda_root_bodies.push(self.current_root_body)
  id
}

///|
fn CollectionBuilder::emit_pattern(
  self : CollectionBuilder,
  pattern : HirPattern,
) -> PatternId {
  let id = self.patterns.length()
  self.patterns.push(pattern)
  self.pattern_files.push(self.current_file)
  self.body_pattern_results.push(id)
  id
}

///|
fn CollectionBuilder::visit_expr_source(
  self : CollectionBuilder,
  source_index : Int,
) -> Unit {
  let source = self.body_expr_sources[source_index]
  match source {
    @parser.I8Expr(value, offset) =>
      ignore(self.emit_expr(HirI8Expr(value, offset)))
    @parser.I16Expr(value, offset) =>
      ignore(self.emit_expr(HirI16Expr(value, offset)))
    @parser.I32Expr(value, offset) =>
      ignore(self.emit_expr(HirI32Expr(value, offset)))
    @parser.I64Expr(value, offset) =>
      ignore(self.emit_expr(HirI64Expr(value, offset)))
    @parser.U8Expr(value, offset) =>
      ignore(self.emit_expr(HirU8Expr(value, offset)))
    @parser.U16Expr(value, offset) =>
      ignore(self.emit_expr(HirU16Expr(value, offset)))
    @parser.U32Expr(value, offset) =>
      ignore(self.emit_expr(HirU32Expr(value, offset)))
    @parser.U64Expr(value, offset) =>
      ignore(self.emit_expr(HirU64Expr(value, offset)))
    @parser.F32Expr(value, offset) =>
      ignore(self.emit_expr(HirF32Expr(value, offset)))
    @parser.F64Expr(value, offset) =>
      ignore(self.emit_expr(HirF64Expr(value, offset)))
    @parser.BoolExpr(value, offset) =>
      ignore(self.emit_expr(HirBoolExpr(value, offset)))
    @parser.StringExpr(value, offset) => {
      if !semantic_utf8_is_valid(value) {
        self.diagnostics.push(
          InvalidUtf8StringLiteral(self.current_file, offset),
        )
      }
      ignore(self.emit_expr(HirStringExpr(value, offset)))
    }
    @parser.BytesExpr(value, offset) =>
      ignore(self.emit_expr(HirBytesExpr(value, offset)))
    @parser.NameExpr(name, offset) =>
      ignore(self.emit_expr(HirNameExpr(self.intern(name), offset)))
    @parser.ImportAliasExpr(name, offset) =>
      ignore(self.emit_expr(HirImportAliasExpr(self.intern(name), offset)))
    @parser.ProductExpr(elements, _) | @parser.ArrayExpr(elements, _) => {
      let start = self.body_expr_results.length()
      self.push_body_task(body_finish_expr, source_index, start, 0)
      let mut index = elements.length()
      while index > 0 {
        index -= 1
        self.schedule_expr(elements[index])
      }
    }
    @parser.LambdaExpr(parameters, return_type, body, offset) =>
      ignore(
        self.emit_expr(
          HirLambdaExpr(
            self.record_lambda(parameters, return_type, body, offset),
            offset,
          ),
        ),
      )
    @parser.ObjectExpr(fields, _) => {
      let start = self.body_expr_results.length()
      self.push_body_task(body_finish_expr, source_index, start, 0)
      let mut index = fields.length()
      while index > 0 {
        index -= 1
        self.schedule_expr(fields[index].value)
      }
    }
    @parser.ConstructExpr(target, fields, _) => {
      let start = self.body_expr_results.length()
      self.push_body_task(body_finish_expr, source_index, start, 0)
      let mut index = fields.length()
      while index > 0 {
        index -= 1
        self.schedule_expr(fields[index].value)
      }
      self.schedule_expr(target)
    }
    @parser.BlockExpr(block) => {
      let expr_start = self.body_expr_results.length()
      let block_start = self.body_block_results.length()
      self.push_body_task(
        body_finish_expr, source_index, expr_start, block_start,
      )
      self.schedule_block(block)
    }
    @parser.IfExpr(condition, block, alternative, _) => {
      let expr_start = self.body_expr_results.length()
      let block_start = self.body_block_results.length()
      self.push_body_task(
        body_finish_expr, source_index, expr_start, block_start,
      )
      match alternative {
        Some(value) => self.schedule_expr(value)
        None => ()
      }
      self.schedule_block(block)
      self.schedule_expr(condition)
    }
    @parser.IsExpr(_, _, _) => {
      self.body_expr_sources[source_index] = source.desugar_is()
      self.push_body_task(body_visit_expr, source_index, 0, 0)
    }
    @parser.MatchExpr(scrutinee, arms, _)
    | @parser.WhileExpr(scrutinee, arms, _) => {
      let expr_start = self.body_expr_results.length()
      let arm_start = self.body_arm_results.length()
      self.push_body_task(body_finish_expr, source_index, expr_start, arm_start)
      let mut index = arms.length()
      while index > 0 {
        index -= 1
        self.schedule_arm(arms[index])
      }
      self.schedule_expr(scrutinee)
    }
    @parser.ReturnExpr(Some(value), _)
    | @parser.BreakExpr(value, _)
    | @parser.ContinueExpr(value, _)
    | @parser.PrefixExpr(_, value, _)
    | @parser.FieldExpr(value, _, _)
    | @parser.QualifiedExpr(value, _, _)
    | @parser.ProductFieldExpr(value, _, _, _) => {
      let start = self.body_expr_results.length()
      self.push_body_task(body_finish_expr, source_index, start, 0)
      self.schedule_expr(value)
    }
    @parser.ReturnExpr(None, offset) =>
      ignore(self.emit_expr(HirReturnExpr(-1, offset)))
    @parser.BinaryExpr(_, left, right, _) | @parser.IndexExpr(left, right, _) => {
      let start = self.body_expr_results.length()
      self.push_body_task(body_finish_expr, source_index, start, 0)
      self.schedule_expr(right)
      self.schedule_expr(left)
    }
    @parser.CallExpr(target, arguments, _)
    | @parser.ExplicitTypeCallExpr(target, _, arguments, _) => {
      let start = self.body_expr_results.length()
      self.push_body_task(body_finish_expr, source_index, start, 0)
      let mut index = arguments.length()
      while index > 0 {
        index -= 1
        self.schedule_expr(arguments[index])
      }
      self.schedule_expr(target)
    }
  }
}

///|
fn CollectionBuilder::append_object_fields(
  self : CollectionBuilder,
  source : Array[@parser.ObjectField],
  result_start : Int,
) -> HirSpan {
  let start = self.object_fields.length()
  for index, field in source {
    self.object_fields.push({
      name: self.intern(field.name),
      value: self.body_expr_results[result_start + index],
      offset: field.offset,
    })
    self.object_field_files.push(self.current_file)
  }
  { start, length: source.length(), }
}

///|
fn CollectionBuilder::finish_expr_source(
  self : CollectionBuilder,
  source_index : Int,
  first_start : Int,
  second_start : Int,
) -> Unit {
  let source = self.body_expr_sources[source_index]
  let expression = match source {
    @parser.ProductExpr(elements, offset)
    | @parser.ArrayExpr(elements, offset) => {
      let start = self.expression_children.length()
      for index in 0..<elements.length() {
        self.expression_children.push(
          self.body_expr_results[first_start + index],
        )
      }
      let span = { start, length: elements.length(), }
      match source {
        @parser.ProductExpr(_, _) => HirProductExpr(span, offset)
        @parser.ArrayExpr(_, _) => HirArrayExpr(span, offset)
        _ => abort("collection expression changed shape")
      }
    }
    @parser.ObjectExpr(fields, offset) =>
      HirObjectExpr(self.append_object_fields(fields, first_start), offset)
    @parser.ConstructExpr(_, fields, offset) => {
      let target = self.body_expr_results[first_start]
      let field_span = self.append_object_fields(fields, first_start + 1)
      HirConstructExpr(target, field_span, offset)
    }
    @parser.BlockExpr(block_source) => {
      let block = self.body_block_results[second_start]
      self.body_block_results.truncate(second_start)
      HirBlockExpr(block, block_source.offset)
    }
    @parser.IfExpr(_, _, alternative, offset) => {
      let condition = self.body_expr_results[first_start]
      let block = self.body_block_results[second_start]
      let alternative = if alternative is Some(_) {
        self.body_expr_results[first_start + 1]
      } else {
        -1
      }
      self.body_block_results.truncate(second_start)
      HirIfExpr(condition, block, alternative, offset)
    }
    @parser.MatchExpr(_, arms, offset) => {
      let arm_start = self.arm_children.length()
      for index in 0..<arms.length() {
        self.arm_children.push(self.body_arm_results[second_start + index])
      }
      self.body_arm_results.truncate(second_start)
      HirMatchExpr(
        self.body_expr_results[first_start],
        { start: arm_start, length: arms.length(), },
        offset,
      )
    }
    @parser.WhileExpr(_, arms, offset) => {
      let arm_start = self.arm_children.length()
      for index in 0..<arms.length() {
        self.arm_children.push(self.body_arm_results[second_start + index])
      }
      self.body_arm_results.truncate(second_start)
      HirWhileExpr(
        self.body_expr_results[first_start],
        { start: arm_start, length: arms.length(), },
        offset,
      )
    }
    @parser.ReturnExpr(value, offset) =>
      HirReturnExpr(
        if value is Some(_) {
          self.body_expr_results[first_start]
        } else {
          -1
        },
        offset,
      )
    @parser.BreakExpr(_, offset) =>
      HirBreakExpr(self.body_expr_results[first_start], offset)
    @parser.ContinueExpr(_, offset) =>
      HirContinueExpr(self.body_expr_results[first_start], offset)
    @parser.PrefixExpr(operator, _, offset) =>
      HirPrefixExpr(
        hir_prefix_operator(operator),
        self.body_expr_results[first_start],
        offset,
      )
    @parser.BinaryExpr(operator, _, _, offset) =>
      HirBinaryExpr(
        hir_binary_operator(operator),
        self.body_expr_results[first_start],
        self.body_expr_results[first_start + 1],
        offset,
      )
    @parser.CallExpr(_, arguments, offset)
    | @parser.ExplicitTypeCallExpr(_, _, arguments, offset) => {
      let target = self.body_expr_results[first_start]
      let argument_start = self.expression_children.length()
      for index in 0..<arguments.length() {
        self.expression_children.push(
          self.body_expr_results[first_start + index + 1],
        )
      }
      HirCallExpr(
        target,
        { start: argument_start, length: arguments.length(), },
        offset,
      )
    }
    @parser.FieldExpr(_, name, offset) =>
      HirFieldExpr(
        self.body_expr_results[first_start],
        self.intern(name),
        offset,
      )
    @parser.QualifiedExpr(_, name, offset) =>
      HirQualifiedExpr(
        self.body_expr_results[first_start],
        self.intern(name),
        offset,
      )
    @parser.ProductFieldExpr(_, index, arity, offset) =>
      HirProductFieldExpr(
        self.body_expr_results[first_start],
        index,
        arity,
        offset,
      )
    @parser.IndexExpr(_, _, offset) =>
      HirIndexExpr(
        self.body_expr_results[first_start],
        self.body_expr_results[first_start + 1],
        offset,
      )
    _ => abort("invalid expression finish task")
  }
  self.body_expr_results.truncate(first_start)
  let expression_id = self.emit_expr(expression)
  match source {
    @parser.ExplicitTypeCallExpr(_, type_arguments, _, _) => {
      let start = self.explicit_call_type_arguments.length()
      for type_ in type_arguments {
        self.explicit_call_type_arguments.push(self.lower_type(type_))
      }
      self.explicit_call_type_argument_spans[expression_id] = {
        start,
        length: self.explicit_call_type_arguments.length() - start,
      }
    }
    _ => ()
  }
}

///|
fn CollectionBuilder::visit_block_source(
  self : CollectionBuilder,
  source_index : Int,
) -> Unit {
  let source = self.body_block_sources[source_index]
  let expr_start = self.body_expr_results.length()
  self.push_body_task(body_finish_block, source_index, expr_start, 0)
  let mut index = source.items.length()
  while index > 0 {
    index -= 1
    match source.items[index] {
      @parser.LetItem(_, _, _, value, _) => self.schedule_expr(value)
      @parser.AssignmentItem(target, value, _) => {
        self.schedule_expr(value)
        self.schedule_expr(target)
      }
      @parser.IndexSetItem(target, value, _) =>
        match target {
          @parser.IndexExpr(base, index, _) => {
            self.schedule_expr(value)
            self.schedule_expr(index)
            self.schedule_expr(base)
          }
          _ => abort("parser index-set item has a non-index target")
        }
      @parser.ExpressionItem(value, _) => self.schedule_expr(value)
    }
  }
}

///|
fn CollectionBuilder::finish_block_source(
  self : CollectionBuilder,
  source_index : Int,
  expr_start : Int,
) -> Unit {
  let source = self.body_block_sources[source_index]
  let item_start = self.block_items.length()
  let mut result_index = expr_start
  for item in source.items {
    match item {
      @parser.LetItem(mutable_, name, name_offset, _, offset) => {
        self.block_items.push(
          HirLetItem(
            mutable_,
            self.intern(name),
            name_offset,
            self.body_expr_results[result_index],
            offset,
          ),
        )
        result_index += 1
      }
      @parser.AssignmentItem(_, _, offset) => {
        let expression = self.append_expr(
          HirAssignmentExpr(
            self.body_expr_results[result_index],
            self.body_expr_results[result_index + 1],
            offset,
          ),
        )
        self.block_items.push(HirExpressionItem(expression, offset))
        result_index += 2
      }
      @parser.IndexSetItem(_, _, offset) => {
        let expression = self.append_expr(
          HirIndexSetExpr(
            self.body_expr_results[result_index],
            self.body_expr_results[result_index + 1],
            self.body_expr_results[result_index + 2],
            offset,
          ),
        )
        self.block_items.push(HirExpressionItem(expression, offset))
        result_index += 3
      }
      @parser.ExpressionItem(_, offset) => {
        self.block_items.push(
          HirExpressionItem(self.body_expr_results[result_index], offset),
        )
        result_index += 1
      }
    }
    self.block_item_files.push(self.current_file)
  }
  self.body_expr_results.truncate(expr_start)
  let id = self.blocks.length()
  self.blocks.push({
    items: { start: item_start, length: source.items.length(), },
    offset: source.offset,
  })
  self.block_files.push(self.current_file)
  self.body_block_results.push(id)
}

///|
fn CollectionBuilder::visit_pattern_source(
  self : CollectionBuilder,
  source_index : Int,
) -> Unit {
  let source = self.body_pattern_sources[source_index]
  match source {
    @parser.WildcardPattern(offset) =>
      ignore(self.emit_pattern(HirWildcardPattern(offset)))
    @parser.BindingPattern(name, offset) =>
      ignore(self.emit_pattern(HirBindingPattern(self.intern(name), offset)))
    @parser.ImportAliasPattern(name, offset) =>
      ignore(
        self.emit_pattern(HirImportAliasPattern(self.intern(name), offset)),
      )
    @parser.RestPattern(offset) =>
      ignore(self.emit_pattern(HirRestPattern(offset)))
    @parser.LiteralPattern(expression, _) => {
      let expr_start = self.body_expr_results.length()
      self.push_body_task(body_finish_pattern, source_index, expr_start, 0)
      self.schedule_expr(expression)
    }
    @parser.QualifiedPattern(base, _, _) => {
      let pattern_start = self.body_pattern_results.length()
      self.push_body_task(body_finish_pattern, source_index, pattern_start, 0)
      self.schedule_pattern(base)
    }
    @parser.TuplePattern(base, arguments, _) => {
      let pattern_start = self.body_pattern_results.length()
      self.push_body_task(body_finish_pattern, source_index, pattern_start, 0)
      let mut index = arguments.length()
      while index > 0 {
        index -= 1
        self.schedule_pattern(arguments[index])
      }
      self.schedule_pattern(base)
    }
    @parser.StructPattern(base, fields, _, _) => {
      let pattern_start = self.body_pattern_results.length()
      self.push_body_task(body_finish_pattern, source_index, pattern_start, 0)
      let mut index = fields.length()
      while index > 0 {
        index -= 1
        self.schedule_pattern(fields[index].pattern)
      }
      self.schedule_pattern(base)
    }
    @parser.AlternativePattern(first, remaining, _) => {
      let pattern_start = self.body_pattern_results.length()
      self.push_body_task(body_finish_pattern, source_index, pattern_start, 0)
      let mut index = remaining.length()
      while index > 0 {
        index -= 1
        self.schedule_pattern(remaining[index])
      }
      self.schedule_pattern(first)
    }
  }
}

///|
fn CollectionBuilder::finish_pattern_source(
  self : CollectionBuilder,
  source_index : Int,
  first_start : Int,
) -> Unit {
  let source = self.body_pattern_sources[source_index]
  let pattern = match source {
    @parser.LiteralPattern(_, offset) =>
      HirLiteralPattern(self.body_expr_results[first_start], offset)
    @parser.QualifiedPattern(_, name, offset) =>
      HirQualifiedPattern(
        self.body_pattern_results[first_start],
        self.intern(name),
        offset,
      )
    @parser.TuplePattern(_, arguments, offset) => {
      let argument_start = self.pattern_children.length()
      for index in 0..<arguments.length() {
        self.pattern_children.push(
          self.body_pattern_results[first_start + index + 1],
        )
      }
      HirTuplePattern(
        self.body_pattern_results[first_start],
        { start: argument_start, length: arguments.length(), },
        offset,
      )
    }
    @parser.StructPattern(_, fields, rest_offset, offset) => {
      let field_start = self.pattern_fields.length()
      for index, field in fields {
        self.pattern_fields.push({
          name: self.intern(field.name),
          pattern: self.body_pattern_results[first_start + index + 1],
          offset: field.offset,
        })
        self.pattern_field_files.push(self.current_file)
      }
      let (has_rest, rest_offset) = match rest_offset {
        Some(value) => (true, value)
        None => (false, 0UL)
      }
      HirStructPattern(
        self.body_pattern_results[first_start],
        { start: field_start, length: fields.length(), },
        has_rest,
        rest_offset,
        offset,
      )
    }
    @parser.AlternativePattern(_, remaining, offset) => {
      let alternative_start = self.pattern_children.length()
      for index in 0..<remaining.length() {
        self.pattern_children.push(
          self.body_pattern_results[first_start + index + 1],
        )
      }
      HirAlternativePattern(
        self.body_pattern_results[first_start],
        { start: alternative_start, length: remaining.length(), },
        offset,
      )
    }
    _ => abort("invalid pattern finish task")
  }
  match source {
    @parser.LiteralPattern(_, _) => self.body_expr_results.truncate(first_start)
    _ => self.body_pattern_results.truncate(first_start)
  }
  ignore(self.emit_pattern(pattern))
}

///|
fn CollectionBuilder::visit_arm_source(
  self : CollectionBuilder,
  source_index : Int,
) -> Unit {
  let source = self.body_arm_sources[source_index]
  let pattern_start = self.body_pattern_results.length()
  let expr_start = self.body_expr_results.length()
  self.push_body_task(body_finish_arm, source_index, pattern_start, expr_start)
  self.schedule_expr(source.body)
  match source.guard_condition {
    Some(value) => self.schedule_expr(value)
    None => ()
  }
  self.schedule_pattern(source.pattern)
}

///|
fn CollectionBuilder::finish_arm_source(
  self : CollectionBuilder,
  source_index : Int,
  pattern_start : Int,
  expr_start : Int,
) -> Unit {
  let source = self.body_arm_sources[source_index]
  let guard_condition = if source.guard_condition is Some(_) {
    self.body_expr_results[expr_start]
  } else {
    -1
  }
  let body = if guard_condition >= 0 {
    self.body_expr_results[expr_start + 1]
  } else {
    self.body_expr_results[expr_start]
  }
  let id = self.pattern_arms.length()
  self.pattern_arms.push({
    pattern: self.body_pattern_results[pattern_start],
    guard_condition,
    body,
    offset: source.offset,
  })
  self.pattern_arm_files.push(self.current_file)
  self.body_pattern_results.truncate(pattern_start)
  self.body_expr_results.truncate(expr_start)
  self.body_arm_results.push(id)
}

///|
fn CollectionBuilder::run_body_tasks(self : CollectionBuilder) -> Unit {
  while self.body_task_kinds.length() > 0 {
    let kind = self.body_task_kinds.pop().unwrap()
    let source = self.body_task_sources.pop().unwrap()
    let first_start = self.body_task_first_starts.pop().unwrap()
    let second_start = self.body_task_second_starts.pop().unwrap()
    match kind {
      0 => self.visit_expr_source(source)
      1 => self.finish_expr_source(source, first_start, second_start)
      2 => self.visit_block_source(source)
      3 => self.finish_block_source(source, first_start)
      4 => self.visit_pattern_source(source)
      5 => self.finish_pattern_source(source, first_start)
      6 => self.visit_arm_source(source)
      7 => self.finish_arm_source(source, first_start, second_start)
      _ => abort("invalid body lowering task")
    }
  }
}

///|
fn CollectionBuilder::reset_body_scratch(self : CollectionBuilder) -> Unit {
  self.body_task_kinds.clear()
  self.body_task_sources.clear()
  self.body_task_first_starts.clear()
  self.body_task_second_starts.clear()
  self.body_expr_sources.clear()
  self.body_block_sources.clear()
  self.body_pattern_sources.clear()
  self.body_arm_sources.clear()
  self.body_expr_results.clear()
  self.body_block_results.clear()
  self.body_pattern_results.clear()
  self.body_arm_results.clear()
}

///|
fn CollectionBuilder::append_body(
  self : CollectionBuilder,
  declaration : DeclId,
  kind : HirBodyKind,
  root : HirBodyRoot,
  expression_start : Int,
  expression_child_start : Int,
  block_start : Int,
  block_item_start : Int,
  pattern_start : Int,
  pattern_child_start : Int,
  arm_start : Int,
  arm_child_start : Int,
  object_field_start : Int,
  pattern_field_start : Int,
  offset : UInt64,
) -> Unit {
  let body_index = self.bodies.length()
  self.body_files.push(self.current_file)
  self.bodies.push({
    id: make_semantic_id(self.module_id, body_index),
    declaration,
    kind,
    root,
    expressions: {
      start: expression_start,
      length: self.expressions.length() - expression_start,
    },
    expression_children: {
      start: expression_child_start,
      length: self.expression_children.length() - expression_child_start,
    },
    blocks: { start: block_start, length: self.blocks.length() - block_start, },
    block_items: {
      start: block_item_start,
      length: self.block_items.length() - block_item_start,
    },
    patterns: {
      start: pattern_start,
      length: self.patterns.length() - pattern_start,
    },
    pattern_children: {
      start: pattern_child_start,
      length: self.pattern_children.length() - pattern_child_start,
    },
    pattern_arms: {
      start: arm_start,
      length: self.pattern_arms.length() - arm_start,
    },
    arm_children: {
      start: arm_child_start,
      length: self.arm_children.length() - arm_child_start,
    },
    object_fields: {
      start: object_field_start,
      length: self.object_fields.length() - object_field_start,
    },
    pattern_fields: {
      start: pattern_field_start,
      length: self.pattern_fields.length() - pattern_field_start,
    },
    offset,
  })
  self.body_by_declaration[semantic_id_local(declaration)] = body_index
}

///|
fn CollectionBuilder::lower_pending_lambda_bodies(
  self : CollectionBuilder,
) -> Unit {
  while self.lambdas.length() < self.lambda_sources.length() {
    let lambda = self.lambdas.length()
    self.reset_body_scratch()
    let expression_start = self.expressions.length()
    let expression_child_start = self.expression_children.length()
    let block_start = self.blocks.length()
    let block_item_start = self.block_items.length()
    let pattern_start = self.patterns.length()
    let pattern_child_start = self.pattern_children.length()
    let arm_start = self.pattern_arms.length()
    let arm_child_start = self.arm_children.length()
    let object_field_start = self.object_fields.length()
    let pattern_field_start = self.pattern_fields.length()
    self.current_lambda = lambda
    self.current_root_body = self.lambda_root_bodies[lambda]
    self.schedule_block(self.lambda_sources[lambda])
    self.run_body_tasks()
    guard self.body_block_results.length() == 1 else {
      abort("invalid lambda block lowering result")
    }
    self.lambdas.push({
      id: lambda,
      parent: self.lambda_parents[lambda],
      root_body: self.lambda_root_bodies[lambda],
      parameters: self.lambda_parameter_spans[lambda],
      return_type: self.lambda_return_types[lambda],
      body: {
        root: self.body_block_results[0],
        expressions: {
          start: expression_start,
          length: self.expressions.length() - expression_start,
        },
        expression_children: {
          start: expression_child_start,
          length: self.expression_children.length() - expression_child_start,
        },
        blocks: {
          start: block_start,
          length: self.blocks.length() - block_start,
        },
        block_items: {
          start: block_item_start,
          length: self.block_items.length() - block_item_start,
        },
        patterns: {
          start: pattern_start,
          length: self.patterns.length() - pattern_start,
        },
        pattern_children: {
          start: pattern_child_start,
          length: self.pattern_children.length() - pattern_child_start,
        },
        pattern_arms: {
          start: arm_start,
          length: self.pattern_arms.length() - arm_start,
        },
        arm_children: {
          start: arm_child_start,
          length: self.arm_children.length() - arm_child_start,
        },
        object_fields: {
          start: object_field_start,
          length: self.object_fields.length() - object_field_start,
        },
        pattern_fields: {
          start: pattern_field_start,
          length: self.pattern_fields.length() - pattern_field_start,
        },
      },
      file: self.lambda_files[lambda],
      offset: self.lambda_offsets[lambda],
    })
    self.reset_body_scratch()
    self.current_lambda = -1
    self.current_root_body = 0UL
  }
}

///|
fn CollectionBuilder::lower_expression_body(
  self : CollectionBuilder,
  declaration : DeclId,
  kind : HirBodyKind,
  source : @parser.Expr,
  offset : UInt64,
) -> Unit {
  self.reset_body_scratch()
  self.current_lambda = -1
  self.current_root_body = make_semantic_id(
    self.module_id,
    self.bodies.length(),
  )
  let expression_start = self.expressions.length()
  let expression_child_start = self.expression_children.length()
  let block_start = self.blocks.length()
  let block_item_start = self.block_items.length()
  let pattern_start = self.patterns.length()
  let pattern_child_start = self.pattern_children.length()
  let arm_start = self.pattern_arms.length()
  let arm_child_start = self.arm_children.length()
  let object_field_start = self.object_fields.length()
  let pattern_field_start = self.pattern_fields.length()
  self.schedule_expr(source)
  self.run_body_tasks()
  guard self.body_expr_results.length() == 1 else {
    abort("invalid expression body lowering result")
  }
  self.append_body(
    declaration,
    kind,
    ExpressionBodyRoot(self.body_expr_results[0]),
    expression_start,
    expression_child_start,
    block_start,
    block_item_start,
    pattern_start,
    pattern_child_start,
    arm_start,
    arm_child_start,
    object_field_start,
    pattern_field_start,
    offset,
  )
  self.reset_body_scratch()
  self.lower_pending_lambda_bodies()
}

///|
fn CollectionBuilder::lower_block_body(
  self : CollectionBuilder,
  declaration : DeclId,
  kind : HirBodyKind,
  source : @parser.Block,
  offset : UInt64,
) -> Unit {
  self.reset_body_scratch()
  self.current_lambda = -1
  self.current_root_body = make_semantic_id(
    self.module_id,
    self.bodies.length(),
  )
  let expression_start = self.expressions.length()
  let expression_child_start = self.expression_children.length()
  let block_start = self.blocks.length()
  let block_item_start = self.block_items.length()
  let pattern_start = self.patterns.length()
  let pattern_child_start = self.pattern_children.length()
  let arm_start = self.pattern_arms.length()
  let arm_child_start = self.arm_children.length()
  let object_field_start = self.object_fields.length()
  let pattern_field_start = self.pattern_fields.length()
  self.schedule_block(source)
  self.run_body_tasks()
  guard self.body_block_results.length() == 1 else {
    abort("invalid block body lowering result")
  }
  self.append_body(
    declaration,
    kind,
    BlockBodyRoot(self.body_block_results[0]),
    expression_start,
    expression_child_start,
    block_start,
    block_item_start,
    pattern_start,
    pattern_child_start,
    arm_start,
    arm_child_start,
    object_field_start,
    pattern_field_start,
    offset,
  )
  self.reset_body_scratch()
  self.lower_pending_lambda_bodies()
}
