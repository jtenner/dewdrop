# Transform signature reflection

Baseline: `ee12ab0ba3`. The remaining-work request includes structured parameter
and type nodes. This change exposes source types in the existing context, without
changing two-field `FnNode` constructors or the placeholder check for original
bodies that a transform will replace.

`TypeNode` retains the source kind, name, and nested arguments. It covers named,
qualified, tuple, applied, function, and computed types. Function results are the
last argument. Applied bases are the first argument. Computed expression bytes
remain source text. `ParameterNode` retains each name and type. Generic parameter
nodes retain names and structured bounds. Aliases are not resolved by this API.

Both compiler implementations construct supplied arrays by calling the ordinary
Dew `syntax_array` library body. The compiler passes bounded interpreter storage;
the library builds the standard array value. Unchecked interpreter fixtures keep
the existing sequence fallback when no checked array-layout proof is available.
No runtime builtin or standard-path dispatch was added. Type recursion has a
128-node depth bound and charges the existing work/allocation budgets.

Reading names exposed an existing restriction on string literal patterns. Both
interpreters now compare checked UTF-8 string literal payloads. Normal source
checking still requires the string trait import. Array indexing requires the
normal array trait import.

## Checks

Evidence is under `.tmp/transforms-v3/`. `signature-red.log` records the initial
missing-field failure along with missing string-trait diagnostics. The final
`signature-native-8.log` passes two whole-compiler tests for named types, generic
bounds, tuples, function types, and applied types. The focused file took 8.403
seconds. `native-transforms-2.log` passes all 21 existing interpreter tests in
0.817 seconds. `dew-signature.log` passes 12 Dew interpreter tests; generation
was 4.987 seconds, linking 1.139 seconds, execution 0.071 seconds.

An initial command selected the whole driver package instead of the owning file.
It took 35.134 seconds and is recorded as a test-harness performance issue in
`signature-native.log`. Another broad run was stopped after its transform tests;
its partial package results are not final validation evidence.

`bootstrap-signature.log` passes the clean compiler self-build. Raw and linked
B/C SHA-256 is `2d93b52c12507c1073342511462a637882d6b2a309df4500461ddd0110beb604`.
`requests-signature.log` passes all 21 real Dew compiler requests, including the
two new examples. Each output returns 42. All ten rejection requests retain the
expected diagnostic and write no output. Generated-source and API checks pass.
