# Self-host module interfaces and imported types — August 20, 2026

## Status

The Dew self-host compiler now freezes public signature interfaces and resolves
imported type syntax across ordered modules.

The port adds:

- `semantic_module_interfaces.dew`: public signature declarations, imported
  declaration bindings, exact aliases, open imports, wildcard imports,
  deterministic ambiguity diagnostics, qualified lookup, and interface-local
  resolved-type translation;
- `semantic_program_interfaces.dew`: manifest-ordered module and file
  collection, deterministic module/file IDs, two-stage interface freezing,
  missing import diagnostics, and cyclic signature support;
- focused module-interface and program-interface tests.

Public structs, enums, foreign types, traits, and aliases are frozen. Private and
test-only declarations are excluded. Alias interfaces publish the resolved alias
target while nominal and trait declarations preserve their external semantic
identities.

## Imported type resolution

Local declarations shadow opened imports. Exact imports create only an `@alias`
namespace. Open and wildcard imports expose public types and traits. Two opened
interfaces with the same distinct type or trait name mark that name ambiguous
and retain a deterministic diagnostic.

The local type resolver now supports:

- opened imported nominal and trait types;
- alias-qualified type and trait syntax;
- imported constructor arity;
- transparent zero-argument imported aliases;
- generic imported alias substitution;
- imported product, application, and function types copied iteratively into the
  consumer's canonical resolved-type arena.

Imported type copying and generic alias substitution use explicit task stacks.
They do not recurse with source nesting.

## Program freezing

Program manifests preserve module order and file order. Module IDs use the
caller base plus the manifest index. File IDs retain the packed module/local
layout.

Interface freezing uses two stages:

1. resolve and freeze each module's local public declarations;
2. build import scopes from those provisional identities, resolve complete
   signatures with imports, and freeze final interfaces.

This permits mutually importing modules to refer to each other's public nominal
and trait declarations without requiring body inference.

## Current boundary

These are signature-only interfaces. Callable export recipes, public inferred
module values, fields, variants, implementation evidence, ABI fingerprints,
content fingerprints, persistent interface codecs, and cache admission remain
in the later interface and backend tranches.

Opened imported value names and exact module aliases are now consumed by body
name resolution. See
[`self-host-body-name-resolution-2026-08-20.md`](self-host-body-name-resolution-2026-08-20.md).
Full callable recipes, inferred module values, fields, variants, and
implementation evidence remain for imported semantic resolution and inference.
The next dependency phase is deterministic derive expansion.
