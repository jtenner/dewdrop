# Starshine Core Wasm-GC guest

`src/starshine_guest` exports `module_new` with the concrete Starshine `Module` GC type.

Build it from the repository root:

```sh
./scripts/build-starshine-guest.sh
```

The script validates the release artifact before it replaces `starshine-guest.wasm`. It removes temporary and build files after a successful copy.
