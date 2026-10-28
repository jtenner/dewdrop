import { readFile, readdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';

export const fixtureRoot = fileURLToPath(new URL('.', import.meta.url));

// Only tagged text recipes expand. Ordinary manifest bytes stay unchanged.
export function expand(value) {
  if (Array.isArray(value)) return value.map(expand);
  if (value && typeof value === 'object') {
    const keys = Object.keys(value).sort().join(',');
    if (keys === 'count,repeat') {
      if (typeof value.repeat !== 'string' || !Number.isSafeInteger(value.count) || value.count < 0 ||
          Buffer.byteLength(value.repeat) * value.count > 1048577) {
        throw new Error('invalid or excessive repeat recipe');
      }
      return value.repeat.repeat(value.count);
    }
    if (keys === 'concat') {
      if (!Array.isArray(value.concat)) throw new Error('concat recipe requires an array');
      const parts = value.concat.map(expand);
      if (parts.some(part => typeof part !== 'string') ||
          parts.reduce((n, part) => n + Buffer.byteLength(part), 0) > 1048577) {
        throw new Error('invalid or excessive concat recipe');
      }
      return parts.join('');
    }
    return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, expand(item)]));
  }
  return value;
}

export async function loadCases() {
  const output = [];
  const ids = new Set();
  for (const file of (await readdir(fixtureRoot)).filter(file => file.endsWith('.json') && file !== 'limits.json').sort()) {
    const suite = JSON.parse(await readFile(join(fixtureRoot, file), 'utf8'));
    if (suite.schemaVersion !== 1 || typeof suite.kind !== 'string' || !Array.isArray(suite.cases)) {
      throw new Error(`invalid suite: ${file}`);
    }
    for (const test of suite.cases) {
      const id = `${suite.kind}/${test.id}`;
      if (!test.id || ids.has(id) || !test.rule || typeof test.expected?.accept !== 'boolean' || !Object.hasOwn(test, 'input')) {
        throw new Error(`invalid or duplicate case: ${id}`);
      }
      ids.add(id);
      output.push({ ...test, id, kind: suite.kind, input: expand(test.input) });
    }
  }
  return output;
}
