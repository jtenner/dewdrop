///|
test "type layout plans retain generic struct fields and scalar shapes" {
  let collected = collect_bytes(
    921UL, b"struct Pair<t> {\n  first: t\n  second: I64\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let layouts = plan_module_type_layouts(collected, resolved)
  assert_eq(layouts.layouts.length(), 1)
  let layout = layouts.layouts[0]
  assert_eq(layout.declaration, collected.declarations[0].id)
  assert_eq(layout.generic_parameters.length, 1)
  match layout.kind {
    PlannedStructLayout(fields) => {
      assert_eq(fields.length, 2)
      assert_eq(layouts.fields[fields.start].field, collected.fields[0].id)
      assert_eq(layouts.fields[fields.start].index, 0)
      assert_eq(layouts.fields[fields.start].shape, GenericPlannedValueShape)
      assert_eq(layouts.fields[fields.start + 1].index, 1)
      assert_eq(layouts.fields[fields.start + 1].shape, I64PlannedValueShape)
    }
    _ => fail("expected struct layout")
  }
}

///|
test "enum layout plans assign stable tags and payload recipes" {
  let collected = collect_bytes(
    922UL, b"enum Value<t> {\n  Empty\n  One(t)\n  Pair(I32, I64)\n  Named {\n    value: t\n    flag: Bool\n  }\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let layouts = plan_module_type_layouts(collected, resolved)
  let layout = layouts.layouts[0]
  match layout.kind {
    PlannedEnumLayout(variants) => {
      assert_eq(variants.length, 4)
      for index in 0..<variants.length {
        assert_eq(layouts.variants[variants.start + index].tag, index)
      }
      match layouts.variants[variants.start].payload {
        PlannedUnitVariantLayout => ()
        _ => fail("expected unit payload")
      }
      match layouts.variants[variants.start + 1].payload {
        PlannedTupleVariantLayout(payload) => {
          assert_eq(payload.length, 1)
          assert_eq(
            layouts.payload_shapes[payload.start],
            GenericPlannedValueShape,
          )
        }
        _ => fail("expected tuple payload")
      }
      match layouts.variants[variants.start + 2].payload {
        PlannedTupleVariantLayout(payload) => {
          assert_eq(payload.length, 2)
          assert_eq(layouts.payload_shapes[payload.start], I32PlannedValueShape)
          assert_eq(
            layouts.payload_shapes[payload.start + 1],
            I64PlannedValueShape,
          )
        }
        _ => fail("expected pair payload")
      }
      match layouts.variants[variants.start + 3].payload {
        PlannedStructVariantLayout(fields) => {
          assert_eq(fields.length, 2)
          assert_eq(layouts.fields[fields.start].index, 0)
          assert_eq(layouts.fields[fields.start + 1].index, 1)
          assert_eq(
            layouts.fields[fields.start + 1].shape,
            I32PlannedValueShape,
          )
        }
        _ => fail("expected struct payload")
      }
    }
    _ => fail("expected enum layout")
  }
}

///|
test "enum layout tags remain iterative and stable for 1024 variants" {
  let collected = collect_bytes(924UL, flow_enum_source(1024, false))
  let resolved = resolve_module_types(collected)
  let layouts = plan_module_type_layouts(collected, resolved)
  match layouts.layouts[0].kind {
    PlannedEnumLayout(variants) => {
      assert_eq(variants.length, 1024)
      assert_eq(layouts.variants[variants.start].tag, 0)
      assert_eq(layouts.variants[variants.start + 1023].tag, 1023)
    }
    _ => fail("expected wide enum layout")
  }
}

///|
test "type layout lookup is stable by declaration identity" {
  let collected = collect_bytes(
    923UL, b"struct First {}\nenum Second {\n  Value\n}\ntype Alias = First\n",
  )
  let resolved = resolve_module_types(collected)
  let layouts = plan_module_type_layouts(collected, resolved)
  assert_eq(layouts.layouts.length(), 2)
  assert_eq(
    layouts.layout_of(collected.declarations[0].id).unwrap(),
    layouts.layouts[0],
  )
  assert_eq(
    layouts.layout_of(collected.declarations[1].id).unwrap(),
    layouts.layouts[1],
  )
  assert_eq(layouts.layout_of(collected.declarations[2].id), None)
}
