# Named function identity during transforms

## Runtime controls

The earlier alias fix compared Function and Closure VM objects by object identity. That fixes one stored value compared with itself. It is incomplete for named functions: the backend uses singleton globals for those references.

Six source controls were compiled with the existing Native backend, validated with pinned `wasm-tools@1.262.0`, and executed in Node. Matching transform controls were compiled and executed with both existing compiler artifacts.

| Source comparison | Runtime | Native transform before fix | Dew transform before fix |
| --- | --- | --- | --- |
| `same(identity, identity)` | true | false | false |
| two bindings from the same named function | true | false | false |
| two helper returns of the same named function | true | false | false |
| one stored capturing closure and its alias | true | true | true |
| two fresh closures with equal captured data | false | false | false |
| two fresh noncapturing closures from one lambda site | false | false | false |

The supported closure controls return I64. Initial I32 control forms failed the existing backend with UnsupportedExpression and are excluded from identity claims. Sources, hashes, per-command times, and output values are in `.tmp/transforms-v3/named-function-reference-probes/`; the read-only report is `.tmp/transforms-v3/named-function-reference-review.md`.

## Fix

The semantic call proof now carries a checked declaration identity for a callable without a receiver. Both the callable's own generic parameters and its owner's generic parameters are checked. A declaration with neither kind of generic parameter has a proven singleton. A generic declaration is marked as unresolved for exact ABI identity; its type is not guessed from a result-kind string or a Wasm carrier.

Each Function value has a separate FunctionIdentity field. Each reference proof stores `{target, identity}`, so function evaluation still uses one map lookup. The target and result-coercion metadata remain specific to their checked source site. No function wrapper cache or per-machine identity map is added. Proof registration saves one final record after target selection.

Reference equality checks physical alias identity first. It then compares proven non-generic singleton declaration IDs. Fresh closures and bound receiver values retain instance identity. Separate declarations remain distinct, even when their code or instruction is the same. Comparing separate references to the same unresolved generic declaration gives `generic function reference identity needs a checked ABI identity`. A stored generic alias still compares true without that error.

This is a narrow fix for proven named singletons. Source-reachable generic references to the same declaration still need exact checked ABI identity or logical frame metadata before equality can be decided across separate evaluations. The compiler reports that limit instead of returning a guessed result. No algorithm is selected by a function name or module path.

## Validation

- Native VM tests: 71 passed in 1.894 seconds, including the root agent's new vector/byte tests and the new singleton/generic identity tests.
- New Native source regressions: 8 passed in 18.588 seconds. These cover three named-singleton forms, builtin singleton identity, distinct declarations, closure aliases, and fresh captured/noncapturing closures.
- The byte source execution test passed in 1.298 seconds.
- The integrated Dew source check passed in 14.294 seconds. All 75 Dew transform tests passed, including the new identity, vector, and integer-bit cases. Test generation took 6.990 seconds, linking 1.420 seconds, and execution 0.233 seconds.

Logs: `native-after.log` and `native-text-after.log` under the probe directory. The first command also had a final nonexistent test-file filter; the VM and eight source cases had already passed. The correct byte test file then passed separately. Each compiler step was timed with `self_host_measure`. These results do not claim a controlled speed or allocation benchmark.
