# Parse-cache owner path boundaries

## Confirmed fault

The parse-cache owner was `"file:" + module_path + ":" + file_path`.
These distinct path pairs had the same owner, `file:a:b:c.dew`:

| Module path | File path |
| --- | --- |
| `a` | `b:c.dew` |
| `a:b` | `c.dew` |

The manifest constructor accepts these paths. The compile-request validator
allows colons in module names and normalized relative file paths.

This caused two failures:

- Storing both files in a new pack replaced the first entry. Warm reads kept
  missing because each new store removed the other file's saved entry.
- After saving the first file and opening that pack, storing the second file
  and then reading the first loaded two entries with one owner. Saving failed
  with `artifact pack contains duplicate section owners`.

The context digest already uses length-prefixed paths. It prevents a wrong
context from giving a cache hit. It did not prevent owner replacement or the
duplicate-owner save error.

## Fix

The owner is now
`file-paths-v1:<module string length>:<module path><file path>`.
The module string length preserves the path boundary even when either string
contains a colon. The new prefix is separate from old `file:` owners. Old
entries become misses. The pack codec and version stay at 1.

This changes only parse-cache owner construction. It adds no hashing or byte
copies to that function. General pack replacement and lookup rules stay the
same.

### Retained entries and cleanup

The pack has no remove-owner API. When a shallow file becomes too deep to cache,
the writer skips the new entry. The last shallow entry stays in that pack.
Content and context checks prevent it from matching the changed file. More deep
edits do not append entries. A later cacheable edit replaces the current owner's
entry. Under the compiler's normal store path, this is at most one stale entry
per current file owner in a pack.

The owner-prefix change can also retain one old `file:` entry per old owner.
There is one old prefix and one current prefix in this change. The limit is per
owner and prefix in one pack, not a bound on the whole cache directory or future
format changes. Packs for removed module graphs can also stay on disk.

Safe owner removal would need a new pack operation that checks exact owner
strings in lazy indexes and updates both loaded and indexed entries. There is
no cheap existing removal call. This change keeps that work out of cache
admission and documents the bounded retained entry.

To reclaim the pack files, run this from the project root:

```sh
rm -f -- "${DEW_CACHE_DIR:-.dew/cache}"/packs/v1-*.dwp
```

This removes pack cache data. The next builds create fresh packs. Source files
are unchanged. A caller can instead delete only the selected `.dwp` file.

## Validation

The isolated native proof used cache pack sources from commit
`7ac4abc716079c85d1db6f521f57c44d1e718acd`. Both runs used the same pack code.
Only the owner function changed. The old owner failed both cases in 0.285
seconds: the pack had one entry instead of two, and the saved-pack reuse case
reported the exact duplicate-owner error. The new owner passed both cases in
0.278 seconds. These times include build work and tests. No compiler activity
exceeded 30 seconds.

The loader tests in `src/standard_loader/parse_event_cache_wbtest.mbt` exercise
the actual parse-cache path. They check cold stores, warm hits, saved-pack
reopening, preserved parse events, and strict pack validation after reuse.

Run the loader tests with:

```sh
DEW_NATIVE_TEST_PACKAGES=standard_loader tools/test-native.sh
```

The [evidence directory](data/cache-owner-boundaries-2026-10-18/) contains the
raw isolated failure and success logs, timings, source identities, owner
snapshots, and probe source. From the repository root, repeat the proof with:

```sh
python3 docs/research/data/cache-owner-boundaries-2026-10-18/reproduce.py
```

The root validation also ran the actual parse-cache owning file. All five
tests passed in 4.946 seconds, including both new cases. Full output is in
`/tmp/dewdrop-implementation-2026-10-18/validation/native-remaining.log`.
No runtime speed gain is claimed.
