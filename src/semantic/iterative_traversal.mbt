///|
/// Debug-visible invariant for iterative traversals represented by parallel
/// integer stacks. It is called at push/pop boundaries, not inside indexed hot
/// loops.
fn assert_aligned_traversal_stacks(
  tasks : Int,
  states : Int,
  result_starts : Int,
) -> Unit {
  guard tasks == states && tasks == result_starts else {
    abort("iterative traversal stacks are not aligned")
  }
}

///|
fn assert_aligned_traversal_stacks4(
  owners : Int,
  tasks : Int,
  states : Int,
  result_starts : Int,
) -> Unit {
  guard owners == tasks && tasks == states && tasks == result_starts else {
    abort("iterative traversal stacks are not aligned")
  }
}

///|
/// Advances reusable generation marks without clearing on ordinary traversals.
/// A wrapped generation clears marks once and resumes at generation one.
fn next_traversal_generation(marks : Array[Int], generation : Int) -> Int {
  let next = generation + 1
  if next == 0 {
    marks.fill(0)
    1
  } else {
    next
  }
}

///|
fn append_int_result_range(
  source : Array[Int],
  start : Int,
  end : Int,
  target : Array[Int],
) -> Unit {
  guard start >= 0 && start <= end && end <= source.length() else {
    abort("iterative traversal result range is invalid")
  }
  for index in start..<end {
    target.push(source[index])
  }
}
