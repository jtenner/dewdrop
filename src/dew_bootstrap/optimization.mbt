///|
struct BootstrapOptimization {
  profile : String
  passes : Array[String]
  arguments : Array[String]
  print_passes : Bool
}

///|
fn BootstrapOptimization::enabled(self : BootstrapOptimization) -> Bool {
  !self.passes.is_empty()
}

///|
fn bootstrap_optimization_passes(
  profile : String,
) -> Result[Array[String], String] {
  match profile {
    "none" => Ok([])
    "speed" =>
      Ok([
        "duplicate-function-elimination", "precompute", "inlining", "local-cse",
        "simplify-locals-nostructure", "coalesce-locals", "vacuum", "remove-unused-module-elements",
        "memory-packing", "reorder-locals", "strip-debug",
      ])
    "O4s" =>
      Ok([
        "duplicate-function-elimination", "vacuum", "reorder-locals", "strip-debug",
      ])
    _ =>
      Err(
        "unknown optimization profile '\{profile}'; expected none, speed, or O4s",
      )
  }
}

///|
fn bootstrap_parse_optimization(
  arguments : Array[String],
) -> Result[BootstrapOptimization, String] {
  let remaining : Array[String] = []
  let custom : Array[String] = []
  let mut profile : String? = None
  let mut print_passes = false
  let mut index = 0
  while index < arguments.length() {
    let argument = arguments[index]
    if argument == "--optimize" || argument == "--starshine-pass" {
      if index + 1 >= arguments.length() || arguments[index + 1].has_prefix("-") {
        return Err("missing value for \{argument}")
      }
      let value = arguments[index + 1]
      if argument == "--optimize" {
        if profile is Some(_) {
          return Err("--optimize may be supplied only once")
        }
        profile = Some(value)
      } else {
        if value == "" {
          return Err("--starshine-pass requires a pass name")
        }
        for byte in @utf8.encode(value) {
          if !((byte >= b'a' && byte <= b'z') ||
            (byte >= b'0' && byte <= b'9') ||
            byte == b'-') {
            return Err("invalid Starshine pass name '\{value}'")
          }
        }
        custom.push(value)
      }
      index += 2
    } else if argument == "--print-passes" {
      print_passes = true
      index += 1
    } else {
      remaining.push(argument)
      index += 1
    }
  }
  if !custom.is_empty() && profile is Some(_) {
    return Err("--optimize cannot be combined with --starshine-pass")
  }
  let name = if custom.is_empty() {
    profile.unwrap_or("none")
  } else {
    "custom"
  }
  let passes = if custom.is_empty() {
    match bootstrap_optimization_passes(name) {
      Ok(passes) => passes
      Err(error) => return Err(error)
    }
  } else {
    custom
  }
  Ok({ profile: name, passes, arguments: remaining, print_passes, })
}

///|
fn bootstrap_optimizer_output_arguments(
  arguments : Array[String],
  output : String,
) -> Array[String] {
  let result : Array[String] = []
  let mut index = 0
  let mut found = false
  while index < arguments.length() {
    let argument = arguments[index]
    result.push(argument)
    if argument == "-o" || argument == "--output" {
      if index + 1 >= arguments.length() {
        bootstrap_fail("missing output path")
      }
      result.push(output)
      found = true
      index += 2
    } else {
      index += 1
    }
  }
  if !found {
    result.append(["-o", output])
  }
  result
}

///|
fn bootstrap_print_optimization(plan : BootstrapOptimization) -> Unit {
  let passes : Array[Json] = plan.passes.map(name => Json::string(name))
  println(
    Json::object({
      "version": Json::number(1),
      "profile": Json::string(plan.profile),
      "optimizeLevel": Json::number(4),
      "shrinkLevel": Json::number(1),
      "passes": Json::array(passes),
    }).stringify(),
  )
}

///|
fn bootstrap_optimization_or_fail(
  arguments : Array[String],
) -> BootstrapOptimization {
  match bootstrap_parse_optimization(arguments) {
    Ok(plan) => plan
    Err(error) => {
      bootstrap_fail(error)
      abort("optimizer option parsing failed")
    }
  }
}

///|
fn bootstrap_optimizer_binary(repository : String) -> String {
  match @sys.get_env_var("DEW_STARSHINE") {
    Some(path) => {
      let binary = bootstrap_working_path(path)
      if !@fs.path_exists(binary) {
        bootstrap_fail("Starshine executable does not exist: \{binary}")
      }
      binary
    }
    None => {
      let status = bootstrap_run_process([
        "moon", "build", "--quiet", "--target", "native", "--release", "-j", "8",
        "starshine-mb/src/cmd",
      ])
      if status != 0 {
        bootstrap_fail("cannot build the pinned native Starshine optimizer")
      }
      bootstrap_join(
        repository, "_build/native/release/build/jtenner/starshine/cmd/cmd.exe",
      )
    }
  }
}

///|
fn bootstrap_optimizer_identity(
  compiler : String,
  binary : String,
  plan : BootstrapOptimization,
) -> String {
  let hash = @crypto.SHA256::new()
  hash.update(b"DEW_STARSHINE_BUILD_V1\x00")
  bootstrap_write_hash_string(hash, compiler)
  bootstrap_write_hash_string(hash, "optimize=4;shrink=1")
  for pass in plan.passes {
    bootstrap_write_hash_string(hash, pass)
  }
  let bytes = @fs.read_file_to_bytes(binary) catch {
    error => {
      bootstrap_fail(
        "cannot read Starshine executable: \{bootstrap_fs_error_message(error)}",
      )
      b""
    }
  }
  hash.update(bytes)
  @crypto.bytes_to_hex_string(hash.finalize())
}

///|
fn bootstrap_optimize_wasm(
  binary : String,
  plan : BootstrapOptimization,
  input : String,
  output : String,
) -> Int {
  bootstrap_ensure_directory(bootstrap_dirname(output))
  let temporary = output + ".dew-opt-\{bootstrap_process_id()}"
  @fs.remove_file(temporary) catch {
    _ => ()
  }
  let flags = plan.passes.map(pass => "--" + pass)
  let status = bootstrap_run_process(
    [
      binary, "--optimize-level", "4", "--shrink-level", "1", ..flags, input, "-o",
      temporary,
    ],
  )
  if status != 0 {
    println("Starshine failed for passes: " + plan.passes.join(", "))
    println("optimizer input retained at \{input}")
    return status
  }
  match bootstrap_rename(temporary, output) {
    Ok(_) => ()
    Err(error) => bootstrap_fail(error)
  }
  println("wrote \{output} (Starshine \{plan.profile})")
  0
}

///|
fn bootstrap_optimize_command(
  repository : String,
  arguments : Array[String],
) -> Int {
  let has_profile = arguments.contains("--optimize") ||
    arguments.contains("--starshine-pass")
  let plan = bootstrap_optimization_or_fail(
    if has_profile {
      arguments
    } else {
      ["--optimize", "speed", ..arguments]
    },
  )
  let mut input = ""
  let mut output = ""
  let mut index = 0
  while index < plan.arguments.length() {
    let argument = plan.arguments[index]
    if argument == "-o" || argument == "--output" {
      if index + 1 >= plan.arguments.length() {
        bootstrap_fail("missing output path")
      }
      output = bootstrap_working_path(plan.arguments[index + 1])
      index += 2
    } else {
      if input != "" || argument.has_prefix("-") {
        bootstrap_fail(
          "usage: dew optimize INPUT.wasm -o OUTPUT.wasm [--optimize speed|O4s|none]",
        )
      }
      input = bootstrap_working_path(argument)
      index += 1
    }
  }
  if input == "" || output == "" {
    bootstrap_fail("dew optimize requires INPUT.wasm and -o OUTPUT.wasm")
  }
  if !plan.enabled() {
    let bytes = @fs.read_file_to_bytes(input) catch {
      error => {
        bootstrap_fail(bootstrap_fs_error_message(error))
        b""
      }
    }
    bootstrap_atomic_write(output, bytes)
    return 0
  }
  bootstrap_optimize_wasm(
    bootstrap_optimizer_binary(repository),
    plan,
    input,
    output,
  )
}
