import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { performance } from 'node:perf_hooks';

const [directory, variant, mode, processIndex = '0'] = process.argv.slice(2);
const binary = path.join(directory, `${variant}${mode === 'inspect' ? '-inspect' : ''}.wasm`);
const { instance } = await WebAssembly.instantiate(fs.readFileSync(binary), {});
const e = instance.exports;
if (mode === 'inspect') {
  const sites = JSON.parse(fs.readFileSync(path.join(directory, `${variant}-sites.json`)));
  const report = {};

  const record = (name, action, hot = false, publicResults = 0, comparatorResults = 0) => {
    e.reset_allocations();
    const value = action();
    const counts = Object.fromEntries(Object.entries(sites).map(([name, site]) =>
      [name, { ...site, count: Number(e[name].value) }]).filter(([, site]) => site.count));
    const arrays = Object.values(counts).filter(x => x.opcode.startsWith('array.')).reduce((n, x) => n + x.count, 0);
    const structs = Object.values(counts).filter(x => x.opcode.startsWith('struct.')).reduce((n, x) => n + x.count, 0);
    report[name] = { arrays, structs, sites: counts };
    if (hot) report[name].categories = { public_results: publicResults, comparator_results: comparatorResults, private_tree_path_search: structs - publicResults - comparatorResults };
    console.log(name, JSON.stringify({ arrays, structs }));
    if (hot) {
      assert.equal(arrays, 0, `${variant} ${name}: no tree/path array`);
      assert.equal(structs - publicResults - comparatorResults, 0, `${variant} ${name}: no private tree/path/search objects`);
    }
    return value;
  };
  record('empty', () => e.make_empty());
  assert.equal(report.empty.arrays, 0, 'empty construction has no node arrays');
  const tree = record('numeric-construction', () => e.make_numeric());
  record('unit-construction', () => e.make_unit());
  assert.equal(record('numeric-search-hit', () => e.search_numeric(tree, 4), true), 5);
  assert.equal(record('numeric-search-miss', () => e.search_numeric(tree, 5), true), 6);
  assert.equal(record('lookup-hit', () => e.lookup(tree, 4), true, 1), 2n);
  assert.equal(record('lookup-miss', () => e.lookup(tree, 5), true, 1), -1n);
  assert.equal(record('contains-hit', () => e.contains(tree, 4), true), 1);
  assert.equal(record('contains-miss', () => e.contains(tree, 5), true), 0);
  assert.equal(record('replace-bool', () => e.replace_bool(tree, 4, 99n), true), 0);
  record('replace-unit', () => e.replace_unit(tree, 4, 100n), true);
  assert.equal(record('replace-consumed-old', () => e.replace_old(tree, 4, 101n), true, 1), 100n);
  record('replace-escaping-old', () => e.old_snapshot(tree, 4, 102n), true, 1);
  assert.equal(record('fit-bool', () => e.fit_bool(tree), true), 1);
  record('fit-unit', () => e.fit_unit(tree), true);
  const text = e.make_text(), key = e.text_key(), miss = e.text_miss();
  assert.equal(record('consumed-compare', () => e.consumed_compare(text, key, miss), true, 0, 1), -1);
  assert.equal(record('text-contains-hit', () => e.text_contains(text, key), true, 0, 1), 1);
  assert.equal(record('text-contains-miss', () => e.text_contains(text, miss), true, 0, 2), 0);
  assert.equal(record('text-search-hit', () => e.search_text(text, key), true, 0, 1), 3);
  assert.equal(record('text-search-miss', () => e.search_text(text, miss), true, 0, 2), 4);
  assert.equal(record('text-hit', () => e.text_lookup(text, key), true, 1, 1), 3n);
  assert.equal(record('text-miss', () => e.text_lookup(text, miss), true, 1, 2), -1n);
  record('text-replace', () => e.text_replace(text, key), true, 0, 1);
  assert.equal(record('text-fit', () => e.text_fit(text, miss), true, 0, 2), 1);
  const textKeys = e.text_keys(text), textValues = e.text_values(text);
  for (let i = 0; i < e.slots_length(textKeys); i++) {
    assert.equal(e.slot_null(textKeys, i), i < 4 ? 0 : 1, 'exact live keys and null inactive/default slots');
  }
  assert.equal(e.slot_i64(textValues, 0), 0n, 'globally first root has no head value');
  for (let i = 5; i < e.slots_length(textValues); i++) {
    assert.equal(e.slot_i64(textValues, i), 0n, 'inactive and permanent default values stay clear');
  }
  record('clear', () => e.text_clear(text));
  assert.equal(e.text_has_root(text), 0, 'clear releases the map root');
  assert.equal(e.text_length(text), 0, 'clear resets length');
  for (const name of ['i32', 'f32', 'f64', 'vector', 'reference', 'option', 'nested', 'unit']) {
    const carrier = e['carrier_make_' + name]();
    // JS cannot carry V128 or Unit; those probe functions build scalar bits in Wasm.
    const args = ['vector', 'unit'].includes(name) ? [] : [e['carrier_value_' + name]()];
    record('carrier-replace-' + name, () => e['carrier_replace_' + name](carrier, ...args), true);
    assert.equal(record('carrier-fit-' + name, () => e['carrier_fit_' + name](carrier, ...args), true), 1);
    record('carrier-get-' + name, () => e['carrier_get_' + name](carrier), true, 1);
    record('carrier-put-' + name, () => e['carrier_put_' + name](carrier, ...args), true, 1);
  }
  const loops = e.make_numeric();
  assert.equal(record('lookup-loop', () => e.cost_lookup(loops, 1024), true, 1024), 6912n);
  assert.equal(record('contains-loop', () => e.cost_contains(loops, 1024), true), 496);
  record('replace-loop', () => e.cost_replace(loops, 1000), true);
  assert.equal(record('fit-loop', () => e.cost_fit(loops, 100), true), 3100);
  fs.writeFileSync(path.join(directory, `${variant}-allocations.json`), JSON.stringify(report, null, 2) + '\n');

} else if (mode === 'cost') {
  const count = 3000000, rounds = 100000;
  const tree = e.make_numeric(), keys = e.numeric_keys(tree);
  const replacement = e.make_numeric(), fitting = e.make_numeric();
  const cases = [
    ['lookup', () => e.cost_lookup(tree, count), count],
    ['direct-control', () => e.cost_control(keys, count), count],
    ['contains', () => e.cost_contains(tree, count), count],
    ['replace-unit', () => e.cost_replace(replacement, count), count],
    ['fit-bool', () => e.cost_fit(fitting, rounds), rounds * 31],
  ];
  const expected = new Map();
  for (let warmup = 0; warmup < 3; warmup++) {
    for (const [name, action] of cases) expected.set(name, action().toString());
  }
  assert.equal(expected.get('lookup'), expected.get('direct-control'));
  assert.equal(expected.get('fit-bool'), String(rounds * 31));
  const samples = [];
  for (let repetition = 0; repetition < 6; repetition++) {
    const order = (Number(processIndex) + repetition) % 2 ? [...cases].reverse() : cases;
    for (const [name, action, operations] of order) {
      const start = performance.now();
      const checksum = action().toString();
      const milliseconds = performance.now() - start;
      assert.equal(checksum, expected.get(name), name);
      samples.push({ name, repetition, operations, milliseconds,
        ns_per_operation: milliseconds * 1e6 / operations, checksum });
    }
  }
  const report = { variant, process: Number(processIndex), warmups: 3, repetitions: 6,
    order: 'alternating forward/reverse; initial order varies by process',
    inputs: '31 even I32 keys, I64 values equal to key/2; queries cycle 0..63; fit permutation (i*17)%31',
    fit_limit: 'fit samples include one node clear per 31 writes; no node allocation', samples };
  fs.writeFileSync(path.join(directory, `${variant}-cost-${processIndex}.json`), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
} else {
  throw new Error('expected inspect or cost');
}
