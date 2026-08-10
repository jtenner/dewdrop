# Semantic package public-surface audit

Date: August 10, 2026

## Scope

This audit classified declarations exported by `src/semantic` according to their
actual consumers:

1. compiler orchestration (`src/compiler_driver` and compiler executables);
2. persistent interface loading (`src/standard_loader`);
3. backend planning and emission (`src/backend`);
4. semantic black-box benchmarks;
5. white-box semantic tests and same-package implementation files.

The source audit compared top-level `pub fn` declarations with qualified uses in
consumer packages and with black-box benchmark references. Receiver methods were
reviewed separately because MoonBit call syntax does not retain the package
qualifier at the method name.

## Result

The production semantic sources now export 21 fewer top-level functions. The
removed exports were implementation or white-box-test helpers covering:

- raw file-ID packing and unpacking;
- type-constraint origin construction;
- imported body-flow and inference entry points;
- direct interface freezing and import-scope construction;
- test-only collection helpers;
- internal WasmGC physical-count and receiver-layout helpers;
- internal specialization-plan validation.

Test-only synthetic `_test.dew` collection moved into the white-box test support
that uses it rather than remaining in the production package interface.

`src/semantic/pkg.generated.mbti` is the reviewable interface snapshot. Backend
and executable interface snapshots are regenerated when their visible semantic
contracts change.

## Supported contracts

The public semantic surface remains intentionally data-oriented. Its supported
cross-package contracts are:

- ordered manifest/source collection and compiler diagnostics;
- frozen interface serialization and cached-analysis entry points;
- analyzed-program and lowering results consumed by `compiler_driver`;
- module/program WasmGC plans and their zero-allocation query methods consumed by
  `backend`;
- stable semantic IDs and compiler-owned standard identities needed to interpret
  those plans.

Explicit baseline lowering, optimization, specialization, and physical-link
entry points remain public even when production orchestration currently uses a
higher-level wrapper. They are phase contracts used by characterization tests,
benchmarks, and future artifact requests rather than accidental helper exports.

## Package-boundary decision

The package is not split merely to make the file graph look smaller. HIR,
resolved types, inference, lowering, and program planning share compact IDs and
flat arenas; splitting them today would either duplicate broad public model
contracts or require copying large arrays across package boundaries.

Instead, the package uses deep file-level owners and narrow public phase/query
contracts:

- model and flat IR definitions;
- collection and semantic analysis;
- module lowering;
- program optimization;
- specialization planning;
- physical linking.

A future package split requires measurements showing that it does not add arena
copies, boxed wrappers, compile-time regressions, or generated-code regressions.
Until then, `compiler_driver` is the orchestration facade and the generated MBTI
is the enforceable package surface.
