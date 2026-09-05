# Frozen physical local slots

Source-shape erasure alone missed `identity<Unit>`. The body plan now stores a
parallel logical-to-physical local-slot table and physical local count. Parameter
seeding first specializes each logical type, omits Unit/Never, then advances the
physical parameter cursor. It no longer assigns the following scalar carrier to
an erased parameter.

Local emission, pattern bindings, scratch allocation, and capture storage consume
the frozen map. Discard decisions check the planned carrier, preventing a drop
after an erased generic local read. Dense local IDs have a checked fast path;
scratch base lookup is constant-time when a body plan exists. ARN-103 checks the
slot/value arrays before verification.

Validation: 125 hardening tests and 25 exact records pass. The execution lane
passes 84 reference/capture/Unit checks and all 66 shared callback cases. A new
generic scalar-capture test remains enabled and fails at closure construction:
its environment still uses the unspecialized reference field. That is the next
separate fix. The one-field negative test removes one frozen slot and checks the
complete ARN-103 record.

Before this change, clean bootstrap at commit `686ed7d` passed with identical B/C
SHA-256 `342d26d40a53a99b9cdd7218b3de0e71edf88e857bdbd3a8838cc9a691e75b6c`.
Compiler A build took 29.290 seconds; A/B self-host executions took 55.174 and
57.282 seconds. Both exceed the 30-second limit and remain visible performance
bugs. Total bootstrap took 160.801 seconds. This commit needs a fresh bootstrap
after the remaining generic capture fix.
