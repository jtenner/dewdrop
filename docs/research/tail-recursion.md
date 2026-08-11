# Direct tail-recursion optimization

Date: 2026-08-11

The whole-program optimization pass now marks exact non-generic, receiver-free self calls that occur in structural tail position through function roots, block tails, explicit returns, `if` branches, and match arms. The WasmGC backend emits WebAssembly Core 3 `return_call` for those sites. Non-tail recursion remains an ordinary `call`.

Argument expressions retain the existing direct-call lowering, so they evaluate exactly once in source order before the tail transfer. Generic recursion, methods/receivers, mutual recursion, callbacks, and calls nested under arithmetic or other value-producing operators remain deliberately unoptimized.

The runtime snapshot executes 100,000 tail-recursive steps in both Node and Wago Core 3 while retaining a separate ordinary non-tail recursive function. Its WAT contains exactly one `return_call` and keeps the non-tail `call` visible.

`tools/benchmark-tail-recursion.py` measured 128 steps over 10,000 warmed Node 26.3.0 samples:

| Form | Median | Wasm bytes |
| --- | ---: | ---: |
| optimized tail recursion | 0.110 µs | 452 |
| functional while | 0.080 µs | 482 |

Tail recursion measured 1.3750x the functional loop runtime but was 30 bytes smaller and completed the separate 100,000-step depth check without stack growth. The explicit functional loop remains preferable in hand-written hot code; `return_call` makes natural tail-recursive APIs safe and bounded in stack use.
