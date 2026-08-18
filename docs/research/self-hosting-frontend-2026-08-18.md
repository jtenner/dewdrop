# Self-hosting tokenizer and parser — August 18, 2026

## Delivered slice

The linked Dew compiler now tokenizes and parses its bootstrap source instead of scanning bytes for the first decimal sequence.

`self_host/compiler/tokenizer.dew` provides a single-pass in-memory tokenizer for the frozen source-Bytes boundary. The first slice includes:

- all current keywords and fixed/compound symbols;
- longest-match operator handling;
- ASCII and strict UTF-8 identifiers;
- line comments with preserved LF, CRLF, or CR newline tokens;
- `@` identifiers;
- decimal I32 magnitudes with underscore and overflow checks;
- quoted String and Bytes literals with escapes;
- malformed-byte preservation inside literals and deterministic errors outside them;
- stable byte offsets and token indexes;
- recovery after malformed `@` identifiers and unterminated strings.

`self_host/compiler/parser.dew` consumes those tokens for the first bootstrap grammar: one public, zero-argument `main` function returning `I32` with one positive I32 literal body. It rejects lexical errors, extra declarations, parameters, wrong return types, incomplete syntax, and positive overflow.

This is the first dependency slice, not the complete production grammar. Remaining tokenizer work includes every numeric width and float form, multiline strings, WTF-8 surrogate identifiers policy, and parity fixtures. Remaining parser work includes the full expression, pattern, type, declaration, recovery, and parse-event surface.

## Performance

The implementation originally used long nested `if` chains for keywords and symbols. That made a clean tiny build take 81 seconds. Replacing those chains with literal `match` dispatch reduced the same build to 1.12 seconds.

Warm measurements on this workspace:

- tokenizer-only Dew check: 0.285 seconds;
- tokenizer plus tests check: 0.29 seconds;
- tokenizer/parser plus 16 tests check: 0.40 seconds;
- tokenizer/parser 16-test execution: 0.19 seconds.

The tests compile once into one self-describing module. No test starts a compiler process per case.

## Linked result

`tools/check-self-host-smoke.sh` rebuilds the provider, runs all 16 frontend tests, builds the linked compiler twice in separate directories, checks compiler/output byte identity, validates the output, proves `i32.const 73`, and rejects fingerprint and unbounded-count corruption.

Current linked compiler:

- size: 887,505 bytes;
- SHA-256: `7083bfdaa3130fde088f17918deb99491090928bc729ae414d06a1e5cc0a1df5`.
