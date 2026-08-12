# Dew clean command

Date: 2026-08-11

`dew clean` removes the complete configured Dew cache, including frozen standard/dependency interfaces and installed package capsules. The default target is `.dew/cache` under the Dewdrop root; `DEW_CACHE_DIR` selects an alternative. Cleaning the default cache leaves the parent `.dew` metadata directory intact.

`dew clean --dry-run` reports the exact path without changing it. Repeated clean operations are idempotent and report an already-clean cache. Unknown or duplicate options fail visibly.

Safety checks refuse filesystem root, the user's home directory, the Dewdrop root, and the configured working directory. A cache path that is itself a symlink is unlinked without recursively deleting its target. Regular cache files are removed as corrupt cache state; directories are removed recursively.
