# Self-host body flow

Date: 2026-08-21

The Dew semantic port now computes basic control-flow summaries for function and lambda bodies.

Implemented behavior:

- fallthrough, return, break, continue, and divergence outcomes;
- sequencing and branch union;
- `Never` terminal detection;
- block, conditional, match, functional-loop, logical short-circuit, call, construction, assignment, and index evaluation order;
- unreachable block-item diagnostics;
- functional-loop arm fallthrough diagnostics;
- catch-all, Bool, local enum, and imported enum match exhaustiveness;
- redundant catch-all, Bool, and direct variant arms;
- explicit missing catch-all, Bool, and variant case publication;
- deterministic per-body and per-lambda expression, block, arm, and diagnostic output;
- iterative alternative-pattern catch-all traversal.

Diagnostics are now sorted by source offset and stable diagnostic rank. Alternative-variant flattening and invalid-pattern suppression remain to reach full MoonBit flow parity.
