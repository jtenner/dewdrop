# Wave 1 item 03: text split and lines

Base: `4a35c1d75d434056c5efee34aec4ea4e9d171e29`.
Test checkpoint: six new tests; not run at this checkpoint. The API is absent.

Contract: `StringView.split(delimiter)` returns a lazy `Iter<StringView>`.
Matches do not overlap. Leading, repeated and trailing delimiters yield empty
fields. Empty source yields one empty field. Empty delimiter yields the source
once (also for empty source). `lines()` splits on LF and removes a CR only
immediately before that LF. Lone CR stays. Final LF yields a final empty line.
Both return views of the source; `compact()` makes an explicit independent copy.
Exhausted iterators keep returning None. Iterator aliases share progress.

Plan: KMP prefix table, O(delimiter bytes) state, no source scan on construction,
one source byte read per scan step, at most twice as many search comparisons as
source bytes. Source scan and comparison counters give test evidence.
No compiler changes, new builtins, module slots, or B-tree edits are needed.
