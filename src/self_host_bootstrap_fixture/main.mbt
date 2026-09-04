///|
fn bootstrap_io_error_message(error : @fs.IOError) -> String {
  match error {
    @fs.IOError(message) => message
  }
}

///|
fn bootstrap_fingerprint(prefix : Bytes, provider : Bytes) -> Bytes {
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
fn standard_module_name(path : String) -> String {
  if path.has_prefix("std/preamble/") {
    return "dew.std.preamble"
  }
  let parts = path.split("/").map(part => part.to_owned()).to_array()
  let mut output = "dew.std"
  for index in 1..<parts.length() {
    let part = if index == parts.length() - 1 {
      parts[index].replace_all(old=".dew", new="")
    } else {
      parts[index]
    }
    output += "." + part
  }
  output
}

///|
fn bootstrap_module_required(name : String) -> Bool {
  match name {
    "dew.std.array"
    | "dew.std.blake3"
    | "dew.std.bytes"
    | "dew.std.bytes_builder"
    | "dew.std.facet"
    | "dew.std.facet.core"
    | "dew.std.facet.fs"
    | "dew.std.facet.imports"
    | "dew.std.facet.process"
    | "dew.std.fixed_array"
    | "dew.std.fs"
    | "dew.std.map"
    | "dew.std.math"
    | "dew.std.option"
    | "dew.std.path"
    | "dew.std.preamble"
    | "dew.std.process"
    | "dew.std.result"
    | "dew.std.string"
    | "dew.std.string_builder"
    | "dew.std.testing"
    | "dew.std.text_runtime"
    | "dew.std.wasm.intrinsics" => true
    _ => false
  }
}

///|
fn append_standard_module(
  modules : Array[@compile_request.CompilerRequestModule],
  name : String,
  path : String,
  source : Bytes,
) -> Unit {
  for index, module_ in modules {
    if module_.name == name {
      module_.files.push({ logical_path: path, source, })
      modules[index] = module_
      return
    }
  }
  let files : Array[@compile_request.CompilerRequestFile] = []
  if name != "dew.std.preamble" {
    let imports = if name == "dew.std.option" {
      b"open dew.std.preamble\n"
    } else if name == "dew.std.result" {
      b"open dew.std.preamble\nopen dew.std.option\n"
    } else if name == "dew.std.text_runtime" {
      b"open dew.std.preamble\nopen dew.std.option\n"
    } else if name == "dew.std.string" ||
      name == "dew.std.string_builder" ||
      name == "dew.std.bytes_builder" ||
      name == "dew.std.bytes" {
      b"open dew.std.preamble\nopen dew.std.text_runtime\nopen dew.std.option\n"
    } else {
      b"open dew.std.preamble\nopen dew.std.option\nopen dew.std.result\n"
    }
    files.push({ logical_path: "__dew_std_imports.dew", source: imports, })
  }
  files.push({ logical_path: path, source, })
  modules.push({ name, files, })
}

///|
fn main {
  let args = @sys.get_cli_args()
  if args.length() < 7 {
    println(
      "usage: self_host_bootstrap_fixture REQUEST PROVIDER FINGERPRINT_PREFIX OUTPUT ROOT_MODULE SOURCE...",
    )
    @sys.exit(2)
  }
  let provider = @fs.read_file_to_bytes(args[2]) catch {
    error => {
      println(
        "cannot read Starshine provider: \{bootstrap_io_error_message(error)}",
      )
      @sys.exit(2)
      b""
    }
  }
  let fingerprint_prefix = @fs.read_file_to_bytes(args[3]) catch {
    error => {
      println(
        "cannot read fingerprint prefix: \{bootstrap_io_error_message(error)}",
      )
      @sys.exit(2)
      b""
    }
  }
  let modules : Array[@compile_request.CompilerRequestModule] = []
  for path in @standard_sources.standard_source_paths() {
    let name = standard_module_name(path)
    if bootstrap_module_required(name) {
      let source = match @standard_sources.bootstrap_standard_source(path) {
        Some(value) => value
        None => abort("bootstrap standard source registry is incomplete")
      }
      append_standard_module(modules, name, path, source)
    }
  }
  let root_files : Array[@compile_request.CompilerRequestFile] = []
  for index in 6..<args.length() {
    let path = args[index]
    let source = @fs.read_file_to_bytes(path) catch {
      error => {
        println(
          "cannot read compiler source \{path}: \{bootstrap_io_error_message(error)}",
        )
        @sys.exit(2)
        b""
      }
    }
    root_files.push({ logical_path: path, source, })
  }
  modules.push({ name: args[5], files: root_files, })
  let request : @compile_request.CompilerRequest = {
    command: @compile_request.CompilerBuild,
    output_kind: @compile_request.CompilerWasmOutput,
    response: @compile_request.CompilerOutputFile(args[4]),
    root_module: args[5],
    modules,
    dependency_interfaces: [],
    static_providers: [{ name: "starshine", wasm: provider, }],
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
    compiler_fingerprint: bootstrap_fingerprint(fingerprint_prefix, provider),
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
      println(
        "cannot write self-host bootstrap request: \{bootstrap_io_error_message(error)}",
      )
      @sys.exit(2)
    }
  }
}
