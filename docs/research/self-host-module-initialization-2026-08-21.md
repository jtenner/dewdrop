# Self-host module initialization

Date: 2026-08-21

The Dew semantic port now plans module-level initialization from inferred module values.

Implemented behavior:

- dependency-first eager initialization steps;
- declaration-to-step lookup slots;
- preserved inferred module-value types;
- self-cycle and mutual-cycle detection;
- grouped cyclic initialization steps;
- stable eager-cycle diagnostics and source offsets;
- test-only SCC classification;
- iterative 1,024-value chain coverage.

This plan is the first lowering-adjacent artifact after body inference and flow. Function planning, layouts, specialization, and expression lowering remain next.
