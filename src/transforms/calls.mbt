///|
enum CallTarget {
  Constant(CheckedConstant)
  Framed(CallTarget, String)
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
  function_declaration~ : UInt64? = None,
  generic_function~ : Bool = false,
  function_specialization~ : UInt32? = None,
  frame~ : String = "",
  target_frame~ : String = "",
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
      if frame == "" {
        self.scalar_types[site] = result_kind
      } else {
        self.execution_frame(frame).scalar_types[site] = result_kind
      }
      return
    }
    let identity = match function_declaration {
      Some(value) =>
        if generic_function {
          match function_specialization {
            Some(key) => FunctionSpecialization(value, key)
            None => GenericFunctionSingleton(value)
          }
        } else {
          FunctionSingleton(value)
        }
      None => FunctionInstance
    }
    if target_module < 0 {
      let target = if target_module == -2 {
        FunctionValue(result_kind)
      } else if target_module == -3 {
        Constructor(constructor_key)
      } else if target_module == -4 {
        UnitConstructor(constructor_key)
      } else {
        Unsupported
      }
      self.save_frame_call_proof(
        frame, site, reference, target, identity, target_frame,
      )
      return
    }
    if target_module >= self.files.length() {
      self.save_frame_call_proof(
        frame,
        site,
        reference,
        Unsupported,
        identity,
        target_frame,
      )
      return
    }
    let mut selected = Unsupported
    for ti, target in self.files[target_module] {
      if target.file.path != target_path {
        continue
      }
      for declaration in target.declarations {
        match declaration {
          @parser.Function(f) if f.offset == target_offset =>
            selected = Source(target_module, ti, f, result_kind)
          @parser.Impl(impl_) =>
            for f in impl_.methods {
              if f.offset == target_offset {
                selected = Source(target_module, ti, f, result_kind)
              }
            }
          @parser.Let(value) if value.offset == target_offset =>
            selected = Global(target_module, ti, value)
          @parser.Builtin(b) if b.offset == target_offset =>
            selected = Intrinsic(b, result_kind)
          _ => ()
        }
      }
    }
    self.save_frame_call_proof(
      frame, site, reference, selected, identity, target_frame,
    )
  }
}

///|
fn Plan::save_call_proof(
  self : Plan,
  site : (Int32, Int32, Int32),
  reference : Bool,
  target : CallTarget,
  identity : FunctionIdentity,
) -> Unit {
  if reference {
    self.references[site] = { target, identity, }
  } else {
    self.calls[site] = target
  }
}

///|
fn Machine::source_call(
  self : Machine,
  mi : Int32,
  fi : Int32,
  function : @parser.FunctionDeclaration,
  args : Array[Value],
  frame~ : String = "",
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
  let previous = self.file_index
  let previous_frame = self.frame
  self.frame = frame
  self.file_index = fi
  let result = self.source_body(mi, function, args) catch {
    Returned(value) => value
    Broken(_) | Continued(_) => {
      self.file_index = previous
      self.frame = previous_frame
      return eval_fail("loop control escaped a compile-time function")
    }
    Failed(message) => {
      self.file_index = previous
      self.frame = previous_frame
      return eval_fail(function.name + ": " + message)
    }
  }
  self.file_index = previous
  self.frame = previous_frame
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
  let (selected, frame) = unframe_call(
    self.call_proof((mi, self.file_index, offset.to_int())),
  )
  match selected {
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
      self.typed_value(
        self.source_call(target_mi, target_fi, function, values, frame~),
        kind,
      )
    }
    Some(Intrinsic(builtin, kind)) => {
      let result = self.intrinsic(
        builtin,
        args.map(fn(arg) { self.eval(mi, arg, env) }),
        result_kind=kind,
      )
      self.typed_value(result, kind)
    }
    Some(Constructor(key)) =>
      Variant(key, args.map(fn(arg) { self.eval(mi, arg, env) }))
    Some(FunctionValue(kind)) => {
      let closure = self.eval(mi, callee, env)
      let values = args.map(fn(arg) { self.eval(mi, arg, env) })
      self.typed_value(self.closure_call(closure, values), kind)
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
  let (selected, frame) = unframe_call(
    self.call_proof((mi, self.file_index, offset.to_int())),
  )
  match selected {
    Some(Source(target_mi, target_fi, function, kind)) =>
      self.typed_value(
        self.source_call(target_mi, target_fi, function, values, frame~),
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
  if closure is Function(target, bound, _) {
    let values = bound.copy()
    for arg in args {
      values.push(arg)
    }
    let (selected, frame) = unframe_call(Some(target))
    return match selected {
      Some(Source(mi, fi, function, kind)) =>
        self.typed_value(
          self.source_call(mi, fi, function, values, frame~),
          kind,
        )
      Some(Intrinsic(builtin, kind)) =>
        self.typed_value(
          self.intrinsic(builtin, values, result_kind=kind),
          kind,
        )
      Some(Constructor(key)) => Variant(key, values)
      _ => eval_fail("unsupported checked function reference")
    }
  }
  guard closure is Closure(mi, fi, parameters, body, captured, frame) else {
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
  let previous_frame = self.frame
  self.frame = frame
  self.file_index = fi
  let result = self.block(mi, body, env) catch {
    Returned(value) => value
    Broken(_) | Continued(_) => {
      self.file_index = previous
      self.frame = previous_frame
      return eval_fail("loop control escaped a compile-time closure")
    }
    error => {
      self.file_index = previous
      self.frame = previous_frame
      raise error
    }
  }
  self.file_index = previous
  self.frame = previous_frame
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
  guard self.reference_proof(
      (mi, self.file_index, expression.offset().to_int()),
    )
    is Some(proof) else {
    return eval_fail("global value has no checked function reference")
  }
  let target = proof.target
  if target is Global(mi, fi, declaration) {
    return self.global_value(mi, fi, declaration)
  }
  if target is UnitConstructor(key) {
    return Variant(key, [])
  }
  let bound : Array[Value] = []
  let (selected, _) = unframe_call(Some(target))
  if selected is Some(Source(_, _, function, _)) &&
    function.receiver is Some(_) &&
    expression is @parser.FieldExpr(owner, _, _) {
    bound.push(self.eval(mi, owner, env))
  }
  Function(
    target,
    bound,
    if bound.is_empty() {
      proof.identity
    } else {
      FunctionInstance
    },
  )
}
