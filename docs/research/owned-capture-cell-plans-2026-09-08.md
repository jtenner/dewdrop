# Owned capture-cell plans

## Defect

The emitter selected capture-cell slots again from local mutability/capture
flags and selected heap types again from linked types. Those choices were not
part of the frozen body plan. A source-derived test changed one local flag
after planning: lookup silently removed a previously present cell. The red
hardening lane passed 576 tests and failed that regression (75.500 seconds).

## Retained evidence

Every logical local now has a capture-cell entry: a verified absence, or an
immutable record containing local identity, source arena index, source slot,
cell slot, linked heap type, stored value type, and parameter role. Planning
checks the selected cell field's identity, mutability, storage, and unique
linked owner. Verification checks the table against source facts before freeze.

Freeze owns a separate array and compares every record field. Local reads,
writes, parameter-cell initialization, cell slot lookup, and local allocation
use the retained records. Cell locals use the selected nullable nominal heap
type, not generic eqref. No provider or FFI regeneration is needed.

The first build caught an unsupported storage-enum equality operation and a
match-arm comma (17.923 seconds). After correction, 577 tests and 220 exact
records passed with all shared execution probes (69.997 seconds). Eleven new
negative cases cover table length/presence and each frozen field. The expanded
lane passes 589 tests and 231 exact records with all shared probes
(74.510 seconds). The native library lane passes 326 tests and all shared
probes (35.280 seconds). Generated-file checks pass (5.505 seconds). The clean
bootstrap passes (260.492 seconds). Compiler B and C have identical raw and
linked SHA-256 hashes:
`4c04ce75d77ef7a3f5c0f290ec11ade1212aff7926c99975de92eac56853ece7`.

## Remaining work

The record covers cells owned by this body. Mutable captures read through a
closure environment still select their pointee type from linked metadata;
those forwarded references need their own frozen entries next. Full reference
assignability, complete constructor recipe freeze, and source-local recovery
remain separate work. Runs above 30 seconds remain speed bugs.
