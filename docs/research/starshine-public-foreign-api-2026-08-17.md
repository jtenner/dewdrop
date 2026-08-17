# Starshine public foreign API audit — August 17, 2026

## Correction

The production Dew boundary should mirror Starshine's public module-building API
directly. A command-tape layer would duplicate an already stable typed object
model and add a second schema that the compiler would have to maintain.

## Audited source

The remote `jtenner/starshine-mb` default branch was cloned on August 17, 2026 at
commit `a15644be6434e26eafd00db1eaf49b2a0a58803a`. The package remains version
`0.1.1`.

The generated public interfaces inspected were:

- `src/lib/pkg.generated.mbti`;
- `src/binary/pkg.generated.mbti`;
- `src/validate/pkg.generated.mbti`;
- `src/passes/pkg.generated.mbti`.

The `lib` interface contains 1,329 public functions, 63 public structs, 39 public
enums, and one public type alias. Dewdrop's current backend and core linker name
671 distinct `@lib` root members. The production generator only needs the
transitive public subset used by those packages.

## Stable construction surface

The public interface exposes the complete typed Core Wasm object model:

- `Module::new` and immutable `Module::with_*_sec` helpers;
- section types such as `TypeSec`, `ImportSec`, `FuncSec`, `CodeSec`, and
  `ExportSec`;
- `RecType`, `SubType`, `CompType`, `FieldType`, `ValType`, and `RefType`;
- typed index wrappers for every Core index space;
- `Expr`, `Func`, `Locals`, and the complete `Instruction` enum plus constructor
  methods;
- names, limits, memories, tables, globals, tags, elements, data, custom
  sections, and name metadata.

The adjacent packages expose the required module operations:

- `binary::decode_module`;
- `binary::encode_module`;
- `validate::validate_module`;
- the small set of module passes used by Dewdrop's linker and final emission.

## Generated direct ABI

The Dewdrop generator will consume pinned `.mbti` snapshots and emit two matching
artifacts:

1. MoonBit `#export_name` wrappers in `src/starshine_guest`;
2. Dew foreign types and functions with the exact linked signatures.

The ABI remains version 1 while Dewdrop is unreleased. Generated names must be
stable and derived from the Starshine package, type, member, and overload shape.

The first generated set should cover the exact transitive members used by:

- `src/backend`;
- `src/core_linker`;
- binary encode/decode;
- module validation;
- selected final module passes.

## Representation bridges

Most nominal Starshine values can cross the static WasmGC boundary directly.
The existing linker already proves direct concrete `Module` results and nominal
foreign type replacement.

Generated bridge helpers are still required where source representations differ:

- Dew `String` to MoonBit `String` uses the existing UTF-8 to UTF-16 adapter;
- repeated values use typed guest array builders or generated copy adapters;
- optional values use explicit typed constructors or overload wrappers;
- fallible binary and validation operations use generated typed result
  inspectors or exact compatible result records;
- scalar index wrappers use direct constructors and preserve unsigned widths.

These are typed representation bridges. They are not a command language and do
not serialize the Starshine object graph.

## Fingerprint policy

The deterministic compiler fingerprint must bind:

- the pinned Starshine commit;
- exact `.mbti` snapshot bytes and their BLAKE3 digests;
- the generated export manifest;
- every export name and Core Wasm signature;
- exact compiled guest Wasm bytes.

A missing export, signature mismatch, unexpected interface change, guest digest
mismatch, validation failure, or malformed result bridge must fail visibly.

## Acceptance order

1. Vendor the four pinned `.mbti` snapshots and provenance.
2. Generate the exact used type and function closure.
3. Generate MoonBit guest wrappers and Dew declarations.
4. Extend signature-audit tests to every generated export.
5. Build a direct typed module containing one exported `main` function.
6. Validate and encode it through Starshine.
7. Link it into the source-Bytes smoke compiler.
8. Require repeated and cross-directory byte identity.

## Decision

Use the direct typed Starshine public API. Do not add a command-tape ABI.
