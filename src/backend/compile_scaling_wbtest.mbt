///|
test "effect worklist equals full fixed point on chains cycles and unknown calls" {
  let empty = @representation.EffectMask::empty()
  let all = starshine_fact_all_effects()
  // Chain, diamond, cycle, self-call, import and two invalid callee indices.
  let calls : Array[Array[UInt]] = [
    [1U],
    [2U],
    [3U],
    [],
    [0U, 2U],
    [6U],
    [5U, 3U],
    [7U],
    [999U],
    [0xffffffffU],
    [],
  ]
  let original = [
    empty, empty, empty, all, empty, empty, empty, empty, empty, empty, empty,
  ]
  let expected = original.copy()
  let mut changed = true
  while changed {
    changed = false
    for function, targets in calls {
      let mut next = original[function]
      for target in targets {
        let index = target.reinterpret_as_int()
        next = next.union(
          if index >= 0 && index < expected.length() {
            expected[index]
          } else {
            all
          },
        )
      }
      if next != expected[function] {
        expected[function] = next
        changed = true
      }
    }
  }
  let actual = original.copy()
  starshine_propagate_fact_effects(actual, calls)
  assert_eq(actual, expected)
  assert_eq(actual[7], empty)
  assert_eq(actual[10], empty)
  assert_eq(actual[0], all)
  // Reverse declaration order must have the same result.
  let reverse_calls : Array[Array[UInt]] = [[], [0U], [1U], [2U]]
  let reverse = [all, empty, empty, empty]
  starshine_propagate_fact_effects(reverse, reverse_calls)
  assert_eq(reverse, [all, all, all, all])
}

///|
test "effect worklist joins distinct bits through a cycle and branch" {
  let empty = @representation.EffectMask::empty()
  let read = @representation.EffectMask::may_read_global()
  let write = @representation.EffectMask::may_write_global()
  let allocate = @representation.EffectMask::may_allocate_gc()
  let effects = [empty, read, write, allocate, empty]
  starshine_propagate_fact_effects(effects, [[1U, 2U], [3U], [3U], [1U], []])
  let cycle = read.union(allocate)
  assert_eq(effects, [
    cycle.union(write),
    cycle,
    cycle.union(write),
    cycle,
    empty,
  ])
}
