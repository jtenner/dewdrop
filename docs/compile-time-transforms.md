# Compile-time function transforms

Function transforms run Dew code inside the compiler. They use an interpreter;
they do not start a process, create another Wasm instance, or call host APIs.
The native compiler and the compiler written in Dew use the same source API.

## Try it

From the repository root:

```sh
tools/dew build -o .tmp/local-transform.wasm examples/transforms/local.dew
tools/dew build --root example.app \
  --module example.app examples/transforms/imported.dew \
  --module example.tools examples/transforms/tools.dew \
  -o .tmp/imported-transform.wasm
```

Both exported `main` functions return `42`.

```sh
node -e 'const fs=require("fs"); WebAssembly.instantiate(fs.readFileSync(".tmp/local-transform.wasm")).then(({instance})=>console.log(instance.exports.main()))'
```

## Define a transform

```dew
import dewdrop.ast as @ast
import dewdrop.transform as @transform

transform fn answer(
  node: @ast.FnNode,
  ctx: @transform.TransformContext,
) -> Result<@ast.FnNode, @transform.TransformError> {
  Result::Ok(node.with_body(@ast.integer(42i32)))
}

#answer
pub fn main() -> I32 {
  0i32
}
```

A transform can return `FnNode` directly, or use `Result` to return a diagnostic:
`Result::Err(@transform.error("explanation"))`.
The annotation must occupy its own line. Put it before `pub fn` or `fn`.
Multiple annotations run in source order, from top to bottom. Each receives the
previous result. Expansion happens once; returned source cannot add annotations.

Use `pub transform fn` to export a transform. Import its module normally, then
write `#@alias.name`. Packages supply source through the same manifest or locked
package mechanism as ordinary Dew packages. A transform can call ordinary functions and methods in its module or imported
modules. The compiler uses the checked call target. Private helpers stay private.
It cannot call a function that itself has transform annotations.

## Syntax values

The compiler supplies the ordinary source modules `dewdrop.ast` and
`dewdrop.transform`. Their source is in `lib/dewdrop/`. These module names are
reserved for that API. Their library functions use ordinary evaluation rules.

`FnNode` has `name: String` and `body: ExprNode`. The current API transforms
function bodies. The name, parameters, type parameters, return type, and visibility
remain unchanged. The context supplies checked types for original expressions.
A transform can add declarations and imports through the context.

`ExprNode` has these variants:

| Variant | Generated code |
| --- | --- |
| `Source(String)` | A source fragment, checked before use |
| `Quote(Array<String>, Array<ExprNode>)` | Source text with expression splices and fresh `$name` locals |
| `Integer(I32)` | An I32 literal |
| `Unit`, `Integer64(I64)`, `Unsigned64(U64)` | Unit and wide integer values |
| `Path(String)` | A checked qualified name, including `@alias.Type::method` |
| `Field(ExprNode, String)`, `Index(ExprNode, ExprNode)` | Field and index access |
| `MethodCall(ExprNode, String, Array<ExprNode>)` | A method call |
| `Prefix(String, ExprNode)` | `!`, `-`, or `+` |
| `Tuple(Array<ExprNode>)`, `Array(Array<ExprNode>)` | Tuple and array expressions |
| `MutableBind(String, ExprNode)`, `Assign(ExprNode, ExprNode)` | A mutable binding and assignment |
| `Boolean(Bool)` | A Boolean literal |
| `Text(String)` | An escaped string literal |
| `Name(String)` | One checked identifier |
| `Call(ExprNode, Array<ExprNode>)` | A call |
| `Binary(String, ExprNode, ExprNode)` | A supported binary operator |
| `Block(Array<ExprNode>)` | A block, in source order |
| `Bind(String, ExprNode)` | An immutable local binding |
| `Return(ExprNode)` | A return from the containing function |
| `If(ExprNode, ExprNode, ExprNode)` | A conditional expression |

The input body is a `Source` node containing the original block. Builders let
you wrap or replace that block. A source fragment is an explicit escape hatch;
it must still produce exactly one valid function body and pass normal checks.

Generated names resolve in the target module and lexical scope. Quotes give `$name` bindings fresh local names. Use `ctx.fresh_name` for a
local introduced with other builders. Do not assume a plain `Name("x")` refers to a variable in the
transform's own module. Imported generated references can use
`Path("@alias.function")` and an import in the target module.

## Methods and builders

Use methods to change a function:

```dew
node.with_body(@ast.integer(42i32))
node.prepend(@ast.call(@ast.name("before"), []))
node.append(@ast.integer(42i32))
node.wrap(@ast.path("finish"))
node.returning(@ast.integer(42i32))
```

`with_body` returns a replacement node. It keeps the name and changes the body.
`prepend` puts an expression before the old body. `append` puts one after it;
the new last expression sets the result. An explicit return in the old body
still returns early. `wrap` calls the supplied function with the old body's
result. `returning` replaces the body with an explicit return.

Expression methods include `call`, `binary`, `field`, `index`, `method_call`,
`returned`, `bind`, `bind_mut`, and `assign`. Free builders remain available.
Names, paths, and operators are checked before rendering. Generated code must
also pass the normal compiler checks.

See [the full feature list](transform-features.md) for current tests and open
work. Runnable examples are in `examples/transforms/`:

| Example | Use |
| --- | --- |
| `methods.dew` | Mutable receivers, aliases, named functions, captured callbacks |
| `imported_methods.dew` | A method from another module |
| `collections.dew` | Ordinary Array methods and array literals |
| `raw_arrays.dew` | Bounded raw arrays and overlap-safe copy |
| `casts.dew` | Inferred cast types and default array values |
| `builders.dew` | Array, index, mutable binding, assignment, and return builders |
| `wrappers.dew` | Prepend and wrap the original body |
| `syntax.dew` | Qualified calls, fields, method calls, tuples, wide integers |
| `evaluation.dew` | Receiver and argument order, record patterns |
| `operators.dew` | Selected custom operators and indexed reads |
| `callbacks.dew` | A function value that returns a closure |
| `flow.dew` | Return from a call argument |
| `generics.dew` | Generic helper results and typed default values |
| `defaults.dew` | Deferred zero values inside generic enum payloads |
| `scalar_values.dew` | Checked values in generic records, options, and tuples |
| `signature_info.dew` | Structured parameter names and source types |
| `type_info.dew` | Generic bounds, tuple types, function types, applied types |
| `declarations.dew` | Generated imports, types, functions, and implementations |
| `constants.dew` | Local module constants and dependent initializers |
| `constant_state.dew` | Initialization once per application, fresh state for stacked transforms |
| `imported_constants.dew` | Public module constants from another module |
| `repeated_imports.dew` | Generated imports shared by two transformed functions |

## Add declarations and imports

Use `ctx.add_function(source)`, `ctx.add_type(source)`, and
`ctx.add_implementation(source)` to add one declaration of the requested kind.
Types can be structs, enums, or aliases. Use `ctx.import_module(module_path,
alias)` to add a named import to the target module. Do not include `@` in the
alias. Repeated requests for an existing path and alias reuse that import,
including requests from transforms on different functions. An alias that already
names a different module produces an error. A later transform in a stack can use declarations emitted by an earlier
transform in its output. Execution still uses the original checked source set.

The context stores these requests in `declarations` and `imports` arrays.
Each declaration must parse as exactly one item of its requested kind. Names,
visibility, types, duplicate definitions, and references pass the normal final
compiler checks. Generated declarations cannot contain transform annotations.
All emitted imports, declarations, and the target function share the existing
1 MiB output limit. Raw body fragments must still produce only a function body.

## Context

- `ctx.location.file_name`: original logical source path.
- `ctx.location.line_no`, `ctx.location.col_no`: annotation location, starting at
  one. Columns count UTF-8 bytes, as compiler diagnostics do.
- `ctx.fn_name`, `ctx.module_name`: target function and module names.
- `ctx.parameters_source`, `ctx.return_type_source`: signature source text.
- `ctx.fresh_name`: a compiler-chosen local name absent from all source files in the target module.

Generated bodies have their own logical source files, named from their original
file and function. Original source line numbers remain stable. A diagnostic in
generated code shows that generated source and its own line number.

`ctx.parameters` contains `ParameterNode` values with `name` and `type_`.
`ctx.type_parameters` contains names and structured bounds. `ctx.return_type`
contains the declared result type. These are source types; aliases retain their
source names.

A `TypeNode` has `kind`, `name`, and `arguments`. The kinds are `named`,
`qualified`, `tuple`, `applied`, `function`, and `computed`. Applied types put the
base first, then type arguments. Function types put the result last. Computed
types retain their expression text in `name` and their base in `arguments`.
Type trees have a depth limit of 128. Import `dew.std.array` to index their
arrays and `dew.std.string` to match their names against string literals.

## Execution and safety

Before execution, transforms and helpers pass normal name and type checks.
Annotated bodies are replaced with checked placeholders during this pass.
After expansion, all generated code passes the full normal compiler checks.
A failed transform produces no successful build artifact.

The interpreter supports integer and Boolean values, UTF-8 string values,
records, enum payloads, tuples, arrays, local bindings and mutation, branches,
checked patterns, functional loops, source functions, methods, and returns.
Closures can capture local values, change captured mutable locals, and pass to
ordinary source helpers. Named source functions can also pass as values.

Calls use the exact target from the normal type check. This includes static and
instance methods, concrete trait methods, custom binary operators, and indexed
reads. A custom operator runs its selected source body. Primitive operations use
the checked Wasm opcode. A checked unsupported call cannot fall back to another
function with the same name.

The standard `Array` operations run their normal Dew bodies: construction,
length, capacity, push, pop, get, set, and clear. The interpreter supplies bounded
Wasm GC array operations and selected integer Wasm operations. It keeps checked
scalar result types, including inferred casts and zero/false array defaults.
Checked types also apply when reading local values and record fields. Tuple
values use normal destructuring, such as `let (value, flag) = pair`. Unsupported
floating-point carriers cannot enter integer execution through a generic record
or optional value. Array copies preserve overlap behavior. These operations add no host calls.

Immutable module bindings can run their checked initializers on first use.
They can call source functions and refer to other constants, including public
constants in imported modules. Values are cached during one transform
application. A new application starts with a new cache. An immutable binding can
hold a record with mutable fields; aliases share those changes within the
application. Mutable module bindings remain unavailable. Initializer cycles,
escaped control flow, and host calls produce errors.

Unsupported operations produce errors when reached. These include host calls,
mutable module bindings, and dynamic trait objects. Scalar floats and standard text methods execute
through checked Wasm operations and ordinary Dew source. Generic source helpers keep selected type instances and checked trait witnesses.
Unsupported dynamic trait dispatch still produces an error. All branches must pass
the normal source checks, including branches that execution does not reach.

Each application has a 100,000-step work budget and an estimated allocation
budget of 4 MiB. Interpreter and generated-node depth are limited to 128.
Generated source is limited to 1 MiB per function. The allocation budget counts
interpreter work; it is not a measured process-memory limit. Limits fail with a
compiler diagnostic. No file, network, clock, environment, or process capability
is exposed to interpreted code.

The two compiler implementations count work differently. A transform near a
limit can pass in one and fail in the other. Name and proof lookup also counts as
work, so large source modules can reach the limit sooner. The limits protect the
compiler; they are not a portable measure of transform cost.

Transform result caching and a bytecode backend are future work. Ordinary
compiler artifact caches still apply to the expanded program. Performance work
must preserve the interpreter's checks and deterministic behavior.

## Tests

```sh
DEW_NATIVE_TEST_PACKAGES='transforms compiler_driver' tools/test-native.sh
mise exec wasm-tools@1.262.0 -- tools/test-transforms.sh
```

To test real compile requests after building a self-host compiler:

```sh
mise exec wasm-tools@1.262.0 -- tools/test-transform-requests.sh \
  .tmp/self-host-bootstrap/a/compiler.wasm node-facet
```

Use `wago` in place of `node-facet` to run the same requests in Wago.
The test checks every public example and requires each exported `main` to
return `42`. It also checks that invalid signatures, extra declarations, unsafe
operations, and host calls fail with a diagnostic and produce no output file.

## Quotes and splices

Use `@ast.quote(parts, splices)` to join source text with expression nodes. The
number of text parts must be one more than the number of expressions. Each
inserted expression has parentheses. The complete quote has its own local scope.

```dew
node.with_body(@ast.quote([
  "let $saved = 2i32\n",
  " + $saved",
], [node.body]))
```

Inside quote text, `$saved` is a quote-local name. The compiler gives it a fresh
name and uses the same name for every `$saved` in that quote. It checks all text
and inserted expressions for name conflicts. Nested quotes have their own names.
Dollar text in strings and comments stays unchanged. An ordinary name such as
`value` keeps its normal source meaning. Use `$name` for each new local binding.
A quote does not parse or execute code during interpretation. The compiler checks
its final source with all other generated code. The normal size, work, and
nesting limits apply. See `examples/transforms/quotes.dew`.

## Read the original body tree

`ctx.syntax` is the original parsed body as a `SyntaxNode`. A node has `kind`,
`label`, `offset`, `children`, and `types`. Offsets are byte offsets in the original
UTF-8 source. Children keep source order. A block has one child per source item;
a call has its callee first, then its arguments. Binary nodes have the operator
in `label`, then left and right children. Bindings have the name in `label`.

The tree includes expressions, blocks, lambda parameters, record properties,
match arms, guards, and patterns. Explicit source types use `TypeNode` in `types`.
Integer labels hold unsigned literal bits; a separate prefix node holds a minus
sign. Float labels hold IEEE bits. String labels hold decoded text. A bytes
literal has one `U8` child per byte, which preserves bytes that are not UTF-8.
The tree keeps the source form. Use `ctx.type_of(node)` for checked types.
Stacked transforms see the same original tree. Use `node.body` for the output of
the previous transform. See `examples/transforms/syntax_tree.dew`.

## Read checked expression types

`ctx.type_of(syntax_node)` returns `Option<@ast.TypeNode>`. It reads the type of
an expression in the original function body. A call and its callee can have the
same byte offset; the lookup also checks the syntax kind.

```dew
let expression = ctx.syntax.children[0u32]
match ctx.type_of(expression) {
  Some(type_) => {
    // Inspect type_.kind, type_.name, and type_.arguments.
    node
  }
  None => node
}
```

`ctx.expression_types` contains the underlying `ExpressionTypeNode` records,
sorted by byte offset. Each record has `offset`, `kind`, and `type_`. The order
of records at the same offset is unspecified. `type_of` uses a binary search
and then checks the matching offset group. Binding statements and patterns do
not have expression types.

Primitive types use `kind: "named"` and names such as `I32`. Nominal and trait
types use `nominal` and `trait`, with a qualified name such as
`example.app::Box`. Generic parameters use `parameter` and their declared name.
`self` represents `Self`. Tuples use `tuple`. Applied types put their base first
in `arguments`; function types put their result last. Associated type
projections use `projection` and retain their owner type.

If the original input has a check error, `expression_types` is empty and
`ctx.type_errors` contains the check errors. A transform can still repair the
body. The generated result must then pass normal checking. A missing type
returns `None`; the compiler does not guess it.

The view always refers to the original body, including with stacked transforms.
Each application gets fresh arrays. Type traversal and array construction use
the transform work, allocation, and nesting limits. Building the checked view
also needs a separate source-check pass; that pass is outside the interpreter
work report.

See `examples/transforms/typed_reflection.dew`, `typed_generics.dew`, and
`typed_repair.dew`. All three can be built with `tools/dew build` as shown above.

## Annotation arguments

An annotation can pass syntax to its transform:

```dew
#labeled("answer")
pub fn main() -> I32 {
  0i32
}
```

Read the arguments from `ctx.arguments: Array<SyntaxNode>`. For a string literal,
`kind` is `"String"` and `label` is the decoded text. The source offsets refer to
the original file. `ctx.arguments_source` holds the exact text inside the
parentheses. No parentheses and empty parentheses both give an empty array.

These are syntax arguments, like macro input. The compiler parses them but does
not execute them or resolve names in them. A transform can inspect a call node
without making that call. It can reject input with a normal transform error.
The complete annotation must fit on one line. Limits are 256 arguments, 64 KiB
of argument text, and 127 nested bracket pairs. See
`examples/transforms/arguments.dew`.

## Inspect expanded source

```sh
tools/dew build --emit expanded -o .tmp/expanded.json examples/transforms/declarations.dew
```

This writes a version 1 JSON document with `modules` and their `files`. Each file
has a logical `path` and exact `source` text. A generated file also has an `origin`
with the original file and a stable `function@byte-offset` site. Its `ranges`
list the byte start and end of each generated declaration. All ranges in one
file share that origin. This maps multiple generated declarations back to their
source function; it does not claim a separate origin for every inserted token.
An editor can show these files directly. The command checks and runs transforms,
then writes source before generated-code type checks or Wasm emission. This lets
you inspect generated code that has a type error.

## Native Wago check

```sh
mise exec wasm-tools@1.262.0 -- tools/test-transform-wago.sh .tmp/self-host-bootstrap/a/compiler.wasm
```

This checks a real transform request with a pinned native Wago host and the
existing Facet bindings. The CI job uses a Linux x64 project runner with the
`dewdrop` label. Native Wago currently takes about 116 seconds for the small
request; this is an open host speed issue. See
`docs/research/native-wago-transform-check-2026-10-19.md` for measured limits.

## Scalar floats and selected function values

F32 and F64 literals, ordinary source helpers, scalar arithmetic, comparisons,
and selected Wasm float instructions can run at compile time. Nearest rounds
ties to even. Negative zero and NaN follow Wasm rules. A float-to-integer trap
becomes a transform error. Use reinterpret instructions to read float bits;
an unsafe cast cannot move a float into an integer carrier. See
`examples/transforms/floats.dew`.

A function value uses the target chosen by normal source checking. This also
works for overloaded builtins when the expected function type selects a target.
Dew does not permit overloaded ordinary free functions. See
`examples/transforms/overloads.dew`.

String equality, concat, and StringBuilder methods run from the ordinary Dew
library source. A built String can supply AST source, names, quote text, and
new declarations. See `examples/transforms/strings.dew`.

## Work reports

The expanded-source JSON includes `transform_reports`, in source order. Each
completed annotation has its module, file, function, transform, byte offset,
`work`, and `allocation_work`. Each annotation starts with a fresh budget.
These are logical interpreter counts. Allocation work is an estimate of work
that creates values; it is not retained heap bytes or peak memory. It includes
context construction and generated import and declaration work. Final shared
function rendering and later compiler passes are outside this per-annotation
count. Counts can differ between the native and Dew implementations.

Compiler API users can read `options.transform_reports` after compilation.
The Dew API `ct_expand_checked_with_reports` returns the expanded manifest and
reports without adding host calls. Failed annotations retain their normal
error diagnostics. A report is emitted only for a completed annotation.

## Raw-array defaults and null

Integer, Boolean, float, vector, and unit slots have their typed zero value.
A tuple whose leaves are all unit values keeps its nested tuple shape. It does
not require a boxed value. A default tuple with runtime leaves traps when read,
because its box is null. Unit-only tuple construction debits allocation work
before it creates the value.

A `NullableRef<Handle>` slot contains null. A cast from null to another checked
nullable reference preserves null. A cast to a non-null reference traps.
Record, enum, string, and non-null foreign reference reads require a non-null
value. This also applies to records with one or more type arguments. Raw-array
identity comes from the normal checked builtin contracts, not the number of
type arguments on a user type.

Function, trait, and raw-array slots use nullable carriers. Their default null
can be read; a later call, method dispatch, or array operation can trap. Reading
a zero-length unit array still fails bounds checking. `Never` has no default
value. These rules match the normal Wasm path. See `nulls.dew` and
`default_references.dew` in `examples/transforms/`.

## Checked type queries

`dew.std.types` queries can run inside transforms and selected generic helpers. They use results
proved by normal type checking. Name arrays are fresh values, so changing one
result does not change the next result. See
`examples/transforms/type_queries.dew`, `generic_queries.dew`, and
`generic_query_api.dew`. Computed field and payload types stay in type positions.
They do not become runtime values.


## Byte literals and vectors

Byte literals keep their exact bytes during interpretation. This includes invalid
UTF-8. Standard Bytes length, index, views, equality, concat, and text conversion
use the normal Dew library. `@ast.bytes(value)` builds a byte literal without
changing its data. See `examples/transforms/bytes.dew`.

Both interpreters execute the pure vector operations in the current compiler
instruction catalog. These include lane access, integer and float arithmetic,
comparisons, shifts, narrowing, widening, dot products, bit masks, shuffle,
swizzle, rounding, and numeric conversion. Vector memory operations remain
unsupported. Arithmetic float NaNs use canonical bits; moves, sign operations,
and pseudo-min/max preserve their selected operand bits. See
`examples/transforms/vectors.dew`.

Standard text views, UTF-8 conversion, cross-vector-boundary searches, byte
views, and growing StringBuilder/BytesBuilder operations run through their Dew
source. See `examples/transforms/text_operations.dew`. Lexical scope snapshots
share cells and copy their name map only when a declaration changes the names.
Checked source sites use numeric IDs that distinguish modules and files.
Work and allocation reports remain implementation-specific; the current full
text control uses78,686/83,981 work steps in Native/Dew respectively.

Integer bit counts, rotations, and I64 sign extension also execute at compile
time. Named function references keep their checked runtime identity, including
generic references. Ordinary I32 and U32 instances can share that identity.
Narrow scalar types, type-query-sensitive instances, and distinct checked trait
evidence keep the distinctions used by the normal compiler. Fresh closures and
bound methods keep separate instance identities. Missing generic identity proof
produces a diagnostic. See `generic_function_identity.dew`,
`generic_identity_nested.dew`, `generic_identity_closures.dew`, and
`generic_identity_evidence.dew` in `examples/transforms/`.


## Checked generic frames

Each selected generic helper has a separate execution frame. It keeps its
checked call targets, result types, local scalar types, primitive operator
proofs, and folded query results. A returned closure keeps the frame that built
it. Two instances of one source helper cannot replace each other's proofs.
Trait-bound calls use the normal compiler's selected implementation. Generic
implementation methods retain implementation types, method types, and both sets
of checked bound proofs. Parameters used only by the trait argument also keep
their logical type. See `generic_trait_impl.dew`, `generic_trait_method_bounds.dew`,
and `generic_trait_trait_arguments.dew`.

A generic branch can require another check after its types are known. Transform
setup rejects errors from that check before it runs source code. Newly selected
methods and primitive operators use the checked instance proofs. See
`generic_traits.dew`, `generic_closures.dew`, `generic_selected_methods.dew`, and
`generic_selected_operators.dew` in `examples/transforms/`.

Transform planning follows checked helpers and the module-value initializers
they read. Runtime-only bodies and unread initializers do not use its instance
budget. Transform planning allows at most 128 logical instances and charges copied
module-arena entries against a separate 1,048,576-entry budget. Rechecks charge
another copy bundle. A type-tree walk also has a 65,536-node limit. These are
work bounds; they do not state peak heap use. Normal parsing, type checking,
and fresh inferred arenas remain compiler work outside the VM allocation ledger.


Unsafe casts and raw `struct.get` calls that return a tuple need checked tuple
layout data. The interpreter currently rejects these operations, including a
single-leaf tuple whose Wasm ABI is otherwise valid. Ordinary tuple construction,
source calls, destructuring, and unit-only defaults are supported.

## Loop transfers in guards

A `break` or `continue` in a functional loop guard targets that loop. The
first value of a nested loop is evaluated in the outer loop's control scope.
Both interpreters keep these checked targets. See
`examples/transforms/loop_guards.dew`.


## Interpreter execution

Both compilers use portable 32-bit bytecode for supported function bodies.
Checked calls, scalar proofs, loop flow and type reads keep the tree
interpreter's rules. Unsupported bodies use the tree interpreter as a whole.
This includes closure creation. The choice is automatic; source code uses the
same API on both paths. No second Wasm instance or host call is needed.

Bytecode compilation has separate work, slot and code-cache bounds. Exhausting
one of these bounds selects the tree path. It does not remove the normal work,
allocation, output-size or depth limits. The code-cache byte budget is a weighted
estimate, not a measured total-heap limit. See
[the bytecode notes](research/transform-bytecode.md) and
`examples/transforms/bytecode.dew`.


## Memory and packed integers

The current scalar and vector memory instruction catalog runs at compile time.
It includes scalar loads and stores, full vector loads and stores, splat and
extending loads, zero loads, and checked lane loads and stores. Lane immediates
must have the exact form accepted by the normal compiler.

Each transform gets a private, zeroed 64 KiB page on its first memory access.
It shares that page with its helpers and starts fresh for the next transform,
including the next annotation in a stack. The page uses 64 KiB of allocation
work. Every access checks its whole range before reading or writing. A failed
store keeps the old bytes. Memory growth and operations outside the normal
instruction catalog remain unsupported. The page does not expose host memory.

`Swar32` and `Swar64` use the existing integer execution rules. All 55 packed
integer helpers run through their Dew source. Type queries retain the source
type, so a packed type is still distinct from a plain integer. Packed record
fields, raw arrays, default values, and array literals are also supported.

Try `examples/transforms/memory.dew`, `memory_state.dew`,
`packed_integers.dew`, and `packed_storage.dew`. Each main returns `42`.
