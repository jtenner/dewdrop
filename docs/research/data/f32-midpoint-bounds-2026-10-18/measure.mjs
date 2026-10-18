import { readFileSync } from "node:fs";
import { performance } from "node:perf_hooks";
const [path, count] = process.argv.slice(2);
const module = new WebAssembly.Module(readFileSync(path));
const imports = {};
for (const item of WebAssembly.Module.imports(module)) {
  if (item.kind !== "function") throw new Error(`unexpected import ${JSON.stringify(item)}`);
  (imports[item.module] ??= {})[item.name] = () => { throw new Error(`unexpected call ${item.module}.${item.name}`); };
}
const { exports: guest } = new WebAssembly.Instance(module, imports);
guest.__dew_init?.();
guest.f32_scaling_prepare(64);
if (guest.f32_scaling_run() !== 0x3f800000) throw new Error("warmup mismatch");
guest.f32_scaling_prepare(Number(count));
global.gc();
const before = process.memoryUsage().heapUsed;
const rssBefore = process.resourceUsage().maxRSS;
const start = performance.now();
const bits = guest.f32_scaling_run();
const elapsedMs = performance.now() - start;
const after = process.memoryUsage().heapUsed;
const peakRssKiB = process.resourceUsage().maxRSS;
if (bits !== 0x3f800000) throw new Error(`rounding mismatch: ${bits}`);
console.log(JSON.stringify({ count: Number(count), bits, elapsedMs, heapBefore: before, heapAfter: after, heapGrowth: after - before, rssBeforeKiB: rssBefore, peakRssKiB }));
