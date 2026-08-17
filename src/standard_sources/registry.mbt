///|
pub fn standard_source_paths() -> Array[String] {
  let paths = [
    "std/preamble/00-builtins.dew", "std/preamble/10-traits.dew", "std/preamble/20-i32.dew",
    "std/preamble/30-packed.dew", "std/preamble/40-numeric-builtins.dew", "std/preamble/50-numeric-impls.dew",
    "std/preamble/60-memory.dew", "std/preamble/70-into-builtins.dew", "std/preamble/80-into-impls.dew",
    "std/preamble/90-swar-core.dew", "std/preamble/100-v128.dew", "std/preamble/110-debug.dew",
    "std/option.dew", "std/result.dew", "std/fixed_array.dew", "std/array.dew", "std/map.dew",
    "std/set.dew", "std/collections/stack.dew", "std/queue.dew", "std/collections/circular_buffer.dew",
    "std/collections/deque.dew", "std/ordering.dew", "std/collections/binary_heap.dew",
    "std/collections/priority_queue.dew", "std/collections/red_black_tree.dew", "std/collections/ordered_map.dew",
    "std/collections/ordered_set.dew", "std/show.dew", "std/disposable.dew", "std/iter.dew",
    "std/math.dew", "std/io.dew", "std/testing.dew", "std/json.dew", "std/encode.dew",
    "std/decode.dew", "std/format.dew", "std/semver.dew", "std/package.dew", "std/package/artifact.dew",
    "std/bloom_filter.dew", "std/blake3.dew", "std/integrity/sha256.dew", "std/path.dew",
    "std/fs.dew", "std/process.dew", "std/fs/wasi.dew", "std/fs/wpsi.dew", "std/process/wasi.dew",
    "std/process/wpsi.dew", "std/text_runtime.dew", "std/string.dew", "std/string_fixed_array.dew",
    "std/string_builder.dew", "std/bytes_builder.dew", "std/bytes.dew", "std/text.dew",
    "std/encoding/utf8.dew", "std/wasm/wasi.dew", "std/wasi.dew", "std/wasm/intrinsics.dew",
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
    "std/queue.dew" => Some(standard_queue_source())
    "std/collections/circular_buffer.dew" =>
      Some(standard_circular_buffer_source())
    "std/collections/deque.dew" => Some(standard_deque_source())
    "std/ordering.dew" => Some(standard_ordering_source())
    "std/collections/binary_heap.dew" => Some(standard_binary_heap_source())
    "std/collections/priority_queue.dew" =>
      Some(standard_priority_queue_source())
    "std/collections/red_black_tree.dew" =>
      Some(standard_red_black_tree_source())
    "std/collections/ordered_map.dew" => Some(standard_ordered_map_source())
    "std/collections/ordered_set.dew" => Some(standard_ordered_set_source())
    "std/show.dew" => Some(standard_show_source())
    "std/disposable.dew" => Some(standard_disposable_source())
    "std/math.dew" => Some(standard_math_source())
    "std/io.dew" => Some(standard_io_source())
    "std/testing.dew" => Some(standard_testing_source())
    "std/json.dew" => Some(standard_json_source())
    "std/encode.dew" => Some(standard_encode_source())
    "std/decode.dew" => Some(standard_decode_source())
    "std/format.dew" => Some(standard_format_source())
    "std/semver.dew" => Some(standard_semver_source())
    "std/package.dew" => Some(standard_package_source())
    "std/package/artifact.dew" => Some(standard_package_artifact_source())
    "std/bloom_filter.dew" => Some(standard_bloom_filter_source())
    "std/blake3.dew" => Some(standard_blake3_source())
    "std/integrity/sha256.dew" => Some(standard_sha256_source())
    "std/path.dew" => Some(standard_path_source())
    "std/fs.dew" => Some(standard_fs_source())
    "std/process.dew" => Some(standard_process_source())
    "std/fs/wasi.dew" => Some(standard_fs_wasi_source())
    "std/fs/wpsi.dew" => Some(standard_fs_wpsi_source())
    "std/process/wasi.dew" => Some(standard_process_wasi_source())
    "std/process/wpsi.dew" => Some(standard_process_wpsi_source())
    "std/iter.dew" => Some(standard_iter_source())
    "std/text_runtime.dew" => Some(standard_text_sources()[0])
    "std/string.dew" => Some(standard_text_sources()[1])
    "std/string_fixed_array.dew" => Some(standard_string_fixed_array_source())
    "std/string_builder.dew" => Some(standard_text_sources()[2])
    "std/bytes_builder.dew" => Some(standard_text_sources()[3])
    "std/bytes.dew" => Some(standard_text_sources()[4])
    "std/text.dew" => Some(standard_text_iteration_source())
    "std/encoding/utf8.dew" => Some(standard_utf8_source())
    "std/wasm/wasi.dew" => Some(standard_wasm_wasi_source())
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
