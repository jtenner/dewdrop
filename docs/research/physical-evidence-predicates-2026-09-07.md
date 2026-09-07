# Checked physical evidence predicates

## Defect and scope

The native optimizer rejected concrete trait evidence after depth 64. Fragment
planning had a different recursive predicate and silently rejected invalid IDs,
spans, and deep/cyclic graphs. Both paths could treat erroneous shape arguments
as concrete. Forwarding, runtime classification, and dependency collection also
used recursive evidence walks with silent failure paths.

The focused depth-65 test failed against the old code (8.900 seconds). The new
shared predicate first validates the full graph, then visits evidence and product
shapes with explicit worklists. A seen-node table preserves shared subgraphs.
Generic evidence stays pending. Error shapes report SPC-301 with the exact
argument index. Invalid generic ordinals report EVD-212. A 65,536-work limit
reports EVD-213 instead of returning false, including cyclic mutable shape
storage. Whole-graph validation prevents a pending child from hiding a cycle.

The optimizer, fragments, linker, and specialization planner share this check.
Forwarding accepts bound evidence but not guarded evidence awaiting selection.
The runtime classifier uses a checked postorder worklist and preserves direct
versus captured evidence. Invalid bound slots are errors. Implementation-use
collection checks the graph before recording dependencies, then walks each node
once without recursion.

These are evidence-validity checks, not a complete physical carrier certificate.
Full reference heap-type and nullability checks remain separate work.

## Regression coverage

Eight focused tests cover deep concrete and runtime evidence, pending shapes,
later Error siblings, invalid ordinals, cycles, owned spans, missing roots,
shared graphs, and recursive shape limits. Mutation tests restore the valid
fixture and check it again. The recursive shape test breaks its intentional
storage cycle before checking the result, so the test does not leak that cycle.
The final eight tests pass in 9.181 seconds. Negative bound slots, guarded source
type IDs, and runtime parameter slots fail before forwarding or key publication.

## Verification

- Native suite: 1,011 tests pass in 124.423 seconds; the final negative-ID guard
  and eighth focused test were added afterward and pass separately. Semantic
  tests took 73.483 seconds. These are speed bugs; no speed code was changed.
- Native integration: 268 tests pass in 49.612 seconds (aggregate speed bug).
- Library: 326 tests and all shared execution corpora pass in 23.449 seconds.
- Generated-source and policy checks pass in 15.583 seconds.
- Self-host hardening: 311 tests, 65 exact invariant records, and all shared
  execution corpora pass in 61.572 seconds. Generation took 21.826 seconds.
- Clean bootstrap: A/B/C validation passes in 157.757 seconds. B/C core and
  linked bytes match. Linked SHA-256 remains
  `df4aa9c5ae4618ce0a1721d20cd6bffd9664df3fe102d510e0e35ba86e4b56f5`.
  Compiler A build took 39.547 seconds; A execution took 41.610 seconds;
  B execution took 54.500 seconds. These remain speed bugs, as do native
  backend tests at 38.396 seconds and the aggregate hardening/bootstrap lanes.

The shared key file was formatted while adding its negative-ID check. No
storage layout, reference assignability, or emission-stack work is claimed by
this batch. The separate solver lifecycle regression file starts the next batch
and is not included in this commit.
