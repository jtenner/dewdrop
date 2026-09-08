# Lowered body cycles — next checked boundary

Status: both boundary checks are implemented and validated.

The existing lowered-body child checks prove spans, body ownership, local IDs,
and capture availability. They do not prove that the syntax graph is acyclic.
An expression can name itself as its unary operand and still pass ownership.
Likewise, a block expression can select the block which contains that expression.
Neither is a valid lowered syntax graph; a task-based emitter can loop forever.
Do not reproduce this by running an unbounded emitter. Check the arena boundary
directly first. The two native regressions in `planned_body_cycles_wbtest.mbt`
both return Ok on the old checker instead of the required ARN-108 record
(10.075 seconds). No unbounded emitter was run.

Both compilers use the existing exhaustive child-edge visitors. The
block, pattern, and arm loop bodies are visitors too, rather than maintaining a
second expression-kind switch. The graph includes expressions, blocks, patterns,
and arms. Local slots, capture metadata, declaration/type references, and control
labels are not syntax edges. Loop control-flow cycles are valid and must not be
rejected as syntax cycles. Shared children in a DAG are also valid.

An explicit depth-first enter/leave work stack avoids recursion and arbitrary
depth limits. Each node has unseen/active/done state. Bounds-check a child before
mapping its arena ID to the packed node index. An edge to an active node is the
cycle witness. A done node is reusable. Enter events can be duplicated; done
events are skipped, while each entered node receives one leave event. A single
U64 event word stores the node and enter/leave bit, so there are no parallel
work arrays that can lose alignment. No copy of the edge graph is needed.

Constructor target IDs in the self-host IR are source metadata, not evaluations;
lowering consumes those targets separately. Unit constructors can name their
own expression. Their ownership remains checked, but they are not graph edges.

Total node-count arithmetic is checked before allocation. Existing error
records for bad spans and owners remain. Stable ARN-108 reports a syntax cycle, with
phase/module/declaration/body, a relevant expression when available, expected
inactive state 0, actual active state 1, and detail `(child arena tag << 32) |
child global ID`. Existing arena tags are expression 1, block 3, pattern 4,
and arm 5. A block-to-expression witness can report that child expression.

Tests must include self and multi-node expression cycles, block/expression and
pattern cycles, an acyclic shared child, ordinary loop/continue flow, and a long
valid chain without a semantic depth cap. Self-host negative probes must check
the entire numeric record, not just the trap. Keep the graph checks at the
existing physical entry and final verification boundaries. This is structural
correctness work, not carrier evidence propagation or speed tuning.

## Validation

- The first two native regressions pass after the implementation (9.858 seconds).
- Expanded native tests first exposed a fixture type error: a pattern name is
  a numeric name ID, not a String (1.566 seconds). Both fixtures now use a name ID.
- All six native cycle/acyclic tests then pass (9.704 seconds), including a
  5,001-node forward chain, shared children, and loop/continue control.
- The self-host lane includes seven new tests and five complete ARN-108 records.
- Initial self-host builds caught an invalid generic constructor syntax, a
  misplaced context field, and a fixture diagnostic lookup on the wrong record
  (104.223 and 14.477 seconds). These were corrected without relaxing checks.
- Full self-host hardening passes 422 tests, 119 exact records, and every
  execution corpus (55.380 seconds).
- Full native passes all 1,096 tests (151.316 seconds).
- Shared-child tests also include two pending sibling edges with a cross-edge,
  so a duplicate white-node event must be skipped after that node finishes.
  All six strengthened native tests pass (9.781 seconds); full self-host
  hardening again passes 422 tests, 119 records, and all execution probes
  (71.793 seconds, including time waiting for the native integration lane).
- All 268 integration tests pass (57.743 seconds).
- Clean bootstrap passes (171.932 seconds). Compiler B/C raw and linked
  SHA-256 all match:
  `15dfb833a91fb7cc3dd38b638741194dc6577ad3e725baa1fb736d91739b30f7`.
- The library lane passes 326 tests and every shared execution corpus
  (32.963 seconds). Generated checks pass (12.793 seconds).
- All 15 stress tests pass (0.343 seconds). Provider code is unchanged.

Runs exceeding 30 seconds remain speed defects. This change does not tune them.
Other arena consumers and the rest of the compiler audit remain separate work.
