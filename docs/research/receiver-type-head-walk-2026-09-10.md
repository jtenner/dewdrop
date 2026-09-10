# Receiver primitive type-head walks

The receiver primitive lookup stops after eight body-type links and reports
ordinary absence. It also refuses to follow an applied-type base when that
base uses the negative resolved-type encoding. Neither behavior proves that
the receiver is not primitive.

A direct I64 type followed by 64 internal application-head wrappers checks
the walk contract. The wrappers are an internal graph fixture, not a claim
that applying I64 is source-language syntax. A separate test starts with a
valid generic source type and replaces one body-type node with a self-cycle.
The cycle must have an exact numeric record instead of becoming rank zero.

The first baseline takes 114.607 seconds. The long-chain test fails as intended.
The cycle fixture incorrectly assumes the source inference node is a resolved
link. Its setup assertion traps, and the exact-record checker correctly rejects
that unrelated failure. The corrected fixture appends a resolved generic link,
checks it, and then replaces that one node with a self-cycle.

The corrected baseline passes 906 tests and fails both new tests for the
intended reasons in 114.125 seconds. The cycle returns normally, which the
exact-record checker rejects.

The walker now follows negative resolved links as well as body links. It checks
arena bounds and signed encoding before reads. A chain can visit at most the
number of body nodes without repeating; reaching that bound reports ARN-108
with the module, root encoding, arena size, and hop count. Missing and
non-primitive types still return no primitive rank. No visited-set allocation
or arbitrary depth cutoff is needed for this single-successor walk.

The first implementation run passes 908 tests and 471 records in 115.146
seconds. The expanded run also checks an invalid body index and an
unencodable resolved index: 910 tests, 473 exact records, all 318 shared
callback checks, and the other emission/library and semantic probes pass in
112.178 seconds. Generated checks pass in 6.403 seconds. Bootstrap exposed a
separate loop divergence emission defect after 111.638 seconds; see the
[loop stack log](loop-divergence-stack-2026-09-10.md). Its fix is required for
this walk's non-fall-through loop. Combined hardening then passes 910 tests,
473 records, and 324 shared callback checks in 105.182 seconds. Generated checks
pass in 5.339 seconds. Clean combined bootstrap passes in 194.293 seconds;
compiler B/C core and linked SHA-256 is
`4debc1eaeeb082b6457424102718449be883a1f0b7761fee8470a7fda59777b8`.
The provider and FFI are unchanged. Runs above 30
seconds remain timing defects; speed work is deferred.

This checks type heads only;
complete argument/signature child graphs remain a separate boundary check.
