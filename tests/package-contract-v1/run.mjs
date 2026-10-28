#!/usr/bin/env node
import { isDeepStrictEqual } from 'node:util';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { loadCases } from './vectors.mjs';

export function compare(test, actual) {
  if (!actual || typeof actual.accept !== 'boolean') return 'adapter must return a boolean accept field';
  if (!actual.accept && (typeof actual.diagnostic !== 'string' || !actual.diagnostic.trim())) {
    return 'rejection must include a diagnostic from the reader';
  }
  for (const [key, value] of Object.entries(test.expected)) {
    if (!isDeepStrictEqual(actual[key], value)) return `${key}: expected ${JSON.stringify(value)}, got ${JSON.stringify(actual[key])}`;
  }
  return null;
}

async function main() {
  const [adapterPath, ...filters] = process.argv.slice(2);
  if (!adapterPath) throw new Error('usage: node tests/package-contract-v1/run.mjs ADAPTER.mjs [kind/id ...]');
  const adapter = await import(pathToFileURL(resolve(adapterPath)).href);
  if (!Array.isArray(adapter.kinds) || typeof adapter.evaluate !== 'function') throw new Error('adapter requires kinds and evaluate(kind, input, test)');
  const all = await loadCases();
  for (const filter of filters) {
    if (!all.some(test => test.id === filter || test.kind === filter)) throw new Error(`unknown case filter: ${filter}`);
  }
  const selected = all.filter(test => !filters.length || filters.some(filter => test.id === filter || test.kind === filter));
  const unsupported = selected.filter(test => !adapter.kinds.includes(test.kind));
  // An explicit unsupported request must fail. Unselected kinds stay visible.
  if (filters.length && unsupported.length) throw new Error(`adapter cannot run requested case: ${unsupported[0].id}`);
  let passed = 0, failed = 0;
  for (const test of selected.filter(test => adapter.kinds.includes(test.kind))) {
    try {
      const actual = await adapter.evaluate(test.kind, test.input, test);
      const error = compare(test, actual);
      if (error) {
        failed++;
        console.error(`FAIL ${test.id} [${test.rule}]: ${error}; reader=${JSON.stringify(actual)}`);
      } else {
        passed++;
        console.log(`PASS ${test.id}`);
      }
    } catch (error) {
      failed++;
      console.error(`ERROR ${test.id}: ${error.stack ?? error}`);
    }
  }
  console.log(JSON.stringify({ passed, failed, unsupported: unsupported.map(test => test.id) }));
  if (!passed && !failed) throw new Error('adapter ran no cases');
  process.exitCode = failed ? 1 : 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  await main().catch(error => { console.error(error.stack ?? error); process.exitCode = 2; });
}
