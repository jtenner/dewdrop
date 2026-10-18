# Refresh the imported-package ABI fixture

The field privacy change adds a module-private bit to each field's interface
metadata. This changes saved hashes even when the bit is false. The imported
callback package and the standard Option and Result types have fields, so the
fixture's package lock and expected ABI data need new hashes. The application
interface also depends on them.

The dependency and application source, plus both package definitions, are
byte-identical to review baseline `9d86b82929`. Package integrity is unchanged.
ABI schema versions and module paths stay the same. The generic adapter remains
`identity_box$dew$i32`, and the existing external consumer returns `42`.

The hashes came from real native compiler output, with the package's module
names and disk standard modules. For example:

```sh
_build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe build \
  --no-program-cache --no-cache-pack --no-interface-cache \
  --module fixture.package_callback \
  tests/abi-consumers/imported-package/dependency/callback.dew \
  --root fixture.package_callback -o /tmp/package-callback.wasm
node tools/dew-abi.mjs /tmp/package-callback.wasm interface
```

The same command with both package modules and root `fixture.application`
produced the application ABI. The new dependency interface is
`0814b500a42b5814c92ea1331e8d4be9d943bbb4a0eda806e2a6065de6bebfba`.
The application interface is
`40675e033507c17e9376721378d813385a979c3aa303ec69d495e21a3e7e4984`.
The two builds took 0.180 and 0.183 seconds. The compiler accepts the new
dependency hash and reports a visible error for the all-zero hash. The external
consumer also rejects its all-zero expected hash. A changed source byte still
fails package-integrity validation. The negative tests in the full script are
unchanged.

The [validation record](data/imported-package-abi-2026-10-18/validation.json)
contains exact commands, tool hashes, source comparisons, decoded ABI data,
runtime results, and the old-constant search. No active fixture or test command
still uses the old hashes. Research logs and this audit keep them as evidence.

The normal `tools/dew` manifest check reached a 29-second timeout while another
shared Moon build was active. No pass is claimed for that call. No child
compiler from it remained after the timeout. The focused checks above use
prebuilt tools; the complete CLI lane must be run again by the root agent.
