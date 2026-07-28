# Agent Guidelines

- Use test-driven development where it is appropriate.
- Keep commits atomic, bounded, and easy to review.
- Adding tests that currently fail is acceptable; a failing suite is not itself a blocker.
- Do not write fail-closed tests. Failures must remain visible and diagnostic.
- Store research notes in `docs/research/*.md`.
- Update and organize documentation with every commit; keep it consistent with the implementation.
- Design for modularity and performance. Runtime performance is the highest priority, followed by a low memory footprint.
