# Self-host inference arena merge

Date: 2026-08-21

The Dew semantic port now merges independent body and lambda inference jobs into one deterministic module artifact.

The merger:

- emits body jobs first in body order and lambda jobs next in lambda-ID order;
- rebases positive body-type IDs while preserving rigid negative resolved-type IDs;
- rebases product, application, and function type graphs;
- rebases expression, local, capture, block, pattern, and control type arrays;
- rebases call, expression-construction, and pattern-constructor type-argument spans;
- preserves selections, unsupported-expression markers, and source diagnostics;
- rebases type IDs embedded in local mismatch and infinite-type diagnostics.

Each merged job publishes exact spans for its contribution to every shared arena. This provides the stable module-level input required by lowering without allowing positive solver-local type IDs to cross job boundaries.
