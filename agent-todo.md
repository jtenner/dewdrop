# Dew Agent TODO

> Current handoff updated September 9, 2026. The older deferred backlog below
> comes from [`docs/roadmap.md`](docs/roadmap.md); it is not a claim that the whole
> roadmap was re-audited today. Use small commits with tests, docs, and measured
> compiler runs. Fix correctness before speed. Do not push without a new request.

## Current work — do this first

The standard-library migration and compiler audit are not complete. The detailed
history is in [`docs/research/stdlib-builtin-migration-worklist-2026-09-05.md`](docs/research/stdlib-builtin-migration-worklist-2026-09-05.md).
Scalar, packed `Into`, SIMD, and math migrations have landed. Typed Starshine FFI
names and unqualified enum support have also had implementation work; do not
restart them from scratch. Raw Unit array storage now passes both compilers.

### Compile-time type queries and branch removal

Implementation is complete in both compilers. The shared corpus now has 102
execution checks. Read the [query guide](docs/compile-time-types.md) for the
20 builtins, examples, and layout limits. The full history and measured checks
are in the [completion log](docs/research/compile-time-query-completion-2026-09-06.md).

- [x] Pure query/assertion builtins in `dew.std.types`. Use logical type identity;
  keep unknown types pending and errors diagnostic. Emit no runtime query calls.
- [x] Real `field_type` and `variant_payload_types` results in declarations,
  lambda signatures, and generic arguments. Support imported/generic owners,
  deferred member projections, aliases, `Self`, and block-local type bindings.
- [x] Ordered `field_names` and `variant_names`, with fresh string arrays.
- [x] Scalar and ordered-tuple raw layout queries. Reject unsupported GC layouts;
  never invent object offsets or turn missing layout evidence into a reference.
- [x] Private specialized IR bodies and exact logical keys. Fold query guards,
  local aliases, captured scalar query values, and short circuits before planning.
- [x] Branch-local `implements` proofs and type facts. Recheck selected fields,
  operators, calls, overloads, results, and generic method bounds, including imports.
  Preserve concrete source errors and trait cycles/limits.
- [x] Remove dead calls, locals, captures, lambdas, and storage demand. Keep source
  IDs, argument effects, Never prefixes, and the exact selected emitter input.
- [x] Native/self-host positive and negative tests, numeric invariant records,
  shared Wasm execution, and checks that no query reaches physical emission.
- [x] Complete the final full-lane run and fresh byte-identical B/C bootstrap.
  Native 913 tests, integration 266 tests, stdlib execution, hardening 220 tests
  and 29 records, generated checks, 15 stress tests, and all 10,982 pinned
  Starshine tests pass. The refreshed provider passes hardening and integration.
  Compiler B/C core and linked Wasm bytes match in the clean bootstrap run.

### Performance follow-up

Correctness comes first. Keep these timing defects visible after query completion.

- [ ] Reduce full-module query instance copies to body-local overlays. Keep exact
  logical keys, immutable source templates, and one selected emitter input.
- [ ] Profile and share repeated query source/evidence maps where safe. Keep local
  and capture IDs tied to their owning body; do not reintroduce ID guessing.
- [ ] Reduce compiler builds, test lanes, and bootstrap stages that exceed
  30 seconds. Record both cold and warm timings; do not hide or skip slow tests.

### Finish the standard-library migration

- [x] Remove special `FixedArray` method and index dispatch. Compile the existing
  Dew method bodies and delete unused checked-read builders. Thirteen shared
  tests cover Unit, tuples, references, packed values, bounds, and evaluation
  order. Native/self-host checks and a clean B/C fixed point pass. See the
  [migration log](docs/research/fixed-array-library-migration-2026-09-06.md).
- [x] Finish raw Wasm array contracts and storage adapters. Both compilers bind
  raw owners from checked declarations, preserve typed scalar and product
  storage, and support `array.new_default` and `array.copy`. Fourteen shared
  cases cover multiple generic parameters, Unit effects, and storage bounds.
  Missing types fail at the storage boundary. Clean bootstrap passes. See the
  [contract log](docs/research/raw-array-contracts-2026-09-06.md).
- [x] Declare Array storage fields in Dew and compile length/capacity through
  ordinary library calls. Remove the native layout override and self-host size
  method shortcuts. Tests check actual field identities and changed method
  bodies. See the [accessor log](docs/research/array-library-accessors-2026-09-06.md).
- [x] Move Array allocation, growth, mutation, and iteration into Dew. All 13
  remaining builtins now have Dew bodies, with typed raw backing storage.
  Both compilers pass 28 shared Array checks and the clean B/C fixed point.
  Native method/operation ordinal dispatch and the iterator layout override are
  removed. See the [algorithm log](docs/research/array-library-algorithms-2026-09-06.md).
- [ ] Remove the old Array wrapper layout and literal shortcuts. Use declared
  fields and exact construction recipes, not a guessed three-field layout.
  Unused native Array operation nodes and emitters are now removed; literal
  construction remains; shared ring producers are now removed. See the
  [cleanup log](docs/research/array-legacy-ir-cleanup-2026-09-06.md).
  Literal storage now rejects unresolved evidence and preserves packed integer
  widths; all 29 shared checks pass. The unused opcode switch/helpers are gone.
  See the [literal storage log](docs/research/array-literal-storage-2026-09-06.md).
  Narrow raw arrays now retain packed width and signed reads through ordinary
  generic calls, literals, and growth. The literal's reference/first-child
  storage guesses are removed; its wrapper recipe remains. All 34 shared raw
  array checks pass. See the
  [narrow storage log](docs/research/narrow-array-storage-2026-09-08.md).
  The stack, iterator, accessor, and link fixtures now use declared Dew bodies,
  not removed runtime builtins. See the
  [fixture log](docs/research/array-library-fixtures-2026-09-07.md).
  The obsolete specialization search, Unit-to-reference runtime adapter, and
  native inline wrapper lookup are removed. See the
  [adapter removal log](docs/research/array-adapter-removal-2026-09-07.md).
  Old runtime call synthesis and empty/clear/iterator-next builders are also
  removed; missing selected functions remain errors. See the
  [call synthesis log](docs/research/array-call-synthesis-removal-2026-09-07.md).
  Remaining push/pop/read/write emitter builders now use selected calls too;
  only literal construction and planning heuristics remain in this cleanup.
  See the [method emission log](docs/research/array-method-emission-removal-2026-09-07.md).
  The pinned provider's old Array algorithms and three unused instruction
  exports are removed too. The shared Map layout helpers are also gone after
  its separate provider cleanup. See the
  [provider removal log](docs/research/array-provider-removal-2026-09-07.md).
- [x] Move Map hashing, buckets, growth, lookup, and iteration into Dew. Typed
  entries preserve aliases, cached hashes avoid repeated user calls during
  growth, and all 12 shared native/self-host checks pass. Native Map IR and
  self-host Map runtime emitters are removed. The clean B/C fixed point passes.
  See the [Map log](docs/research/map-library-storage-2026-09-06.md).
  The unused pinned-provider Map algorithms are removed too, including their
  Array layout helpers. The provider constructor no longer accepts collection
  carrier or Option layout arguments. See the
  [provider log](docs/research/map-bridge-removal-2026-09-07.md).
  The obsolete `dew_map_` query-demand rule and its unused separate logical-key
  propagation state are removed. Map uses the normal bound-call evidence path.
  See the [query rule log](docs/research/map-query-rule-removal-2026-09-08.md).
- [x] Move Set storage and iteration into Dew using Map with Unit values.
  Eight shared checks pass in both compilers. Special Set inference/layout/IR,
  the remaining native hash-table runtime, and its extra target arrays are gone.
  The clean B/C fixed point passes. See the
  [Set log](docs/research/set-library-storage-2026-09-06.md).
- [x] Move Queue, circular-buffer, and deque storage algorithms into Dew.
  Each family has a separate commit. Declared typed storage replaces the shared
  Array layout, and unused native ring code is removed. Twenty shared checks
  pass in both compilers, including Unit, tuples, references, bounds, growth,
  clearing, floats, and Iter. See the
  [storage log](docs/research/circular-buffer-library-storage-2026-09-06.md).
- [x] Move Text, Bytes, views, and builders out of compiler-owned algorithms.
  Keep encoding, bounds, and lifetime checks in ordinary library code.
  Bytes equality, hash, searches, affixes, UTF-8 validation, and checked String
  conversion now run in Dew. Bytes storage operations are migrated too.
  Declared text/builder storage probes now expose exact raw-array field gaps.
  Native heap ordering and field-only reachability are fixed. Self-host
  concrete array fields, constructor casts, and frozen field-write casts now
  pass the shared storage probes and clean bootstrap validation.
  The complete library migration now passes. See the
  [declared storage log](docs/research/declared-text-storage-2026-09-09.md).
  Bytes view range checks and shared-storage construction now use Dew, with
  the native/provider runtime entry removed. Both compilers, integration,
  and clean bootstrap checks pass; see
  the [Bytes view log](docs/research/bytes-view-library-2026-09-09.md).
  String/StringView slicing also uses Dew boundary checks over Bytes views.
  This fixes empty ranges at exact V128 array ends. Native, self-host,
  integration, generated, and clean bootstrap checks pass; see the
  [StringView log](docs/research/string-view-library-2026-09-09.md).
  Byte access now uses declared storage and raw array/lane instructions.
  The preamble uses a normal private import; ordering and Facet use library
  calls. Native, integration, generated, and clean bootstrap checks pass; see the
  [byte-access log](docs/research/bytes-access-library-2026-09-09.md).
  BytesBuilder allocation, growth, append, and finish now have Dew bodies;
  the four native/provider runtime entries and private copying helpers are
  removed. All 53 Bytes cases pass in both compilers, along with the library
  and self-host hardening lanes. Integration, generated checks, and the clean
  B/C byte-comparison checkpoint pass.
  See the [builder storage log](docs/research/bytes-builder-storage-library-2026-09-09.md).
  StringBuilder capacity, scalar encoding, and finish now use Dew too. All 47
  String cases pass in both compilers. Native, integration, provider, stress,
  generated, and clean bootstrap checks pass. No private text or
  builder algorithm bodies remain. The obsolete runtime bridge still needs
  cleanup; see the
  [StringBuilder log](docs/research/string-builder-storage-library-2026-09-09.md).
  Raw `struct.get N` now retains a concrete struct owner and physical field
  index in both compilers, including function-value wrappers and the native
  fragment codec. It accepts unpacked scalar fields only. Packed/reference
  fields and generic owners still need full contracts. See the
  [raw struct read log](docs/research/raw-struct-get-2026-09-09.md).
  Raw `ref.cast` now retains a concrete result heap in direct calls and returned
  functions. Both compilers reject missing targets and applied generic result
  types. Saved operand and heap mutations have exact numeric failure tests.
  This enables text representation conversions. See the
  [reference cast log](docs/research/raw-reference-casts-2026-09-09.md).
  String-to-Bytes now uses this instruction through its existing Dew functions
  and a new `Into<Bytes>` implementation. Both compilers and the provider have
  removed its old runtime entry. See
  the [String conversion log](docs/research/string-bytes-cast-library-2026-09-09.md).
  StringView-to-Bytes now also uses a raw cast and `Into<Bytes>`. Its old runtime
  entry is removed, with nested-range and returned-function coverage; see the
  [view conversion log](docs/research/string-view-bytes-cast-library-2026-09-09.md).
  Bytes-to-String and its JSON declaration now also use raw casts. Checked
  conversion and the new `Into<String>` implementation retain Dew UTF-8 checks.
  The final conversion dispatch and rewrap helpers are removed in both
  compilers and the provider. Storage algorithms still remain; see the
  [Bytes conversion log](docs/research/bytes-string-cast-library-2026-09-09.md).
  Bytes length now uses that raw instruction. Ordering and Facet call the Dew
  operation; the native and pinned provider length builders are removed.
  See the [Bytes length log](docs/research/bytes-length-intrinsic-2026-09-09.md).
  BytesBuilder length and its consumed-state check now run in Dew through raw
  scalar field reads. Both old runtime entries are removed. Shared checks
  cover live aliases, finished aliases, and a returned function. See the
  [builder length log](docs/research/bytes-builder-length-library-2026-09-09.md).
  StringBuilder now uses the same Dew-side lifetime check with its own heap
  identity. The last shared length builder is removed. Both changes pass a
  clean B/C bootstrap; see the
  [StringBuilder log](docs/research/string-builder-length-library-2026-09-09.md).
  BytesBuilder's default capacity now comes from Dew, with an ordinary
  returned-constructor and growth test. Its separate runtime entry is removed;
  the explicit-capacity allocator remains. See the
  [default constructor log](docs/research/bytes-builder-default-library-2026-09-09.md).
  StringBuilder defaults now also run in Dew. The allocator no longer has a
  separate default mode. Shared checks retain Unicode lengths, aliases, and
  growth; see the [StringBuilder default log](docs/research/string-builder-default-library-2026-09-09.md).
  String, view, and ASCII builder append now have Dew bodies and a private raw
  cast to the same BytesBuilder storage. The program reachability queue now
  retains returned function targets as well as calls. Scalar encoding, capacity,
  finish, and byte storage remain open. See the
  [StringBuilder append log](docs/research/string-builder-append-library-2026-09-09.md).
  The SIMD load algorithm now runs in Dew too. See the
  [Bytes log](docs/research/bytes-library-algorithms-2026-09-06.md).
  The pinned provider's nine old Bytes algorithms and UTF-8 validator entry
  are removed too. The provider no longer accepts a validator function index.
  See the [provider log](docs/research/bytes-provider-removal-2026-09-07.md).
  Bytes concatenation also uses a checked Dew body and the shared builder path.
  See the [concatenation log](docs/research/bytes-concatenation-library-2026-09-07.md).
  StringView scans also run in Dew, with shared native/self-host tests and a
  fix for reference-identity equality. View storage remains.
  See the [StringView log](docs/research/string-view-library-algorithms-2026-09-06.md).
  The pinned provider's 12 old StringView operations and eight unused shared
  text builders are removed too. See the
  [provider log](docs/research/string-view-provider-removal-2026-09-07.md).
  StringView byte access and conversion also use Dew calls; the old wrapper-copy
  builder is removed. See the
  [StringView access log](docs/research/string-view-byte-access-2026-09-07.md).
  String scans, equality, and concatenation use the Bytes library path. The
  String equality runtime builder and runtime-name lookup are removed.
  String byte access, ordering, and text iteration use the Bytes path. The
  emitter no longer selects text methods by name. See the
  [byte access log](docs/research/string-byte-access-2026-09-07.md).
  See the [String log](docs/research/string-library-algorithms-2026-09-06.md).
  The pinned provider's 13 old String algorithms and unused private builders
  are removed too. Text storage remains separate work. See the
  [provider log](docs/research/string-provider-removal-2026-09-07.md).
  String SIMD access now uses an ordinary Dew conversion and the shared Bytes
  load. The separate native/provider String SIMD entry is removed. See the
  [SIMD access log](docs/research/string-simd-library-access-2026-09-08.md).
  Bytes SIMD loading now checks its range and assembles sixteen lanes in Dew.
  Both native/provider load builders are removed. The byte storage accessors
  and builders remain. See the
  [Bytes SIMD log](docs/research/bytes-simd-library-load-2026-09-08.md).
  String pattern inference now selects the ordinary Eq method and keeps the
  literal's String type. Lowering and specialization retain that evidence.
  Self-host physical call recipes now retain the cached subject and literal and
  verify target identity, operand types, and result. Both emitters use the
  selected target and reject missing evidence. The no-evidence legacy path is
  removed; optional optimization cannot discard an unresolved comparison.
  See the [equality removal log](docs/research/string-equality-library-2026-09-07.md).
  See the
  [pattern log](docs/research/string-pattern-equality-2026-09-06.md).
  See also the [recipe checks](docs/research/string-pattern-call-recipes-2026-09-07.md).
  The [emission checks](docs/research/string-pattern-emission-2026-09-07.md) cover
  custom equality, nested patterns, evaluation order, and optimizer effects.
- [x] Convert remaining host-operation builtins into foreign declarations.
  Keep generated Dew types, provider metadata, and emitted signatures in sync.
  The 46 raw Preview 1 functions now use public `foreign import` declarations.
  Diagnostics remain. See the
  [WASI log](docs/research/wasi-foreign-imports-2026-09-07.md).
  Debug dispatch and result discard now use ordinary Dew functions; primitive
  output has an explicit private foreign import. Formatting and its transport
  remain. See the [Debug log](docs/research/debug-library-dispatch-2026-09-07.md).
  High-level WASI Bytes reads and writes now use ordinary Dew loops and raw
  foreign calls. Shared tests cover partial/empty/multi-window operations and
  invalid host results. The obsolete read runtime is removed; Debug's old write
  transport remains. See the [Bytes I/O log](docs/research/wasi-bytes-library-2026-09-07.md).
  Integer Debug formatting now uses Dew functions and a bounded foreign-write
  loop. The eight old formatters are removed from both compiler backends. See the
  [integer Debug log](docs/research/debug-integers-library-2026-09-07.md).
  F32/F64 bit formatting now runs in Dew too, with exact NaN/signed-zero tests
  and one-to-one reinterpret intrinsics. Text formatting still remains.
  See the [float Debug log](docs/research/debug-floats-library-2026-09-07.md).
  V128 formatting also runs in Dew, with two one-to-one lane reads and shared
  exact-output tests for lane order. See the
  [V128 Debug log](docs/research/debug-vectors-library-2026-09-07.md).
  Swar32/Swar64 output now uses Dew ASCII delimiters and unsigned formatting,
  with checked foreign writes for every part. See the
  [packed Debug log](docs/research/debug-swar-library-2026-09-07.md).
  Unit output also uses direct Dew ASCII stores and the checked foreign loop;
  argument effects still run once. See the
  [Unit log](docs/research/debug-unit-library-2026-09-07.md).
  Bool formatting also uses Dew ASCII stores and checked foreign writes. No
  primitive Debug implementation calls the old write builtin now, but the
  old write builtin is also removed with the transport cleanup below. See the
  [Bool log](docs/research/debug-bool-library-2026-09-07.md).
  Test assertion output now uses an ordinary module-local Dew function and the
  checked WASI Bytes loop. The hidden body, dependency roots, and emitter target
  override are removed. See the
  [test assertion log](docs/research/test-assertion-library-2026-09-08.md).
  Production assertions now use ordinary Dew control flow too. The old native
  and generated self-host expansions and wasm_assert alias are removed. Shared
  tests preserve argument order, trap behavior, and zero host calls. See the
  [production assertion log](docs/research/production-assertion-library-2026-09-08.md).
  The old Bytes write runtime, unused provider assertion copy, and private
  Debug write declaration are now removed. Debug text still needs its own
  foreign-write dependency. See the
  [transport cleanup log](docs/research/wasi-write-runtime-removal-2026-09-08.md).
  Derived Debug labels now expand to ordinary stores and checked Dew writes.
  Nine shared checks cover every enum form and nested generic values. See the
  [derive output log](docs/research/derived-debug-literal-output-2026-09-08.md).
  Benchmark byte staging now has ordinary Dew bodies too. Both legacy runtime
  names and the native/provider copy builders are removed; 54 shared checks
  cover bounds, exact bytes, scratch isolation, and owned read results. See the
  [staging log](docs/research/bytes-staging-library-2026-09-08.md).
  String Debug escaping and quoted output now run in Dew, using checked output
  windows and foreign writes. The native/provider String runtime entries are
  removed. Bytes Debug and text storage remain separate work. See the
  [text Debug log](docs/research/debug-text-library-2026-09-07.md).
  Bytes Debug also runs in Dew now. The native/provider private formatters and
  scratch-write builders are deleted, and the provider's write-index argument
  is gone. Native hidden Debug dependency roots are removed. The self-host's
  forced-WASI-import rule still needs a separate check. See the
  [Bytes Debug log](docs/research/debug-bytes-library-2026-09-08.md).
  The self-host's hidden sixteen-import WASI prefix, name-based host-call
  dispatch, forced import retention, and index offsets are removed too. Ordinary
  foreign declarations supply host calls. Function-handle sentinels are checked
  before conversion. See the
  [intrinsic-name log](docs/research/intrinsic-wasi-name-dispatch-2026-09-08.md).
- [ ] Remove all remaining standard-module path, declaration-number, and name
  dispatch. Use declaration IDs and explicit representation metadata, including
  Option variants and collection types. Names such as None, into, or RoadMap
  must not change compiler rules.
  Nominal enum payload selection no longer has spelling exclusions for text
  or collection names. User-defined Map and Array payloads have shared
  execution coverage. Separate container-element heuristics remain. See the
  [nominal payload log](docs/research/nominal-payload-name-cleanup-2026-09-09.md).
  Option now uses ordinary declared enum storage in the self-host compiler.
  Its adapter tags, Some/None physical spelling recovery, and eight unused
  runtime types are removed. Source-fragment variant operands use frozen
  carriers, including raw array reads.
  See the [Option layout log](docs/research/option-declared-layout-2026-09-09.md).
  Result now uses its declared enum storage too. Its thirteen runtime types,
  hidden error-identity operand, and the variant adapter registry are removed.
  Selected declaration and payload position replace Ok/Err spelling recovery.
  Collection representation and the remaining name recovery still need work.
  See the [Result layout log](docs/research/result-declared-layout-2026-09-09.md).
  Removed three obsolete global variant-name searches and their dead fallback
  tails. Missing-pattern diagnostics no longer guess a physical type by name.
  See the
  [variant lookup log](docs/research/variant-lookup-cleanup-2026-09-08.md).
  The former runtime-only payload seeding is removed. Exact call
  payloads follow the declared result's substituted type arguments, not a
  fixed generic slot or a get suffix. Shared receiver recovery still remains.
  See the [payload identity log](docs/research/pattern-payload-identity-2026-09-08.md).
  The last body-payload Some/Ok/Err suffix-recovery tail is now removed too.
  Valid user variants keep their declared storage; missing fields remain
  unresolved. See the
  [payload spelling log](docs/research/pattern-payload-spelling-2026-09-08.md).
  Exact call-result lookup and signature emission now use selected fragments,
  with no getter/into suffix exemption in final result verification. Two
  direct-get recovery helpers and their unproved I32 default are removed.
  Other unresolved receiver/collection recovery remains. See the
  [method-result log](docs/research/method-result-spelling-2026-09-08.md).
  Interface publication now follows source `pub` visibility in both compilers.
  Existing library exports are explicit; a `dew.std.` path cannot expose
  private declarations. Compiler-owned root/optimizer filtering and implicit
  standard dependency selection still remain. See the
  [visibility log](docs/research/module-source-visibility-2026-09-08.md).
  Native reference instructions now bind to builtin opcode metadata, including
  imported declarations and selected instances. The generated declaration-
  ordinal operation switch is removed; reordered declarations retain their
  meaning. Nominal/trait identity tables still remain. See the
  [reference metadata log](docs/research/reference-intrinsic-metadata-2026-09-08.md).
- [ ] Delete unused legacy builtin plans/builders after each migration. Enforce
  the opcode-or-unsafe-cast rule across every module, registry, and generator.
  Keep conversion behavior in `Into` impls where it is a type conversion.
  Include the pinned Starshine `src/ffi_bridge` runtime copies in each removal;
  text/builder algorithm copies are now removed. The retired runtime function
  kind/provider protocol remains. Unknown builtin names now remain intrinsic
  requests and produce exact emission errors instead of host imports. Explicit
  foreign host calls retain real exported memory even without guest memory
  instructions. See the [builtin boundary log](docs/research/unknown-builtin-imports-2026-09-09.md).
  Self-host text-name dispatch and its three FFI runtime-builder calls are now
  removed. Six obsolete private helpers are deleted, and the consumer selects
  473 APIs. Hardening, generated checks, and clean bootstrap pass; see the
  [self-host retirement log](docs/research/self-host-text-runtime-retirement-2026-09-09.md).
  Removed 46 unused private linker/body helpers, including stale collection
  name recovery and consumed-expression recovery. This does not remove the
  remaining native/provider runtime protocol. Erased adapters now have an
  explicit function kind and unique-target checks. Native, integration,
  generated, and clean bootstrap checks pass.
  The old runtime kind, unused lookup maps, and provider rejection API still
  need removal. See the [adapter kind log](docs/research/erased-adapter-function-kind-2026-09-09.md) and the
  [unused linker log](docs/research/unused-link-recovery-2026-09-09.md).

### Finish the compiler correctness audit

- [ ] Complete physical-boundary checks. Reject missing, Generic, Error,
  conflicting, or consumed evidence before a reachable value reaches emission.
  Extend the existing specialization checks to every fragment/storage boundary.
  Callback signatures now validate complete inferred/resolved child graphs before
  reference erasure. Cycles, hidden errors, unresolved leaves, bad child spans,
  and invalid type encodings have numeric call context. Shared deep graphs remain
  valid; see the [callback graph log](docs/research/callback-type-graphs-2026-09-09.md).
  Self-host packed struct fields, enum payloads, and immutable captures now
  retain width and signedness, with shared native/self-host execution tests.
  Mutable capture cells preserve full local values. See the
  [packed field log](docs/research/packed-field-storage-2026-09-08.md).
  Nested packed pattern paths now use those same checked reads. The shared
  corpus also checks small-integer literal matches and non-matches. See the
  [nested packed log](docs/research/nested-packed-patterns-2026-09-09.md).
  Declared struct/variant field and payload graphs now reject Error, unresolved
  projections, invalid runtime type values, bad child spans, and structural
  cycles in both compilers. The retained-shape/Ref error fallbacks are removed
  at these boundaries. Other expression/signature fallbacks remain. See the
  [declared storage log](docs/research/declared-storage-types-2026-09-08.md).
  Named function parameters/results now require concrete shape evidence,
  including product leaves, before physical signature conversion. Elided bases
  and signature-only declarations retain logical metadata without a fabricated
  physical signature. See the
  [named signature log](docs/research/named-fragment-shapes-2026-09-08.md).
  Self-host mutable capture cells now reject invalid shapes before storage
  conversion, including after generic substitution. Unit remains erased. See
  the [capture-cell log](docs/research/capture-cell-shapes-2026-09-08.md).
  Native selected lambda parameters, results, and captures now reject invalid
  product leaves as well as top-level Generic/Error shapes, with complete
  numeric context. See the
  [native lambda log](docs/research/native-lambda-shapes-2026-09-08.md).
- [ ] Finish exact call-target checks. A second different target must report
  SPC-303, not silently keep the first. Remove remaining first-candidate and
  name-based exceptions. Verify the emitter uses the frozen target.
  Native imported function values now use their own parameter/result records,
  not an exported position in the full source callable table. Private helpers
  cannot change a public function's imported type. See the
  [import identity log](docs/research/imported-callable-identity-2026-09-09.md).
  Linked call-index reads now retain body identity, check parallel arrays,
  and require older same-body links before an exact hit can return. Insertions
  reject different targets and ignore identical duplicates. See the
  [call-index log](docs/research/linked-call-index-contracts-2026-09-09.md).
  Native replays now verify declarations, ABI keys, and hidden evidence operands;
  self-host source call records are checked before fragment planning. Both
  target disagreements have exact numeric-record tests. See the
  [call identity log](docs/research/specialized-call-identity-2026-09-07.md).
  Bound calls now use logical implementation witnesses without requiring an
  explicit type query. An unrelated generic implementation no longer hides a
  valid target. See the
  [bound-call log](docs/research/bound-call-logical-selection-2026-09-08.md).
  Removed the emitter's final same-name trait scan and its first-linked-function
  fallback. Missing targets retain the source diagnostic. See the
  [emitter trait log](docs/research/emitter-trait-fallback-2026-09-08.md).
  Generic function-value and lambda factories now retain their logical trait
  targets in native compilation too. The verifier reads the selected caller's
  evidence, not the generic template, and runtime capture records match the
  full caller identity. See the
  [bound function-value log](docs/research/bound-trait-function-values-2026-09-08.md).
  Callback-to-direct-call rewrites now copy logical arguments between their
  distinct arenas and preserve exact trait roots. Closed runtime-export lambdas
  keep their owner's key; admission uses a cycle-safe worklist. See the
  [export admission log](docs/research/runtime-trait-export-admission-2026-09-08.md).
  Native direct calls with type arguments now require the exact call map;
  they cannot recover a target from physical shapes. Bounds, missing mappings,
  and target disagreement return full numeric emission records. Retained
  witnesses keep the selected declaration, instance key, and physical/table
  indices; a trait implementation is checked against its selected witness.
  A different physical-target replay cannot overwrite that witness. Physical
  shape lookup also rejects multiple source candidates. See the
  [exact generic target log](docs/research/exact-generic-call-targets-2026-09-08.md).
  The shared specialized-call getter now checks the retained witness as well;
  the link boundary verifies matching key sets and exact targets before return.
  See the [consumer log](docs/research/specialized-call-consumers-2026-09-08.md).
  Self-host physical target updates now reject a different second known target
  with SPC-303 and check body ownership, table length, and stored identity.
  Missing proposals cannot erase evidence. Receiver-based selection remains.
  See the [target update log](docs/research/physical-call-target-updates-2026-09-08.md).
  Body planning no longer refines a selected target from receiver carriers or
  repairs a missing target from receiver names or the last argument carrier.
  A removed exact method mapping yields BOD-607; same-carrier logical instances
  retain distinct results. Other phase selectors still need cleanup. See the
  [body recovery log](docs/research/body-target-recovery-removal-2026-09-08.md).
  Module-value reads now require one exact initializer and check source body,
  expression kind, and declaration identity. Missing globals cannot become
  function references through a declaration/name fallback. Other callable
  name searches remain. See the
  [global read log](docs/research/global-read-identity-2026-09-09.md).
  The emitter now requires consistent saved expression and call-recipe targets.
  Missing plans cannot fall back to linked plain functions. Main call emission
  no longer searches method/runtime names or implements `into` by spelling.
  Other shape selectors still need cleanup. See the
  [call read log](docs/research/frozen-call-target-reads-2026-09-09.md).
- [ ] Finish call operand recipes for all call kinds and hidden arguments.
  Callback signatures now require the target's function type; missing evidence
  cannot be rebuilt from operands. Scope spans and target membership have exact
  numeric checks, and lambda diagnostics retain the parent declaration. See the
  [callback signature log](docs/research/callback-signature-targets-2026-09-09.md).
  Missing defined, lambda, and initializer bodies can no longer remove callback
  signature scopes. All three paths retain exact BOD-610 records; see the
  [scope body log](docs/research/signature-scope-bodies-2026-09-09.md).
  Callback parameter spans now stay checked when empty, and signature result
  metadata comes from the target. Carrier disagreement, Generic/Error results,
  and type-ID encoding overflow retain numeric call context. The last callback
  result-name recovery helper is removed; see the
  [type boundary log](docs/research/callback-type-boundaries-2026-09-09.md).
  Operator calls now use saved left-receiver/right-argument recipes and the
  full call-argument verifier. Their type-argument span is no longer read as
  expression children. Direct calls with missing targets report BOD-607 rather
  than emitting nothing. See the
  [operator recipe log](docs/research/operator-call-recipes-2026-09-09.md).
  Self-host tuple arguments now remain one physical reference. Planning and
  emission no longer split them to fit a guessed parameter count. Missing
  evaluation body plans report a complete BOD-610 record. See the
  [tuple call log](docs/research/tuple-call-no-spread-2026-09-09.md).
  Raw builtin references now have explicit outlined physical targets in both
  compilers. The native failure required a returned function value; a local
  reference alone became a direct call and hid it. Scalar, SIMD, memory, and
  unsafe-cast wrappers have a shared execution corpus. Parameterized heap
  instruction wrappers still need exact layout recipes. See the
  [outlined intrinsic log](docs/research/outlined-intrinsics-2026-09-08.md).
  Check Unit receivers, non-generic Unit indexed writes, and Never arguments.
  Evaluate each source once in order; stop after a non-returning argument.
  Native direct-call trait operands now have an independent ordered copy in
  the saved target witness. Linking and emission check spans, counts, and
  exact operands; different replays cannot overwrite the recipe. See the
  [trait operand log](docs/research/frozen-trait-call-operands-2026-09-08.md).
  Emission now also checks each forwarded index against the actual caller's
  parameter span, including separate lambda frames. See the
  [frame-bound log](docs/research/trait-call-frame-bounds-2026-09-08.md).
  Public generic lambda factories still need runtime trait dictionaries in
  their escaping closure recipe. Concrete lambda instances and public generic
  function-value factories now work; the external runtime lambda case is
  retained in the [bound callback log](docs/research/bound-trait-function-values-2026-09-08.md).
  Optional erased exports now require a proved ABI, including all nested lambda
  expressions. This avoids a late emission failure but does not implement
  runtime dictionary capture; that part stays open.
  Index writes now always use their frozen call recipe; the shared fixture also
  checks non-generic Unit writes in exact source order. See the
  [index write log](docs/research/array-index-write-recipes-2026-09-07.md).
  Unit receivers now retain their evaluation identity without a stack operand.
  Never method arguments stop left-to-right physical propagation; qualified
  instance calls do not evaluate a type owner. See the
  [receiver log](docs/research/unit-receiver-call-recipes-2026-09-07.md).
- [ ] Complete full Wasm reference checks. Check heap type and nullability,
  not just an eqref label, for call operands, results, locals, and branches.
- [ ] Put constructor and other temporary locals in the frozen physical plan.
  Source-local declarations now require the frozen carrier and slot tables.
  Missing/conflicting types cannot become EqRef; FuncRef stays distinct.
  Non-returning initializers get no physical local. The old local recovery
  body and its 13 unused helpers are removed. Full reference and remaining
  adapter checks are still open. See the
  [local declaration log](docs/research/frozen-local-declarations-2026-09-09.md).
  Local slot and erasure reads also require the frozen plan, complete tables,
  requested identity, concrete stored carrier, and valid physical range.
  Missing plans cannot reconstruct slots from source shapes or counts. See the
  [local slot log](docs/research/frozen-local-slot-reads-2026-09-09.md).
  Generic tuple enum payloads now have explicit scalar boxing and checked
  extraction based on their exact declared payload slots. This also covers
  nested bindings/literals, Unit readers, and mixed payloads. See the
  [generic enum log](docs/research/generic-enum-payload-storage-2026-09-09.md).
  Tuple-variant constructors now retain frozen targets and complete operand
  recipes, including storage, boxing, Unit markers, and reference casts.
  Emission uses those records without selecting a target or carrier again.
  The old scheduler and poisoned zero-arity recovery are removed. See the
  [tuple recipe log](docs/research/frozen-variant-constructor-recipes-2026-09-09.md).
  Named struct patterns now select struct fragments using their saved
  declaration and constructor kind; they no longer search only enum variants.
  Missing or contradictory selections have no name/type fallback. See the
  [struct-pattern target log](docs/research/named-struct-pattern-targets-2026-09-09.md).
  Constructor field temporary types now come from frozen source-order records;
  emission checks presence, uniqueness, source agreement, and mirrored carriers.
  Global initializers now pass through body planning, verification, and freeze.
  Full reference checks and other remaining recovery paths still need work.
  See the
  [temporary plan log](docs/research/constructor-temporary-plans-2026-09-08.md).
  The old collection temporary allocations and slot counts based on
  `self_host_array_pop`, `next`, and `push` spelling are removed. An ordinary
  function rename now keeps identical code bytes. Other name-based recovery
  remains. See the
  [temporary name log](docs/research/temporary-local-name-removal-2026-09-08.md).
  Raw `array.new` length temporaries now retain frozen I32 evidence and the
  source logical type. Proved Never arguments stop the evaluation prefix and
  prevent allocation emission. Both compilers also preserve declared results
  when a forwarding body diverges. See the
  [raw temporary log](docs/research/raw-array-temporary-plans-2026-09-08.md).
  Temporary slot lookup and counts now use the frozen records, including each
  constructor field ordinal. Missing, duplicate, wrong-owner, and sentinel
  slots produce numeric failures. See the
  [slot log](docs/research/frozen-temporary-slots-2026-09-08.md).
  Expression temporary allocation now uses the frozen record order and
  physical carrier types. Unused Unit/Never slots have explicit I32 storage;
  Unit loop initializers and continues are evaluated without empty-stack
  stores. Full reference checks remain. See the
  [temporary type log](docs/research/frozen-temporary-types-2026-09-08.md).
  Owned capture cells now retain source identity, source/cell slots, selected
  heap type, stored type, and parameter role in the body freeze witness.
  Emission uses those records and typed nullable cell locals. See the
  [owned cell log](docs/research/owned-capture-cell-plans-2026-09-08.md).
  Lambda capture reads/writes and forwarding now retain exact source, closure
  field, cell pointee, storage, and erasure records. Packed reads use frozen
  widths and signedness. Runtime trait evidence captures and full reference
  checks remain. See the
  [capture access log](docs/research/frozen-capture-accesses-2026-09-08.md).
  Object constructor emission now uses a checked exact field-ID recipe, with
  separate source evaluation and physical load order. Missing or different IDs
  cannot be repaired by names or tentative carriers. See the
  [constructor identity log](docs/research/constructor-field-identity-2026-09-08.md).
  The body worklist also checks that complete exact field map before changing
  carrier evidence. Source names cannot repair a field ID during propagation.
  See the [propagation log](docs/research/constructor-propagation-identities-2026-09-08.md).
  Object construction now retains its exact target, physical field order,
  source identities, storage, boxing, and Unit markers in the frozen plan.
  Missing targets cannot use result-heap evidence. Emission no longer chooses
  an object target or reconstructs its field map; its old nominal/name fallback
  path is removed. Runtime trait capture, full reference checks, and
  runtime-adapter removal remain. See the
  [object recipe log](docs/research/frozen-object-constructor-recipes-2026-09-08.md).
  Ordinary closure construction now retains the entry, heap type, source
  identity, erasure, storage, cell type, and each local/forwarded capture operand.
  Emission uses those frozen records instead of searching source locals again.
  Both compilers pass 120 callback cases, including nested shared cells, Unit
  erasure, and signed/unsigned packed captures. Runtime trait-dictionary capture
  and full reference checks remain. See the
  [closure recipe log](docs/research/frozen-closure-construction-recipes-2026-09-08.md).
  No emitter step may invent a new carrier or overwrite conflicting evidence.
  Verify all worklist constraints at the fixed point and reject later mutation.
  Self-host body plans now retain exact freeze witnesses and check all tables
  before and after emission. The late Array method-target repair is removed.
  Full temporary coverage remains. See the
  [freeze log](docs/research/physical-body-freeze-2026-09-08.md).
  The work queue now audits every transfer before completion, retains required
  self-dependencies, and checks graph/queue contracts with numeric records.
  See the [work-queue audit](docs/research/carrier-work-queue-audit-2026-09-08.md).
  The freeze work also exposed generic Array iteration gaps. Unit payload
  bindings now check the specialized logical type and exact declared or adapter
  storage; 30 shared Array cases cover the copy loop. See the
  [Unit iteration log](docs/research/generic-array-unit-iteration-2026-09-08.md).
  The original generic copying helper's missing-Self failure is now fixed:
  late query-demand changes had invalidated earlier specialization requests.
  Demand now stays fixed after its source-graph closure. Both small source
  cases and the isolated full compiler-source helper compile successfully.
  Production still uses ordinary library copies. See the
  [query-demand log](docs/research/frozen-query-demand-2026-09-08.md).
- [x] Finish constructor non-returning-value tests. A Never field or payload
  must prevent later effects and construction, including generic tuple payloads.
  Nine shared execution checks pass in both compilers. Construction stops at
  the non-returning prefix before storage selection; declared Unit fields have
  a separate marker certificate. See the
  [constructor log](docs/research/constructor-never-prefixes-2026-09-07.md).
  Unit payload bindings also keep their logical empty value separate from a
  certified null storage marker. Planning and emission agree that no local
  operand exists. See the
  [Unit pattern log](docs/research/pattern-unit-storage-2026-09-08.md).
- [ ] Complete the emission shadow stack. Track operand types and control
  frames through each instruction, including unreachable code and adapters.
  Exact expression and logical-operand reads now use the checked frozen plan.
  Their source/name recovery, eight-step unwrap scan, and six unused helpers
  are removed. Thirteen negative probes retain complete failure context; see the
  [expression read log](docs/research/emitted-expression-reads-2026-09-09.md).
  Physical shape reads now share that checked carrier reader. Match result
  selection cannot replace frozen evidence with inferred or binding guesses;
  the result override chain and four unused helpers are removed. Payload hints
  and other container/branch recovery remain open. See the
  [shape read log](docs/research/frozen-expression-shapes-2026-09-09.md).
  Non-returning `if` conditions, `match` subjects, and `while` initial values
  now stop control emission and do not force unused branches to Never.
  Shared runtime and planner checks cover all three forms; see the
  [control-input log](docs/research/never-control-inputs-2026-09-09.md).
  Discard decisions now read checked frozen carriers, not source shapes or
  callable names. Missing/conflicting evidence is an error; an absent optional
  transfer payload schedules no expression. This is not the full instruction
  stack checker. See the
  [discard log](docs/research/frozen-discard-values-2026-09-09.md).
  Early-exit evaluation sequences now stop at the first non-fall-through
  child and retain all child flow effects. Both planning and emission check
  the same rule with exact numeric context; anonymous sequence assertions
  are removed. See the
  [sequence flow log](docs/research/evaluation-sequence-flow-2026-09-09.md).
  Native Unit branches now discard their actual emitted tail values, including
  blocks selected by compile-time queries. Self-host transfer rules keep the
  Unit parent's evidence separate from child call results. Twenty-four shared
  execution checks preserve side effects. See the
  [branch result log](docs/research/unit-branch-results-2026-09-08.md).
- [ ] Complete solver transaction and arena checks. Require LIFO snapshots,
  parallel undo arrays, valid undo entries, bounded parent walks, and exact
  rollback contents. Check span ownership before relative-index subtraction.
  Physical body entry now checks all five owned spans, and body-relative
  expression lookup reports ARN-102 before subtraction. Boundary and exact
  failure-record tests pass; other phase consumers remain to be audited. See
  [checked index notes](docs/research/checked-body-indices-2026-09-07.md).
  Solver work stacks and undo values now have numeric checks. Native snapshots
  have unique tokens, including across reset. Nested rollback tests check saved
  contents. See [solver notes](docs/research/solver-work-stack-contracts-2026-09-07.md).
  Native parent walks now check their arenas and bounds. Both compilers also
  reject type-binding cycles even when the parent forest is valid. Native
  binding IDs and stored variable identities are checked before use. See the
  [root walk log](docs/research/solver-root-walks-2026-09-07.md).
  Native rollback now validates the complete undo range before the first write,
  including saved values and encoded resolved bindings. Commit cannot discard
  an invalid undo record. See the
  [undo log](docs/research/solver-undo-records-2026-09-07.md).
  Native union sizes and resolved-type encoding now check machine and arena
  limits before writes or arithmetic. See the
  [value limit log](docs/research/solver-value-limits-2026-09-07.md).
  Both solvers now finish owned work on normal return and check idle, parallel
  state before reset, snapshot, or zonk. Self-host commit and rollback preflight
  every undo record before writes or removal. See the
  [lifecycle log](docs/research/solver-lifecycle-2026-09-07.md).
  Unification, occurs/unresolved searches, and zonk now check complete input type
  graphs. Missing solver IDs cannot become Error, and Error siblings cannot
  hide structural cycles or bad spans. See the
  [type graph log](docs/research/solver-type-graphs-2026-09-07.md).
  Name resolution, inference, and flow now check all ten HIR body spans before
  allocation and check membership before relative lookup. Exact owner/phase
  records cover cross-body and machine-boundary mutations. See the
  [front-end arena log](docs/research/body-arena-contracts-2026-09-07.md).
  The self-host physical verifier now checks complete local/expression/control
  tables and ordered expression identity before reads. Erased locals cannot
  disappear from logical tables. Eleven mutations have exact numeric records.
  See the [table log](docs/research/physical-body-table-completeness-2026-09-07.md).
  Native local planning now checks all five lowered body spans, root membership,
  and stored local body/relative IDs before allocation. Named and lambda bodies
  have positive checks; invalid spans and identities retain numeric context.
  See the [native boundary log](docs/research/native-planned-body-arenas-2026-09-07.md).
  Native lowered expression operands and block/pattern/field/arm lists now have
  checked spans and body ownership. New IR expression variants must extend the
  explicit edge checker. Only the exact missing sentinel erases optional edges.
  See the [child ownership log](docs/research/planned-body-child-ownership-2026-09-07.md).
  The self-host planner now checks those source child lists before work-graph
  construction and again at final verification. Nine source mutations retain
  exact phase-6 records. See the
  [self-host child log](docs/research/self-host-lowered-child-ownership-2026-09-07.md).
  Both lowered-body boundaries now reject syntax cycles with ARN-108. An
  explicit work stack checks expression, block, pattern, and arm edges without
  a depth cap; shared nodes and normal loop control remain valid. See the
  [cycle log](docs/research/lowered-body-cycles-2026-09-08.md).
  Fragment payload reads now use a checked payload-relative index in both
  compilers. Type/shape arrays stay parallel, the span is checked before
  addition, and a field ordinal cannot read the next payload. Numeric failures
  retain the owning variant. See the
  [payload span log](docs/research/fragment-payload-spans-2026-09-08.md).
  Both physical boundaries now check each stored local's relative ID, body ID,
  and exact lambda owner. Lambda emission passes its selected owner explicitly.
  See the [local identity log](docs/research/physical-local-identity-2026-09-07.md).
  Physical capture reads/writes now require an owned slot. Lambda/capture IDs,
  root bodies, and capture spans are checked; native closure/direct-call recipes
  must retain the selected capture span. See the
  [capture log](docs/research/physical-capture-ownership-2026-09-07.md).
  Capture sources now retain their exact body/lambda and local identity,
  including Unit captures. Closure construction checks direct or forwarded
  availability in the enclosing environment; native direct emission also
  preserves the source body guard. See the
  [source log](docs/research/capture-source-ownership-2026-09-07.md).
  Global capture/local metadata now has a preflight before fragment storage
  planning and public emission, including private generic instances. Checked
  source IDs and complete spans catch orphan entries before arena reads; the
  record retains phase 4 or 7 instead of borrowing a physical-body context.
  See the [metadata log](docs/research/fragment-capture-metadata-2026-09-08.md).
  Complete child-list, stored-identity, parallel-array, and later-consumer checks
  remain open.
- [ ] Complete SCC and linker checks. Every module must occur once, dependency
  order must hold, and stored identities, physical indices, and import offsets
  must agree. Missing bases or bodies must produce a diagnostic.
  Both compilers now check SCC coverage, uniqueness, owned spans, and dependency
  order at graph construction and linking. Seven self-host negative cases check
  complete LNK-501 records. See the
  [graph log](docs/research/module-graph-invariants-2026-09-07.md).
  Self-host links now verify type bases, function/type records, signature spans,
  source body identity, and import order. Native emitted indices form a checked
  total, unique set, including startup functions. Import-offset cleanup and
  complete native type/fragment checks remain. See the
  [link record log](docs/research/physical-link-records-2026-09-07.md).
  Global initializer links now retain test-inclusion mode and are checked
  against the full source schedule before module/body access. Counts, slots,
  source identities, shapes, and body owners must agree. Initializer function
  handles use checked wide arithmetic. Complete startup/adaptor recipes and
  link freeze remain. See the
  [initializer log](docs/research/initializer-link-records-2026-09-08.md).
  Unit/Never globals now have no physical slot in the self-host compiler.
  Their initializer functions still run; Unit reads produce no operand, and
  scalar slots stay aligned. Both compilers share effect/order tests. See the
  [Unit global log](docs/research/unit-global-storage-2026-09-08.md).
  Native initializer candidates now require a present, owned module-let body
  and a concrete root shape. Missing bodies cannot silently remove a global.
  Full native initializer/global table checks remain. See the
  [native initializer log](docs/research/native-initializer-source-checks-2026-09-08.md).
  Native startup dependency walks now use one checked work record per body,
  require exact callable/global lookups, and reject missing called bodies.
  Recursive calls and repeated reads retain one dependency edge. Indirect-call
  effect analysis and full link freeze remain. See the
  [startup walk log](docs/research/native-startup-dependency-checks-2026-09-08.md).
  Startup dependency analysis now uses the exact selected query body and keeps
  distinct logical instances separate. Missing query instances cannot become
  template scans; removed branches cannot cause false initialization cycles.
  See the [selected startup log](docs/research/selected-startup-query-bodies-2026-09-08.md).
  Self-host startup now follows selected function bodies across module cycles;
  a source probe exposed a valid Wasm program returning 2 instead of 42. The
  new schedule verifies each dependency edge and assigns global slots afterward.
  Direct query-folded module-value cycles, dynamic-call effects, and full link
  freeze remain. See the
  [self-host startup log](docs/research/selfhost-startup-dependency-order-2026-09-08.md).
  Direct global queries now fold in both compilers. Startup uses a new selected
  dependency graph without changing source inference records; removed branches
  no longer produce false cycles. Real selected cycles still fail. See the
  [global-query log](docs/research/direct-global-query-initialization-2026-09-08.md).
  The source startup builder now checks complete, unique SCC membership and
  dependency order before reading value/body tables. Missing lookups no longer
  select value zero or body zero. Native and self-host negative tests compare
  the full error record. See the
  [startup input log](docs/research/module-startup-input-contracts-2026-09-08.md).
  Native plain-function lookup now checks table bounds and declaration,
  module, fragment, lambda, kind, and ABI-key identity at link completion and each
  read. Missing keys stay missing; specialization entries cannot replace plain
  entries. Imported trait signature fragments retain their source declaration.
  See the [lookup log](docs/research/named-function-lookups-2026-09-08.md).
  Linked source functions now preserve all four signature/evidence spans,
  direct-builtin and elision metadata, and checked signature relocation.
  Linking and emission require one linked record per source function fragment,
  including specializations and lambdas. Complete physical type tables and
  synthetic adapter recipes remain separate checks. See the
  [signature-copy log](docs/research/linked-function-signature-copies-2026-09-08.md).
  Native physical type tables now check field spans/order, recursive-group
  coverage, source owners, relocations, nominal lookup entries, canonical
  signatures, and the exact emitted type-prefix order. Emission returns full
  numeric records before writing sections. Canonical trait layout proofs and
  late adapter/text-runtime recipes remain open. See the
  [type-table log](docs/research/physical-type-tables-2026-09-08.md).
  Native field references now check heap/signature bounds and recursive-group
  ownership. Canonical closure/trait fields and function signatures compare
  full relocated types, including heap identity and nullability. Late adapter
  and text recipes and complete plan freeze still remain. See the
  [alias log](docs/research/physical-type-aliases-2026-09-08.md).
  Native source-function lookup now checks bounds, stored identity, plain
  instance kind, and table coverage. Imported plain fragments must be unique.
  The self-host builtin lookup also removes its malformed-plan recovery scan.
  See the [source lookup log](docs/research/source-function-lookups-2026-09-08.md).
  Native function-type preflight now checks all source signature spans,
  references, stored logical IDs, reverse lookup entries, and callback maps
  before interning. Structural signature cycles report ARN-108; shared children
  and nominal recursion remain valid. See the
  [signature preflight log](docs/research/function-type-preflight-2026-09-08.md).
- [x] Separate trait cycles and search limits from ordinary missing evidence.
  Use visited obligations and explicit limit errors, including implementation
  comparison and module-interface traversal.
  Native trait signatures now compare substituted tuple fields; an Error field
  cannot hide a later mismatch. Both compiler regressions are in the
  [tuple signature log](docs/research/trait-tuple-signatures-2026-09-07.md).
  The self-host standalone evidence API now shares the checked logical search
  used by inference and type queries. Trees retain logical arguments and exact
  direct-child spans. See the
  [shared search log](docs/research/shared-trait-evidence-2026-09-07.md).
  Both interface visibility walkers now check cycles and owned spans and handle
  deep/shared type graphs. Private or Error siblings cannot hide a cycle.
  Both implementation signature comparators now check complete graphs and
  substitution edges before equality or Error recovery. There is no fixed
  depth cutoff; cycles retain numeric type context. Equal type IDs still check
  children under different generic contexts. See the
  [implementation walk log](docs/research/implementation-type-walks-2026-09-07.md).
  Native inference now uses rollback-stable logical obligation keys, explicit
  cycle/limit diagnostics, and restored caller generic environments. Deep chains,
  sibling bounds, and diagnostic codecs have focused tests. See the
  [native search log](docs/research/native-trait-search-2026-09-07.md).
  Native physical evidence keys now use one checked writer. Deep leaves and
  product fields remain distinct; missing/cyclic data and work limits cannot
  produce a partial key. See the
  [evidence key log](docs/research/physical-evidence-keys-2026-09-07.md).
  Native evidence-concreteness, forwarding, runtime classification, and
  dependency collection now use checked worklists. Pending evidence cannot
  hide Error shapes, bad IDs, or cycles. Resource limits retain exact records.
  See the [predicate log](docs/research/physical-evidence-predicates-2026-09-07.md).
  See the [interface walk log](docs/research/interface-type-walks-2026-09-07.md).
- [ ] Complete stable numeric failure records and the negative invariant tests.
  Start with a valid state, change one field, and check the exact code and source
  context. Missing data or an unexpected trap must never count as a pass.
  Request-index lookup now checks parallel arrays, visited declaration IDs,
  concrete shape spans, and strictly older next links before duplicate hits.
  Seven one-mutation tests retain all nine failure fields; a sixteen-record
  chain has a positive replay check. Other specialization helpers remain.
  See the [request index log](docs/research/specialization-request-index-2026-09-09.md).
  Physical body errors now use 41 typed reasons with exhaustive code and text
  mappings. Field, constructor, local, flow, and raw-instruction errors no longer
  become code zero. See the
  [typed reason log](docs/research/physical-diagnostic-reasons-2026-09-08.md).
- [ ] Add stable phase snapshots to both compilers. Compare by semantic identity
  and stop at the first difference, from collection through emission. Keep
  bootstrap byte comparison as an additional check, not a substitute.
- [x] Finish nested anonymous tuple patterns, such as `Some((left, right))`,
  in both parsers and downstream pattern handling. Imported/unqualified payload
  tests retain exact types and constructor identity. Short unit constructors
  survive lowering; nested patterns use selected declarations, not spelling.
  Both compilers pass 17 shared execution cases, including Unit, rest, generic
  payloads, and guard order. Clean B/C bytes match. See the
  [product pattern log](docs/research/product-patterns-2026-09-07.md).
  The native importer now rebuilds product field spans in the receiving arena.
  Nested imports and structural identity have focused tests; see the
  [imported product log](docs/research/imported-product-spans-2026-09-07.md).
- [x] Keep readable, typed Starshine FFI names through regeneration. Audit any
  remaining numbered references; test identity and signature agreement rather
  than merely renaming incompatible reference types.
  Regeneration verifies all 476 selected signatures and keeps named carriers;
  three unused Array algorithm exports have now been removed.
  Constructor aliases preserve nullability. Invalid identity proofs and numbered
  Dew references fail with diagnostics. The real linked FFI smoke runs in the
  hardening lane. See [FFI notes](docs/research/ffi-carrier-identity-2026-09-07.md).

### Final checks for this work

The September 7 link-record batch passes all eight lanes: 955 native tests,
268 integration tests, 326 library tests and shared execution corpora, 278
self-host tests with 61 exact failure records, generated checks, 15 stress tests,
and 10,982 pinned Starshine tests. Clean B/C core and linked bytes match.
See [measured results](docs/research/physical-link-records-2026-09-07.md).
These are batch results; the remaining implementation tasks are still open.

The September 9 linked-call-index batch passes 1,275 native tests, 270
integration tests, 812 self-host tests with 411 exact failure records, all
shared library checks, generated checks, 15 stress tests, and 10,994 pinned
Starshine tests. Clean B/C raw and linked bytes match. This includes the
import-signature fix and builder length/default migrations. See the
[measured results](docs/research/linked-call-index-contracts-2026-09-09.md).

The text-conversion batch passes 1,282 native tests, 270 integration tests,
821 self-host tests with 414 exact failure records, all shared library cases,
generated checks, and 15 stress tests. The targeted provider suite passes all
21 tests. Clean B/C raw and linked bytes match; see the
[conversion results](docs/research/bytes-string-cast-library-2026-09-09.md).
These results do not close the remaining compiler and storage tasks.
These are current batch checks, not completion of the remaining tasks above.

- [ ] Run `tools/test-native.sh`, `tools/test-integration-native.sh`,
  `tools/dew-test/run.sh`, `tools/test-self-host-hardening.sh`, and
  `tools/check-generated.sh` after the remaining implementation batches.
- [x] Run `tools/test-stress-native.sh` and `tools/test-starshine-native.sh`.
  After the Set migration, all 15 stress tests and 10,982 pinned Starshine tests
  pass. Run them again after the remaining compiler changes.
- [ ] Run `tools/check-self-host-bootstrap.sh --clean --fast` after compiler
  changes. Require successful A/B/C builds and identical B/C output; the lane
  already exists and has passed, so extend it rather than creating it again.
- [ ] Measure every compiler run and record runs above 30 seconds as performance
  bugs. Cold native generation, aggregate test lanes, and bootstrap execution
  still exceed the limit. Address speed after the correctness work above.

## P1 — self-hosting

1. Finish the compiler port, including remaining optimization parity, cache codecs,
   and the compiler driver. The Dew parser, semantic pipeline, physical planning,
   and Starshine emission already pass a clean A/B/C fixed-point bootstrap.
   The current correctness and library tasks above remain active.

Use [`docs/research/self-hosting-compiler-gap-catalog-2026-08-16.md`](docs/research/self-hosting-compiler-gap-catalog-2026-08-16.md) for the audited host, Wasm, collection, and port-surface gaps. Port-enabling options in that catalog remain decisions, not active backlog items, until explicitly selected.

Indexed implementation uniqueness, mutable struct fields, and complete `@alias` namespace lookup are finished and therefore omitted from this execution-only backlog.

## P2 — deferred until self-hosting

Every unchecked item below is P2 unless the P1 compiler port proves it is a concrete blocker. Package acquisition, work budgets, optional arguments, annotations, ordinary Boolean `while`, higher-kinded types, negative implementations, TOML, formatter/documentation/LSP work, release infrastructure, and parallel compilation remain deferred.

## Incremental compilation

- [ ] Add hundreds-of-files and representative external-package stress workloads.

Parallel module/body jobs, completion-order tests, and parallel-output checks are intentionally absent from this execution backlog. MoonBit cannot run these compiler jobs in parallel. They become active work only after Dewdrop is self-hosted and Dew supports parallel computation; see [`docs/decisions/0002-parallel-compilation-after-self-hosting.md`](docs/decisions/0002-parallel-compilation-after-self-hosting.md).

## Post-release performance work

These are older, deferred performance tasks. They do not override the current
self-host timing bugs or the correctness work listed above.

- [ ] Define compiler budgets for graph size, nesting/width, alias expansion, inference, trait search, pattern usefulness, specialization growth, and diagnostic volume.
- [ ] Diagnose budget exhaustion deterministically without panic or partial cache publication.
- [ ] Add opt-in runtime allocation and phase counters with zero production overhead.
- [ ] Track compile, validation/encoding, runtime time, compiler allocations, and peak memory with warmup and variance.
- [ ] Extend aligned-pack phase-cache admission measurements beyond the implemented 100-module startup benchmark to larger external-package and heavy-inference workloads before changing the default body-cache policy.
- [ ] Establish reviewed cross-engine regression thresholds for hot workloads; Array growth now has reproducible scalar-loop versus WasmGC `array.copy` measurements.
- [ ] Benchmark Array growth, large reference copying, write barriers, and GC behavior on each supported WasmGC runtime.
- [ ] Measure full-array pop allocation and Unit marker storage. The Dew clear
  path uses one temporary default slot only when storage is full. Remove that
  cost only with a checked storage design that also works for literal producers.
- [ ] Add representative heap, ordered-tree, queue, JSON, and generated typed-decoder performance suites.
- [ ] Use runtime allocation evidence to evaluate proof-driven constructor/store forwarding, physical nominal propagation, and private `Result` forwarding.
- [ ] Benchmark thresholded exact-`Set` JSON duplicate tracking only for substantially wider objects.
- [ ] Benchmark reusable nested JSON structural indexes only for repeated selective lookups with explicit ownership and memory contracts.
- [ ] Audit integer conversions, packed identities, and malformed-input-driven indexing.

## Modules, imports, packages, and visibility

- [ ] Define duplicate identical imports, opens, and aliases across files with both source locations.
- [ ] Decide and define selective imports.
- [ ] Define re-exports and package visibility if needed.
- [ ] Define canonical standard operator-trait identities and diagnose conflicting local declarations.
- [ ] Decide import and canonical-preamble shadowing rules.
- [ ] Decide whether source syntax is needed for default-preamble opt-out.
- [ ] Add registry lookup, Git checkout, deterministic lockfile generation/update, and a content-addressed installed-package store.
- [ ] Package `dew.std` with the compiler or as a versioned dependency.
- [ ] Version the compiler and prelude ABI together initially.

## Type system and language surface

- [ ] Add negative/sealed implementations, higher-kinded types, or variance only when concrete requirements justify them.
- [ ] Design optional arguments and their ABI/evaluation-order rules.
- [ ] Add checked, saturating, wrapping, and explicit truncating conversions.
- [ ] Decide ordinary Boolean `while` and a second `loop` form.
- [ ] Add lazy module values or additional startup entry points only if required.

## Annotations, derivation, and cleanup

- [ ] Define `#annotation(...)` syntax and permitted constant values.
- [ ] Define annotation resolution, validation, retention, and interface serialization.
- [ ] Expose frozen annotations to compiler features and tooling without runtime reflection.
- [ ] Define the relationship between annotations and postfix `derive(...)`.
- [ ] Add alias-mediated disposal/escape diagnostics only if affine tracking is adopted.
- [ ] Continue cross-phase and cross-module coverage for `defer`, `using`, and `Disposable`.

## Patterns, text, and primitive policies

- [ ] Add full nested pattern-matrix usefulness analysis when needed.
- [ ] Preserve deterministic source-order pattern diagnostics.
- [ ] Measure retained-range and small-inline-string representations before changing the text ABI.
- [ ] Define public string indexing and malformed-WTF-8 host-boundary behavior.
- [ ] Define stable float, Bytes, SWAR, and typed-lane Show formats.
- [ ] Define typed-lane Debug and non-WASI Debug behavior.
- [ ] Expand generated lane tests to every operation family.
- [ ] Complete cross-runtime execution and benchmark coverage for primitive/runtime features.

## Standard library

- [ ] Design a one-pass generated typed JSON decoder and public cursor/event core; slice-reparse typed and raw-index prototypes were measured and rejected, and minimal recursive generic visitors now link, so isolate the remaining JSON-specific callback/capture case before changing the compiler.
- [ ] Specify and benchmark workloads before adding finger trees or persistent lists.
- [ ] Implement bounded Dew-native TOML; add YAML only after JSON and TOML stabilize.
- [ ] Define cryptography boundaries and reviewed algorithms before implementation.
- [ ] Implement bounded HTTP semantics separately from host transport adapters.

## WasmGC backend and interoperability

- [ ] Add Start, element/table, or data/string sections only when selected runtime designs require them.
- [ ] Add deterministic Name and source-information sections.
- [ ] Deduplicate equivalent ABI signatures.
- [ ] Define and continuously test the supported WasmGC runtime baseline.
- [ ] Define checked raw-opcode registry extensions, Wasm imports/exports,
  JavaScript bindings, and string/reference interop. Registry entries must not
  add compiler-owned library algorithms.
- [ ] Define component-model/WIT integration only after the core Wasm ABI stabilizes.
- [ ] Provide explicit low-level escape hatches without ambient semantics.

## CLI, formatter, docs, and language server

- [ ] Add CLI phase timing and allocation reporting.
- [ ] Define canonical Dew formatting rules.
- [ ] Implement lossless/comment-preserving `dew fmt`.
- [ ] Add formatter idempotence and parse/format/parse tests.
- [ ] Retain documentation comments and implement `dew doc`.
- [ ] Link imported identities, preserve source spelling, and support runnable examples.
- [ ] Reuse incremental artifacts for language-server state.
- [ ] Add diagnostics, definition, references, hover, completion, rename, symbols, semantic tokens, and focused code actions.

## Testing, fuzzing, packaging, and releases

- [ ] Continue feature-adjacent success, warning, failure, boundary, trap-order, and stress fixtures.
- [ ] Add tests for every new import/module rule and cross-file source locations.
- [ ] Add malformed standard-library source and broader cross-file semantic matrices.
- [ ] Add tokenizer, parser, HIR, solver, and Wasm round-trip fuzzing.
- [ ] Add differential parse/format and resource-limit fuzzing after prerequisites land.
- [ ] Add reproducible release builds and CI across supported targets/hosts.
- [ ] Publish compiler binaries and standard-library sources.
- [ ] Define language edition/version behavior before compatibility commitments.
