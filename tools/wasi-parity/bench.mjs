import { readFile } from "node:fs/promises";

const wasm = await readFile(new URL("./wasi_parity.wasm", import.meta.url));
const module = await WebAssembly.compile(wasm);
let instance;
let checksum = 0;
let writeLimit = Infinity;

function memoryView() {
  return new DataView(instance.exports.memory.buffer);
}

function memoryBytes() {
  return new Uint8Array(instance.exports.memory.buffer);
}

function fdWrite(fd, iovs, iovsLength, written) {
  const view = memoryView();
  const pointer = view.getUint32(iovs, true);
  const length = view.getUint32(iovs + 4, true);
  const count = Math.min(length, writeLimit);
  const bytes = memoryBytes();
  if (count > 0) checksum ^= bytes[pointer] ^ bytes[pointer + count - 1];
  view.setUint32(written, count, true);
  return 0;
}

function fdRead(fd, iovs, iovsLength, read) {
  const view = memoryView();
  const pointer = view.getUint32(iovs, true);
  const length = view.getUint32(iovs + 4, true);
  memoryBytes().fill((checksum++ * 17 + 3) & 0xff, pointer, pointer + length);
  view.setUint32(read, length, true);
  return 0;
}

instance = await WebAssembly.instantiate(module, {
  wasi_snapshot_preview1: { fd_write: fdWrite, fd_read: fdRead },
});

const iterations = Number(process.env.DEW_WASI_BENCH_ITERATIONS ?? 10000);
const warmup = Number(process.env.DEW_WASI_BENCH_WARMUP ?? 3000);
const samples = Number(process.env.DEW_WASI_BENCH_SAMPLES ?? 9);
const prepareIovec = (length) => {
  const view = memoryView();
  view.setUint32(0, 16, true);
  view.setUint32(4, length, true);
};
const cases = [
  ["stage_write_4096", () => instance.exports.stage_write_4096(), 4096],
  ["stage_write_10000", () => instance.exports.stage_write_10000(), 10000],
  ["stage_write_65520", () => instance.exports.stage_write_65520(), 65520],
  ["stage_read_4096", () => instance.exports.stage_read_4096(), 4096],
  ["stage_read_10000", () => instance.exports.stage_read_10000(), 10000],
  ["stage_read_65520", () => instance.exports.stage_read_65520(), 65520],
  ["host_write_callback_4096", () => instance.exports.host_write_call(1), 0, () => prepareIovec(4096)],
  ["host_read_callback_4096", () => instance.exports.host_read_call(0), 0, () => prepareIovec(4096)],
  ["write_4096", () => instance.exports.write_boundary_4096(1), 4096],
  ["write_10000", () => instance.exports.write_boundary_10000(1), 10000],
  ["write_65520", () => instance.exports.write_boundary_65520(1), 65520],
  ["write_100000", () => instance.exports.write_boundary_100000(1), 100000],
  ["write_partial_10000_1024", () => instance.exports.write_boundary_10000(1), 10000, () => { writeLimit = 1024; }],
  ["read_4096", () => instance.exports.read_length_4096(0), 4096],
  ["read_10000", () => instance.exports.read_length_10000(0), 10000],
  ["read_65520", () => instance.exports.read_length_65520(0), 65520],
  ["read_100000", () => instance.exports.read_length_100000(0), 100000],
];

for (const [, fn, expected, setup] of cases) {
  writeLimit = Infinity;
  if (setup) setup();
  for (let index = 0; index < warmup; index++) {
    if (fn() !== expected) throw new Error("WASI benchmark warmup mismatch");
  }
}

for (const [name, fn, expected, setup] of cases) {
  writeLimit = Infinity;
  if (setup) setup();
  const timings = [];
  let result = 0;
  for (let sample = 0; sample < samples; sample++) {
    const start = process.hrtime.bigint();
    for (let index = 0; index < iterations; index++) result ^= fn();
    const elapsed = process.hrtime.bigint() - start;
    timings.push(Number(elapsed) / iterations);
  }
  if (fn() !== expected) throw new Error(`${name} result mismatch`);
  timings.sort((left, right) => left - right);
  const median = timings[Math.floor(timings.length / 2)];
  console.log(
    `${name} median_ns=${median.toFixed(2)} min_ns=${timings[0].toFixed(2)} ` +
      `max_ns=${timings[timings.length - 1].toFixed(2)} checksum=${result ^ checksum}`,
  );
}
