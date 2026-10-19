# Expanded-source editor view

`tools/dew build --emit expanded` writes version 1 JSON before generated-code
checking or Wasm planning. Each module retains logical file paths and exact
UTF-8 source text. Generated files carry their original function site and byte
ranges for top-level declarations. These are declaration origins, not token
source maps. Original file names that contain the generated suffix are not
classified as generated when the full original path matches.

The shared expansion driver handles bounded late import closure. An editor can
inspect output even when a generated function has a later type error.

Checks: native driver regression 1/1 passed in 8.960 seconds; CLI build 4.671
seconds; CLI output 1.109 seconds. The public declarations example wrote 8,480
bytes of JSON. A separate JSON check read every generated range, checked bounds
against UTF-8 bytes, checked the original function origin, and found the new
`generated` function. The CLI uses the native compiler path; this does not add
an expanded-source output kind to the Wasm compile-request codec.
