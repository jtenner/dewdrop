# Imported static method path checks

A Dew compiler request for `@tools.Scale::new(2i32)` failed before transform
execution. The checker selected the correct static method, but it cleared the
provisional unsupported-expression flags for only `Scale::new` and `Scale`.
The import alias at the start of the path kept its flag. Physical planning then
reported an unsupported poison expression.

The Dew checker now clears the full checked qualified/field path after one
static method is selected. This matches the native checker's
`consume_unsupported_root` rule. It does not change the selected callable type,
poison other types, or clear errors after a failed or ambiguous lookup.

The regression in `semantic_method_context_test.dew` checks a named imported
static factory followed by an instance call. It requires clean inference and
physical planning. A wrong Boolean argument must still report
`NoMatchingMethod`. The broad Dew hardening lane passed 1,035 tests with this
regression. The real transform request `imported_methods.dew` also produced a
validated module whose `main()` returned 42.

Evidence is in `.tmp/transforms-v2/hardening-final.log` and
`.tmp/transforms-v2/requests-final.log`. The saved earlier request failure is in
`requests-2.log`. The source audit is in `dew-local-blocker.md` and the agent
messages for the static-path follow-up; those reports are review evidence,
not substitutes for the executed tests.
