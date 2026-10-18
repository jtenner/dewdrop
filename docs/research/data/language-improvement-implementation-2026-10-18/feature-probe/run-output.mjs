import { readFileSync } from "node:fs";
import { performance } from "node:perf_hooks";
const started = performance.now();
const module = new WebAssembly.Module(readFileSync(process.argv[2]));
const imports = {};
for (const item of WebAssembly.Module.imports(module)) {
  if (item.kind !== "function") throw new Error(`unexpected import ${JSON.stringify(item)}`);
  (imports[item.module] ??= {})[item.name] = () => { throw new Error(`unexpected call ${item.module}.${item.name}`); };
}
const { exports: guest } = new WebAssembly.Instance(module, imports);
guest.__dew_init?.();
const result = guest.main();
console.log(JSON.stringify({ result, elapsed_ms: performance.now() - started }));
if (result !== 42) process.exitCode = 1;
