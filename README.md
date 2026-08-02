# Dewdrop

Dewdrop is the reference compiler and standard library for **Dew**, an experimental statically typed language targeting WebAssembly GC. The compiler is written in MoonBit and emits deterministic modules through [Starshine](https://github.com/jtenner/starshine-mb).

The implementation emphasizes runtime performance, low memory use, deterministic compilation, stack-safe streaming frontends, immutable semantic phase boundaries, and mechanically validated WasmGC emission.

## Current capabilities

- Refillable raw-file-descriptor WTF-8 source cursor.
- Streaming lexer with two decoded units of lookahead.
- One-token-lookahead, non-backtracking parser with shunting-yard expressions.
- Deterministic multi-file and multi-module semantic analysis and static linking.
- Traits, implementations, structs, optimized subtype-family enums, aliases, patterns, matches, and functional control-flow analysis.
- Compiler-owned generic `Option`, `Result`, `FixedArray`, `Map`, and `Set` representations.
- Collision-safe `Hash` semantics and deterministic separate-chaining Map/Set storage.
- Unboxed scalar, SIMD, SWAR, and WasmGC reference carriers, including `let mut` locals and shared boxed mutable closure captures.
- Strict UTF-8 `String`/`StringView`, arbitrary `Bytes`, builders, search, slicing, and WASI Preview 1 staging.
- Deterministic `_test.dew` discovery, expected traps, and Node/Wago differential execution.
- Persistent content-addressed frozen standard-interface caching.

See [`docs/spec.md`](docs/spec.md) for the language and compiler specification, [`docs/roadmap.md`](docs/roadmap.md) for planned work, and [`agent-todo.md`](agent-todo.md) for the detailed implementation backlog.

## Checkout

The current MoonBit workspace expects Starshine as a sibling checkout:

```sh
git clone https://github.com/jtenner/starshine-mb.git
# Clone Dewdrop beside it so the directories are ../starshine-mb and ./dewdrop.
git clone https://github.com/jtenner/dewdrop.git
cd dewdrop
```

Required development tools include MoonBit, Python 3, Node.js, and Go. Node and Go are used by the integration and differential Wasm runners.

## Build and check Dew programs

```sh
tools/dew check path/to/main.dew
tools/dew build path/to/main.dew -o program.wasm
tools/dew build --emit wat path/to/main.dew -o program.wat
tools/dew build --emit hir path/to/main.dew -o program.hir
tools/dew build --emit lowering path/to/main.dew -o program.lowering
tools/dew run path/to/main.dew
```

Multi-module programs use repeated `--module NAME` arguments or strict `dew.json` manifests. Compiler-owned standard sources are loaded from deterministic registered paths; `--bootstrap-std` selects generated fallback sources.

Programs with non-constant module-level values export `__dew_init`. Dew-owned hosts call it exactly once after instantiation and before `main` or test entry points, allowing initialization to use host imports without relying on a WebAssembly start section. Public module-level `let` values are available through `open` and `@alias.value`; their inferred scalar, nominal, and applied generic types are frozen into module interfaces. Public non-foreign implementation evidence is likewise frozen with exact method identities, while test-only, private-head, and `foreign impl` evidence remains module-local. Consumer coherence rejects overlapping local/imported or independently imported trait implementations before dispatch. Reachable nominal dependencies close across modules, and mutually recursive physical WasmGC types are emitted as deterministic shared recursive groups. First-class functions use structural `fn(T, ...) -> R` types and a WasmGC closure ABI. Explicit typed lambdas may capture lexical values, nest, escape through returns, pass as parameters, initialize module values, and cross module boundaries. Named non-generic functions and lambdas share one closure representation while calls retain typed direct or environment-first `call_ref` signatures. Uncaptured `let mut` bindings remain unboxed Wasm locals; captured mutable bindings use one carrier-specialized shared WasmGC cell visible to the declaring body and all direct, nested, sibling, returned, or directized closures. Generic/overloaded function-reference disambiguation remains pending.

## Tests

Run the fast native validation loop:

```sh
tools/check.sh --quick
```

Run the complete validation entry point:

```sh
tools/check.sh
```

The full suite covers native, WasmGC, JavaScript, and classic Wasm MoonBit targets; standard-library tests; SWAR, UTF, and WASI parity; Starshine validation; and differential Node/Wago module snapshots.

Run explicit Dew tests with:

```sh
tools/dew test --module app.main path/to/example_test.dew
```

Dew files ending exactly in `_test.dew` are test-only. Expected runtime traps are declared in test metadata rather than inferred by the runner.

## Example

```dew
open dew.std.map
open dew.std.set

pub fn main() -> Bool {
  let counts = Map::singleton(1, 10)
  counts[1] = 11

  let seen = Set::singleton(1)
  seen.insert(17)

  counts[1] == 11 && seen.contains(17)
}
```

## Repository layout

```text
src/tokenizer/       streaming source cursor and lexer
src/parser/          forward-only parser and AST event stream
src/semantic/        collection, inference, layouts, lowering, and linking
src/backend/         deterministic Starshine/WasmGC emission
std/                 Dew standard-library sources
tests/               CLI and differential module snapshots
tools/               compiler wrappers, generators, runners, and parity suites
docs/research/       implementation notes and design measurements
```

## Status

Dew is under active development. The compiler and standard library are usable for the supported subset, but package TOML/lockfiles, general executable generic functions and aggregates, mutable scalar assignment/capture cells, growable arrays, queues, iterators, and several tooling surfaces remain planned.

## License

The project is licensed under Apache-2.0. Third-party attribution is recorded in [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
