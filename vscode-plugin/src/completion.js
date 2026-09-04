'use strict';

const keywords = 'fn test pub builtin foreign impl trait for enum struct type let using mut if else match is while loop return defer break continue true false as in where open import export package derive self'.split(' ');
const types = 'Unit Bool I8 I16 I32 I64 U8 U16 U32 U64 F32 F64 String Bytes StringView StringBuilder BytesBuilder V128 Swar32 Swar64 I8x4 U8x4 I16x2 U16x2 I8x8 U8x8 I16x4 U16x4 I32x2 U32x2 I8x16 U8x16 I16x8 U16x8 I32x4 U32x4 I64x2 U64x2 F32x4 F64x2 Self'.split(' ');
// Match the tokenizer's broad non-ASCII identifier rule, not ASCII-only \w.
const start = '[A-Za-z_\\P{ASCII}]';
const part = '[A-Za-z_0-9\\P{ASCII}]';
// Non-ASCII whitespace is removed before scanning identifiers.
const identifier = `${start}${part}*`;
const namePattern = new RegExp(`@${identifier}(?:\\.${identifier})*|${identifier}`, 'gu');
const tokenPattern = new RegExp(`//[^\\r\\n]*|#\\|[^\\r\\n]*|b?"(?:\\\\[^\\r\\n]|[^"\\\\\\r\\n])*(?:"|(?=[\\r\\n]|$))|(?:[0-9][A-Za-z_0-9]*(?:\\.[0-9][A-Za-z_0-9]*)?|\\.[0-9][A-Za-z_0-9]*)(?:[eE][+-]?[0-9][A-Za-z_0-9]*)?|@${identifier}(?:\\.${identifier})*|${identifier}`, 'gu');
const baseItems = [
  ...keywords.map(label => ({ label, kind: 'Keyword', detail: 'Dew keyword' })),
  ...types.map(label => ({ label, kind: 'Class', detail: 'Dew type' })),
];
const reserved = new Set([...keywords, ...types]);

function analyze(text) {
  const names = new Map();
  for (const match of text.replace(/[^\S\r\n]/gu, ' ').matchAll(tokenPattern)) {
    const label = match[0];
    if (label.startsWith('//') || label.startsWith('#|') || label.includes('"') || /^[0-9.]/u.test(label)) continue;
    if (!reserved.has(label) && !names.has(label)) {
      names.set(label, { label, kind: 'Text', detail: 'Name in this file (not type checked)' });
    }
  }
  return [...baseItems, ...names.values()];
}

function inText(line) {
  let quoted = false;
  for (let i = 0; i < line.length; i++) {
    if (quoted && line[i] === '\\') { i++; continue; }
    if (line[i] === '"') { quoted = !quoted; continue; }
    if (!quoted && (line.slice(i, i + 2) === '//' || line.slice(i, i + 2) === '#|')) return true;
  }
  return quoted;
}

function prefixAt(line) {
  let prefix = '';
  for (const match of line.replace(/[^\S\r\n]/gu, ' ').matchAll(namePattern)) {
    if (match.index + match[0].length === line.length) prefix = match[0];
  }
  return prefix;
}

function complete(items, line) {
  if (inText(line)) return [];
  const prefix = prefixAt(line);
  return items.filter(item => item.label.startsWith(prefix));
}

function createCache() {
  const documents = new Map();
  return {
    get(document) {
      const key = document.uri.toString();
      let entry = documents.get(key);
      if (!entry || entry.version !== document.version) {
        entry = { version: document.version, items: analyze(document.getText()) };
        documents.set(key, entry);
      }
      return entry.items;
    },
    delete(document) { documents.delete(document.uri.toString()); },
    clear() { documents.clear(); },
  };
}

module.exports = { analyze, complete, createCache, prefixAt, inText };
