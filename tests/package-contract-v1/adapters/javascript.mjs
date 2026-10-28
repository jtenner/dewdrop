// Adapter for the Phase 1 JS contract, in this repo after merge or a read-only peer checkout.
import * as fs from 'node:fs/promises';
import { tmpdir } from 'node:os';
import * as path from 'node:path';
import { pathToFileURL } from 'node:url';
import { fixtureRoot } from '../vectors.mjs';
import { parsePackageLock } from '../../../tools/dew-package-lock.mjs';

const modulePath = path.resolve(process.env.DEW_CONTRACT_JS_MODULE ?? path.join(fixtureRoot, '../../tools/dew-package-contract.mjs'));
const api = await import(pathToFileURL(modulePath).href);
const entry = process.env.DEW_CONTRACT_JS_ENTRY ?? 'parse';
if (!['parse', 'read'].includes(entry)) throw new Error('DEW_CONTRACT_JS_ENTRY must be parse or read');
export const kinds = ['manifest', 'lock', 'name', 'semver', 'requirement', 'source-selection', 'artifact-paths'];
const limits = JSON.parse(await fs.readFile(path.join(fixtureRoot, 'limits.json'), 'utf8'));
for (const [exportName, key] of Object.entries({
  MAX_MANIFEST_BYTES: 'manifestBytes', MAX_NAME_BYTES: 'nameBytes', MAX_VERSION_BYTES: 'semverBytes',
  MAX_REQUIREMENT_BYTES: 'requirementBytes', MAX_DEPENDENCIES: 'directDependencies',
  MAX_PATH_BYTES: 'logicalPathBytes', MAX_SOURCE_BYTES: 'sourceBytes', MAX_FILES: 'files',
  MAX_CAPSULE_BYTES: 'publishEncodedBytes', MAX_LOCAL_ARTIFACT_BYTES: 'localArtifactEncodedBytes',
})) {
  if (api[exportName] !== limits[key]) throw new Error(`JS exported bound mismatch: ${exportName}`);
}

const reasonPatterns = {
  'name-grammar': /package name/i, 'name-byte-limit': /package name.*bytes/i,
  'strict-semver': /package version/i, 'semver-byte-limit': /package version.*bytes/i,
  'requirement-grammar': /dependency requirement/i, 'requirement-byte-limit': /dependency requirement.*bytes/i,
  'nested-semver-limit': /dependency requirement version.*bytes/i,
  'unknown-field': /unknown (package manifest|lockfile|locked package) field/i, 'required-name': /package name/i,
  'required-version': /package version/i, 'name-type': /name.*string/i, 'version-type': /version.*string/i,
  'dependency-object': /invalid manifest JSON: expected '\{'/i, 'dependency-name': /dependency name/i,
  'dependency-string': /dependency requirement must be a string/i,
  'manifest-object': /invalid manifest JSON: expected '\{'/i,
  'duplicate-decoded-key': /duplicate (manifest|dependency) key|duplicate decoded field/i,
  'locked-record': /locked package/i, 'duplicate-locked-name': /duplicate locked package name/i,
  'lock-version': /lockfileVersion/i,
  'json-syntax': /invalid manifest JSON/i, 'dependency-count': /dependencies exceed/i,
  'manifest-byte-limit': /package manifest exceeds/i,
  'file-count': /capsule files must contain/i, 'relative-path': /invalid source path/i,
  'path-segments': /source path/i, 'slash-path': /invalid source path/i,
  'path-nul': /invalid source path/i, 'source-extension': /invalid source path/i,
  'reserved-manifest-prefix': /invalid source path/i, 'duplicate-path': /duplicate source path/i,
  'path-prefix-conflict': /source path prefix conflict/i, 'path-byte-limit': /source path.*bytes/i,
  'reject-symlink': /symlink/i, 'source-required': /no conventional \.dew sources/i,
};

async function observed(call, test) {
  try { return await call(); }
  catch (error) {
    // OS/setup failures are never package validation results.
    if (error.code) throw error;
    if (!test.expected.accept) {
      const pattern = reasonPatterns[test.rule];
      if (!pattern || !pattern.test(error.message)) throw new Error(`wrong rejection for ${test.id}: ${error.message}`);
    }
    return { accept: false, diagnostic: error.message };
  }
}

async function withPackage(action) {
  const temporary = await fs.mkdtemp(path.join(tmpdir(), 'dew-contract-js-'));
  const root = path.join(temporary, 'package');
  await fs.mkdir(root);
  try { return await action(root); }
  finally { await fs.rm(temporary, { recursive: true, force: true }); }
}

export async function evaluate(kind, input, test) {
  if (kind === 'lock') return observed(() => {
    parsePackageLock(input);
    return { accept: true };
  }, test);
  if (kind === 'source-selection') return withPackage(async root => {
    for (const item of input.entries) {
      const target = path.resolve(root, item.path);
      if (!target.startsWith(root + path.sep)) throw new Error(`unsafe fixture entry: ${item.path}`);
      await fs.mkdir(path.dirname(target), { recursive: true });
      if (item.type === 'file') await fs.writeFile(target, item.text);
      else if (item.type === 'directory') await fs.mkdir(target, { recursive: true });
      else if (item.type === 'symlink') await fs.symlink(item.target, target);
      else throw new Error(`unknown fixture entry: ${item.type}`);
    }
    return observed(async () => {
      const artifact = (await api.collectSourceFiles(root)).map(file => file.path);
      return { accept: true, artifact, compiler: artifact.filter(file => !file.endsWith('_test.dew')) };
    }, test);
  });
  if (kind === 'artifact-paths') return observed(() => {
    api.encodeCapsule({
      manifest: { name: '@a/b', version: '1.0.0' },
      files: input.map(path => ({ path, contents: Buffer.from('x') })),
      source: 'registry:https://example.invalid', interfaceFingerprint: '0'.repeat(64), integrity: `sha256-${'0'.repeat(64)}`,
    });
    return { accept: true };
  }, test);
  if (!kinds.includes(kind)) throw new Error(`unsupported kind: ${kind}`);
  const value = { name: '@a/b', version: '1.0.0', dependencies: {} };
  if (kind === 'name') value.name = input;
  if (kind === 'semver') value.version = input;
  if (kind === 'requirement') value.dependencies['@c/d'] = input;
  const text = kind === 'manifest' ? input : JSON.stringify(value);
  const result = manifest => ({ accept: true, dependencies: manifest.dependencies });
  if (entry === 'parse') return observed(() => result(api.parsePackageManifest(text)), test);
  return withPackage(async root => {
    const file = path.join(root, 'dew.json');
    await fs.writeFile(file, text);
    return observed(async () => result(await api.readPackageManifest(file)), test);
  });
}
