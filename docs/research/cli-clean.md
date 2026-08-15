# Dew clean command

Date: 2026-08-11

`dew clean` removes all managed build artifacts. These are the configured Dew cache, MoonBit `_build`, `target`, `.tmp`, and the legacy `.dew-cache`. The cache includes frozen standard/dependency interfaces, compiler packs, whole-build outputs, and installed package capsules. The default cache is `.dew/cache`; `DEW_CACHE_DIR` selects an alternative. Cleaning the default cache leaves the parent `.dew` metadata directory intact. Explicit `-o` output paths are user-owned files and are not removed.

`dew clean --dry-run` reports every selected path without changing it. Repeated clean operations are idempotent and report an already-clean workspace. Unknown or duplicate options fail visibly.

Safety checks refuse filesystem root, the user's home directory, the Dewdrop root, the configured working directory, and any selected ancestor of those paths. A selected path that is a symlink is unlinked without recursively deleting its target. Regular files at managed paths are removed as corrupt build state; directories are removed recursively.
