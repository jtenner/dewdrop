///|
test "emission rejects a missing physical type relocation before writing sections" {
  let (lowering, link, diagnostics) = backend_packed_primitive_pipeline(
    b"pub struct Pair {\n  left: I32\n  right: I64\n}\npub fn read(value: Pair) -> I64 {\n  value.right\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(link.modules[0].physical_types.length(), 1)
  assert_eq(
    @validate.validate_module(
      emit_starshine_program_module(lowering, link).unwrap(),
    ),
    Ok(()),
  )
  link.module_type_indices[0][0] = -1
  match emit_starshine_program_module(lowering, link) {
    Err(error) =>
      assert_eq(
        error,
        CompilerInvariantFailure({
          code: 503U,
          phase: 7U,
          module_id: 2520UL,
          declaration: 2520UL << 32,
          body: 0UL,
          expression: 0xffffffffU,
          expected: link.type_count.to_uint64(),
          actual: 0xffffffffUL,
          detail: 14UL << 32,
        }),
      )
    Ok(_) => fail("a missing physical type reached emission")
  }
}
