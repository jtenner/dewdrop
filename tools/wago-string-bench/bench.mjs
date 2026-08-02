import { readFile } from "node:fs/promises";
import { performance } from "node:perf_hooks";

const wasm = await readFile(new URL("./string_bench.wasm", import.meta.url));
const { instance } = await WebAssembly.instantiate(wasm, {});
const iterations = Number(process.env.DEW_STRING_BENCH_ITERATIONS ?? 100000);
const warmup = Number(process.env.DEW_STRING_BENCH_WARMUP ?? 20000);
const samples = Number(process.env.DEW_STRING_BENCH_SAMPLES ?? 15);
const expected = new Map([
  ["identity", 0],
  ["flat_scan", 29],
  ["view_create", 36],
  ["view_scan", 29],
  ["string_slice_scan", 29],
  ["bytes_subarray_create", 36],
  ["bytes_slice_copy", 36],
  ["string_concat_create", 36],
  ["string_concat_view_create", 36],
  ["bytes_find_byte_present", 63],
  ["bytes_find_byte_absent", 1],
  ["bytes_find_substring_present", 113],
  ["bytes_find_substring_absent", 1],
  ["bytes_find_long_substring_present", 96],
  ["bytes_find_long_substring_absent", 1],
  ["string_find_string", 15],
  ["string_find_view", 15],
  ["string_view_find_view", 15],
  ["string_view_find_string", 15],
  ["string_prefix_view", 1],
  ["string_view_suffix_string", 1],
  ["bytes_prefix_match", 1],
  ["bytes_suffix_match", 1],
  ["bytes_concat_create", 36],
  ["repeated_string_concat", 32],
  ["exact_builder_concat", 32],
  ["view_copy_scan", 29],
  ["builder_scalars", 16],
  ["builder_checked_bytes", 22],
  ["builder_fragments", 141],
  ["bytes_builder_fragments", 96],
]);

for (const [name, increment] of expected) {
  const fn = instance.exports[name];
  if (typeof fn !== "function") throw new Error(`missing export ${name}`);
  if (Number(fn(0)) !== increment) {
    throw new Error(`${name}: expected increment ${increment}`);
  }
  let checksum = 0;
  for (let index = 0; index < warmup; index++) checksum = fn(checksum >>> 0);
  const timings = [];
  for (let sample = 0; sample < samples; sample++) {
    if (typeof globalThis.gc === "function") globalThis.gc();
    const start = performance.now();
    for (let index = 0; index < iterations; index++) checksum = fn(checksum >>> 0);
    const elapsed = performance.now() - start;
    timings.push(elapsed * 1e6 / iterations);
  }
  timings.sort((left, right) => left - right);
  const median = timings[Math.floor(timings.length / 2)];
  const low = timings[0];
  const high = timings[timings.length - 1];
  console.log(
    `${name} median_ns=${median.toFixed(2)} min_ns=${low.toFixed(2)} ` +
    `max_ns=${high.toFixed(2)} checksum=${checksum >>> 0}`,
  );
}
