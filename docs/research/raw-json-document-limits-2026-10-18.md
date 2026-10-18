# Raw JSON document limits

Raw documents now retain their caller's immutable `JsonLimits` object and use
it in `materialize()`. They no longer reparse with the default limits. Stored
source and limits are private fields. The existing source accessors remain
available. This adds one retained reference, with no new limits allocation.

The regression builds 129 nested arrays. Default validation rejects that depth;
validation with `max_depth = 130` accepts it. Materialization must then succeed
with those same limits. A second test checks caller input-limit rejection and
default materialization.

The tests ran against the original JSON source first. Generation took 0.329 s,
and the first test failed with `custom limits lost on materialization`; the
second passed. The current importing test module built with the fresh release
generator in 0.347 s. Both tests passed under Node in 0.034 s. Tests are in
`std/tests/json_raw_limits_test.dew` and run in the full standard-library lane.

The depth case is a small proof of the shared limits path. It does not allocate
an input larger than the default 16 MiB or a million-value tree just to exercise
the other numeric limits. No speed or peak-memory gain is claimed.
