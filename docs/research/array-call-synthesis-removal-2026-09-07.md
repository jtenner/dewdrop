# Remove old Array runtime call synthesis

The self-host linker no longer emits `dew_array_*` builtins as runtime functions.
It also no longer keeps an elided capacity builtin alive through a special rule.
Unsupported old targets stay unsupported; they do not acquire a guessed ABI.

Emission no longer:

- rewrites a direct call named `self_host_array_pop` or an old Array push target;
- adapts old Array allocation results through target spelling;
- substitutes old Array length, capacity, clear, or backing-field builders;
- invents an empty Array when a constructor has no physical function;
- invents iterator-next or has-next runtime calls when method selection fails;
- searches for `dew_array_iter` to repair a missing iterator declaration.

Missing selected callable/method functions now return BOD-607 diagnostics with
body, expression, and declaration IDs. The raw intrinsic path still verifies
its stack contract and reports unsupported targets by their exact opcode name.

The obsolete emission tasks and their empty/field-access builders are deleted.
A self-host negative test checks both linker classification and the exact
`dew_array_clear` error. Source-policy checks prevent those tasks and builders
from returning. Existing shared Array and iterator tests remain enabled.

This is not the end of Array migration. The literal wrapper recipe, several
name-based receiver/type heuristics, and remaining push/pop/index-write fallback
paths still need removal. The obsolete link module marker also remains until
its consumers are replaced. No new module-name or declaration-order rule was
added here.

## Measured checks

- Source policy: 13 passed, 0.064 seconds (failed before removal).
- Hardening with the new negative test: 239 tests, 29 exact failure records,
  and all shared execution probes passed, 57.058 seconds. The first run passed
  only the existing 238 tests; the new test was moved into its own Array file
  and explicitly added to the runner before the final run.
- Generated sources and CLI fixtures: passed, 3.408 seconds.
- Clean bootstrap: passed, 157.724 seconds. Compiler A build took 38.170 seconds;
  A/B execution took 42.316 and 55.334 seconds. B/C core and linked bytes agree.

Linked B/C SHA-256:
`7bc2f3f886adf1127a8e97bde4d340d002ea3a10316f378b76652880eb81c888`.
Runs above 30 seconds remain performance bugs.
