# Direct tail-call optimization

Date: 2026-08-11

The whole-program optimization pass marks exact non-generic, receiver-free self calls that occur in structural tail position through function roots, block tails, explicit returns, `if` branches, and match arms when the callable result and every local use scalar carriers. It now also marks direct calls to different local callables when those calls are terminal results of `if` branches or match arms and the caller/target result carriers agree. The WasmGC backend emits WebAssembly Core 3 `return_call` for those sites. Non-tail and reference-carrier callables remain ordinary `call` operations.

Branch conditions, match scrutinees, and argument expressions retain the existing lowering, so they evaluate exactly once in source order before the tail transfer. Direct calls at a function root remain ordinary calls unless they are self-recursive; this preserves transparent-wrapper directization and avoids turning every forwarding wrapper into contractual WAT churn. Generic calls, methods/receivers, compiler-owned helpers, imported targets without a local scalar-body proof, callbacks, reference-carrier signatures/locals, and calls nested under arithmetic or other value-producing operators remain deliberately unoptimized. The reference restriction preserves cross-runtime parity: focused scalar tail calls execute in Node and Wago, while Wago's current Core 3 path mis-executes `return_call` in several WasmGC collection helpers with reference carriers.

The recursion runtime snapshot executes 100,000 tail-recursive steps in both Node and Wago Core 3 while retaining a separate ordinary non-tail recursive function. The branch snapshots cover `if` and Boolean-match arms, source-order trapping conditions/arguments, and a focused allocation-free WAT budget with four `return_call` sites. Tail-call reachability, specialization, program linking, physical linking, and backend scratch/cast planning all treat `PlannedTailCall` as the direct-call shape it refines.

`tools/benchmark-tail-recursion.py` measured 128 steps over 10,000 warmed Node 26.3.0 samples:

| Form | Median | Wasm bytes |
| --- | ---: | ---: |
| optimized tail recursion | 0.130 µs | 452 |
| functional while | 0.080 µs | 482 |

A current rerun measured tail recursion at 0.101 µs versus 0.080 µs for the functional loop (1.2625x), while retaining the 452-byte versus 482-byte size result and completing the separate 100,000-step depth check without stack growth. The new branch comparison measured 0.080 µs for two branch `return_call` sites versus 0.061 µs for deliberately non-tail `+ 0` branches (1.3115x), with 507 versus 513 Wasm bytes. These host-call-scale timings show no runtime win; the accepted benefit is bounded stack transfer and a small static reduction. Explicit functional loops remain preferable in hand-written hot recursion.
