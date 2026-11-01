# Modern SDK compatibility evidence

See `../stdlib-modern-moonbit-2026-10-31.md` for the decision and gate report.
`data/stdlib-modern-moonbit/` stores measured build and gate logs.
API replacements were checked against the installed core's
`builtin/pkg.generated.mbti`, `float/pkg.generated.mbti`, and `float/methods.mbt`.
The Float constructors use direct integer-to-f32 conversion; no intermediate
Double conversion is introduced. Constructor patterns preserve Result predicates.
