# Read errors inside line comments

Date: 2026-10-18

## Confirmed scope

The original independent review listed this as an unverified concern:
`Tokenizer::skip_trivia` could consume a source read error inside a `//` comment.
The concern is a real defect in the public native descriptor tokenizer API.
A repository search found no current production compiler caller of `from_fd`;
this is not evidence of a current file-loading fault in the compiler CLI.

## Trigger and cause

`Tokenizer::from_fd` reads through a reusable `Utf8Cursor` buffer. When a read
fails, `fill_first` or `fill_second` marks the source error as emitted and creates
an I/O-error marker at the terminal byte offset. `Tokenizer::next` normally
converts that marker to `Error(SourceIo(code))` once.

The line-comment loop consumed every unit until a newline or EOF. An I/O-error
marker is not a newline, so the loop discarded it. The source error was already
marked as emitted. The next call therefore returned clean EOF instead of the
read error.

A native regression test opens a pipe containing `// comment`, puts those bytes
in the tokenizer buffer, and closes the descriptor. The next refill returns
`EBADF` (code 9 in the test environment). Before the fix, the token stream is
empty. After the fix, it contains exactly one `Error(SourceIo(9))` at byte offset
10, followed by EOF. This uses the actual public `Tokenizer::from_fd` path.

A second test uses the existing terminal-error helper for `//`, `// comment`,
and a comment after spaces. It checks error code, byte offset, and single-error
emission. The same inputs with normal EOF remain trivia.

## Change and cost

The inner line-comment loop now stops before an I/O-error marker. The normal
`next` path reports the error. No new state, buffer, allocation, host function,
or error type is needed. This adds one marker predicate to each comment-loop
iteration. No runtime speed gain is claimed.

The self-hosted lexer reads an in-memory `Bytes` value. It has no descriptor
refill or source-I/O marker path, so this fix does not add a self-hosted branch.

## Validation

```sh
DEW_NATIVE_TEST_PACKAGES='tokenizer/lexer_wbtest.mbt' bash tools/test-native.sh --target-dir /tmp/dewdrop-implementation-2026-10-18/tokenizer-fd-build
```

Before the fix: 23 of 25 tests passed. Both new cases failed because the expected
source-error token was absent. The command took 0.383 seconds.

After the fix: all 25 tests passed in 0.368 seconds. The isolated target folder
kept the main native test build unchanged. No compiler step exceeded 30 seconds.

[Failing results](data/tokenizer-comment-read-error-2026-10-18/red.txt),
[passing results](data/tokenizer-comment-read-error-2026-10-18/green.txt), and
[the measured command](data/tokenizer-comment-read-error-2026-10-18/green.json)
are retained with this note.
