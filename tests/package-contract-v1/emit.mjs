#!/usr/bin/env node
// Export fully expanded cases for a language-specific test generator.
import { loadCases } from './vectors.mjs';
const filters = process.argv.slice(2);
const cases = await loadCases();
for (const filter of filters) {
  if (!cases.some(test => test.id === filter || test.kind === filter)) throw new Error(`unknown case filter: ${filter}`);
}
for (const test of cases) {
  if (!filters.length || filters.some(filter => test.id === filter || test.kind === filter)) {
    console.log(JSON.stringify({ schemaVersion: 1, ...test }));
  }
}
