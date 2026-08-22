# Self-host fixed-point harness

Date: 2026-08-22

`tools/check-self-host-bootstrap.sh` now owns the complete fixed-point sequence:

1. MoonBit Dewdrop builds compiler A with the pinned Starshine provider.
2. The bootstrap fixture writes the full source request in stage A's physical directory.
3. A builds compiler B.
4. The same logical inputs are written in stage B's physical directory.
5. B builds compiler C.
6. A, B, and C are validated.
7. B and C are compared byte-for-byte.
8. Separate B and C SHA-256 digests are printed.

Each stage uses a separate directory. Persistent build caches are disabled by the request and by the A build command.

The harness is complete, but it does not pass yet. Compiler A currently traps during full-source body inference before B is emitted. The smoke pipeline remains green.
