# Self-host module-value dependencies

Date: 2026-08-21

The Dew semantic port now builds deterministic module-level `let` dependencies and a dependency-first SCC schedule.

Implemented behavior:

- direct module-value reference collection from resolved body names;
- per-body dependency deduplication and source-index sorting;
- iterative forward and reverse reachability SCC discovery;
- source-order members within each SCC;
- iterative dependency-first component scheduling;
- mutual-cycle and self-cycle preservation;
- 1,024-value chain coverage without recursive compiler traversal.

The current SCC implementation uses bounded repeated reachability scans. This is conservative and can be quadratic, but it is deterministic, stack-safe, and adequate for the first fixed point. It can be replaced by a packed reverse graph after self-hosting is stable.

Module-value joint unification and inferred value type publication remain next.
