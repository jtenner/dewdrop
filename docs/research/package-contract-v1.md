# Local package contract, version 1

Date: 2026-10-28. Base: `20f902acb6caa56a49712df832aeb0c46ec520b8`.
Plan: `c812b052:docs/package-manager-migration-plan.md`.
The owner has approved Phase 1 local work only. The plan's earlier Phase 0-only
text is not the current grant. This note defines the shared local rules and the
scope of all seven gaps. It does not claim that all readers pass these rules.

Shared vectors and adapters live in `tests/package-contract-v1/`.
They are test data, not a new runtime parser. All formats and codecs stay v1.

## Names, versions, and requests

A name is `@scope/name`, at most 255 UTF-8 bytes. Both sides are nonempty.
Each side permits only lowercase ASCII letters, digits, `.`, `_`, and `-`.
Exactly one slash is present. No additional start-character rule applies.
For example, `@0/9` and `@./..` pass the existing name grammar. They are not
filesystem paths or a claim to a registry namespace.

A SemVer is a strict `major.minor.patch`, with optional nonempty prerelease and
build identifier lists. The complete text is at most 255 bytes. Core numbers
and all-numeric prerelease identifiers are U32, from 0 through 4,294,967,295.
They have no leading zero unless the number is zero. Identifiers use ASCII
letters, digits, and `-`, separated by dots; no identifier is empty. Build
identifiers are text: numeric build text can exceed U32 and have leading zeros.
No `v` prefix, spaces, missing core part, or trailing `-` or `+` is valid.

SemVer precedence ignores build text. Numeric prerelease IDs sort below text
IDs. A release sorts above its prereleases. Use the existing Dew comparison
rules, not a host package library with different numeric bounds.

A dependency request is nonempty, at most 2,048 bytes, and is exactly one of:

- `*`.
- One full SemVer, or `^` or `~` followed by one full SemVer.
- `git+SOURCE#REF`, with nonempty SOURCE and REF and no NUL.

For Git, split at the first `#`. The existing Dew rule does not validate a URL
scheme or restrict later `#` characters. `git+x#r` and `git+x#r#s` pass. Phase 1
does not add remote lookup, Git URL policy, or public release provenance rules.
There are no npm partial, comparator, union, hyphen-range, or `x` forms.

The local match predicate stays as `std/package.dew` and `std/semver.dew` define
it. `*` excludes prereleases. Exact matches compare precedence, ignoring build.
Caret starts at its base and keeps the same nonzero major; for major zero it
keeps the same nonzero minor; for `0.0.p` it keeps that patch. Tilde starts at its
base and keeps major and minor. A prerelease candidate passes caret or tilde
only when it has the SAME precedence as the base. Selecting any prerelease with
the same core is broader and is not the current rule. A Git request's local
version predicate returns true. This is not proof of Git source identity.

## Manifest

`dew.json` is a UTF-8 JSON object of at most 1,048,576 bytes. It has required
string `name` and `version`, checked by the rules above, and optional
`dependencies`. Absence means `{}`. A present value must be an object. Each
member key is a valid package name; each value is a valid request string. There
are at most 256 direct dependencies. Treat `__proto__` and similar strings as
ordinary input keys; the name grammar rejects them.

No other top-level key is allowed. Dependency members are package names, not
nested dependency option records. Reject every duplicate key, including equal
values. Decode JSON escapes before key comparison. `name` and `na\u006de` are
duplicates, as are `@c/d` and `@c\u002fd`. Do not parse to a map that loses this
information before validation. Sort dependencies by unsigned UTF-8 bytes for
canonical output and hashing. Input member order does not change identity.

## Source selection and fixed inputs

If `src` is a real directory, select its recursive regular `.dew` files.
Otherwise select only root regular `.dew` files. A regular file named `src`
does not prevent the root fallback. An empty `src` directory does prevent that
fallback, then fails the source-required check. Do not use a read failure as a
reason to switch to a different inventory.

The selected logical paths are relative to the package root and sorted in full
unsigned UTF-8 byte order. Compile excludes names ending `_test.dew`. Source
integrity and capsules include those tests. No selected source is a symlink.
Reject symlink source entries and directories in the selected tree, including a
symlink named `src`, and any escape from the root. Do not follow, silently skip,
or fall back from such a link. A root subdirectory outside the selected `src`
tree does not become source merely because it contains `.dew` files.

Phase 1 pack must use one fixed local snapshot for compile, interface, integrity,
and capsule input. Mutation after the snapshot must not combine old and new
bytes. The worker that owns pack must add its own race check. The static
source-selection vectors do not prove snapshot safety. Remote tagged source
verification remains Phase 4.

Module name derivation retains its purpose: remove `@`, map `/` to `.`, and map
`-` to `_`. Name collisions need graph checks; these grammar vectors do not prove
collision handling.

## Logical artifact paths and bounds

A logical source path is nonempty, relative, slash-separated UTF-8 text of at
most 4,096 bytes. It must end with the exact lowercase suffix `.dew`. No
absolute path, backslash, NUL, empty segment, `.`, or `..` segment is allowed.
`dew.json/` is a reserved prefix. Reject duplicate paths and a file path that
is also a directory prefix, in EITHER record order. Check path syntax and
containment before materialization. Logical path tests do not prove that a
host filesystem can create a 4,096-byte single path segment.

| Limit | Inclusive maximum |
| --- | --- |
| Package name | 255 bytes |
| SemVer text | 255 bytes |
| Dependency request | 2,048 bytes |
| Manifest | 1,048,576 bytes |
| Direct dependencies | 256 |
| Logical source path | 4,096 bytes |
| One source file | 16,777,216 bytes |
| Source file count | 65,536, with at least one file |
| Complete publish capsule | 67,108,864 bytes (64 MiB) |
| Complete local artifact | 268,435,456 bytes (256 MiB) |

The 64 MiB cap is a publish policy for the complete encoded capsule. It does not
lower the local artifact codec cap. Both count length prefixes, headers, and the
32-byte SHA-256 trailer. Check sizes and counts before large allocations. A local
artifact over 64 MiB can be valid if each source and the complete 256 MiB bound
pass. This does not make it publishable.

The capsule remains `DEWPKG1\0`: identity, exact version, source, source integrity,
interface fingerprint, dependency requests, source records, SHA-256 trailer.
Source integrity, capsule checksum, and interface fingerprint remain distinct.
Shared path/budget vectors do not alone prove binary decode or restoration.

## All seven plan gaps: scope ledger

| Gap | Phase 1 work | Limit and remaining gate |
| --- | --- | --- |
| 1. Publisher requires dependencies | All local manifest readers accept absence as `{}`; shared absent/empty controls. | The baseline probe reproduces the old capsule rejection. Other workers own production fixes. |
| 2. Split manifest validation | Align names, SemVer, requests, schema, decoded duplicate keys, sources, and bounds across local CLI, bootstrap, and standard codec entry points. | Shared vectors are provided here. Each worker must test its real reader, including decode plus validate where separate. Server reuse is later. |
| 3. Missing package commands | Add only local `dew pack` with strict options and local output. | Network add/install/search/resolve/update/remove/info belong to Phase 5. Do not test their absence as a Phase 1 defect. |
| 4. Multiple source reads | Bind local build, interface, integrity, and pack bytes to one fixed snapshot. | Pack worker owns mutation checks. Remote tag/source verification, upload, and accepted release records belong to Phase 4. |
| 5. Unproved server persistence/listing | No local change can close this gap. | Durable persistence, public listing, and immutable download require the Phase 4 server work and end-to-end checks. A local pack result is not proof. |
| 6. Lock validation shortfall | Check existing materialized local graphs: request/version, source, identity, containment, integrity, and interfaces at the owning layer. Keep v1 fields. | The lock worker must prove each reachable failure first and cover shared build/cache callers. Network graph resolution and fetch are Phase 5. These vectors cover value rules, not lock traversal. |
| 7. Token expiry/revoke | Explicitly outside Phase 1. No auth edit or auth regression claim here. | Expiry, refresh, revoke status, and session state are Phase 3. Pack does not fix them. |

## Open rule points for the coordinator

The owner instructions settle strict SemVer and full sorted paths. Baseline Dew
parser source appears to accept a trailing `-` or `+`; that observation has NOT
been executed in Dew during this hold. The old JS capsule probe does accept
those versions, because that function does not check SemVer. Workers must test
the Dew parser itself before claiming that parser defect is reproduced.

The old JS collector returns directory-first order for `src/a/z.dew` versus
`src/a.dew`. The shared case requires full logical path sorting. This is a
reproduced old-reader difference and can affect source integrity. Coordinate all
hash/capsule callers together; do not let only one path switch order.

`C:/main.dew` is an absolute Windows path and is rejected by the shared vector.
The old Dew relative-path predicate checks a leading slash but not drive roots.
Execution on Windows and drive-relative or host-specific filename policy are
not proved here. Do not silently add a ban on all colon characters or change
case-sensitive logical identity. The platform worker must check those paths.

The direct dependency limit is 256. A very large valid 256-member manifest can
also meet a JSON reader's independent depth/string budget. Alignment must not
introduce an undocumented smaller public name, request, or manifest byte cap.

## Validation and performance limits

The test-only baseline adapter runs unchanged baseline JS function bodies with
fresh local files. Its SemVer/name/request checks call capsule with those
values in an otherwise valid manifest. This proves capsule admission behavior,
not a standalone SemVer parser's behavior. Its `compiler` path list is only a
filter of publisher source paths, not a compiler run.

No compiler, native test lane, platform build, benchmark, memory measurement,
server, auth, network install, or publication is run by this area. The laptop
hold remains active. Adapter support and unsupported IDs must stay visible.
Production red-to-green checks and the quiet-host measurement gate remain with
the owning workers and coordinator. See `pkg-phase1-contract.md` for the exact
baseline evidence and handoff workload.
