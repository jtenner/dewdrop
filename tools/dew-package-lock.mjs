// Strict local dew.lock v1 input. No resolution, filesystem, or network work.
import { MAX_PATH_BYTES, MAX_REQUIREMENT_BYTES, validatePackageName, validatePackageVersion } from './dew-package-contract.mjs';

export const MAX_LOCK_BYTES = 8 * 1_048_576;
export const MAX_LOCK_PACKAGES = 4096;

function parseStrictJson(text) {
  if (typeof text !== 'string' || Buffer.byteLength(text) > MAX_LOCK_BYTES) throw new Error('lockfile exceeds the 8 MiB limit');
  let offset = 0;
  let values = 0;
  const fail = message => { throw new Error(`invalid lockfile JSON: ${message} at ${offset}`); };
  function whitespace() { while (offset < text.length && ' \t\r\n'.includes(text[offset])) offset++; }
  function token(expected) {
    whitespace();
    if (text[offset++] !== expected) fail(`expected ${expected}`);
  }
  function string() {
    whitespace();
    if (text[offset] !== '"') fail('expected string');
    const start = offset++;
    while (offset < text.length) {
      const char = text[offset++];
      if (char === '\\') offset++;
      else if (char === '"') {
        let value;
        try { value = JSON.parse(text.slice(start, offset)); }
        catch { fail('invalid string'); }
        if (/[\uD800-\uDFFF]/u.test(value) || Buffer.byteLength(value) > MAX_PATH_BYTES) fail('invalid Unicode or string exceeds 4096 bytes');
        return value;
      }
    }
    fail('unterminated string');
  }
  function value(depth, lockVersion = false) {
    if (depth > 16 || ++values > 65536) fail('depth or value limit exceeded');
    whitespace();
    if (text[offset] === '"') return string();
    if (text[offset] === '{') {
      offset++;
      const result = Object.create(null);
      whitespace();
      if (text[offset] === '}') { offset++; return result; }
      for (;;) {
        const key = string();
        if (Object.hasOwn(result, key)) fail(`duplicate decoded field ${key}`);
        token(':');
        result[key] = value(depth + 1, depth === 0 && key === 'lockfileVersion');
        whitespace();
        if (text[offset] === '}') { offset++; return result; }
        token(',');
      }
    }
    if (text[offset] === '[') {
      offset++;
      const result = [];
      whitespace();
      if (text[offset] === ']') { offset++; return result; }
      for (;;) {
        result.push(value(depth + 1));
        whitespace();
        if (text[offset] === ']') { offset++; return result; }
        token(',');
      }
    }
    const start = offset;
    while (offset < text.length && !' \t\r\n,]}'.includes(text[offset])) offset++;
    if (start === offset) fail('expected value');
    const representation = text.slice(start, offset);
    if (lockVersion && representation !== '1') fail('lockfileVersion must use literal JSON 1');
    try { return JSON.parse(representation); }
    catch { fail('invalid scalar'); }
  }
  const result = value(0);
  whitespace();
  if (offset !== text.length) fail('trailing data');
  return result;
}

function fields(value, allowed, label) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error(`${label} must be an object`);
  for (const key of Object.keys(value)) if (!allowed.has(key)) throw new Error(`unknown ${label} field: ${key}`);
  for (const key of allowed) if (!Object.hasOwn(value, key)) throw new Error(`missing ${label} field: ${key}`);
}

function text(value, limit, label) {
  if (typeof value !== 'string' || value.length === 0 || Buffer.byteLength(value) > limit) throw new Error(`${label} must be a nonempty string of at most ${limit} bytes`);
}

const rootFields = new Set(['lockfileVersion', 'packages']);
const packageFields = new Set(['name', 'version', 'source', 'path', 'integrity', 'interface']);

export function parsePackageLock(input) {
  const lock = parseStrictJson(input);
  fields(lock, rootFields, 'lockfile');
  if (lock.lockfileVersion !== 1) throw new Error('lockfileVersion must be 1');
  if (!Array.isArray(lock.packages) || lock.packages.length > MAX_LOCK_PACKAGES) throw new Error('lockfile packages must be an array of at most 4096 records');
  const names = new Set();
  for (const entry of lock.packages) {
    fields(entry, packageFields, 'locked package');
    validatePackageName(entry.name, 'locked package name');
    validatePackageVersion(entry.version, 'locked package version');
    if (names.has(entry.name)) throw new Error(`duplicate locked package name: ${entry.name}`);
    names.add(entry.name);
    text(entry.source, MAX_REQUIREMENT_BYTES, 'locked package source');
    text(entry.path, MAX_PATH_BYTES, 'locked package path');
    if (entry.path.startsWith('/') || /^[A-Za-z]:\//.test(entry.path) || entry.path.includes('\\') || entry.path.includes('\0') || entry.path.split('/').some(segment => segment === '' || segment === '.' || segment === '..')) throw new Error(`unsafe locked package path: ${entry.path}`);
    if (typeof entry.integrity !== 'string' || !/^sha256-[0-9a-f]{64}$/.test(entry.integrity) || typeof entry.interface !== 'string' || !/^[0-9a-f]{64}$/.test(entry.interface) || entry.integrity.length !== 71 || entry.interface.length !== 64) throw new Error(`invalid locked package provenance: ${entry.name}`);
  }
  return lock;
}
