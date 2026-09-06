import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { performance } from "node:perf_hooks";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const imports = Object.create(null);
for (const entry of WebAssembly.Module.imports(module)) {
  assert.equal(entry.kind, "function", `unsupported probe import ${entry.module}.${entry.name}`);
  imports[entry.module] ??= Object.create(null);
  imports[entry.module][entry.name] = () => {
    throw new Error(`unexpected semantic probe host call ${entry.module}.${entry.name}`);
  };
}
const instance = await WebAssembly.instantiate(module, imports);
instance.exports.__dew_init?.();
let failures = 0;
for (const name of ["self_host_bootstrap_primitive_probe", "self_host_bootstrap_type_query_probe", "self_host_bootstrap_solver_probe", "self_host_bootstrap_import_probe", "self_host_bootstrap_body_probe"]) {
  const start = performance.now();
  try {
    assert.equal(typeof instance.exports[name], "function", `missing semantic probe ${name}`);
    assert.equal(instance.exports[name](), 0, `${name}: semantic disagreement`);
    const elapsed = (performance.now() - start) / 1000;
    console.log(`self-host semantic probe passed: ${name} (${elapsed.toFixed(3)} seconds)`);
    assert.ok(elapsed <= 30, `${name}: compiler performance exceeds 30 seconds`);
  } catch (error) {
    failures++;
    console.error(error);
  }
}
assert.equal(failures, 0, "self-host semantic probes failed");
