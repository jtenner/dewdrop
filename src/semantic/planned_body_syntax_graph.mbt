///|
priv struct PlannedBodySyntaxWalk {
  ends : Array[Int]
  states : Array[Int]
  // One event word: node in the high bits, enter/leave in the low bit.
  events : Array[UInt64]
}

///|
fn PlannedBodyChildChecker::syntax_child(
  self : PlannedBodyChildChecker,
  parent : Int,
  child : Int,
  tag : Int,
) -> Unit {
  let walk = match self.syntax_walk {
    Some(walk) => walk
    None => return
  }
  // Metadata references are owned, but they are not syntax edges.
  let node = match tag {
    1 => child - self.body.expressions.start
    3 => walk.ends[0] + (child - self.body.blocks.start)
    4 => walk.ends[1] + (child - self.body.patterns.start)
    5 => walk.ends[2] + (child - self.body.pattern_arms.start)
    _ => return
  }
  // owned() checked the child before subtraction; ends were checked at entry.
  match walk.states[node] {
    0 => walk.events.push(node.to_uint64() << 1)
    1 =>
      self.fail(
        108,
        if parent != -1 {
          parent
        } else if tag == 1 {
          child
        } else {
          -1
        },
        0UL,
        1UL,
        (tag.to_uint64() << 32) | child.to_uint64(),
      )
    2 => ()
    state => self.fail(108, parent, 2UL, state.to_uint64(), node.to_uint64())
  }
}

///|
fn PlannedBodyChildChecker::verify_syntax_graph(
  self : PlannedBodyChildChecker,
) -> Unit {
  let body = self.body
  let ends : Array[Int] = []
  let mut total = 0
  for
    length in [
      body.expressions.length,
      body.blocks.length,
      body.patterns.length,
      body.pattern_arms.length,
    ] {
    if length > 2147483647 - total {
      self.fail(
        101,
        -1,
        (2147483647 - total).to_uint64(),
        length.to_uint64(),
        24UL << 32,
      )
      return
    }
    total += length
    ends.push(total)
  }
  let walk : PlannedBodySyntaxWalk = {
    ends,
    states: Array::make(total, 0),
    events: [],
  }
  self.syntax_walk = Some(walk)
  for seed in 0..<total {
    if walk.states[seed] != 0 {
      continue
    }
    walk.events.push(seed.to_uint64() << 1)
    while walk.events.pop() is Some(event) {
      let encoded_node = event >> 1
      if encoded_node >= total.to_uint64() {
        self.fail(104, -1, total.to_uint64(), encoded_node, 24UL << 32)
        return
      }
      let node = encoded_node.to_int()
      if (event & 1UL) != 0UL {
        if walk.states[node] != 1 {
          self.fail(
            108,
            -1,
            1UL,
            walk.states[node].to_uint64(),
            node.to_uint64(),
          )
          return
        }
        walk.states[node] = 2
        continue
      }
      if walk.states[node] == 2 {
        continue
      }
      if walk.states[node] != 0 {
        self.fail(108, -1, 0UL, walk.states[node].to_uint64(), node.to_uint64())
        return
      }
      walk.states[node] = 1
      walk.events.push(event | 1UL)
      if node < ends[0] {
        let expression = body.expressions.start + node
        self.expression_edges(
          expression,
          self.lowering.expressions[expression].kind,
        )
      } else if node < ends[1] {
        self.block_edges(body.blocks.start + (node - ends[0]))
      } else if node < ends[2] {
        self.pattern_edges(body.patterns.start + (node - ends[1]))
      } else {
        self.arm_edges(body.pattern_arms.start + (node - ends[2]))
      }
      if self.failure is Some(_) {
        return
      }
    }
  }
  self.syntax_walk = None
}
