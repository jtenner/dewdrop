///|
pub(all) struct SourceFile {
  path : String
  source : Bytes
}

///|
pub(all) struct SourceModule {
  path : String
  files : Array[SourceFile]
}

///|
struct Annotation {
  arguments : Array[@parser.Expr]
  arguments_source : String
  arguments_offset : Int32
  name : String
  offset : Int32
  target : Int32
  line_no : UInt64
  col_no : UInt64
}

///|
struct SourceFunction {
  module_ : Int32
  file : Int32
  declaration : @parser.FunctionDeclaration
  transform : Bool
  annotation_start : Int32
  annotation_count : Int32
  start : Int32
  end : Int32
}

///|
struct ParsedFile {
  file : SourceFile
  clean : Bytes
  annotations : Array[Annotation]
  functions : Array[SourceFunction]
  declarations : Array[@parser.Declaration]
}

///|
pub struct Plan {
  modules : Array[SourceModule]
  files : Array[Array[ParsedFile]]
  active : Bool
  frames : Map[String, ExecutionFrame]
  validation_stop : String
  scalar_proofs : Map[(Int32, Int32, Int32), Bytes]
  pattern_proofs : Map[(Int32, Int32, Int32), String]
  type_names : Map[(Int32, String), String]
  references : Map[(Int32, Int32, Int32), FunctionReferenceProof]
  calls : Map[(Int32, Int32, Int32), CallTarget]
  scalar_types : Map[(Int32, Int32, Int32), String]
  array_literals : Map[(Int32, Int32, Int32), (String, Array[String])]
  array_layouts : Map[String, Array[String]]
  raw_layouts : Map[String, RawLayout]
  intrinsic_contracts : Map[String, IntrinsicContract]
  adapter_names : Map[Int32, Map[String, Bool]]
  mut signature_error : String
  validation_targets : Map[(Int32, String), (String, UInt64)]
  body_errors : Map[(Int32, Int32, Int32), String]
  signature_calls : Map[(Int32, Int32, Int32), (Int32, Int32, UInt64)]
  reports : Array[TransformReport]
  expression_types : Map[(Int32, Int32), Array[ReflectedExpressionType]]
  reflection_errors : Array[String]
  mut source_lookup : SourceIndex?
}

///|
/// Add already checked source-loader modules for name lookup and helper calls.
/// They retain the semantic program's module and file order for operator proofs.
pub fn Plan::add_checked_module(
  self : Plan,
  module_ : SourceModule,
) -> Result[Unit, String] {
  guard self.active && self.files.length() == self.modules.length() else {
    return Err(
      "checked transform modules require an active, aligned source plan",
    )
  }
  let mi = self.modules.length()
  let parsed : Array[ParsedFile] = []
  for fi, file in module_.files {
    match scan(file, mi, fi) {
      Ok(value) => parsed.push(value)
      Err(message) => return Err(file.path + ": error: " + message)
    }
  }
  self.source_lookup = None
  self.modules.push(module_)
  self.files.push(parsed)
  Ok(())
}

///|
fn text(bytes : Bytes) -> String {
  @utf8.decode_lossy(bytes)
}

///|
fn bytes(value : String) -> Bytes {
  let out = @buffer.new()
  out.write_string_utf8(value)
  out.to_bytes()
}

///|
fn part(source : Bytes, start : Int32, end : Int32) -> String {
  text(source[start:end].to_owned())
}

///|
fn blank(source : FixedArray[Byte], start : Int32, end : Int32) -> Unit {
  for i = start; i < end; i = i + 1 {
    if source[i] != b'\n' && source[i] != b'\r' {
      source[i] = b' '
    }
  }
}

///|
fn scan(
  file : SourceFile,
  module_ : Int32,
  file_index : Int32,
) -> Result[ParsedFile, String] {
  let tokens = @tokenizer.tokens(file.source).collect()
  let clean = file.source.to_fixedarray()
  let annotations : Array[Annotation] = []
  let marks : Array[Int32] = []
  let pending : Array[Annotation] = []
  let mut depth = 0
  let mut location_cursor = 0
  let mut line_no = 1UL
  let mut col_no = 1UL
  let mut i = 0
  while i < tokens.length() {
    let token = tokens[i]
    let offset = token.offset().to_int()
    match token.kind() {
      @tokenizer.Symbol(@tokenizer.LeftBrace) => depth += 1
      @tokenizer.Symbol(@tokenizer.RightBrace) => depth -= 1
      @tokenizer.Error(@tokenizer.UnexpectedUnit(35U)) if depth == 0 => {
        let mut before = offset
        while before > 0 && file.source[before - 1] != b'\n' {
          before -= 1
          guard file.source[before] == b' ' ||
            file.source[before] == b'\t' ||
            file.source[before] == b'\r' else {
            return Err("a transform annotation must occupy its own line")
          }
        }
        let start = i
        i += 1
        guard i < tokens.length() else {
          return Err("unfinished transform annotation")
        }
        let mut name = match tokens[i].kind() {
          @tokenizer.Identifier(name) => name
          @tokenizer.AtIdentifier(name) => "@" + name
          _ => return Err("expected a transform name after #")
        }
        i += 1
        if name.has_prefix("@") {
          guard i + 1 < tokens.length() &&
            tokens[i].kind() == @tokenizer.Symbol(@tokenizer.Dot) else {
            return Err("expected #@alias.transform_name")
          }
          match tokens[i + 1].kind() {
            @tokenizer.Identifier(member) => name += "." + member
            _ => return Err("expected transform name after import alias")
          }
          i += 2
        }
        let (arguments, arguments_source, arguments_offset, next) = match
          scan_annotation_arguments(file.source, tokens, i) {
          Ok(value) => value
          Err(error) => return Err(error)
        }
        i = next
        guard i == tokens.length() || tokens[i].kind() == @tokenizer.Newline else {
          return Err("a transform annotation must occupy its own line")
        }
        let end = if i < tokens.length() {
          tokens[i].offset().to_int()
        } else {
          clean.length()
        }
        blank(clean, tokens[start].offset().to_int(), end)
        while location_cursor < offset {
          if file.source[location_cursor] == b'\n' {
            line_no += 1UL
            col_no = 1UL
          } else {
            col_no += 1UL
          }
          location_cursor += 1
        }
        pending.push({
          name,
          offset,
          target: 0,
          line_no,
          col_no,
          arguments,
          arguments_source,
          arguments_offset,
        })
        continue
      }
      @tokenizer.Identifier("transform") if depth == 0 &&
        i + 1 < tokens.length() &&
        tokens[i + 1].kind() == @tokenizer.Keyword(@tokenizer.Fn) => {
        guard i + 1 < tokens.length() &&
          tokens[i + 1].kind() == @tokenizer.Keyword(@tokenizer.Fn) else {
          return Err("expected fn after transform")
        }
        guard pending.is_empty() else {
          return Err("a transform cannot itself have a transform annotation")
        }
        marks.push(tokens[i + 1].offset().to_int())
        blank(clean, offset, offset + 9)
      }
      @tokenizer.Keyword(@tokenizer.Fn) if depth == 0 => {
        for annotation in pending {
          annotations.push({ ..annotation, target: offset, })
        }
        pending.clear()
      }
      @tokenizer.Newline | @tokenizer.Keyword(@tokenizer.Pub) => ()
      _ if depth == 0 && !pending.is_empty() =>
        return Err("transforms can only be applied to functions")
      _ => ()
    }
    i += 1
  }
  guard pending.is_empty() else {
    return Err("transform annotation has no function")
  }
  let declarations : Array[@parser.Declaration] = []
  let functions : Array[SourceFunction] = []
  let clean = Bytes::from_fixedarray(clean)
  let mut token_cursor = 0
  let mut annotation_cursor = 0
  let mut mark_cursor = 0
  for event in @parser.parse_bytes(clean) {
    match event {
      @parser.Diagnostic(error) =>
        return Err(
          "invalid transform source: " +
          "parse error at byte " +
          error.error.offset().to_string(),
        )
      @parser.Declaration(declaration) => {
        declarations.push(declaration)
        if declaration is @parser.Function(fn_) {
          let body = fn_.body.offset.to_int()
          let mut nesting = 0
          let mut end = body
          while token_cursor < tokens.length() {
            let t = tokens[token_cursor]
            token_cursor += 1
            if t.offset().to_int() >= body {
              match t.kind() {
                @tokenizer.Symbol(@tokenizer.LeftBrace) => nesting += 1
                @tokenizer.Symbol(@tokenizer.RightBrace) => {
                  nesting -= 1
                  if nesting == 0 {
                    end = t.offset().to_int() + 1
                    break
                  }
                }
                _ => ()
              }
            }
          }
          while mark_cursor < marks.length() &&
                marks[mark_cursor] < fn_.offset.to_int() {
            mark_cursor += 1
          }
          let is_transform = mark_cursor < marks.length() &&
            marks[mark_cursor] < fn_.name_offset.to_int()
          while mark_cursor < marks.length() &&
                marks[mark_cursor] < fn_.name_offset.to_int() {
            mark_cursor += 1
          }
          while annotation_cursor < annotations.length() &&
                annotations[annotation_cursor].target < fn_.offset.to_int() {
            annotation_cursor += 1
          }
          let annotation_start = annotation_cursor
          while annotation_cursor < annotations.length() &&
                annotations[annotation_cursor].target < fn_.name_offset.to_int() {
            annotation_cursor += 1
          }
          let annotation_count = annotation_cursor - annotation_start
          functions.push({
            module_,
            file: file_index,
            declaration: fn_,
            transform: is_transform,
            annotation_start,
            annotation_count,
            start: fn_.offset.to_int(),
            end,
          })
        }
      }
    }
  }
  Ok({ file, clean, annotations, functions, declarations, })
}

///|
pub fn contains_transform_syntax(source : Bytes) -> Bool {
  let mut depth = 0
  let mut previous_transform = false
  for token in @tokenizer.tokens(source) {
    if depth == 0 &&
      (
        token.kind() == @tokenizer.Error(@tokenizer.UnexpectedUnit(35U)) ||
        (
          previous_transform &&
          token.kind() == @tokenizer.Keyword(@tokenizer.Fn)
        )
      ) {
      return true
    }
    if token.kind() == @tokenizer.Symbol(@tokenizer.LeftBrace) {
      depth += 1
    }
    if token.kind() == @tokenizer.Symbol(@tokenizer.RightBrace) {
      depth -= 1
    }
    previous_transform = depth == 0 &&
      token.kind() == @tokenizer.Identifier("transform")
  }
  false
}

///|
pub fn transform_library_sources() -> Array[SourceModule] {
  [
    {
      path: "dewdrop.ast",
      files: [{ path: "lib/dewdrop/ast.dew", source: ast_source(), }],
    },
    {
      path: "dewdrop.transform",
      files: [
        { path: "lib/dewdrop/transform.dew", source: transform_source(), },
      ],
    },
  ]
}

///|
pub fn prepare(
  modules : Array[SourceModule],
  trusted_library_indices~ : Array[Int32] = [],
) -> Result[Plan, String] {
  // Avoid parsing the ordinary build twice. Tokens keep strings/comments inert.
  let active = modules.any(fn(module_) {
    module_.files.any(fn(file) { contains_transform_syntax(file.source) })
  })
  if !active {
    return Ok({
      modules,
      files: [],
      active,
      validation_stop: "",
      scalar_proofs: {},
      pattern_proofs: {},
      type_names: {},
      calls: {},
      scalar_types: {},
      references: {},
      array_literals: {},
      array_layouts: {},
      raw_layouts: {},
      intrinsic_contracts: {},
      frames: {},
      adapter_names: {},
      signature_error: "",
      validation_targets: {},
      body_errors: {},
      signature_calls: {},
      reports: [],
      expression_types: {},
      reflection_errors: [],
      source_lookup: None,
    })
  }
  let modules = modules.copy()
  let libraries = transform_library_sources()
  for mi, module_ in modules {
    for library in libraries {
      if module_.path == library.path {
        let mut trusted = trusted_library_indices.contains(mi) &&
          module_.files.length() == library.files.length()
        if trusted {
          for fi, file in module_.files {
            if file.path != library.files[fi].path ||
              file.source != library.files[fi].source {
              trusted = false
            }
          }
        }
        guard trusted else {
          return Err(
            "dewdrop.ast and dewdrop.transform are supplied by the compiler",
          )
        }
      }
    }
  }
  for library in libraries {
    if !modules.any(module_ => module_.path == library.path) {
      modules.push(library)
    }
  }
  let files : Array[Array[ParsedFile]] = []
  for mi, module_ in modules {
    let parsed : Array[ParsedFile] = []
    for fi, file in module_.files {
      let _ = @utf8.decode(file.source) catch {
        _ =>
          return Err(
            file.path +
            ": error: compile-time transform sources must be valid UTF-8",
          )
      }
      match scan(file, mi, fi) {
        Ok(value) => parsed.push(value)
        Err(error) => return Err(file.path + ": error: " + error)
      }
    }
    files.push(parsed)
  }
  let mut validation_stop = "__dew_transform_validation_stop"
  while modules.any(fn(module_) {
          module_.files.any(fn(file) {
            text(file.source).contains(validation_stop)
          })
        }) {
    validation_stop += "_"
  }
  Ok({
    modules,
    files,
    active,
    validation_stop,
    scalar_proofs: {},
    pattern_proofs: {},
    type_names: {},
    calls: {},
    scalar_types: {},
    references: {},
    array_literals: {},
    array_layouts: {},
    raw_layouts: {},
    intrinsic_contracts: {},
    frames: {},
    adapter_names: {},
    signature_error: "",
    validation_targets: {},
    body_errors: {},
    signature_calls: {},
    reports: [],
    expression_types: {},
    reflection_errors: [],
    source_lookup: None,
  })
}

///|
fn Plan::validation_body(self : Plan) -> String {
  "{\n " + self.validation_stop + "()\n}"
}

///|
pub fn Plan::validation_sources(self : Plan) -> Array[SourceModule] {
  if !self.active {
    return self.modules
  }
  self.modules.mapi(fn(mi, module_) {
    let files : Array[SourceFile] = []
    let checks : Array[SourceFile] = []
    for fi, file in self.files[mi] {
      let out = @buffer.new()
      let mut cursor = 0
      for function in file.functions {
        if function.annotation_count > 0 {
          out.write_bytes(file.clean[cursor:function.start])
          let removed = file.clean[function.start:function.end]
            .to_owned()
            .to_fixedarray()
          blank(removed, 0, removed.length())
          out.write_bytes(Bytes::from_fixedarray(removed))
          cursor = function.end
          let mut path = file.file.path +
            "::transform-check::" +
            function.declaration.name +
            "@" +
            function.start.to_string()
          while self.modules.any(fn(module_) {
                  module_.files.any(fn(source) { source.path == path })
                }) {
            path += "_"
          }
          let header = part(
            file.clean,
            function.start,
            function.declaration.body.offset.to_int(),
          )
          self.validation_targets[(mi, path)] = (
            file.file.path,
            function.declaration.offset,
          )
          checks.push({ path, source: bytes(header + self.validation_body()), })
        }
      }
      out.write_bytes(file.clean[cursor:])
      if fi == self.files[mi].length() - 1 {
        out.write_string_utf8(
          "\nbuiltin " +
          self.validation_stop +
          "() -> Never = \"unreachable\"\n",
        )
      }
      files.push({ path: file.file.path, source: out.to_bytes(), })
    }
    for check in checks {
      files.push(check)
    }
    { path: module_.path, files, }
  })
}
