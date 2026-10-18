# Module-only struct fields

Date: 2026-10-18

## Problem

Checked JSON values were ordinary public records. Safe user code could create
`JsonNumber::{ lexeme: "BAD" }` or set `JsonString.needs_escape` to false for text
that needs an escape. The writer then returned success with invalid JSON.
Rechecking every write would remove the purpose of these checked values.

The language now has a general source access rule for struct fields. It applies
to every module and nominal type. It does not depend on a standard module path,
a type name, a declaration number, or a source spelling outside the parser.

## Syntax and access

```dew
pub struct CheckedText {
  private value: String
}

pub struct Counter {
  private mut count: U32
  label: String
}
```

Unmarked fields stay public. `private` is a contextual field prefix before the
optional `mut` prefix. It is not a new tokenizer keyword. The old field spelling
`private: I32` stays valid and public. The rule applies to struct declarations;
enum payload fields keep their existing public behavior.

All files of the declaring module can read, write, construct, and destructure
private fields. A different module cannot read, write, initialize, or bind such
a field. This includes generic types and inferred object expressions. If any
field is private, a caller cannot construct the record by omitting it: required
field checks still include the complete shape. Callers can receive the public
type from a factory function and call its public methods.

A pattern in another module can read public fields and ignore the other fields
with `...`. It cannot bind a private field. A full pattern must still account
for the complete record shape.

The compiler reports unavailable fields with the existing source diagnostics:
`UnknownFieldForType`, `UnknownConstructionField`, `MissingConstructionField`,
and `UnknownPatternField`. Failed access never receives a usable selected field
operation. This preserves the normal diagnostic and compiler error paths.

Field-name and field-type queries describe structural metadata. They still
include private field names and types. Knowing a name or type does not grant
access to a value or allow construction. Private fields are a source access
rule, not a security boundary against explicit unsafe casts or raw WebAssembly
instruction declarations.

## Compiler and cache design

Both parsers record `module_private` separately from mutability. Native and
self-hosted collection, frozen interfaces, and imported field records preserve
that bit. Ordinary source inference checks the bit at the module boundary.
Same-module field handling stays direct.

Frozen interfaces retain the full ordered field list. Removing a private field
would change layout indices and break constructors, methods, generic type
substitution, and link-time checks. Private fields therefore keep their original
physical position and carrier. No runtime visibility checks are emitted.

The parser artifact and native frozen interface codecs store one Boolean after
the existing mutability Boolean. Declaration ABI fingerprints include privacy.
Frozen-interface binary magic and bundle, workspace, and SCC cache keys use a
new version-1 private-field format marker, so old cache bytes are not read as the
new shape. The parser cache provenance also changes with the parser artifact
schema. All format versions remain 1.

## JSON use

`JsonNumber.lexeme`, `JsonString.value`, and `JsonString.needs_escape` are private.
Stored source/value fields of `JsonDocument` and `JsonRawDocument` are also private,
so callers cannot forge source documents described as validated.
Checked factories, parser construction, and getters remain available under their
normal module rules. The writer can keep the proven-value fast paths.

Parser/writer state types and internal scanner, parser, writer, and unsafe
rewrap helpers are module-only declarations. The documented parse, validate,
reader, writer, limit, value-construction, and object-lookup APIs stay public.

## Cost

Runtime field layouts and direct access instructions do not change. Checked JSON
writes add no validation pass and no allocation. The compiler stores one Boolean
per source/import/interface field; serialized parser and interface records add
one Boolean byte per field. These are static representation costs, not a claim
of a measured compiler memory improvement.

## Validation

Focused parser tests cover the modifier, mutable private fields, public defaults,
a public field named `private`, and parser artifact round trips. Native semantic
tests cover cross-module reads, writes, construction with supplied or omitted
private fields, pattern binding, public getters, public fields, same-module
construction/mutation/patterns, rest patterns, and frozen interface round trips.
Self-hosted tests cover the matching source rules and metadata propagation. All
28 focused self-hosted tests passed, including seven new privacy tests, existing
imported-semantics cases, derive tests, a field named `private`, and access from
another file in the same module. Test generation took 4.503 seconds, linking took
1.093 seconds, and execution took 0.078 seconds. Logs are in
`.tmp/self-host-private-fields/{generate.log,test-link.log,all-focused-tests.log}`;
the separate self-host note records the commands.

The exact native test command was:

```sh
DEW_NATIVE_TEST_PACKAGES='parser/module_private_fields_wbtest.mbt semantic/module_private_fields_wbtest.mbt' bash tools/test-native.sh
```

All three parser tests and eight semantic tests passed. The command took 9.970
seconds; the semantic lane took 9.934 seconds. These include same-module
cross-file access, getter methods, derived Eq/Debug/Hash implementations, and
cross-module field-name and field-type query results. The JSON source generator,
standard builtin registry check, and six text-cast policy tests also passed.
A first test-name filter matched zero tests; the final command above uses exact
file targets and its nonzero test counts are the recorded evidence.

The compact test record is in
[`data/module-private-fields-2026-10-18/validation.json`](data/module-private-fields-2026-10-18/validation.json).
Full native logs are in
`/tmp/dewdrop-review-2026-10-18/runtime/privacy/focused-exact.{stdout,stderr,json}`.

An additional native regression in `src/semantic/json_provenance_wbtest.mbt`
imports the actual standard module and rejects forged JsonNumber, JsonString,
JsonDocument, and JsonRawDocument constructors. It passed with the final flow
test group. This checks the library's private modifiers as well as the general
language rule, so removal of a JSON modifier causes a test failure.
