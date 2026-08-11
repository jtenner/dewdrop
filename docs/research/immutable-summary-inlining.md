# Immutable-summary inlining

Date: 2026-08-11

The copied whole-program lowering plan now derives deterministic immutable summaries for two bounded classes of non-generic free functions:

- scalar parameter selectors that return one I32/U32/I64/U64 carrier parameter through transparent immutable local aliases;
- zero-parameter Bool/I32/U32/I64/U64 constant functions after constant folding.

Selector calls rewrite to `PlannedParameterSelect`. That node evaluates every original argument exactly once in source order, discards unselected carriers, and returns the selected argument without a call. Constant calls rewrite directly to the summarized constant and are limited to zero-argument functions so no argument effects can be lost. Summary discovery and call rewriting iterate to a deterministic fixed point, allowing transparent wrapper chains to collapse transitively.

Reference, trait-object, callback, receiver, generic, effectful, and non-scalar cases are intentionally excluded. This preserves existing runtime-trait and callback directization boundaries and avoids cloning arbitrary local/control-flow graphs before a more general cost model exists.

The checked-in inlining fixture retains only the two effectful `record_value` calls. The `second`, transitive `wrapper`, and folded `answer` calls disappear, while the state assertion proves that both selector arguments still execute left-to-right exactly once. The WAT budget forbids dynamic dispatch/table/global machinery and pins the remaining direct-call count at two.
