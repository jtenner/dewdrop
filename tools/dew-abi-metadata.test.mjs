import assert from "node:assert/strict";
import test from "node:test";

import { decodeDewAbi, requireDewAbi } from "./dew-abi-metadata.mjs";

const encoder = new TextEncoder();

function u32(value) {
  return Uint8Array.of(value & 255, (value >>> 8) & 255, (value >>> 16) & 255, value >>> 24);
}

function string(value) {
  const bytes = encoder.encode(value);
  return Uint8Array.from([...u32(bytes.length), ...bytes]);
}

function leb(value) {
  const bytes = [];
  do {
    let byte = value & 127;
    value >>>= 7;
    if (value !== 0) byte |= 128;
    bytes.push(byte);
  } while (value !== 0);
  return bytes;
}

function moduleWithPayload(payload) {
  const name = encoder.encode("dew.abi");
  const content = Uint8Array.from([...leb(name.length), ...name, ...payload]);
  return new WebAssembly.Module(
    Uint8Array.from([0, 97, 115, 109, 1, 0, 0, 0, 0, ...leb(content.length), ...content]),
  );
}

function payload(fingerprint = "0".repeat(64)) {
  return Uint8Array.from([
    ...encoder.encode("DWA1"),
    1,
    1,
    1,
    1,
    1,
    ...string("fixture.provider"),
    ...string(fingerprint),
    ...u32(1),
    ...string("fixture.dependency"),
    ...string("1".repeat(64)),
  ]);
}

test("decode deterministic Dew ABI metadata", () => {
  const decoded = decodeDewAbi(moduleWithPayload(payload()));
  assert.equal(decoded.path, "fixture.provider");
  assert.equal(decoded.interfaceFingerprint, "0".repeat(64));
  assert.deepEqual(decoded.dependencies, [
    { path: "fixture.dependency", contentFingerprint: "1".repeat(64) },
  ]);
});

test("reject incompatible provider fingerprints", () => {
  const module = moduleWithPayload(payload());
  assert.throws(
    () =>
      requireDewAbi(module, {
        path: "fixture.provider",
        interfaceFingerprint: "2".repeat(64),
      }),
    /interface fingerprint mismatch/,
  );
});

test("reject malformed and unsupported Dew ABI metadata", () => {
  assert.throws(() => decodeDewAbi(moduleWithPayload(Uint8Array.of(1, 2, 3))), /truncated/);
  const unsupported = payload();
  unsupported[4] = 0;
  assert.throws(() => decodeDewAbi(moduleWithPayload(unsupported)), /unsupported language ABI/);
});
