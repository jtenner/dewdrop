# Item 06: bounded binary cursor

Dependency: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Test checkpoint: eight new tests, not yet run. Import is expected to fail
until the module exists. No baseline tests or snapshots changed.

Contract: a cursor owns a Bytes reference and a U32 position. Failed reads
leave that position unchanged. Errors contain position, requested length,
and available length. Slice reads and remaining bytes share the input.
Read/write U16/U32/U64 in explicit little or big endian order. Bounds use
`requested > length - position`; no unchecked addition precedes this check.
