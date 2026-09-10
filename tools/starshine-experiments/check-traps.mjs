import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
let instance;
const stdout = [];
const imports = {wasi_snapshot_preview1: {fd_write(fd, iovs, count, written) {
  assert(instance, "unexpected write during instantiation");
  const memory = new DataView(instance.exports.memory.buffer);
  let total = 0;
  for (let i = 0; i < count; i++) {
    const offset = memory.getUint32(iovs + i * 8, true);
    const length = memory.getUint32(iovs + i * 8 + 4, true);
    stdout.push(Buffer.from(instance.exports.memory.buffer, offset, length).toString());
    total += length;
  }
  memory.setUint32(written, total, true);
  return 0;
}}};
instance = await WebAssembly.instantiate(module, imports);
instance.exports.__dew_init?.();
let count = 0;
for (const [name, fn] of Object.entries(instance.exports)) {
  if (typeof fn !== "function" || name === "__dew_init") continue;
  assert.throws(() => fn(), WebAssembly.RuntimeError, `${name}: expected a Wasm trap`);
  count++;
}
assert(count > 0, "no trap exports found");
console.log(JSON.stringify({traps: count, stdout}));
