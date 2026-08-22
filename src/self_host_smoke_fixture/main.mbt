///|
fn self_host_smoke_fingerprint(prefix : Bytes, provider : Bytes) -> Bytes {
  let input = Buffer(size_hint=prefix.length() + provider.length())
  input.write_bytes(prefix)
  input.write_bytes(provider)
  let digest = @cache_binary.blake3(input.to_bytes())
  let output = Buffer(size_hint=32)
  for byte in digest {
    output.write_byte(byte)
  }
  output.to_bytes()
}

///|
fn main {
  let args = @sys.get_cli_args()
  if args.length() != 5 {
    println(
      "usage: self_host_smoke_fixture REQUEST PROVIDER FINGERPRINT_PREFIX OUTPUT",
    )
    @sys.exit(2)
  }
  let provider = @fs.read_file_to_bytes(args[2]) catch {
    error => {
      println("cannot read Starshine provider: \{error}")
      @sys.exit(2)
      b""
    }
  }
  let fingerprint_prefix = @fs.read_file_to_bytes(args[3]) catch {
    error => {
      println("cannot read fingerprint prefix: \{error}")
      @sys.exit(2)
      b""
    }
  }
  let request : @compile_request.CompilerRequest = {
    command: @compile_request.CompilerBuild,
    output_kind: @compile_request.CompilerWasmOutput,
    response: @compile_request.CompilerOutputFile(args[4]),
    root_module: "fixture.main",
    modules: [
      {
        name: "fixture.main",
        files: [
          {
            logical_path: "src/main.dew",
            source: b"fn add(left: I32, right: I32) -> I32 {\n  left + right\n}\nfn twice(value: I32) -> I32 {\n  add(value, value)\n}\nfn choose(value: I32) -> I32 {\n  if value == 70 {\n    return value + 3\n  } else {\n    0\n  }\n}\npub fn main() -> I32 {\n  let value = twice(35)\n  choose(value)\n}\n",
          },
        ],
      },
    ],
    dependency_interfaces: [],
    static_providers: [{ name: "starshine", wasm: provider }],
    standard_library: @compile_request.CompilerBootstrapStandard(
      @compile_request.bootstrap_standard_library_identity(),
    ),
    config: {
      optimization: @compile_request.CompilerOptimized,
      diagnostics: @compile_request.CompilerTextDiagnostics,
      test_mode: false,
      default_preamble: true,
      cache_policy: @compile_request.CompilerCachesDisabled,
      cache_report: false,
    },
    compiler_fingerprint: self_host_smoke_fingerprint(
      fingerprint_prefix, provider,
    ),
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
    error => {
      println("cannot write self-host smoke request: \{error}")
      @sys.exit(2)
    }
  }
}
