import fs from 'node:fs';
import {performance} from 'node:perf_hooks';
const {instance} = await WebAssembly.instantiate(fs.readFileSync(process.argv[2]), {});
instance.exports.__dew_init?.();
if (instance.exports.main() !== 7) throw Error('capsule oracle');
console.log('wasm_bytes', fs.statSync(process.argv[2]).size);
console.log('memory_exports', Object.entries(instance.exports).filter(([,value])=>value instanceof WebAssembly.Memory).map(([name])=>name));
console.log('imports', WebAssembly.Module.imports(await WebAssembly.compile(fs.readFileSync(process.argv[2]))));
for (const name of ["scan", "roundtrip"]) {
for (const count of [1000,10000,100000]) {
  for(let i=0;i<10;i++) if(instance.exports[name](count)!==count) throw Error('scan oracle');
  global.gc();
  const before=process.memoryUsage();
  const times=[];
  for(let i=0;i<21;i++) {
    const start=performance.now();
    if(instance.exports[name](count)!==count) throw Error('scan oracle');
    times.push(performance.now()-start);
  }
  global.gc();
  times.sort((a,b)=>a-b);
  console.log(JSON.stringify({name,count,median_ms:times[10],before,after:process.memoryUsage()}));
}
}
