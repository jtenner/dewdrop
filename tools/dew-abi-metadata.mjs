const textDecoder = new TextDecoder("utf-8", { fatal: true });
const fingerprintPattern = /^[0-9a-f]{64}$/;

function fail(message) {
  throw new Error(`Dew ABI metadata: ${message}`);
}

function reader(buffer) {
  const bytes = new Uint8Array(buffer);
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  let offset = 0;
  return {
    bytes,
    readByte() {
      if (offset >= bytes.length) fail("truncated payload");
      return bytes[offset++];
    },
    readU32() {
      if (offset + 4 > bytes.length) fail("truncated u32");
      const value = view.getUint32(offset, true);
      offset += 4;
      return value;
    },
    readString(label) {
      const length = this.readU32();
      if (offset + length < offset || offset + length > bytes.length) {
        fail(`invalid ${label} range`);
      }
      let value;
      try {
        value = textDecoder.decode(bytes.subarray(offset, offset + length));
      } catch {
        fail(`${label} is not UTF-8`);
      }
      offset += length;
      return value;
    },
    finish() {
      if (offset !== bytes.length) fail("trailing payload bytes");
    },
  };
}

export function decodeDewAbi(module) {
  const sections = WebAssembly.Module.customSections(module, "dew.abi");
  if (sections.length !== 1) {
    fail(`expected exactly one dew.abi section, got ${sections.length}`);
  }
  const input = reader(sections[0]);
  const magic = String.fromCharCode(
    input.readByte(),
    input.readByte(),
    input.readByte(),
    input.readByte(),
  );
  if (magic !== "DWA1") fail(`unsupported schema ${JSON.stringify(magic)}`);
  const versions = {
    language: input.readByte(),
    closure: input.readByte(),
    genericCarrier: input.readByte(),
    box: input.readByte(),
    callbackWrapper: input.readByte(),
  };
  const supportedVersions = {
    language: 2,
    closure: 1,
    genericCarrier: 1,
    box: 1,
    callbackWrapper: 1,
  };
  for (const [name, version] of Object.entries(versions)) {
    if (version !== supportedVersions[name]) {
      fail(`unsupported ${name} ABI version ${version}`);
    }
  }
  const path = input.readString("module path");
  if (!path) fail("module path is empty");
  const interfaceFingerprint = input.readString("interface fingerprint");
  if (!fingerprintPattern.test(interfaceFingerprint)) {
    fail("interface fingerprint must be 64 lowercase hexadecimal digits");
  }
  const dependencyCount = input.readU32();
  const dependencies = [];
  const seen = new Set();
  for (let index = 0; index < dependencyCount; index += 1) {
    const dependencyPath = input.readString("dependency path");
    const contentFingerprint = input.readString("dependency fingerprint");
    if (!dependencyPath) fail("dependency path is empty");
    if (seen.has(dependencyPath)) fail(`duplicate dependency ${dependencyPath}`);
    if (!fingerprintPattern.test(contentFingerprint)) {
      fail(`dependency ${dependencyPath} fingerprint is invalid`);
    }
    seen.add(dependencyPath);
    dependencies.push({ path: dependencyPath, contentFingerprint });
  }
  input.finish();
  return { schema: 1, versions, path, interfaceFingerprint, dependencies };
}

export function requireDewAbi(module, expected) {
  const actual = decodeDewAbi(module);
  if (expected?.path !== undefined && actual.path !== expected.path) {
    fail(`expected module ${expected.path}, got ${actual.path}`);
  }
  if (
    expected?.interfaceFingerprint !== undefined &&
    actual.interfaceFingerprint !== expected.interfaceFingerprint
  ) {
    fail(
      `interface fingerprint mismatch for ${actual.path}: expected ${expected.interfaceFingerprint}, got ${actual.interfaceFingerprint}`,
    );
  }
  return actual;
}
