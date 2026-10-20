///|
pub(all) struct ReflectedType {
  kind : String
  name : String
  arguments : Array[ReflectedType]
}

///|
struct ReflectedExpressionType {
  offset : UInt64
  kind : String
  type_ : ReflectedType
}

///|
pub fn Plan::reflection_sources(self : Plan) -> Array[SourceModule] {
  self.modules.mapi(fn(mi, module_) {
    {
      path: module_.path,
      files: self.files[mi].map(fn(file) {
        { path: file.file.path, source: file.clean, }
      }),
    }
  })
}

///|
pub fn Plan::reflection_targets(
  self : Plan,
) -> Array[(Int32, String, UInt64, UInt64)] {
  let result = []
  for mi, files in self.files {
    for file in files {
      for function in file.functions {
        if function.annotation_count > 0 {
          result.push(
            (
              mi,
              file.file.path,
              function.declaration.body.offset,
              function.end.to_uint64(),
            ),
          )
        }
      }
    }
  }
  result
}

///|
pub fn Plan::add_expression_type(
  self : Plan,
  mi : Int32,
  path : String,
  offset : UInt64,
  kind : String,
  type_ : ReflectedType,
) -> Unit {
  guard mi >= 0 && mi < self.files.length() else {
    abort("reflected expression lost its module")
  }
  for fi, file in self.files[mi] {
    if file.file.path == path {
      let entries = self.expression_types.get_or_init((mi, fi), fn() { [] })
      guard entries.is_empty() || entries[entries.length() - 1].offset <= offset else {
        abort("reflected expressions must be in source order")
      }
      entries.push({ offset, kind, type_, })
      return
    }
  }
  abort("reflected expression lost its source file")
}

///|
pub fn Plan::set_reflection_error(self : Plan, message : String) -> Unit {
  self.reflection_errors.push(message)
}

///|
fn Machine::reflected_type(
  self : Machine,
  type_ : ReflectedType,
  depth : Int32,
) -> Value raise EvalError {
  guard depth < 128 else { raise Failed("reflected type depth limit exceeded") }
  self.charge(64 + bytes(type_.kind).length() + bytes(type_.name).length())
  record("dewdrop.ast::TypeNode", [
    ("kind", Text(type_.kind)),
    ("name", Text(type_.name)),
    (
      "arguments",
      self.syntax_values(
        type_.arguments.map(fn(value) { self.reflected_type(value, depth + 1) }),
      ),
    ),
  ])
}

///|
fn Machine::expression_type_nodes(
  self : Machine,
  function : SourceFunction,
) -> Value raise EvalError {
  self.charge(0)
  let result = []
  if self.plan.expression_types.get((function.module_, function.file))
    is Some(entries) {
    let mut low = 0
    let mut high = entries.length()
    while low < high {
      let middle = low + (high - low) / 2
      if entries[middle].offset < function.declaration.body.offset {
        low = middle + 1
      } else {
        high = middle
      }
    }
    for index in low..<entries.length() {
      let entry = entries[index]
      if entry.offset >= function.end.to_uint64() {
        break
      }
      self.charge(64)
      result.push(
        record("dewdrop.ast::ExpressionTypeNode", [
          ("offset", Number(entry.offset, "U32")),
          ("kind", Text(entry.kind)),
          ("type_", self.reflected_type(entry.type_, 0)),
        ]),
      )
    }
  }
  self.syntax_values(result)
}

///|
fn Machine::reflection_errors(self : Machine) -> Value raise EvalError {
  let values = []
  for message in self.plan.reflection_errors {
    // Compiler diagnostics are immutable metadata. Charge the value wrapper;
    // reading their bytes uses the normal text storage charge.
    self.charge(16)
    values.push(Text(message))
  }
  self.syntax_values(values)
}
