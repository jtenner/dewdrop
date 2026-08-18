# Starshine FFI consumer

`ffi.dew` is generated from the function exports in the pinned raw Core WasmGC provider.

Generate it after building Starshine:

```sh
tools/starshine-ffi.sh build
python3 tools/generate_starshine_ffi_consumer.py
```

Check it:

```sh
python3 tools/generate_starshine_ffi_consumer.py --check
tools/dew check self_host/starshine/ffi.dew self_host/starshine/smoke.dew
```

The bindings use exact Wasm carrier types. A MoonBit newtype can use the same Wasm carrier as a Dew primitive. Keep its constructor call. For example, call `I32::new` before `Instruction::i32_const`, as shown in `smoke.dew`.

`ffi-bindings.json` records every function export. All 3,350 exports are bound. Nullable WasmGC references use `NullableRef<StarshineRefN>`.
