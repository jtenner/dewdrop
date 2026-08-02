# Semantic declaration collection

Date: 2026-07-29

## Scope

The first semantic package is implemented in `src/semantic/`. It consumes the parser's lazy `Iter[ParseEvent]` directly and produces one module-local `CollectedModule` containing:

- stable declaration and member identities;
- module-local interned names;
- separate type, trait, and value namespaces;
- source-ordered builtin overload chains;
- duplicate-name and parser diagnostics;
- stable identities for fields, enum variants, generic parameters, and value parameters;
- compact callable, builtin-registry, module-let, alias, and impl signature records;
- child-first flat HIR for every declaration-level type expression;
- stable executable body IDs;
- flat expression, block, pattern, object-field, and pattern-arm HIR.

Module lets, functions, and impl methods lower their executable bodies during the same event-consumption pass. Recursive parser declarations and body ASTs become unreachable immediately after collection. The executable arena design is detailed in `docs/research/executable-body-hir.md`.

## Stable identities

Every semantic identity is a packed `UInt64`:

```text
high 32 bits: deterministic ModuleId
low 32 bits:  module-local source-order index
```

Top-level declarations and nested trait/impl methods share one declaration index sequence. This gives methods stable `DeclId` values without a global allocator. A compact signed location array maps the local declaration component directly to either a top-level declaration index or a method index, so downstream phases do not scan the separate arenas. Fields, variants, generic parameters, and value parameters each use independent module-local sequences because their ID kinds are semantically distinct.

Module IDs must eventually be assigned from a deterministic module-path ordering before modules are collected in parallel. Collection itself performs no global allocation and writes only its own module artifact.

## Name interning

Each module owns one `Map[String, NameId]` and one source-order `Array[String]`. The same spelling used by declarations, fields, variants, generic parameters, parameters, and type syntax resolves to one module-local `NameId`.

The collector does not require a global concurrent string interner. Future cross-module lookup can use exported spellings and stable string hashes while retaining module-local IDs internally.

## Namespaces and overloads

Collection builds three independent module namespaces:

- type declarations: structs, enums, and aliases;
- trait declarations;
- value declarations: builtins, lets, and functions.

A type, trait, and value may therefore currently share one spelling. Repeated types, traits, ordinary functions, or lets produce `DuplicateName` diagnostics while all declarations retain stable IDs for continued analysis.

Dew-visible builtin names are explicitly overloadable. Value candidates use a flat source-ordered linked array rather than allocating one `Array[DeclId]` for every value name. `CollectedModule::value_declarations` iterates an overload set without constructing a result array.

Trait method overloading remains an open language question. The initial collector diagnoses repeated trait method names. Impl method names, struct fields, struct-like variant fields, enum variants, generic parameters, and parameters are also checked in their immediate owner scope.

## Type HIR

Parser `TypeExpr` trees are lowered into two flat arrays:

```moonbit
pub enum HirTypeSyntax {
  NamedTypeSyntax(NameId, UInt64)
  AppliedTypeSyntax(HirTypeId, HirSpan, UInt64)
}
```

`HirTypeId` is a module-local array index. Applied-type arguments occupy spans in a shared `Array[HirTypeId]`. Children are emitted before parents, allowing future resolution to process the arena in source-independent postorder without recursive tree traversal.

Lowering itself is iterative. A 1,024-level applied type produces 2,049 HIR nodes without recursive MoonBit calls. The collection builder owns reusable source, state, result, and list scratch arrays, so repeated type lowering does not allocate traversal stacks for every signature.

Builtin registry bytes, module-let mutability, and foreign-impl status are retained in dedicated compact records. Signature HIR is retained for:

- builtin parameters and returns;
- function and method receiver/parameter/return types;
- struct and struct-like variant fields;
- tuple variant payloads;
- alias targets;
- impl trait and target types.

Generic-parameter and parameter spans are indexed directly by the declaration ID's local component.

## Duplicate detection

Small declaration-local scopes use direct scans over their newly appended arena span. Scopes larger than eight entries switch to a temporary hash map. This avoids a hash-table allocation for the common one-parameter or one-generic declaration while preventing quadratic behavior for adversarially large declarations.

Module namespace duplicate detection remains expected constant time through persistent module-local maps. The first declaration remains the namespace binding; later duplicates retain IDs and produce diagnostics carrying both identities and offsets.

Parser diagnostics are preserved in event order, and collection continues after parser recovery.

## Parallelization properties

Collection already follows the intended future threaded contract:

- one job owns one module builder;
- no global mutable state is read or written;
- IDs do not depend on worker scheduling;
- scratch arrays are builder-local;
- diagnostics are module-local;
- the resulting artifact is frozen by convention;
- module namespace maps are read-only after `finish`.

MoonBit currently drives this sequentially. A self-hosted compiler can run `collect_module` independently for every parsed module once deterministic module IDs have been assigned.

## Complexity

For `N` parser events, `T` type-syntax nodes, and `B` executable body nodes:

- event consumption is `O(N)`;
- name interning and module binding are expected `O(1)` per name;
- type lowering is `O(T)` time and `O(depth)` reusable scratch space;
- body lowering is `O(B)` time with reusable iterative task storage;
- common small owner scopes use bounded linear scans;
- large owner scopes use expected-linear hash-table duplicate detection.

The output retains compact semantic records, type HIR, and executable HIR. It retains neither recursive declaration type trees nor executable parser ASTs.

## Tests

`src/semantic/collect_wbtest.mbt` covers:

- deterministic packed IDs across top-level declarations and nested methods;
- stable parent relationships and constant-time declaration-ID lookup;
- field, variant, generic-parameter, and parameter IDs;
- module-local name reuse;
- separate module namespaces;
- duplicate diagnostics in every implemented owner scope;
- source-ordered builtin overload sets;
- parser diagnostic preservation and continued collection;
- flat nested type HIR;
- callable, alias, impl, generic-parameter, and parameter metadata;
- iterative lowering of a 1,024-level applied type;
- hash-backed duplicate detection for owner scopes wider than eight entries;
- iterative collection of a 1,024-declaration module.

Executable body coverage lives in `src/semantic/body_hir_wbtest.mbt` and is documented in `docs/research/executable-body-hir.md`.

## Benchmarks

Release-mode benchmarks are in `src/semantic/collect_bench_test.mbt`. Times compare only within one backend runner.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| collect-only aliases, n=256 | 105.71 us | 64.93 us | 200.17 us | 301.57 us |
| parse and collect pre-tokenized aliases, n=256 | 225.82 us | 128.98 us | 263.54 us | 649.12 us |
| tokenize, parse, and collect aliases, n=256 | 410.06 us | 416.76 us | 484.91 us | 1.19 ms |
| collect-only mixed declarations with bodies, n=192 | 103.01 us | 64.97 us | 239.91 us | 280.49 us |
| tokenize, parse, and collect mixed declarations with bodies, n=192 | 438.31 us | 443.99 us | 542.86 us | 1.31 ms |
| collect-only function bodies, n=256 | 248.74 us | 193.91 us | 643.15 us | 701.62 us |
| parse and collect function bodies, n=256 | 519.03 us | 348.45 us | 840.36 us | 1.40 ms |
| tokenize, parse, and collect function bodies, n=256 | 936.99 us | 994.39 us | 1.30 ms | 2.62 ms |
| collect-only match body, arms=256 | 46.62 us | 45.41 us | 97.05 us | 137.08 us |
| tokenize, parse, and collect match body, arms=256 | 146.77 us | 119.73 us | 211.43 us | 418.17 us |
| collect-only nested type, depth=256 | 24.47 us | 13.50 us | 39.30 us | 74.36 us |

Reusable type and body traversal storage, small-scope duplicate scans, and consolidated value-binding metadata keep collection allocation-conscious. The native function workload lowers 256 complete bodies in about 249 microseconds.

## Next steps

Declaration-level type resolution, transparent alias normalization, and body-local name/control resolution are now implemented in `docs/research/declaration-type-resolution.md`, `docs/research/transparent-alias-normalization.md`, and `docs/research/body-name-resolution.md`. The next steps are:

Body-local type terms, union-find unification, occurs checking, rollback snapshots, and zonking are now implemented in `docs/research/body-local-unification.md`. The remaining next steps are:

Literal, local, block, return, `if`, and structural operator constraints are now generated as documented in `docs/research/basic-body-type-inference.md`. The remaining next steps are:

Direct and generic calls plus rollback-based builtin overload selection are now implemented in `docs/research/direct-generic-overload-call-inference.md`. The remaining next steps are:

Module-let dependency SCC inference is now implemented in `docs/research/module-value-scc-inference.md`. The remaining next steps are:

Pattern/loop inference, structured flow, objects, enum constructors, fields, impl indexing, static/instance method selection, and backend-neutral lowering plans are implemented. Remaining next steps include indexing, generic trait obligations, trait objects, runtime layouts, and Starshine emission.
