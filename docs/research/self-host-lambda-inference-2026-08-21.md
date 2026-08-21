# Self-host lambda inference

Date: 2026-08-21

The Dew semantic port now runs basic inference for lambda bodies.

Implemented behavior:

- lambda-body views over the shared flat HIR arenas;
- resolved lambda parameter and return signatures;
- independent solver jobs in deterministic lambda-ID order;
- expression, local, block, pattern, control, call, selection, and diagnostic output through the ordinary basic inferencer;
- published lambda capture type slots;
- rigid primitive and nominal capture routing from enclosing body locals and earlier parent lambdas;
- iterative product, application, and function capture-graph import from enclosing bodies and parent lambdas;
- mismatch diagnostics when a routed capture conflicts with the lambda signature;
- compaction of lambda body inference arenas with the ordinary body compactor.

Lambda families still need final joint result merging and rebasing before lowering.
