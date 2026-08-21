# Self-host variant pattern selection

Date: 2026-08-21

The Dew inference layer now selects local unit, tuple, struct, and struct-variant patterns. It also selects local struct-variant construction.

Implemented behavior:

- qualified and bare local variant lookup;
- expected-type filtering for bare variant names;
- generic enum argument recovery from the matched type;
- `SelfHostBasicPatternConstructor` output with stable variant identities;
- tuple payload type constraints;
- unit-pattern selection;
- struct and struct-variant field lookup and type constraints;
- struct-pattern rest handling;
- missing and unknown pattern-field diagnostics;
- struct-variant construction with ordinary object-field targets;
- payload kind and arity diagnostics;
- consumed constructor-root tracking;
- zonked pattern type arguments.

Pattern constructor selection runs after match and control constraints, so each pattern has its matched type before generic substitution.

Focused tests cover generic `Some` and `None` patterns, generic struct and struct-variant patterns, struct-variant construction, unknown fields, and payload arity failures.

Imported variants, fields, callables, and patterns remain with imported selection and evidence work.
