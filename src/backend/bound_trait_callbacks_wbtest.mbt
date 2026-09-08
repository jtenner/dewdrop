///|
fn bound_trait_callback_check(
  source : Bytes,
  runtime_export? : Bool? = None,
) -> Unit raise {
  let program = @semantic.collect_program_manifest(
    28200UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new("main.dew", source),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(
    @semantic.collect_compiler_source_diagnostics(
      program, analyzed, lowering, link,
    ),
    [],
  )
  if runtime_export is Some(expected) {
    let declaration = program.modules[0].lookup_value("reader").unwrap()
    assert_eq(
      link.functions.any(function_ => {
        function_.declaration == declaration &&
        !function_.elided &&
        function_.visibility is @semantic.Public
      }),
      expected,
    )
  }
  let module_ = match emit_starshine_program_module(lowering, link) {
    Ok(value) => value
    Err(error) => fail(@debug.to_string(error))
  }
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "bound trait function values retain their concrete target" {
  bound_trait_callback_check(
    b"trait Read {\n  fn read(self) -> I64\n}\nimpl Read for I64 {\n  fn read(self) -> I64 {\n    self\n  }\n}\nfn forward<t: Read>(value: t) -> I64 {\n  value.read()\n}\nfn reader<t: Read>() -> fn(t) -> I64 {\n  forward\n}\npub fn main(value: I64) -> I64 {\n  let callback = reader::<I64>()\n  callback(value)\n}\n",
  )
}

///|
test "bound trait lambda bodies retain their concrete target" {
  bound_trait_callback_check(
    b"trait Read {\n  fn read(self) -> I64\n}\nimpl Read for I64 {\n  fn read(self) -> I64 {\n    self\n  }\n}\nfn forward<t: Read>(value: t) -> I64 {\n  value.read()\n}\nfn reader<t: Read>() -> fn(t) -> I64 {\n  fn(value: t) -> I64 {\n    forward(value)\n  }\n}\npub fn main(value: I64) -> I64 {\n  let callback = reader::<I64>()\n  callback(value)\n}\n",
  )
}

///|
test "public trait-bound function factories retain runtime evidence" {
  bound_trait_callback_check(
    b"trait Read {\n  fn read(self) -> I64\n}\nimpl Read for I64 {\n  fn read(self) -> I64 {\n    self\n  }\n}\nfn forward<t: Read>(value: t) -> I64 {\n  value.read()\n}\npub fn reader<t: Read>() -> fn(t) -> I64 {\n  forward\n}\npub fn main(value: I64) -> I64 {\n  let callback = reader::<I64>()\n  callback(value)\n}\n",
    runtime_export=Some(true),
  )
}

///|
test "public generic lambda emits concrete calls without an unproved runtime export" {
  bound_trait_callback_check(
    b"trait Read {\n  fn read(self) -> I64\n}\nimpl Read for I64 {\n  fn read(self) -> I64 {\n    self\n  }\n}\nfn forward<t: Read>(value: t) -> I64 {\n  value.read()\n}\npub fn reader<t: Read>() -> fn(t) -> I64 {\n  fn(value: t) -> I64 {\n    forward(value)\n  }\n}\npub fn main(value: I64) -> I64 {\n  let callback = reader::<I64>()\n  callback(value)\n}\n",
    runtime_export=Some(false),
  )
}

///|
test "runtime lambda export retains a closed generic function reference" {
  bound_trait_callback_check(
    b"trait Read {\n  fn read(self) -> I64\n}\nimpl Read for I64 {\n  fn read(self) -> I64 {\n    self\n  }\n}\nfn forward<t: Read>(value: t) -> I64 {\n  value.read()\n}\nfn invoke(callback: fn(I64) -> I64, value: I64) -> I64 {\n  callback(value)\n}\npub fn reader<t: Read>() -> fn(I64) -> I64 {\n  fn(value: I64) -> I64 {\n    invoke(forward, value)\n  }\n}\npub fn main(value: I64) -> I64 {\n  let callback = reader::<I64>()\n  callback(value)\n}\n",
    runtime_export=Some(true),
  )
}
