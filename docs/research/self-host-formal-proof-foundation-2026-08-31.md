# Self-host formal proof foundation

Date: 2026-08-31

## Toolchain

The host uses mise to manage MoonBit. The global mise entry is `http:moonbit`.

The toolchain was updated from compiler `0.10.4` to compiler `0.10.11` on 2026-08-31:

- `moon 0.1.20260827`, built on 2026-08-27
- `moonc 0.10.11`, built on 2026-08-28

The current MoonBit archive ships the proof frontend and a bundled Why3 runtime. The standard `core` source archive is separate. The mise installation now contains the matching latest `core` archive and its native and WasmGC bundles.

The host also has these external proof tools:

- Why3 1.8.2
- Alt-Ergo 2.6.3
- Z3 4.13.3

Why3 detects both solver families.

## First proof package

`src/compiler_proofs` is proof-enabled. It separates executable code in `.mbt` from logical predicates and lemmas in `.mbtp`.

The first nine proved goals cover three compiler foundations.

### Arena spans

The proof model defines a valid arena span as:

```text
0 <= arena_length
0 <= start
0 <= length
start + length <= arena_length
```

It proves:

- each index inside a valid span is inside the arena;
- a valid span has enough remaining arena items;
- two adjacent valid spans cannot share an index;
- the exclusive span end is not less than the start or length.

These facts will support executable validators for all compiler arenas and span tables.

### Physical carriers

The proof model defines one certified carrier path:

```text
source carrier = planned carrier = emitted carrier
```

It proves that the emitted carrier is supported and is equal to the source carrier.

This is the first part of the certified lowering boundary. Later work must replace late shape recovery in `self_host/compiler/starshine_module.dew` with data that has passed this proof obligation.

### Dense type remaps

The proof model defines the new index of one retained type as:

```text
new index = old index - removed types before old index
```

It proves:

- a retained type index stays inside the compacted type arena;
- dense compaction keeps a retained supertype before its retained subtype;
- the remapped index is not negative and is not greater than the old index.

These proofs support the post-link type compaction in Starshine RUME. A regression test now checks the real rewrite path. It removes one unused subtype between a base type and a retained subtype and checks that the retained supertype index changes from `2` to `1`.

## Proof lane

Run:

```sh
tools/test-proofs.sh
```

The main `tools/check.sh` lane also runs this proof command.

Small failure-driven compiler proofs now live in `docs/proofs/`. The proof map
in `docs/proofs/README.md` states which rules are proved, checked at run time,
tested, or still open. These notes cover namespace calls, branch expected
types, constructor recovery, and unsigned arena checks.

## Trust boundary

MoonBit formal verification is experimental. Its default integer model uses mathematical integers. It does not prove machine-integer overflow safety.

For that reason, each compiler proof that uses `Int` or models Dew `U32` values still needs an executable range check at the certified-plan boundary. The formal proof establishes the algebra after the range check succeeds.

No proof in this package uses `proof_axiomatized`. An axiomatized item would add an unproved assumption to the trusted compiler surface and must be documented before use.

## Next proof work

1. Add executable arena validators for every semantic and lowering arena.
2. Connect each validator condition to the proved span predicates.
3. Define the full carrier set for I32, I64, F32, F64, V128, and reference values.
4. Prove carrier preservation for locals, fields, Array operations, calls, block joins, and returns.
5. Make backend emission consume only a certified representation plan.
6. Reject all error, generic, or fallback shapes before certification.
7. Make the production core-linker package proof-enabled after MoonBit can translate its transitive Starshine types. The current translation stops on the external `closedHeapTypeSet` type.
