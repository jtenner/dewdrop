import assert from "node:assert/strict";
import test from "node:test";
import { readSelfHostInvariantFailure, formatSelfHostInvariantFailure } from "./self-host-invariant-record.mjs";

test("numeric record retains unsigned IDs and all context fields", () => {
  const memory = new WebAssembly.Memory({ initial: 1 });
  const view = new DataView(memory.buffer);
  view.setBigUint64(0, 4919706420659244884n, true);
  view.setBigUint64(8, 1n, true);
  view.setUint32(16, 605, true);
  view.setUint32(20, 6, true);
  view.setBigUint64(24, 18446744073709551615n, true);
  view.setBigUint64(32, 13n, true);
  view.setBigUint64(40, 17n, true);
  view.setUint32(48, 4294967295, true);
  view.setBigUint64(56, 4n, true);
  view.setBigUint64(64, 5n, true);
  view.setBigUint64(72, 31n, true);
  const record = readSelfHostInvariantFailure(memory);
  assert.deepEqual(record, {
    code: 605, phase: 6, module_id: 18446744073709551615n,
    declaration: 13n, body: 17n, expression: 4294967295,
    expected: 4n, actual: 5n, detail: 31n,
  });
  assert.equal(formatSelfHostInvariantFailure(record),
    "self-host invariant failure code=605 phase=6 module_id=18446744073709551615 declaration=13 body=17 expression=4294967295 expected=4 actual=5 detail=31");
  view.setBigUint64(8, 2n, true);
  assert.equal(readSelfHostInvariantFailure(memory), null, "reject an unknown version");
  view.setBigUint64(8, 1n, true);
  view.setBigUint64(0, 0n, true);
  assert.equal(readSelfHostInvariantFailure(memory), null, "reject scratch data without magic");
});

test("missing or empty exported memory is not a failure record", () => {
  assert.equal(readSelfHostInvariantFailure(undefined), null);
  assert.equal(readSelfHostInvariantFailure(new WebAssembly.Memory({ initial: 0 })), null);
});
