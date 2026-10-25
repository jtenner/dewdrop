import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { performance } from 'node:perf_hooks';

const [directory, mode, run = '0'] = process.argv.slice(2);
const modulePath = path.join(directory, mode === 'inspect' ? 'physical-inspect.wasm' : 'physical.wasm');
const { instance } = await WebAssembly.instantiate(fs.readFileSync(modulePath), {});
const e = instance.exports;
if (mode === 'inspect') {
  const sites = JSON.parse(fs.readFileSync(path.join(directory, 'allocation-sites.json')));
  const allocations = {};
  function record(label, action) {
    e.reset_allocations();
    const value = action();
    const counts = Object.fromEntries(Object.entries(sites).map(([name, site]) =>
      [name, { ...site, count: Number(e[name].value) }]).filter(([, site]) => site.count));
    allocations[label] = counts;
    return value;
  }
  const nodes = {}, plans = {};
  for (const name of ['plain', 'same', 'same_ref', 'common32', 'mixed', 'columns', 'unit']) {
    plans[name] = record('plan_' + name, () => e['plan_' + name]());
    nodes[name] = record('make_' + name, () => e['make_' + name](plans[name]));
  }
  const branch = record('make_branch', () => e.make_branch(plans.unit));
  const children = e.branch_children(branch);
  e.branch_prepare(branch, nodes.unit);
  assert.equal(e.slot_null(children, 0), 0);
  assert.equal(e.slot_null(children, 1), 0);
  record('clear_branch', () => e.branch_clear(branch, plans.unit));
  for (let i = 0; i < e.reference_length(children); i++) assert.equal(e.slot_null(children, i), 1);
  const refs = e.reference_slots(nodes.same_ref);
  e.reference_prepare(nodes.same_ref);
  for (let i = 0; i < 4; i++) assert.equal(e.slot_null(refs, i), 0);
  for (let i = 4; i < e.reference_length(refs); i++) assert.equal(e.slot_null(refs, i), 1);
  record('clear_same_ref', () => e.clear_same_ref(nodes.same_ref, plans.same_ref));
  for (let i = 0; i < e.reference_length(refs); i++) assert.equal(e.slot_null(refs, i), 1);
  const keys = e.unit_keys(nodes.unit);
  e.unit_prepare(nodes.unit);
  assert.equal(e.slot_null(keys, 0), 0);
  assert.equal(e.slot_null(keys, 1), 0);
  record('clear_unit', () => e.clear_unit(nodes.unit, plans.unit));
  for (let i = 0; i < e.reference_length(keys); i++) assert.equal(e.slot_null(keys, i), 1);
  const comparator = e.text_provider(), key = e.text_key();
  record('prefix', () => e.prefix_with(comparator, key));
  record('window_with', () => e.window_with(comparator, key, 1));
  record('compare_result', () => e.compare_with(comparator, key));
  const slots = e.same_slots(nodes.same);
  assert.equal(record('cost_pair', () => e.cost_pair(nodes.same, 1000)), 499500n);
  assert.equal(record('cost_pair_control', () => e.cost_pair_control(slots, 1000)), 499500n);
  for (const width of [2, 4, 8]) {
    const packed = e.packed_slots(width);
    assert.equal(e.vector_length(packed), Math.ceil(54 * (width + 1) / 16));
    const simd = record('cost_simd' + width, () => e['cost_simd' + width](packed, 1000));
    const scalar = record('cost_scalar' + width, () => e['cost_scalar' + width](packed, 1000));
    assert.equal(simd, scalar);
  }
  for (const [name, counts] of Object.entries(allocations)) {
    const arrays = Object.values(counts).filter(x => x.opcode.startsWith('array.')).reduce((sum, x) => sum + x.count, 0);
    const structs = Object.values(counts).filter(x => x.opcode === 'struct.new').reduce((sum, x) => sum + x.count, 0);
    console.log(name, JSON.stringify({ arrays, structs }));
    if (name === 'compare_result') assert.equal(arrays + structs, 1, 'one escaping Ordering result');
    if (name.startsWith('clear_') || name.startsWith('cost_') || name.endsWith('_with')) assert.equal(arrays + structs, 0, name);
  }
  fs.writeFileSync(path.join(directory, 'allocations.json'), JSON.stringify(allocations, null, 2) + '\n');
  console.log('All live reference slots, default slots, and metadata sizes passed.');
} else if (mode === 'cost') {
  const plan = e.plan_same(), node = e.make_same(plan), pairs = e.same_slots(node);
  const tests = [
    ['pair', () => e.cost_pair(node, 200000), 'pair_control', () => e.cost_pair_control(pairs, 200000), 200000],
  ];
  for (const width of [2, 4, 8]) {
    const slots = e.packed_slots(width);
    tests.push(['simd' + width, () => e['cost_simd' + width](slots, 20000),
                'scalar' + width, () => e['cost_scalar' + width](slots, 20000), 20000]);
  }
  const samples = [];
  for (const [a, first, b, second, operations] of tests) {
    // Fixed input, no random generator; warm both paths before timing.
    for (let i = 0; i < 3; i++) assert.equal(first(), second());
    for (let repetition = 0; repetition < 6; repetition++) {
      const order = (Number(run) + repetition) % 2 ? [[b, second], [a, first]] : [[a, first], [b, second]];
      const results = [];
      for (const [name, action] of order) {
        const start = performance.now();
        const checksum = action();
        const milliseconds = performance.now() - start;
        samples.push({ name, repetition, operations, milliseconds, ns_per_operation: milliseconds * 1e6 / operations, checksum: checksum.toString() });
        results.push(checksum);
      }
      assert.equal(results[0], results[1]);
    }
  }
  const report = { process: Number(run), warmups: 3, repetitions: 6, order: 'alternating AB/BA, initial order varies by process', samples };
  fs.writeFileSync(path.join(directory, 'cost-' + run + '.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
} else {
  throw new Error('expected inspect or cost');
}
