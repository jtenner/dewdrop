# Self-host merged body value shapes

Date: 2026-08-21

Lowering can now classify merged body and lambda type IDs into backend value shapes.

The planner:

- preserves rigid negative resolved-type references;
- resolves merged positive body-type IDs;
- follows applied types to their representation base;
- classifies function types as references;
- classifies unresolved variables and invalid IDs as errors;
- builds ordered nested product shapes;
- uses an explicit task stack for deep product graphs.

This connects deterministic inference arena merging to the existing resolved-type ABI shape planner and provides the shape operation needed by expression, local, capture, and result lowering.
