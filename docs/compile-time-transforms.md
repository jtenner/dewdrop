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
remain unchanged. It does not yet provide typed expression reflection.
A transform can add declarations and imports through the context.

`ExprNode` has these variants:

| Variant | Generated code |
| --- | --- |
| `Source(String)` | A source fragment, checked before use |
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

Generated names resolve in the target module and lexical scope. This version
has no automatic name hygiene or quotation syntax. Use `ctx.fresh_name` for an
introduced local. Do not assume a plain `Name("x")` refers to a variable in the
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

## Add declarations and imports

Use `ctx.add_function(source)`, `ctx.add_type(source)`, and
`ctx.add_implementation(source)` to add one declaration of the requested kind.
Types can be structs, enums, or aliases. Use `ctx.import_module(module_path,
alias)` to add a named import to the generated file. Do not include `@` in the
alias. A later transform in a stack can use declarations emitted by an earlier
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
floating-point values cannot enter integer execution through a generic record
or optional value. Array copies preserve overlap behavior. These operations add no host calls.

Immutable module bindings can run their checked initializers on first use.
They can call source functions and refer to other constants, including public
constants in imported modules. Values are cached during one transform
application. A new application starts with a new cache. An immutable binding can
hold a record with mutable fields; aliases share those changes within the
application. Mutable module bindings remain unavailable. Initializer cycles,
escaped control flow, and host calls produce errors.

Unsupported operations produce errors when reached. These include host calls,
mutable module bindings, unresolved generic trait dispatch, floating-point
execution, SIMD execution, and general text-library operations. Generic source helpers work
when execution needs no missing type or trait evidence. All branches must pass
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
