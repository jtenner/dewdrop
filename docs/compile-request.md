# Compiler host request protocol

The Python bootstrap host invokes the MoonBit compiler with one versioned binary
request rather than expanding package and cache policy into repeated internal
command-line arguments and inherited environment variables.

This protocol is private to matching Dewdrop toolchain versions. It is not a
language-level package format or a stable third-party API.

## Invocation

```text
moon run --target native --release src/dew_cli -- --compile-request REQUEST
```

The bootstrap host creates `REQUEST`, waits for the compiler process, and removes
the request file. The compiler still accepts its legacy direct arguments for
focused development, but `tools/dew` does not use that path.

## Version 4 encoding

All integers are unsigned 32-bit little-endian values. Strings are a byte length
followed by UTF-8 bytes. Arrays are a count followed by their elements.

```text
magic                         u32 = 0x44574352
version                       u32 = 4
command                       u32 (0 check, 1 build)
requested output              u32 (0 Wasm, 1 HIR, 2 lowering)
output path                   string
root module                   string
modules                       array {
  module name                 string
  ordered source paths        array<string>
}
dependency expectations       array {
  module name                 string
  interface fingerprint       string
}
standard-library policy       u32 (0 ordered on-disk root, 1 bootstrap bytes)
standard-library root         string
use default preamble          bool-as-u32
use parse-event cache         bool-as-u32
use interface cache           bool-as-u32
use body-inference cache      bool-as-u32
use body-family cache         bool-as-u32
report cache status           bool-as-u32
build mode                    u32 (0 production, 1 test planning; reserved by CLI)
dependency cache provenance   string
```

Module and file order are semantic input and must be preserved. The Python host
owns package resolution, lockfile verification, source-path selection, and host
execution. The request contains the resulting compiler inputs and expectations;
it does not ask the MoonBit compiler to resolve packages.

The MoonBit compiler validates the magic, exact version, enum ranges, counts,
lengths, and trailing bytes before reading sources or entering compiler phases.
Malformed and incompatible requests fail visibly.

## Evolution

A protocol change that alters field meaning or ordering increments the version.
New bootstrap implementations should construct this request from their package
model directly. A future Dew-native host can use the same boundary without
reproducing Python-specific argument or environment policy.
