# Testing standard library

## Scope

`dew.std.testing` is the source-level assertion helper layer above the
compiler-owned `test`, `expect_trap`, `assert`, and `unreachable` primitives. It
is an ordinary selective standard module, not a second test runner or metadata
format.

The initial public helpers are:

- `fail(message)`;
- `assert_true` and `assert_false`;
- generic `assert_equal` and `assert_not_equal` using ambient `Eq` evidence;
- generic ordering assertions using `Lt`, `Lte`, `Gt`, and `Gte` evidence;
- shape assertions for `Option` and `Result` variants.

Every helper accepts an explicit message because optional arguments and source
macros are not implemented. Helpers evaluate their supplied values once and use
ordinary static trait evidence. They do not allocate formatted expected/actual
values, capture source expressions, catch traps, or depend on `Show`.

## Failure behavior

`fail(message)` calls the existing compiler-owned `assert(false, message)`.
Production compilation therefore retains the direct zero-I/O unreachable trap.
Test-mode compilation retains the existing dynamic-message transport through
the private assertion runtime. The module does not define a new failure global,
custom section, or host protocol.

Variant assertions pattern-match directly:

- `assert_option_some` and `assert_option_none`;
- `assert_result_ok` and `assert_result_err`.

They intentionally check shape only. Value extraction helpers are deferred
because generic `Never`-arm joins currently expose a backend validation gap;
adding an API whose valid arm returns a generic value must wait for that carrier
join to be fixed rather than encoding a compiler failure into the standard
surface.

## Test metadata boundary

Top-level `test "name"`, `expect_trap`, `_test.dew` visibility, deterministic
`dew.tests` metadata, filtering, and runner behavior remain compiler and tooling
features. `dew.std.testing` is usable in production code as ordinary assertion
functions, but it neither discovers tests nor changes reachability.

## Integration and validation

The module is loaded from reserved standard slot 50 and embedded by
`tools/generate_testing_std.py`. Wildcard imports include it; explicit imports
select only the ordinary preamble, Option, Result, and the testing source.

Coverage includes standard tests for passing helpers and expected failure,
production Node snapshots for success and failure, manual execution of both
fixtures through the pinned Wago snapshot runner, selective-loading tests, and
full generated-source and project validation.
