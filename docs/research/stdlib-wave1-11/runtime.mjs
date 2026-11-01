import assert from 'node:assert/strict';
import {readFileSync, openSync, closeSync} from 'node:fs';
import {WASI} from 'node:wasi';
import {performance} from 'node:perf_hooks';
const pure = new WebAssembly.Module(readFileSync(process.argv[2]));
assert.equal(WebAssembly.Module.customSections(pure, 'dew.tests').length, 0);
const imports = {};
const entries = WebAssembly.Module.imports(pure);
assert.deepEqual(entries, [], 'pure Process consumer must have no host imports');
console.log('pure imports:', JSON.stringify(entries));
const instance = new WebAssembly.Instance(pure, imports);
instance.exports.__dew_init?.();
assert.equal(instance.exports.main(), 4);
for (let i=0;i<1000;i++) assert.equal(instance.exports.main(),4);
for (const n of [10000,100000]) {
  global.gc();
  const before=process.memoryUsage();
  const start=performance.now();
  for(let i=0;i<n;i++) assert.equal(instance.exports.main(),4);
  const ms=performance.now()-start;
  global.gc();
  const after=process.memoryUsage();
  console.log(JSON.stringify({calls:n, processWrites:n*4, bytes:n*10, ms, before, after}));
}
if (process.argv[4]) {
  const module = new WebAssembly.Module(readFileSync(process.argv[4]));
  assert.deepEqual(WebAssembly.Module.imports(module), entries);
  const inst = new WebAssembly.Instance(module, imports);
  inst.exports.__dew_init?.();
  assert.equal(inst.exports.main(), 128);
  for (const n of [100, 1000]) {
    global.gc();
    const before = process.memoryUsage(), start = performance.now();
    for (let i=0;i<n;i++) assert.equal(inst.exports.main(),128);
    const ms = performance.now()-start;
    global.gc();
    console.log(JSON.stringify({largeCalls:n, processWrites:n*128, bytes:n*8192, ms, before, after:process.memoryUsage()}));
  }
}
if (process.argv[3]) {
  const outPath='.tmp/wasi.stdout', errPath='.tmp/wasi.stderr';
  const out=openSync(outPath,'w'), err=openSync(errPath,'w');
  try {
    const wasi=new WASI({version:'preview1', stdout:out, stderr:err, returnOnExit:true});
    const module=new WebAssembly.Module(readFileSync(process.argv[3]));
    const inst=new WebAssembly.Instance(module,{wasi_snapshot_preview1:wasi.wasiImport,'dewdrop.transform.workers':{capacity:()=>0}});
    wasi.initialize(inst);
    inst.exports.__dew_init?.();
    assert.equal(inst.exports.main(),0);
  } finally {closeSync(out); closeSync(err);}
  assert.deepEqual(readFileSync(outPath),Buffer.from([111,117,116,0,128,255,10]));
  assert.deepEqual(readFileSync(errPath),Buffer.from([101,114,114,0,128,255,10]));
  console.log('WASI stdout/stderr: separate channels, exact binary bytes passed');
}
