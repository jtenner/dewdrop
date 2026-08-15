# Complete import-alias namespaces

Date: August 15, 2026

## Status

Implemented end to end.

## Syntax

A qualified import reserves one exact module alias:

```dew
import compiler.ast as @ast
```

The alias can qualify every imported compiler-facing namespace:

```dew
fn inspect(value: @ast.Expr) -> I32 {
  match value {
    @ast.Expr::Name(name) => name.length().to_i32()
    @ast.Expr::Literal(_) => 0
  }
}
```

Supported forms are:

- type positions: `@module.Type` and `@module.Type<t>`;
- trait positions and bounds: `t: @module.Trait`;
- implementation heads: `impl @module.Trait for Local` and `impl @module.Type`;
- enum values and constructors: `@module.Enum::Unit`, tuple, and struct payload forms;
- enum patterns: `@module.Enum::Variant(...)` and struct payload patterns;
- static implementation lookup: `@module.Type::method(...)`;
- existing callable and module-value lookup: `@module.function(...)` and `@module.value`.

The dot selects the imported module member. `::` continues lookup inside a selected type or trait namespace.

## Resolution

Exact aliases do not add names to unqualified lookup. Each qualified type or trait is selected directly from the named frozen interface. Equal names in multiple imported modules remain unambiguous when different aliases are used.

Imported declarations are registered for type arity, body inference, implementation evidence, layout, and linking even when the import is not opened. Registration is separate from exposing a name to unqualified lookup.

Pattern and expression resolution retain imported module roots explicitly. The selected external declaration identity is then reused by ordinary constructor, pattern, method, implementation, and backend paths.

## Diagnostics

Unknown qualified type and trait members use `UnknownType` and `UnknownTrait` at the member location. Unknown pattern aliases use `UnknownPatternImportAlias`. Unknown enum variants keep the ordinary `UnknownVariantForType` diagnostic.

## Artifacts and validation

Parser-event artifacts encode qualified types and import-alias pattern roots. The parser-event cache key was changed so older payloads cannot be reused.

Coverage includes:

- parser AST retention for named/applied types, bounds, implementation heads, expressions, and patterns;
- parser-event binary round trips;
- local implementation of imported traits;
- imported generic types and inherent static methods;
- unit, tuple, and struct enum constructors and patterns;
- exact disambiguation across modules with equal public names;
- deterministic unknown-member and unknown-alias diagnostics;
- cross-module Node and Wago runtime snapshots.
