# Narrow raw-array storage must preserve width and signedness

A valid user module allocates `Raw<I8>` with an unsafe bitcast of I32 value 511,
reads element zero, and bitcasts the result back to I32. Native compilation
returns -1. Self-host compilation returns 511 (0.189 seconds). The raw Wasm
array contract requires packed storage and a signed packed read; an i32 function
carrier does not prove either operation.

The native compiler already preserves narrow storage shapes during
specialization. The self-host compiler normalized I8/U8/I16/U16 to I32, used
unpacked arrays, and emitted plain `array.get`. Storage selection must retain
width and signedness separately from the function's scalar stack carrier.

The regression corpus adds direct signed/unsigned 8-bit and 16-bit reads,
ordinary generic forwarding, and Array literal/growth checks. All 28 cases pass
in native compilation before the self-host fix. The first self-host red lane
fails its packed-shape test and the expanded runtime module (60.315 seconds).
The larger runtime fixture also exposes generic literal storage selecting a
reference array for an i32 value; this is not accepted as an expected trap.

Specialization now retains narrow width and signedness, matching native keys.
Function-carrier normalization has a separate name and still maps these types
to i32. Two packed array heap types follow the existing synthetic prefix; the
function-value signature base accounts for those entries in one shared helper.
Storage recipes select the exact heap and plain/signed/unsigned read kind.
They reject Generic, Error, Never, and invalid product leaves.

Raw allocation, access, writes, default allocation, and copies use the declared
array element type, not a value's erased stack carrier. Array literals use the
same element storage recipe, with no default reference array or first-child
carrier guess. The literal's old three-field wrapper construction still needs
its separate migration. Packed struct/enum fields are also separate: a matching
user-struct probe still returns 511 instead of -1 in self-host compilation.

The provider already
exports the five needed packed-type/read operations. The consumer's explicit
used-export list must include them before regeneration; the first generation
attempt stopped on that check (4.074 seconds). After selecting those exports,
generation succeeds (4.185 seconds). No provider change or speed work is needed.

An intermediate compile found another selected raw-read task using the old
instruction kind (15.628 seconds); it now uses the same storage/read recipe.
The next full lane passes 525 tests and all 28 raw-array checks (60.340 seconds).
The original one-element source now returns -1 (0.201 seconds).

Final coverage adds packed default/write/copy operations and exact runtime
bounds traps, for 34 shared raw-array checks. Hardening passes 526 compiler
tests, 184 exact invariant records, and all execution probes (60.172 seconds).
The library lane passes 326 tests and shared checks (27.691 seconds), and
generated checks pass (4.317 seconds). All 474 selected FFI signatures have
generated typed bindings; the five additions were existing provider exports.

Clean bootstrap passes (185.474 seconds), with identical B/C raw and linked
SHA-256 `611899f914200569f1dfa66b27f239f1a6aba3e1a83fb94932e22840f9acb40b`.
Runs over 30 seconds remain speed bugs.
