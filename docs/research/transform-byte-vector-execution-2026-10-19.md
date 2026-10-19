# Byte and vector transform execution

Both VMs now keep byte literals as raw bytes. The new `ast.bytes` builder emits
hex escapes after checking the output budget. It does not decode UTF-8. The raw
text layout shares the existing checked reference rules, so standard Bytes
algorithms still run as ordinary Dew source.

The integer bit helper adds both widths of clz, ctz, popcnt, rotl, and rotr, plus
I64 extend8/16/32_s. Loops have a fixed maximum width of 64. Rotation counts use
Wasm masks. Zero counts return the operand width.

The Native vector helper uses two U64 words. The Dew dispatcher uses one-to-one
Wasm instructions inside the same compiler instance. It adds no host interface.
The generated dispatcher covers the current pure SIMD catalog, immediate lane
variants, bit operations, and byte shuffle. Linear-memory instructions are still
unsupported. This is not a claim of complete Wasm SIMD instruction coverage.

The test generator assembles actual Wasm oracle functions and records raw result
bits. There are 882 cases in 19 tests. Inputs include integer boundaries, lane
edges, infinities, NaNs, and signed zero. Arithmetic float NaNs are canonical;
moves and sign operations preserve payloads. Pseudo-min/max follow operand
selection from the [Wasm SIMD proposal](https://raw.githubusercontent.com/WebAssembly/spec/main/proposals/simd/SIMD.md).

A source-level test found that the scalar float predicate also matched vector
saturating-truncation names. Both predicates now require a scalar prefix. The
public vector example includes this path.

## Checks

- Native oracle tests: all 882 cases passed in 2.000 seconds.
- Native source tests: byte helpers, byte AST output, and vector helpers passed
  in 12.499 seconds.
- Integrated Native VM suite: 71 passed in 1.894 seconds.
- Dew production source check: 14.294 seconds.
- Integrated Dew transform suite: all 75 tests passed. Generation 6.990 seconds,
  linking 1.420 seconds, execution 0.233 seconds.
- Public compile requests passed for `bytes` and `vectors`. Compile times were
  4.734 and 3.255 seconds; both validated and returned 42.
- Self-host fixed point passed. B and C SHA-256:
  `16268107974f2dc1a6d4a9a2378ac0fae571338da90742b15ff5761d72b2a3a1`.
  A source build 19.474 seconds; A execution 22.734 seconds; B execution
  21.991 seconds. The whole lane took 78.519 seconds and exceeds the 30-second
  project rule. The Native generator refresh also exceeded it at 33.258 seconds.

Logs are under `.tmp/transforms-v3/`: `vector-first-check.log`,
`text-source-first.log`, `source-vector.log`, `dew-vector.log`,
`generator-vector.log`, and `bootstrap-vector.log`. Times are completion checks,
not controlled speed measurements or peak-memory measurements.
