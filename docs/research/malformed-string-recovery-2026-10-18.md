# Malformed string escape recovery

The earlier Claude review's string-recovery concern is confirmed. This input
exposes a local value as a module value before the fix:

```dew
fn broken() -> Unit {
  f("\q", fn() {
    let inner = 1
  })
  let leaked = 2
}
type After = I32
```

Both tokenizers stopped at the invalid escape. The remaining closing quote
started another string and hid `, fn() {`. Native recovery then cleared the
outer function's brace count at the closure's closing brace. The native parser
returned four events, including the local `leaked` value and an extra error,
instead of one error and the valid `After` alias. A direct tokenizer test found
two tokens instead of six after `"\q", fn() {`.

## Change

Both scanners now finish a bad string through its unescaped closing quote or
stop before the line break. Recovery emits one `InvalidEscape` token. Escaped
quotes remain inside the bad string. Short and invalid hex escapes inspect each
digit before consuming it, so they cannot consume a closing quote or newline as
a missing hex digit. A raw newline after a backslash also remains visible. Native
source I/O errors still take priority when the source ends with an I/O failure.

The self-host parser also lost delimiters consumed before a lexical failure. It
now scans recovery delimiters from the failed declaration's starting token for
lexical errors. This uses the token array already in memory. Existing syntactic
recovery rules remain unchanged.

Recovery scans each bad tail once, uses a Bool for escaped-quote state, and adds
no buffer. Valid ordinary string scanning has no new allocation. The two hex
digits use a fixed two-step loop. The self-host recovery rescan applies only to
failed declarations; successful declarations retain their existing path.

## Tests and measurements

Native red tests confirmed both token loss and extra parser events. The self-host
red module also failed its token and parser checks. Evidence is in
`.tmp/malformed-escape-recovery`.

After the change, all 45 native tokenizer tests and 306 native parser tests pass.
The complete package runs took 0.364 seconds and 1.527 seconds. Focused tests
cover unknown escapes, invalid and short hex escapes, byte literals, escaped
quotes, LF and CRLF line endings, following declarations, and terminal source
I/O errors. The isolated native build directory is
`/tmp/dewdrop-implementation-2026-10-18/recovery-build`.

The self-host grouped module also passes all 29 tests. It includes the new
recovery tests, existing declaration and tokenizer parity tests, and the F32
boundary tests. Generation took 4.750 seconds, linking took 1.126 seconds, and
execution took 0.066 seconds. The logs are `green-generate.log`, `green-link.log`,
and `green-tests.log` in the evidence directory above. Source SHA-256 hashes
are saved in `source-sha256.json` beside those logs. No measured compiler
activity exceeded 30 seconds.

The [compact historical record](data/language-improvement-implementation-2026-10-18/malformed-string-recovery.json)
now saves the result lines, timings, log hashes, retained module hashes, and
source manifest in the repository. Historical command lines, process exit
codes, and native build hashes that the old logs did not save are marked
unknown. Reproduction commands are labeled separately. These focused tests do
not establish the final compiler-C feature result.
