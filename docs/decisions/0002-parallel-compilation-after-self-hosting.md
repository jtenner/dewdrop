# 0002: Parallel compilation after self-hosting

- Status: Accepted
- Date: 2026-08-14

## Context

The current Dewdrop compiler is written in MoonBit. MoonBit cannot execute the
compiler's independent module and body jobs in parallel. Keeping worker
scheduling in the active roadmap implies an implementation path that the current
host language cannot provide.

Dewdrop still uses deterministic IDs, immutable phase outputs, job-local scratch
state, and stable merge order. These contracts support incremental compilation
today and preserve a path to parallel compilation later.

## Decision

Do not implement internal parallel compiler scheduling in the MoonBit compiler.
Remove worker scheduling, completion-order testing, and parallel-output checks
from the active execution backlog.

Revisit parallel compiler jobs only after both conditions are true:

1. Dewdrop is self-hosted.
2. Dew provides the required parallel-computation features.

At that point, independent module and body jobs can run concurrently. Diagnostics,
artifacts, and final indices must still merge in deterministic source and manifest
order, and sequential and parallel builds must produce byte-identical output.

## Consequences

- Layout and WasmGC fragment caching remains the next compiler-cache milestone.
- Current performance work must improve sequential and incremental compilation.
- The MoonBit compiler has no worker-pool or parallel-scheduling release goal.
- Existing deterministic phase boundaries remain useful and must not be weakened.
- Parallel compiler work returns to the active roadmap only after self-hosting.

## Evidence and related documents

- [`../roadmap.md`](../roadmap.md)
- [`../../agent-todo.md`](../../agent-todo.md)
- [`0001-compiler-phase-and-arena-boundaries.md`](0001-compiler-phase-and-arena-boundaries.md)
