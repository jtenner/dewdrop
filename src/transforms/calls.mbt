///|
enum CallTarget {
  Constant(CheckedConstant)
  Source(Int32, Int32, @parser.FunctionDeclaration, String)
  Global(Int32, Int32, @parser.LetDeclaration)
  Intrinsic(@parser.BuiltinDeclaration, String)
  FunctionValue(String)
  Unsupported
  Constructor(String)
  UnitConstructor(String)
}

///|
pub fn Plan::add_call_proof(
  self : Plan,
  mi : Int32,
  path : String,
  offset : UInt64,
  target_module : Int32,
  target_path : String,
  target_offset : UInt64,
  reference~ : Bool = false,
  result_kind~ : String = "",
  constructor_key~ : String = "",
) -> Unit {
  if mi < 0 || mi >= self.files.length() {
    return
  }
  for fi, file in self.files[mi] {
    if file.file.path != path || offset >= file.clean.length().to_uint64() {
      continue
    }
    let site = (mi, fi, offset.to_int())
    if target_module == -5 {
      self.scalar_types[site] = result_kind
      return
    }
    let sites = if reference { self.references } else { self.calls }
    if target_module < 0 {
      sites[site] = if target_module == -2 {
        FunctionValue(result_kind)
      } else if target_module == -3 {
        Constructor(constructor_key)
      } else if target_module == -4 {
        UnitConstructor(constructor_key)
      } else {
        Unsupported
      }
      return
    }
    sites[site] = Unsupported
    if target_module >= self.files.length() {
      return
    }
    for ti, target in self.files[target_module] {
      if target.file.path != target_path {
        continue
      }
      for declaration in target.declarations {
        match declaration {
          @parser.Function(f) if f.offset == target_offset =>
            sites[site] = Source(target_module, ti, f, result_kind)
          @parser.Impl(impl_) =>
            for f in impl_.methods {
              if f.offset == target_offset {
                sites[site] = Source(target_module, ti, f, result_kind)
              }
            }
          @parser.Let(value) if value.offset == target_offset =>
            sites[site] = Global(target_module, ti, value)
          @parser.Builtin(b) if b.offset == target_offset =>
            sites[site] = Intrinsic(b, result_kind)
          _ => ()
        }
      }
    }
  }
}

///|
fn Machine::source_call(
  self : Machine,
  mi : Int32,
  fi : Int32,
  function : @parser.FunctionDeclaration,
  args : Array[Value],
) -> Value raise EvalError {
  let file = self.plan.files[mi][fi]
  guard !file.annotations.any(fn(a) {
    a.target >= function.offset.to_int() &&
    a.target < function.name_offset.to_int()
  }) else {
    return eval_fail("annotated functions cannot execute at compile time")
  }
  let receiver_count = if function.receiver is Some(_) { 1 } else { 0 }
  guard args.length() == function.parameters.length() + receiver_count else {
    return eval_fail(
      "checked compile-time argument count mismatch: " + function.name,
    )
  }
  self.charge(32 + args.length() * 16)
  let env : Map[String, Cell] = Map::default()
  if receiver_count == 1 {
    env["self"] = { value: args[0], mutable_: false, }
  }
  for i, parameter in function.parameters {
    env[parameter.name] = { value: args[i + receiver_count], mutable_: false, }
  }
  let previous = self.file_index
  self.file_index = fi
  let result = self.block(mi, function.body, env) catch {
    Returned(value) => value
    Broken(_) | Continued(_) => {
      self.file_index = previous
      return eval_fail("loop control escaped a compile-time function")
    }
    Failed(message) => {
      self.file_index = previous
      return eval_fail(function.name + ": " + message)
    }
  }
  self.file_index = previous
  result
}

///|
fn Machine::checked_call(
  self : Machine,
  mi : Int32,
  offset : UInt64,
  callee : @parser.Expr,
  args : Array[@parser.Expr],
  env : Map[String, Cell],
  type_arguments~ : Array[@parser.TypeExpr] = [],
) -> Value raise EvalError {
  let _ = type_arguments
  match self.plan.calls.get((mi, self.file_index, offset.to_int())) {
    Some(Constant(value)) => self.checked_constant(value)
    Some(Source(target_mi, target_fi, function, kind)) => {
      let values : Array[Value] = []
      if function.receiver is Some(_) {
        guard callee is @parser.FieldExpr(owner, _, _) else {
          return eval_fail(
            "checked receiver call requires a receiver expression",
          )
        }
        values.push(self.eval(mi, owner, env))
      }
      for arg in args {
        values.push(self.eval(mi, arg, env))
      }
      intrinsic_kind(
        self.source_call(target_mi, target_fi, function, values),
        kind,
      )
    }
    Some(Intrinsic(builtin, kind)) => {
      let result = self.intrinsic(
        builtin,
        args.map(fn(arg) { self.eval(mi, arg, env) }),
        result_kind=kind,
      )
      intrinsic_kind(result, kind)
    }
    Some(Constructor(key)) =>
      Variant(key, args.map(fn(arg) { self.eval(mi, arg, env) }))
    Some(FunctionValue(kind)) => {
      let closure = self.eval(mi, callee, env)
      let values = args.map(fn(arg) { self.eval(mi, arg, env) })
      intrinsic_kind(self.closure_call(closure, values), kind)
    }
    Some(_) =>
      eval_fail("checked call requires unsupported compile-time dispatch")
    None => {
      let key = self.path(mi, callee)
      let values = args.map(fn(arg) { self.eval(mi, arg, env) })
      self.call(key, values)
    }
  }
}

///|
fn Machine::selected_operator(
  self : Machine,
  mi : Int32,
  offset : UInt64,
  values : Array[Value],
) -> Value raise EvalError {
  match self.plan.calls.get((mi, self.file_index, offset.to_int())) {
    Some(Source(target_mi, target_fi, function, kind)) =>
      intrinsic_kind(
        self.source_call(target_mi, target_fi, function, values),
        kind,
      )
    _ =>
      eval_fail("selected operator has no supported compile-time source body")
  }
}

///|
fn Machine::closure_call(
  self : Machine,
  closure : Value,
  args : Array[Value],
) -> Value raise EvalError {
  if closure is Function(target, bound) {
    let values = bound.copy()
    for arg in args {
      values.push(arg)
    }
    return match target {
      Source(mi, fi, function, kind) =>
        intrinsic_kind(self.source_call(mi, fi, function, values), kind)
      Intrinsic(builtin, kind) =>
        intrinsic_kind(self.intrinsic(builtin, values, result_kind=kind), kind)
      Constructor(key) => Variant(key, values)
      _ => eval_fail("unsupported checked function reference")
    }
  }
  guard closure is Closure(mi, fi, parameters, body, captured) else {
    return eval_fail(
      "compile-time function value is not an interpreted closure",
    )
  }
  guard parameters.length() == args.length() else {
    return eval_fail("compile-time closure argument count mismatch")
  }
  let env = self.scope(captured)
  for i, parameter in parameters {
    env[parameter.name] = { value: args[i], mutable_: false, }
  }
  let previous = self.file_index
  self.file_index = fi
  let result = self.block(mi, body, env) catch {
    Returned(value) => value
    Broken(_) | Continued(_) => {
      self.file_index = previous
      return eval_fail("loop control escaped a compile-time closure")
    }
    error => {
      self.file_index = previous
      raise error
    }
  }
  self.file_index = previous
  result
}

///|
fn Machine::unit_variant(self : Machine, key : String) -> Value raise EvalError {
  for mi, module_ in self.plan.modules {
    for file in self.plan.files[mi] {
      for declaration in file.declarations {
        self.charge(0)
        if declaration is @parser.Enum(enum_) {
          for variant in enum_.variants {
            if variant is @parser.UnitVariant(name, _) &&
              key == module_.path + "::" + enum_.name + "::" + name {
              return Variant(key, [])
            }
          }
        }
      }
    }
  }
  eval_fail("expression does not name a checked unit enum variant")
}

///|
fn Machine::function_reference(
  self : Machine,
  mi : Int32,
  expression : @parser.Expr,
  env : Map[String, Cell],
) -> Value raise EvalError {
  guard self.plan.references.get(
      (mi, self.file_index, expression.offset().to_int()),
    )
    is Some(target) else {
    return eval_fail("global value has no checked function reference")
  }
  if target is Global(mi, fi, declaration) {
    return self.global_value(mi, fi, declaration)
  }
  if target is UnitConstructor(key) {
    return Variant(key, [])
  }
  let bound : Array[Value] = []
  if target is Source(_, _, function, _) &&
    function.receiver is Some(_) &&
    expression is @parser.FieldExpr(owner, _, _) {
    bound.push(self.eval(mi, owner, env))
  }
  Function(target, bound)
}
