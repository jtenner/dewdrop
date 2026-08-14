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
test "bootstrap package integrity is deterministic" {
  let package_ = bootstrap_load_package(
    "tests/abi-consumers/imported-package/dependency/dew.json",
  )
  assert_eq(
    bootstrap_package_integrity(package_),
    bootstrap_package_integrity(package_),
  )
}
