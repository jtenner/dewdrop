import fs from 'node:fs';
import {performance} from 'node:perf_hooks';
for (const size of [64,512,4096]) {
  const module = await WebAssembly.compile(fs.readFileSync(`.tmp/bench-${size}.wasm`));
  if (WebAssembly.Module.imports(module).length) throw Error('production probe has host imports');
  const instance = await WebAssembly.instantiate(module, {});
  const run = instance.exports.main;
  for(let i=0;i<2000;i++) if(run()!==1) throw Error('wrong query result');
  global.gc();
  const before = process.memoryUsage();
  const samples=[];
  for(let sample=0;sample<7;sample++) {
    const start=performance.now();
    for(let i=0;i<10000;i++) if(run()!==1) throw Error('wrong query result');
    samples.push((performance.now()-start)*1000/10000);
  }
  global.gc();
  const after = process.memoryUsage();
  samples.sort((a,b)=>a-b);
  console.log(JSON.stringify({bytes:size, calls:70000, median_us:samples[3], min_us:samples[0], heap_delta:after.heapUsed-before.heapUsed, rss_delta:after.rss-before.rss, before, after}));
}
