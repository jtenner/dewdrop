# Wave 1 item 10

Base: `4a35c1d75d434056c5efee34aec4ea4e9d171e29`.
Test checkpoint: two new tests specify bounded buffered byte records.
The API is absent at this checkpoint; tests are not yet run.

Contract: `BufferedReader::new(reader, chunk_limit, max_buffer)` owns one
unread chunk. `read_until(delimiter: U8, max_bytes)` returns
`Result<Option<Bytes>, IoError>` and retains the delimiter. `read_line`
uses LF and removes LF only (CR stays). Empty input returns None; an empty
line returns Some(empty). No UTF-8 decoding occurs. Bounds include the
retained delimiter. Errors consume the partial record; unread suffix stays.
