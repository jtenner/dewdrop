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
