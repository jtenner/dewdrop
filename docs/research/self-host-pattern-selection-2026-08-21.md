# Self-host variant pattern selection

Date: 2026-08-21

The Dew inference layer now selects local unit and tuple enum patterns.

Implemented behavior:

- qualified and bare local variant lookup;
- expected-type filtering for bare variant names;
- generic enum argument recovery from the matched type;
- `SelfHostBasicPatternConstructor` output with stable variant identities;
- tuple payload type constraints;
- unit-pattern selection;
- payload kind and arity diagnostics;
- consumed constructor-root tracking;
- zonked pattern type arguments.

Pattern constructor selection runs after match and control constraints, so each pattern has its matched type before generic substitution.

Focused tests cover generic `Some` and `None` patterns and payload arity failures.

Struct and imported variant patterns remain with imported member selection and pattern-field targeting.
