# Self-host linked smoke emission

Date: 2026-08-22

The self-host driver no longer reparses the root source through the separate bounded smoke parser before emission.

For the current smoke subset, output now comes from the production artifacts:

```text
compile request
→ semantic program plan
→ specialization
→ WasmGC fragments
→ physical program link
→ linked root `main` body
→ Starshine module encoding
```

The linked smoke emitter resolves the root module, finds its selected `main` declaration and body, follows its planned block tail, reads the lowered `PlannedI32Const`, and emits that value. Invalid or unsupported linked roots return explicit errors.

This removes the temporary parser-to-emitter bypass. The emitted instruction subset is still one `I32` constant function; complete body instruction emission remains required before the compiler can build itself.
