///|
test "source loader follows actual imports once and fingerprints dependencies" {
  let reads : Map[String, Int32] = Map([])
  let sources : Map[String, Bytes] = Map([
    ("std/ordering.dew", b"open dew.std.string\n"),
    ("std/string.dew", b"open dew.std.ordering\n"),
  ])
  let load = fn() {
    load_standard_source_closure(["std/ordering.dew", "std/ordering.dew"], fn(
      path,
    ) {
      reads[path] = reads.get(path).unwrap_or(0) + 1
      Ok(sources.get(path).unwrap_or(b""))
    }).unwrap()
  }
  let first = load()
  assert_true(first.sources.paths.contains("std/string.dew"))
  for _, count in reads {
    assert_eq(count, 1)
  }
  sources["std/string.dew"] = b"open dew.std.ordering\n// changed dependency\n"
  let second = load()
  assert_eq(first.sources.paths, second.sources.paths)
  assert_false(first.fingerprint == second.fingerprint)
}

///|
test "missing transitive source stays a loader error" {
  let loaded = load_standard_source_closure(["std/ordering.dew"], fn(path) {
    match path {
      "std/ordering.dew" => Ok(b"open dew.std.string\n")
      "std/string.dew" => Err("cannot read selected source std/string.dew")
      _ => Ok(b"")
    }
  })
  match loaded {
    Err(error) => assert_eq(error, "cannot read selected source std/string.dew")
    Ok(_) => fail("a missing dependency must not use embedded fallback bytes")
  }
}

///|
test "complete source registry preserves selected bytes and fingerprints late sources" {
  let reads : Map[String, Int32] = Map([])
  let mut marker = b"pub let selected_marker = 42i32\n"
  let load = fn() {
    load_standard_source_closure(
      @semantic.standard_library_source_paths(),
      fn(path) {
        reads[path] = reads.get(path).unwrap_or(0) + 1
        Ok(if path == "std/map.dew" { marker } else { b"" })
      },
      follow_imports=false,
    ).unwrap()
  }
  let first = load()
  let mut found = false
  for index, path in first.sources.paths {
    if path == "std/map.dew" {
      assert_eq(first.sources.sources[index], marker)
      found = true
    }
  }
  assert_true(found)
  for _, count in reads {
    assert_eq(count, 1)
  }
  marker = b"pub let selected_marker = 43i32\n"
  assert_false(first.fingerprint == load().fingerprint)
}

///|
test "missing late source stays a loader error in complete registry mode" {
  let loaded = load_standard_source_closure(
    @semantic.standard_library_source_paths(),
    fn(path) {
      if path == "std/map.dew" {
        Err("cannot read selected source std/map.dew")
      } else {
        Ok(b"")
      }
    },
    follow_imports=false,
  )
  match loaded {
    Err(error) => assert_eq(error, "cannot read selected source std/map.dew")
    Ok(_) => fail("a late import must not use embedded fallback bytes")
  }
}
