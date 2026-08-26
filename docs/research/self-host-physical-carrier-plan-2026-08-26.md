# Self-host physical body-carrier plan

Date: 2026-08-26

## Baseline

Repository state at task start:

- branch: `review/self-host-fixed-point-2026-08-26`;
- commit: `e451f75adfd2e238dbe003e38a3a5a21bc12239e`;
- existing user changes were present in `AGENTS.md`, `README.md`, `docs/research/rust-style-iteration-and-for-2026-08-20.md`, `starshine-mb`, `tools/dew`, `src/starshine_guest/pkg.generated.mbti`, and `tools/dew-registry.mjs`.

The checked-in Starshine consumer fingerprint was stale for the existing provider tree. `tools/generate_starshine_ffi_consumer.py` refreshed only generated Starshine consumer files.

Baseline commands:

- `tools/test-native.sh`: all reported tests passed. The semantic lane took 158.259 seconds and the backend lane took 97.035 seconds. Both exceed the 30-second project limit.
- `DEW_SELF_HOST_FULL_VALIDATION=1 tools/check-self-host-smoke.sh`: the initial run stopped on the stale generated fingerprint. After refresh, the command exceeded 600 seconds before it reached the smoke build report.
- `tools/check-self-host-bootstrap.sh`: compiler A built and validated. Compiler A build took 105.424 seconds. Request generation took 1.304 seconds. A-to-B execution took 111.414 seconds and stopped because Starshine rejected compiler B.

The latest preserved diagnostic compiler-B artifact is `.tmp/correctness-call-initializer/a/compiler-b.wasm`:

```text
error: func 1759 failed to validate

Caused by:
    0: type mismatch: expected eqref, found i32 (at offset 0x42839)
```

At the failing instruction, call 1761 produces `i32` and `local.set 6` expects `eqref`. The stable source declaration, body ID, specialization key, expression ID, and source offset will be recorded after the carrier-plan diagnostic lane maps this old physical failure to semantic identities. Physical function 1759 is not used as a fix key.

The earlier branch record also identifies the i64-to-i32 `Some` payload class at physical function 1622 and offset `0x35d7f`. That number is historical only. The regression must use the selected `VariantId`, specialization, payload subtype, and physical payload field.

## Current pipeline

The current native pipeline is:

1. parse source AST;
2. collect executable HIR;
3. resolve names and declaration types;
4. infer body-local logical types;
5. compute flow;
6. build backend-neutral lowering with `BodyTypeId`, nominal IDs, and `PlannedValueShape`;
7. specialize program calls;
8. build WasmGC fragments with physical fields and function signatures;
9. link final program type and function indexes;
10. allocate locals and recover carriers inside Starshine emission;
11. validate and encode.

The self-host compiler follows the same broad sequence, but `self_host/compiler/starshine_module.dew` performs a large amount of late recovery. It derives local and scratch types from initializers, uses, names, nearby expressions, generic shapes, and fallback whole-program scans.

## Missing contract

There is no one immutable plan that joins these facts for each materialized body:

- logical Dew type;
- specialization ABI key;
- exact linked Wasm parameter and result ABI;
- exact expression stack carrier;
- exact source-local carrier;
- exact pattern-binding carrier;
- exact control-state and control-result carrier;
- exact scratch-local carrier;
- selected physical field and variant payload field;
- explicit cast, storage conversion, box, or unbox operation.

This gap lets one producer be viewed as `i64` while a constructor expects `i32`, or lets an `i32` call result be stored in an `eqref` local. The emitter then tries to repair incomplete semantic facts. Each repair advances validation to a later failure without removing the cause.

## Planned phase

Add one physical body-carrier planning phase after specialization and physical program linking and before instruction emission.

The plan is keyed by the materialized physical function. Its key includes:

- linked function index;
- module index and module ID;
- body ID or lambda ID;
- declaration ID;
- specialization ABI key;
- initializer identity where applicable.

Runtime functions, imports, signature-only functions, and inline-only builtins do not receive source-body plans.

Each planned entity keeps separate data for:

1. logical Dew type and nominal identity;
2. exact Wasm value carrier;
3. exact Wasm storage type when storage is involved;
4. value cardinality: Unit, one value, Never, or an explicitly supported multi-value ABI;
5. explicit edge conversion.

Products retain the existing one-reference runtime ABI in all contexts.

## Invariants

- Every materialized source body has one carrier plan.
- A generic body is planned per physical specialization.
- Normal specialized bodies have no surviving generic carrier.
- Every source local and scratch local has one exact Wasm local type before emission.
- Local reuse is keyed by exact carrier.
- Packed i8 and i16 storage loads and stores use an explicit i32 value carrier.
- Numeric widths are never exchanged implicitly.
- Unit has no arbitrary value carrier.
- Never produces no stack value.
- Exact references can widen only through planned compatible edges.
- An erased reference cannot narrow to a nominal reference without a planned checked cast.
- Function references and `call_ref` use the selected physical signature.
- Field and variant lookup starts from semantic owner IDs and linked indexes, not names.
- Any box, unbox, cast, null check, or storage conversion is explicit plan data.
- The emitter does not infer a local type or choose a field, variant, or signature.

## Verifier

A pre-emission verifier walks all producer-to-consumer edges and collects all independent errors in deterministic source order. A diagnostic includes:

- module;
- source declaration;
- body or lambda;
- physical function index;
- specialization ABI key;
- expression ID;
- related local, field, pattern, or call ID;
- source offset;
- operation context;
- logical type and logical shape;
- selected nominal owner;
- expected carrier;
- actual carrier.

The verifier runs before Starshine instruction construction. A direct full-compiler lane will build the self-host plan and print all carrier errors in one run.

## Known failure classes

The initial matrix includes:

- scalar divergent values entering reference closure locals;
- flattened product signatures versus runtime product references;
- mixed product field order and projection;
- product match results and pattern bindings;
- functional-loop state and payload bindings;
- Option and Result physical payload selection;
- i64 payload values entering i32 `Some` subtypes;
- nested field and index provenance;
- array iterator Option results;
- Map key/value recovery and `Map::get` Option payloads;
- same-named receiver fields;
- same-named `new` constructors;
- exact closure and `call_ref` signatures;
- packed i8/i16 field loads and stores;
- exact-carrier scratch-local reuse;
- module global and initializer carriers.

## Return and enum inference work

`return` will become one AST, HIR, lowering, and emission expression with logical type `Never`. The old independent block-item return semantics will be removed.

Unqualified enum selection will use propagated expected types, scrutinee owners in patterns, visible-candidate filtering, payload constraints, and delayed choice when the expected type remains an inference variable. Qualified variants remain legal only for explicit disambiguation.

A semantic style gate will report redundant qualified enum variants under `self_host/compiler/**/*.dew` with path, offset, owner, and variant.

## Final results

Pending implementation and final gates.
