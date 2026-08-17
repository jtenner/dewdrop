# Compiler host request protocol

The compiler accepts one bounded binary request from a matching internal launcher.
The launcher resolves packages, verifies integrity, orders sources, selects static
providers, and sends exact source and Wasm bytes. The compiler does not repeat
package discovery or source-file reads.

This protocol is private to matching Dewdrop toolchains. It is not a stable
third-party API.

## Invocation

```text
moon run --target native --release src/dew_cli -- --compile-request REQUEST
```

The compiler reads `REQUEST` once. Build responses are written to the explicit
output path in the request. Check responses return status and diagnostics only.

## Version policy

The request version is **1**. Until Dewdrop is released, incompatible changes
replace version 1 in place. No legacy pre-release reader is retained.

## Scalar encoding

- Integers are unsigned 32-bit little-endian values.
- Booleans are `u32`: `0` false and `1` true.
- Strings are a `u32` byte length followed by strict UTF-8 bytes.
- Byte payloads are a `u32` byte length followed by arbitrary bytes.
- Arrays are a `u32` count followed by ordered elements.
- No padding is present.
- Trailing bytes are rejected.

## Version 1 layout

```text
magic                          u32 = 0x44574352
version                        u32 = 1
command                        u32 (0 check, 1 build)
output kind                    u32 (0 Wasm, 1 HIR, 2 lowering)
response mode                  u32 (0 status only, 1 output file)
if response mode = 1:
  output path                  string
root module                    string
modules                        array {
  module name                  string
  files                        array {
    logical path               string
    exact source               bytes
  }
}
dependency expectations        array {
  module name                  string
  interface fingerprint        string: 64 lowercase hexadecimal bytes
}
static providers               array {
  provider name                string
  exact Core Wasm              bytes
}
standard-library mode          u32 (0 embedded bootstrap standard sources)
standard-library identity      bytes: exactly 32-byte BLAKE3 digest
optimization mode              u32 (0 optimized)
diagnostics mode               u32 (0 deterministic text)
test mode                      bool-as-u32
use default preamble           bool-as-u32
cache policy                   u32 (0 all persistent caches disabled)
report cache status            bool-as-u32
compiler fingerprint           bytes
```

Check requests must use Wasm output kind and status-only response mode. Build
requests must use output-file response mode.

The embedded standard-library identity is BLAKE3 over a domain separator, the
ordered standard source path registry, and each exact source payload. A mismatch
fails before compiler phases begin.

`CompilerSessionConfig` owns optimization, diagnostics, test planning, default
preamble selection, cache policy, and cache reporting. The source-Bytes request
path does not mutate environment variables. The first fixed point supports only
optimized compilation, deterministic text diagnostics, and disabled persistent
caches.

## Bounds

| Item | Limit |
|---|---:|
| Complete request | 256 MiB |
| Modules | 1,024 |
| Files per module | 4,096 |
| Files in the request | 65,536 |
| One source payload | 16 MiB |
| Dependency expectations | 4,096 |
| Static providers | 64 |
| One provider payload | 64 MiB |
| Module/provider names | 255 bytes |
| Logical/output paths | 4,096 bytes |
| Compiler fingerprint | 4,096 bytes |

Every module must contain at least one file. Module names, file paths, dependency
modules, and provider names must be unique in their local collection. Logical
source paths must be relative and normalized. Source and provider payloads may
contain any bytes, including invalid UTF-8.

## Order and ownership

Module, file, dependency, and static-provider order is semantic input and is
preserved exactly.

The launcher owns:

- manifest and lockfile resolution;
- package integrity checks;
- source discovery and ordering;
- standard-library and provider selection;
- downloads and process launch;
- request and response file cleanup.

The compiler owns:

- request validation;
- parsing the supplied in-memory source bytes;
- dependency-interface checks;
- semantic analysis and code generation;
- deterministic static linking;
- diagnostics and output publication.

## Implementation and tests

The shared MoonBit model and codec are in `src/compile_request`. The current
MoonBit compiler consumes the decoded manifest directly through
`ManifestFile(logical_path, source)`. It does not materialize source or provider
payloads as temporary files.

`CompilerPipelineOptions` has an uncached entry point used by this request path.
Ambient cache environment variables are ignored. `tools/check-compile-request.sh`
runs the same request in two physical directories, validates both Wasm outputs,
checks byte identity, and verifies that no cache directory was created.
