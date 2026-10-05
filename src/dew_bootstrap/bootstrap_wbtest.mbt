///|
test "bootstrap normalizes paths and package module names" {
  assert_eq(bootstrap_normalize_path("/a/./b/../c"), "/a/c")
  assert_eq(bootstrap_normalize_path("a/b/../../c"), "c")
  assert_eq(
    bootstrap_package_module_name("@fixture/package-callback"),
    "fixture.package_callback",
  )
}

///|
test "bootstrap shell quoting preserves single quotes" {
  assert_eq(bootstrap_shell_quote("a'b"), "'a'\\''b'")
}

///|
test "bootstrap clean covers every managed build directory" {
  let targets = bootstrap_clean_targets("/work/dewdrop")
  assert_true(targets.contains("/work/dewdrop/_build"))
  assert_true(targets.contains("/work/dewdrop/target"))
  assert_true(targets.contains("/work/dewdrop/.tmp"))
  assert_true(targets.contains("/work/dewdrop/.dew-cache"))
  assert_true(bootstrap_path_contains("/work", "/work/dewdrop"))
  assert_false(bootstrap_path_contains("/work/dew", "/work/dewdrop"))
}

///|
test "bootstrap package integrity is deterministic" {
  let package_ = bootstrap_load_package(
    "tests/abi-consumers/imported-package/dependency/dew.json",
  )
  assert_eq(
    bootstrap_package_integrity(package_),
    bootstrap_package_integrity(package_),
  )
}

///|
test "bootstrap compiler fingerprint covers every compiler input kind" {
  let root = @sys.get_env_var("DEW_REPOSITORY_ROOT").unwrap_or(".")
  let files = bootstrap_compiler_fingerprint_files(root, root)
  assert_true(
    files.contains(bootstrap_join(root, "src/tokenizer/tokenizer_native.c")),
  )
  assert_true(
    files.contains(bootstrap_join(root, "src/dew_bootstrap/platform.c")),
  )
  assert_true(
    files.contains(
      bootstrap_join(root, "src/standard_loader/parse_event_cache_platform.c"),
    ),
  )
  assert_true(files.contains(bootstrap_join(root, "src/tokenizer/moon.pkg")))
  assert_true(files.contains(bootstrap_join(root, "std/array.dew")))
  assert_true(files.contains(bootstrap_join(root, "starshine-mb/moon.mod")))
  assert_true(
    files.contains(bootstrap_join(root, "starshine-mb/src/lib/moon.pkg")),
  )
  assert_true(
    files.contains(bootstrap_join(root, "starshine-mb/src/lib/module.mbt")),
  )
}

///|
test "bootstrap compiler fingerprint uses the selected standard root" {
  let root = @sys.get_env_var("DEW_REPOSITORY_ROOT").unwrap_or(".")
  let external = bootstrap_join(root, "tests/bootstrap-fingerprint-external")
  let selected = bootstrap_standard_root(root, [external])
  assert_eq(selected, bootstrap_working_path(external))
  let files = bootstrap_compiler_fingerprint_files(root, selected)
  assert_true(
    files.contains(bootstrap_join(selected, "std/preamble/00-builtins.dew")),
  )
  assert_false(files.contains(bootstrap_join(root, "std/array.dew")))
}

///|
test "package artifact validation rejects unsafe and conflicting source paths" {
  assert_true(
    bootstrap_validate_package_artifact_files([("../escape.dew", b"")])
    is Err(_),
  )
  assert_true(
    bootstrap_validate_package_artifact_files([("/escape.dew", b"")]) is Err(_),
  )
  assert_true(
    bootstrap_validate_package_artifact_files([("src\\escape.dew", b"")])
    is Err(_),
  )
  assert_true(
    bootstrap_validate_package_artifact_files([("dew.json/source.dew", b"")])
    is Err(_),
  )
  assert_true(
    bootstrap_validate_package_artifact_files([
      ("src/main.dew", b"a"),
      ("src/main.dew", b"b"),
    ])
    is Err(_),
  )
  assert_true(
    bootstrap_validate_package_artifact_files([
      ("src.dew", b"a"),
      ("src.dew/nested.dew", b"b"),
    ])
    is Err(_),
  )
}

///|
test "package artifact validation is iterative at the maximum file count" {
  let files : Array[(String, Bytes)] = []
  for index in 0..<BOOTSTRAP_PACKAGE_ARTIFACT_MAX_FILES {
    files.push(("src/file-\{index}.dew", b""))
  }
  assert_eq(bootstrap_validate_package_artifact_files(files), Ok(["src"]))
}

///|
test "package artifact validation rejects a file beyond the maximum" {
  let files : Array[(String, Bytes)] = []
  for index in 0..<=BOOTSTRAP_PACKAGE_ARTIFACT_MAX_FILES {
    files.push(("file-\{index}.dew", b""))
  }
  assert_true(bootstrap_validate_package_artifact_files(files) is Err(_))
}
