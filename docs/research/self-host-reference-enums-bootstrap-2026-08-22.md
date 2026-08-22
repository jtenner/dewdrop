# Self-host reference, enum, and bootstrap probe

Date: 2026-08-22

## Backend work

The linked emitter now accepts all planned Wasm value carriers in signatures, locals, and fields:

- I32
- I64
- F32
- F64
- V128
- nullable `eqref`

Enum planning now emits:

- one open empty base struct;
- one final subtype for each variant;
- tuple payload fields in source order;
- struct-variant fields in physical field order;
- correct linked supertype indexes.

The smoke source declares unit, tuple, and struct variants. Its output validates the base/subtype hierarchy and scalar payload layouts.

## Full compiler request probe

`src/self_host_bootstrap_fixture/` now writes a bounded source request for the complete self-host compiler plus the exact required bootstrap standard modules and pinned Starshine provider.

The first full request exposed a MoonBit-generated runtime cast failure while the Dew compiler inferred local variant calls in `dew.std.array`. Replacing the internal `Option<U32>` local-variant lookup with a U32 sentinel removed that cast and let inference continue through all selected standard modules into `self_host.compiler`.

The next observed full-source failure is an explicit runtime trap during imported generic method candidate checking in `self_host_parse_function_parameters`. This occurs before physical backend emission. It is now the first fixed-point blocker.
