import {readFileSync} from 'node:fs';
import assert from 'node:assert/strict';
if (!process.argv.includes('--wat-only')) {
const {instance:{exports:e}}=await WebAssembly.instantiate(readFileSync('.tmp/consumer.wasm'),{});
e.__dew_init?.();assert.equal(e.main(),-(1n<<63n));
for(const size of [1,20,200]){
 const f=e['parse'+size];for(let i=0;i<10000;i++)assert.equal(f(),7n);
 global.gc();const before=process.memoryUsage();const start=performance.now();
 for(let i=0;i<100000;i++)assert.equal(f(),7n);
 const ms=performance.now()-start;global.gc();const after=process.memoryUsage();
 console.log(JSON.stringify({digits:size,calls:100000,ms,heapDelta:after.heapUsed-before.heapUsed,rssDelta:after.rss-before.rss}));
}
}
const wat=readFileSync('.tmp/consumer.wat','utf8');
console.log('WAT allocation instructions:',Object.fromEntries(['array.new','array.copy','struct.new','memory.grow'].map(op=>[op,(wat.match(new RegExp(op.replace('.','\\.'),'g'))||[]).length])));

const fixtureFunctions=new Set([...wat.matchAll(/\(export "(?:parse1|parse20|parse200|main)" \(func (\d+)\)\)/g)].map(m=>m[1]));
assert.equal(fixtureFunctions.size,4);
const functions=wat.split(/(?=  \(func \(;\d+;\))/).slice(1);
for(const body of functions){
 const index=body.match(/\(func \(;(\d+);\)/)[1];
 assert.ok(!body.includes('array.copy'),'no text copy');
 if(!fixtureFunctions.has(index))assert.ok(!body.includes('array.new'),'no parser backing-array allocation');
}
console.log('PASS: all backing-array allocations are input literals in consumer functions; none in parser or text helpers');
