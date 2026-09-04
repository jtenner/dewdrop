'use strict';
const assert = require('node:assert/strict');
const { test } = require('node:test');
const { analyze, complete, createCache } = require('../src/completion');

test('offers keywords, primitive types, and names from the current file', () => {
  const data = analyze('fn greet(person: String) -> Unit {\n let mut count = 1\n}\nstruct Person {}');
  const items = complete(data, '');
  for (const label of ['fn', 'using', 'defer', 'is', 'U64', 'greet', 'person', 'count', 'Person']) {
    assert.ok(items.some(item => item.label === label), `missing ${label}`);
  }
  assert.equal(items.filter(item => item.label === 'String').length, 1);
});

test('ignores comments and all string forms, including escaped quotes', () => {
  const data = analyze('let real = "hidden \\" still_hidden" // comment_name\n#| raw_name\nlet blob = b"byte_name"\n');
  const labels = complete(data, '').map(item => item.label);
  assert.ok(labels.includes('real'));
  for (const name of ['hidden', 'still_hidden', 'comment_name', 'raw_name', 'byte_name']) assert.ok(!labels.includes(name), name);
});

test('suppresses completion inside comments and strings but recovers on next line', () => {
  for (const line of ['// note', '#| text', 'let x = "text', 'let b = b"text']) {
    assert.deepEqual(complete(analyze(''), line), [], line);
  }
  assert.ok(complete(analyze(''), 'let x = "done"; ').length);
  assert.ok(complete(analyze(''), 'let next = ').length);
});

test('supports Unicode names, aliases, and prefix filtering', () => {
  const data = analyze('import app.util as @util\nlet café = 1\n@util.read()\nlet caféine = café');
  assert.deepEqual(complete(data, 'caf').map(item => item.label), ['café', 'caféine']);
  assert.ok(complete(data, '@ut').some(item => item.label === '@util'));
  assert.ok(complete(data, '@util.re').some(item => item.label === '@util.read'));
});

test('does not split numeric suffixes into names', () => {
  const labels = complete(analyze('let x = 12_345u32 + .5f32 + 1.0e-3F'), '').map(item => item.label);
  for (const name of ['u32', 'f32', 'e', 'F']) assert.ok(!labels.includes(name), name);
});

test('cache reuses each document version and discards closed files', () => {
  const cache = createCache();
  let reads = 0;
  const document = { uri: { toString: () => 'untitled:one' }, version: 1, getText: () => { reads++; return 'let first = 1'; } };
  const first = cache.get(document);
  assert.equal(cache.get(document), first);
  assert.equal(reads, 1);
  document.version++;
  assert.notEqual(cache.get(document), first);
  cache.delete(document);
  cache.get(document);
  assert.equal(reads, 3);
});
