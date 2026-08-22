# Self-host I32 locals and blocks

Date: 2026-08-22

The linked I32 emitter now supports block sequencing and scalar locals.

Added instruction support:

- local declaration groups;
- `local.get`;
- `local.set`;
- expression-result `drop`;
- nested lowered blocks;
- sequential `let` initialization;
- mutable local assignment.

The smoke request now compiles:

```dew
pub fn main() -> I32 {
  let value = 70
  value + 3
}
```

The output is validated and checked for the exact constant, local write, local read, and addition instructions.

This work found and fixed a lowering defect: `SelfHostHirBlockItem::LetItem` was reading the name offset as the initializer expression. The corrected field order now publishes the actual initializer ID.

Parameters, calls, branches, loops, aggregates, references, and multiple function bodies still require complete physical body emission.
