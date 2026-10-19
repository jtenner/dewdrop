# Distinct proof sites for generated for-loop calls

The parser lowers each source `for` into calls to `iter` and `next`. Both calls
used the same byte offset. The transform proof map therefore stored only the
last selected target. A syntax-tree walker could call `next` in place of `iter`
and fail while reading a missing `cursor` field.

Use separate byte positions within the reserved `for` keyword for the generated
calls and patterns. A user expression cannot start at those positions. Pattern
and call facts use separate maps. The native and Dew parsers use the same rule.
No extra source text, map, or runtime operation is needed.

Validation: the routine native lane passed all 1,654 tests; integration passed
all 272 tests. Parser regression tests and the Dew transform syntax-tree walker
pass. The walker uses ordinary Array iteration and emits 42.
