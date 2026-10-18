# MoonBit source format refresh

Date: 2026-10-18

The current formatter uses `Int32` and `UInt32`, `~` for optional defaults,
and current range syntax. This format commit applies the official output to
299 source files. A separate check formats each committed baseline in a
temporary file and requires exact equality with the staged source. Files with
behavior changes are kept in their own commits.

The compiler proof package uses the current top-level `proof_enabled` setting.
The native link fixture keeps the same GCC optimization and linker flags.
The standard-builtin registry generator emits the same current integer spelling
as its generated MoonBit file.

The complete refresh passes formatting, generated-source checks, nine proof
goals, and all four MoonBit test targets: native 1,375/1,375, and WasmGC,
JavaScript and Wasm 1,366/1,366 each. The source-format check also passes for
every file in this commit. These results come from the complete refresh state.
