///|
fn fixture(source : String) -> Plan raise {
  let plan = match
    prepare([
      { path: "app", files: [{ path: "main.dew", source: bytes(source), }], },
    ]) {
    Ok(plan) => plan
    Err(error) => {
      fail(error)
      abort("unreachable")
    }
  }
  if !plan.active {
    return plan
  }
  match
    plan.add_checked_module({
      path: "dew.std.result",
      files: [
        {
          path: "result.dew",
          source: b"pub enum Result<t, e> {\n Ok(t)\n Err(e)\n}\n",
        },
      ],
    }) {
    Ok(_) => ()
    Err(message) => fail(message)
  }
  plan.add_type_name(0, "Result", "dew.std.result::Result")
  plan
}

///|
test "transform annotation cannot follow code on the same line" {
  match
    prepare([
      {
        path: "app",
        files: [
          {
            path: "main.dew",
            source: b"fn before() -> I32 {\n 0i32\n} #replace\nfn after() -> I32 {\n 0i32\n}\n",
          },
        ],
      },
    ]) {
    Err(message) =>
      assert_true(message.contains("must occupy its own line"), msg=message)
    Ok(_) => fail("annotation after code must fail")
  }
}

///|
test "local transform executes an ordinary helper" {
  let plan = fixture(
    "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn answer() -> I32 {\n  6i32 * 7i32\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  @ast.with_body(node, @ast.integer(answer()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
  )
  for token in @tokenizer.tokens(plan.modules[0].files[0].source) {
    if token.kind() == @tokenizer.Symbol(@tokenizer.Star) {
      plan.add_scalar_proof(0, "main.dew", token.offset(), b"i32.mul")
    }
  }
  let expanded = expanded(plan)
  let source = expanded[0].files.map(fn(file) { text(file.source) }).join("\n")
  assert_true(source.contains("42i32"))
  assert_false(source.contains("fn replace"))
}

///|
test "imported public transform calls private helper" {
  let source = "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn helper() -> I32 {\n  42i32\n}\npub transform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(helper()))\n}\n"
  let plan = prepared([
    {
      path: "app",
      files: [
        {
          path: "main.dew",
          source: bytes(
            "import tools as @tools\n#@tools.replace\npub fn main() -> I32 {\n 0i32\n}\n",
          ),
        },
      ],
    },
    { path: "tools", files: [{ path: "tools.dew", source: bytes(source), }], },
  ])
  assert_true(
    expanded(plan)[0].files.any(fn(file) { text(file.source).contains("42i32") }),
  )
}

///|
test "unsupported local declarations do not fall through to imported helpers" {
  let plan = prepared([
    {
      path: "app",
      files: [
        {
          path: "main.dew",
          source: bytes(
            "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen tools\nlet helper = 7i32\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(helper()))\n}\n#replace\nfn main() -> I32 {\n 0i32\n}\n",
          ),
        },
      ],
    },
    {
      path: "tools",
      files: [
        { path: "tools.dew", source: b"pub fn helper() -> I32 {\n 42i32\n}\n", },
      ],
    },
  ])
  match plan.expand() {
    Err(error) =>
      assert_true(
        error.contains(
          "unsupported compile-time declaration shadows name: helper",
        ),
        msg=error,
      )
    Ok(_) => fail("a local declaration must shadow an imported helper")
  }
}

///|
test "generated source cannot introduce sibling declarations" {
  let plan = fixture(
    "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn bad(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.source(\"1i32\\n}\\nfn injected() -> I32 {\\n2i32\"))\n}\n#bad\nfn main() -> I32 {\n 0i32\n}\n",
  )
  assert_true(plan.expand() is Err(_))
}

///|
test "recursive transform fails with a bounded diagnostic" {
  let plan = fixture(
    "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn recurse() -> I32 {\n recurse()\n}\ntransform fn bad(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(recurse()))\n}\n#bad\nfn main() -> I32 {\n 0i32\n}\n",
  )
  match plan.expand() {
    Err(error) => assert_true(error.contains("depth limit"))
    _ => fail("recursion must fail")
  }
}

///|
fn expanded(plan : Plan) -> Array[SourceModule] raise {
  match plan.expand() {
    Ok(value) => value
    Err(error) => {
      fail(error)
      []
    }
  }
}

///|
fn prepared(modules : Array[SourceModule]) -> Plan raise {
  match prepare(modules) {
    Ok(value) => value
    Err(error) => {
      fail(error)
      abort("unreachable")
    }
  }
}

///|
test "ordinary transform names do not activate expansion" {
  let plan = fixture(
    "fn transform() -> I32 {\n  let transform = 1i32\n  transform\n}\n",
  )
  assert_false(plan.active)
}

///|
test "an endless transform stops at the work limit" {
  let plan = fixture(
    "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn spin(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n while 0i32 {\n _ => continue 0i32\n }\n node\n}\n#spin\nfn main() -> I32 {\n 0i32\n}\n",
  )
  match plan.expand() {
    Err(error) => assert_true(error.contains("transform work limit exceeded"))
    Ok(_) => fail("an endless transform must stop")
  }
}

///|
test "transform host calls are rejected" {
  let plan = fixture(
    "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nforeign import \"env\" as Host {\n pub fn ping() -> I32 = \"ping\"\n}\ntransform fn bad(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(Host.ping()))\n}\n#bad\nfn main() -> I32 {\n 0i32\n}\n",
  )
  match plan.expand() {
    Err(error) =>
      assert_true(
        error.contains(
          "compile-time calls require a direct function or enum constructor",
        ),
      )
    Ok(_) => fail("a transform must not call the host")
  }
}

///|
test "deep product patterns stop with a diagnostic" {
  let mut pattern_source = "_"
  for _ in 0..<130 {
    pattern_source = "(0i32, " + pattern_source + ")"
  }
  let plan = fixture(
    "transform fn unused(value: I32) -> I32 {\n match value {\n " +
    pattern_source +
    " => 0i32\n }\n}\n",
  )
  let machine : Machine = {
    plan,
    steps: 100_000,
    depth: 0,
    allocated: 0,
    file_index: 0,
    frame: "",
    functions: {},
    imports: {},
    globals: {},
    initializing: {},
    text_storage: {},
    memory: None,
    render_source: DefaultValue,
    render_replacement: "",
    bytecode_enabled: true,
    bytecode: {},
    bytecode_compile_work: 1048576,
    bytecode_bytes_left: 8388608,
  }
  let pattern = match plan.files[0][0].functions[0].declaration.body.items[0] {
    @parser.ExpressionItem(@parser.MatchExpr(_, arms, _), _) => arms[0].pattern
    _ => {
      fail("expected a match fixture")
      abort("unreachable")
    }
  }
  let mut value : Value = Number(0UL, "I32")
  for _ in 0..<130 {
    value = Sequence([Number(0UL, "I32"), value])
  }
  try {
    let _ = machine.pattern(0, pattern, value, {})
    fail("a deep pattern must fail")
  } catch {
    Failed(message) => assert_true(message.contains("depth limit exceeded"))
    _ => fail("pattern limit must produce a diagnostic")
  }
  assert_eq(machine.depth, 0)
}

///|
test "scope copies and name searches consume transform budgets" {
  let plan = fixture(
    "transform fn unused() -> I32 {\n 0i32\n}\nfn helper() -> I32 {\n 1i32\n}\n",
  )
  let machine : Machine = {
    plan,
    steps: 100_000,
    depth: 0,
    allocated: 4_194_300,
    file_index: 0,
    frame: "",
    functions: {},
    imports: {},
    globals: {},
    initializing: {},
    text_storage: {},
    memory: None,
    render_source: DefaultValue,
    render_replacement: "",
    bytecode_enabled: true,
    bytecode: {},
    bytecode_compile_work: 1048576,
    bytecode_bytes_left: 8388608,
  }
  let env : Map[String, Cell] = { "value": { value: Unit, mutable_: false, } }
  try {
    let _ = machine.scope(env)
    fail("a scope copy must consume the allocation budget")
  } catch {
    Failed(message) =>
      assert_true(message.contains("allocation limit exceeded"))
    _ => fail("scope budget must produce a diagnostic")
  }
  machine.allocated = 0
  machine.steps = 0
  try {
    let _ = machine.local_member(0, "helper", false)
    fail("a name search must consume the work budget")
  } catch {
    Failed(message) => assert_true(message.contains("work limit exceeded"))
    _ => fail("name search budget must produce a diagnostic")
  }
}

///|
test "many source functions retain their body end positions" {
  let source = StringBuilder::new()
  for i in 0..<1000 {
    source.write_string("fn helper" + i.to_string() + "() -> I32 {\n 0i32\n}\n")
  }
  source.write_string("transform fn unused() -> I32 {\n 0i32\n}\n")
  let plan = fixture(source.to_string())
  let file = plan.files[0][0]
  assert_eq(file.functions.length(), 1001)
  for function in file.functions {
    assert_eq(file.clean[function.end - 1], b'}')
    assert_true(function.end > function.declaration.body.offset.to_int())
  }
}

///|
test "validation keeps original helper offsets and newlines" {
  let plan = fixture(
    "transform fn replace() -> I32 {\n 0i32\n}\n#replace\nfn target() -> I32 {\n 1i32\n 2i32\n 3i32\n}\nfn helper() -> I32 {\n 42i32\n}\n",
  )
  let original = plan.files[0][0]
  let validated = plan.validation_sources()[0].files
  assert_eq(validated.length(), 2)
  for i in 0..<original.clean.length() {
    if original.clean[i] == b'\n' || original.clean[i] == b'\r' {
      assert_eq(validated[0].source[i], original.clean[i])
    }
  }
  for function in original.functions {
    if function.declaration.name == "helper" {
      assert_eq(
        validated[0].source[function.start:function.end].to_owned(),
        original.clean[function.start:function.end].to_owned(),
      )
    }
  }
  assert_true(text(validated[1].source).contains("fn target()"))
}

///|
test "invalid UTF8 strings fail instead of changing their bytes" {
  let plan = fixture(
    "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn bad(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.ExprNode::Text(\"\\xFF\"))\n}\n#bad\nfn main() -> String {\n \"ok\"\n}\n",
  )
  match plan.expand() {
    Err(error) =>
      assert_true(error.contains("non-UTF-8 string literals are not supported"))
    Ok(_) => fail("invalid UTF8 must not be replaced with a different string")
  }
}

///|
test "compile time calls cannot execute an annotated original body" {
  let plan = fixture(
    "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn answer(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(target()))\n}\n#answer\nfn target() -> I32 {\n 0i32\n}\n",
  )
  match plan.expand() {
    Err(error) =>
      assert_true(
        error.contains("annotated functions cannot execute at compile time"),
      )
    Ok(_) => fail("a transform must not execute a stale target body")
  }
}

///|
test "transform sources reject raw invalid UTF8 before source rewriting" {
  let source = b"transform fn unused() -> String {\n \"\xFF\"\n}\n"
  match prepare([{ path: "app", files: [{ path: "main.dew", source, }], }]) {
    Err(error) => {
      assert_true(error.contains("main.dew"))
      assert_true(error.contains("transform sources must be valid UTF-8"))
    }
    Ok(_) => fail("rewritten transform source must preserve valid UTF8")
  }
}

///|
test "generated source limit counts UTF-8 bytes" {
  let plan = fixture("")
  let machine : Machine = {
    plan,
    steps: 100_000,
    depth: 0,
    allocated: 0,
    file_index: 0,
    frame: "",
    functions: {},
    imports: {},
    globals: {},
    initializing: {},
    text_storage: {},
    memory: None,
    render_source: DefaultValue,
    render_replacement: "",
    bytecode_enabled: true,
    bytecode: {},
    bytecode_compile_work: 1048576,
    bytecode_bytes_left: 8388608,
  }
  let source = StringBuilder::new()
  for _ in 0..<600_000 {
    source.write_string("é")
  }
  try {
    let _ = machine.render(
      Variant("dewdrop.ast::ExprNode::Source", [Text(source.to_string())]),
      0,
    )
    fail("multi-byte source must obey the byte limit")
  } catch {
    Failed(message) => assert_true(message.contains("source size limit"))
    _ => fail("unexpected interpreter control transfer")
  }
}

///|
test "transform context exposes the original signature and location text" {
  for
    (field_, expected) in [
      ("location.file_name", "main.dew"),
      ("fn_name", "sample"),
      ("module_name", "app"),
      ("parameters_source", "(value: I32, other: Bool)"),
      ("return_type_source", "I32 "),
    ] {
    let plan = fixture(
      "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn reject(node: @ast.FnNode, ctx: @transform.TransformContext) -> Result<@ast.FnNode, @transform.TransformError> {\n Result::Err(@transform.error(ctx." +
      field_ +
      "))\n}\n#reject\nfn sample(value: I32, other: Bool) -> I32 {\n value\n}\n",
    )
    match plan.expand() {
      Err(message) =>
        assert_true(message.has_suffix(": " + expected), msg=message)
      Ok(_) => fail("context diagnostic was not returned")
    }
  }
}
