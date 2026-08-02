# Dew SWAR parity suite

This harness ports the deterministic edge-case and seeded-random parity strategy from `JairusSW/as-simd` to executable Dew-generated Wasm. The initial port was audited against upstream commit `4045df3c989cc7c4e0e05db508879906b63906f0` from July 24, 2026.

Run from the repository root:

```text
tools/swar-parity/run.sh
```

The harness:

1. Compiles `swar_parity.dew` through Dew's complete frontend, semantic, lowering, Starshine validation, and binary encoder pipeline.
2. Writes the temporary `swar_parity.wasm` fixture.
3. Instantiates it in Node.
4. Compares exported `Swar32` and `Swar64` operations against independent BigInt lane oracles.

The current suite covers:

- splat;
- signed and unsigned extraction;
- dynamic replacement;
- wrapping lane add/subtract/multiply;
- signed and unsigned lane shifts;
- signed and unsigned `i8`, `i16`, and `i32` min/max and comparison masks;
- signed packed absolute value and negation;
- signed and unsigned saturating packed add/subtract;
- unsigned rounded packed average;
- `any_true` and `all_true_i8`;
- `i8` bitmask, equality/inequality masks, and per-lane population count;
- both deterministic edge vectors and 256 SplitMix64-derived random runs.

The current run performs 61,000 comparisons. Extend this harness together with each newly ported SWAR operation. The generated `.wasm` file is ignored and must not be committed.

The upstream MIT notice is retained in `THIRD_PARTY_NOTICES.md`.
