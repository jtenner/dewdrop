# Frozen closure capture accesses

## Defect

Owned cell slots were frozen, but lambda reads and writes still selected their
closure fields and cell pointee types during emission. A source-derived test
changed one linked fragment reference after planning. The write lookup lost
its original cell type. The red lane passed 589 tests and failed that regression
(87.863 seconds).

## Change

Every lambda capture now retains its source identity, erasure state, closure
heap type, field index/storage, and optional cell heap type/storage. Planning
requires one exact closure fragment and one correctly ordered field per live
capture. The entry field, field spans, mutability, logical storage agreement,
and total field count are checked before freeze. Mutable cell storage cannot
silently narrow a source local, even if both types use an I32 stack value.

The verifier independently compares the retained access records with source
and link facts. The freeze witness copies the access array and checks every
field, including the three parts of capture-source identity. Reads, writes,
erasure checks, and forwarding through an enclosing closure use these records.
Field reads choose signed/unsigned packed instructions from frozen storage;
they do not select the width again from linked metadata. The old linked cell
and capture-field searches are removed from emission.

The first fixed lane passes 590 tests and 231 exact records (87.889 seconds).
Sixteen further negative cases cover every frozen field, missing storage,
table length, and capture frame/identity checks. Each changes one field or
performs one invalid lookup against valid source-derived state. The expanded
lane passes 607 tests and 247 exact records with all shared probes
(86.640 seconds). The native library lane passes 326 tests and all shared
probes (29.588 seconds). Generated-file checks pass (4.777 seconds). The clean
bootstrap passes (220.069 seconds). Compiler B and C have identical raw and
linked SHA-256 hashes:
`21839c9637e103278cd3117084fc9ecb7d6590b4b2d9ec8800710b81930b292d`.

## Remaining scope

This completes retained access records for ordinary lambda captures and their
cell pointees. Closure construction evaluation recipes, runtime trait evidence
for escaping generic lambdas, full reference assignability, and complete link
plan freeze remain separate work. No provider/FFI change is included. Runs
above 30 seconds remain speed bugs.
