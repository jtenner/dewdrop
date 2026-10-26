import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { performance } from 'node:perf_hooks';

const [directory, variant, mode, processIndex = '0'] = process.argv.slice(2);
const correctnessOnly = mode === 'correctness';
const binary = path.join(directory, `${variant}${mode === 'inspect' || correctnessOnly ? '-inspect' : ''}.wasm`);
const { instance } = await WebAssembly.instantiate(fs.readFileSync(binary), {});
const e = instance.exports;
if (mode === 'inspect' || correctnessOnly) {
  const sites = correctnessOnly ? {} : JSON.parse(fs.readFileSync(path.join(directory, `${variant}-sites.json`)));
  const report = {};
  function record(name, action, publicResults = 0, hot = true) {
    if (correctnessOnly) return action();
    e.reset_allocations();
    const value = action();
    const counts = Object.fromEntries(Object.entries(sites).map(([name, site]) =>
      [name, { ...site, count: Number(e[name].value) }]).filter(([, site]) => site.count));
    const arrays = Object.values(counts).filter(s => s.opcode.startsWith('array.')).reduce((a, s) => a + s.count, 0);
    const structs = Object.values(counts).filter(s => s.opcode.startsWith('struct.')).reduce((a, s) => a + s.count, 0);
    report[name] = { arrays, structs, original_wasm_instructions: Number(e.instructions.value), sites: counts };
    fs.writeFileSync(path.join(directory, `${variant}-split-allocations.json`), JSON.stringify(report, null, 2)+'\n');
    if (hot) {
      assert.equal(arrays, 0, `${variant} ${name}: private array allocation`);
      assert.equal(structs, publicResults, `${variant} ${name}: private object or discarded public result`);
      report[name].categories = { requested_public_results: publicResults, provider_orderings: 0, private_tree_path_search: 0 };
    }
    return value;
  }
  function checkWork(tree, kind = 'numeric') {
    if (!e[`split_${kind}_has_work`](tree)) return;
    const prefix = kind === 'numeric' ? 'split_work' : 'split_ref_work';
    const work = e[`split_${kind}_work`](tree), slots = e[`${prefix}_nodes`](work);
    assert.equal(e.slots_length(slots), 17);
    assert.equal(e[`${prefix}_depth`](work), 0, 'work path must be empty');
    for (let i = 0; i < 17; i++) {
      const live = i === 15 && e[`${prefix}_hinted`](work);
      assert.equal(e.slot_null(slots, i), live ? 0 : 1, `work slot ${i}: path/hint/default reference`);
    }
  }
  function inspect(tree, kind, expectedLength, expectedKeys = null) {
    const root = e[`split_${kind}_root`](tree);
    const seen = new Set(), keys = [], keyRefs = new Set(), valueRefs = new Set();
    let leafDepth = null, leaves = 0, keySum = 0;
    function visit(node, depth, lower = null) {
      assert.ok(!seen.has(node), 'inspect ownership: node has more than one home');
      seen.add(node);
      const count = e[`split_${kind}_count`](node), branch = e[`split_${kind}_branch`](node);
      const column = e[`split_${kind}_keys`](node), capacity = e.slots_length(column) - 1;
      assert.ok(count <= capacity, `inspect ${kind}: count exceeds capacity`);
      if (depth) assert.ok(count >= Math.max(Math.floor(capacity / 8), 4), 'inspect non-root occupancy');
      keySum += count;
      // Inspect copies with raw helpers: no typed read of inactive/default references.
      for (let i = count; i <= capacity; i++) {
        if (kind === 'ref') assert.equal(e.slot_null(column, i), 1, `inspect ${kind} key slot ${i}: inactive/default reference not clear`);
        else assert.equal(e.slot_i32(column, i), 0, `inspect numeric key slot ${i}: inactive/default slot not clear`);
      }
      function keyAt(i) {
        if (kind === 'ref') {
          const ref = e.slot_ref(column, i);
          assert.ok(ref !== null && !keyRefs.has(ref), 'inspect key ownership: missing or duplicate key reference');
          keyRefs.add(ref);
          return e.split_ref_order(ref);
        }
        return e.slot_i32(column, i);
      }
      if (branch) {
        assert.ok(count > 0 && !e[`split_${kind}_head`](node), 'inspect branch head/count');
        const children = e[`split_${kind}_children`](node);
        assert.equal(e.slots_length(children), capacity + 2);
        for (let i = count + 1; i < capacity + 2; i++) {
          assert.equal(e.slot_null(children, i), 1, `inspect child slot ${i}: moved/default reference not clear`);
        }
        let fence = lower;
        for (let i = 0; i <= count; i++) {
          const child = e.slot_ref(children, i);
          assert.ok(child !== null, 'inspect live child edge missing');
          visit(child, depth + 1, fence);
          if (i < count) { fence = keyAt(i); keys.push(fence); }
        }
      } else {
        assert.equal(e[`split_${kind}_head`](node), leaves ? 1 : 0, 'inspect leaf head ownership');
        if (leafDepth === null) leafDepth = depth;
        assert.equal(depth, leafDepth, 'inspect unequal leaf depth');
        const values = e[`split_${kind}_values`](node);
        assert.equal(e.slots_length(values), capacity + 2);
        function valueAt(i, key) {
          if (kind === 'ref') {
            const ref = e.slot_ref(values, i);
            assert.ok(ref !== null && !valueRefs.has(ref), 'inspect value ownership: missing or duplicate head/regular reference');
            valueRefs.add(ref);
            assert.equal(e.split_ref_order(ref), key * 3 + 100, 'inspect head/regular value moved with key');
          } else {
            assert.equal(e.slot_i64(values, i), BigInt((key / 2) * 3 + 100), 'inspect numeric head/regular value');
          }
        }
        if (leaves) { assert.notEqual(lower, null); valueAt(0, lower); }
        else if (kind === 'ref') assert.equal(e.slot_null(values, 0), 1, 'inspect first head must be clear');
        else assert.equal(e.slot_i64(values, 0), 0n, 'inspect first head must be clear');
        for (let i = 0; i < count; i++) { const key = keyAt(i); keys.push(key); valueAt(i + 1, key); }
        for (let i = count + 1; i < capacity + 2; i++) {
          if (kind === 'ref') assert.equal(e.slot_null(values, i), 1, `inspect value slot ${i}: promoted/source/default reference not clear`);
          else assert.equal(e.slot_i64(values, i), 0n, `inspect numeric value slot ${i}: inactive/default value not clear`);
        }
        leaves++;
      }
    }
    visit(root, 0);
    assert.equal(keySum, expectedLength, 'inspect all-node key sum');
    assert.equal(keys.length, expectedLength, 'inspect exactly one head entry per separator');
    for (let i = 1; i < keys.length; i++) assert.ok(keys[i - 1] < keys[i], 'inspect global child fence/order');
    if (expectedKeys) assert.deepEqual(keys, [...expectedKeys].sort((a,b) => a-b), 'inspect sorted-array membership');
    checkWork(tree, kind);
    return { nodes: seen.size, leaves, depth: leafDepth, root };
  }
  // Node/column bound includes the existing Option root ownership envelope.
  function splitBound(name, tree, key, expectedLength) {
    const before = inspect(tree, 'numeric', expectedLength);
    const hadWork = e.split_numeric_has_work(tree);
    const savedWork = hadWork ? e.split_numeric_work(tree) : null;
    const added = record(name, () => e.split_numeric_insert(tree, key, BigInt(key / 2 * 3 + 100)), 0, false);
    assert.equal(added, 1);
    const after = inspect(tree, 'numeric', expectedLength + 1);
    if (correctnessOnly) {
      if (hadWork) assert.equal(e.split_numeric_work(tree), savedWork, `${name}: workspace reused`);
      return after;
    }
    const newNodes = after.nodes - before.nodes, rootChanged = after.root !== before.root;
    const workspaceArrays = hadWork ? 0 : 2, workspaceObjects = hadWork ? 0 : 2;
    assert.equal(report[name].arrays, 2 * newNodes + workspaceArrays, `${name}: only required node columns and first-use work arrays`);
    assert.equal(report[name].structs, 3 * newNodes + Number(rootChanged) + workspaceObjects, `${name}: only required wrappers/bodies, root ownership and first-use work object`);
    if (hadWork) assert.equal(e.split_numeric_work(tree), savedWork, `${name}: workspace reused`);
    report[name].categories = { new_nodes: newNodes, node_arrays: 2 * newNodes, node_objects: 3 * newNodes,
      root_ownership_option: Number(rootChanged), first_use_workspace_arrays: workspaceArrays, first_use_workspace_objects: workspaceObjects };
    return after;
  }
  const capacityProbe = e.split_numeric_make(1, 0);
  const capacity = e.slots_length(e.split_numeric_keys(e.split_numeric_root(capacityProbe))) - 1;
  const smallHalf = Math.min(2*Math.max(Math.floor(capacity/8),4), Math.floor(capacity/2));
  const first = e.split_numeric_make(capacity, 0);
  assert.equal(e.split_numeric_has_work(first), 0, 'fit-only construction has no workspace');
  splitBound('first-leaf-and-root-split', first, capacity*2, capacity);
  const work = e.split_numeric_work(first), slots = e.split_work_nodes(work), hint = e.slot_ref(slots, 15);
  assert.equal(record('head-lookup', () => e.split_numeric_lookup(first, (capacity-smallHalf)*2), 1), BigInt((capacity-smallHalf)*3+100));
  assert.equal(record('head-contains', () => e.split_numeric_contains(first, (capacity-smallHalf)*2)), 1);
  assert.equal(e.slot_ref(slots, 15), hint, 'reads retain the same hint');
  assert.equal(record('hint-append', () => e.split_numeric_insert(first, (capacity+1)*2, BigInt((capacity+1)*3+100))), 1);
  assert.equal(e.slot_ref(slots, 15), hint, 'append reuses the same hint leaf');
  checkWork(first);
  assert.equal(record('head-replace-bool', () => e.split_numeric_insert(first, (capacity-smallHalf)*2, BigInt((capacity-smallHalf)*3+100))), 0);
  record('head-replace-old', () => e.split_numeric_put(first, (capacity-smallHalf)*2, BigInt((capacity-smallHalf)*3+100)), 1);
  assert.equal(e.split_work_hinted(work), 0, 'other mutation clears hint');
  assert.equal(record('branch-fit', () => e.split_numeric_insert(first, -2, 97n)), 1);
  assert.equal(record('branch-regular-read', () => e.split_numeric_lookup(first, 0), 1), 100n);
  assert.equal(record('branch-miss-read', () => e.split_numeric_lookup(first, 1), 1), -1n);
  inspect(first, 'numeric', capacity+3);
  const laterLength = 2*capacity-smallHalf+1;
  const later = e.split_numeric_make(laterLength, 0);
  splitBound('later-leaf-split-reuses-work', later, laterLength*2, laterLength);
  const branchCapacity = e.slots_length(e.split_numeric_keys(e.split_numeric_root(later))) - 1;
  const cascadeLength = branchCapacity*(capacity-smallHalf)+capacity+branchCapacity;
  const cascade = e.split_numeric_make(cascadeLength, 0);
  assert.equal(splitBound('leaf-parent-and-root-split', cascade, cascadeLength*2, cascadeLength).depth, 2);
  // Find the first non-root full parent on the last spine. No allocation data
  // from this preparation is used as the measured split result.
  let length = cascadeLength+1;
  while (length < 3000) {
    let node = e.split_numeric_root(cascade), parent = null;
    while (e.split_numeric_branch(node)) { parent = node; node = e.slot_ref(e.split_numeric_children(node), e.split_numeric_count(node)); }
    if (e.split_numeric_count(parent) === branchCapacity && e.split_numeric_count(node) === capacity) break;
    e.split_numeric_insert(cascade, length * 2, BigInt(length * 3 + 100)); length++;
  }
  assert.ok(length < 3000, 'non-root parent split preparation');
  splitBound('non-root-parent-split', cascade, length * 2, length);
  const boundary = e.split_numeric_make(capacity, 0);
  const boundaryRoot = e.split_numeric_root(boundary);
  e.split_numeric_length_set(boundary, 0xffffffff);
  assert.throws(() => e.split_numeric_insert(boundary, capacity*2, 7n), WebAssembly.RuntimeError, 'overflow before any split edit');
  assert.equal(e.split_numeric_root(boundary), boundaryRoot);
  assert.equal(e.split_numeric_count(boundaryRoot), capacity);
  assert.equal(e.split_numeric_has_work(boundary), 0, 'overflow before work allocation');
  e.split_numeric_length_set(boundary, capacity);
  inspect(boundary, 'numeric', capacity);
  const maxHead = e.split_numeric_make(cascadeLength+1, 0), oldLength = e.split_numeric_length(maxHead);
  const headKey = e.slot_i32(e.split_numeric_keys(e.split_numeric_root(maxHead)), 0);
  e.split_numeric_length_set(maxHead, 0xffffffff);
  assert.equal(record('head-replace-at-U32-max', () => e.split_numeric_insert(maxHead, headKey, BigInt(headKey/2*3+100))), 0);
  record('head-put-at-U32-max', () => e.split_numeric_put(maxHead, headKey, BigInt(headKey/2*3+100)), 1);
  assert.throws(() => e.split_numeric_insert(maxHead, -2, 97n), WebAssembly.RuntimeError);
  assert.equal(e.split_numeric_length(maxHead), -1); // Wasm i32 JS boundary.
  e.split_numeric_length_set(maxHead, oldLength);
  inspect(maxHead, 'numeric', oldLength);
  record('clear', () => e.split_numeric_clear(first), 0, false);
  assert.equal(e.split_numeric_has_root(first), 0);
  assert.equal(e.split_numeric_has_work(first), 0);
  assert.equal(e.split_numeric_length(first), 0);
  for (const carrier of ['i32', 'f32', 'f64', 'vector', 'reference', 'option', 'nested', 'unit']) {
    const tree = e[`split_carrier_make_${carrier}`]();
    const args = ['vector','unit'].includes(carrier) ? [] : [e[`split_carrier_value_${carrier}`]()];
    record(`head-carrier-replace-${carrier}`, () => e[`split_carrier_replace_${carrier}`](tree, ...args));
    assert.equal(record(`branch-carrier-fit-${carrier}`, () => e[`split_carrier_fit_${carrier}`](tree, ...args)), 1);
    record(`head-carrier-get-${carrier}`, () => e[`split_carrier_get_${carrier}`](tree), 1);
    record(`head-carrier-put-${carrier}`, () => e[`split_carrier_put_${carrier}`](tree, ...args), 1);
  }
  const inspectorDiagnostics = {};
  function expectInspectorFailure(name, expected, action) {
    let failure;
    try { action(); } catch(error) { failure = error; }
    assert.ok(failure instanceof assert.AssertionError, `${name}: missing diagnostic assertion`);
    const firstLine = failure.message.split('\n')[0];
    assert.equal(firstLine, expected, `${name}: exact inspector diagnostic`);
    inspectorDiagnostics[name] = firstLine;
  }
  const bad = e.split_ref_make(62, 0), badRoot = e.split_ref_root(bad);
  const badChildren = e.split_ref_children(badRoot), left = e.slot_ref(badChildren, 0);
  const leftKeys = e.split_ref_keys(left), leftCount = e.split_ref_count(left), leftValues = e.split_ref_values(left);
  e.slot_set_ref(leftKeys, leftCount, e.slot_ref(leftKeys, 0));
  expectInspectorFailure('promoted/source key', `inspect ref key slot ${leftCount}: inactive/default reference not clear`, () => inspect(bad, 'ref', 62));
  e.slot_set_ref(leftKeys, leftCount, null);
  const defaultKey = e.slots_length(leftKeys)-1;
  e.slot_set_ref(leftKeys, defaultKey, e.slot_ref(leftKeys, 0));
  expectInspectorFailure('permanent default key', `inspect ref key slot ${defaultKey}: inactive/default reference not clear`, () => inspect(bad, 'ref', 62));
  e.slot_set_ref(leftKeys, defaultKey, null);
  e.slot_set_ref(leftValues, leftCount+1, e.slot_ref(leftValues, 1));
  expectInspectorFailure('promoted/source value', `inspect value slot ${leftCount+1}: promoted/source/default reference not clear`, () => inspect(bad, 'ref', 62));
  e.slot_set_ref(leftValues, leftCount+1, null);
  e.slot_set_ref(badChildren, 2, left);
  expectInspectorFailure('moved child', 'inspect child slot 2: moved/default reference not clear', () => inspect(bad, 'ref', 62));
  e.slot_set_ref(badChildren, 2, null);
  const right = e.slot_ref(badChildren, 1);
  e.slot_set_ref(badChildren, 1, left);
  expectInspectorFailure('duplicate node home', 'inspect ownership: node has more than one home', () => inspect(bad, 'ref', 62));
  e.slot_set_ref(badChildren, 1, right);
  const deeper = e.split_ref_make(2000, 0), deepRoot = e.split_ref_root(deeper);
  const deepBranch = e.slot_ref(e.split_ref_children(deepRoot), 1);
  assert.equal(e.split_ref_branch(deepBranch), 1, 'unequal-depth diagnostic setup');
  e.slot_set_ref(badChildren, 1, deepBranch);
  expectInspectorFailure('unequal depth', 'inspect unequal leaf depth', () => inspect(bad, 'ref', 62));
  e.slot_set_ref(badChildren, 1, right);
  inspect(bad, 'ref', 62);
  const refWorkSlots = e.split_ref_work_nodes(e.split_ref_work(bad));
  for (const slot of [0, 16]) {
    e.slot_set_ref(refWorkSlots, slot, left);
    expectInspectorFailure(`retained reference work slot ${slot}`, `work slot ${slot}: path/hint/default reference`, () => inspect(bad, 'ref', 62));
    e.slot_set_ref(refWorkSlots, slot, null);
  }
  inspect(bad, 'ref', 62);
  report.inspector_diagnostics = inspectorDiagnostics;
  const slotCases = [];
  for (const order of [0,1,2]) {
    const tree = e.split_ref_make(10000, order);
    slotCases.push({ order, ...inspect(tree, 'ref', 10000), root: undefined });
  }
  for (let gap = 0; gap <= 61; gap++) {
    const tree = e.split_ref_make(61, 0), key = gap * 2 - 1;
    e.split_ref_insert(tree, e.split_ref_query(key), e.split_ref_query(key * 3 + 100));
    inspect(tree, 'ref', 62, new Set([...Array(61)].map((_,i) => i*2).concat([key])));
  }
  const evolving = e.split_ref_make(0, 0), expected = new Set();
  for (let i = 0; i < 2000; i++) {
    const key = ((i * 7919) % 2000) * 2;
    assert.equal(e.split_ref_insert(evolving, e.split_ref_query(key), e.split_ref_query(key*3+100)), 1);
    expected.add(key);
    inspect(evolving, 'ref', i+1, expected);
  }
  report.slot_checks = { final_reference_shapes: slotCases, every_reference_leaf_gap: 62,
    after_each_reference_mutation: 2000, seed: 'permutation (i*7919)%2000; gcd=1',
    limits: correctnessOnly ? 'structural correctness checks; no performance measurements'
      : 'constructor and Wasm instruction counts are not exact heap bytes, JIT allocations, CPU instructions or GC measurements' };
  fs.writeFileSync(path.join(directory, `${variant}-split-${correctnessOnly ? 'correctness' : 'allocations'}.json`), JSON.stringify(report, null, 2)+'\n');
  console.log(correctnessOnly
    ? `${variant}: split structure, all head carriers and cleared slots passed`
    : `${variant}: split bounds, no-private-allocation paths, all head carriers and cleared slots passed`);
} else if (mode === 'cost') {
  const count = 1000000, buildCount = 100000;
  const small = e.split_numeric_make(4096, 2), large = e.split_numeric_make(1000000, 2);
  const smallReplace = e.split_numeric_make(4096, 2), largeReplace = e.split_numeric_make(1000000, 2);
  const cases = [
    ['small-lookup-half-hit', () => e.split_cost_lookup(small, 4096, count), count],
    ['large-lookup-half-hit', () => e.split_cost_lookup(large, 1000000, count), count],
    ['small-replace', () => e.split_cost_replace(smallReplace, 4096, count), count],
    ['large-replace', () => e.split_cost_replace(largeReplace, 1000000, count), count],
    ['sorted-build-hint', () => e.split_cost_build(buildCount, 0, false), buildCount],
    ['sorted-build-drop-hint-control', () => e.split_cost_build(buildCount, 0, true), buildCount],
    ['permuted-build', () => e.split_cost_build(buildCount, 1, false), buildCount],
  ];
  const expected = new Map();
  function expectedLookup(population) {
    let sum = 0n;
    for (let i=0; i<count; i++) sum += i&1 ? -1n : BigInt(((Math.imul(i,7919)>>>0)%population)*3+100);
    return String(sum);
  }
  expected.set('small-lookup-half-hit', expectedLookup(4096));
  expected.set('large-lookup-half-hit', expectedLookup(1000000));
  for (const [name] of cases.slice(2)) expected.set(name, name.includes('replace') ? '0' : String(buildCount));
  for (let warmup=0; warmup<3; warmup++) for (const [name, action] of cases) assert.equal(String(action()), expected.get(name), name);
  const samples = [];
  for (let repetition=0; repetition<6; repetition++) {
    const order = (Number(processIndex)+repetition)%2 ? [...cases].reverse() : cases;
    for (const [name,action,operations] of order) {
      const start=performance.now(), checksum=String(action()), milliseconds=performance.now()-start;
      assert.equal(checksum, expected.get(name), name);
      samples.push({name,repetition,operations,milliseconds,ns_per_operation:milliseconds*1e6/operations,checksum});
    }
  }
  const report = { variant, process:Number(processIndex), warmups:3, repetitions:6,
    order:'alternating forward/reverse; initial order varies by process',
    inputs:'I32 even keys, I64 ordinal*3+100; build permutation uses U64 product (i*7919)%population; query multiplication wraps U32; half queries odd/missing',
    controls:'drop-hint control clears existing hint before every write; it includes that explicit clear cost; no whole-call object-free claim',
    samples };
  fs.writeFileSync(path.join(directory,`${variant}-split-cost-${processIndex}.json`),JSON.stringify(report,null,2)+'\n');
  console.log(`${variant}: process ${processIndex} runtime checksums passed`);
} else throw new Error('expected correctness, inspect or cost');
