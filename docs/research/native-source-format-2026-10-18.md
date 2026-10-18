# Native source format

Date: 2026-10-18.

Run `moon fmt src/parser src/semantic src/backend src/cache_binary src/standard_sources`
after the language improvements. This applies the current MoonBit source format.
It does not change behavior. The command took 0.498 seconds.

Run `moon info src/parser src/semantic` to update the package interfaces. This
adds the parser's internal admission type to the generated interface. The
command took 1.087 seconds and reported no errors. Existing promotion warnings
remain visible.

A final format and interface pass took 1.502 seconds after the review fixes.
The generated tokenizer interface now matches the existing keyword and JSON
declarations in its source. The pass also formats the new flow, operator, and
recovery tests. The command and full output are in the final validation record.
It reported no errors.
