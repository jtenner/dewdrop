# WASI process scratch validation

`dew.std.process.wasi` uses one 65,520-byte region after its 16-byte control
prefix. Argument and environment imports must fit both the pointer table and the
text payload in that region. The host-reported count is at most 4,096, the text
payload is at most 49,152 bytes, and `count * 4 + bytes` cannot exceed 65,520.

Every host-written string pointer must address the declared text payload. The
adapter rejects pointers into the control prefix or pointer table, pointers at
or beyond the text end, and strings without a terminating zero inside the
remaining payload. UTF-8 errors retain the requested process operation, so an
environment value reports `Environment` instead of `Arguments`.
