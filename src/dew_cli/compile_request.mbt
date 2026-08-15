///|
const COMPILE_REQUEST_MAGIC : UInt = 0x44574352U

///|
const COMPILE_REQUEST_VERSION : UInt = 7U

///|
priv struct CompileRequestReader {
  bytes : Bytes
  mut offset : Int
  mut error : String?
}

///|
fn CompileRequestReader::fail(
  self : CompileRequestReader,
  message : String,
) -> Unit {
  if self.error is None {
    self.error = Some(message)
  }
}

///|
fn CompileRequestReader::read_byte(self : CompileRequestReader) -> UInt {
  if self.offset >= self.bytes.length() {
    self.fail("truncated compile request")
    return 0U
  }
  let value = self.bytes[self.offset].to_uint()
  self.offset += 1
  value
}

///|
fn CompileRequestReader::read_u32(self : CompileRequestReader) -> UInt {
  let b0 = self.read_byte()
  let b1 = self.read_byte()
  let b2 = self.read_byte()
  let b3 = self.read_byte()
  b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
}

///|
fn CompileRequestReader::read_count(
  self : CompileRequestReader,
  kind : String,
) -> Int {
  let value = self.read_u32().reinterpret_as_int()
  if value < 0 || value > 1000000 {
    self.fail("invalid \{kind} count in compile request")
    return 0
  }
  value
}

///|
fn CompileRequestReader::read_bool(
  self : CompileRequestReader,
  kind : String,
) -> Bool {
  match self.read_u32() {
    0U => false
    1U => true
    _ => {
      self.fail("invalid \{kind} flag in compile request")
      false
    }
  }
}

///|
fn CompileRequestReader::read_string(
  self : CompileRequestReader,
  kind : String,
) -> String {
  let length = self.read_count("\{kind} byte")
  if self.offset + length < self.offset ||
    self.offset + length > self.bytes.length() {
    self.fail("invalid \{kind} range in compile request")
    return ""
  }
  let output = Buffer(size_hint=length)
  for index in 0..<length {
    output.write_byte(self.bytes[self.offset + index])
  }
  self.offset += length
  @utf8.decode_lossy(output.to_bytes())
}

///|
priv struct CompileRequestModule {
  name : String
  files : Array[String]
}

///|
priv struct CompileRequestDependencyInterface {
  module_name : String
  fingerprint : String
}

///|
priv struct CompileRequestStaticLink {
  provider : String
  path : String
}

///|
priv struct CompileRequest {
  command : Int
  emit : Int
  output : String
  root_module : String
  modules : Array[CompileRequestModule]
  dependency_interfaces : Array[CompileRequestDependencyInterface]
  static_links : Array[CompileRequestStaticLink]
  standard_policy : Int
  standard_root : String
  default_preamble : Bool
  parse_event_cache : Bool
  interface_cache : Bool
  body_cache : Bool
  body_family_cache : Bool
  planning_cache : Bool
  cache_pack : Bool
  program_cache : Bool
  cache_report : Bool
  build_mode : Int
  dependency_cache_key : String
}

///|
fn parse_compile_request(bytes : Bytes) -> Result[CompileRequest, String] {
  let reader : CompileRequestReader = { bytes, offset: 0, error: None }
  if reader.read_u32() != COMPILE_REQUEST_MAGIC {
    return Err("invalid compile request magic")
  }
  if reader.read_u32() != COMPILE_REQUEST_VERSION {
    return Err("unsupported compile request version")
  }
  let command = reader.read_u32().reinterpret_as_int()
  if command < 0 || command > 1 {
    reader.fail("invalid compile request command")
  }
  let emit = reader.read_u32().reinterpret_as_int()
  if emit < 0 || emit > 2 {
    reader.fail("invalid compile request output kind")
  }
  let output = reader.read_string("output path")
  let root_module = reader.read_string("root module")
  let modules : Array[CompileRequestModule] = []
  let module_count = reader.read_count("module")
  for _ in 0..<module_count {
    let name = reader.read_string("module name")
    let files : Array[String] = []
    let file_count = reader.read_count("module file")
    for _ in 0..<file_count {
      files.push(reader.read_string("source path"))
    }
    modules.push({ name, files })
  }
  let dependency_interfaces : Array[CompileRequestDependencyInterface] = []
  let dependency_count = reader.read_count("dependency interface")
  for _ in 0..<dependency_count {
    dependency_interfaces.push({
      module_name: reader.read_string("dependency module"),
      fingerprint: reader.read_string("dependency fingerprint"),
    })
  }
  let static_links : Array[CompileRequestStaticLink] = []
  let static_link_count = reader.read_count("static link")
  for _ in 0..<static_link_count {
    static_links.push({
      provider: reader.read_string("static-link provider"),
      path: reader.read_string("static-link module path"),
    })
  }
  let standard_policy = reader.read_u32().reinterpret_as_int()
  if standard_policy < 0 || standard_policy > 1 {
    reader.fail("invalid standard-library policy in compile request")
  }
  let standard_root = reader.read_string("standard-library root")
  let default_preamble = reader.read_bool("default preamble")
  let parse_event_cache = reader.read_bool("parse event cache")
  let interface_cache = reader.read_bool("interface cache")
  let body_cache = reader.read_bool("body inference cache")
  let body_family_cache = reader.read_bool("body-family inference cache")
  let planning_cache = reader.read_bool("layout and fragment planning cache")
  let cache_pack = reader.read_bool("compilation cache pack")
  let program_cache = reader.read_bool("exact program cache")
  let cache_report = reader.read_bool("cache report")
  let build_mode = reader.read_u32().reinterpret_as_int()
  if build_mode < 0 || build_mode > 1 {
    reader.fail("invalid build mode in compile request")
  }
  let dependency_cache_key = reader.read_string("dependency cache key")
  if reader.offset != bytes.length() {
    reader.fail("trailing bytes in compile request")
  }
  match reader.error {
    Some(error) => Err(error)
    None =>
      Ok({
        command,
        emit,
        output,
        root_module,
        modules,
        dependency_interfaces,
        static_links,
        standard_policy,
        standard_root,
        default_preamble,
        parse_event_cache,
        interface_cache,
        body_cache,
        body_family_cache,
        planning_cache,
        cache_pack,
        program_cache,
        cache_report,
        build_mode,
        dependency_cache_key,
      })
  }
}

///|
fn CompileRequest::cli_arguments(self : CompileRequest) -> Array[String] {
  ignore(self.build_mode)
  let arguments : Array[String] = [
    if self.command == 0 {
      "check"
    } else {
      "build"
    },
  ]
  if self.root_module != "" {
    arguments.push("--root")
    arguments.push(self.root_module)
  }
  if self.standard_policy == 1 {
    arguments.push("--bootstrap-std")
  } else {
    arguments.push("--std-root")
    arguments.push(self.standard_root)
  }
  if !self.default_preamble {
    arguments.push("--no-default-preamble")
  }
  if !self.parse_event_cache {
    arguments.push("--no-parse-event-cache")
  }
  if !self.interface_cache {
    arguments.push("--no-interface-cache")
  }
  if self.body_cache {
    arguments.push("--body-cache")
  } else {
    arguments.push("--no-body-cache")
  }
  if self.body_family_cache {
    arguments.push("--body-family-cache")
  }
  if self.planning_cache {
    arguments.push("--plan-cache")
  } else {
    arguments.push("--no-plan-cache")
  }
  arguments.push(
    if self.cache_pack {
      "--cache-pack"
    } else {
      "--no-cache-pack"
    },
  )
  arguments.push(
    if self.program_cache {
      "--program-cache"
    } else {
      "--no-program-cache"
    },
  )
  if self.cache_report {
    arguments.push("--cache-report")
  }
  for dependency in self.dependency_interfaces {
    arguments.push("--dependency-interface")
    arguments.push(dependency.module_name)
    arguments.push(dependency.fingerprint)
  }
  for link in self.static_links {
    arguments.push("--link-wasm")
    arguments.push(link.provider)
    arguments.push(link.path)
  }
  for module_ in self.modules {
    arguments.push("--module")
    arguments.push(module_.name)
    for file in module_.files {
      arguments.push(file)
    }
  }
  if self.command == 1 {
    arguments.push("--output")
    arguments.push(self.output)
    match self.emit {
      1 => {
        arguments.push("--emit")
        arguments.push("hir")
      }
      2 => {
        arguments.push("--emit")
        arguments.push("lowering")
      }
      _ => ()
    }
  }
  arguments
}
