// Test-only adapter. It executes unchanged baseline function bodies from Git.
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import * as fs from 'node:fs/promises';
import { tmpdir } from 'node:os';
import * as path from 'node:path';
import { compileFunction } from 'node:vm';
import { fixtureRoot } from '../vectors.mjs';

export const baseline = '20f902acb6caa56a49712df832aeb0c46ec520b8';
export const kinds = ['manifest', 'name', 'semver', 'requirement', 'source-selection'];
const root = path.resolve(fixtureRoot, '../..');
const source = execFileSync('git', ['show', `${baseline}:tools/dew-registry.mjs`], {
  cwd: root, encoding: 'utf8', timeout: 5000, maxBuffer: 1048576,
});
export const sourceSha256 = createHash('sha256').update(source).digest('hex');
const start = source.indexOf('function fail(');
const end = source.lastIndexOf('\nif (command === "login")');
if (start < 0 || end < start) throw new Error('baseline module boundaries not found');
class Rejection extends Error {}
const blocked = () => { throw new Error('baseline adapter forbids compiler, network, and process use'); };
const bindings = {
  ...fs, ...path, createHash, tmpdir, repositoryRoot: root, command: 'contract-probe', arguments_: [],
  Buffer, URL, Response, Bun: { spawn: blocked, sleep: blocked }, fetch: blocked,
  process: { env: {}, cwd: () => root, exit(status) { throw new Rejection(`exit ${status}`); } },
  console: { error(message) { throw new Rejection(message); }, log: blocked, warn: blocked },
};
// Only the module imports, top-level CLI state, and CLI dispatch are excluded.
// No validator/source-collector/capsule function body is rewritten.
const api = compileFunction(`${source.slice(start, end)}\nreturn { capsule, sourceFiles };`, Object.keys(bindings))(...Object.values(bindings));

function safePath(root, relative) {
  const target = path.resolve(root, relative);
  if (!target.startsWith(root + path.sep)) throw new Error(`unsafe fixture entry: ${relative}`);
  return target;
}

export async function evaluate(kind, input) {
  if (!kinds.includes(kind)) throw new Error(`unsupported kind: ${kind}`);
  const temporary = await fs.mkdtemp(path.join(tmpdir(), 'dew-contract-baseline-'));
  const packageRoot = path.join(temporary, 'package');
  await fs.mkdir(packageRoot);
  try {
    if (kind === 'source-selection') {
      for (const entry of input.entries) {
        const target = safePath(packageRoot, entry.path);
        await fs.mkdir(path.dirname(target), { recursive: true });
        if (entry.type === 'directory') await fs.mkdir(target, { recursive: true });
        else if (entry.type === 'file') await fs.writeFile(target, entry.text);
        else if (entry.type === 'symlink') await fs.symlink(entry.target, target);
        else throw new Error(`unknown fixture entry type: ${entry.type}`);
      }
      const artifact = (await api.sourceFiles(packageRoot)).map(file => path.relative(packageRoot, file).split(path.sep).join('/'));
      return { accept: true, artifact, compiler: artifact.filter(file => !file.endsWith('_test.dew')) };
    }
    const manifest = { name: '@a/b', version: '1.0.0', dependencies: {} };
    if (kind === 'name') manifest.name = input;
    if (kind === 'semver') manifest.version = input;
    if (kind === 'requirement') manifest.dependencies['@c/d'] = input;
    const manifestPath = path.join(packageRoot, 'dew.json');
    await fs.writeFile(manifestPath, kind === 'manifest' ? input : JSON.stringify(manifest));
    await fs.writeFile(path.join(packageRoot, 'main.dew'), 'pub fn value() -> I32 { 1 }\n');
    const result = await api.capsule(manifestPath, 'registry:https://example.invalid', '0'.repeat(64), `sha256-${'0'.repeat(64)}`);
    return { accept: true, dependencies: result.manifest.dependencies };
  } catch (error) {
    if (error instanceof Rejection) return { accept: false, diagnostic: error.message };
    throw error; // Setup and infrastructure errors must remain failures.
  } finally {
    await fs.rm(temporary, { recursive: true, force: true });
  }
}
