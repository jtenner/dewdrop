# Native source format

Date: 2026-10-18.

Run `moon fmt src/parser src/semantic src/backend src/cache_binary src/standard_sources`
after the language improvements. This applies the current MoonBit source format.
It does not change behavior. The command took 0.498 seconds.

Run `moon info src/parser src/semantic` to update the package interfaces. This
adds the parser's internal admission type to the generated interface. The
command took 1.087 seconds and reported no errors. Existing promotion warnings
remain visible.
