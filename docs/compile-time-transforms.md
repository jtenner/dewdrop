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
  Result::Ok(@ast.with_body(node, @ast.integer(42i32)))
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
package mechanism as ordinary Dew packages. A transform can call ordinary free
functions in its module or imported modules. Private helpers stay private.
It cannot call a function that itself has transform annotations.

## Syntax values

The compiler supplies the ordinary source modules `dewdrop.ast` and
`dewdrop.transform`. Their source is in `lib/dewdrop/`. These module names are
reserved for that API. Their library functions use ordinary evaluation rules.

`FnNode` has `name: String` and `body: ExprNode`. This first version transforms
function bodies. The name, parameters, type parameters, return type, and visibility
remain unchanged. It does not provide typed expression reflection or declaration
generation.

`ExprNode` has these variants:

| Variant | Generated code |
| --- | --- |
| `Source(String)` | A source fragment, checked before use |
| `Integer(I32)` | An I32 literal |
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
transform's own module. Imported generated references can use an explicit source
fragment and an import in the target module.

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

## Execution and safety

Before execution, transforms and helpers pass normal name and type checks.
Annotated bodies are replaced with checked placeholders during this pass.
After expansion, all generated code passes the full normal compiler checks.
A failed transform produces no successful build artifact.

The initial interpreter supports integer and Boolean values, UTF-8 strings,
records, enum payloads, tuples, array literals, local bindings and mutation,
branches, supported patterns, functional loops, direct helper calls, and returns.
Scalar binary operations require proof of the actual selected primitive operation.
Custom operator implementations without that proof produce a diagnostic.
Pattern matches use the constructor or local binding selected by normal type
checking. Standard enum constructors use the same lookup rules as user enums.

Unsupported operations are errors. These include host calls, builtin calls,
mutable globals, closures and indirect calls, general method dispatch, indexed
access, string patterns, and floating-point execution. Helpers may use generics
when execution does not require unsupported type-dependent dispatch. This is not
yet an interpreter for every Dew program. Unsupported branches are allowed if
execution does not reach them; they must still pass normal compiler checks.

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
The test checks local transforms, imported transforms, enum patterns, and direct
syntax-record construction. It runs all four outputs and checks that each returns `42`.
It also checks that invalid signatures, extra declarations, and host calls fail
with a diagnostic and produce no output file.
