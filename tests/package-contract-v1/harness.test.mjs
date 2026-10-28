import test from 'node:test';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';
import { loadCases, expand } from './vectors.mjs';
import { compare } from './run.mjs';

const fakeReader = fileURLToPath(new URL('./support/jsonl-reader.mjs', import.meta.url));
const command = mode => [process.execPath, fakeReader, mode];
const fixture = (id, input, accept) => ({ id: `manifest/${id}`, kind: 'manifest', input, expected: { accept }, rule: 'test-only' });
const cases = [fixture('positive', 'ok', true), fixture('negative', 'bad', false)];
const bridge = async () => (await import('./jsonl.mjs')).runReader;

test('bridge runs one reader and preserves raw escaped duplicate keys', async () => {
  const runReader = await bridge();
  const input = '{"name":"@a/b","na\\u006de":"@c/d","version":"1.0.0"}';
  const result = runReader(command('valid'), [fixture('raw', input, false)]);
  assert.equal(result.get('manifest/raw').observedInput, input);
  assert.equal(result.size, 1);
});

test('bridge returns positive and negative reader results with their IDs', async () => {
  const runReader = await bridge();
  const result = runReader(command('valid'), cases);
  for (const item of cases) assert.equal(compare(item, result.get(item.id)), null);
});

for (const [mode, diagnostic] of [
  ['omit', /missing result.*manifest\/positive/],
  ['duplicate', /duplicate result.*manifest\/positive/],
  ['unknown', /unexpected result.*manifest\/not-requested/],
  ['malformed', /invalid JSON.*line 1/],
  ['fail', /exit 7.*fixture reader failed/s],
]) {
  test(`bridge exposes ${mode} output as an error`, async () => {
    const runReader = await bridge();
    assert.throws(() => runReader(command(mode), cases), diagnostic);
  });
}

test('bridge reports a missing executable as setup failure', async () => {
  const runReader = await bridge();
  assert.throws(() => runReader(['/no/such/package-contract-reader'], cases), /reader could not start.*ENOENT/s);
});

test('runner requires a diagnostic and checks source path order', () => {
  assert.match(compare({ expected: { accept: false } }, { accept: false }), /diagnostic/);
  assert.match(compare({ expected: { accept: true, artifact: ['a.dew', 'a/z.dew'] } },
    { accept: true, artifact: ['a/z.dew', 'a.dew'] }), /artifact/);
  assert.match(compare({ expected: { accept: true } }, { accept: false, diagnostic: 'wrong field' }), /expected true/);
});

test('text recipes count UTF-8 bytes and reject excessive expansion', () => {
  assert.equal(expand({ concat: ['@a/', { repeat: 'b', count: 252 }] }).length, 255);
  assert.equal(Buffer.byteLength(expand({ concat: [{ repeat: '\u00e9', count: 2046 }, '.dew'] })), 4096);
  assert.throws(() => expand({ repeat: 'a', count: 1048578 }), /excessive/);
  assert.throws(() => expand({ repeat: '\u00e9', count: 600000 }), /excessive/);
  assert.throws(() => expand({ concat: [42] }), /invalid/);
});

test('manifest byte boundaries and one-case rule controls stay exact', async () => {
  const all = await loadCases();
  const byId = new Map(all.map(item => [item.id, item]));
  for (const size of [1048576, 1048577]) {
    const item = byId.get(`manifest/bytes-${size}`);
    assert.equal(Buffer.byteLength(item.input), size);
    assert.deepEqual(JSON.parse(item.input).dependencies, {});
  }
  assert.ok(byId.get('manifest/duplicate-name-escaped').input.includes('na\\u006de'));
  assert.ok(byId.get('manifest/duplicate-dependency-escaped').input.includes('@c\\u002fd'));
  assert.equal(byId.get('manifest/dependencies-absent').expected.accept, true);
  assert.equal(byId.get('manifest/dependencies-empty').expected.accept, true);
  assert.equal(all.length, 179);
});
