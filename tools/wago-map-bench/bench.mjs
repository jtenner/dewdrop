import fs from "node:fs";
import { performance } from "node:perf_hooks";

const path = process.argv[2];
const calls = Number(process.argv[3] ?? 20);
const rounds = Number(process.argv[4] ?? 7);
if (!path || !Number.isInteger(calls) || calls < 1 || !Number.isInteger(rounds) || rounds < 1) {
  throw new Error("usage: node bench.mjs MODULE.wasm [calls] [rounds]");
}

const bytes = fs.readFileSync(path);
const { instance } = await WebAssembly.instantiate(bytes, {});
for (let index = 0; index < 3; index += 1) {
  instance.exports.main();
}
const samples = [];
for (let round = 0; round < rounds; round += 1) {
  const start = performance.now();
  for (let index = 0; index < calls; index += 1) {
    instance.exports.main();
  }
  samples.push(((performance.now() - start) * 1_000_000) / calls);
}
samples.sort((left, right) => left - right);
console.log(
  JSON.stringify({
    engine: "node",
    bytes: bytes.length,
    median_ns: samples[Math.floor(samples.length / 2)],
    samples_ns: samples,
  }),
);
