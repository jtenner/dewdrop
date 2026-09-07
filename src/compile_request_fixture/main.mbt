///|
fn main {
  let args = @sys.get_cli_args()
  if args.length() != 3 {
    println("usage: compile_request_fixture REQUEST OUTPUT")
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
