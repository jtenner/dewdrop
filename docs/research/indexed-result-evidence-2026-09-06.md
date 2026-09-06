# Indexed result evidence

The ordinary Map prototype triggered twelve self-host body-plan diagnostics.
Indexed reads overwrote their resolved result shape with the receiver's first
type argument. The nominal-owner fallback guessed a different argument when
the type name ended in Map. Neither rule described the selected IndexedGet
implementation.

Index-read seeds now retain the resolved, specialized expression type and exact
selected call target. Linked call-result constraints check that evidence. No
receiver type argument or type-name suffix supplies index-result evidence.

The shared member test includes RoadMap<U32, I64>. Native library checks pass
(11.930 seconds); self-host hardening passes (54.121 seconds). The hardening lane
still exceeds 30 seconds and remains a performance bug. The Map prototype no
longer has those twelve carrier errors. It now exposes a later Option payload
constructor bug, tracked separately rather than masked by this change.
