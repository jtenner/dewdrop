# Wave 1 item 12: bounded directory pages

Base: `8dc8bdf406733f8a29662f28c68528276870b0de`.
Branch: `worker/wave1-item-12`. No B-tree edits, SDK changes, or push.

Test checkpoint: three new tests specify empty pages, limits, truncated records,
relative names, link metadata, cookies, and explicit end state. This checkpoint
is red: `dew.std.fs.directory` does not yet exist. No compiler run yet.

Contract: a separate DirectoryReader trait leaves FileSystem unchanged. Pages
have at most 2048 records and at most 49152 encoded bytes. A zero-length host
read means end. A full buffer or a count stop means more. A partial final record
returns prior progress, or PartialRecord if there is none. Names are validated
UTF-8 single path parts; dot entries are skipped. Links are returned as data.
All opened handles must close on all paths. Each WASI path part uses no-follow.
