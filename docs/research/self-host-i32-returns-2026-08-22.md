# Self-host I32 returns

Date: 2026-08-22

The linked I32 emitter now writes an explicit Wasm `return` for every lowered return item.

This makes early returns valid inside nested branch bodies. The branch result remains valid because the return path is unreachable after the return instruction.

The smoke program now returns early from the then branch of an I32 `if`, then calls that function from `main`.

The focused compiler build, Starshine validation, and output validation pass. The full self-host smoke remains the commit gate.
