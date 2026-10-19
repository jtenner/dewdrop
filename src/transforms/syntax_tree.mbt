///|
fn Machine::syntax_node(
  self : Machine,
  kind : String,
  label : String,
  offset : UInt64,
  children : Array[Value],
  types : Array[Value],
  depth : Int32,
) -> Value raise EvalError {
  guard depth < 128 else { raise Failed("syntax tree depth limit exceeded") }
  self.charge(64 + bytes(label).length())
  record("dewdrop.ast::SyntaxNode", [
    ("kind", Text(kind)),
    ("label", Text(label)),
    ("offset", Number(offset, "U32")),
    ("children", self.syntax_values(children)),
    ("types", self.syntax_values(types)),
  ])
}

///|
fn Machine::syntax_block(
  self : Machine,
  block : @parser.Block,
  depth : Int32,
) -> Value raise EvalError {
  guard depth < 128 else { raise Failed("syntax tree depth limit exceeded") }
  let children : Array[Value] = []
  for item in block.items {
    let node = match item {
      @parser.ExpressionItem(value, _) => self.syntax_expr(value, depth + 1)
      @parser.LetItem(mutable_, name, _, value, offset) =>
        self.syntax_node(
          if mutable_ {
            "mutable_bind"
          } else {
            "bind"
          },
          name,
          offset,
          [self.syntax_expr(value, depth + 1)],
          [],
          depth + 1,
        )
      @parser.AssignmentItem(target, value, offset) =>
        self.syntax_node(
          "assign",
          "",
          offset,
          [
            self.syntax_expr(target, depth + 1),
            self.syntax_expr(value, depth + 1),
          ],
          [],
          depth + 1,
        )
      @parser.IndexSetItem(target, value, offset) =>
        self.syntax_node(
          "index_set",
          "",
          offset,
          [
            self.syntax_expr(target, depth + 1),
            self.syntax_expr(value, depth + 1),
          ],
          [],
          depth + 1,
        )
      @parser.TypeBindingItem(name, type_, offset) =>
        self.syntax_node(
          "type_bind",
          name,
          offset,
          [],
          [self.type_node(type_)],
          depth + 1,
        )
    }
    children.push(node)
  }
  self.syntax_node("block", "", block.offset, children, [], depth)
}

///|
fn Machine::syntax_expr(
  self : Machine,
  value : @parser.Expr,
  depth : Int32,
) -> Value raise EvalError {
  guard depth < 128 else { raise Failed("syntax tree depth limit exceeded") }
  let children : Array[Value] = []
  let types : Array[Value] = []
  let mut kind = ""
  let mut label = ""
  match value {
    @parser.I8Expr(bits, _) => {
      kind = "I8"
      label = bits.to_string()
    }
    @parser.I16Expr(bits, _) => {
      kind = "I16"
      label = bits.to_string()
    }
    @parser.I32Expr(bits, _) => {
      kind = "I32"
      label = bits.to_string()
    }
    @parser.I64Expr(bits, _) => {
      kind = "I64"
      label = bits.to_string()
    }
    @parser.U8Expr(bits, _) => {
      kind = "U8"
      label = bits.to_string()
    }
    @parser.U16Expr(bits, _) => {
      kind = "U16"
      label = bits.to_string()
    }
    @parser.U32Expr(bits, _) => {
      kind = "U32"
      label = bits.to_string()
    }
    @parser.U64Expr(bits, _) => {
      kind = "U64"
      label = bits.to_string()
    }
    @parser.F32Expr(bits, _) => {
      kind = "F32"
      label = bits.reinterpret_as_uint().to_string()
    }
    @parser.F64Expr(bits, _) => {
      kind = "F64"
      label = bits.reinterpret_as_uint64().to_string()
    }
    @parser.BoolExpr(flag, _) => {
      kind = "Bool"
      label = if flag { "true" } else { "false" }
    }
    @parser.StringExpr(raw, _) => {
      kind = "String"
      label = text(raw)
    }
    @parser.BytesExpr(raw, _) => {
      kind = "Bytes"
      for b in raw {
        children.push(
          self.syntax_node(
            "U8",
            b.to_int().to_string(),
            value.offset(),
            [],
            [],
            depth + 1,
          ),
        )
      }
    }
    @parser.NameExpr(name, _) => {
      kind = "name"
      label = name
    }
    @parser.ImportAliasExpr(name, _) => {
      kind = "import"
      label = name
    }
    @parser.ProductExpr(values, _) => {
      kind = "tuple"
      for item in values {
        children.push(self.syntax_expr(item, depth + 1))
      }
    }
    @parser.ArrayExpr(values, _) => {
      kind = "array"
      for item in values {
        children.push(self.syntax_expr(item, depth + 1))
      }
    }
    @parser.BlockExpr(block) => {
      kind = "block"
      return self.syntax_block(block, depth)
    }
    @parser.BreakExpr(item, _) => {
      kind = "break"
      children.push(self.syntax_expr(item, depth + 1))
    }
    @parser.ContinueExpr(item, _) => {
      kind = "continue"
      children.push(self.syntax_expr(item, depth + 1))
    }
    @parser.ReturnExpr(item, _) => {
      kind = "return"
      if item is Some(item) {
        children.push(self.syntax_expr(item, depth + 1))
      }
    }
    @parser.FieldExpr(item, name, _) => {
      kind = "field"
      label = name
      children.push(self.syntax_expr(item, depth + 1))
    }
    @parser.QualifiedExpr(item, name, _) => {
      kind = "qualified"
      label = name
      children.push(self.syntax_expr(item, depth + 1))
    }
    @parser.ProductFieldExpr(item, index, arity, _) => {
      kind = "tuple_field"
      label = index.to_string() + "/" + arity.to_string()
      children.push(self.syntax_expr(item, depth + 1))
    }
    @parser.IndexExpr(owner, index, _) => {
      kind = "index"
      children.push(self.syntax_expr(owner, depth + 1))
      children.push(self.syntax_expr(index, depth + 1))
    }
    @parser.PrefixExpr(op, item, _) => {
      kind = "prefix"
      label = match op {
        @parser.Positive => "+"
        @parser.Negative => "-"
        @parser.LogicalNot => "!"
      }
      children.push(self.syntax_expr(item, depth + 1))
    }
    @parser.BinaryExpr(op, left, right, _) => {
      kind = "binary"
      label = match op {
        @parser.LogicalOr => "||"
        @parser.LogicalAnd => "&&"
        @parser.BitOr => "|"
        @parser.BitXor => "^"
        @parser.BitAnd => "&"
        @parser.Equal => "=="
        @parser.NotEqual => "!="
        @parser.Less => "<"
        @parser.LessEqual => "<="
        @parser.Greater => ">"
        @parser.GreaterEqual => ">="
        @parser.ShiftLeft => "<<"
        @parser.ShiftRight => ">>"
        @parser.Add => "+"
        @parser.Subtract => "-"
        @parser.Multiply => "*"
        @parser.Divide => "/"
        @parser.Remainder => "%"
        @parser.Exponentiate => "**"
      }
      children.push(self.syntax_expr(left, depth + 1))
      children.push(self.syntax_expr(right, depth + 1))
    }
    @parser.CallExpr(callee, values, _) => {
      kind = "call"
      children.push(self.syntax_expr(callee, depth + 1))
      for item in values {
        children.push(self.syntax_expr(item, depth + 1))
      }
    }
    @parser.ExplicitTypeCallExpr(callee, arguments, values, _) => {
      kind = "type_call"
      children.push(self.syntax_expr(callee, depth + 1))
      for item in values {
        children.push(self.syntax_expr(item, depth + 1))
      }
      for type_ in arguments {
        types.push(self.type_node(type_))
      }
    }
    @parser.IfExpr(condition, then_, else_, _) => {
      kind = "if"
      children.push(self.syntax_expr(condition, depth + 1))
      children.push(self.syntax_block(then_, depth + 1))
      if else_ is Some(item) {
        children.push(self.syntax_expr(item, depth + 1))
      }
    }
    @parser.ObjectExpr(fields, _) => {
      kind = "record"
      for field in fields {
        children.push(
          self.syntax_node(
            "property",
            field.name,
            field.offset,
            [self.syntax_expr(field.value, depth + 1)],
            [],
            depth + 1,
          ),
        )
      }
    }
    @parser.ConstructExpr(callee, fields, _) => {
      kind = "construct"
      children.push(self.syntax_expr(callee, depth + 1))
      for field in fields {
        children.push(
          self.syntax_node(
            "property",
            field.name,
            field.offset,
            [self.syntax_expr(field.value, depth + 1)],
            [],
            depth + 1,
          ),
        )
      }
    }
    @parser.LambdaExpr(parameters, result, block, _) => {
      kind = "lambda"
      for parameter in parameters {
        children.push(
          self.syntax_node(
            "parameter",
            parameter.name,
            parameter.offset,
            [],
            [self.type_node(parameter.type_)],
            depth + 1,
          ),
        )
      }
      types.push(self.type_node(result))
      children.push(self.syntax_block(block, depth + 1))
    }
    @parser.MatchExpr(value, arms, _) => {
      kind = "match"
      children.push(self.syntax_expr(value, depth + 1))
      for arm in arms {
        let nodes = [self.syntax_pattern(arm.pattern, depth + 1)]
        if arm.guard_condition is Some(guard_) {
          nodes.push(self.syntax_expr(guard_, depth + 1))
        }
        nodes.push(self.syntax_expr(arm.body, depth + 1))
        children.push(
          self.syntax_node("arm", "", arm.offset, nodes, [], depth + 1),
        )
      }
    }
    @parser.WhileExpr(value, arms, _) => {
      kind = "while"
      children.push(self.syntax_expr(value, depth + 1))
      for arm in arms {
        let nodes = [self.syntax_pattern(arm.pattern, depth + 1)]
        if arm.guard_condition is Some(guard_) {
          nodes.push(self.syntax_expr(guard_, depth + 1))
        }
        nodes.push(self.syntax_expr(arm.body, depth + 1))
        children.push(
          self.syntax_node("arm", "", arm.offset, nodes, [], depth + 1),
        )
      }
    }
    @parser.IsExpr(value, pattern, _) => {
      kind = "is"
      children.push(self.syntax_expr(value, depth + 1))
      children.push(self.syntax_pattern(pattern, depth + 1))
    }
  }
  self.syntax_node(kind, label, value.offset(), children, types, depth)
}

///|
fn Machine::syntax_pattern(
  self : Machine,
  value : @parser.Pattern,
  depth : Int32,
) -> Value raise EvalError {
  guard depth < 128 else { raise Failed("syntax tree depth limit exceeded") }
  let children : Array[Value] = []
  let mut kind = ""
  let mut label = ""
  match value {
    @parser.WildcardPattern(_) => kind = "pattern_wildcard"
    @parser.RestPattern(_) => kind = "pattern_rest"
    @parser.BindingPattern(name, _) => {
      kind = "pattern_bind"
      label = name
    }
    @parser.ImportAliasPattern(name, _) => {
      kind = "pattern_import"
      label = name
    }
    @parser.LiteralPattern(item, _) => {
      kind = "pattern_literal"
      children.push(self.syntax_expr(item, depth + 1))
    }
    @parser.QualifiedPattern(base, name, _) => {
      kind = "pattern_qualified"
      label = name
      children.push(self.syntax_pattern(base, depth + 1))
    }
    @parser.TuplePattern(base, items, _) => {
      kind = "pattern_variant"
      children.push(self.syntax_pattern(base, depth + 1))
      for item in items {
        children.push(self.syntax_pattern(item, depth + 1))
      }
    }
    @parser.AlternativePattern(base, items, _) => {
      kind = "pattern_alternative"
      children.push(self.syntax_pattern(base, depth + 1))
      for item in items {
        children.push(self.syntax_pattern(item, depth + 1))
      }
    }
    @parser.ProductPattern(items, _) => {
      kind = "pattern_tuple"
      for item in items {
        children.push(self.syntax_pattern(item, depth + 1))
      }
    }
    @parser.StructPattern(base, fields, rest, _) => {
      kind = "pattern_record"
      children.push(self.syntax_pattern(base, depth + 1))
      for field in fields {
        children.push(
          self.syntax_node(
            "pattern_property",
            field.name,
            field.offset,
            [self.syntax_pattern(field.pattern, depth + 1)],
            [],
            depth + 1,
          ),
        )
      }
      if rest is Some(offset) {
        children.push(
          self.syntax_node("pattern_rest", "", offset, [], [], depth + 1),
        )
      }
    }
  }
  self.syntax_node(kind, label, value.offset(), children, [], depth)
}
