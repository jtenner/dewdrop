# Faster native tools during compiler development

`DEW_HARDENING_NATIVE_PROFILE=debug tools/test-self-host-hardening.sh` builds the
native fixture tools in debug mode. The default remains release. Invalid profile
values are errors. This switch does not disable Dew optimization, assertions,
validation, tests, or emission checks.

A native semantic edit required about 89 seconds to rebuild release C tools.
Debug tool rebuilds took about 9 seconds. A cold debug hardening run took 40.214
seconds; a subsequent run took 29.294 seconds. The cold total and release rebuild
still exceed the repository's 30-second compiler-work budget and remain
performance defects.
