// Count original Wasm instructions in copies; this is not a runtime benchmark.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
const [directory,variant] = process.argv.slice(2);
const {instance} = await WebAssembly.instantiate(fs.readFileSync(path.join(directory,`${variant}-inspect.wasm`)),{});
const e=instance.exports, sites=JSON.parse(fs.readFileSync(path.join(directory,`${variant}-sites.json`)));
const report={};
function record(name,action,operations,publicResults=0) {
  e.reset_allocations(); const value=action();
  const counts=Object.fromEntries(Object.entries(sites).map(([k,s])=>[k,{...s,count:Number(e[k].value)}]).filter(([,s])=>s.count));
  const arrays=Object.values(counts).filter(s=>s.opcode.startsWith('array.')).reduce((n,s)=>n+s.count,0);
  const structs=Object.values(counts).filter(s=>s.opcode.startsWith('struct.')).reduce((n,s)=>n+s.count,0);
  assert.equal(arrays,0,name);assert.equal(structs,publicResults,name);
  report[name]={operations,original_wasm_instructions:Number(e.instructions.value),arrays,structs,public_results:publicResults,sites:counts};
  return value;
}
const tree=e.make_numeric(), replacing=e.make_numeric(), fitting=e.make_numeric(),keys=e.numeric_keys(tree);
assert.equal(record('lookup',()=>e.cost_lookup(tree,1024),1024,1024),6912n);
assert.equal(record('direct-control',()=>e.cost_control(keys,1024),1024),6912n);
assert.equal(record('contains',()=>e.cost_contains(tree,1024),1024),496);
record('replace-unit',()=>e.cost_replace(replacing,1000),1000);
assert.equal(record('fit-bool',()=>e.cost_fit(fitting,100),3100),3100);
fs.writeFileSync(path.join(directory,`${variant}-instructions.json`),JSON.stringify(report,null,2)+'\n');
console.log(`${variant}: original instruction and private-allocation checks passed`);
