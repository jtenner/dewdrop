import assert from 'node:assert/strict';
import {readFileSync, mkdtempSync, mkdirSync, writeFileSync, symlinkSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {WASI} from 'node:wasi';
import {performance} from 'node:perf_hooks';

const module = new WebAssembly.Module(readFileSync(process.argv[2]));
const error = code => 0xffffffff00000000n + BigInt(code);
const record = (cookie, name, kind = 4) => {
  name = typeof name === 'string' ? Buffer.from(name) : name;
  const bytes = Buffer.alloc(24 + name.length);
  bytes.writeBigUInt64LE(BigInt(cookie)); bytes.writeUInt32LE(name.length, 16);
  bytes[20] = kind; bytes.set(name, 24); return bytes;
};
const hash = (name, kind) => ((Buffer.from(name).reduce((v, b) => (Math.imul(v, 31) + b) >>> 0, 0) * 8 + kind) >>> 0);
let checks = 0;
let memory, scenario, opened, closed, reads;
const defaults = {data: Buffer.alloc(0)};
function reset(values = {}) { scenario = {...defaults, ...values}; opened = []; closed = []; reads = 0; }
const imports = {};
for (const entry of WebAssembly.Module.imports(module)) {
  imports[entry.module] ??= {};
  imports[entry.module][entry.name] = () => {throw Error(`unexpected import ${entry.name}`);};
}
Object.assign(imports.wasi_snapshot_preview1, {
  path_filestat_get(parent, flags, pointer, length, result) {
    assert.equal(flags, 0, 'stat does not follow links');
    assert.equal(parent, opened.length ? opened.at(-1).fd : 3);
    if (scenario.statError && opened.length === (scenario.failAt ?? 0)) return scenario.statError;
    new Uint8Array(memory.buffer)[result + 16] = scenario.symlinkAt === opened.length ? 7 : scenario.notDirectory ? 4 : 3;
    return 0;
  },
  path_open(parent, flags, pointer, length, oflags, rights, inheriting, fdflags, result) {
    assert.equal(flags, 0, 'no link lookup'); assert.equal(oflags, 2, 'directory only');
    assert.equal(rights, 286720n); assert.equal(inheriting, 286720n); assert.equal(fdflags, 0);
    const name = Buffer.from(memory.buffer, pointer, length).toString();
    assert.ok(!name.includes('/'), 'open one path component');
    assert.equal(parent, opened.length ? opened.at(-1).fd : 3);
    if (scenario.openError && opened.length === (scenario.failAt ?? 0)) return scenario.openError;
    const fd = 10 + opened.length; opened.push({fd, name});
    new DataView(memory.buffer).setUint32(result, fd, true); return 0;
  },
  fd_readdir(fd, pointer, length, cookie, used) {
    assert.equal(fd, opened.at(-1).fd); assert.ok(length >= 24 && length <= 49152);
    assert.equal(pointer, 8192); reads++;
    if (scenario.readError) return scenario.readError;
    const data = scenario.data;
    const size = Math.min(length, data.length);
    new Uint8Array(memory.buffer, pointer, size).set(data.subarray(0, size));
    new DataView(memory.buffer).setUint32(used, scenario.excess ? length + 1 : size, true); return 0;
  },
  fd_close(fd) { assert.ok(opened.some(x => x.fd === fd)); assert.ok(!closed.includes(fd)); closed.push(fd); return scenario.closeError ?? 0; },
});
const instance = new WebAssembly.Instance(module, imports); memory = instance.exports.memory;
instance.exports.__dew_init?.();
const invoke = (...args) => BigInt.asUintN(64, instance.exports.main(...args));
function run(values, expected, mode = 16, cookie = 0n, count = 100, bytes = 1024) {
  reset(values); assert.equal(invoke(mode, cookie, count, bytes), expected);
  assert.deepEqual([...closed].sort(), opened.map(x => x.fd).sort(), 'every handle closes'); checks++;
}
run({}, 0x80000000n);
run({data: record(1, 'x')}, 0x80000001n);
run({data: record(1, 'x', 7)}, BigInt(hash('x', 7)), 8);
run({data: Buffer.from('x')}, error(2));
for (let n = 1; n < 25; n++) run({data: record(1, 'x').subarray(0, n)}, error(2));
run({data: record(1, Buffer.from([255]))}, error(5));
for (const name of ['', 'a/b', 'a\\b', '\0']) run({data: record(1, name)}, error(4));
run({data: record(1, 'x', 8)}, error(3));
run({data: record(0, 'x')}, error(6));
run({data: Buffer.concat([record(1, 'a'), record(1, 'b')])}, error(6));
run({data: Buffer.concat([record(1, 'a'), record(0, 'b')])}, error(6));
run({data: record(2, 'x')}, 2n, 0, 9n);
run({data: record(1, 'x')}, 1n, 16, 0n, 10, 25);
run({data: Buffer.concat([record(1, '.'), record(2, '..')])}, 1n, 0, 0n, 1);
run({data: Buffer.concat([record(1, 'a'), record(2, 'b')])}, 1n, 0, 0n, 1);
run({data: record(2, 'b')}, 0x80000001n, 16, 1n);
run({data: Buffer.concat([record(1, 'a'), Buffer.from('tail')])}, 1n, 0);
for (const [count, bytes] of [[0, 64], [2049, 64], [1, 23], [1, 49153]]) {
  run({}, error(1), 16, 0n, count, bytes); assert.equal(opened.length, 0);
}
for (const code of [2, 63]) {
  run({openError: code}, error(7)); run({readError: code}, error(7));
  run({statError: code}, error(7)); run({statError: code, failAt: 1}, error(7), 17);
  run({openError: code, failAt: 1}, error(7), 17);
}
run({symlinkAt: 0}, error(8));
run({symlinkAt: 1}, error(8), 17);
run({notDirectory: true}, error(154));
run({excess: true}, error(3));
run({closeError: 29}, error(229));
run({closeError: 29}, error(229), 17);
run({readError: 29, closeError: 29}, error(129));
run({}, 0x80000000n, 17);

// Real WASI tree. Wrap only to count handles; Node's WASI does all host work.
const root = mkdtempSync(join(tmpdir(), 'dew-directory-'));
try {
  mkdirSync(join(root, 'tree')); mkdirSync(join(root, 'tree/nested'));
  writeFileSync(join(root, 'tree/a'), 'a'); writeFileSync(join(root, 'tree/é'), 'b');
  symlinkSync('nested', join(root, 'tree/link')); symlinkSync('tree', join(root, 'linktree'));
  const wasi = new WASI({version: 'preview1', preopens: {'.': root}, returnOnExit: true});
  const host = {...wasi.wasiImport}; let realMemory; let live = new Set(); let opens = 0, closes = 0;
  const originalOpen = host.path_open, originalClose = host.fd_close;
  host.path_open = (...args) => {
    const code = originalOpen(...args);
    if (!code) { live.add(new DataView(realMemory.buffer).getUint32(args[8], true)); opens++; }
    return code;
  };
  host.fd_close = fd => { assert.ok(live.delete(fd)); closes++; return originalClose(fd); };
  const real = new WebAssembly.Instance(module, {wasi_snapshot_preview1: host});
  realMemory = real.exports.memory; wasi.initialize(real); real.exports.__dew_init?.();
  const call = (...args) => { const result = BigInt.asUintN(64, real.exports.main(...args)); assert.equal(live.size, 0); return result; };
  assert.equal(call(24, 0n, 100, 4096), BigInt((hash('nested', 3) + hash('a', 4) + hash('é', 4) + hash('link', 7)) >>> 0)); checks++;
  assert.equal(call(17, 0n, 100, 4096), 0x80000000n); checks++;
  assert.equal(call(18, 0n, 100, 4096), error(8), 'final symlink rejected'); checks++;
  assert.equal(call(19, 0n, 100, 4096), error(8), 'intermediate symlink rejected'); checks++;
  let cookie = 0n, total = 0, pages = 0;
  for (; pages < 20; pages++) {
    const state = call(16, cookie, 1, 256); assert.ok(state < error(1));
    total += Number(state & 0x7fffffffn);
    const next = call(0, cookie, 1, 256);
    if (state & 0x80000000n) break;
    assert.notEqual(next, cookie); cookie = next;
  }
  assert.ok(pages < 20, 'pagination terminates'); assert.equal(total, 4); checks++;
  assert.equal(opens, closes);
  console.log(`real WASI: ${pages + 1} pages, ${opens} opens, ${closes} closes`);
} finally { rmSync(root, {recursive: true, force: true}); }

// Bounded decoder/host scaling; no claim of an earlier API speedup.
for (const size of [1, 16, 256, 1024, 1966]) {
  const data = Buffer.concat(Array.from({length: size}, (_, i) => record(i + 1, 'x')));
  reset({data}); global.gc?.(); const before = process.memoryUsage(); const started = performance.now();
  for (let i = 0; i < 100; i++) {
    opened = []; closed = []; reads = 0;
    assert.equal(invoke(16, 0n, 2048, 49152), 0x80000000n + BigInt(size));
  }
  const elapsed = performance.now() - started; const after = process.memoryUsage();
  assert.equal(memory.buffer.byteLength, 65536, 'fixed scratch memory');
  console.log(JSON.stringify({records: size, iterations: 100, milliseconds: +elapsed.toFixed(3), linearMemoryBytes: memory.buffer.byteLength, rssBytes: after.rss, heapDeltaBytes: after.heapUsed - before.heapUsed, encodedBytes: data.length}));
}
console.log(`directory host checks passed: ${checks}`);
