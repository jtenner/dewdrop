///|
fn source_pool_case(
  request : @compile_request.CompilerRequest,
  case : String,
) -> @compile_request.CompilerRequest {
  if case == "basic" {
    return request
  }
  let root_source = if case == "pooled-standard-transform" {
    b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn generate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.import_module(\"dew.std.map\", \"selected\")\n node.with_body(@ast.source(\"@selected.answer()\"))\n}\n#generate\npub fn main() -> I32 {\n 0i32\n}\n"
  } else if case == "explicit-standard" {
    b"import dew.std.map as @selected\npub fn main() -> I32 {\n @selected.selected_marker\n}\n"
  } else {
    b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn generate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.import_module(\"dew.std.map\", \"selected\")\n node.with_body(@ast.source(\"@selected.selected_marker\"))\n}\n#generate\npub fn main() -> I32 {\n 0i32\n}\n"
  }
  let root : @compile_request.CompilerRequestModule = {
    name: request.root_module,
    files: [{ logical_path: "src/main.dew", source: root_source, }],
  }
  let files : Array[@compile_request.CompilerRequestFile] = match case {
    "pooled-custom-path" | "explicit-standard" =>
      [
        {
          logical_path: "custom-map.dew",
          source: b"pub let selected_marker = 42i32\n",
        },
      ]
    "pooled-extra-file" =>
      [
        {
          logical_path: "std/map.dew",
          source: b"pub let marker_base = 40i32\n",
        },
        {
          logical_path: "helpers.dew",
          source: b"pub let selected_marker = 42i32\n",
        },
      ]
    "pooled-standard-transform" =>
      [
        {
          logical_path: "custom-map.dew",
          source: b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn answer() -> I32 {\n 0i32\n}\n",
        },
      ]
    _ => {
      println("unknown compile-request fixture case: \{case}")
      @sys.exit(2)
      []
    }
  }
  let selected : @compile_request.CompilerRequestModule = {
    name: "dew.std.map",
    files,
  }
  if case == "explicit-standard" {
    { ..request, modules: [selected, root], }
  } else {
    {
      ..request,
      modules: [root],
      source_pool: [
        selected,
        {
          name: "dew.std.json",
          files: [
            {
              logical_path: "unused-invalid.dew",
              source: b"\xff invalid unused pool source",
            },
          ],
        },
      ],
    }
  }
}

///|
fn main {
  let args = @sys.get_cli_args()
  if args.length() < 3 || args.length() > 4 {
    println("usage: compile_request_fixture REQUEST OUTPUT [SOURCE_POOL_CASE]")
    @sys.exit(2)
  }
  let request : @compile_request.CompilerRequest = {
    command: @compile_request.CompilerBuild,
    output_kind: @compile_request.CompilerWasmOutput,
    response: @compile_request.CompilerOutputFile(args[2]),
    root_module: "fixture.main",
    modules: [
      {
        name: "fixture.main",
        files: [
          {
            logical_path: "src/main.dew",
            source: b"pub fn main() -> I32 {\n  42\n}\n",
          },
        ],
      },
    ],
    source_pool: [],
    dependency_interfaces: [],
    static_providers: [],
    standard_library: @compile_request.CompilerBootstrapStandard(
      @compile_request.bootstrap_standard_library_identity(),
    ),
    config: {
      optimization: @compile_request.CompilerOptimized,
      diagnostics: @compile_request.CompilerTextDiagnostics,
      test_mode: false,
      default_preamble: true,
      cache_policy: @compile_request.CompilerCachesDisabled,
      cache_report: true,
    },
    compiler_fingerprint: b"compile-request-smoke-compiler-v1",
  }
  let request = source_pool_case(
    request,
    if args.length() == 4 {
      args[3]
    } else {
      "basic"
    },
  )
  let encoded = match request.encode() {
    Ok(value) => value
    Err(error) => {
      println(error)
      @sys.exit(2)
      b""
    }
  }
  @fs.write_bytes_to_file(args[1], encoded) catch {
    @fs.IOError(message) => {
      println("cannot write compile request: " + message)
      @sys.exit(2)
    }
  }
}
