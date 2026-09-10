import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { performance } from "node:perf_hooks";

const [specPath, samplesText = "31", targetText = "3"] = process.argv.slice(2);
const spec = JSON.parse(await readFile(specPath, "utf8"));
const samples = Number(samplesText);
const targetMs = Number(targetText);
assert(samples >= 5 && targetMs > 0, "invalid benchmark settings");
const entries = [];
const byHash = new Map();
const variants = [];
for (const variant of spec.variants) {
  const bytes = await readFile(variant.wasm);
  const hash = createHash("sha256").update(bytes).digest("hex");
  const equivalent = byHash.get(hash);
  if (equivalent) {
    // Equal bytes with the same export and inputs are the same experiment.
    // Reuse its samples instead of awarding noise to one pipeline spelling.
    variants.push({name: variant.name, entry: equivalent, equivalentTo: equivalent.name});
    continue;
  }
  const start = performance.now();
  const module = await WebAssembly.compile(bytes);
  const compileMs = performance.now() - start;
  const instance = await WebAssembly.instantiate(module, {});
  instance.exports.__dew_init?.();
  const fn = instance.exports[spec.export];
  assert.equal(typeof fn, "function", `missing ${spec.export}`);
  for (const input of spec.inputs) {
    assert.equal(fn(...input.args), input.expected, `${variant.name}: wrong result for ${input.args}`);
  }
  const run = (count) => {
    let total = 0;
    for (let index = 0; index < count; index++) {
      const input = spec.inputs[index % spec.inputs.length];
      total += fn(...input.args);
    }
    return total;
  };
  const warmupEnd = performance.now() + 150;
  while (performance.now() < warmupEnd) run(100);
  const entry = { name: variant.name, run, compileMs, times: [] };
  entries.push(entry);
  byHash.set(hash, entry);
  variants.push({name: variant.name, entry, equivalentTo: null});
}
// Calibrate once on the unoptimized module; every variant uses the same work.
let batch = spec.inputs.length;
for (;;) {
  const start = performance.now();
  entries[0].run(batch);
  const ms = performance.now() - start;
  if (ms >= targetMs || batch >= 1000000) break;
  batch *= 2;
}
let expectedTotal = 0;
for (let index = 0; index < batch; index++) expectedTotal += spec.inputs[index % spec.inputs.length].expected;
// Rotate order each sample to distribute order and thermal bias.
for (let sample = 0; sample < samples; sample++) {
  for (let offset = 0; offset < entries.length; offset++) {
    const entry = entries[(sample + offset) % entries.length];
    const start = performance.now();
    const total = entry.run(batch);
    const elapsed = performance.now() - start;
    assert.equal(total, expectedTotal, `${entry.name}: timed batch result changed`);
    entry.times.push(elapsed * 1e6 / batch);
  }
}
console.log(JSON.stringify({batch, samples, warmup_ms_per_unique_module: 150,
  unique_modules: entries.length, variants:
  Object.fromEntries(variants.map(({name, entry, equivalentTo}) => [name,
    {compile_ms: equivalentTo === null ? entry.compileMs : null,
     equivalent_to: equivalentTo, ns_per_call: entry.times}]))}));
