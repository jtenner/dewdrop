import fs from 'node:fs';
import {performance} from 'node:perf_hooks';
const [path, sizeText, kind] = process.argv.slice(2);
const size = Number(sizeText);
const {instance} = await WebAssembly.instantiate(fs.readFileSync(path), {});
const run = () => {
  if (instance.exports.main() !== size) throw new Error('wrong scan count');
};
for (let i=0; i<100; i++) run();
global.gc();
const before = process.memoryUsage();
const times=[];
for (let sample=0; sample<21; sample++) {
  const start=performance.now();
  for (let i=0; i<20; i++) run();
  times.push((performance.now()-start)*1000/20);
}
global.gc();
const after = process.memoryUsage();
times.sort((a,b)=>a-b);
console.log(JSON.stringify({kind, bytes:size, scans:size, comparison_bound:2*size,
  median_us:times[10], heap_before:before.heapUsed, heap_after:after.heapUsed,
  rss_before:before.rss, rss_after:after.rss, wasm_bytes:fs.statSync(path).size}));
