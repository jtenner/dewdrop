# Wave 1 item 11: Process Writer

Base: `8dc8bdf406733f8a29662f28c68528276870b0de`.
Test checkpoint: ten new tests; not run yet. The module is absent, so these
are expected to fail until implementation. No baseline changes.

Contract: `process_stdout(p)` and `process_stderr(p)` return a Writer that
keeps the given Process and channel. A direct write forwards once. Use
`io_write_all` for complete writes. Empty complete writes make no Process call.
`LimitExceeded` maps to `IoError::LimitExceeded`. All other Process error kinds
map to `IoError::Backend(code)`, preserving the numeric code. Process operation
is discarded; channel identity stays in the writer. No host imports are needed
for a mock Process. No global Process is created.
