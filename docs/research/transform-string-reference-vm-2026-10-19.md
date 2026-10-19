# String references in the transform VM

Date: 2026-10-19.

## Fault

The syntax-tree transform calls ordinary String equality code. That code uses
`ref.cast`, struct fields, raw byte chunks, and SIMD instructions. The native
transform VM rejected `ref.cast`. The Dew VM tried to read integer bits from a
String before it checked the instruction name.

The first String fix exposed a second fault. Source `for` loops lower to an
`iter` call and two `next` calls. The parsers used the same source offset for
all three. The checked call table therefore replaced `iter` with `next`.
Generated `Some` and `None` patterns also shared an offset. Both parsers now
use different bytes within the reserved `for` keyword for different generated
sites. User expressions cannot start at those bytes. Both `next` calls retain
the same site because they call the same checked method.

## Change

Both VMs execute the selected Wasm instructions. String equality, concat, and
builder algorithms remain ordinary Dew source. No module path, declaration
number, or function name selects a String algorithm.

The checked lowering supplies raw struct field order and storage types. Cast
checks include field mutability, packed scalar widths, raw array element type,
and nested nominal identity. Unsupported nested shapes fail with a diagnostic.
This rule can reject equivalent nominal heap types; it does not assume that
all references have the same heap type. Generic raw struct layouts are not
accepted by this proof table.

String literals expose immutable UTF-8 chunks. Checked views retain the source
reference identity. A cast from a constructed byte view to String retains its
storage as `TextReference`; AST renderers, quote parts, declarations, imports,
errors, and text patterns read it through the VM String reader. The reader
checks the byte range and UTF-8 text. It also counts its work and allocation.

The native UTF-8 backing cache uses a map from immutable text content to byte
storage. Equal content can share immutable bytes, while reference equality
still checks the original value. The cache is cleared before each annotation.
The Dew String-to-Bytes view uses the existing source ABI and does not keep a
VM backing cache. Neither VM performs a growing linear cache search.

Dew scalar and pattern proofs now use source-site maps. They no longer scan
every proof for each operator or pattern. Pattern entries retain promotion
from an unselected binding to a selected constructor. Annotated-function
checks use a plan map built by the source scan rather than an all-files scan
on each helper call.

Struct patterns read cast views through checked fields. Tuple identity now
uses the same physical storage rule in both VMs. Missing checked native raw
layout declarations produce an assertion with the module and declaration ID.
The Dew `array.set` path checks an exact three-argument length before indexing.

## Checks and measured results

Commands use the repository timing helpers. Logs are under `.tmp/string-vm/`.
No full bootstrap was run for this work; the root agent owns that check.

- `DEW_NATIVE_TEST_PACKAGES=transforms tools/test-native.sh`: 35/35 passed,
  1.390 seconds. This includes wrong field mutability, wrong nested array and
  record type, repeated-literal cache work, and tuple identity.
- `DEW_NATIVE_TEST_PACKAGES=parser/for_loop_wbtest.mbt tools/test-native.sh`:
  3/3 passed, 1.631 seconds. It checks distinct generated call and pattern sites.
- All six native String compiler cases passed in the root agent's combined
  39-case compiler check. That check passed 39/39 in 37.563 seconds and exceeded
  the 30-second limit. The six cases cover ordinary equality,
  empty/UTF-8/multi-chunk text, mismatched full/tail chunks, concat to source,
  StringBuilder output to source, a built binding name, and a struct pattern on
  a checked String cast view.
- Final direct Dew generation: 6.027 seconds. Link: 1.475 seconds. The six
  reference/loop/float tests passed in 0.058 seconds. The full direct transform
  and reference module passed 26/26 in 0.094 seconds.
- Seven real source-pool requests passed in the direct Dew VM: long/UTF-8 String
  equality, concat to AST source, StringBuilder output to AST source, concat to
  a binding name, a cast-view struct pattern, the original syntax-tree walk,
  and the public combined String example. The old 100,000-step proof-scan
  failure did not recur. See `requests-final.log` for the total measured time.
- `moon build --target native --release src/dew_test_gen`: 33.050 seconds.
  The timing helper marked this as a performance bug because it exceeds
  30 seconds. This log has no Moon lock wait. A prior focused compiler test
  waited for the root agent's Moon test; that wait is not compiler runtime.

The final run used the current native release generator. Earlier failed
fixture parses were corrected before this run. During concurrent float work,
two direct builds stopped at unsupported float host opcodes; those declarations
were removed by the root agent before the successful final run. Those failed
builds did not supply a Wasm artifact to the final check.

## Limits

These results cover the Wasm instructions used by the tested String source
paths. They are not proof that all String, Unicode, vector, or raw heap
operations work in the VM. The checks do not measure peak heap use. The map
removes the observed quadratic cache search; the repeated-literal test checks
work growth and cache count, not host allocation bytes. Wasm heap-equivalence
checks remain a separate backend validation concern.
