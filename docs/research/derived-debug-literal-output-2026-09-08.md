# Derived Debug literal output

Removing the old Bytes write declaration exposed a generated caller: both derive
expanders still created calls to __dew_debug_write for static type names, field
labels, and punctuation. The native semantic derive test reports three missing
call diagnostics. The transport removal must not remove derived Debug behavior.

Both expanders now create ordinary Dew expression blocks. Static bytes are
packed into little-endian U64 constants, stored with the one-to-one u64_store
intrinsic, and sent through the existing checked Dew scratch writer. Each window
is at most 65,520 bytes at address 16; the final padded eight-byte store remains
inside the 64 KiB page. Empty text makes no host call. The expression retains
the full logical byte count as its result. User field formatting remains a
normal selected Debug call.

This is source-level derive expansion, not a new runtime builtin or an emitter
shortcut. The shared corpus checks structs, empty types, nested generic values,
all enum variant forms, exact text, partial host writes, and invalid host results.

Three AST tests fail before the change in 1.564 seconds. They check byte order,
empty output, and the 65,521-byte window boundary. An initial implementation
used an unavailable MoonBit int.min function; replacing it with direct bound
comparisons fixes the compile error (0.188 seconds). All 13 focused parser and
semantic derive tests then pass in 11.114 seconds. Native compilation takes
10.724 seconds and all nine output checks pass in 0.021 seconds.

The shared self-host execution test also exposes missing logical trait targets
and a Unit payload storage conflict. These are addressed separately in the
[bound-call fix](bound-call-logical-selection-2026-09-08.md) and
[Unit storage fix](pattern-unit-storage-2026-09-08.md), without dropping the
generic or Unit cases. All nine shared output checks now pass in the self-host
compiler (1.360 seconds); the hardening lane passes 365 tests, 108 exact failure
records, and all execution corpora in 57.726 seconds. Full-lane checks are in
progress. No speed work is included.
