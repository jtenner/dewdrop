# Dewdrop

Dewdrop is the reference compiler and standard library for **Dew**, an experimental, statically typed programming language that compiles to **WebAssembly GC**.

If those words are new to you, that is okay:

- A **compiler** turns source code written by people into code a computer runtime can execute.
- **Statically typed** means Dew checks many mistakes, such as passing a string where a number is required, before the program runs.
- **WebAssembly**, usually shortened to **Wasm**, is a portable binary format supported by standalone runtimes and JavaScript runtimes.
- **WebAssembly GC**, or **WasmGC**, lets compiled programs use managed objects such as structs, arrays, strings, enums, and closures.
- **WASI** is a standard interface through which a Wasm program can request basic host services such as reading standard input or writing standard output.

Dewdrop is written in [MoonBit](https://www.moonbitlang.com/) and uses [Starshine](https://github.com/jtenner/starshine-mb) to validate and encode deterministic WasmGC modules.

> **Project status:** Dew is under active development. The implemented subset is substantial, but this is not yet a stable language release. Syntax, APIs, package formats, and generated Wasm may change. Check [`docs/roadmap.md`](docs/roadmap.md) before depending on a planned feature.

## Find your way around

- **Try Dew:** start with [`Getting started`](#getting-started), then use `tools/dew check`, `run`, `build`, and `test`.
- **Learn the language:** read [`A beginner tour of Dew syntax`](#a-beginner-tour-of-dew-syntax); use [`docs/spec.md`](docs/spec.md) for exact and evolving rules.
- **Use the CLI and packages:** see [`Command reference`](#command-reference), [`Building a small package`](#building-a-small-package), and [`docs/research/compiler-cli.md`](docs/research/compiler-cli.md).
- **Use the standard library:** see [`std/README.md`](std/README.md) for module ownership, APIs, and source-generation rules.
- **Contribute to the compiler:** read [`Contributing with TDD`](#contributing-with-tdd), [`docs/roadmap.md`](docs/roadmap.md), and [`agent-todo.md`](agent-todo.md).
- **Study implementation details:** browse [`docs/research/`](docs/research/) for design notes, measurements, and coverage findings.

The README is the practical guide; the specification is authoritative for language and compiler behavior; the roadmap records project status; and research notes explain individual implementation decisions.

## Welcome: contributions, AI, tests, and behavior

**Everyone's reasonable contributions are welcome.** You do not need to be a compiler expert to report a clear bug, improve an explanation, add a focused test, reduce a failing example, or propose a carefully scoped change.

### AI-generated contributions are welcome, with extra responsibility

AI-generated code, tests, documentation, and research are welcome. However, AI makes it very easy to produce ten times more **AI slop** than a reviewer can safely verify.

If you use AI, you are still responsible for the entire contribution:

- Read and understand every changed line.
- Verify that APIs, syntax, and claims actually exist in this repository.
- Remove invented abstractions, fake tests, unnecessary comments, and speculative compatibility code.
- Keep the change small enough for a person to review carefully.
- Run the relevant tests and report exactly what you ran.
- Add tests that would fail if the implementation were wrong.
- Do not ask reviewers to debug a large generated patch that you have not validated yourself.

AI assistance is not a substitute for understanding the change. Because generated patches often look plausible even when they are subtly wrong, expect AI-heavy changes to receive **more scrutiny, not less**.

### Use test-driven development for almost everything

Dewdrop strongly prefers **test-driven development**, usually abbreviated **TDD**.

TDD is a small loop:

1. **Red:** Write a focused test that describes the behavior you want. Run it and confirm that it fails for the expected reason.
2. **Green:** Make the smallest implementation change that causes the test to pass.
3. **Refactor:** Improve the code without changing its behavior, running the test again as you work.

For example, if you are fixing an enum-pattern compiler bug:

1. Add the smallest Dew program that reproduces the bug.
2. Confirm that the compiler or runtime test fails.
3. Fix the parser, semantic phase, lowering phase, or backend.
4. Confirm that the focused test passes.
5. Run the wider validation suite to catch regressions.

TDD matters especially in a compiler because a change that fixes one program can silently break another program, alter generated Wasm, change type identity, or make compilation nondeterministic. Documentation-only edits and short-lived research spikes do not always need a new automated test, but executable behavior usually does.

### Issues are welcome when they are reasonable

Good issues are focused and actionable. Please include:

- What you tried.
- What you expected.
- What actually happened.
- A small source example when possible.
- The exact command you ran.
- Relevant error output.
- Your operating system and runtime/tool versions when the problem may be environment-specific.

Feature requests are welcome, but explain the real use case rather than only naming a feature. Very broad demands, duplicate reports without new information, and reports that cannot be reproduced may be closed or narrowed.

### Be excellent to each other

**Be excellent to each other.** This repository does not have a separate formal code of conduct. Treat contributors and users with patience, honesty, and respect. Disagreement about technical decisions is normal; personal attacks and abusive behavior are not useful here.

---

## What Dew is trying to do

Dew is designed around these priorities, in order:

1. Fast generated programs.
2. Low memory use.
3. Predictable and deterministic compilation.
4. Compiler phases with clear, immutable boundaries.
5. A familiar expression-oriented language that remains practical to compile to WasmGC.

“Deterministic compilation” means that compiling the same inputs with the same compiler should produce the same output bytes. Stable output makes builds reproducible and makes compiler changes easier to review.

Dewdrop currently includes, among other things:

- Fixed-width signed, unsigned, and floating-point numbers.
- Booleans, tuples, structs, enums, aliases, pattern matching, and Boolean `value is Pattern(binding)` tests with branch-local bindings.
- Traits, implementations, methods, static dispatch, and nominal/scalar/SIMD runtime trait values using typed WasmGC dictionaries.
- Generic bounds and recursive trait evidence across local, imported, callback, and erased runtime boundaries.
- Generic functions, structs, and enums using deterministic Wasm carrier specialization.
- Postfix `derive(Eq)`, `derive(Debug)`, and `derive(Hash)` for structs and enums, including conditional generic prerequisites and imported execution.
- Ambient deterministic `Debug` output through bounded WASI writes.
- First-class functions and closures, including escaping bounded callbacks that capture runtime trait evidence.
- Immutable and mutable local variables, including captured mutable variables.
- Multi-file modules and statically linked multi-module programs.
- Strict UTF-8 `String` and `StringView` values.
- Arbitrary `Bytes` values, consuming string/byte builders, deterministic allocation-free text hashing, explicit lexicographic String/StringView/Bytes comparators, and strict UTF-8 code-point iterators.
- Explicit `Ordering`/`Comparator` evidence for deterministic ordered collections.
- Carrier-specialized `FixedArray`, growable `Array`, bounded/growable circular buffers, comparator-driven `BinaryHeap`, `PriorityQueue`, red-black trees, ordered maps, ordered sets, and builder-backed Unit/primitive and derived `Show` formatting, and explicit `Disposable` cleanup evidence, and deterministic LIFO `defer`, scoped `using`, and fixed-point primitive constant folding and immutable-summary scalar inlining, Core 3 direct tail recursion, and immutable scalar-field and exact nested-reference common-subexpression elimination and fresh, pure-gap sole-use, repeated-same-field, ordered/reordered/one-missing source-local and multi-missing and mixed alias/direct synthesized scalar/fresh/local/module-reference/generic component-local, fresh-if/match-join, and nonescaping reference/generic box, direct/let-bound/stable-guard fresh tuple/struct-variant, constructor-resolved alternative, constant/stable-composite-or-payload guard and catchall selection and binding-forwarding/projection and tuple/struct scalar-transform, and nested aggregate payload, and exact trait-object escape elimination, double-ended `Deque`, LIFO `Stack`, FIFO `Queue`, and mutable `Map` and `Set` collections with explicit iterators.
- Native SIMD and allocation-free packed-lane operations.
- WASI Preview 1 standard input and output.
- Source-level tests with deterministic compiler-produced metadata.
- Deterministic WAT snapshots and Wasm execution tests.
- File-aware deterministic diagnostics with line/column positions, excerpts, carets, and related-location labels.

Not every familiar language feature exists yet. In particular, consult the roadmap rather than assuming planned features such as general `#annotation(...)` metadata, `Show`, `defer`, iterators, growable arrays, formatting, HTTP, or cryptography have already been implemented. Postfix `derive(Eq)`, `derive(Debug)`, and `derive(Hash)` are implemented; `Show` derivation and any future annotation-based spelling remain separate design work.

## How a Dew program runs

The basic path is:

```text
Dew source (.dew)
    |
    v
Dewdrop compiler
    |
    v
validated WebAssembly GC module (.wasm)
    |
    v
WasmGC runtime + WASI host
```

Dewdrop emits a **core WasmGC module**, not a native operating-system executable. A runtime must instantiate that module and provide any imported WASI functions.

A normal executable Dew module exports a zero-argument function named `main`. If it has non-constant module-level initialization, it also exports `__dew_init`. A Dew-aware host must:

1. Compile or load the `.wasm` file.
2. Provide its WASI Preview 1 imports.
3. Instantiate it.
4. Call `__dew_init()` exactly once if that export exists.
5. Call `main()`.

The included Node host at [`tools/dew-run.mjs`](tools/dew-run.mjs) follows this sequence.

## Getting started

The easiest current path is to build Dewdrop from its source checkout and use the included `tools/dew` command. There is not yet a published, versioned Dew compiler release that this tutorial can install globally.

### 1. Install the development tools

You will need:

- **Git** to clone the repositories.
- A **Bash-compatible shell** for the checked-in wrapper scripts. On Windows, using WSL is the simplest current route.
- **MoonBit** to build the compiler.
- **Python 3** for the command-line wrapper, generators, and snapshot tools.
- A current stable **Node.js** release for the repository's reference Wasm/WASI host and JavaScript tests.
- **wasm-tools** for rendering, parsing, and inspecting Wasm.
- **Go** for parts of the complete differential validation setup.

For ordinary experimentation, Bash, MoonBit, Python, Node, and wasm-tools are the important tools. The complete contributor suite has more dependencies than compiling one small Dew file. The snapshot suite requires the exact wasm-tools release recorded in [`tools/module-snapshots/WASM_TOOLS_VERSION`](tools/module-snapshots/WASM_TOOLS_VERSION).

Confirm that your shell can find them:

```sh
git --version
moon version
python3 --version
node --version
wasm-tools --version
```

Use current stable tool releases. Dew targets evolving WasmGC functionality, so a very old runtime may reject otherwise valid output.

### 2. Clone Starshine and Dewdrop beside each other

The MoonBit workspace currently expects Starshine to be a sibling checkout of Dewdrop:

```text
some-parent-directory/
├── starshine-mb/
└── dewdrop/
```

Create that layout:

```sh
mkdir dew-work
cd dew-work

git clone https://github.com/jtenner/starshine-mb.git
git clone https://github.com/jtenner/dewdrop.git
cd dewdrop
```

### 3. Verify the checkout

Run the fast validation loop:

```sh
tools/check.sh --quick
```

This checks formatting, generated sources, CLI behavior, and the native MoonBit test target. It is the best first command because a failure here usually points to a missing tool or an incompatible checkout.

The complete suite is:

```sh
tools/check.sh
```

The complete suite is much larger. It exercises native MoonBit, WasmGC, JavaScript, classic Wasm, standard-library tests, differential UTF/SWAR/WASI checks, Starshine validation, Node execution, and Wago snapshot execution. Full validation runs the four MoonBit target suites concurrently in isolated persistent target directories, uses a release native UTF parity generator, and builds the snapshot compiler once before running independent fixtures concurrently. Logs remain deterministic. Set `DEW_CHECK_TARGET_JOBS=1` and `DEW_SNAPSHOT_JOBS=1` to force serial target and fixture execution.

### 4. Write your first Dew program

Create a file named `hello.dew` in the Dewdrop checkout:

```dew
open dew.std.wasi

pub fn main() -> U32 {
  wasi_fd_write(1u32, b"Hello from Dew!\n")
}
```

What each line means:

- `open dew.std.wasi` makes the public names from the WASI standard module available without a module prefix.
- `pub` makes `main` visible outside its Dew module, which allows the host to call it.
- `fn` declares a function.
- `main()` takes no parameters.
- `-> U32` says the function returns an unsigned 32-bit integer.
- `wasi_fd_write` writes bytes to a file descriptor.
- `1u32` is the conventional WASI file descriptor for standard output.
- `b"..."` creates a `Bytes` value. The `\n` escape adds a newline.
- The final expression in a block is the block's value, so the number of bytes written becomes the function result.

Dew requires explicit function return types. Newlines are significant in several declarations and block forms, so do not add semicolons as if this were C or JavaScript.

### 5. Check the program without building it

```sh
tools/dew check hello.dew
```

`check` parses the program, resolves names, checks types and traits, plans its runtime representation, and reports compiler errors without writing a final program file.

Use `check` frequently while learning. It gives you a faster feedback loop than waiting until the end to build and run everything.

### 6. Run the program through the reference host

```sh
tools/dew run hello.dew
```

You should see:

```text
Hello from Dew!
```

`tools/dew run` currently compiles a temporary Wasm file and executes it with the repository's Node-based WASI host.

### 7. Build a reusable Wasm file

```sh
tools/dew build hello.dew -o hello.wasm
```

Run that file with the included host:

```sh
node tools/dew-run.mjs hello.wasm
```

This separates compilation from execution. It is useful when testing a different runtime or embedding the module in another host program. Successful Wasm, HIR, and lowering builds are stored as verified content-addressed entries under `.dew-cache/builds/`; an exact repeated request can restore the output without invoking the compiler. Use `--no-build-cache` to force compilation and `--cache-report` to report hit/miss keys.

### 8. Inspect the generated WebAssembly text

Binary `.wasm` files are not intended to be read directly. WAT is a text representation of Wasm:

```sh
tools/dew build --emit wat hello.dew -o hello.wat
```

Open `hello.wat` in a text editor. You do not need to understand all of it yet. Looking at WAT is mostly useful for compiler development, debugging ABI issues, and confirming whether a change added allocations, imports, types, or instructions.

You can also inspect earlier compiler representations:

```sh
tools/dew build --emit hir hello.dew -o hello.hir
tools/dew build --emit lowering hello.dew -o hello.lowering
```

- **HIR** is the compiler's resolved high-level representation.
- **Lowering** is closer to the operations the backend will emit.
- **WAT** is readable WebAssembly.
- **Wasm** is the final binary output and the default build format.

## Choosing a runtime to bootstrap Dew programs

Use a maintained **stable** Wasm runtime while bootstrapping Dew code. Avoid basing important work on an abandoned host or an unexplained browser experiment.

Good runtime categories include:

- [Wasmtime](https://docs.wasmtime.dev/) as a standalone Wasm runtime and embedding library.
- [Node.js](https://nodejs.org/) with a WASI host. Node is the reference JavaScript runtime used by this repository.
- [Bun](https://bun.com/docs) with its WebAssembly and Node-compatibility facilities, after confirming the required WasmGC and WASI behavior in its current stable release.
- [Deno](https://docs.deno.com/runtime/reference/wasm/) with its WebAssembly APIs and an appropriate WASI host, again verifying the required features in the installed stable release.

Dewdrop's current host boundary uses **WasmGC plus WASI Preview 1**. A runtime must support the features actually present in your module. Support can differ by release, so use a smoke test instead of assuming that every runtime exposes the same WASI API.

### Recommended bootstrap strategy

1. Start with `tools/dew run`, which uses the tested Node host.
2. Build a persistent module with `tools/dew build ... -o program.wasm`.
3. Run the module with `node tools/dew-run.mjs program.wasm`.
4. Add Wasmtime, Bun, or Deno as a second host only after the Node path works.
5. Confirm that the second host provides `wasi_snapshot_preview1.fd_read` and `fd_write` when your program needs them.
6. Confirm that it calls optional `__dew_init` before `main`.
7. Keep a tiny runtime smoke test in your project so runtime upgrades fail visibly.

A plain runtime command may assume a WASI command module with an exported `_start`. Dew currently exports `main` and optional `__dew_init` instead. If a runtime's command-line interface cannot express that sequence, use its embedding API or a small Dew-aware adapter based on [`tools/dew-run.mjs`](tools/dew-run.mjs).

The return value of `main` is currently less important than its observable output and traps. The included host calls `main` but does not use its result as an operating-system exit code.

## A beginner tour of Dew syntax

The examples below focus on implemented behavior. For exact and evolving rules, see [`docs/spec.md`](docs/spec.md).

### Comments

A line comment starts with `//`:

```dew
// This is a comment.
let answer = 42
```

### Values and basic types

Dew has fixed-width scalar types:

| Kind | Common types | Example literals |
| --- | --- | --- |
| Signed integers | `I8`, `I16`, `I32`, `I64` | `42`, `42i64` |
| Unsigned integers | `U8`, `U16`, `U32`, `U64` | `42u8`, `42u32`, `42u64` |
| Floating point | `F32`, `F64` | `1.5f32`, `1.5f64` |
| Boolean | `Bool` | `true`, `false` |
| No meaningful value | `Unit` | Usually produced by statements or an empty result |
| Never returns normally | `Never` | Produced by operations such as `unreachable()` |

Dew intentionally distinguishes number widths. This makes storage and generated Wasm behavior predictable.

### Functions

```dew
fn add(left: I32, right: I32) -> I32 {
  left + right
}
```

The last expression is returned automatically. You may also use `return`:

```dew
fn absolute(value: I32) -> I32 {
  if value < 0 {
    return -value
  } else {}
  value
}
```

Every function must declare its return type, including functions returning `Unit`.

### Immutable local variables

Use `let` for a name whose value will not be replaced:

```dew
fn answer() -> I32 {
  let base = 40
  let extra = 2
  base + extra
}
```

Prefer immutable values unless mutation makes the code clearer.

### Mutable local variables

Use `let mut` when the binding must be assigned a new value:

```dew
fn count_once() -> I32 {
  let mut count = 0
  count = count + 1
  count
}
```

Mutation belongs to the local binding. General field assignment and every collection style are not automatically supported just because local assignment exists.

### Conditions

`if` is an expression, so it can produce a value:

```dew
fn classify(value: I32) -> I32 {
  if value < 0 {
    -1
  } else {
    1
  }
}
```

Both branches must be compatible with the expected result type.

### Structs

A struct groups named fields:

```dew
struct Point {
  x: I32
  y: I32
}

fn sum(point: Point) -> I32 {
  point.x + point.y
}

fn example() -> I32 {
  let point = Point {
    x: 20
    y: 22
  }
  sum(point)
}
```

Struct fields are newline-delimited rather than comma-delimited. A struct or
enum may append `derive(Eq)`, `derive(Debug)`, or `derive(Hash)` after its closing
brace. Generated implementations visit fields and payloads in source order and
require the corresponding trait evidence for every stored value. Generic owner
parameters referenced by stored types receive conditional bounds and execute
through static evidence specialization; phantom parameters remain unconstrained.
Derived implementations use ordinary coherence and visibility rules, survive
frozen cross-module interfaces, and conflict with handwritten evidence rather
than silently overriding it.

### Enums and pattern matching

An enum describes a value that can be one of several variants:

```dew
enum Choice {
  First(I32)
  Second(I32)
}

fn read(choice: Choice) -> I32 {
  match choice {
    Choice::First(value) => value
    Choice::Second(value) => value
  }
}
```

`match` checks the variant and can extract its payload. For a closed enum, the compiler can diagnose a missing case.

### `Option<T>`

`Option<T>` represents either a value or the absence of a value:

```dew
fn read_or_zero(value: Option<I32>) -> I32 {
  match value {
    Option::Some(item) => item
    Option::None => 0
  }
}
```

This is safer than inventing a special number such as `-1` to mean “missing.”

### Traits and implementations

A trait describes behavior a type can provide. An implementation connects that behavior to a type. Dew uses trait evidence for operators, methods, generic APIs, hashing, indexing, and other static dispatch. An ordinary trait implementation must be owned by its package through either the trait declaration or the target's nominal head; primitive targets belong to `dew.std`. Explicit `foreign impl` supplies private module-local evidence when neither side is owned and is never exported.

A bare trait name in a value position denotes an erased runtime trait value. Passing a nominal reference value to an expected trait type constructs a small WasmGC envelope containing the erased receiver and a shared immutable typed-function-reference dictionary. Scalar, packed, and SIMD values receive one carrier-specific snapshot box only at that erased boundary. Calls load the source-ordered method slot and use `call_ref`; calls whose concrete implementation is statically known remain direct and allocate nothing for dispatch. Linked imported traits and implementations use the same representation. Closed generic specializations substitute symbolic bound evidence recursively. Transparent tail and explicit-return parameter selectors then directize to the caller's concrete carrier with no envelope or dictionary, while genuinely dynamic generic branches materialize one exact dictionary and evidence-aware implementation-method specialization, including recursive prerequisites and imported providers. Cross-module trait method/vtable/object layouts are canonicalized by declaration identity. A public root generic whose symbolic bounds are consumed by erased trait construction or direct bound methods/operators now exports an all-reference fallback with one trailing `eqref` vtable parameter per source-ordered bound; an external Wasm consumer may construct a structurally equivalent typed dictionary and pass it directly. Bound calls load the typed method slot and use `call_ref` without constructing an intermediate trait object. Direct symbolic evidence forwards through private, recursive, and imported generic call chains using hidden trailing arguments at each specialization. Statically selected concrete generic implementations forward their runtime prerequisites into the exact implementation-method specialization the same way. Escaping bounded function references use immutable closure subtypes that capture source-ordered caller dictionaries and invoke the exact local or imported target specialization through a private environment-first trampoline. When an erased concrete implementation has caller-local prerequisites, Dew wraps the concrete receiver and ordered dictionaries in one immutable capture object; the ordinary typed vtable remains shared, and its adapter extracts the receiver and evidence before directly calling the exact implementation specialization. Internal calls through public or imported wrappers may still directize when transitive summaries prove every discarded prelude total and effect-free; the public dynamic body remains available, while trapping, mutating, recursive, escaping, or unknown flows stay dynamic.

Generic parameters accept ordered bounds such as `t: Eq + Debug`. The compiler retains and executes those trait identities through evidence-aware static specialization for closed calls; dictionaries are reserved for actual runtime trait-value boundaries.

### Function values and closures

Functions can be stored in variables and passed around. A lambda is an anonymous function:

```dew
fn make_counter(start: I32) -> fn() -> I32 {
  let mut current = start
  fn() -> I32 {
    current = current + 1
    current
  }
}
```

The returned lambda **captures** `current`. Because `current` is mutable, the compiler stores it in one shared runtime cell so later calls see the updated value. A named bounded generic function can also escape from a generic API: Dew captures the caller's immutable trait dictionaries in the same closure representation, preserving exact evidence across returns, callback parameters, and module boundaries. Non-escaping callback calls can directize through immutable local aliases and transitive public/imported forwarding wrappers; returned, captured, multiply invoked, trapping, or unknown callback uses retain the closure ABI.

### Strings and bytes

Dew separates text from arbitrary bytes:

- `"hello"` is a strict UTF-8 `String`.
- `b"hello"` is `Bytes`.
- `StringView` is a shared view into valid string data.
- `Bytes` may contain data that is not valid UTF-8.

WASI reads and writes bytes, so beginner output examples commonly use `b"..."`.

## Testing Dew programs

Suppose the regular code is in `math.dew`:

```dew
fn add(left: I32, right: I32) -> I32 {
  left + right
}
```

Put its tests in a file whose name ends exactly in `_test.dew`, such as `math_test.dew`:

```dew
test "adds two numbers" {
  assert(add(20, 22) == 42, "20 + 22 should equal 42")
}
```

Run both files as one test module:

```sh
tools/dew test math.dew math_test.dew
```

Useful test filters include:

```sh
# List discovered tests without running them.
tools/dew test --list math.dew math_test.dew

# Run one exact display name.
tools/dew test --name "adds two numbers" math.dew math_test.dew

# Run tests whose stable identity contains some text.
tools/dew test --filter "adds" math.dew math_test.dew
```

A failed `assert(condition, message)` reports its dynamic message through the test WASI host and traps the test. The runner continues according to the test metadata and reports a nonzero status for failures.

Tests may also declare an expected runtime trap. See existing files under [`tests/module-snapshots/tests/`](tests/module-snapshots/tests/) for current syntax and examples.

## Building a small package

For one file, passing the `.dew` path directly is simplest. As a project grows, use a package manifest.

A package normally looks like this:

```text
hello-package/
├── dew.json
└── src/
    ├── main.dew
    └── main_test.dew
```

A minimal `dew.json` is:

```json
{
  "name": "@example/hello",
  "version": "0.1.0",
  "dependencies": {}
}
```

The package name `@example/hello` derives the Dew module name `example.hello`. Source files are discovered in deterministic sorted order from `src/**/*.dew`. Files ending in `_test.dew` are included only by `dew test`.

From the package directory, invoke the compiler without listing source files:

```sh
/path/to/dewdrop/tools/dew check
/path/to/dewdrop/tools/dew run
/path/to/dewdrop/tools/dew build -o hello.wasm
/path/to/dewdrop/tools/dew test
```

If the package has dependencies, `dew.json` records requested dependency versions while `dew.lock` records exact resolved versions, sources, materialized paths, SHA-256 integrity, and expected interface fingerprints. A successful source-backed resolution publishes a verified content-addressed capsule under `.dew-cache/packages/`; if that locked dependency tree is later removed, the CLI can atomically restore it from the capsule and produce byte-identical Wasm. Registry lookup and first-time network installation remain roadmap work.

You can compute a package's canonical integrity value with:

```sh
tools/dew package-integrity path/to/dew.json
```

## Multi-module programs

Most beginners should begin with one module. When you need explicit multi-module compiler inputs, a `dew.modules.json` graph names the root module and lists modules and files in deterministic order:

```json
{
  "root": "example.main",
  "modules": [
    {
      "name": "example.library",
      "files": ["library.dew"]
    },
    {
      "name": "example.main",
      "files": ["main.dew"]
    }
  ]
}
```

In `main.dew`, open the library module:

```dew
open example.library

pub fn main() -> I32 {
  answer()
}
```

Then check or build the graph:

```sh
tools/dew check --manifest dew.modules.json
tools/dew build --manifest dew.modules.json -o program.wasm
```

`dew.modules.json` is useful for compiler fixtures and explicit graphs. Convention-based packages use `dew.json` and, when needed, `dew.lock`.

## Imports and visibility

Imports must appear before ordinary declarations in each source file.

Use `open` to bring a module's public names into unqualified lookup:

```dew
open dew.std.map
```

Use `import ... as @alias` for qualified access:

```dew
import example.library as @library
```

Qualified alias support is still being extended to every type and pattern namespace, so consult the roadmap and tests when using advanced qualified forms.

Declarations are visible throughout their owning module by default. Add `pub` when another module or the Wasm host must see the declaration:

```dew
fn helper() -> I32 {
  42
}

pub fn main() -> I32 {
  helper()
}
```

Files do not create private namespaces. Multiple files assigned to one module contribute to one shared module namespace.

## Command reference

### Check

```sh
tools/dew check path/to/program.dew
```

Checks the program without writing final output. Compiler failures use stable logical paths, one-based byte line/column positions, source excerpts, carets, and related-location labels where available:

```text
path/to/program.dew:2:3: error: UnknownValueName(2, 0, 25)
  |
2 |   missing_value
  |   ^
```

### Build Wasm

```sh
tools/dew build path/to/program.dew -o program.wasm
```

Builds deterministic, Starshine-validated Wasm.

### Run

```sh
tools/dew run path/to/program.dew
```

Builds a temporary Wasm module and executes it with the Node reference host.

### Test

```sh
tools/dew test path/to/program.dew path/to/program_test.dew
```

Builds a self-describing test module and runs selected tests.

### Clean compiler caches

```sh
tools/dew clean
tools/dew clean --dry-run
```

Removes the configured `.dew-cache` build, interface, and package artifacts. `--dry-run` prints the selected cache path without changing it.

### Emit compiler representations

```sh
tools/dew build --emit hir path/to/program.dew -o program.hir
tools/dew build --emit lowering path/to/program.dew -o program.lowering
tools/dew build --emit wat path/to/program.dew -o program.wat
tools/dew build --emit wasm path/to/program.dew -o program.wasm
```

### Standard-library source selection

Normal commands load standard-library source from deterministic package roots. Advanced compiler/bootstrap work may use:

- `--package-root PATH` to add an ordered package root.
- `DEW_PACKAGE_ROOTS` to configure ordered package roots through the environment.
- `--bootstrap-std` to use generated fallback standard sources.
- `--no-default-preamble` for focused bootstrap/compiler tests where the ambient preamble must be disabled.

Most users should not need these flags.

## Common beginner mistakes

### Forgetting `pub` on `main`

The runtime must be able to see `main`:

```dew
pub fn main() -> Unit {
}
```

### Forgetting a return type

This is invalid:

```dew
fn answer() {
  42
}
```

Write:

```dew
fn answer() -> I32 {
  42
}
```

### Using commas or semicolons where Dew expects newlines

Many Dew declarations and fields are newline-delimited:

```dew
struct Point {
  x: I32
  y: I32
}
```

Follow existing fixtures if parser diagnostics are unclear.

### Confusing strings and bytes

Use a normal string for valid text data:

```dew
let greeting = "hello"
```

Use bytes for WASI and arbitrary binary data:

```dew
let encoded = b"hello\n"
```

### Assuming roadmap items already work

The roadmap intentionally includes unfinished work. An unchecked item is not an available feature. The execution-only unfinished backlog is in [`agent-todo.md`](agent-todo.md).

### Running Wasm without a compatible host

A `.wasm` file does not automatically know how to access your terminal. Provide the expected WASI imports and call `__dew_init` before `main` when initialization exists. Start with:

```sh
node tools/dew-run.mjs program.wasm
```

## Contributing with TDD

A practical contribution usually follows this sequence.

### 1. Choose one observable behavior

Good scopes include:

- One parser error.
- One type-checking rule.
- One lowering operation.
- One generated Wasm instruction shape.
- One standard-library operation.
- One documentation inconsistency.

Avoid combining unrelated cleanup, redesign, and feature work in one patch.

### 2. Find the closest existing test

The repository contains several test styles:

- MoonBit unit and white-box tests under `src/`.
- Dew standard-library tests under `std/tests/`.
- End-to-end compiler fixtures under `tests/module-snapshots/`.
- Runtime and ABI consumers under `tests/abi-consumers/`.
- Performance limits under `tests/performance-budgets/`.

Copy the smallest relevant pattern rather than inventing a new test harness.

### 3. Make the test fail first

Run the narrowest command that demonstrates the missing behavior. For one module snapshot:

```sh
tools/module-snapshots/run.sh --fixture feature/name
```

For a MoonBit package, run the relevant target and package rather than the entire project when possible. End-to-end CLI behavior also has sorted initial suites under `tests/compile-pass`, `tests/compile-fail`, and `tests/run-pass`; run them with:

```sh
python3 tools/cli-fixtures.py
```

A failing test should be diagnostic. It should show the behavior that is wrong, not hide a crash or silently skip because an optional tool is absent.

### 4. Implement the smallest correct change

Dewdrop prioritizes runtime performance first and low memory use second. Preserve deterministic ordering and immutable phase boundaries. Do not replace a measured, allocation-conscious path with a convenient abstraction without measuring the effect.

### 5. Update snapshots only when the output change is intentional

Ordinary test runs never rewrite expected files. To intentionally regenerate a focused compiler fixture:

```sh
tools/module-snapshots/run.sh --update --fixture feature/name
```

Read the WAT and JSON diff. Snapshot regeneration is not proof that a change is correct; it only records the new behavior.

### 6. Run validation

At minimum, run:

```sh
tools/check.sh --quick
```

Before a broad compiler/backend contribution is considered ready, run:

```sh
tools/check.sh
```

If you cannot run the full suite, say so clearly and list what remains unverified.

### 7. Keep documentation synchronized

When behavior changes, update the relevant specification, roadmap, research note, or tutorial in the same contribution. Research and measurements belong in [`docs/research/`](docs/research/).

## Repository layout

```text
src/tokenizer/       raw source cursor, WTF-8 decoding, and streaming lexer
src/parser/          forward-only parser and syntax events
src/semantic/        collection, name resolution, inference, flow, layouts,
                     lowering, interface freezing, specialization, and linking
src/standard_sources/ generated portable bootstrap source bytes and path registry
src/standard_loader/ on-disk dew.std selection and the persistent interface cache
src/backend/         deterministic Starshine/WasmGC planning and emission
src/compiler_driver/ shared collect/analyze/lower/link/emit orchestration
src/dew_cli/         compiler-facing command implementation
std/                 Dew standard-library sources
std/tests/           direct standard-library tests written in Dew
tests/               snapshots, CLI fixtures, ABI consumers, and budgets
tools/               compiler wrappers, generators, hosts, and test runners
docs/spec.md         language and compiler specification
docs/roadmap.md      completed history and planned work
docs/architecture.md compiler phases, package ownership, and arena boundaries
docs/compile-request.md versioned host/compiler request protocol
docs/decisions/      accepted cross-cutting architecture decisions
agent-todo.md        unfinished execution backlog only
docs/research/       design notes, experiments, and measurements
```

## Compiler architecture in plain language

Dewdrop processes source code in stages:

```text
bytes from the source file
  -> decoded source units
  -> tokens such as names, numbers, and punctuation
  -> parsed declarations and expressions
  -> collected module identities
  -> resolved names and types
  -> checked traits, patterns, and control flow
  -> lowered executable operations
  -> linked whole-program plans
  -> validated and encoded WasmGC
```

Each stage tries to consume an immutable result from the previous stage and produce a new result for the next one. This makes compiler behavior easier to reason about and prepares the project for future incremental and parallel compilation.

The frontend is deliberately streaming and forward-only. It does not keep every possible parse tree or repeatedly rewind input. The backend assigns deterministic identities and indices so output does not depend on hash-map iteration or worker completion order.

## Runtime and ABI notes for advanced users

- Dew programs are statically linked into one Wasm module.
- The selected root module controls public Wasm exports.
- Compiler-owned standard code is imported as frozen Dew module interfaces and dead code is removed before final indexing.
- Generic code uses deterministic physical-carrier specializations, with erased `eqref` fallbacks at supported exported boundaries.
- Generic boundary adapters may recursively convert nested structs, enums, and structural function values.
- First-class functions use typed Wasm references and a flattened WasmGC closure representation.
- Public ABI metadata is stored in a versioned `dew.abi` custom section.
- Static cost information is stored in a versioned `dew.metrics` custom section.
- Standard and versioned dependency interfaces use content-addressed persistent caching.
- WASI Preview 1 byte I/O uses bounded staging through one reusable linear-memory page.

These details are important for compiler and host authors. Beginners can safely use `tools/dew check`, `run`, `build`, and `test` without understanding all of them.

## More documentation

- [`docs/spec.md`](docs/spec.md) — detailed language and compiler specification.
- [`docs/roadmap.md`](docs/roadmap.md) — implemented milestones and future plans.
- [`docs/architecture.md`](docs/architecture.md) — compiler phases, package ownership, identities, arenas, and validation contracts.
- [`docs/compile-request.md`](docs/compile-request.md) — versioned bootstrap-host/compiler request protocol.
- [`docs/decisions/`](docs/decisions/) — accepted cross-cutting architecture decisions.
- [`agent-todo.md`](agent-todo.md) — unfinished execution backlog.
- [`docs/research/`](docs/research/) — design investigations and measurements.
- [`std/README.md`](std/README.md) — standard-library source organization.

## License

Dewdrop is licensed under the Apache License 2.0. Third-party attribution is recorded in [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
