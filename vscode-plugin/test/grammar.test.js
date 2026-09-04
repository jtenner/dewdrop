'use strict';
const assert = require('node:assert/strict');
const { test, before } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const { Registry, parseRawGrammar, INITIAL } = require('vscode-textmate');
const { loadWASM, OnigScanner, OnigString } = require('vscode-oniguruma');
let grammar;
before(async () => {
  const wasm = fs.readFileSync(require.resolve('vscode-oniguruma/release/onig.wasm'));
  await loadWASM(wasm.buffer.slice(wasm.byteOffset, wasm.byteOffset + wasm.byteLength));
  const registry = new Registry({
    onigLib: Promise.resolve({ createOnigScanner: patterns => new OnigScanner(patterns), createOnigString: text => new OnigString(text) }),
    loadGrammar: async () => parseRawGrammar(fs.readFileSync(path.join(__dirname, '../syntaxes/dew.tmLanguage.json'), 'utf8'), 'dew.json'),
  });
  grammar = await registry.loadGrammar('source.dew');
});
function check(line, word, scope, state = INITIAL) {
  const result = grammar.tokenizeLine(line, state);
  const offset = line.indexOf(word);
  assert.ok(offset >= 0, `missing fixture word: ${word}`);
  const token = result.tokens.find(token => token.startIndex <= offset && token.endIndex > offset);
  assert.ok(token.scopes.includes(scope), `${word}: expected ${scope}, got ${token.scopes.join(', ')}`);
  return result.ruleStack;
}
test('colors declarations, calls, types, control flow, aliases, and booleans', () => {
  for (const [line, word, scope] of [
    ['pub fn greet(name: String) -> Unit {', 'greet', 'entity.name.function.dew'],
    ['struct Person {', 'Person', 'entity.name.type.dew'],
    ['let n: U64 = 1u64', 'U64', 'support.type.dew'],
    ['using resource = acquire()', 'using', 'keyword.other.dew'],
    ['defer { close() }', 'defer', 'keyword.control.dew'],
    ['if x is Some(_) { true }', 'is', 'keyword.control.dew'],
    ['if true {}', 'true', 'constant.language.boolean.dew'],
    ['@wasm.i64_trunc_i32(value)', '@wasm.i64_trunc_i32', 'variable.other.namespace.dew'],
    ['fn café() {}', 'café', 'entity.name.function.dew'],
    ['read::<I32>()', 'read', 'entity.name.function.dew'],
  ]) check(line, word, scope);
});
test('colors Dew numbers with suffixes, separators, and exponents', () => {
  for (const number of ['1', '1i8', '12_345u64', '1UL', '1U', '1L']) check(`let x = ${number}`, number, 'constant.numeric.integer.dew');
  for (const number of ['.5', '1.0', '1.0F', '1.0e-3f32']) check(`let x = ${number}`, number, 'constant.numeric.float.dew');
});
test('strings and comments prevent keywords from receiving code scopes', () => {
  check('// fn fake() {}', 'fn', 'comment.line.double-slash.dew');
  check('let text = "fn fake"', 'fn', 'string.quoted.double.dew');
  check('let bytes = b"fn fake"', 'fn', 'string.quoted.double.dew');
  check('  #| fn fake " //', 'fn', 'string.unquoted.multiline.dew');
  check('"hello\\n\\x41"', '\\n', 'constant.character.escape.dew');
  check('"hello\\q"', '\\q', 'invalid.illegal.escape.dew');
});
test('unterminated strings and marked lines do not hide the following code', () => {
  for (const line of ['let text = "unfinished', ' #| text', '// text']) {
    const state = grammar.tokenizeLine(line, INITIAL).ruleStack;
    check('fn next() {}', 'next', 'entity.name.function.dew', state);
  }
});
test('package paths and snippets are valid', () => {
  const root = path.join(__dirname, '..');
  const manifest = require('../package.json');
  for (const file of [manifest.main, ...manifest.contributes.languages.map(x => x.configuration), ...manifest.contributes.grammars.map(x => x.path), ...manifest.contributes.snippets.map(x => x.path)]) {
    assert.ok(fs.statSync(path.join(root, file)).isFile(), file);
  }
  const snippets = require('../snippets/dew.json');
  assert.ok(Object.keys(snippets).length >= 10);
  for (const snippet of Object.values(snippets)) {
    assert.ok(snippet.prefix);
    assert.ok(snippet.body.join('\n').includes('$0') || snippet.body.join('\n').includes('${0:'));
  }
  assert.equal(require('../language-configuration.json').comments.lineComment, '//');
});
