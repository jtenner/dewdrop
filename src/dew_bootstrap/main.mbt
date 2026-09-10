///|
fn bootstrap_fail(message : String) -> Unit {
  println("dew: \{message}")
  @sys.exit(2)
}

///|
fn bootstrap_fs_error_message(error : @fs.IOError) -> String {
  match error {
    @fs.IOError(message) => message
  }
}

///|
fn bootstrap_join(left : String, right : String) -> String {
  if left.has_suffix("/") {
    left + right
  } else {
    left + "/" + right
  }
}

///|
fn bootstrap_is_absolute(path : String) -> Bool {
  path.has_prefix("/")
}

///|
fn bootstrap_normalize_path(path : String) -> String {
  let absolute = bootstrap_is_absolute(path)
  let parts : Array[String] = []
  for part in path.split("/") {
    let value = part.to_owned()
    if value == "" || value == "." {
      continue
    }
    if value == ".." {
      if parts.length() > 0 && parts[parts.length() - 1] != ".." {
        ignore(parts.pop())
      } else if !absolute {
        parts.push(value)
      }
    } else {
      parts.push(value)
    }
  }
  let output = Buffer()
  if absolute {
    output.write_byte(b'/')
  }
  for index, part in parts {
    if index > 0 {
      output.write_byte(b'/')
    }
    output.write_string_utf8(part)
  }
  let result = @utf8.decode(output.to_bytes()) catch { _ => path }
  if result == "" {
    if absolute {
      "/"
    } else {
      "."
    }
  } else {
    result
  }
}

///|
fn bootstrap_working_path(path : String) -> String {
  if bootstrap_is_absolute(path) {
    bootstrap_normalize_path(path)
  } else {
    bootstrap_normalize_path(
      bootstrap_join(
        @sys.get_env_var("DEW_WORKING_DIRECTORY").unwrap_or("."),
        path,
      ),
    )
  }
}

///|
fn bootstrap_collect_files(
  root : String,
  suffix : String,
  output : Array[String],
) -> Unit {
  if !@fs.path_exists(root) {
    return
  }
  let entries = @fs.read_dir(root) catch { _ => [] }
  entries.sort()
  for entry in entries {
    let path = bootstrap_join(root, entry)
    let directory = @fs.is_dir(path) catch { _ => false }
    if directory {
      bootstrap_collect_files(path, suffix, output)
    } else if entry.has_suffix(suffix) {
      output.push(path)
    }
  }
}

///|
fn bootstrap_write_hash_string(hash : @crypto.SHA256, value : String) -> Unit {
  let bytes = @utf8.encode(value)
  let prefix = Buffer(size_hint=4)
  let length = bytes.length().reinterpret_as_uint()
  prefix.write_byte((length & 0xffU).to_byte())
  prefix.write_byte(((length >> 8) & 0xffU).to_byte())
  prefix.write_byte(((length >> 16) & 0xffU).to_byte())
  prefix.write_byte(((length >> 24) & 0xffU).to_byte())
  hash.update(prefix.to_bytes())
  hash.update(bytes)
}

///|
fn bootstrap_compiler_fingerprint(repository : String) -> String {
  let files : Array[String] = []
  bootstrap_collect_files(bootstrap_join(repository, "src"), ".mbt", files)
  bootstrap_collect_files(bootstrap_join(repository, "std"), ".dew", files)
  for candidate in ["moon.mod", "moon.work", ".mooncakes/.moon-lock"] {
    let path = bootstrap_join(repository, candidate)
    if @fs.path_exists(path) {
      files.push(path)
    }
  }
  files.sort()
  let hash = @crypto.SHA256::new()
  hash.update(b"DEW_COMPILER_SOURCE_FINGERPRINT_MOONBIT_V1\x00")
  for path in files {
    bootstrap_write_hash_string(hash, path)
    let bytes = @fs.read_file_to_bytes(path) catch {
      error => {
        bootstrap_fail(
          "cannot fingerprint compiler input \{path}: \{bootstrap_fs_error_message(error)}",
        )
        b""
      }
    }
    let length = Buffer(size_hint=8)
    let bits = bytes.length().to_uint64()
    for shift in [0, 8, 16, 24, 32, 40, 48, 56] {
      length.write_byte(((bits >> shift) & 0xffUL).to_byte())
    }
    hash.update(length.to_bytes())
    hash.update(bytes)
  }
  @crypto.bytes_to_hex_string(hash.finalize())
}

///|
fn bootstrap_standard_root(
  repository : String,
  roots : Array[String],
) -> String {
  let candidates = if roots.length() > 0 {
    roots
  } else {
    match @sys.get_env_var("DEW_PACKAGE_ROOTS") {
      Some(value) => value.split(":").map(part => part.to_owned()).to_array()
      None => [repository]
    }
  }
  let checked : Array[String] = []
  for candidate in candidates {
    let canonical = bootstrap_working_path(candidate)
    for package_root in [bootstrap_join(canonical, "dew.std"), canonical] {
      checked.push(package_root)
      if @fs.path_exists(
          bootstrap_join(package_root, "std/preamble/00-builtins.dew"),
        ) {
        return package_root
      }
    }
  }
  bootstrap_fail(
    "cannot locate dew.std package in ordered roots: " + checked.join(", "),
  )
  repository
}

///|
fn bootstrap_expand_manifest_arguments(
  arguments : Array[String],
  include_tests : Bool,
) -> Array[String] {
  let remaining : Array[String] = []
  let mut manifest : String? = None
  let mut index = 0
  while index < arguments.length() {
    if arguments[index] == "--manifest" {
      if manifest is Some(_) {
        bootstrap_fail("--manifest may be supplied only once")
      }
      if index + 1 >= arguments.length() {
        bootstrap_fail("missing value for --manifest")
      }
      manifest = Some(bootstrap_working_path(arguments[index + 1]))
      index += 2
    } else {
      remaining.push(arguments[index])
      index += 1
    }
  }
  if manifest is None {
    let mut explicit = false
    for argument in remaining {
      if argument.has_suffix(".dew") ||
        argument == "--module" ||
        argument == "--root" {
        explicit = true
      }
    }
    if !explicit {
      let candidate = bootstrap_join(
        @sys.get_env_var("DEW_WORKING_DIRECTORY").unwrap_or("."),
        "dew.json",
      )
      if @fs.path_exists(candidate) {
        manifest = Some(candidate)
      }
    }
  }
  match manifest {
    None => remaining
    Some(path) => {
      let loaded = bootstrap_load_manifest(path, include_tests)
      if loaded.dependency_key == "" {
        @sys.unset_env_var("DEW_DEPENDENCY_INTERFACE_KEY")
      } else {
        @sys.set_env_var("DEW_DEPENDENCY_INTERFACE_KEY", loaded.dependency_key)
      }
      let expanded = remaining.copy()
      expanded.push("--root")
      expanded.push(loaded.root)
      for expectation in loaded.expectations {
        expanded.push("--dependency-interface")
        expanded.push(expectation.0)
        expanded.push(expectation.1)
      }
      for module_ in loaded.modules {
        expanded.push("--module")
        expanded.push(module_.0)
        for file in module_.1 {
          expanded.push(file)
        }
      }
      expanded
    }
  }
}

///|
fn bootstrap_compiler_source_path(repository : String, path : String) -> String {
  let absolute = bootstrap_working_path(path)
  let prefix = repository + "/"
  if absolute.has_prefix(prefix) {
    absolute[prefix.length():].to_owned()
  } else {
    absolute
  }
}

///|
fn bootstrap_prepare_compile_arguments(
  repository : String,
  arguments : Array[String],
) -> Array[String] {
  let roots : Array[String] = []
  let remaining : Array[String] = []
  let mut bootstrap_standard = false
  let mut index = 0
  while index < arguments.length() {
    let argument = arguments[index]
    if argument == "--package-root" {
      if index + 1 >= arguments.length() {
        bootstrap_fail("missing value for --package-root")
      }
      roots.push(arguments[index + 1])
      index += 2
    } else if argument == "--bootstrap-std" {
      bootstrap_standard = true
      remaining.push(argument)
      index += 1
    } else if argument == "--std-root" {
      bootstrap_fail(
        "--std-root is an internal compiler option; use --package-root",
      )
    } else if argument == "-o" || argument == "--output" {
      if index + 1 >= arguments.length() {
        bootstrap_fail("missing output path")
      }
      remaining.push(argument)
      remaining.push(bootstrap_working_path(arguments[index + 1]))
      index += 2
    } else if argument.has_suffix(".dew") {
      remaining.push(bootstrap_compiler_source_path(repository, argument))
      index += 1
    } else {
      remaining.push(argument)
      index += 1
    }
  }
  if bootstrap_standard {
    if roots.length() > 0 {
      bootstrap_fail("--bootstrap-std cannot be combined with --package-root")
    }
    @sys.set_env_var("DEW_BOOTSTRAP_STD", "1")
    @sys.unset_env_var("DEW_STD_ROOT")
  } else {
    @sys.unset_env_var("DEW_BOOTSTRAP_STD")
    @sys.set_env_var("DEW_STD_ROOT", bootstrap_standard_root(repository, roots))
  }
  remaining
}

///|
fn bootstrap_compile(
  repository : String,
  command : String,
  arguments : Array[String],
) -> Int {
  let optimization = bootstrap_optimization_or_fail(arguments)
  if command == "check" && optimization.enabled() {
    bootstrap_fail(
      "--optimize and --starshine-pass require build, run, test, or optimize",
    )
  }
  let expanded = bootstrap_expand_manifest_arguments(
    optimization.arguments,
    false,
  )
  let prepared = bootstrap_prepare_compile_arguments(repository, expanded)
  let fingerprint = bootstrap_compiler_fingerprint(repository)
  @sys.set_env_var("DEW_COMPILER_FINGERPRINT", fingerprint)
  let host = repository + "/tools/run-dew-cli-host.sh"
  if command == "build" {
    let binary = if optimization.enabled() {
      bootstrap_optimizer_binary(repository)
    } else {
      ""
    }
    let build_identity = if optimization.enabled() {
      bootstrap_optimizer_identity(fingerprint, binary, optimization)
    } else {
      fingerprint
    }
    let plan = bootstrap_build_cache_plan(repository, prepared, build_identity)
    if optimization.enabled() && plan.emit != "wasm" {
      bootstrap_fail(
        "Starshine optimization requires --emit wasm or --emit wat",
      )
    }
    if bootstrap_build_cache_restore(plan) {
      return 0
    }
    let raw = if optimization.enabled() {
      if plan.output == "" {
        bootstrap_fail("dew build requires -o OUTPUT")
      }
      bootstrap_ensure_directory(bootstrap_dirname(plan.output))
      plan.output + ".dew-raw-\{bootstrap_process_id()}"
    } else {
      plan.output
    }
    let compile_arguments = if optimization.enabled() {
      bootstrap_optimizer_output_arguments(plan.arguments, raw)
    } else {
      plan.arguments
    }
    let result = bootstrap_run_process([host, command, ..compile_arguments])
    if result != 0 {
      return result
    }
    if optimization.enabled() {
      let optimized = bootstrap_optimize_wasm(
        binary,
        optimization,
        raw,
        plan.output,
      )
      if optimized != 0 {
        return optimized
      }
      @fs.remove_file(raw) catch {
        _ => ()
      }
    }
    bootstrap_build_cache_publish(plan)
    return 0
  }
  bootstrap_run_process([host, command, ..prepared])
}

///|
fn bootstrap_remove_tree(path : String) -> Bool {
  match bootstrap_platform_remove_tree(path) {
    Ok(removed) => removed
    Err(error) => {
      bootstrap_fail(error)
      false
    }
  }
}

///|
fn bootstrap_path_contains(parent : String, child : String) -> Bool {
  let normalized_parent = bootstrap_normalize_path(parent)
  let normalized_child = bootstrap_normalize_path(child)
  normalized_parent == normalized_child ||
  normalized_child.has_prefix(
    if normalized_parent == "/" {
      "/"
    } else {
      normalized_parent + "/"
    },
  )
}

///|
fn bootstrap_clean_targets(repository : String) -> Array[String] {
  let candidates = [
    bootstrap_cache_root(repository),
    bootstrap_join(repository, "_build"),
    bootstrap_join(repository, "target"),
    bootstrap_join(repository, ".tmp"),
    bootstrap_join(repository, ".dew-cache"),
  ]
  let targets : Array[String] = []
  for candidate in candidates {
    let target = bootstrap_normalize_path(candidate)
    if !targets.contains(target) {
      targets.push(target)
    }
  }
  targets
}

///|
fn bootstrap_validate_clean_target(
  repository : String,
  working_directory : String,
  target : String,
) -> Unit {
  let normalized = bootstrap_normalize_path(target)
  let home = bootstrap_normalize_path(
    @sys.get_env_var("HOME").unwrap_or("/nonexistent-dew-home"),
  )
  if normalized == "." ||
    normalized == "/" ||
    bootstrap_path_contains(normalized, repository) ||
    bootstrap_path_contains(normalized, working_directory) ||
    bootstrap_path_contains(normalized, home) {
    bootstrap_fail(
      "refusing to clean unsafe build artifact path: \{normalized}",
    )
  }
  let components = normalized.split("/").filter(part => part != "").count()
  if components < 2 {
    bootstrap_fail(
      "refusing to clean unsafe build artifact path: \{normalized}",
    )
  }
}

///|
fn bootstrap_clean(repository : String, dry_run : Bool) -> Unit {
  let working_directory = bootstrap_normalize_path(
    @sys.get_env_var("DEW_WORKING_DIRECTORY").unwrap_or("."),
  )
  let targets = bootstrap_clean_targets(repository)
  for target in targets {
    bootstrap_validate_clean_target(repository, working_directory, target)
  }
  if dry_run {
    for target in targets {
      println("would remove Dew build artifact: \{target}")
    }
    return
  }
  let mut removed = false
  for target in targets {
    if bootstrap_remove_tree(target) {
      removed = true
      println("removed Dew build artifact: \{target}")
    }
  }
  if !removed {
    println("Dew build artifacts already clean")
  }
}

///|
fn bootstrap_take_output(arguments : Array[String]) -> (String, Array[String]) {
  let remaining : Array[String] = []
  let mut output = ""
  let mut index = 0
  while index < arguments.length() {
    if arguments[index] == "-o" || arguments[index] == "--output" {
      if index + 1 >= arguments.length() {
        bootstrap_fail("missing output path")
      }
      output = bootstrap_working_path(arguments[index + 1])
      index += 2
    } else {
      remaining.push(arguments[index])
      index += 1
    }
  }
  if output == "" {
    bootstrap_fail("build requires -o OUTPUT")
  }
  (output, remaining)
}

///|
fn bootstrap_emit_wat(repository : String, arguments : Array[String]) -> Int {
  let (output, remaining) = bootstrap_take_output(arguments)
  let filtered : Array[String] = []
  let mut index = 0
  while index < remaining.length() {
    if remaining[index] == "--emit" &&
      index + 1 < remaining.length() &&
      remaining[index + 1] == "wat" {
      index += 2
    } else {
      filtered.push(remaining[index])
      index += 1
    }
  }
  let temporary = bootstrap_join(
    repository,
    ".tmp/dew-emit-wat-\{bootstrap_process_id()}.wasm",
  )
  bootstrap_ensure_directory(bootstrap_dirname(temporary))
  let result = bootstrap_compile(
    repository,
    "build",
    [..filtered, "--no-build-cache", "-o", temporary],
  )
  if result != 0 {
    return result
  }
  let rendered = bootstrap_run_process([
    "wasm-tools", "print", temporary, "-o", output,
  ])
  if rendered == 0 {
    let bytes = @fs.read_file_to_bytes(output) catch { _ => b"" }
    println("wrote \{output} (\{bytes.length()} bytes)")
  }
  @fs.remove_file(temporary) catch {
    _ => ()
  }
  rendered
}

///|
fn bootstrap_run_command(repository : String, arguments : Array[String]) -> Int {
  let temporary = bootstrap_join(
    repository,
    ".tmp/dew-run-\{bootstrap_process_id()}.wasm",
  )
  bootstrap_ensure_directory(bootstrap_dirname(temporary))
  let result = bootstrap_compile(
    repository,
    "build",
    [..arguments, "--no-build-cache", "-o", temporary],
  )
  if result != 0 {
    return result
  }
  let executed = bootstrap_run_process([
    "node", "--no-liftoff", "tools/dew-run.mjs", temporary,
  ])
  @fs.remove_file(temporary) catch {
    _ => ()
  }
  executed
}

///|
fn bootstrap_test_command(
  repository : String,
  arguments : Array[String],
) -> Int {
  let optimization = bootstrap_optimization_or_fail(arguments)
  let expanded = bootstrap_expand_manifest_arguments(
    optimization.arguments,
    true,
  )
  let prepared = bootstrap_prepare_compile_arguments(repository, expanded)
  let modules : Array[(String, Array[String])] = []
  let runner : Array[String] = []
  let mut module_name = "main"
  let mut root = ""
  let mut files : Array[String] = []
  let mut index = 0
  while index < prepared.length() {
    let argument = prepared[index]
    if argument == "--module" {
      if files.length() > 0 {
        modules.push((module_name, files))
        files = []
      }
      module_name = prepared[index + 1]
      index += 2
    } else if argument == "--root" {
      root = prepared[index + 1]
      index += 2
    } else if argument == "--dependency-interface" {
      index += 3
    } else if argument == "--file" ||
      argument == "--name" ||
      argument == "--filter" {
      runner.push(argument)
      runner.push(prepared[index + 1])
      index += 2
    } else if argument == "--list" {
      runner.push(argument)
      index += 1
    } else if argument.has_prefix("--") {
      index += 1
    } else {
      files.push(argument)
      index += 1
    }
  }
  if files.length() > 0 {
    modules.push((module_name, files))
  }
  if root == "" {
    root = if modules.length() > 0 { modules[0].0 } else { module_name }
  }
  let mut has_test = false
  for module_ in modules {
    for file in module_.1 {
      if file.has_suffix("_test.dew") {
        has_test = true
      }
    }
  }
  if !has_test {
    bootstrap_fail("dew test requires at least one path ending in _test.dew")
  }
  let wasm = bootstrap_join(
    repository,
    ".tmp/dew-test-\{bootstrap_process_id()}.wasm",
  )
  let compile : Array[String] = [
    "moon", "run", "--target", "native", "--release", "-j", "8", "src/dew_test_gen",
    "--", wasm, root,
  ]
  for module_ in modules {
    for file in module_.1 {
      compile.push(module_.0)
      compile.push(file)
      compile.push(file)
    }
  }
  let compiled = bootstrap_run_process(compile)
  if compiled != 0 {
    return compiled
  }
  if optimization.enabled() {
    let optimized = bootstrap_optimize_wasm(
      bootstrap_optimizer_binary(repository),
      optimization,
      wasm,
      wasm,
    )
    if optimized != 0 {
      return optimized
    }
  }
  let executed = bootstrap_run_process(
    [
      "node", "--no-liftoff", "tools/dew-test/run.mjs", "--wasm", wasm, "--label",
      "Dew tests", ..runner,
    ],
  )
  @fs.remove_file(wasm) catch {
    _ => ()
  }
  executed
}

///|
fn main {
  let arguments = @sys.get_cli_args()
  if arguments.length() < 2 {
    bootstrap_fail("expected a command")
  }
  let repository = bootstrap_normalize_path(
    @sys.get_env_var("DEW_REPOSITORY_ROOT").unwrap_or("."),
  )
  let command = arguments[1]
  let remaining = arguments[2:].to_owned()
  if command == "--help" || command == "help" || remaining.contains("--help") {
    println(
      "dew build|run|test [source files] [--optimize none|speed|speed-deep|O4s]",
    )
    println(
      "dew optimize INPUT.wasm -o OUTPUT.wasm [--optimize speed|speed-deep|O4s|none]",
    )
    println(
      "--starshine-pass NAME: exact ordered pass; repeat to form a custom schedule",
    )
    println(
      "--print-passes: print the selected schedule as JSON without compiling",
    )
    println("Optimization defaults to none for builds, speed for dew optimize.")
    return
  }
  if ["build", "run", "test", "optimize", "check"].contains(command) &&
    remaining.contains("--print-passes") {
    let selected = if command == "optimize" &&
      !remaining.contains("--optimize") &&
      !remaining.contains("--starshine-pass") {
      ["--optimize", "speed", ..remaining]
    } else {
      remaining
    }
    bootstrap_print_optimization(bootstrap_optimization_or_fail(selected))
    return
  }
  if command == "optimize" {
    @sys.exit(bootstrap_optimize_command(repository, remaining))
  }
  if command == "package-integrity" {
    if remaining.length() != 1 {
      bootstrap_fail("usage: dew package-integrity MANIFEST")
    }
    println(
      bootstrap_package_integrity(
        bootstrap_load_package(bootstrap_working_path(remaining[0])),
      ),
    )
    return
  }
  if command == "clean" {
    if remaining.length() > 1 ||
      (remaining.length() == 1 && remaining[0] != "--dry-run") {
      bootstrap_fail("usage: dew clean [--dry-run]")
    }
    bootstrap_clean(repository, remaining.length() == 1)
    return
  }
  if command == "run" {
    @sys.exit(bootstrap_run_command(repository, remaining))
  }
  if command == "test" {
    @sys.exit(bootstrap_test_command(repository, remaining))
  }
  if command == "check" || command == "build" {
    if command == "build" {
      for index, argument in remaining {
        if argument == "--emit" &&
          index + 1 < remaining.length() &&
          remaining[index + 1] == "wat" {
          @sys.exit(bootstrap_emit_wat(repository, remaining))
        }
      }
    }
    @sys.exit(bootstrap_compile(repository, command, remaining))
  }
  bootstrap_fail("unsupported MoonBit bootstrap command: \{command}")
}
