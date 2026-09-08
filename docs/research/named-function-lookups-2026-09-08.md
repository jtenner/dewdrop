# Named linked-function lookup

Native `PlannedProgramWasmGCLink::function_of` trusted a map's array index and
returned that entry without checking its declaration. Changing one map value
to the slot of another valid function reproduced a wrong but well-formed
selection. After extracting the old getter unchanged, the exact-record test
fails (8.981 seconds): it returns the other function instead of LNK-504.

The checked lookup retains `None` for an absent key. A present entry must have
an in-range table index, the requested declaration, zero specialization-shape
length, an owned module and fragment, and matching fragment declaration,
lambda identity, function kind, and structural ABI key. Imported trait
requirements may have signature-only fragments in the importing module;
their stored declaration and source-fragment identity must still agree.
This is the plain-function table;
exact specialization selection uses a different table. SPC-304 rejects a
specialization placed in the plain table. No link-order fallback is added.

The checker returns all nine numeric fields. The production getter and final
link verification render the record before aborting. Phase is 5; module and
declaration describe the requested callee. This lookup has no caller body or
expression, so body is zero and expression is the missing sentinel. For owned
entries, detail packs a reason in its high 32 bits and the table slot below:

| Reason | Check |
| --- | --- |
| 0 | Table bounds or requested declaration |
| 1 | Module index bounds |
| 2 | Module identity |
| 3 | Fragment index bounds |
| 4 | Fragment declaration |
| 5 | Plain entry cannot be a specialization |
| 6 | Lambda identity |
| 7 | ABI key equality (expected true, actual false) |
| 8 | Function kind equality (expected true, actual false) |

Bounds report ARN-101. Identity differences report LNK-504. Missing-key lookup
does not read any function entry. Table verification also runs before a clean
link is returned; the getter rechecks later reads.

Seven focused tests pass, including all plain entries of the valid fixture,
missing lookup, signed/out-of-range indices, owner/fragment/key mutations, and
a real specialization deliberately placed in the plain table. The generic
fixture first used optimized lowering, which removed its identity call (six
pass, one fixture failure; 10.674 seconds). Unoptimized lowering retains the
required specialization (seven pass, 10.721 seconds). The final run including
link-boundary verification passes in 10.788 seconds. The native lane passed
in 152.827 seconds. Integration then exposed a too-strong module-ownership
check for imported trait requirements (57.279 seconds, failed). These have
local signature-only fragments by design, not local declarations. The revised
check permits that explicit kind while checking it against the source
fragment. A new imported-trait positive case and a wrong-kind negative case
pass with the other focused tests: eight tests, 11.407 seconds.

After the correction, the serial lanes pass:

- Integration: 268 tests, 65.826 seconds.
- Dew library: 326 tests and all shared runtime cases, 33.291 seconds.
- Self-host: 450 tests, 137 exact failure records, and all shared runtime and
  semantic probes, 148.395 seconds.
- Clean bootstrap: 170.597 seconds. B/C core and linked bytes match:
  `577075c3e5f27f53387b4e3ed1125ae019963c47c9ff487a8eba4630196d0ec8`.
- Generated-source and policy checks: 12.845 seconds.
- Stress: 15 tests, 0.345 seconds.

The provider and FFI files are unchanged. Runs above 30 seconds remain speed
bugs; this batch does not try to improve their speed.

This does not claim to verify all specialized call tables, complete physical
signature/type relocation, or every frozen call's semantic target. Those
remain separate audit items. No performance changes are included.
