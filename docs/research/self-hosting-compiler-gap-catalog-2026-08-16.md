# Self-hosting compiler gap catalog — August 16, 2026

## Purpose

This document lists the features that Dewdrop cannot use from Dew source today,
but that are needed to move the compiler from MoonBit to Dew.

It separates three kinds of gap:

1. **Hard blocker** — compiler A cannot build compiler B without it.
2. **Port-enabling gap** — Dew can express the work now, but the rewrite would be
   large, error-prone, or slower without a small language or library addition.
3. **Bootstrap-only gap** — needed for the complete `dew` command, but a small
   MoonBit or JavaScript launcher can own it during the first fixed-point build.

This is not a request for MoonBit source compatibility. Dew only needs enough
surface area to implement Dewdrop cleanly and efficiently.

## Audit scope

The production compiler audit includes these packages:

- `src/tokenizer`
- `src/parser`
- `src/semantic`
- `src/backend`
- `src/cache_binary`
- `src/standard_loader`
- `src/core_linker`
- `src/compiler_driver`
- `src/dew_cli`

Tests, benchmarks, generated interfaces, and target stubs were excluded. That
leaves **112 MoonBit files and 105,919 source lines**. The current bootstrap
command under `src/dew_bootstrap` is another **5 files and 1,788 lines**.

Counts below are lexical inventory counts. They show port pressure. They are not
an exact parser-level count.

## Executive result

Dew already has most of the semantic foundation needed for its own compiler:

- structs, enums, aliases, generics, bounds, traits, implementations, and
  derivation;
- mutable locals, mutable fields, arrays, maps, sets, iterators, closures, and
  function values;
- multi-file and multi-module compilation;
- fixed-width arithmetic, Bytes, strings, builders, JSON, binary codecs, and
  BLAKE3 source code;
- functional loops, pattern matching, deterministic cleanup, and Wasm
  intrinsics.

Self-hosting is blocked by one large missing capability:

1. **A compiler host boundary** for input, output, files, environment, and exit.

Dewdrop's linker and newly implemented foreign imports let the Dew compiler link
against a compiled Starshine binary. A Dew-native Starshine replacement is not a
self-hosting blocker.

Before the main port, Dew also needs a small compiler-oriented collection layer:
filled arrays, truncation, cloning, deterministic sorting, and structural
collection operations. Product tuples and conventional loops are not theoretical
hard blockers, but the current compiler uses them enough that adding them before
the port will materially reduce risk.

Optional arguments, exceptions, annotations, higher-kinded types, general
reflection, and a full package manager are **not required** for the first
fixed-point compiler.

## P0 hard blockers

### SH-01 — Compiler host boundary

**Current state:** unsupported from ordinary Dew source.

`std/wasi.dew` exposes only `fd_read` and `fd_write`. `std/io.dew` provides
host-independent Reader and Writer traits, but it intentionally has no paths,
files, arguments, environment, or process exit.

The MoonBit compiler and loader currently call `@fs` 27 times and `@sys` 62
times in the audited compiler scope. The complete bootstrap command needs more.

**Minimum fixed-point API:**

- get command arguments;
- get one environment variable;
- read a complete file as Bytes;
- write a complete file;
- create a directory tree;
- inspect whether a path exists and whether it is a directory;
- atomically publish a file, normally by temporary write plus rename;
- remove a cache file or directory owned by Dewdrop;
- write stdout and stderr separately;
- terminate with an explicit process status.

**Streaming extension:**

The tokenizer currently supports a borrowed file descriptor and refillable
page-sized buffer. The first Dew compiler can read complete source files through
the minimum API, but parity with the current memory contract needs:

- open a path for reading;
- bounded descriptor reads;
- close;
- a stable host error code.

**Required policy:**

- ordinary host errors return `Result`; they do not trap;
- paths have one defined byte/String encoding contract;
- reads and writes are bounded by U32 lengths or use explicit chunking;
- atomic publication remains fail-visible;
- the host API does not expose arbitrary native pointers.

**Bootstrap allowance:**

Process spawning, WAT rendering, Node execution, and package download can remain
in a small launcher. They are not required inside compiler A, B, or C.

### SH-02 — Compiled Starshine foreign dependency

**Current state:** resolved by the Dewdrop linker and Dew foreign imports.

The self-hosted compiler can keep the Starshine boundary. Starshine is compiled
as a foreign binary, linked into the compiler, and called through typed Dew
foreign imports. The fixed-point build must still pin the Starshine binary and
include its exact bytes in the compiler fingerprint, but it does not need a
Dew-native Wasm model, validator, decoder, or encoder.

The 8,688 audited `@lib` references remain porting work at the foreign API
boundary. They are not evidence for a missing Dew language or standard-library
feature.

### SH-03 — Bootstrap source and standard-library provisioning

**Current state:** the MoonBit launcher discovers files, packages, standard
sources, lock records, and static-link inputs before it invokes the compiler.

Compiler A must receive a complete deterministic input set without first
requiring a Dew-native package manager.

**Minimum solution:** keep a small launcher that sends a versioned request with:

- ordered modules;
- ordered logical file paths and source Bytes, or paths available through SH-01;
- the root module;
- standard-library source identity;
- dependency interface expectations;
- static-link provider names and module Bytes;
- cache policy and compiler fingerprint.

The existing private compile-request protocol is a useful starting point, but a
source-Bytes form avoids making package discovery part of the first self-hosted
compiler.

## P1 required library gaps

These features can be implemented in Dew without new type-system work. They
should land before the large compiler port because the current compiler depends
on them pervasively.

### SH-04 — Compiler-grade growable Array operations

**Current state:** implemented on August 16, 2026. `dew.std.array` now has filled
construction, reserve, shrink, truncate, copy/clone, native extend, strict bulk
fill/copy/slice, stable natural and comparator sorting, structural Eq/Ne, and the
broader TypeScript-inspired method surface. Measurements and fixtures are in
[`array-api-and-performance-2026-08-16.md`](array-api-and-performance-2026-08-16.md).

The audited compiler uses:

- `Array::make` 316 times;
- `truncate` 49 times;
- `copy` 31 times;
- `sort` 18 times;
- `sort_by` 26 times.

**Delivered:**

- `Array::make(length, value)`;
- no-reallocation `truncate(new_length)`;
- exact independent `copy()`/`clone()`;
- geometric `reserve` and exact `shrink_to_fit`;
- alias-safe native `extend`;
- deterministic stable natural and comparator sorting;
- structural Array Eq/Ne.

The signed `Arena<t>` facade in SH-06 was delivered in the next compiler-library tranche.

### SH-05 — Structural collection equality and rendering

**Current state:** implemented on August 16, 2026. FixedArray has structural
`Eq`/`Ne`; Array, FixedArray, Option, and Result have deterministic Show; and
`render_compiler_diagnostic` provides bounded path, line, column, byte-offset,
level, code, and message output. See
[`self-hosting-stdlib-tranche-2026-08-16.md`](self-hosting-stdlib-tranche-2026-08-16.md).

Map equality remains intentionally absent because hash traversal order is not a
public deterministic order.

`ToJson` and `FromJson` derivation are not required. Production caches already
use explicit bounded binary codecs. HIR and lowering text can use Show or
manual renderers.

### SH-06 — Signed arena-index facade

**Current state:** implemented on August 16, 2026. `Arena<t>` wraps Array with
I32 IDs, dense push IDs, `-1` missing semantics, one checked I32/U32 conversion
boundary, checked and unchecked access, checkpoints, rollback, fill, truncate,
copy, and span helpers.

A direct port would add conversions at almost every arena access. The audited
source has 1,953 lexical index-write sites and many more reads.

Negative values other than `-1` trap instead of wrapping into U32. The public
Array index type and bounds behavior are unchanged.

### SH-07 — Deterministic integer and diagnostic text rendering

**Current state:** implemented on August 16, 2026. StringBuilder appends every
signed and unsigned integer width directly without a temporary String and handles
signed minima exactly. Integer Show uses the same path. The bounded compiler
diagnostic renderer produces deterministic path, line, column, byte-offset,
level, code, and message text without interpolation.

### SH-08 — Hashing needed by compiler and package artifacts

**Current state:** the portable BLAKE3-256 implementation is now available as
`dew.std.blake3`, including the first little-endian U32 lookup lane used by
cache packs. Official short, block, chunk, and tree vectors pass in Node and
Wago. The complete bootstrap command still uses SHA-256 for package integrity.

**Full-command requirement:** either:

- add Dew-native SHA-256; or
- leave package integrity and capsule management in the bootstrap launcher for
  the first fixed point.

No general cryptography framework is required for self-hosting.

## P1 port-enabling language gaps

These are not hard semantic blockers. Each has a current rewrite. Their use in
the compiler is large enough that supporting them can make the port smaller and
safer.

### SH-09 — Product tuples and destructuring

**Current state:** Dew supports tuple-like enum variants, but it has no general
product tuple value or tuple type.

The audited compiler has approximately:

- 171 tuple-destructuring lets;
- 65 tuple return or parameter type sites.

Compiler phases often return two or three related values, such as a result plus
status, parallel arenas, or an index plus metadata.

**Two valid paths:**

1. Add fixed-arity product tuples with construction, field access,
   destructuring, Eq/Show evidence, and deterministic WasmGC layout.
2. Use named result structs throughout the Dew port.

**Recommendation:** add tuples only for small local products and function
results. Keep persistent compiler artifacts as named structs. Do not add variadic
tuple machinery.

### SH-10 — Conventional iteration

**Current state:** Dew has functional pattern `while`, Array iterators, and
iterator traits. It has no ordinary Boolean `while` or executable `for` loop.

The audited compiler contains approximately:

- 2,218 `for` loops;
- 323 Boolean `while` loops;
- 31 `nobreak` clauses.

All can be rewritten with functional loops, explicit indices, or iterator
objects. Doing this across the optimizer, type solver, linker, and codecs would
make the port much larger and could hide ordering or early-exit mistakes.

**Minimum useful surface:**

- `while condition { ... }` with Unit result;
- `break` and `continue` without required values in that form;
- range iteration over U32/I32 half-open ranges;
- `for value in iterator`;
- optional `(index, value)` enumeration as a library adapter, not special
  syntax.

**Required semantics:**

- source-order evaluation;
- no implicit allocation per iteration;
- deterministic early exit;
- no hidden iterator cloning;
- existing functional `while` remains the expression-valued loop form.

If ordinary loops stay deferred, the port must define and enforce one explicit
functional-loop translation style before semantic work begins.

### SH-11 — Small literal and assignment conveniences

The compiler uses byte scalar literals, array literals, compound assignments,
string interpolation, and object-field shorthand. Dew can rewrite each form:

- `b'\n'` to `10u8`;
- `[a, b]` to an Array builder;
- `count += 1` to `count = count + 1`;
- interpolation to StringBuilder/Show;
- `{ field, }` to `{ field: field }`.

These conveniences are not required before compiler A. Add them only if the
port shows that generated boilerplate obscures correctness. Array literals are
the most useful candidate because Wasm construction and diagnostics use many
small ordered instruction/value lists.

## Bootstrap-only gaps

The following are needed for a fully self-contained user command, but not for
the first self-hosted compiler module.

### SH-12 — Process launch and temporary-file policy

The current bootstrap launches the compiler, Node, and `wasm-tools`, and uses a
process ID in temporary names.

A small external launcher may continue to own:

- child process execution;
- signal and exit-status translation;
- process IDs and secure temporary paths;
- WAT rendering;
- `dew run` and `dew test` host selection.

Do not add process APIs to the Dew language solely for the fixed-point test.

### SH-13 — Directory traversal, package install, and clean

The complete command recursively discovers source files, restores package
capsules, and removes build trees.

A launcher may initially own:

- recursive directory enumeration;
- path canonicalization and platform separators;
- package registry or Git access;
- recursive removal for `dew clean`;
- lockfile generation and update.

The compiler should continue to receive an already ordered module/file graph.

## MoonBit features that are not self-hosting requirements

The following MoonBit forms appear in the current source, but Dew does not need
to implement them to self-host:

| MoonBit feature | Audit pressure | Dew port rule |
|---|---:|---|
| postfix optional type `T?` | about 620 sites | write `Option<T>` |
| optional/default parameters | about 40 sites | use explicit parameters or `Option<T>` |
| `guard ... else` | about 157 sites | use `if` plus early `return` |
| exception `catch` | 19 sites | host APIs return `Result` |
| `nobreak` | 31 sites | use an explicit completion flag or final branch |
| named optional forwarding `arg~` | limited to cache/driver paths | pass the value explicitly |
| `ToJson`/`FromJson` derive | 78 derive sites | retain explicit binary codecs; use Dew JSON manually where needed |
| tuple structs | rare | use named structs |
| `const` declarations | five production constants | use immutable module values until a measured need exists |
| local recursive named functions | bootstrap-only use | move to a top-level helper or iterative worklist |
| exceptions or panic unwinding | not required | use `Result`; reserve traps for broken compiler invariants |
| annotations | no compiler dependency | keep deferred |
| higher-kinded types or variance | no compiler dependency | keep deferred |
| associated types/constants | no compiler dependency | keep excluded from the first edition |

## Proposed implementation order

1. **Freeze the bootstrap request.** Define the exact data passed from the small
   launcher to compiler A.
2. **Add SH-01.** Prove argument, file, output, environment, and exit behavior in
   a tiny Dew program.
3. **Add SH-04 through SH-08.** Port compiler-grade arenas, sorting, rendering,
   and BLAKE3 before large semantic modules.
4. **Decide SH-09 and SH-10.** Either implement tuples and ordinary loops or
   publish mandatory translation patterns and accept the larger port.
5. **Freeze the linked Starshine foreign ABI.** Pin the compiled binary, expose
   the typed imports needed by the backend, and include its bytes in compiler
   fingerprints.
6. **Port tokenizer and parser.** Keep binary parser-event compatibility only if
   it materially shortens bootstrap work.
7. **Port semantic phases in dependency order.** Collection, types, imports,
   names, inference, flow, layouts, specialization, optimization, and linking.
8. **Port backend calls to the linked Starshine foreign ABI.** Keep linker-owned
   composition deterministic.
9. **Port cache codecs, loader, driver, and compiler-facing CLI.** Keep package
   acquisition and process launch outside if necessary.
10. **Run the fixed point.** MoonBit Dewdrop builds A; A builds B; B builds C;
    B and C must be byte-identical.

## Required acceptance tests

### Host boundary

- arguments preserve order and exact UTF-8 bytes;
- missing environment variables are distinct from empty values;
- file reads and writes preserve arbitrary Bytes;
- partial writes and host errors remain visible;
- atomic publication never exposes a partial cache artifact;
- stdout, stderr, and exit status are independently testable.

### Compiler collections

- Array fill, truncate, copy, and sort are deterministic;
- sort comparator calls have a defined order or are required to be pure;
- arena signed-ID conversion rejects negative non-sentinel values;
- rollback-heavy type-solver tests preserve exact lengths and contents;
- structural equality does not depend on object identity.

### Linked Starshine dependency

- the compiled Starshine binary and foreign ABI are version-pinned;
- every required import has an exact Dew signature;
- malformed modules fail with bounded typed errors across the foreign boundary;
- custom sections remain deterministic;
- repeated encoding is byte-identical;
- compiler fingerprints include the exact linked Starshine bytes.

### Fixed point

```text
MoonBit Dewdrop -> compiler A
compiler A      -> compiler B
compiler B      -> compiler C
B bytes         == C bytes
```

The comparison includes the compiler Wasm, custom sections, embedded standard
sources, and any compiler-owned schema/version data.

## Bottom line

Do not begin the 100,000-line compiler port by translating MoonBit syntax.
First close the host boundary, freeze the linked Starshine foreign ABI, and add
the small collection layer that compiler arenas need.

After those items, the current Dew type system is sufficient. Product tuples
and conventional loops are the only language additions with strong evidence
that they will reduce port risk. The remaining MoonBit conveniences can be
rewritten without expanding Dew's first self-hosting language surface.
