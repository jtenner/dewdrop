// Opcodes: 1 constant, 2 load, 3 store, 4 binary, 5 charge, 6 enter,
// 7 leave, 8 jump, 9 jump-false, 10 jump-true, 11 call, 12 typed read,
// 13 prefix, 14 field read, 15 field write (+ owner word), 16 return,
// 17 restore loop depth, 18 truth, 19 simple pattern, 20 literal compare.

///|
/// Opcodes occupy the low byte; the remaining 24 bits hold an unsigned operand.
/// Code and proof pools are immutable after construction. Unsupported functions
/// use the tree interpreter as a whole; there is no unchecked expression escape.
struct BytecodeFunction {
  words : FixedArray[UInt32]
  constants : Array[Value]
  calls : Array[BytecodeCall]
  binaries : Array[BytecodeBinary]
  prefixes : Array[(@parser.PrefixOperator, String?)]
  names : Array[String]
  kinds : Array[String]
  slots : Int32
  estimated_bytes : Int32
}

///|
struct BytecodeCall {
  target : CallTarget
  arguments : Array[Int32]
  callee : Int32?
}

///|
struct BytecodeBinary {
  operator : @parser.BinaryOperator
  opcode : Bytes?
  target : CallTarget?
  left : Int32
}

///|
struct BytecodeLoop {
  value : Int32
  head : Int32
  depth : Int32
  breaks : Array[Int32]
}

///|
struct BytecodeBuilder {
  machine : Machine
  module_ : Int32
  words : Array[UInt32]
  constants : Array[Value]
  calls : Array[BytecodeCall]
  binaries : Array[BytecodeBinary]
  prefixes : Array[(@parser.PrefixOperator, String?)]
  names : Array[String]
  kinds : Array[String]
  mutable_slots : Array[Bool]
  mut visits : Int32
  mut depth : Int32
  mut supported : Bool
  mut estimated_bytes : Int32
}

///|
fn BytecodeBuilder::reserve(self : BytecodeBuilder, bytes : Int32) -> Bool {
  if !self.supported || bytes > 1048576 - self.estimated_bytes {
    self.supported = false
    return false
  }
  self.estimated_bytes += bytes
  true
}

///|
fn BytecodeBuilder::emit(
  self : BytecodeBuilder,
  op : UInt32,
  arg : Int32,
) -> Int32 {
  let at = self.words.length()
  if at >= 262144 || arg < 0 || arg >= 16777216 {
    self.supported = false
    return 0
  }
  if !self.reserve(4) {
    return 0
  }
  self.words.push(op | (arg.to_uint() << 8))
  at
}

///|
fn BytecodeBuilder::patch(
  self : BytecodeBuilder,
  at : Int32,
  target : Int32,
) -> Unit {
  if !self.supported {
    return
  }
  self.words[at] = (self.words[at] & 255U) | (target.to_uint() << 8)
}

///|
fn BytecodeBuilder::slot(self : BytecodeBuilder, mutable_ : Bool) -> Int32 {
  let slot = self.mutable_slots.length()
  if slot >= 512 {
    self.supported = false
    return 0
  }
  self.mutable_slots.push(mutable_)
  slot
}

///|
fn BytecodeBuilder::constant(self : BytecodeBuilder, value : Value) -> Unit {
  if !self.reserve(64) {
    return
  }
  let index = self.constants.length()
  self.constants.push(value)
  let _ = self.emit(1U, index)
}

///|
fn BytecodeBuilder::save(self : BytecodeBuilder) -> Int32 {
  let slot = self.slot(false)
  let _ = self.emit(3U, slot)
  slot
}

///|
fn BytecodeBuilder::type_read(self : BytecodeBuilder, offset : UInt64) -> Unit {
  let site = (self.module_, self.machine.file_index, offset.to_int())
  if self.machine.scalar_type_proof(site) is Some(kind) {
    if !self.reserve(8) {
      return
    }
    let index = self.kinds.length()
    self.kinds.push(kind)
    let _ = self.emit(12U, index)
  }
}

///|
fn BytecodeBuilder::block(
  self : BytecodeBuilder,
  block : @parser.Block,
  outer : Map[String, Int32],
  loop_ : BytecodeLoop?,
) -> Unit {
  if !self.supported {
    return
  }
  let env = outer.copy()
  let _ = self.emit(5U, outer.length() * 16)
  self.constant(Unit)
  for item in block.items {
    if !self.supported {
      return
    }
    let _ = self.emit(5U, 16)
    self.constant(Unit)
    match item {
      @parser.LetItem(mutable_, name, _, value, _) => {
        self.expr(value, env, loop_)
        let slot = self.slot(mutable_)
        let _ = self.emit(3U, slot)
        env[name] = slot
        self.constant(Unit)
      }
      @parser.ExpressionItem(value, _) => self.expr(value, env, loop_)
      @parser.AssignmentItem(@parser.NameExpr(name, _), value, _) => {
        guard env.get(name) is Some(slot) && self.mutable_slots[slot] else {
          self.supported = false
          return
        }
        self.expr(value, env, loop_)
        let _ = self.emit(3U, slot)
        self.constant(Unit)
      }
      @parser.AssignmentItem(@parser.FieldExpr(owner, name, _), value, _) => {
        self.expr(owner, env, loop_)
        let slot = self.save()
        self.expr(value, env, loop_)
        if !self.reserve(8) {
          return
        }
        let index = self.names.length()
        self.names.push(name)
        let _ = self.emit(15U, index)
        let _ = self.emit(0U, slot)
        self.constant(Unit)
      }
      @parser.TypeBindingItem(_, _, _) => ()
      _ => self.supported = false
    }
  }
}

///|
fn BytecodeBuilder::call(
  self : BytecodeBuilder,
  callee : @parser.Expr,
  arguments : Array[@parser.Expr],
  offset : UInt64,
  env : Map[String, Int32],
  loop_ : BytecodeLoop?,
) -> Unit {
  let site = (self.module_, self.machine.file_index, offset.to_int())
  guard self.machine.call_proof(site) is Some(target) else {
    self.supported = false
    return
  }
  let (selected, _) = unframe_call(Some(target))
  let slots : Array[Int32] = []
  let mut closure = None
  match selected {
    Some(Constant(_)) => ()
    Some(Source(_, _, function, _)) => {
      if function.receiver is Some(_) {
        guard callee is @parser.FieldExpr(owner, _, _) else {
          self.supported = false
          return
        }
        self.expr(owner, env, loop_)
        slots.push(self.save())
      }
      for arg in arguments {
        if !self.supported {
          return
        }
        self.expr(arg, env, loop_)
        slots.push(self.save())
      }
    }
    Some(Intrinsic(_, _)) | Some(Constructor(_)) =>
      for arg in arguments {
        if !self.supported {
          return
        }
        self.expr(arg, env, loop_)
        slots.push(self.save())
      }
    Some(FunctionValue(_)) => {
      self.expr(callee, env, loop_)
      closure = Some(self.save())
      for arg in arguments {
        if !self.supported {
          return
        }
        self.expr(arg, env, loop_)
        slots.push(self.save())
      }
    }
    _ => {
      self.supported = false
      return
    }
  }
  if !self.reserve(96 + slots.length() * 8) {
    return
  }
  let index = self.calls.length()
  self.calls.push({ target, arguments: slots, callee: closure, })
  let _ = self.emit(11U, index)
}

///|
fn BytecodeBuilder::expr(
  self : BytecodeBuilder,
  expr : @parser.Expr,
  env : Map[String, Int32],
  loop_ : BytecodeLoop?,
) -> Unit {
  if !self.supported {
    return
  }
  if self.machine.bytecode_compile_work <= 0 {
    self.supported = false
    return
  }
  self.machine.bytecode_compile_work -= 1
  self.visits += 1
  if self.visits > 100000 || self.depth >= 128 {
    self.supported = false
    return
  }
  let _ = self.emit(6U, 0)
  self.depth += 1
  match expr {
    @parser.I8Expr(n, _) => self.constant(normalized(n, "I8"))
    @parser.I16Expr(n, _) => self.constant(normalized(n, "I16"))
    @parser.I32Expr(n, _) => self.constant(normalized(n, "I32"))
    @parser.I64Expr(n, _) => self.constant(normalized(n, "I64"))
    @parser.U8Expr(n, _) => self.constant(normalized(n, "U8"))
    @parser.U16Expr(n, _) => self.constant(normalized(n, "U16"))
    @parser.U32Expr(n, _) => self.constant(normalized(n, "U32"))
    @parser.U64Expr(n, _) => self.constant(normalized(n, "U64"))
    @parser.F32Expr(n, _) =>
      self.constant(Floating(n.reinterpret_as_uint().to_uint64(), "F32"))
    @parser.F64Expr(n, _) =>
      self.constant(Floating(n.reinterpret_as_uint64(), "F64"))
    @parser.BoolExpr(value, _) => self.constant(Boolean(value))
    @parser.ProductExpr(values, _) if values.is_empty() => self.constant(Unit)
    @parser.NameExpr(name, _) =>
      match env.get(name) {
        Some(slot) => {
          let _ = self.emit(2U, slot)
        }
        None => self.supported = false
      }
    @parser.BlockExpr(block) => self.block(block, env, loop_)
    @parser.IfExpr(condition, yes, no, _) => {
      self.expr(condition, env, loop_)
      let next = self.emit(9U, 0)
      self.block(yes, env, loop_)
      let done = self.emit(8U, 0)
      self.patch(next, self.words.length())
      match no {
        Some(value) => self.expr(value, env, loop_)
        None => self.constant(Unit)
      }
      self.patch(done, self.words.length())
    }
    @parser.BinaryExpr(op, left, right, offset) => {
      self.expr(left, env, loop_)
      if op is @parser.LogicalAnd || op is @parser.LogicalOr {
        let _ = self.emit(18U, 0)
        let done = self.emit(if op is @parser.LogicalAnd { 9U } else { 10U }, 0)
        // The evaluated right operand is the Wasm result, including raw Bool bits.
        self.expr(right, env, loop_)
        self.patch(done, self.words.length())
      } else {
        let slot = self.save()
        self.expr(right, env, loop_)
        let site = (self.module_, self.machine.file_index, offset.to_int())
        let opcode = self.machine.scalar_operator_proof(site)
        let target = self.machine.call_proof(site)
        if opcode is None && target is None {
          self.supported = false
        }
        if !self.reserve(80) {
          return
        }
        let index = self.binaries.length()
        self.binaries.push({ operator: op, opcode, target, left: slot, })
        let _ = self.emit(4U, index)
      }
    }
    @parser.PrefixExpr(op, value, offset) => {
      self.expr(value, env, loop_)
      let site = (self.module_, self.machine.file_index, offset.to_int())
      if !self.reserve(48) {
        return
      }
      let index = self.prefixes.length()
      self.prefixes.push((op, self.machine.scalar_type_proof(site)))
      let _ = self.emit(13U, index)
    }
    @parser.CallExpr(callee, args, offset)
    | @parser.ExplicitTypeCallExpr(callee, _, args, offset) =>
      self.call(callee, args, offset, env, loop_)
    @parser.FieldExpr(owner, name, offset) =>
      // Method references carry their own identity/receiver semantics.
      if self.machine.has_reference_proof(
          (self.module_, self.machine.file_index, offset.to_int()),
        ) {
        self.supported = false
      } else {
        self.expr(owner, env, loop_)
        if !self.reserve(8) {
          return
        }
        let index = self.names.length()
        self.names.push(name)
        let _ = self.emit(14U, index)
      }
    @parser.ReturnExpr(value, _) => {
      match value {
        Some(value) => self.expr(value, env, loop_)
        None => self.constant(Unit)
      }
      let _ = self.emit(16U, 0)
    }
    @parser.BreakExpr(value, _) | @parser.ContinueExpr(value, _) => {
      guard loop_ is Some(loop_) else {
        self.supported = false
        return
      }
      self.expr(value, env, Some(loop_))
      let _ = self.emit(17U, loop_.depth)
      if expr is @parser.ContinueExpr(_, _) {
        let _ = self.emit(3U, loop_.value)
        let _ = self.emit(8U, loop_.head)
      } else {
        loop_.breaks.push(self.emit(8U, 0))
      }
    }
    @parser.WhileExpr(initial, arms, _) => {
      self.expr(initial, env, loop_)
      let slot = self.save()
      let head = self.words.length()
      let loop_ : BytecodeLoop = {
        value: slot,
        head,
        depth: self.depth,
        breaks: [],
      }
      let _ = self.emit(5U, 0)
      for arm in arms {
        if !self.supported {
          break
        }
        let scope = env.copy()
        let _ = self.emit(5U, env.length() * 16)
        let mut pattern_next = None
        match arm.pattern {
          @parser.WildcardPattern(_) => {
            let _ = self.emit(19U, 0)
          }
          @parser.BindingPattern(name, offset) => {
            let _ = self.emit(19U, 0)
            let site = (self.module_, self.machine.file_index, offset.to_int())
            guard self.machine.plan.pattern_proofs.get(site) is Some("") else {
              self.supported = false
              break
            }
            let bound = self.slot(false)
            let _ = self.emit(2U, slot)
            let _ = self.emit(3U, bound)
            scope[name] = bound
          }
          @parser.LiteralPattern(expected, _) => {
            let _ = self.emit(6U, 0)
            self.depth += 1
            self.expr(expected, scope, Some(loop_))
            self.depth -= 1
            let _ = self.emit(7U, 0)
            let _ = self.emit(20U, slot)
            pattern_next = Some(self.emit(9U, 0))
          }
          _ => {
            self.supported = false
            break
          }
        }
        let next = match arm.guard_condition {
          Some(condition) => {
            self.expr(condition, scope, Some(loop_))
            Some(self.emit(9U, 0))
          }
          None => None
        }
        self.expr(arm.body, scope, Some(loop_))
        let _ = self.emit(8U, head)
        if next is Some(at) {
          self.patch(at, self.words.length())
        }
        if pattern_next is Some(at) {
          self.patch(at, self.words.length())
        }
      }
      self.constant(Unit)
      for at in loop_.breaks {
        self.patch(at, self.words.length())
      }
    }
    _ => self.supported = false
  }
  self.depth -= 1
  let _ = self.emit(7U, 0)
  match expr {
    @parser.NameExpr(_, offset) | @parser.FieldExpr(_, _, offset) =>
      self.type_read(offset)
    _ => ()
  }
}

///|
fn Machine::compile_bytecode(
  self : Machine,
  mi : Int32,
  function : @parser.FunctionDeclaration,
) -> BytecodeFunction? {
  let builder : BytecodeBuilder = {
    machine: self,
    module_: mi,
    words: [],
    constants: [],
    calls: [],
    binaries: [],
    prefixes: [],
    names: [],
    kinds: [],
    mutable_slots: [],
    visits: 0,
    depth: 0,
    supported: true,
    estimated_bytes: 256,
  }
  let env : Map[String, Int32] = {}
  if function.receiver is Some(_) {
    env["self"] = builder.slot(false)
  }
  for parameter in function.parameters {
    if !builder.supported {
      return None
    }
    env[parameter.name] = builder.slot(false)
  }
  builder.block(function.body, env, None)
  guard builder.supported else { return None }
  Some({
    words: FixedArray::makei(builder.words.length(), fn(i) { builder.words[i] }),
    constants: builder.constants,
    calls: builder.calls,
    binaries: builder.binaries,
    prefixes: builder.prefixes,
    names: builder.names,
    kinds: builder.kinds,
    slots: builder.mutable_slots.length(),
    estimated_bytes: builder.estimated_bytes,
  })
}

///|
fn Machine::bytecode_target(
  self : Machine,
  target : CallTarget,
  values : Array[Value],
  closure : Value,
) -> Value raise EvalError {
  let (target, frame) = unframe_call(Some(target))
  match target {
    Some(Constant(value)) => self.checked_constant(value)
    Some(Source(mi, fi, function, kind)) =>
      self.typed_value(self.source_call(mi, fi, function, values, frame~), kind)
    Some(Intrinsic(builtin_, kind)) =>
      self.typed_value(self.intrinsic(builtin_, values, result_kind=kind), kind)
    Some(Constructor(key)) => Variant(key, values)
    Some(FunctionValue(kind)) =>
      self.typed_value(self.closure_call(closure, values), kind)
    _ => eval_fail("unsupported checked bytecode call target")
  }
}

///|
fn Machine::scalar_prefix(
  self : Machine,
  op : @parser.PrefixOperator,
  value : Value,
  kind : String?,
) -> Value raise EvalError {
  let value = match kind {
    Some(kind) => {
      guard kind != "" else {
        return eval_fail(
          "prefix operation needs concrete scalar type evidence at compile time",
        )
      }
      self.typed_value(value, kind)
    }
    None => value
  }
  match (op, value) {
    (@parser.LogicalNot, DefaultValue) => Boolean(true)
    (@parser.LogicalNot, Boolean(value)) => Boolean(!value)
    (@parser.LogicalNot, Number(bits, "Bool")) => Boolean(bits == 0UL)
    (@parser.Negative, Number(bits, kind)) => normalized(0UL - bits, kind)
    (@parser.Positive, Number(_, _)) | (@parser.Positive, Floating(_, _)) =>
      value
    (@parser.Negative, Floating(bits, kind)) =>
      Floating(
        bits ^
        (if kind == "F32" { 2147483648UL } else { 9223372036854775808UL }),
        kind,
      )
    _ => eval_fail("unsupported prefix operator at compile time")
  }
}

///|
fn Machine::run_bytecode(
  self : Machine,
  code : BytecodeFunction,
  arguments : Array[Value],
) -> Value raise EvalError {
  let initial_depth = self.depth
  let result = self.run_bytecode_inner(code, arguments, initial_depth) catch {
    error => {
      self.depth = initial_depth
      raise error
    }
  }
  self.depth = initial_depth
  result
}

///|
fn Machine::run_bytecode_inner(
  self : Machine,
  code : BytecodeFunction,
  arguments : Array[Value],
  initial_depth : Int32,
) -> Value raise EvalError {
  guard arguments.length() <= code.slots && code.slots <= 512 else {
    return eval_fail("invalid bytecode frame layout")
  }
  let slots : FixedArray[Value] = FixedArray::make(code.slots, Unit)
  for i, value in arguments {
    slots[i] = value
  }
  let mut value = Unit
  let mut pc = 0
  while pc < code.words.length() {
    let word = code.words[pc]
    pc += 1
    let op = word & 255U
    let arg = (word >> 8).to_int()
    match op {
      1U => value = code.constants[arg]
      2U => value = slots[arg]
      3U => slots[arg] = value
      4U => {
        let selected = code.binaries[arg]
        let left = slots[selected.left]
        if !raw_bool_operator_body(selected.target, left, value) &&
          selected.opcode is Some(opcode) &&
          (
            opcode == b"primitive" ||
            opcode == scalar_opcode(selected.operator, left)
          ) {
          value = binary(operation(selected.operator), left, value)
        } else if selected.target is Some(target) {
          let (target, frame) = unframe_call(Some(target))
          guard target is Some(Source(mi, fi, function, kind)) else {
            return eval_fail(
              "selected operator has no supported compile-time source body",
            )
          }
          value = self.typed_value(
            self.source_call(mi, fi, function, [left, value], frame~),
            kind,
          )
        } else {
          return eval_fail(
            "selected operator has no supported compile-time source body",
          )
        }
      }
      5U => self.charge(arg)
      6U => {
        self.charge(16)
        guard self.depth < 128 else {
          return eval_fail("transform depth limit exceeded")
        }
        self.depth += 1
      }
      7U => {
        guard self.depth > initial_depth else {
          return eval_fail("unbalanced bytecode expression depth")
        }
        self.depth -= 1
      }
      8U => pc = arg
      9U => if !truth(value) { pc = arg }
      10U => if truth(value) { pc = arg }
      11U => {
        let selected = code.calls[arg]
        let values = selected.arguments.map(fn(slot) { slots[slot] })
        let closure = match selected.callee {
          Some(slot) => slots[slot]
          None => Unit
        }
        value = self.bytecode_target(selected.target, values, closure)
      }
      12U => value = self.typed_value(value, code.kinds[arg])
      13U => {
        let (operator, kind) = code.prefixes[arg]
        value = self.scalar_prefix(operator, value, kind)
      }
      14U => value = self.read_field(value, code.names[arg])
      15U => {
        guard pc < code.words.length() else {
          return eval_fail("truncated bytecode field write")
        }
        let owner = (code.words[pc] >> 8).to_int()
        pc += 1
        self.write_field(slots[owner], code.names[arg], value)
      }
      16U => raise Returned(value)
      17U => self.depth = initial_depth + arg
      18U => value = Boolean(truth(value))
      19U => {
        self.charge(16)
        guard self.depth < 128 else {
          return eval_fail("transform depth limit exceeded")
        }
      }
      20U => value = Boolean(equal(value, slots[arg]))
      _ => return eval_fail("invalid bytecode instruction")
    }
  }
  guard self.depth == initial_depth else {
    return eval_fail("unbalanced bytecode expression depth")
  }
  value
}

///|
fn Machine::source_body(
  self : Machine,
  mi : Int32,
  function : @parser.FunctionDeclaration,
  args : Array[Value],
) -> Value raise EvalError {
  if self.bytecode_enabled {
    let cache = match self.bytecode.get(self.frame) {
      Some(cache) => cache
      None => {
        if self.bytecode_bytes_left < 384 {
          return self.tree_source_body(mi, function, args)
        }
        self.bytecode_bytes_left -= 256
        let cache = Map::new()
        self.bytecode[self.frame] = cache
        cache
      }
    }
    let key = (mi, self.file_index, function.offset.to_int())
    let code = match cache.get(key) {
      Some(code) => code
      None => {
        if self.bytecode_bytes_left < 128 {
          return self.tree_source_body(mi, function, args)
        }
        self.bytecode_bytes_left -= 128
        let candidate = if self.bytecode_bytes_left >= 256 &&
          self.bytecode_compile_work > 0 {
          self.compile_bytecode(mi, function)
        } else {
          None
        }
        let code = match candidate {
          Some(code) if code.estimated_bytes <= self.bytecode_bytes_left => {
            self.bytecode_bytes_left -= code.estimated_bytes
            Some(code)
          }
          _ => None
        }
        cache[key] = code
        code
      }
    }
    if code is Some(code) {
      return self.run_bytecode(code, args)
    }
  }
  self.tree_source_body(mi, function, args)
}

///|
fn Machine::tree_source_body(
  self : Machine,
  mi : Int32,
  function : @parser.FunctionDeclaration,
  args : Array[Value],
) -> Value raise EvalError {
  let env : Map[String, Cell] = Map::new()
  let receiver_count = if function.receiver is Some(_) { 1 } else { 0 }
  if receiver_count == 1 {
    env["self"] = { value: args[0], mutable_: false, }
  }
  for i, parameter in function.parameters {
    env[parameter.name] = { value: args[i + receiver_count], mutable_: false, }
  }
  self.block(mi, function.body, env)
}
