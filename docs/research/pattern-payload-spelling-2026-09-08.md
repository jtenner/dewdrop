# Remaining payload spelling recovery

The old final branch of `self_host_body_pattern_payload_value` recognized
Some/Ok/Err suffixes after declaration field lookup and inferred child evidence
fail. It attempted to turn a request for an absent field into a scalar by
choosing generic argument zero or one from a callable's spelling. The earlier adapter
identity migration removed other paths, not this tail.

A focused test in `semantic_pattern_payload_spelling_test.dew` starts with
a valid user enum with `UserSome`, `UserOk`, and `UserErr` payloads. Payload zero
must retain its declared storage evidence; payload one must remain unresolved,
not reuse generic slot zero or one. All 423 hardening tests, 119 numeric records,
and shared corpora already pass this baseline (55.194 seconds). Thus this test
does not demonstrate a reachable normal-source failure. The branch's name helper
looks up a callable, not a variant; well-formed constructor identities do not
normally reach that spelling recovery.

The policy regression fails in all three positions before removal (0.038
seconds): declaration-to-name lookup, suffix matching, and arbitrary generic
slot access. The stale recovery branch is now removed. Valid declaration or
inferred-child evidence remains available. A missing field stays missing for
the caller's normal boundary check; a source suffix cannot supply evidence.

This removes obsolete recovery code, not all pattern/storage checks. Full
validation of corrupted constructor identities and physical field ownership
remains part of the broader audit.

After removal, all five policy tests pass (0.034 seconds). Full hardening passes 423 tests,
119 exact invariant records, and every shared execution corpus (56.562 seconds).
Clean bootstrap passes (166.093 seconds), with identical B/C raw and linked
SHA-256 `b8969dc4339abf28eb12cc807efb236af80e6635ff0960f840b18129241bee8d`.
Generated checks pass (4.086 seconds). The native backend and provider
are unchanged; their latest full-lane results remain in the preceding logs.

Runs exceeding 30 seconds remain speed defects; no speed tuning was included.
