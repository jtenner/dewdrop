///|
test "link keeps remapped function names through cleanup" {
  let dew = core_link_test_dew_module().with_name_sec(
    @lib.NameSec::new(
      func_names=Some(
        @lib.NameMap::new([
          @lib.NameAssoc::new(0U, @lib.Name::from_string("import alias")),
        ]),
      ),
    ),
  )
  let guest = core_link_test_guest_module().with_name_sec(
    @lib.NameSec::new(
      func_names=Some(
        @lib.NameMap::new([
          @lib.NameAssoc::new(0U, @lib.Name::from_string("provider body")),
        ]),
      ),
    ),
  )
  let linked = link_core_wasm_gc_modules(@binary.encode_module(dew).unwrap(), [
    { provider: "starshine", bytes: @binary.encode_module(guest).unwrap(), },
  ]).unwrap()
  let decoded = @binary.decode_module(linked).unwrap()
  let names = decoded.name_sec.unwrap().func_names.unwrap()
  let @lib.NameMap(entries) = names
  assert_true(entries.length() > 0)
  let mut saw_provider = false
  for entry in entries {
    let @lib.NameAssoc(index, name) = entry
    assert_true(
      index.to_int() <
      core_import_counts(decoded).functions + core_functions(decoded).length(),
    )
    if name == @lib.Name::from_string("provider body") {
      saw_provider = true
    }
  }
  assert_true(saw_provider)
}
