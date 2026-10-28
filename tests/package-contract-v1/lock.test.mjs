import assert from 'node:assert/strict';
import { test } from 'node:test';
import { parsePackageLock, MAX_LOCK_BYTES } from '../../tools/dew-package-lock.mjs';

const entry = { name: '@test/dep', version: '1.0.0', source: 'file:dep', path: '.dew/packages/dep', integrity: `sha256-${'a'.repeat(64)}`, interface: 'b'.repeat(64) };
const lock = packages => JSON.stringify({ lockfileVersion: 1, packages });

test('lock parser accepts original v1 fields and preserves exact strings', () => {
  const parsed = parsePackageLock(lock([entry]));
  assert.deepEqual(JSON.parse(JSON.stringify(parsed)), { lockfileVersion: 1, packages: [entry] });
});

for (const input of ['', 'null', '[]', '{}', '{"lockfileVersion":1,"packages":[],}', '{"lockfileVersion":1,"packages":[]} true', '{"lockfileVersion":1,"packages":[true]}', '{"lockfileVersion":1,"packages":[{"name":"unterminated}]}', '{"lockfileVersion":01,"packages":[]}']) {
  test(`lock parser keeps malformed input visible: ${JSON.stringify(input)}`, () => assert.throws(() => parsePackageLock(input), /lockfile|locked package/));
}

test('lock parser rejects duplicate decoded keys and duplicate records', () => {
  assert.throws(() => parsePackageLock('{"lockfileVersion":1,"lockfileVersi\\u006fn":1,"packages":[]}'), /duplicate/);
  assert.throws(() => parsePackageLock(lock([entry, entry])), /duplicate locked package name/);
});

for (const [key, value, reason] of [
  ['name', '@A/a', /name/], ['version', '1.0.0+', /version/], ['path', 'C:/a', /path/],
  ['path', 'a//b', /path/], ['path', 'a/./b', /path/], ['path', 'a/../b', /path/],
  ['source', '', /source/], ['integrity', `sha256-${'a'.repeat(64)}\n`, /provenance/],
  ['interface', 'b'.repeat(63), /provenance/],
]) test(`lock parser rejects invalid ${key}: ${JSON.stringify(value)}`, () => assert.throws(() => parsePackageLock(lock([{ ...entry, [key]: value }])), reason));

test('lock parser keeps 8 MiB separate from the 1 MiB manifest bound', () => {
  const input = lock([]);
  assert.equal(parsePackageLock(input.padEnd(MAX_LOCK_BYTES)).packages.length, 0);
  assert.throws(() => parsePackageLock(input.padEnd(MAX_LOCK_BYTES + 1)), /8 MiB/);
});

test('lock parser admits 4096 valid records and rejects 4097', () => {
  const packages = Array.from({ length: 4096 }, (_, index) => ({ ...entry, name: `@test/dep${index}` }));
  assert.equal(parsePackageLock(lock(packages)).packages.length, 4096);
  packages.push({ ...entry, name: '@test/extra' });
  assert.throws(() => parsePackageLock(lock(packages)), /4096/);
});

for (const version of ['1.0', '1e0']) test(`lock version requires literal JSON 1: ${version}`, () => {
  assert.throws(() => parsePackageLock(`{"lockfileVersion":${version},"packages":[]}`), /lockfileVersion/);
});
