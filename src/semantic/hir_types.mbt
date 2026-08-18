///|
/// Module-local index into `CollectedModule.type_syntax`.
pub type HirTypeId = Int

///|
pub struct HirSpan {
  start : Int
  length : Int
} derive(Eq, Debug, ToJson, FromJson)

///|
fn empty_hir_span(at : Int) -> HirSpan {
  { start: at, length: 0 }
}

///|
pub enum HirTypeSyntax {
  NamedTypeSyntax(NameId, UInt64)
  QualifiedTypeSyntax(NameId, NameId, UInt64, UInt64)
  ProductTypeSyntax(HirSpan, UInt64)
  AppliedTypeSyntax(HirTypeId, HirSpan, UInt64)
  FunctionTypeSyntax(HirSpan, HirTypeId, UInt64)
} derive(Eq, Debug)

///|
pub fn HirTypeSyntax::offset(self : HirTypeSyntax) -> UInt64 {
  match self {
    NamedTypeSyntax(_, offset)
    | QualifiedTypeSyntax(_, _, offset, _)
    | ProductTypeSyntax(_, offset)
    | AppliedTypeSyntax(_, _, offset)
    | FunctionTypeSyntax(_, _, offset) => offset
  }
}

///|
/// Lowers one recursive parser type into flat module-local arenas without
/// recursive host-language calls. Child types are emitted before their parent.
fn CollectionBuilder::lower_type(
  self : CollectionBuilder,
  root : @parser.TypeExpr,
) -> HirTypeId {
  let sources = self.type_source_scratch
  let states = self.type_state_scratch
  let result_starts = self.type_result_start_scratch
  let results = self.type_result_scratch
  sources.clear()
  states.clear()
  result_starts.clear()
  results.clear()
  sources.push(root)
  states.push(0)
  result_starts.push(0)
  while sources.length() > 0 {
    let source = sources.pop().unwrap()
    let state = states.pop().unwrap()
    let result_start = result_starts.pop().unwrap()
    if state == 0 {
      match source {
        @parser.NamedType(name, offset) => {
          let id = self.type_syntax.length()
          self.type_syntax.push(NamedTypeSyntax(self.intern(name), offset))
          self.type_syntax_files.push(self.current_file)
          results.push(id)
        }
        @parser.QualifiedType(module_alias, name, offset, name_offset) => {
          let id = self.type_syntax.length()
          self.type_syntax.push(
            QualifiedTypeSyntax(
              self.intern(module_alias),
              self.intern(name),
              offset,
              name_offset,
            ),
          )
          self.type_syntax_files.push(self.current_file)
          results.push(id)
        }
        @parser.ProductType(fields, _) => {
          sources.push(source)
          states.push(1)
          result_starts.push(results.length())
          let mut index = fields.length()
          while index > 0 {
            index -= 1
            sources.push(fields[index])
            states.push(0)
            result_starts.push(0)
          }
        }
        @parser.AppliedType(base, arguments, _) => {
          sources.push(source)
          states.push(1)
          result_starts.push(results.length())
          let mut index = arguments.length()
          while index > 0 {
            index -= 1
            sources.push(arguments[index])
            states.push(0)
            result_starts.push(0)
          }
          sources.push(base)
          states.push(0)
          result_starts.push(0)
        }
        @parser.FunctionType(parameters, result, _) => {
          sources.push(source)
          states.push(1)
          result_starts.push(results.length())
          sources.push(result)
          states.push(0)
          result_starts.push(0)
          let mut index = parameters.length()
          while index > 0 {
            index -= 1
            sources.push(parameters[index])
            states.push(0)
            result_starts.push(0)
          }
        }
      }
    } else {
      match source {
        @parser.ProductType(fields, offset) => {
          let field_start = self.type_arguments.length()
          for index in 0..<fields.length() {
            self.type_arguments.push(results[result_start + index])
          }
          let id = self.type_syntax.length()
          self.type_syntax.push(
            ProductTypeSyntax(
              { start: field_start, length: fields.length() },
              offset,
            ),
          )
          self.type_syntax_files.push(self.current_file)
          results.truncate(result_start)
          results.push(id)
        }
        @parser.AppliedType(_, arguments, offset) => {
          let base = results[result_start]
          let argument_start = self.type_arguments.length()
          for index in 0..<arguments.length() {
            self.type_arguments.push(results[result_start + index + 1])
          }
          let id = self.type_syntax.length()
          self.type_syntax.push(
            AppliedTypeSyntax(
              base,
              { start: argument_start, length: arguments.length() },
              offset,
            ),
          )
          self.type_syntax_files.push(self.current_file)
          results.truncate(result_start)
          results.push(id)
        }
        @parser.FunctionType(parameters, _, offset) => {
          let parameter_start = self.type_arguments.length()
          for index in 0..<parameters.length() {
            self.type_arguments.push(results[result_start + index])
          }
          let result = results[result_start + parameters.length()]
          let id = self.type_syntax.length()
          self.type_syntax.push(
            FunctionTypeSyntax(
              { start: parameter_start, length: parameters.length() },
              result,
              offset,
            ),
          )
          self.type_syntax_files.push(self.current_file)
          results.truncate(result_start)
          results.push(id)
        }
        @parser.NamedType(_, _) | @parser.QualifiedType(_, _, _, _) =>
          abort("invalid named-type lowering state")
      }
    }
  }
  guard results.length() == 1 else { abort("invalid type lowering result") }
  results[0]
}

///|
fn CollectionBuilder::lower_type_list(
  self : CollectionBuilder,
  source : Array[@parser.TypeExpr],
) -> HirSpan {
  let lowered = self.type_list_scratch
  lowered.clear()
  for type_ in source {
    lowered.push(self.lower_type(type_))
  }
  let start = self.type_arguments.length()
  for type_ in lowered {
    self.type_arguments.push(type_)
  }
  { start, length: lowered.length() }
}
