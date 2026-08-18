# Self-hosting tokenizer and parser — August 18, 2026

## Delivered slice

The linked Dew compiler now tokenizes and parses its bootstrap source instead of scanning bytes for the first decimal sequence.

`self_host/compiler/tokenizer.dew` provides a single-pass in-memory tokenizer for the frozen source-Bytes boundary. The first slice includes:

- all current keywords and fixed/compound symbols;
- longest-match operator handling;
- ASCII and strict UTF-8 identifiers;
- line comments with preserved LF, CRLF, or CR newline tokens;
- `@` identifiers;
- every integer width (`I8` through `I64`, `U8` through `U64`), legacy `U`/`L`/`UL` suffixes, separators, unsigned-magnitude boundaries, and overflow checks;
- decimal `F32`/`F64` literals, leading dots, required-dot exponent syntax, separators, `F`/`f32`/`f64` suffixes, bounded exponent scaling, exact round-to-even fallback for long/extreme decimals, and malformed-width recovery;
- quoted String and Bytes literals with all supported escapes;
- MoonBit-style `#|` multiline strings across LF, CRLF, and CR;
- all specified non-line Unicode whitespace;
- WTF-8 surrogate preservation inside literals and one explicit surrogate error outside them;
- one lossless sentinel error per malformed or truncated source byte outside literals;
- stable byte offsets and token indexes;
- recovery after malformed `@` identifiers, numeric suffixes, escapes, and unterminated strings.

`self_host/compiler/parser.dew` consumes those tokens for the first bootstrap grammar: one public, zero-argument `main` function returning `I32` with one positive I32 literal body. It rejects lexical errors, extra declarations, parameters, wrong return types, incomplete syntax, and positive overflow.

The in-memory source-Bytes tokenizer port now covers the complete production token surface used by the compiler request. Descriptor streaming and `SourceIo` are intentionally outside this boundary because the frozen request already supplies bounded source bytes. Remaining frontend work is parser parity: the full expression, pattern, type, declaration, recovery, and parse-event surface.

## Performance

The implementation originally used long nested `if` chains for keywords and symbols. That made a clean tiny build take 81 seconds. Replacing those chains with literal `match` dispatch reduced the same build to 1.12 seconds.

Warm measurements on this workspace:

- tokenizer-only Dew check: 0.285 seconds;
- tokenizer plus tests check: 0.29 seconds;
- tokenizer/parser plus the original 16 tests check: 0.40 seconds;
- complete tokenizer plus bootstrap parser: 35 tests in 0.22 seconds, including 300 KB of trivia, identifier, and huge-exponent stress input plus IEEE minimum-subnormal, minimum-normal, maximum-finite, halfway, and above-halfway rounding cases;
- clean complete-tokenizer Wasm build: 1.25 seconds;
- full linked deterministic self-host smoke: about 17 seconds.

The tests compile once into one self-describing module. No test starts a compiler process per case.

## Linked result

`tools/check-self-host-smoke.sh` rebuilds the provider, runs the tokenizer baseline/parity suites and parser suite in one test module, builds the linked compiler twice in separate directories, checks compiler/output byte identity, validates the output, proves `i32.const 73`, and rejects fingerprint and unbounded-count corruption.

Current linked compiler:

- size: 898,311 bytes;
- SHA-256: `130e30b3e5d5b8d76620a589328092f92eaa33f5d00a5d2287e877e7e496e576`.
