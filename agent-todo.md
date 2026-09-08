# Dew Agent TODO

> Current handoff updated September 8, 2026. The older deferred backlog below
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

Implementation is complete in both compilers. The shared corpus now has 96
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
- [ ] Move Text, Bytes, views, and builders out of compiler-owned algorithms.
  Keep encoding, bounds, and lifetime checks in ordinary library code.
  Bytes equality, hash, searches, affixes, UTF-8 validation, and checked String
  conversion now run in Dew. Bytes storage operations and the SIMD storage
  bridge still need migration. See the
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
  load. The separate native/provider String SIMD entry is removed; the Bytes
  storage bridge remains. See the
  [SIMD access log](docs/research/string-simd-library-access-2026-09-08.md).
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
  Removed three obsolete global variant-name searches and their dead fallback
  tails. Runtime variant selectors retain typed declaration adapter metadata;
  missing-pattern diagnostics no longer guess a physical type by name. Runtime
  adapter layouts still remain. See the
  [variant lookup log](docs/research/variant-lookup-cleanup-2026-09-08.md).
  Active runtime payload seeding now uses selected adapter IDs. Exact call
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
  text storage and SIMD storage bridges still remain.

### Finish the compiler correctness audit

- [ ] Complete physical-boundary checks. Reject missing, Generic, Error,
  conflicting, or consumed evidence before a reachable value reaches emission.
  Extend the existing specialization checks to every fragment/storage boundary.
  Self-host packed struct fields, enum payloads, and immutable captures now
  retain width and signedness, with shared native/self-host execution tests.
  Mutable capture cells preserve full local values. See the
  [packed field log](docs/research/packed-field-storage-2026-09-08.md).
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
- [ ] Finish call operand recipes for all call kinds and hidden arguments.
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
  Constructor field temporary types now come from frozen source-order records;
  emission checks presence, uniqueness, source agreement, and mirrored carriers.
  Global initializers now pass through body planning, verification, and freeze.
  Forwarded capture types and full reference checks remain. See the
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
  stores. Forwarded capture and full reference checks remain. See the
  [temporary type log](docs/research/frozen-temporary-types-2026-09-08.md).
  Owned capture cells now retain source identity, source/cell slots, selected
  heap type, stored type, and parameter role in the body freeze witness.
  Emission uses those records and typed nullable cell locals. Forwarded mutable
  captures still need frozen pointee types. See the
  [owned cell log](docs/research/owned-capture-cell-plans-2026-09-08.md).
  Object constructor emission now uses a checked exact field-ID recipe, with
  separate source evaluation and physical load order. Missing or different IDs
  cannot be repaired by names or tentative carriers. Recipe freeze and nominal
  constructor recovery still remain. See the
  [constructor identity log](docs/research/constructor-field-identity-2026-09-08.md).
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
  Native Unit branches now discard their actual emitted tail values, including
  blocks selected by compile-time queries. Self-host transfer rules keep the
  Unit parent's evidence separate from child call results. Twenty shared
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
  Regeneration verifies all 474 selected signatures and keeps named carriers;
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
