# Array methods use selected calls

The self-host emitter no longer emits Array algorithms from method spellings.
The special push, pop, unchecked-read, and unchecked-write paths are removed.
The two remaining method-target branches now use the common frozen call recipe,
which checks target/operand agreement and keeps the planned evaluation order.

Removed code includes:

- Array push/pop instruction-sequence builders and wrapper-field prefixes;
- late receiver/carrier guesses used only by those builders;
- the raw-versus-planned argument switch that bypassed the stored recipe;
- unreferenced helpers used only by the deleted paths, including self-recursive
  helpers with no callers outside their own bodies.

Only a checked raw `array.get` reaches the direct intrinsic read path. That path
casts raw storage; it no longer unwraps an Array through guessed field zero.
Raw array instructions remain available. Array algorithms remain Dew functions.

Two source-policy checks failed before removal. Shared Array, raw storage,
member/index, ring, Map, Set, stack, and iterator execution remains enabled.
This removes more than 2,000 lines without removing those tests.

Literal construction and several carrier-planning/name-based owner heuristics
still remain. The old link module marker is not removed by this change. The
complete Array physical-layout migration is therefore still open.

## Measured checks

- Array policy: 15 passed, 0.072 seconds; both added checks failed before removal.
- Hardening: 239 tests, 29 exact failure records, and all shared probes passed,
  60.281 seconds. The member/index corpus still checks Unit evaluation order.
- Generated sources and CLI fixtures: passed, 4.045 seconds.
- Clean bootstrap: passed, 170.456 seconds. B/C core and linked bytes agree.

Linked B/C SHA-256:
`0dbbd03204310ea1cf1412745044bedbd9d83c739d07cd629d72963f68fb21e4`.

The immediately preceding index-write change also passed all 944 native tests,
15 stress tests, and 10,982 pinned Starshine tests. This change touches only the
self-host emitter, its source-policy test, and docs. A function-body comparison
confirmed that only the main emitter changed: seven unused Array helpers were
removed, and all other retained function bodies are unchanged.

Runs above 30 seconds remain performance bugs. The smaller source file is not
a measured speed improvement; bootstrap timing still needs separate work.
