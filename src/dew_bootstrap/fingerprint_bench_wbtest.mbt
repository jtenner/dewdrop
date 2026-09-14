///|
test "bench bootstrap source fingerprint" (it : @bench.T) {
  let root = @sys.get_env_var("DEW_REPOSITORY_ROOT").unwrap()
  it.bench(fn() { it.keep(bootstrap_compiler_fingerprint(root)) }, count=3U)
}

///|
test "bench bootstrap built artifact fingerprint experiment" (it : @bench.T) {
  let root = @sys.get_env_var("DEW_REPOSITORY_ROOT").unwrap()
  let artifact = @sys.get_env_var("DEW_BENCH_COMPILER_ARTIFACT").unwrap()
  it.bench(
    fn() {
      let files = [artifact]
      bootstrap_collect_files(bootstrap_join(root, "std"), ".dew", files)
      it.keep(bootstrap_fingerprint_files(files))
    },
    count=3U,
  )
}
