///|
enum Value {
  Unit
  NullValue
  DefaultValue
  RawArray(RawStorage)
  Vector(UInt64, UInt64)
  TextChunks(Value, Bytes)
  TextReference(Value)
  ReferenceView(Value, Array[String])
  Floating(UInt64, String)
  Number(UInt64, String)
  Boolean(Bool)
  Text(String)
  ByteText(Bytes)
  Sequence(Array[Value])
  Record(String, Map[String, Value])
  Variant(String, Array[Value])
  Function(CallTarget, Array[Value], FunctionIdentity)
  Closure(
    Int32,
    Int32,
    Array[@parser.FnParameter],
    @parser.Block,
    Map[String, Cell],
    String
  )
}

///|
suberror EvalError {
  Failed(String)
  Returned(Value)
  Broken(Value)
  Continued(Value)
}

///|
struct Cell {
  mut value : Value
  mutable_ : Bool
}

///|
struct Machine {
  plan : Plan
  mut steps : Int32
  mut depth : Int32
  mut allocated : Int32
  functions : Map[String, CallTarget]
  imports : Map[(Int32, String), String]
  globals : Map[String, Value]
  initializing : Map[String, Bool]
  mut file_index : Int32
  mut frame : String
  text_storage : Map[String, Bytes]
  bytecode_enabled : Bool
  bytecode : Map[String, Map[(Int32, Int32, Int32), BytecodeFunction?]]
  mut bytecode_compile_work : Int32
  mut bytecode_bytes_left : Int32
}

///|
fn Machine::charge(self : Machine, amount : Int32) -> Unit raise EvalError {
  self.steps -= 1
  self.allocated += amount
  guard self.steps >= 0 else { raise Failed("transform work limit exceeded") }
  guard self.allocated <= 4_194_304 else {
    raise Failed("transform allocation limit exceeded")
  }
}

///|
fn eval_fail(message : String) -> Value raise EvalError {
  raise Failed(message)
}

///|
fn truth(value : Value) -> Bool raise EvalError {
  match value {
    Boolean(value) => value
    DefaultValue => false
    _ => raise Failed("expected Bool in transform")
  }
}

///|
fn string(value : Value) -> String raise EvalError {
  match value {
    Text(value) => value
    _ => raise Failed("expected String in transform")
  }
}

///|
fn fields(value : Value) -> Map[String, Value] raise EvalError {
  match value {
    Record(_, values) => values
    _ => raise Failed("expected record in transform")
  }
}

///|
fn field(value : Value, name : String) -> Value raise EvalError {
  match fields(value).get(name) {
    Some(value) => value
    None => eval_fail("unknown transform field: " + name)
  }
}

///|
fn Machine::module_index(
  self : Machine,
  path : String,
) -> Int32 raise EvalError {
  for i, module_ in self.plan.modules {
    self.charge(16)
    if module_.path == path {
      return i
    }
  }
  raise Failed("compile-time module source is unavailable: " + path)
}

///|
fn Machine::local_member(
  self : Machine,
  mi : Int32,
  name : String,
  exported : Bool,
) -> String? raise EvalError {
  let mut found = false
  for file in self.plan.files[mi] {
    self.charge(0)
    for declaration in file.declarations {
      self.charge(16)
      let unsupported = match declaration {
        @parser.Let(d) =>
          Some((d.name, !exported || d.visibility is @parser.Public))
        @parser.Trait(d) =>
          Some((d.name, !exported || d.visibility is @parser.Public))
        @parser.TypeAlias(d) =>
          Some((d.name, !exported || d.visibility is @parser.Public))
        @parser.ForeignType(d) =>
          Some((d.name, !exported || d.visibility is @parser.Public))
        @parser.ForeignLibrary(d) => Some((d.namespace_alias, !exported))
        _ => None
      }
      if unsupported is Some((n, visible)) && n == name && visible {
        raise Failed(
          "unsupported compile-time declaration shadows name: " + name,
        )
      }
      let candidate = match declaration {
        @parser.Function(d) => Some((d.name, d.visibility))
        @parser.Struct(d) => Some((d.name, d.visibility))
        @parser.Enum(d) => Some((d.name, d.visibility))
        @parser.Builtin(d) => Some((d.name, d.visibility))
        _ => None
      }
      if candidate is Some((n, visibility)) &&
        n == name &&
        (!exported || visibility is @parser.Public) {
        guard !found else {
          raise Failed(
            "overloaded compile-time names are not supported: " + name,
          )
        }
        found = true
      }
    }
  }
  if found {
    Some(self.plan.modules[mi].path + "::" + name)
  } else {
    None
  }
}

///|
fn Machine::resolve(
  self : Machine,
  mi : Int32,
  name : String,
  alias : String?,
) -> String raise EvalError {
  if alias is Some(alias) {
    let mut path : String? = None
    for file in self.plan.files[mi] {
      self.charge(0)
      for declaration in file.declarations {
        self.charge(16)
        if declaration is @parser.Import(import_) &&
          !import_.open_ &&
          import_.import_alias.unwrap_or(import_.path.last().unwrap()) == alias {
          let next = import_.path.join(".")
          if path is Some(prior) && prior != next {
            raise Failed("ambiguous transform import alias: " + alias)
          }
          path = Some(next)
        }
      }
    }
    guard path is Some(path) else {
      raise Failed("unknown transform import alias: " + alias)
    }
    let target = self.module_index(path)
    guard self.local_member(target, name, true) is Some(key) else {
      raise Failed("unknown or non-public compile-time member: " + name)
    }
    return key
  }
  if self.local_member(mi, name, false) is Some(key) {
    return key
  }
  let mut result : String? = None
  for file in self.plan.files[mi] {
    self.charge(0)
    for declaration in file.declarations {
      self.charge(16)
      if declaration is @parser.Import(import_) && import_.open_ {
        guard !import_.wildcard else {
          raise Failed(
            "wildcard imports are not supported by the transform interpreter",
          )
        }
        let target = self.module_index(import_.path.join("."))
        if self.local_member(target, name, true) is Some(key) {
          if result is Some(prior) && prior != key {
            raise Failed("ambiguous compile-time name: " + name)
          }
          result = Some(key)
        }
      }
    }
  }
  if result is Some(key) {
    return key
  }
  if self.plan.type_names.get((mi, name)) is Some(key) {
    return key
  }
  raise Failed("unknown or unsupported compile-time name: " + name)
}

///|
fn Machine::path(
  self : Machine,
  mi : Int32,
  expr : @parser.Expr,
) -> String raise EvalError {
  self.charge(16)
  guard self.depth < 128 else { raise Failed("transform depth limit exceeded") }
  self.depth += 1
  let result = self.path_inner(mi, expr) catch {
    error => {
      self.depth -= 1
      raise error
    }
  }
  self.depth -= 1
  result
}

///|
fn Machine::path_inner(
  self : Machine,
  mi : Int32,
  expr : @parser.Expr,
) -> String raise EvalError {
  match expr {
    @parser.NameExpr(name, _) => self.resolve(mi, name, None)
    @parser.FieldExpr(@parser.ImportAliasExpr(alias, _), name, _)
    | @parser.QualifiedExpr(@parser.ImportAliasExpr(alias, _), name, _) =>
      self.resolve(mi, name, Some(alias))
    @parser.QualifiedExpr(owner, name, _) => self.path(mi, owner) + "::" + name
    _ =>
      raise Failed(
        "compile-time calls require a direct function or enum constructor",
      )
  }
}

///|
fn Machine::call(
  self : Machine,
  key : String,
  args : Array[Value],
) -> Value raise EvalError {
  self.charge(32 + args.length() * 16)
  if self.functions.get(key) is Some(Source(mi, fi, function, _)) {
    return self.source_call(mi, fi, function, args)
  }
  for mi, module_ in self.plan.modules {
    self.charge(0)
    for fi, file in self.plan.files[mi] {
      self.charge(0)
      for declaration in file.declarations {
        self.charge(16)
        match declaration {
          @parser.Function(fn_) if key == module_.path + "::" + fn_.name => {
            guard fn_.receiver is None else {
              return eval_fail("method calls are not supported at compile time")
            }
            guard !file.annotations.any(fn(annotation) {
              annotation.target >= fn_.offset.to_int() &&
              annotation.target < fn_.name_offset.to_int()
            }) else {
              return eval_fail(
                "annotated functions cannot execute at compile time",
              )
            }
            guard args.length() == fn_.parameters.length() else {
              return eval_fail("compile-time argument count mismatch: " + key)
            }
            self.functions[key] = Source(mi, fi, fn_, "")
            for _ in fn_.parameters {
              self.charge(16)
            }
            let previous_file = self.file_index
            self.file_index = fi
            let result = self.source_body(mi, fn_, args) catch {
              Returned(value) => value
              Broken(_) | Continued(_) => {
                self.file_index = previous_file
                return eval_fail("loop control escaped a compile-time function")
              }
              Failed(message) => {
                self.file_index = previous_file
                return eval_fail(key + ": " + message)
              }
            }
            self.file_index = previous_file
            return result
          }
          @parser.Enum(enum_) =>
            for variant in enum_.variants {
              self.charge(16)
              if key == module_.path + "::" + enum_.name + "::" + variant.name() {
                return Variant(key, args)
              }
            }
          @parser.Builtin(builtin) if key == module_.path + "::" + builtin.name =>
            return eval_fail(
              "builtin is not supported at compile time: " +
              text(builtin.builtin_name),
            )
          _ => ()
        }
      }
    }
  }
  eval_fail(
    "function is unavailable at compile time (host calls are forbidden): " + key,
  )
}

///|
fn normalized(bits : UInt64, kind : String) -> Value {
  let bits = match kind {
    "I8" | "U8" => bits & 255UL
    "I16" | "U16" => bits & 65535UL
    "I32" | "U32" => bits & 4294967295UL
    _ => bits
  }
  Number(bits, kind)
}

///|
fn signed(bits : UInt64, kind : String) -> Int64 {
  match kind {
    "I8" => bits.to_int64() << 56 >> 56
    "I16" => bits.to_int64() << 48 >> 48
    "I32" => bits.to_int64() << 32 >> 32
    _ => bits.to_int64()
  }
}

///|
fn binary(op : Operation, left : Value, right : Value) -> Value raise EvalError {
  let left = if left is DefaultValue {
    match right {
      Number(_, kind) => normalized(0UL, kind)
      Boolean(_) => Boolean(false)
      _ => left
    }
  } else {
    left
  }
  let right = if right is DefaultValue {
    match left {
      Number(_, kind) => normalized(0UL, kind)
      Boolean(_) => Boolean(false)
      _ => right
    }
  } else {
    right
  }
  match (left, right) {
    (DefaultValue, DefaultValue) =>
      match op {
        Equal | LessEqual | GreaterEqual => Boolean(true)
        NotEqual | Less | Greater => Boolean(false)
        Add
        | Subtract
        | Multiply
        | BitAnd
        | BitOr
        | BitXor
        | ShiftLeft
        | ShiftRight => DefaultValue
        Divide | Remainder =>
          eval_fail("integer division by zero at compile time")
      }
    (Boolean(a), Boolean(b)) =>
      match op {
        Equal => Boolean(a == b)
        NotEqual => Boolean(a != b)
        _ => eval_fail("unsupported Bool operator at compile time")
      }
    (Floating(_, kind), Floating(_, other)) if kind == other =>
      float_binary(op, left, right, kind)
    (Number(a, kind), Number(b, other)) if kind == other ||
      op is ShiftLeft ||
      op is ShiftRight => {
      let sa = signed(a, kind)
      let sb = signed(b, kind)
      let is_signed = kind.has_prefix("I")
      match op {
        Add => normalized(a + b, kind)
        Subtract => normalized(a - b, kind)
        Multiply => normalized(a * b, kind)
        BitAnd => normalized(a & b, kind)
        BitOr => normalized(a | b, kind)
        BitXor => normalized(a ^ b, kind)
        ShiftLeft =>
          normalized(
            a <<
            (
              b.to_int() &
              (if kind == "I64" || kind == "U64" { 63 } else { 31 })
            ),
            kind,
          )
        ShiftRight => {
          let amount = b.to_int() &
            (if kind == "I64" || kind == "U64" { 63 } else { 31 })
          normalized(
            if is_signed {
              (sa >> amount).reinterpret_as_uint64()
            } else {
              a >> amount
            },
            kind,
          )
        }
        Equal => Boolean(a == b)
        NotEqual => Boolean(a != b)
        Less => Boolean(if is_signed { sa < sb } else { a < b })
        LessEqual => Boolean(if is_signed { sa <= sb } else { a <= b })
        Greater => Boolean(if is_signed { sa > sb } else { a > b })
        GreaterEqual => Boolean(if is_signed { sa >= sb } else { a >= b })
        Divide | Remainder => {
          guard b != 0UL else {
            return eval_fail("division by zero in transform")
          }
          guard !(op is Divide &&
            is_signed &&
            sb == -1L &&
            (
              sa == -9223372036854775808L ||
              (kind == "I32" && sa == -2147483648L)
            )) else {
            return eval_fail("signed division overflow in transform")
          }
          normalized(
            if is_signed {
              (if op is Divide {
                sa / sb
              } else if sb == -1L {
                0L
              } else {
                sa % sb
              }).reinterpret_as_uint64()
            } else if op is Divide {
              a / b
            } else {
              a % b
            },
            kind,
          )
        }
        _ => eval_fail("unsupported integer operator at compile time")
      }
    }
    _ => eval_fail("unsupported operands at compile time")
  }
}

///|
fn Machine::block(
  self : Machine,
  mi : Int32,
  block : @parser.Block,
  outer : Map[String, Cell],
) -> Value raise EvalError {
  let env = self.scope(outer)
  let mut result = Unit
  for item in block.items {
    self.charge(16)
    result = Unit
    match item {
      @parser.LetItem(mutable_, name, _, value, _) =>
        env[name] = { value: self.eval(mi, value, env), mutable_, }
      @parser.ExpressionItem(value, _) => result = self.eval(mi, value, env)
      @parser.AssignmentItem(@parser.NameExpr(name, _), value, _) => {
        guard env.get(name) is Some(cell) && cell.mutable_ else {
          return eval_fail("assignment requires a mutable compile-time local")
        }
        cell.value = self.eval(mi, value, env)
      }
      @parser.AssignmentItem(@parser.FieldExpr(owner, name, _), value, _) => {
        let owner = self.eval(mi, owner, env)
        self.write_field(owner, name, self.eval(mi, value, env))
      }
      @parser.TypeBindingItem(_, _, _) => ()
      _ => return eval_fail("unsupported assignment at compile time")
    }
  }
  result
}

///|
fn Machine::eval(
  self : Machine,
  mi : Int32,
  expr : @parser.Expr,
  env : Map[String, Cell],
) -> Value raise EvalError {
  self.charge(16)
  guard self.depth < 128 else {
    return eval_fail("transform depth limit exceeded")
  }
  self.depth += 1
  let result = self.eval_inner(mi, expr, env) catch {
    error => {
      self.depth -= 1
      raise error
    }
  }
  self.depth -= 1
  match expr {
    @parser.NameExpr(_, _) | @parser.FieldExpr(_, _, _) =>
      match
        self.scalar_type_proof((mi, self.file_index, expr.offset().to_int())) {
        Some(kind) => self.typed_value(result, kind)
        _ => result
      }
    _ => result
  }
}

///|
fn Machine::eval_inner(
  self : Machine,
  mi : Int32,
  expr : @parser.Expr,
  env : Map[String, Cell],
) -> Value raise EvalError {
  match expr {
    @parser.I8Expr(n, _) => normalized(n, "I8")
    @parser.I16Expr(n, _) => normalized(n, "I16")
    @parser.I32Expr(n, _) => normalized(n, "I32")
    @parser.I64Expr(n, _) => normalized(n, "I64")
    @parser.U8Expr(n, _) => normalized(n, "U8")
    @parser.U16Expr(n, _) => normalized(n, "U16")
    @parser.U32Expr(n, _) => normalized(n, "U32")
    @parser.U64Expr(n, _) => normalized(n, "U64")
    @parser.F32Expr(value, _) =>
      Floating(value.reinterpret_as_uint().to_uint64(), "F32")
    @parser.F64Expr(value, _) => Floating(value.reinterpret_as_uint64(), "F64")
    @parser.BoolExpr(value, _) => Boolean(value)
    @parser.StringExpr(value, _) => {
      self.charge(value.length())
      let decoded = @utf8.decode(value) catch {
        _ =>
          raise Failed(
            "non-UTF-8 string literals are not supported at compile time",
          )
      }
      Text(decoded)
    }
    @parser.BytesExpr(value, _) => {
      self.charge(value.length())
      ByteText(value)
    }
    @parser.NameExpr(name, _) =>
      match env.get(name) {
        Some(cell) => cell.value
        None => self.function_reference(mi, expr, env)
      }
    @parser.LambdaExpr(parameters, _, body, _) =>
      Closure(
        mi,
        self.file_index,
        parameters,
        body,
        self.scope(env),
        self.frame,
      )
    @parser.ArrayExpr(items, offset) =>
      self.array_value(
        mi,
        offset,
        items.map(fn(item) { self.eval(mi, item, env) }),
      )
    @parser.ProductExpr(items, _) =>
      if items.is_empty() {
        Unit
      } else {
        Sequence(items.map(fn(item) { self.eval(mi, item, env) }))
      }
    @parser.BlockExpr(block) => self.block(mi, block, env)
    @parser.ObjectExpr(items, _) => {
      let values : Map[String, Value] = Map::default()
      for item in items {
        values[item.name] = self.eval(mi, item.value, env)
      }
      Record("", values)
    }
    @parser.ConstructExpr(type_, items, _) => {
      let key = self.path(mi, type_)
      let values : Map[String, Value] = Map::default()
      for item in items {
        values[item.name] = self.eval(mi, item.value, env)
      }
      Record(key, values)
    }
    @parser.QualifiedExpr(_, _, _) =>
      if self.has_reference_proof((mi, self.file_index, expr.offset().to_int())) {
        self.function_reference(mi, expr, env)
      } else {
        self.unit_variant(self.path(mi, expr))
      }
    @parser.FieldExpr(owner, name, _) =>
      if self.has_reference_proof((mi, self.file_index, expr.offset().to_int())) {
        self.function_reference(mi, expr, env)
      } else {
        self.read_field(self.eval(mi, owner, env), name)
      }
    @parser.ProductFieldExpr(owner, index, _, _) => {
      guard self.eval(mi, owner, env) is Sequence(values) &&
        index >= 0 &&
        index < values.length() else {
        return eval_fail("invalid compile-time product access")
      }
      values[index]
    }
    @parser.IfExpr(condition, yes, no, _) =>
      if truth(self.eval(mi, condition, env)) {
        self.block(mi, yes, env)
      } else {
        match no {
          Some(no) => self.eval(mi, no, env)
          None => Unit
        }
      }
    @parser.CallExpr(callee, args, offset) =>
      self.checked_call(mi, offset, callee, args, env)
    @parser.ExplicitTypeCallExpr(callee, types, args, offset) =>
      self.checked_call(mi, offset, callee, args, env, type_arguments=types)
    @parser.IndexExpr(owner, index, offset) =>
      self.selected_operator(mi, offset, [
        self.eval(mi, owner, env),
        self.eval(mi, index, env),
      ])
    @parser.BinaryExpr(@parser.LogicalAnd, left, right, _) =>
      Boolean(
        truth(self.eval(mi, left, env)) && truth(self.eval(mi, right, env)),
      )
    @parser.BinaryExpr(@parser.LogicalOr, left, right, _) =>
      Boolean(
        truth(self.eval(mi, left, env)) || truth(self.eval(mi, right, env)),
      )
    @parser.BinaryExpr(op, left, right, offset) =>
      self.scalar_binary(
        mi,
        offset,
        op,
        self.eval(mi, left, env),
        self.eval(mi, right, env),
      )
    @parser.PrefixExpr(op, value, offset) => {
      let value = self.eval(mi, value, env)
      self.scalar_prefix(
        op,
        value,
        self.scalar_type_proof((mi, self.file_index, offset.to_int())),
      )
    }
    @parser.ReturnExpr(value, _) =>
      raise Returned(
        match value {
          Some(value) => self.eval(mi, value, env)
          None => Unit
        },
      )
    @parser.BreakExpr(value, _) => raise Broken(self.eval(mi, value, env))
    @parser.ContinueExpr(value, _) => raise Continued(self.eval(mi, value, env))
    @parser.MatchExpr(value, arms, _) => {
      let value = self.eval(mi, value, env)
      for arm in arms {
        let scope = self.scope(env)
        if self.pattern(mi, arm.pattern, value, scope) {
          if arm.guard_condition is Some(guard_) &&
            !truth(self.eval(mi, guard_, scope)) {
            continue
          }
          return self.eval(mi, arm.body, scope)
        }
      }
      eval_fail("non-exhaustive match during transform execution")
    }
    @parser.WhileExpr(initial, arms, _) => {
      let mut value = self.eval(mi, initial, env)
      while true {
        self.charge(0)
        let mut matched = false
        for arm in arms {
          let scope = self.scope(env)
          if self.pattern(mi, arm.pattern, value, scope) {
            try {
              if arm.guard_condition is Some(guard_) &&
                !truth(self.eval(mi, guard_, scope)) {
                continue
              }
              matched = true
              let _ = self.eval(mi, arm.body, scope)
            } catch {
              Continued(next) => {
                value = next
                matched = true
              }
              Broken(result) => return result
              error => raise error
            }
            break
          }
        }
        if !matched {
          return Unit
        }
      } nobreak {
        Unit
      }
    }
    _ =>
      eval_fail(
        "expression is not supported by the transform interpreter at " +
        self.plan.files[mi][self.file_index].file.path +
        ":" +
        expr.offset().to_string(),
      )
  }
}

///|
fn Machine::pattern(
  self : Machine,
  mi : Int32,
  pattern : @parser.Pattern,
  value : Value,
  env : Map[String, Cell],
) -> Bool raise EvalError {
  self.charge(16)
  guard self.depth < 128 else { raise Failed("transform depth limit exceeded") }
  self.depth += 1
  let result = self.pattern_inner(mi, pattern, value, env) catch {
    error => {
      self.depth -= 1
      raise error
    }
  }
  self.depth -= 1
  result
}

///|
fn Machine::pattern_inner(
  self : Machine,
  mi : Int32,
  pattern : @parser.Pattern,
  value : Value,
  env : Map[String, Cell],
) -> Bool raise EvalError {
  match pattern {
    @parser.WildcardPattern(_) => true
    @parser.BindingPattern(name, offset) => {
      let constructor = self.pattern_key(mi, offset)
      if constructor.is_empty() {
        env[name] = { value, mutable_: false, }
        true
      } else {
        value is Variant(key, values) && key == constructor && values.is_empty()
      }
    }
    @parser.LiteralPattern(expr, _) => {
      let expected = self.eval(mi, expr, env)
      match (expected, value) {
        (Text(text), TextReference(_)) => text == self.string(value)
        _ => equal(expected, value)
      }
    }
    @parser.ProductPattern(patterns, _) => {
      if patterns.is_empty() && (value is Unit || value is DefaultValue) {
        return true
      }
      guard value is Sequence(values) && values.length() == patterns.length() else {
        return false
      }
      for i, p in patterns {
        if !self.pattern(mi, p, values[i], env) {
          return false
        }
      }
      true
    }
    @parser.QualifiedPattern(_, _, offset) => {
      let constructor = self.pattern_key(mi, offset)
      guard !constructor.is_empty() else {
        raise Failed("expected a checked enum constructor pattern")
      }
      value is Variant(key, values) && key == constructor && values.is_empty()
    }
    @parser.StructPattern(_, patterns, _, offset) => {
      let expected = self.pattern_key(mi, offset)
      if value is ReferenceView(_, _) {
        for pattern in patterns {
          if !self.pattern(
              mi,
              pattern.pattern,
              self.read_field(value, pattern.name),
              env,
            ) {
            return false
          }
        }
        return true
      }
      guard value is Record(key, values) else { return false }
      if !key.is_empty() && key != expected {
        return false
      }
      for pattern in patterns {
        guard values.get(pattern.name) is Some(item) else { return false }
        if !self.pattern(mi, pattern.pattern, item, env) {
          return false
        }
      }
      true
    }
    @parser.AlternativePattern(first, rest, _) => {
      let choices = [first]
      for choice in rest {
        choices.push(choice)
      }
      for choice in choices {
        let scope = self.scope(env)
        if self.pattern(mi, choice, value, scope) {
          for name, cell in scope {
            env[name] = cell
          }
          return true
        }
      }
      false
    }
    @parser.TuplePattern(_, patterns, _) => {
      guard value is Variant(key, values) &&
        key == self.pattern_path(mi, pattern) &&
        values.length() == patterns.length() else {
        return false
      }
      for i, p in patterns {
        if !self.pattern(mi, p, values[i], env) {
          return false
        }
      }
      true
    }
    _ => raise Failed("pattern is not supported by the transform interpreter")
  }
}

///|
fn Machine::scope(
  self : Machine,
  outer : Map[String, Cell],
) -> Map[String, Cell] raise EvalError {
  self.charge(outer.length() * 16)
  outer.copy()
}

///|
fn Machine::pattern_path(
  self : Machine,
  mi : Int32,
  pattern : @parser.Pattern,
) -> String raise EvalError {
  self.charge(16)
  guard self.depth < 128 else { raise Failed("transform depth limit exceeded") }
  self.depth += 1
  let result = self.pattern_path_inner(mi, pattern) catch {
    error => {
      self.depth -= 1
      raise error
    }
  }
  self.depth -= 1
  result
}

///|
fn Machine::pattern_path_inner(
  self : Machine,
  mi : Int32,
  pattern : @parser.Pattern,
) -> String raise EvalError {
  let key = self.pattern_key(mi, pattern.offset())
  guard !key.is_empty() else {
    raise Failed("expected a checked enum constructor pattern")
  }
  key
}

///|
fn equal(a : Value, b : Value) -> Bool raise EvalError {
  match (a, b) {
    (DefaultValue, Number(n, _)) | (Number(n, _), DefaultValue) => n == 0UL
    (DefaultValue, Boolean(v)) | (Boolean(v), DefaultValue) => !v
    (DefaultValue, DefaultValue) => true
    (Floating(a, k), Floating(b, other)) if k == other => {
      let a = float_double(Floating(a, k), k)
      let b = float_double(Floating(b, other), other)
      a == b
    }
    (Number(a, k), Number(_, _)) =>
      match intrinsic_kind(b, k) {
        Number(bits, _) => a == bits
        _ => false
      }
    (Boolean(a), Boolean(b)) => a == b
    (Boolean(a), Number(_, _)) =>
      match intrinsic_kind(b, "Bool") {
        Boolean(value) => a == value
        _ => false
      }
    (Text(a), Text(b)) => a == b
    _ => raise Failed("unsupported equality in compile-time pattern")
  }
}

///|
enum Operation {
  ShiftLeft
  ShiftRight
  Add
  BitAnd
  BitOr
  BitXor
  Divide
  Equal
  Greater
  GreaterEqual
  Less
  LessEqual
  Multiply
  NotEqual
  Remainder
  Subtract
}

///|
fn operation(op : @parser.BinaryOperator) -> Operation raise EvalError {
  match op {
    @parser.ShiftLeft => ShiftLeft
    @parser.ShiftRight => ShiftRight
    @parser.Add => Add
    @parser.BitAnd => BitAnd
    @parser.BitOr => BitOr
    @parser.BitXor => BitXor
    @parser.Divide => Divide
    @parser.Equal => Equal
    @parser.Greater => Greater
    @parser.GreaterEqual => GreaterEqual
    @parser.Less => Less
    @parser.LessEqual => LessEqual
    @parser.Multiply => Multiply
    @parser.NotEqual => NotEqual
    @parser.Remainder => Remainder
    @parser.Subtract => Subtract
    _ => raise Failed("unsupported primitive operator at compile time")
  }
}

///|
struct RawStorage {
  values : Array[Value]
  mut default_kind : String
}
