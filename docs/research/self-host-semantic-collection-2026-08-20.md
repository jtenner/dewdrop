# Self-host semantic collection — August 20, 2026

## Status

The Dew self-host compiler now collects the parser syntax graph into a flat,
source-ordered semantic HIR.

The port adds these files under `self_host/compiler/`:

- `semantic_ids.dew`: packed U64 module, file, declaration, and body identities;
- `semantic_hir.dew`: flat type, expression, pattern, block, arm, and lambda HIR;
- `semantic_model.dew`: collected declarations, namespaces, diagnostics, and
  immutable-by-convention collection output;
- `semantic_collection.dew`: file collection, name interning, declaration
  indexing, duplicate detection, iterative type lowering, and module bindings;
- `semantic_body_lowering.dew`: expression, block, pattern, arm, assignment,
  explicit type argument, and lambda lowering.

Collection supports every parser declaration family, multiple ordered files,
separate type/trait/value namespaces, builtin overload chains, generic and
parameter scopes, fields, enum variants, foreign declarations, tests, imports,
and parser diagnostic preservation.

Valid `derive(Eq)`, `derive(Debug)`, `derive(Hash)`, and `derive(Show)` requests
are retained as collected derive records. Duplicate and unknown requests are
diagnostic. Expansion into synthetic implementation bodies is the first task of
the derivation semantic phase; no valid request is discarded.

## Representation

Entity IDs use the production packed layout:

```text
high 32 bits: module ID
low 32 bits: source-order local ID
```

Arena indexes use U32. Missing optional expression and local indexes use
`0xffffffff` where the production HIR uses `-1`. Declaration locations use the
high bit to distinguish top-level declarations from methods, avoiding signed
index conversion in the Dew runtime.

Types lower through an explicit stack and remain safe for at least 1,024 nested
applications. Children are emitted before parents. Bodies use separate flat
arenas for expressions, blocks, block items, patterns, arms, object fields, and
pattern fields. Lambda bodies have isolated spans and retain their parent lambda
and root body identities.

## Compiler fixes exposed by the port

The larger compiler-shaped source graph found four foundation bugs:

1. `String`, `StringView`, and `Bytes` had content methods but no `Eq` or `Ne`
   implementations. `==` and `!=` now use content equality.
2. Starshine rejected Unit-valued `if` expressions without an `else`. Emission
   now supplies an empty alternative.
3. Empty exact-capacity Array literals unnecessarily used a shared backing
   scratch local. Empty literals now construct their wrappers directly.
4. Starshine `heap2local` could reorder repeated array-allocation writes to one
   scratch local before an earlier wrapper consumed the local. Array literals
   now receive expression-local backing scratch storage, and the pass skips only
   functions where the next allocation can occur before the prior allocation's
   first local read.

The last fix is correctness-first and narrow. Sequential array candidates whose
reads finish before the next write still scalarize, and iterator Option
scalarization is unchanged because it uses struct/variant flows.

The corpus also exposed missing multiline index closing support in the Dew
parser. Newlines before `]` are now accepted.

## Tests

Focused Dew tests cover:

- packed semantic identities;
- source-order declarations and methods;
- name interning and namespace separation;
- nested and 1,024-deep type HIR;
- builtin overload chains;
- duplicate owner scopes;
- parser recovery;
- foreign declarations;
- tests and derive diagnostics;
- ordered multi-file collection;
- expression child order;
- functions, lets, implementations, assignments, matches, functional loops,
  patterns, lambdas, objects, calls, and multiline indexes.

`tools/check-self-host-semantics.py` runs diagnostic-free collection over all
checked-in Dew sources whose snapshot expects successful semantic analysis. It
covers the standard library, self-host compiler, and successful module snapshot
sources in bounded batches.

Backend regressions cover Unit `if` emission and mixed Array fields with
different element carriers. The mixed-field fixture executes in both Node and
Wago.

## Next phase

1. Expand collected derive requests into deterministic synthetic impl HIR.
2. Port resolved type interning and signature resolution.
3. Add alias dependency collection, SCC cycle diagnostics, and normalization.
4. Port module interface freezing and imported type/trait scopes.
5. Replace recursive body lowering with the production explicit task stack
   before compiler stress and fixed-point work.
