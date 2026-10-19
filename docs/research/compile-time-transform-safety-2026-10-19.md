# Compile-time transform safety

The native evaluator uses the selected operator declaration. It does not assume
that `+` or `==` names a primitive operation. The semantic proof reads actual
builtin metadata and accepts exact forwarding of the original two parameters.
The existing bounded Boolean proof checks all four inputs. The evaluator also
checks that the proved opcode matches its number kind and operator. Unsupported
custom operators stop with a diagnostic. Index calls and string patterns are
rejected until their selected methods can be proved or evaluated.

Validation blanks each annotated function in its original file. Bytes and
newlines stay in place. A separate source file holds its signature and temporary
body. The temporary body calls a fresh private Never builtin. The name is absent
from every input file, including parameters. Original helper offsets thus remain
valid for operator proofs. The output pass uses separate generated files too.

The evaluator rejects calls to annotated original bodies. It rejects non-UTF-8
string literals instead of changing their bytes. Function calls retain their
source file for proof lookup and restore the caller's file on exit.

The entry signature check uses resolved declaration IDs. It requires two
parameters, FnNode and TransformContext, and a result of FnNode or
Result<FnNode, TransformError>. It accepts type aliases and rejects generic
entries. The CLI selects external standard sources from a load-only manifest
that includes the compiler libraries when transform syntax is present. This
loads the selected standard root's array source before the AST module needs it.

The Dew proof collector reads original inference job targets. Lowering can
clear a target when it folds a constant, so planned expression targets alone
do not supply the required source proof.

The source scanner reads function ends with one moving token cursor. Its fast
activation check streams tokens and stops at the first top-level annotation or
`transform fn`. A local or ordinary function named `transform` stays inactive.

Declaration scans, parameter cells, enum variants, and scope copies consume the
execution budget. Expression, pattern, and qualified-path recursion have depth
guards. The allocation counter is a work budget with fixed charges;
it is not a measurement of live heap bytes.

## Native checks

- `DEW_NATIVE_TEST_PACKAGES='transforms' tools/test-native.sh`: 13 passed,
  0.786 seconds. Log: `.tmp/transforms/safety-native-unit.log`.
- The compiler driver lane passed 9 tests in 12.382 seconds with the final
  validation and output file layout. Log:
  `.tmp/transforms/safety-native-complete.log`.
- That earlier combined run also records two test-only compile errors from
  attempts to construct read-only parser patterns. The final unit run parses a
  130-level source pattern and passes.

Checks cover a custom scalar Add method, a helper below a target, no preamble,
a parameter named `unreachable`, an endless loop, forbidden host calls, deep
patterns, scope and name-lookup budgets, 1,001 function ends, original source
offsets and newlines, invalid UTF-8, and calls to an annotated target.

The later entry signature, loader, name, and pattern tests passed in the final
18-test interpreter and 19-test driver run described below.

No new whole-program cache fault was found. The input digest includes all
source bytes and file paths. The producer context includes the compiler and
dependency fingerprints. The bootstrap compiler fingerprint includes the
embedded native library sources and the external standard source tree.
Transform execution has no host input and is deterministic under these inputs.

## Checked pattern selection

The evaluator now reads constructor selection from semantic pattern metadata.
A checked binding has an empty constructor key. A selected enum pattern has
the canonical module, enum, and variant key. The lookup includes the original
module, file, and byte offset. This prevents a bare `None` pattern from binding
an entire `Some` value. Tuple constructor patterns use the selected root pattern
and retain separate proofs for payload bindings. A selected constructor takes
priority when its owner node has the same byte offset.

Both compiler implementations carry these proofs into transform execution.
Native driver tests cover bare and qualified Option patterns, a local enum,
and a normal binding. The shared request fixture
`examples/transforms/patterns.dew` must produce 42 from all three forms.
The native transform lane passed 18 tests in 0.812 seconds. The driver lane
passed 19 tests in 22.433 seconds. The raw log is
`.tmp/transforms/pattern-native-3.log`. The shared Dew pattern request also
produced 42 in `.tmp/transforms/requests-node-5.log`.

Unsupported local values, type aliases, traits, foreign types, and foreign
library aliases stop name lookup. They cannot fall through to a same-named
imported helper. A native regression checks this path.

These runs are functional checks. They do not establish a runtime speed gain,
heap bound, or cross-architecture result. The Dew adapters are in
`self_host/compiler/transform_operator_proofs.dew` and
`self_host/compiler/transform_pattern_proofs.dew`. The final full compiler and
request results are recorded in
[`source-transform-implementation-2026-10-19.md`](source-transform-implementation-2026-10-19.md).
