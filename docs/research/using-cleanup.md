# Scoped using cleanup

Date: 2026-08-11

`using name = expression` evaluates the acquisition expression exactly once, binds the result immutably, and registers `name.dispose()` through the same lexical cleanup mechanism as `defer`. The owning module must import or open `dew.std.disposable` so ordinary coherent `Disposable` evidence is available.

The binding remains usable until its scope exits. Disposal runs exactly once in LIFO order on fallthrough, return, break, and continue, after any exit value is evaluated. Acquisition traps register no cleanup; ordinary later traps do not unwind cleanup. A disposal trap is fail-stop and prevents older pending cleanups from running.

Using dispatches the selected `Disposable.dispose` method directly inside the compiler-owned cleanup closure. This supports local and imported evidence without a finalizer runtime, dynamic table, or `call_ref` in the measured closed cases.

Current Dew references remain aliasable rather than affine. `using` guarantees one compiler-inserted disposal call for its lexical binding, but aliases are not invalidated automatically. Direct/manual double-disposal and escape diagnostics remain a separate semantic-hardening task; resource implementations should remain defensively idempotent where aliases are exposed until those diagnostics land.
