// Compiler-dependency policy checks. No real compiler or network call.
import assert from 'node:assert/strict';
import { mkdtemp, mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { test } from 'node:test';
import { preparePackage } from './dew-package-snapshot.mjs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');

async function fixture(t) {
  const directory = await mkdtemp(join(tmpdir(), 'dew-pack-offline-'));
  t.after(() => rm(directory, { recursive: true, force: true }));
  return directory;
}

for (const launch of ['bootstrap', 'js', 'wasm-gc']) {
  for (const offline of [false, true]) test(`${launch} compiler dependencies are frozen only for package preparation: ${offline}`, async t => {
    const directory = await fixture(t);
    const bin = join(directory, 'bin');
    await mkdir(bin);
    const trace = join(directory, 'moon.jsonl');
    const fakeMoon = '#!/usr/bin/env node\nrequire("node:fs").appendFileSync(process.env.DEW_TEST_MOON_TRACE, JSON.stringify(process.argv.slice(2)) + "\\n");\n';
    await writeFile(join(bin, 'moon'), fakeMoon, { mode: 0o755 });
    await writeFile(join(bin, 'moonrun'), '#!/bin/sh\nexit 0\n', { mode: 0o755 });
    const target = join(directory, 'target');
    const js = join(target, 'js/release/build/jtenner/dewdrop/dew_cli/dew_cli.js');
    await mkdir(dirname(js), { recursive: true });
    await writeFile(js, 'process.exit(0);\n');
    const script = launch === 'bootstrap' ? 'tools/dew' : 'tools/run-dew-cli-host.sh';
    const args = launch === 'bootstrap' ? ['build'] : launch === 'js' ? ['check'] : ['--compile-request'];
    const result = spawnSync('bash', [join(root, script), ...args], {
      cwd: directory, encoding: 'utf8', timeout: 10_000,
      env: { ...process.env, PATH: `${bin}:${process.env.PATH}`, DEW_TEST_MOON_TRACE: trace,
        DEW_PACKAGE_OFFLINE: offline ? '1' : '', DEW_HOST_TARGET_DIR: target, DEW_BOOTSTRAP_TARGET_DIR: target },
    });
    assert.ifError(result.error);
    assert.equal(result.status, 0, result.stderr);
    const calls = (await readFile(trace, 'utf8')).trim().split('\n').map(line => JSON.parse(line));
    assert.equal(calls.length, 1);
    assert.equal(calls[0].includes('--frozen'), offline, 'compiler dependency synchronization policy was not forwarded');
  });
}

test('package preparation forces frozen dependencies in its compiler environment', async t => {
  const directory = await fixture(t);
  const pkg = join(directory, 'package');
  const installed = join(directory, 'installed');
  await mkdir(pkg);
  await mkdir(join(installed, 'std/preamble'), { recursive: true });
  await writeFile(join(pkg, 'dew.json'), '{"name":"@test/offline","version":"1.0.0"}');
  await writeFile(join(pkg, 'main.dew'), '// fixture\n');
  await writeFile(join(installed, 'std/preamble/00-builtins.dew'), '// fixture\n');
  const stop = new Error('compiler environment captured');
  let observed;
  await assert.rejects(preparePackage({ manifestPath: join(pkg, 'dew.json'), repositoryRoot: installed,
    source: 'registry:https://example.invalid', environment: { ...process.env, DEW_PACKAGE_ROOTS: installed, DEW_PACKAGE_OFFLINE: '0' },
    run: async (_argv, options) => { observed = options.env; throw stop; },
  }), error => error === stop);
  assert.equal(observed.DEW_PACKAGE_OFFLINE, '1', 'package compiler dependencies were not forced frozen');
});
