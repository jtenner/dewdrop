# Wave 1 item 07: incremental SHA-256

Base: 8c3b047fe633aa11c6634b929045376e9dfc7d6c.
Test checkpoint: new stream test reuses all CAVS messages and checks every
split, empty updates, shared state aliases, repeated finalize, rejected
post-finalize updates, and independent returned digests. Not run yet;
sha256_new/update/finalize do not exist at this checkpoint.

Contract: new state is shared by aliases. Update returns false after finalize
or if total bytes would exceed 2^61-1; rejection makes no change. Finalize
closes the state, is repeatable, and returns a fresh FixedArray<U8> digest.
Empty updates succeed only while open. State retains no input Bytes.
