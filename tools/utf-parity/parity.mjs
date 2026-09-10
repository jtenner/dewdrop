import { readFile } from "node:fs/promises";

const wasm = await readFile(process.argv[2] ?? new URL("./utf_parity.wasm", import.meta.url));
const generated = JSON.parse(await readFile(new URL("./generated_expected.json", import.meta.url), "utf8"));
const builderExpected = JSON.parse(
  await readFile(new URL("./generated_builder_expected.json", import.meta.url), "utf8"),
);
const { instance } = await WebAssembly.instantiate(wasm, {});
const e = instance.exports;
let checks = 0;

function check(name, expected) {
  checks++;
  const actual = Number(e[name]());
  if (actual !== expected) {
    throw new Error(`${name}: expected ${expected}, got ${actual}`);
  }
}

function checkArgs(name, args, expected) {
  checks++;
  const actual = Number(e[name](...args));
  if (actual !== expected) {
    throw new Error(`${name}(${args.join(", ")}): expected ${expected}, got ${actual}`);
  }
}

function expectTrap(name) {
  checks++;
  let trapped = false;
  try {
    e[name]();
  } catch (error) {
    trapped = error instanceof WebAssembly.RuntimeError;
  }
  if (!trapped) throw new Error(`${name}: expected WebAssembly trap`);
}

for (const name of [
  "valid_empty", "valid_ascii", "valid_two", "valid_three", "valid_four",
  "valid_cross_two", "valid_cross_three", "valid_cross_four",
]) check(name, 1);

for (const name of [
  "invalid_stray", "invalid_c0", "invalid_c1", "invalid_two_truncated",
  "invalid_two_continuation", "invalid_three_overlong", "invalid_surrogate",
  "invalid_three_truncated", "invalid_four_overlong", "invalid_too_large",
  "invalid_f5", "invalid_four_truncated", "invalid_cross",
]) check(name, 0);

check("length_empty", 0);
check("length_ascii", 3);
check("length_two", 1);
check("length_three", 1);
check("length_four", 2);
check("length_mixed", 4);
check("byte_length_string", 7);
check("byte_length_bytes", 3);
check("string_bytes_shared", 11);
check("string_utf16_units", 4);

for (const name of [
  "bytes_equal_empty", "bytes_equal_multichunk", "string_equal_unicode",
]) check(name, 1);
for (const name of [
  "bytes_unequal_length", "bytes_unequal_first_chunk",
  "bytes_unequal_second_chunk", "bytes_unequal_tail",
  "string_unequal_unicode",
]) check(name, 0);

check("bytes_at_zero", 0);
check("bytes_at_ff", 255);
check("bytes_at_15", 70);
check("bytes_at_16", 45);
check("string_utf8_byte", 187);
for (const name of ["bytes_at_oob", "empty_at_oob"]) {
  checks++;
  let trapped = false;
  try {
    e[name]();
  } catch (error) {
    trapped = error instanceof WebAssembly.RuntimeError;
  }
  if (!trapped) throw new Error(`${name}: expected WebAssembly trap`);
}

for (const test of generated) {
  check(`generated_valid_${test.index}`, test.valid ? 1 : 0);
  if (test.valid) check(`generated_units_${test.index}`, test.units);
  if (test.equality) {
    check(`generated_equal_${test.index}`, 1);
    check(`generated_unequal_${test.index}`, 0);
    for (const probe of test.probes) {
      check(`generated_byte_${test.index}_${probe.offset}`, probe.value);
    }
  }
  if (test.view) {
    check(`generated_view_equal_${test.index}`, 1);
    check(`generated_view_bytes_${test.index}`, 1);
    check(`generated_view_units_${test.index}`, test.units);
  }
  if (test.nested_view) check(`generated_nested_view_${test.index}`, 1);
  if (test.builder) check(`generated_builder_${test.index}`, 1);
  if (test.bytes_builder) check(`generated_bytes_builder_${test.index}`, 1);
  if (test.checked_builder) check(`generated_checked_builder_${test.index}`, 1);
  if (test.bytes_concat) check(`generated_bytes_concat_${test.index}`, 1);
  if (test.bytes_search) {
    check(`generated_find_byte_${test.index}`, test.present_index);
    check(`generated_find_absent_${test.index}`, 1);
    check(`generated_contains_byte_${test.index}`, 1);
    check(`generated_starts_with_${test.index}`, 1);
    check(`generated_ends_with_${test.index}`, 1);
  }
  if (test.bytes_substring_search) {
    check(`generated_find_substring_${test.index}`, test.substring_index);
    check(`generated_contains_substring_${test.index}`, 1);
    check(`generated_find_overlong_${test.index}`, 1);
  }
  if (test.string_concat) {
    check(`generated_string_concat_${test.index}`, 1);
    check(`generated_string_concat_view_${test.index}`, 1);
  }
  if (test.bytes_range) {
    for (const operation of ["view", "subarray", "slice", "compact"]) {
      check(`generated_bytes_${operation}_${test.index}`, 1);
    }
  }
  if (test.string_range) {
    for (const operation of ["subarray", "slice", "compact"]) {
      check(`generated_string_${operation}_${test.index}`, 1);
    }
  }
  if (test.conversion_trap) {
    checks++;
    let trapped = false;
    try {
      e[`generated_conversion_trap_${test.index}`]();
    } catch (error) {
      trapped = error instanceof WebAssembly.RuntimeError;
    }
    if (!trapped) {
      throw new Error(`generated_conversion_trap_${test.index}: expected trap`);
    }
  }
}

for (let index = 0; index < builderExpected.ascii_count; index++) {
  check(`generated_ascii_builder_${index}`, 1);
}
for (let index = 0; index < builderExpected.scalar_count; index++) {
  check(`generated_scalar_builder_${index}`, 1);
}
for (let alignment = 0; alignment < builderExpected.byte_alignment_count; alignment++) {
  for (let byte = 0; byte < 256; byte++) {
    checkArgs(`generated_find_all_bytes_alignment_${alignment}`, [byte], byte);
  }
}
for (let alignment = 0; alignment < 16; alignment++) {
  for (let lengthIndex = 0; lengthIndex < builderExpected.substring_lengths.length; lengthIndex++) {
    const needleLength = builderExpected.substring_lengths[lengthIndex];
    for (let positionIndex = 0; positionIndex < builderExpected.substring_positions.length; positionIndex++) {
      const position = builderExpected.substring_positions[positionIndex];
      check(
        `generated_substring_matrix_${alignment}_${lengthIndex}_${positionIndex}`,
        needleLength === 0 ? 0 : position,
      );
    }
    check(`generated_substring_absent_${alignment}_${lengthIndex}`, 1);
  }
}
for (let alignment = 0; alignment < 16; alignment++) {
  for (let patternIndex = 0; patternIndex < builderExpected.text_match_pattern_count; patternIndex++) {
    for (let positionIndex = 0; positionIndex < builderExpected.text_match_positions.length; positionIndex++) {
      const position = builderExpected.text_match_positions[positionIndex];
      const base = `${alignment}_${patternIndex}_${positionIndex}`;
      check(`generated_text_find_matrix_${base}`, position * 4);
      check(`generated_text_contains_matrix_${base}`, 4);
      check(`generated_text_starts_matrix_${base}`, 4);
      check(`generated_text_ends_matrix_${base}`, 4);
      check(`generated_text_absent_matrix_${base}`, 4);
    }
  }
}
check("generated_rolling_hash_collision", builderExpected.collision_index);
for (let alignmentPair = 0; alignmentPair < 16; alignmentPair++) {
  for (let leftIndex = 0; leftIndex < builderExpected.concat_lengths.length; leftIndex++) {
    for (let rightIndex = 0; rightIndex < builderExpected.concat_lengths.length; rightIndex++) {
      check(`generated_concat_boundary_${alignmentPair}_${leftIndex}_${rightIndex}`, 1);
    }
  }
}
for (let alignment = 0; alignment < 16; alignment++) {
  for (let lengthIndex = 0; lengthIndex < builderExpected.range_lengths.length; lengthIndex++) {
    for (const operation of ["view", "subarray", "slice", "compact"]) {
      check(`generated_bytes_range_boundary_${operation}_${alignment}_${lengthIndex}`, 1);
    }
    for (const operation of ["subarray", "slice", "compact"]) {
      check(`generated_string_range_boundary_${operation}_${alignment}_${lengthIndex}`, 1);
    }
  }
}
for (let alignment = 0; alignment < 16; alignment++) {
  for (let scalarIndex = 0; scalarIndex < builderExpected.boundary_scalar_lengths.length; scalarIndex++) {
    const scalarLength = builderExpected.boundary_scalar_lengths[scalarIndex];
    for (let interior = 1; interior < scalarLength; interior++) {
      expectTrap(`generated_utf_boundary_start_trap_${alignment}_${scalarIndex}_${interior}`);
      expectTrap(`generated_utf_boundary_end_trap_${alignment}_${scalarIndex}_${interior}`);
    }
  }
}
for (let capacityIndex = 0; capacityIndex < builderExpected.builder_capacities.length; capacityIndex++) {
  for (let lengthIndex = 0; lengthIndex < builderExpected.builder_lengths.length; lengthIndex++) {
    check(`generated_bytes_builder_boundary_${capacityIndex}_${lengthIndex}`, 1);
    check(`generated_string_builder_boundary_${capacityIndex}_${lengthIndex}`, 1);
  }
}
check("generated_large_search_present", builderExpected.large_search_index);
check("generated_large_search_absent", 1);
check("generated_large_bytes_builder", 1);
check("generated_large_string_builder", 1);

console.log(`UTF parity passed: ${checks} checks`);
