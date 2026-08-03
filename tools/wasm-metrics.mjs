#!/usr/bin/env node
import { readFile } from "node:fs/promises";

function usage(message) {
  if (message) console.error(`wasm metrics: ${message}`);
  console.error("usage: wasm-metrics.mjs WAT WASM [BUDGET_JSON]");
  process.exit(2);
}

const [watPath, wasmPath, budgetPath, ...rest] = process.argv.slice(2);
if (!watPath || !wasmPath || rest.length !== 0) usage();

const [watBytes, wasmBytes] = await Promise.all([
  readFile(watPath),
  readFile(wasmPath),
]);
const wat = watBytes.toString("utf8");
const module = await WebAssembly.compile(wasmBytes);

function count(pattern) {
  return [...wat.matchAll(pattern)].length;
}

const exports = WebAssembly.Module.exports(module);
const imports = WebAssembly.Module.imports(module);
const metrics = {
  wasm_bytes: wasmBytes.length,
  wat_bytes: watBytes.length,
  types: count(/^\s*\(type\s+\(;/gm),
  functions: count(/^\s*\(func\s+\(;/gm),
  globals: count(/^\s*\(global\s+\(;/gm),
  imports: imports.length,
  exports: exports.length,
  function_exports: exports.filter((value) => value.kind === "function").length,
  adapter_exports: exports.filter(
    (value) => value.kind === "function" && value.name.includes("$dew$"),
  ).length,
  direct_calls: count(/^\s*call\s+\d+/gm),
  call_refs: count(/^\s*call_ref\b/gm),
  return_call_refs: count(/^\s*return_call_ref\b/gm),
  struct_news: count(/^\s*struct\.new\b/gm),
  array_news: count(/^\s*array\.new(?:_default|_fixed|_data|_elem)?\b/gm),
  ref_casts: count(/^\s*ref\.cast\b/gm),
  ref_tests: count(/^\s*ref\.test\b/gm),
  local_gets: count(/^\s*local\.get\b/gm),
  local_sets: count(/^\s*local\.set\b/gm),
};

const failures = [];
if (budgetPath) {
  let budget;
  try {
    budget = JSON.parse(await readFile(budgetPath, "utf8"));
  } catch (error) {
    usage(`cannot read budget ${budgetPath}: ${String(error)}`);
  }
  if (!budget || typeof budget !== "object" || Array.isArray(budget)) {
    usage("budget must be a JSON object");
  }
  for (const [name, bounds] of Object.entries(budget)) {
    if (!(name in metrics)) usage(`budget uses unknown metric ${name}`);
    if (!bounds || typeof bounds !== "object" || Array.isArray(bounds)) {
      usage(`budget ${name} must be an object`);
    }
    const allowed = new Set(["exact", "min", "max"]);
    for (const key of Object.keys(bounds)) {
      if (!allowed.has(key)) usage(`budget ${name} uses unknown bound ${key}`);
    }
    for (const key of allowed) {
      if (key in bounds && (!Number.isInteger(bounds[key]) || bounds[key] < 0)) {
        usage(`budget ${name}.${key} must be a non-negative integer`);
      }
    }
    if ("exact" in bounds && ("min" in bounds || "max" in bounds)) {
      usage(`budget ${name} cannot combine exact with min or max`);
    }
    const actual = metrics[name];
    if ("exact" in bounds && actual !== bounds.exact) {
      failures.push(`${name}: expected exactly ${bounds.exact}, got ${actual}`);
    }
    if ("min" in bounds && actual < bounds.min) {
      failures.push(`${name}: expected at least ${bounds.min}, got ${actual}`);
    }
    if ("max" in bounds && actual > bounds.max) {
      failures.push(`${name}: expected at most ${bounds.max}, got ${actual}`);
    }
  }
}

process.stdout.write(`${JSON.stringify(metrics, null, 2)}\n`);
if (failures.length !== 0) {
  for (const failure of failures) console.error(`wasm budget exceeded: ${failure}`);
  process.exit(1);
}
