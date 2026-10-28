#!/usr/bin/env python3
"""Write the small, deterministic, language-neutral package contract fixtures."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def write(name, kind, cases):
    (ROOT / f"{name}.json").write_text(json.dumps({
        "schemaVersion": 1, "kind": kind, "cases": cases,
    }, indent=2, ensure_ascii=True) + "\n")


def case(id, input, accept, rule, **extra):
    return {"id": id, "input": input, "expected": {"accept": accept, **extra}, "rule": rule}


def repeat(text, count):
    return {"repeat": text, "count": count}


def concat(*items):
    return {"concat": list(items)}


names = []
for id, value in [("short", "@a/b"), ("punctuation", "@a.b_c-d/e.f_g-h"),
                  ("digits", "@0/9"), ("dots-are-name-bytes", "@./..")]:
    names.append(case(id, value, True, "name-grammar"))
for id, value in [("empty", ""), ("unscoped", "a/b"), ("scope-empty", "@/b"),
                  ("name-empty", "@a/"), ("no-slash", "@ab"), ("two-slashes", "@a/b/c"),
                  ("upper-scope", "@A/b"), ("upper-name", "@a/B"), ("space", "@a/b c"),
                  ("unicode", "@a/caf\u00e9"), ("nul", "@a/b\0"), ("backslash", "@a/b\\c")]:
    names.append(case(id, value, False, "name-grammar"))
names += [case("bytes-255", concat("@a/", repeat("b", 252)), True, "name-byte-limit"),
          case("bytes-256", concat("@a/", repeat("b", 253)), False, "name-byte-limit")]
write("names", "name", names)

versions = []
for id, value in [("zero", "0.0.0"), ("release", "1.2.3"),
                  ("u32-core", "4294967295.4294967295.4294967295"),
                  ("u32-prerelease", "1.0.0-4294967295"),
                  ("build-not-u32", "1.0.0+9999999999999999999999999"),
                  ("build-leading-zero", "1.0.0+001"),
                  ("mixed-identifiers", "1.2.3-alpha.0.Z-9+build.001"),
                  ("text-leading-zero", "1.0.0-01a"), ("hyphen-identifier", "1.0.0--")]:
    versions.append(case(id, value, True, "strict-semver"))
for id, value in [("empty", ""), ("prefix-v", "v1.0.0"), ("short-core", "1.0"),
                  ("extra-core", "1.0.0.0"), ("leading-zero", "01.0.0"),
                  ("minor-leading-zero", "1.01.0"), ("patch-leading-zero", "1.0.01"),
                  ("core-overflow", "4294967296.0.0"), ("minor-overflow", "1.4294967296.0"),
                  ("patch-overflow", "1.0.4294967296"),
                  ("prerelease-overflow", "1.0.0-4294967296"),
                  ("prerelease-leading-zero", "1.0.0-01"), ("empty-prerelease", "1.0.0-"),
                  ("empty-build", "1.0.0+"), ("empty-pre-id", "1.0.0-a..b"),
                  ("empty-build-id", "1.0.0+a..b"), ("two-builds", "1.0.0+a+b"),
                  ("underscore", "1.0.0-a_b"), ("unicode", "1.0.0-\u00e9"),
                  ("space", " 1.0.0"), ("newline", "1.0.0\n"), ("nul", "1.0.0\0")]:
    versions.append(case(id, value, False, "strict-semver"))
versions += [case("bytes-255", concat("1.0.0+", repeat("a", 249)), True, "semver-byte-limit"),
             case("bytes-256", concat("1.0.0+", repeat("a", 250)), False, "semver-byte-limit")]
write("semver", "semver", versions)

requirements = []
for id, value in [("any", "*"), ("exact", "1.2.3"), ("caret", "^1.2.3"),
                  ("tilde", "~0.2.3"), ("pre", "^1.0.0-alpha.1"),
                  ("git-https", "git+https://example.invalid/a.git#main"),
                  ("git-ssh", "git+ssh://git@example.invalid/a#abc123"),
                  ("git-minimal-source", "git+x#r"), ("git-ref-hash", "git+x#r#s")]:
    requirements.append(case(id, value, True, "requirement-grammar"))
for id, value in [("empty", ""), ("npm-x", "1.x"), ("npm-partial", "^1.2"),
                  ("comparator", ">=1.0.0"), ("union", "1.0.0 || 2.0.0"),
                  ("space", " ^1.0.0"), ("bare-git", "https://example.invalid/a#main"),
                  ("git-no-ref", "git+x"), ("git-empty-ref", "git+x#"),
                  ("git-empty-source", "git+#main"), ("git-nul", "git+x#r\0"),
                  ("bad-version", "^01.0.0"), ("overflow", "~1.0.4294967296")]:
    requirements.append(case(id, value, False, "requirement-grammar"))
for suffix, version in [("empty-prerelease", "1.0.0-"), ("empty-build", "1.0.0+")]:
    for form, prefix in [("exact", ""), ("caret", "^"), ("tilde", "~")]:
        requirements.append(case(f"{form}-{suffix}", prefix + version, False, "requirement-grammar"))
requirements += [case("bytes-2048", concat("git+x#", repeat("r", 2042)), True, "requirement-byte-limit"),
                 case("bytes-2049", concat("git+x#", repeat("r", 2043)), False, "requirement-byte-limit"),
                 case("caret-semver-255", concat("^1.0.0+", repeat("a", 249)), True, "nested-semver-limit"),
                 case("caret-semver-256", concat("^1.0.0+", repeat("a", 250)), False, "nested-semver-limit")]
write("requirements", "requirement", requirements)

matches = []
for id, req, ver, match in [
    ("any-stable", "*", "1.2.3", True), ("any-pre", "*", "1.2.3-a", False),
    ("exact-build-ignored", "1.2.3+one", "1.2.3+two", True),
    ("exact-pre", "1.2.3-a", "1.2.3-a+meta", True),
    ("exact-other", "1.2.3", "1.2.4", False),
    ("caret-major", "^1.2.3", "1.9.0", True), ("caret-upper", "^1.2.3", "2.0.0", False),
    ("caret-lower", "^1.2.3", "1.2.2", False),
    ("caret-zero-minor", "^0.2.3", "0.2.9", True),
    ("caret-zero-upper", "^0.2.3", "0.3.0", False),
    ("caret-zero-patch", "^0.0.3", "0.0.4", False),
    ("caret-pre-same", "^1.2.3-a", "1.2.3-a+meta", True),
    ("caret-pre-next", "^1.2.3-a", "1.2.3-b", False),
    ("caret-pre-release", "^1.2.3-a", "1.2.3", True),
    ("tilde-minor", "~1.2.3", "1.2.9", True), ("tilde-upper", "~1.2.3", "1.3.0", False),
    ("tilde-pre-next", "~1.2.3-a", "1.2.3-b", False),
    ("git-version-filter-only", "git+x#r", "99.0.0-a", True),
]:
    matches.append({"id": id, "input": {"requirement": req, "version": ver},
                    "expected": {"accept": True, "matches": match}, "rule": "dew-range-match"})
write("requirement-matches", "requirement-match", matches)

base = {"name": "@a/b", "version": "1.0.0"}
raw = lambda value: json.dumps(value, separators=(",", ":"), ensure_ascii=True)
manifest = [case("dependencies-absent", raw(base), True, "absent-dependencies", dependencies={}),
            case("dependencies-empty", raw({**base, "dependencies": {}}), True, "manifest-fields", dependencies={}),
            case("dependencies-sorted", raw({**base, "dependencies": {"@z/b": "*", "@a/c": "^1.0.0"}}),
                 True, "dependency-order", dependencies={"@a/c": "^1.0.0", "@z/b": "*"}),
            case("escaped-valid-keys", '{"na\\u006de":"@a/b","ver\\u0073ion":"1.0.0","dependencies":{}}', True, "decoded-keys", dependencies={})]
for id, value, rule in [
    ("unknown-field", {**base, "dependencies": {}, "description": "x"}, "unknown-field"),
    ("name-missing", {"version": "1.0.0", "dependencies": {}}, "required-name"),
    ("version-missing", {"name": "@a/b", "dependencies": {}}, "required-version"),
    ("name-null", {**base, "name": None, "dependencies": {}}, "name-type"),
    ("version-number", {**base, "version": 1, "dependencies": {}}, "version-type"),
    ("bad-name", {**base, "name": "@A/b", "dependencies": {}}, "name-grammar"),
    ("bad-version", {**base, "version": "01.0.0", "dependencies": {}}, "strict-semver"),
    ("dependencies-null", {**base, "dependencies": None}, "dependency-object"),
    ("dependencies-array", {**base, "dependencies": []}, "dependency-object"),
    ("dependencies-string", {**base, "dependencies": "*"}, "dependency-object"),
    ("dependency-name", {**base, "dependencies": {"@A/b": "*"}}, "dependency-name"),
    ("dependency-value", {**base, "dependencies": {"@c/d": 1}}, "dependency-string"),
    ("dependency-object", {**base, "dependencies": {"@c/d": {"version": "1.0.0"}}}, "dependency-string"),
    ("dependency-range", {**base, "dependencies": {"@c/d": ">=1.0.0"}}, "requirement-grammar"),
    ("root-array", [], "manifest-object"), ("root-null", None, "manifest-object"),
]:
    manifest.append(case(id, raw(value), False, rule))
for suffix, version in [("empty-prerelease", "1.0.0-"), ("empty-build", "1.0.0+")]:
    manifest.append(case(f"version-{suffix}", raw({**base, "version": version}), False, "strict-semver"))
    for form, prefix in [("exact", ""), ("caret", "^"), ("tilde", "~")]:
        manifest.append(case(f"dependency-{form}-{suffix}", raw({**base, "dependencies": {"@c/d": prefix + version}}), False, "requirement-grammar"))
for id, value in [
    ("duplicate-name", '{"name":"@a/b","name":"@c/d","version":"1.0.0","dependencies":{}}'),
    ("duplicate-name-escaped", '{"name":"@a/b","na\\u006de":"@c/d","version":"1.0.0","dependencies":{}}'),
    ("duplicate-version", '{"name":"@a/b","version":"1.0.0","version":"2.0.0","dependencies":{}}'),
    ("duplicate-dependencies", '{"name":"@a/b","version":"1.0.0","dependencies":{},"dependencies":{}}'),
    ("duplicate-dependency", '{"name":"@a/b","version":"1.0.0","dependencies":{"@c/d":"*","@c/d":"^1.0.0"}}'),
    ("duplicate-dependency-escaped", '{"name":"@a/b","version":"1.0.0","dependencies":{"@c/d":"*","@c\\u002fd":"^1.0.0"}}'),
]:
    manifest.append(case(id, value, False, "duplicate-decoded-key"))
manifest += [case("trailing-data", raw(base) + " false", False, "json-syntax"),
             case("trailing-comma", '{"name":"@a/b","version":"1.0.0",}', False, "json-syntax")]
for n in [256, 257]:
    manifest.append(case(f"dependencies-{n}", raw({**base, "dependencies": {f"@d/p{i:03}": "*" for i in range(n)}}), n == 256, "dependency-count"))
for n in [1048576, 1048577]:
    manifest.append(case(f"bytes-{n}", concat(raw({**base, "dependencies": {}}), repeat(" ", n - len(raw({**base, "dependencies": {}})))), n == 1048576, "manifest-byte-limit", **({"dependencies": {}} if n == 1048576 else {})))
write("manifests", "manifest", manifest)

locked = {"name": "@a/b", "version": "1.0.0", "source": "file:fixture", "path": "fixture", "integrity": "sha256-" + "a" * 64, "interface": "b" * 64}
locks = [case("empty", raw({"lockfileVersion": 1, "packages": []}), True, "lock-v1"),
         case("valid-record", raw({"lockfileVersion": 1, "packages": [locked]}), True, "lock-v1")]
for id, field, value in [
    ("bad-name", "name", "@A/b"), ("bad-version", "version", "1.0.0-"),
    ("empty-source", "source", ""), ("absolute-path", "path", "/fixture"),
    ("drive-path", "path", "C:/fixture"), ("parent-path", "path", "../fixture"),
    ("empty-path-part", "path", "a//fixture"), ("dot-path-part", "path", "a/./fixture"),
    ("bad-integrity", "integrity", "sha256-wrong"), ("bad-interface", "interface", "wrong"),
    ("unknown-record-field", "extra", "value"),
]:
    locks.append(case(id, raw({"lockfileVersion": 1, "packages": [{**locked, field: value}]}), False, "locked-record"))
locks.append(case("duplicate-record", raw({"lockfileVersion": 1, "packages": [locked, locked]}), False, "duplicate-locked-name"))
locks.append(case("unknown-field", raw({"lockfileVersion": 1, "packages": [], "extra": 0}), False, "unknown-field"))
locks.append(case("duplicate-field", '{"lockfileVersion":1,"lockfileVersi\\u006fn":1,"packages":[]}', False, "duplicate-decoded-key"))
for id, value in [("decimal-version", "1.0"), ("exponent-version", "1e0")]:
    locks.append(case(id, '{"lockfileVersion":' + value + ',"packages":[]}', False, "lock-version"))
write("locks", "lock", locks)

paths = []
for id, value in [("root", ["main.dew"]), ("nested", ["src/a.dew", "src/z/b_test.dew"]),
                  ("utf8", ["src/caf\u00e9.dew"]), ("case-sensitive", ["a.dew", "A.dew"]),
                  ("not-prefix", ["a.dew", "a.dewx/b.dew"])]:
    paths.append(case(id, value, True, "logical-source-path"))
for id, value, rule in [
    ("empty-set", [], "file-count"), ("empty", [""], "path-segments"),
    ("absolute", ["/main.dew"], "relative-path"),
    ("windows-absolute", ["C:/main.dew"], "relative-path"),
    ("backslash", ["src\\main.dew"], "slash-path"), ("nul", ["src/a\0.dew"], "path-nul"),
    ("empty-segment", ["src//a.dew"], "path-segments"), ("dot", ["./a.dew"], "path-segments"),
    ("dot-inner", ["src/./a.dew"], "path-segments"), ("dotdot", ["src/../a.dew"], "path-segments"),
    ("trailing-slash", ["a.dew/"], "path-segments"), ("not-dew", ["src/a.txt"], "source-extension"),
    ("uppercase-extension", ["src/a.DEW"], "source-extension"),
    ("manifest-file", ["dew.json"], "source-extension"),
    ("manifest-prefix", ["dew.json/a.dew"], "reserved-manifest-prefix"),
    ("duplicate", ["a.dew", "a.dew"], "duplicate-path"),
    ("prefix-forward", ["a.dew", "a.dew/b.dew"], "path-prefix-conflict"),
    ("prefix-reverse", ["a.dew/b.dew", "a.dew"], "path-prefix-conflict"),
    ("prefix-deep", ["a.dew/x/b.dew", "z.dew", "a.dew"], "path-prefix-conflict"),
]:
    paths.append(case(id, value, False, rule))
paths += [case("bytes-4096", [concat(repeat("a", 4092), ".dew")], True, "path-byte-limit"),
          case("bytes-4097", [concat(repeat("a", 4093), ".dew")], False, "path-byte-limit"),
          case("utf8-bytes-4096", [concat(repeat("\u00e9", 2046), ".dew")], True, "path-byte-limit"),
          case("utf8-bytes-4098", [concat(repeat("\u00e9", 2047), ".dew")], False, "path-byte-limit")]
write("artifact-paths", "artifact-paths", paths)

# Filesystem entries are relative to one fresh package root. Symlinks are explicit.
def f(path): return {"type": "file", "path": path, "text": "pub fn value() -> I32 { 1 }\n"}
def d(path): return {"type": "directory", "path": path}
def link(path, target): return {"type": "symlink", "path": path, "target": target}
def selection(id, tree, compile, artifact):
    return case(id, {"entries": tree}, True, "conventional-sources", compiler=compile, artifact=artifact)
source = [
    selection("root-fallback", [f("z.dew"), f("a.dew"), f("a_test.dew"), f("nested/no.dew")], ["a.dew", "z.dew"], ["a.dew", "a_test.dew", "z.dew"]),
    selection("src-recursive", [f("root.dew"), f("src/z.dew"), f("src/a/n.dew"), f("src/a_test.dew")], ["src/a/n.dew", "src/z.dew"], ["src/a/n.dew", "src/a_test.dew", "src/z.dew"]),
    selection("src-regular-file", [f("src"), f("main.dew")], ["main.dew"], ["main.dew"]),
    selection("directory-with-dew-suffix", [d("x.dew"), f("main.dew")], ["main.dew"], ["main.dew"]),
    # Global byte order differs from depth-first entry order at a directory prefix.
    selection("global-logical-sort", [f("src/a/z.dew"), f("src/a.dew")], ["src/a.dew", "src/a/z.dew"], ["src/a.dew", "src/a/z.dew"]),
]
for id, tree in [
    ("no-sources", [f("README.md")]), ("empty-src-no-fallback", [d("src"), f("main.dew")]),
    ("symlink-source", [f("src/a.dew"), link("src/b.dew", "a.dew")]),
    ("symlink-directory", [f("src/a.dew"), link("src/sub", ".")]),
    ("symlink-src-root", [f("other/a.dew"), link("src", "other")]),
    ("symlink-root-source", [f("main.dew"), link("other.dew", "main.dew")]),
    ("symlink-escape", [f("main.dew"), link("src", "../outside")]),
]:
    source.append(case(id, {"entries": tree}, False, "reject-symlink" if "symlink" in id else "source-required"))
write("source-selection", "source-selection", source)

# Numeric preflight inputs avoid large allocations during the timing hold.
budgets = []
for field, maximum in [("dependencyCount", 256), ("fileCount", 65536), ("sourceBytes", 16777216)]:
    for n in [maximum, maximum + 1]:
        budgets.append(case(f"{field}-{n}", {field: n}, n == maximum, "artifact-count-or-source-bound"))
budgets.append(case("zero-files", {"fileCount": 0}, False, "file-count"))
for policy, maximum in [("publish", 67108864), ("local", 268435456)]:
    for n in [maximum, maximum + 1]:
        budgets.append(case(f"{policy}-{n}", {"policy": policy, "encodedBytes": n}, n == maximum, "encoded-artifact-policy"))
budgets.append(case("local-above-publish", {"policy": "local", "encodedBytes": 67108865}, True, "distinct-local-cap"))
write("artifact-budgets", "artifact-budget", budgets)
(ROOT / "limits.json").write_text(json.dumps({
    "schemaVersion": 1, "nameBytes": 255, "semverBytes": 255, "requirementBytes": 2048,
    "manifestBytes": 1048576, "directDependencies": 256, "logicalPathBytes": 4096,
    "sourceBytes": 16777216, "publishEncodedBytes": 67108864,
    "localArtifactEncodedBytes": 268435456, "files": 65536,
    "semverNumericMax": 4294967295,
}, indent=2) + "\n")
