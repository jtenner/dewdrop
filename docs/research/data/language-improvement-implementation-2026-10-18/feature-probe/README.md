Run from the repository root after a fresh A/B/C bootstrap:

```sh
python3 docs/research/data/language-improvement-implementation-2026-10-18/feature-probe/run.py \
  .tmp/self-host-bootstrap/c/compiler.wasm \
  .tmp/self-host-bootstrap/a/request.bin
```

An optional third argument selects the output folder. Otherwise the driver makes
an isolated temporary folder. It pins the supplied compiler and request before
use, retains the request's provider/configuration/fingerprint tail unchanged,
and replaces only the request header and source modules. It retains the matching
standard module sources and adds `dew.std.text`/`dew.std.iter` when absent, with
the bootstrap import policy. No binary artifact is part of this evidence packet.

The positive program must compile and return 42. It checks Option/Result callback
helpers and lazy fallbacks, checked integer conversions, StringView decimal
boundaries and error positions, nested Bool/enum patterns, iterator folding,
and generic private-field factories/getters across two user modules. The
negative program must report a missing imported construction field and write no
output. Any host function call from the positive output throws.

Each subprocess has a 28-second limit. The driver records commands, times,
statuses, full logs, source hashes, and compiler/template hashes in the output
folder's `validation.json`. The two `*-request.json` files record the exact
module sources and preserved tail hash. A failed positive compile remains a
failure; the independent negative check still runs.

This driver does not build the native compiler or run the A/B/C bootstrap. Its
supplied C compiler and A request must come from the same bootstrap run. A
patched compiler check is distinct from a complete current-source fixed point.

`patched-validation.json` is the completed check with the three-file patched C
compiler described in the lambda, nested-number-pattern, and generic-loop notes.
It is not the final whole-current-source A/B/C result.
