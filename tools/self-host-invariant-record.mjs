// Version 1 numeric compiler crash record. Read memory without calling back
// into the trapped guest: guest code can reuse the low-memory scratch area.
export function readSelfHostInvariantFailure(memory) {
  if (!(memory instanceof WebAssembly.Memory) || memory.buffer.byteLength < 80) {
    return null;
  }
  const view = new DataView(memory.buffer);
  if (view.getBigUint64(0, true) !== 4919706420659244884n ||
      view.getBigUint64(8, true) !== 1n) {
    return null;
  }
  return {
    code: view.getUint32(16, true),
    phase: view.getUint32(20, true),
    module_id: view.getBigUint64(24, true),
    declaration: view.getBigUint64(32, true),
    body: view.getBigUint64(40, true),
    expression: view.getUint32(48, true),
    expected: view.getBigUint64(56, true),
    actual: view.getBigUint64(64, true),
    detail: view.getBigUint64(72, true),
  };
}

export function formatSelfHostInvariantFailure(failure) {
  return `self-host invariant failure ${Object.entries(failure)
    .map(([key, value]) => `${key}=${value}`).join(" ")}`;
}
