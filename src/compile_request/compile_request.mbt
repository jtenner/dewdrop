///|
const COMPILER_REQUEST_MAGIC : UInt = 0x44574352U

///|
const COMPILER_REQUEST_VERSION : UInt = 1U

///|
pub fn max_request_bytes() -> Int {
  256 * 1024 * 1024
}

///|
pub fn max_module_count() -> Int {
  1024
}

///|
pub fn max_files_per_module() -> Int {
  4096
}

///|
pub fn max_total_files() -> Int {
  65536
}

///|
pub fn max_source_bytes() -> Int {
  16 * 1024 * 1024
}

///|
pub fn max_dependency_count() -> Int {
  4096
}

///|
pub fn max_provider_count() -> Int {
  64
}

///|
pub fn max_provider_bytes() -> Int {
  64 * 1024 * 1024
}

///|
pub fn max_name_bytes() -> Int {
  255
}

///|
pub fn max_path_bytes() -> Int {
  4096
}

///|
pub fn max_compiler_fingerprint_bytes() -> Int {
  4096
}

///|
pub(all) enum CompilerRequestCommand {
  CompilerCheck
  CompilerBuild
} derive(Eq, Debug)

///|
pub(all) enum CompilerRequestOutputKind {
  CompilerWasmOutput
  CompilerHirOutput
  CompilerLoweringOutput
} derive(Eq, Debug)

///|
pub(all) enum CompilerRequestResponseMode {
  CompilerStatusOnly
  CompilerOutputFile(String)
} derive(Eq, Debug)

///|
pub(all) enum CompilerOptimizationMode {
  CompilerOptimized
} derive(Eq, Debug)

///|
pub(all) enum CompilerDiagnosticsMode {
  CompilerTextDiagnostics
} derive(Eq, Debug)

///|
pub(all) enum CompilerCachePolicy {
  CompilerCachesDisabled
} derive(Eq, Debug)

///|
pub(all) struct CompilerSessionConfig {
  optimization : CompilerOptimizationMode
  diagnostics : CompilerDiagnosticsMode
  test_mode : Bool
  default_preamble : Bool
  cache_policy : CompilerCachePolicy
  cache_report : Bool
} derive(Eq, Debug)

///|
pub(all) struct CompilerRequestFile {
  logical_path : String
  source : Bytes
} derive(Eq, Debug)

///|
pub(all) struct CompilerRequestModule {
  name : String
  files : Array[CompilerRequestFile]
} derive(Eq, Debug)

///|
pub(all) struct CompilerRequestDependencyInterface {
  module_name : String
  fingerprint : String
} derive(Eq, Debug)

///|
pub(all) struct CompilerRequestStaticProvider {
  name : String
  wasm : Bytes
} derive(Eq, Debug)

///|
pub(all) enum CompilerRequestStandardLibrary {
  CompilerBootstrapStandard(Bytes)
} derive(Eq, Debug)

///|
pub(all) struct CompilerRequest {
  command : CompilerRequestCommand
  output_kind : CompilerRequestOutputKind
  response : CompilerRequestResponseMode
  root_module : String
  modules : Array[CompilerRequestModule]
  dependency_interfaces : Array[CompilerRequestDependencyInterface]
  static_providers : Array[CompilerRequestStaticProvider]
  standard_library : CompilerRequestStandardLibrary
  config : CompilerSessionConfig
  compiler_fingerprint : Bytes
} derive(Eq, Debug)

///|
priv struct CompilerRequestReader {
  bytes : Bytes
  mut offset : Int
  mut error : String?
}

///|
fn CompilerRequestReader::fail(
  self : CompilerRequestReader,
  message : String,
) -> Unit {
  if self.error is None {
    self.error = Some(message)
  }
}

///|
fn CompilerRequestReader::read_byte(self : CompilerRequestReader) -> UInt {
  if self.offset >= self.bytes.length() {
    self.fail("truncated compile request")
    return 0U
  }
  let value = self.bytes[self.offset].to_uint()
  self.offset += 1
  value
}

///|
fn CompilerRequestReader::read_u32(self : CompilerRequestReader) -> UInt {
  let b0 = self.read_byte()
  let b1 = self.read_byte()
  let b2 = self.read_byte()
  let b3 = self.read_byte()
  b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
}

///|
fn CompilerRequestReader::read_count(
  self : CompilerRequestReader,
  kind : String,
  maximum : Int,
) -> Int {
  let value = self.read_u32().reinterpret_as_int()
  if value < 0 || value > maximum {
    self.fail("invalid \{kind} count in compile request")
    0
  } else {
    value
  }
}

///|
fn CompilerRequestReader::read_tag(
  self : CompilerRequestReader,
  kind : String,
  maximum : Int,
) -> Int {
  let value = self.read_u32().reinterpret_as_int()
  if value < 0 || value > maximum {
    self.fail("invalid \{kind} tag in compile request")
    0
  } else {
    value
  }
}

///|
fn CompilerRequestReader::read_bool(
  self : CompilerRequestReader,
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
fn CompilerRequestReader::read_bytes(
  self : CompilerRequestReader,
  kind : String,
  maximum : Int,
) -> Bytes {
  let length = self.read_count("\{kind} byte", maximum)
  if self.offset > self.bytes.length() - length {
    self.fail("invalid \{kind} range in compile request")
    b""
  } else {
    let output = Buffer(size_hint=length)
    for index in 0..<length {
      output.write_byte(self.bytes[self.offset + index])
    }
    self.offset += length
    output.to_bytes()
  }
}

///|
fn CompilerRequestReader::read_string(
  self : CompilerRequestReader,
  kind : String,
  maximum : Int,
) -> String {
  let bytes = self.read_bytes(kind, maximum)
  @utf8.decode(bytes) catch {
    _ => {
      self.fail("invalid UTF-8 in compile request \{kind}")
      ""
    }
  }
}

///|
fn compiler_request_write_u32(output : Buffer, value : UInt) -> Unit {
  output.write_byte((value & 0xffU).to_byte())
  output.write_byte(((value >> 8) & 0xffU).to_byte())
  output.write_byte(((value >> 16) & 0xffU).to_byte())
  output.write_byte(((value >> 24) & 0xffU).to_byte())
}

///|
fn compiler_request_write_bytes(output : Buffer, value : Bytes) -> Unit {
  compiler_request_write_u32(output, value.length().reinterpret_as_uint())
  output.write_bytes(value)
}

///|
fn compiler_request_write_string(output : Buffer, value : String) -> Unit {
  compiler_request_write_bytes(output, @utf8.encode(value))
}

///|
fn compiler_request_string_size(
  value : String,
  maximum : Int,
  kind : String,
  allow_empty : Bool,
) -> Result[Int, String] {
  let bytes = @utf8.encode(value)
  if !allow_empty && bytes.length() == 0 {
    Err("compile request \{kind} must not be empty")
  } else if bytes.length() > maximum {
    Err("compile request \{kind} exceeds \{maximum} bytes")
  } else if value.contains("\u0000") {
    Err("compile request \{kind} contains NUL")
  } else {
    Ok(bytes.length())
  }
}

///|
fn compiler_request_logical_path_valid(value : String) -> Bool {
  value != "" &&
  !value.has_prefix("/") &&
  !value.has_prefix("./") &&
  !value.contains("\\") &&
  !value.contains("//") &&
  !value.contains("/./") &&
  !value.has_suffix("/.") &&
  value != ".." &&
  !value.has_prefix("../") &&
  !value.contains("/../") &&
  !value.has_suffix("/..") &&
  !value.contains("\u0000")
}

///|
fn compiler_request_fingerprint_valid(value : String) -> Bool {
  if @utf8.encode(value).length() != 64 {
    return false
  }
  for character in value {
    if !(character >= '0' && character <= '9') &&
      !(character >= 'a' && character <= 'f') {
      return false
    }
  }
  true
}

///|
fn compiler_request_add_payload(
  total : Int,
  size : Int,
  kind : String,
) -> Result[Int, String] {
  if size < 0 || total > max_request_bytes() - size {
    Err("compile request \{kind} exceeds total request bound")
  } else {
    Ok(total + size)
  }
}

///|
fn compiler_request_bounded_size_add(total : Int, size : Int) -> Int {
  if size < 0 || total > max_request_bytes() - size {
    max_request_bytes() + 1
  } else {
    total + size
  }
}

///|
fn compiler_request_encoded_size(request : CompilerRequest) -> Int {
  let mut total = 104
  match request.response {
    CompilerStatusOnly => ()
    CompilerOutputFile(path) =>
      total = compiler_request_bounded_size_add(
        total,
        4 + @utf8.encode(path).length(),
      )
  }
  total = compiler_request_bounded_size_add(
    total,
    @utf8.encode(request.root_module).length(),
  )
  for module_ in request.modules {
    total = compiler_request_bounded_size_add(
      total,
      8 + @utf8.encode(module_.name).length(),
    )
    for file in module_.files {
      total = compiler_request_bounded_size_add(
        total,
        8 + @utf8.encode(file.logical_path).length() + file.source.length(),
      )
    }
  }
  for dependency in request.dependency_interfaces {
    total = compiler_request_bounded_size_add(
      total,
      8 +
      @utf8.encode(dependency.module_name).length() +
      @utf8.encode(dependency.fingerprint).length(),
    )
  }
  for provider in request.static_providers {
    total = compiler_request_bounded_size_add(
      total,
      8 + @utf8.encode(provider.name).length() + provider.wasm.length(),
    )
  }
  compiler_request_bounded_size_add(
    total,
    request.compiler_fingerprint.length(),
  )
}

///|
pub fn CompilerRequest::validate(
  self : CompilerRequest,
) -> Result[Unit, String] {
  match self.command {
    CompilerCheck => {
      if self.output_kind != CompilerWasmOutput {
        return Err("compile request check command requires Wasm output kind")
      }
      if self.response != CompilerStatusOnly {
        return Err(
          "compile request check command requires status-only response",
        )
      }
    }
    CompilerBuild =>
      match self.response {
        CompilerStatusOnly =>
          return Err("compile request build command requires an output file")
        CompilerOutputFile(path) =>
          match
            compiler_request_string_size(
              path,
              max_path_bytes(),
              "output path",
              false,
            ) {
            Err(error) => return Err(error)
            Ok(_) => ()
          }
      }
  }
  match
    compiler_request_string_size(
      self.root_module,
      max_name_bytes(),
      "root module",
      false,
    ) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  if self.modules.length() == 0 || self.modules.length() > max_module_count() {
    return Err("compile request module count is outside its bound")
  }
  let module_names : Map[String, Bool] = Map::default()
  let mut total_files = 0
  let mut total_payload = 0
  for module_ in self.modules {
    match
      compiler_request_string_size(
        module_.name,
        max_name_bytes(),
        "module name",
        false,
      ) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
    if module_names.contains(module_.name) {
      return Err("compile request has duplicate module \{module_.name}")
    }
    module_names[module_.name] = true
    if module_.files.length() == 0 ||
      module_.files.length() > max_files_per_module() {
      return Err("compile request file count is outside its bound")
    }
    if total_files > max_total_files() - module_.files.length() {
      return Err("compile request total file count exceeds its bound")
    }
    total_files += module_.files.length()
    let file_paths : Map[String, Bool] = Map::default()
    for file in module_.files {
      match
        compiler_request_string_size(
          file.logical_path,
          max_path_bytes(),
          "logical path",
          false,
        ) {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
      if !compiler_request_logical_path_valid(file.logical_path) {
        return Err(
          "compile request logical path is not relative and normalized",
        )
      }
      if file_paths.contains(file.logical_path) {
        return Err(
          "compile request has duplicate file \{module_.name}:\{file.logical_path}",
        )
      }
      file_paths[file.logical_path] = true
      if file.source.length() > max_source_bytes() {
        return Err("compile request source exceeds its byte bound")
      }
      total_payload = match
        compiler_request_add_payload(
          total_payload,
          file.source.length(),
          "source payload",
        ) {
        Err(error) => return Err(error)
        Ok(value) => value
      }
    }
  }
  if !module_names.contains(self.root_module) {
    return Err("compile request root module is not present")
  }
  if self.dependency_interfaces.length() > max_dependency_count() {
    return Err("compile request dependency count exceeds its bound")
  }
  let dependencies : Map[String, Bool] = Map::default()
  for dependency in self.dependency_interfaces {
    match
      compiler_request_string_size(
        dependency.module_name,
        max_name_bytes(),
        "dependency module",
        false,
      ) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
    if dependencies.contains(dependency.module_name) {
      return Err(
        "compile request has duplicate dependency interface \{dependency.module_name}",
      )
    }
    dependencies[dependency.module_name] = true
    if !compiler_request_fingerprint_valid(dependency.fingerprint) {
      return Err(
        "compile request dependency fingerprint must be 64 lowercase hexadecimal bytes",
      )
    }
  }
  if self.static_providers.length() > max_provider_count() {
    return Err("compile request provider count exceeds its bound")
  }
  let providers : Map[String, Bool] = Map::default()
  for provider in self.static_providers {
    match
      compiler_request_string_size(
        provider.name,
        max_name_bytes(),
        "provider name",
        false,
      ) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
    if provider.name.contains(":") {
      return Err("compile request provider must be a simple name")
    }
    if providers.contains(provider.name) {
      return Err("compile request has duplicate provider \{provider.name}")
    }
    providers[provider.name] = true
    if provider.wasm.length() > max_provider_bytes() {
      return Err("compile request provider exceeds its byte bound")
    }
    total_payload = match
      compiler_request_add_payload(
        total_payload,
        provider.wasm.length(),
        "provider payload",
      ) {
      Err(error) => return Err(error)
      Ok(value) => value
    }
  }
  match self.standard_library {
    CompilerBootstrapStandard(identity) =>
      if identity.length() != 32 {
        return Err(
          "compile request bootstrap standard identity must be 32 bytes",
        )
      }
  }
  if self.compiler_fingerprint.length() == 0 ||
    self.compiler_fingerprint.length() > max_compiler_fingerprint_bytes() {
    return Err("compile request compiler fingerprint is outside its byte bound")
  }
  total_payload = match
    compiler_request_add_payload(
      total_payload,
      self.compiler_fingerprint.length(),
      "compiler fingerprint",
    ) {
    Err(error) => return Err(error)
    Ok(value) => value
  }
  ignore(total_payload)
  match self.config.optimization {
    CompilerOptimized => ()
  }
  match self.config.diagnostics {
    CompilerTextDiagnostics => ()
  }
  match self.config.cache_policy {
    CompilerCachesDisabled => ()
  }
  if compiler_request_encoded_size(self) > max_request_bytes() {
    Err("compile request exceeds total request byte bound")
  } else {
    Ok(())
  }
}

///|
pub fn CompilerRequest::encode(self : CompilerRequest) -> Result[Bytes, String] {
  match self.validate() {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let output = Buffer()
  compiler_request_write_u32(output, COMPILER_REQUEST_MAGIC)
  compiler_request_write_u32(output, COMPILER_REQUEST_VERSION)
  compiler_request_write_u32(
    output,
    match self.command {
      CompilerCheck => 0U
      CompilerBuild => 1U
    },
  )
  compiler_request_write_u32(
    output,
    match self.output_kind {
      CompilerWasmOutput => 0U
      CompilerHirOutput => 1U
      CompilerLoweringOutput => 2U
    },
  )
  match self.response {
    CompilerStatusOnly => compiler_request_write_u32(output, 0U)
    CompilerOutputFile(path) => {
      compiler_request_write_u32(output, 1U)
      compiler_request_write_string(output, path)
    }
  }
  compiler_request_write_string(output, self.root_module)
  compiler_request_write_u32(
    output,
    self.modules.length().reinterpret_as_uint(),
  )
  for module_ in self.modules {
    compiler_request_write_string(output, module_.name)
    compiler_request_write_u32(
      output,
      module_.files.length().reinterpret_as_uint(),
    )
    for file in module_.files {
      compiler_request_write_string(output, file.logical_path)
      compiler_request_write_bytes(output, file.source)
    }
  }
  compiler_request_write_u32(
    output,
    self.dependency_interfaces.length().reinterpret_as_uint(),
  )
  for dependency in self.dependency_interfaces {
    compiler_request_write_string(output, dependency.module_name)
    compiler_request_write_string(output, dependency.fingerprint)
  }
  compiler_request_write_u32(
    output,
    self.static_providers.length().reinterpret_as_uint(),
  )
  for provider in self.static_providers {
    compiler_request_write_string(output, provider.name)
    compiler_request_write_bytes(output, provider.wasm)
  }
  match self.standard_library {
    CompilerBootstrapStandard(identity) => {
      compiler_request_write_u32(output, 0U)
      compiler_request_write_bytes(output, identity)
    }
  }
  compiler_request_write_u32(
    output,
    match self.config.optimization {
      CompilerOptimized => 0U
    },
  )
  compiler_request_write_u32(
    output,
    match self.config.diagnostics {
      CompilerTextDiagnostics => 0U
    },
  )
  compiler_request_write_u32(
    output,
    if self.config.test_mode {
      1U
    } else {
      0U
    },
  )
  compiler_request_write_u32(
    output,
    if self.config.default_preamble {
      1U
    } else {
      0U
    },
  )
  compiler_request_write_u32(
    output,
    match self.config.cache_policy {
      CompilerCachesDisabled => 0U
    },
  )
  compiler_request_write_u32(
    output,
    if self.config.cache_report {
      1U
    } else {
      0U
    },
  )
  compiler_request_write_bytes(output, self.compiler_fingerprint)
  let bytes = output.to_bytes()
  if bytes.length() > max_request_bytes() {
    Err("compile request exceeds total request byte bound")
  } else {
    Ok(bytes)
  }
}

///|
pub fn decode(bytes : Bytes) -> Result[CompilerRequest, String] {
  if bytes.length() > max_request_bytes() {
    return Err("compile request exceeds total request byte bound")
  }
  let reader : CompilerRequestReader = { bytes, offset: 0, error: None }
  if reader.read_u32() != COMPILER_REQUEST_MAGIC {
    return Err("invalid compile request magic")
  }
  if reader.read_u32() != COMPILER_REQUEST_VERSION {
    return Err("unsupported compile request version")
  }
  let command = match reader.read_tag("command", 1) {
    0 => CompilerCheck
    _ => CompilerBuild
  }
  let output_kind = match reader.read_tag("output kind", 2) {
    0 => CompilerWasmOutput
    1 => CompilerHirOutput
    _ => CompilerLoweringOutput
  }
  let response = match reader.read_tag("response mode", 1) {
    0 => CompilerStatusOnly
    _ => CompilerOutputFile(reader.read_string("output path", max_path_bytes()))
  }
  let root_module = reader.read_string("root module", max_name_bytes())
  let modules : Array[CompilerRequestModule] = []
  let module_count = reader.read_count("module", max_module_count())
  let mut total_files = 0
  for _ in 0..<module_count {
    let name = reader.read_string("module name", max_name_bytes())
    let files : Array[CompilerRequestFile] = []
    let file_count = reader.read_count("module file", max_files_per_module())
    if total_files > max_total_files() - file_count {
      reader.fail("invalid total file count in compile request")
    } else {
      total_files += file_count
    }
    for _ in 0..<file_count {
      files.push({
        logical_path: reader.read_string("logical path", max_path_bytes()),
        source: reader.read_bytes("source", max_source_bytes()),
      })
    }
    modules.push({ name, files })
  }
  let dependency_interfaces : Array[CompilerRequestDependencyInterface] = []
  let dependency_count = reader.read_count(
    "dependency interface",
    max_dependency_count(),
  )
  for _ in 0..<dependency_count {
    dependency_interfaces.push({
      module_name: reader.read_string("dependency module", max_name_bytes()),
      fingerprint: reader.read_string("dependency fingerprint", 64),
    })
  }
  let static_providers : Array[CompilerRequestStaticProvider] = []
  let provider_count = reader.read_count(
    "static provider",
    max_provider_count(),
  )
  for _ in 0..<provider_count {
    static_providers.push({
      name: reader.read_string("provider name", max_name_bytes()),
      wasm: reader.read_bytes("provider Wasm", max_provider_bytes()),
    })
  }
  let standard_library = match reader.read_tag("standard-library mode", 0) {
    _ =>
      CompilerBootstrapStandard(
        reader.read_bytes("standard-library identity", 32),
      )
  }
  let optimization = match reader.read_tag("optimization mode", 0) {
    _ => CompilerOptimized
  }
  let diagnostics = match reader.read_tag("diagnostics mode", 0) {
    _ => CompilerTextDiagnostics
  }
  let test_mode = reader.read_bool("test mode")
  let default_preamble = reader.read_bool("default preamble")
  let cache_policy = match reader.read_tag("cache policy", 0) {
    _ => CompilerCachesDisabled
  }
  let cache_report = reader.read_bool("cache report")
  let compiler_fingerprint = reader.read_bytes(
    "compiler fingerprint",
    max_compiler_fingerprint_bytes(),
  )
  if reader.offset != bytes.length() {
    reader.fail("trailing bytes in compile request")
  }
  match reader.error {
    Some(error) => Err(error)
    None => {
      let request : CompilerRequest = {
        command,
        output_kind,
        response,
        root_module,
        modules,
        dependency_interfaces,
        static_providers,
        standard_library,
        config: {
          optimization,
          diagnostics,
          test_mode,
          default_preamble,
          cache_policy,
          cache_report,
        },
        compiler_fingerprint,
      }
      match request.validate() {
        Err(error) => Err(error)
        Ok(_) => Ok(request)
      }
    }
  }
}

///|
pub fn bootstrap_standard_library_identity() -> Bytes {
  let output = Buffer()
  output.write_bytes(b"DEW_BOOTSTRAP_STANDARD_LIBRARY_V1\x00")
  let paths = @standard_sources.standard_source_paths()
  compiler_request_write_u32(output, paths.length().reinterpret_as_uint())
  for path in paths {
    compiler_request_write_string(output, path)
    let source = match @standard_sources.bootstrap_standard_source(path) {
      Some(value) => value
      None => abort("bootstrap standard source registry is incomplete")
    }
    compiler_request_write_bytes(output, source)
  }
  let digest = @cache_binary.blake3(output.to_bytes())
  let bytes = Buffer(size_hint=32)
  for byte in digest {
    bytes.write_byte(byte)
  }
  bytes.to_bytes()
}

///|
pub fn bytes_equal(left : Bytes, right : Bytes) -> Bool {
  if left.length() != right.length() {
    return false
  }
  for index in 0..<left.length() {
    if left[index] != right[index] {
      return false
    }
  }
  true
}
