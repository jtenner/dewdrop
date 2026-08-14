# Architecture decision records

This directory records accepted cross-cutting architecture boundaries. It is not
a replacement for implementation research in `docs/research/`, language rules
in `docs/spec.md`, or execution priorities in `docs/roadmap.md`.

Use a decision record when a choice affects multiple compiler phases, packages,
persistent formats, or long-lived contributor expectations.

## Status vocabulary

- **Accepted:** current direction; implementation may still be incremental.
- **Superseded:** replaced by a later decision record.
- **Rejected:** considered and deliberately not adopted.

## Records

- [`0001-compiler-phase-and-arena-boundaries.md`](0001-compiler-phase-and-arena-boundaries.md)
  — preserve flat arenas while making phase ownership and mutation explicit.
- [`0002-parallel-compilation-after-self-hosting.md`](0002-parallel-compilation-after-self-hosting.md)
  — defer compiler job parallelism until Dewdrop is self-hosted.
- [`0003-unified-aligned-cache-pack.md`](0003-unified-aligned-cache-pack.md)
  — replace per-module cache I/O with one aligned BLAKE3 pack and exact warm results.

## Record template

```markdown
# NNNN: Decision title

- Status: Proposed | Accepted | Superseded | Rejected
- Date: YYYY-MM-DD

## Context

## Decision

## Consequences

## Evidence and related documents
```

Keep records short. Put benchmark logs, alternatives, and detailed implementation
notes in `docs/research/` and link them from the record.
