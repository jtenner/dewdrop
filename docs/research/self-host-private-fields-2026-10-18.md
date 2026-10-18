# Self-host module-private struct fields

Struct fields can use `private` before the optional `mut` prefix. A field without
this prefix stays public. `private: I32` remains a public field named `private`.
Enum payload fields keep their existing public behavior.

The source AST, collected fields, frozen interface fields, and resolved imported
fields retain a `module_private: Bool` bit after the mutable flag. Interface
schemas remain version 1. All fields remain in interfaces and physical layout
plans. Their order and storage do not change.

Private fields allow all normal reads, writes, construction, and pattern binding
within their module. Import checks reject reads, writes, named construction
fields, and named pattern fields. Omitted private fields prevent construction.
An imported pattern must use `...` to omit private fields. A rest-only pattern is
valid. These checks run during semantic analysis and add no runtime checks.

Compile-time field-name reflection keeps complete layout metadata. It provides
names, not access to field values. It cannot bypass the semantic checks above.

`self_host/compiler/semantic_private_fields_test.dew` covers the parser flags,
frozen import flags, local access, generic imported access, writes, explicit and
inferred construction, rejected pattern binding, allowed rest patterns, and access from another file in the same module.

Validation used the existing native test generator and linker, with private
outputs in `.tmp/self-host-private-fields`. Test generation took 4.503 seconds,
linking took 1.093 seconds, and all 28 tests passed in 0.078 seconds. This includes
seven private-field tests and the existing imported-semantics and derive
expansion tests. No compiler step exceeded 30 seconds. Physical field records did not
change; the new bit is used only by compiler source and interface records.
