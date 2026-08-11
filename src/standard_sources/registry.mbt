///|
pub fn standard_source_paths() -> Array[String] {
  let paths = [
    "std/preamble/00-builtins.dew", "std/preamble/10-traits.dew", "std/preamble/20-i32.dew",
    "std/preamble/30-packed.dew", "std/preamble/40-numeric-builtins.dew", "std/preamble/50-numeric-impls.dew",
    "std/preamble/60-memory.dew", "std/preamble/70-into-builtins.dew", "std/preamble/80-into-impls.dew",
    "std/preamble/90-swar-core.dew", "std/preamble/100-v128.dew", "std/preamble/110-debug.dew",
    "std/option.dew", "std/result.dew", "std/fixed_array.dew", "std/array.dew", "std/map.dew",
    "std/set.dew", "std/collections/stack.dew", "std/text_runtime.dew", "std/string.dew",
    "std/string_builder.dew", "std/bytes_builder.dew", "std/bytes.dew", "std/wasi.dew",
    "std/wasm/intrinsics.dew",
  ]
  for
    name in [
      "i8x4", "u8x4", "i16x2", "u16x2", "i8x8", "u8x8", "i16x4", "u16x4", "i32x2",
      "u32x2", "i8x16", "u8x16", "i16x8", "u16x8", "i32x4", "u32x4", "i64x2", "u64x2",
      "f32x4", "f64x2",
    ] {
    paths.push("std/" + name + ".dew")
  }
  paths
}

///|
pub fn bootstrap_standard_source(path : String) -> Bytes? {
  match path {
    "std/preamble/00-builtins.dew" => Some(standard_preamble_builtins_source())
    "std/preamble/10-traits.dew" => Some(standard_preamble_traits_source())
    "std/preamble/20-i32.dew" => Some(standard_preamble_i32_source())
    "std/preamble/30-packed.dew" => Some(standard_preamble_packed_source())
    "std/preamble/40-numeric-builtins.dew" =>
      Some(standard_numeric_builtins_source())
    "std/preamble/50-numeric-impls.dew" => Some(standard_numeric_impls_source())
    "std/preamble/60-memory.dew" => Some(standard_memory_preamble_source())
    "std/preamble/70-into-builtins.dew" => Some(standard_into_builtins_source())
    "std/preamble/80-into-impls.dew" => Some(standard_into_impls_source())
    "std/preamble/90-swar-core.dew" => Some(standard_swar_preamble_source())
    "std/preamble/100-v128.dew" => Some(standard_v128_preamble_source())
    "std/preamble/110-debug.dew" => Some(standard_debug_preamble_source())
    "std/option.dew" => Some(standard_option_source())
    "std/result.dew" => Some(standard_result_source())
    "std/fixed_array.dew" => Some(standard_fixed_array_source())
    "std/array.dew" => Some(standard_array_source())
    "std/map.dew" => Some(standard_map_source())
    "std/set.dew" => Some(standard_set_source())
    "std/collections/stack.dew" => Some(standard_stack_source())
    "std/text_runtime.dew" => Some(standard_text_sources()[0])
    "std/string.dew" => Some(standard_text_sources()[1])
    "std/string_builder.dew" => Some(standard_text_sources()[2])
    "std/bytes_builder.dew" => Some(standard_text_sources()[3])
    "std/bytes.dew" => Some(standard_text_sources()[4])
    "std/wasi.dew" => Some(standard_wasi_source())
    "std/wasm/intrinsics.dew" => Some(standard_wasm_intrinsics_source())
    _ => {
      let lanes = standard_lane_sources()
      let names = [
        "std/i8x4.dew", "std/u8x4.dew", "std/i16x2.dew", "std/u16x2.dew", "std/i8x8.dew",
        "std/u8x8.dew", "std/i16x4.dew", "std/u16x4.dew", "std/i32x2.dew", "std/u32x2.dew",
        "std/i8x16.dew", "std/u8x16.dew", "std/i16x8.dew", "std/u16x8.dew", "std/i32x4.dew",
        "std/u32x4.dew", "std/i64x2.dew", "std/u64x2.dew", "std/f32x4.dew", "std/f64x2.dew",
      ]
      for index, name in names {
        if path == name {
          return Some(lanes[index])
        }
      }
      None
    }
  }
}
