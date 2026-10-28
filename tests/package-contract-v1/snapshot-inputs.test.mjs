// Narrow input checks. No compiler build, auth access, or network call.
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { mkdtemp, mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { test } from 'node:test';

const module = process.env.DEW_TEST_SNAPSHOT_MODULE
  ? pathToFileURL(process.env.DEW_TEST_SNAPSHOT_MODULE).href
  : new URL('../../tools/dew-package-snapshot.mjs', import.meta.url).href;
const { preparePackage } = await import(module);
const fingerprint = 'a'.repeat(64);
const manifest = { name: '@test/root', version: '1.0.0', dependencies: {} };
const source = Buffer.from('// fixture\n');
const hash = createHash('sha256').update('DEW_PACKAGE_INTEGRITY_V1\0');
for (const value of [manifest.name, manifest.version, 'test.root', 'main.dew', source]) {
  const bytes = Buffer.from(value);
  const length = Buffer.alloc(4);
  length.writeUInt32LE(bytes.length);
  hash.update(length).update(bytes);
}
const integrity = `sha256-${hash.digest('hex')}`;

async function fixture(t, lockBytes) {
  const root = await mkdtemp(join(tmpdir(), 'dew-lock-input-check-'));
  t.after(() => rm(root, { recursive: true, force: true }));
  const standard = join(root, 'installed');
  await mkdir(join(standard, 'std/preamble'), { recursive: true });
  await writeFile(join(standard, 'std/preamble/00-builtins.dew'), '// mock standard source\n');
  const pkg = join(root, 'package');
  await mkdir(pkg);
  const manifestPath = join(pkg, 'dew.json');
  await writeFile(manifestPath, JSON.stringify(manifest));
  await writeFile(join(pkg, 'main.dew'), source);
  await writeFile(join(pkg, 'dew.lock'), lockBytes);
  let builds = 0;
  return {
    builds: () => builds,
    run: () => preparePackage({
      manifestPath, source: 'registry:https://example.invalid', repositoryRoot: standard,
      environment: { ...process.env, DEW_PACKAGE_ROOTS: standard },
      run: async argv => {
        if (argv[1] === 'build') {
          builds++;
          await writeFile(argv[argv.indexOf('-o') + 1], 'mock wasm');
          return '';
        }
        if (argv[1] === 'package-integrity') return integrity;
        if (argv[1]?.endsWith('dew-abi.mjs')) return JSON.stringify({ path: 'test.root', interfaceFingerprint: fingerprint });
        assert.fail(`unexpected compiler call: ${JSON.stringify(argv)}`);
      },
    }),
  };
}

const locked = { name: '@test/unused', version: '1.0.0', source: 'file:unused', path: 'unused', integrity: `sha256-${'b'.repeat(64)}`, interface: fingerprint };
for (const [name, input, reason] of [
  ['duplicate lock field', '{"lockfileVersion":1,"lockfileVersion":1,"packages":[]}', /duplicate/i],
  ['escaped duplicate lock field', '{"lockfileVersion":1,"lockfileVersi\\u006fn":1,"packages":[]}', /duplicate/i],
  ['duplicate locked field', `{"lockfileVersion":1,"packages":[${JSON.stringify(locked).replace('"version":"1.0.0"', '"version":"1.0.0","version":"1.0.0"')}]}`, /duplicate/i],
  ['unknown lock field', '{"lockfileVersion":1,"packages":[],"extra":0}', /unknown/i],
  ['unknown locked field', JSON.stringify({ lockfileVersion: 1, packages: [{ ...locked, extra: 0 }] }), /unknown/i],
  ['invalid unused locked name', JSON.stringify({ lockfileVersion: 1, packages: [{ ...locked, name: 'bad' }] }), /name/i],
  ['invalid unused locked version', JSON.stringify({ lockfileVersion: 1, packages: [{ ...locked, version: '1.0.0-' }] }), /version/i],
  ['invalid unused locked path', JSON.stringify({ lockfileVersion: 1, packages: [{ ...locked, path: '../outside' }] }), /path/i],
  ['invalid unused locked source', JSON.stringify({ lockfileVersion: 1, packages: [{ ...locked, source: '' }] }), /source/i],
  ['invalid UTF-8 lock', Buffer.concat([Buffer.from('{"lockfileVersion":1,"packages":[],"'), Buffer.from([255]), Buffer.from('":0}')]), /UTF-8/i],
]) {
  test(`snapshot preserves lock rejection: ${name}`, async t => {
    const f = await fixture(t, input);
    await assert.rejects(f.run, reason);
    assert.equal(f.builds(), 0, 'invalid original lock reached compiler');
  });
}

test('snapshot accepts an empty valid lock and retains its input digest', async t => {
  const bytes = Buffer.from('{"lockfileVersion":1,"packages":[]}');
  const f = await fixture(t, bytes);
  const result = await f.run();
  assert.equal(f.builds(), 1);
  assert.equal(result.inputs.lock.originalSha256, createHash('sha256').update(bytes).digest('hex'));
  assert.equal(result.inputs.sourceIntegrity, integrity);
});
