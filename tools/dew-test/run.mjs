import { readFile } from "node:fs/promises";
import { decodeDewTestMetadata, testIdentity } from "./metadata.mjs";
import { readSelfHostInvariantFailure, formatSelfHostInvariantFailure } from "../self-host-invariant-record.mjs";

function usage() {
  console.log(`usage: node tools/dew-test/run.mjs [options]

options:
  --module NAME   run tests from one exact metadata module
  --file PATH     run tests from one exact logical file
  --name NAME     run tests with one exact display name
  --filter TEXT   run identities containing TEXT
  --wasm PATH     read the compiled test module from PATH
  --builtin-traps PATH  additionally validate every exported trap probe
  --label TEXT    summary label (default: Dew tests)
  --list          list selected test identities without executing
  --help          show this help`);
}

const options = {
  module: null,
  file: null,
  name: null,
  filter: null,
  wasm: null,
  builtinTraps: null,
  label: "Dew tests",
  list: false,
};
for (let index = 2; index < process.argv.length; index++) {
  const argument = process.argv[index];
  if (argument === "--help") {
    usage();
    process.exit(0);
  }
  if (argument === "--list") {
    options.list = true;
    continue;
  }
  if (
    [
      "--module",
      "--file",
      "--name",
      "--filter",
      "--wasm",
      "--builtin-traps",
      "--label",
    ].includes(argument)
  ) {
    if (index + 1 >= process.argv.length) {
      throw new Error(`missing value for ${argument}`);
    }
    const key = argument === "--builtin-traps" ? "builtinTraps" : argument.slice(2);
    options[key] = process.argv[++index];
    continue;
  }
  throw new Error(`unknown Dew test option: ${argument}`);
}

const root = new URL("./", import.meta.url);
const wasmPath = options.wasm ?? new URL("stdlib_tests.wasm", root);
const wasm = await readFile(wasmPath);
const module = await WebAssembly.compile(wasm);
const sections = WebAssembly.Module.customSections(module, "dew.tests");
if (sections.length !== 1) {
  throw new Error(`expected exactly one dew.tests custom section, got ${sections.length}`);
}
const tests = decodeDewTestMetadata(Buffer.from(sections[0]));
if (WebAssembly.Module.customSections(module, "dew.assertions").length !== 0) {
  throw new Error("static dew.assertions metadata is no longer supported");
}

const selected = tests.filter((test) => {
  if (options.module !== null && test.module !== options.module) return false;
  if (options.file !== null && test.file !== options.file) return false;
  if (options.name !== null && test.name !== options.name) return false;
  if (
    options.filter !== null &&
    !testIdentity(test).includes(options.filter)
  ) {
    return false;
  }
  return true;
});
const filtered =
  options.module !== null ||
  options.file !== null ||
  options.name !== null ||
  options.filter !== null;
if (filtered && selected.length === 0) {
  throw new Error("Dew test filter selected no tests");
}
if (options.list) {
  for (const test of selected) console.log(testIdentity(test));
  process.exit(0);
}

function normalizedTrap(error) {
  if (!(error instanceof WebAssembly.RuntimeError)) return null;
  const message = error.message.toLowerCase();
  if (message.includes("unreachable")) return "unreachable";
  if (
    message.includes("memory access out of bounds") ||
    message.includes("out of bounds memory")
  ) {
    return "memory-out-of-bounds";
  }
  if (
    message.includes("array element access out of bounds") ||
    message.includes("array out of bounds")
  ) {
    return "array-out-of-bounds";
  }
  if (message.includes("divide by zero")) return "integer-divide-by-zero";
  if (message.includes("integer overflow")) return "integer-overflow";
  if (message.includes("invalid conversion to integer")) {
    return "invalid-conversion-to-integer";
  }
  return null;
}

async function instantiateWithWasi(module) {
  let instance = null;
  let stdout = [];
  const imports = {
    wasi_snapshot_preview1: {
      fd_write(fd, iovs, iovsLength, written) {
        if (instance === null) throw new Error("WASI write during instantiation");
        const memory = instance.exports.memory;
        if (!(memory instanceof WebAssembly.Memory)) {
          throw new Error("WASI test module does not export memory");
        }
        const view = new DataView(memory.buffer);
        let total = 0;
        for (let index = 0; index < iovsLength; index++) {
          const entry = iovs + index * 8;
          const address = view.getUint32(entry, true);
          const length = view.getUint32(entry + 4, true);
          const bytes = Buffer.from(memory.buffer, address, length);
          if (fd === 1) stdout.push(Buffer.from(bytes));
          total += length;
        }
        view.setUint32(written, total, true);
        return 0;
      },
    },
  };
  instance = await WebAssembly.instantiate(module, imports);
  if (typeof instance.exports.__dew_init === "function") {
    instance.exports.__dew_init();
  }
  return {
    instance,
    resetStdout() {
      stdout = [];
      if (readSelfHostInvariantFailure(instance.exports.memory)) {
        new DataView(instance.exports.memory.buffer).setBigUint64(0, 0n, true);
      }
    },
    assertionFailureSuffix() {
      const failure = readSelfHostInvariantFailure(instance.exports.memory);
      if (failure) return `: ${formatSelfHostInvariantFailure(failure)}`;
      if (stdout.length === 0) return "";
      const bytes = Buffer.concat(stdout);
      let message;
      try {
        message = new TextDecoder("utf-8", { fatal: true }).decode(bytes);
      } catch (error) {
        return `: assertion stdout is not strict UTF-8: ${error}`;
      }
      return `: assertion failed: ${message}`;
    },
  };
}

const testRuntime = await instantiateWithWasi(module);
const instance = testRuntime.instance;
if ("__dew_assertion_id" in instance.exports) {
  throw new Error("static assertion ID globals are no longer supported");
}
let passed = 0;
const failures = [];
for (const test of selected) {
  const fn = instance.exports[test.export];
  const identity = testIdentity(test);
  if (typeof fn !== "function") {
    failures.push(`${identity}: missing export ${test.export}`);
    continue;
  }
  try {
    testRuntime.resetStdout();
    fn();
    if (test.expectedTrap === null) {
      passed++;
    } else {
      failures.push(`${identity}: expected trap ${test.expectedTrap}`);
    }
  } catch (error) {
    const actual = normalizedTrap(error);
    if (test.expectedTrap !== null && actual === test.expectedTrap) {
      passed++;
    } else if (actual === null) {
      failures.push(
        `${identity}: unsupported test failure: ${error}${testRuntime.assertionFailureSuffix()}`,
      );
    } else if (test.expectedTrap === null) {
      failures.push(
        `${identity}: unexpected trap ${actual}${testRuntime.assertionFailureSuffix()}`,
      );
    } else {
      failures.push(
        `${identity}: expected trap ${test.expectedTrap}, got ${actual}${testRuntime.assertionFailureSuffix()}`,
      );
    }
  }
}

// Builtin trap probes validate the default harness run. A metadata-filtered run
// executes exactly the selected compiler-described tests and skips this separate
// all-exports trap artifact.
if (!filtered && options.builtinTraps !== null) {
  const trapWasm = await readFile(options.builtinTraps);
  const trapModule = await WebAssembly.compile(trapWasm);
  const { instance: trapInstance } = await instantiateWithWasi(trapModule);
  for (const [name, fn] of Object.entries(trapInstance.exports)) {
    if (typeof fn !== "function") continue;
    let trapped = false;
    try {
      fn();
    } catch (error) {
      trapped = error instanceof WebAssembly.RuntimeError;
    }
    if (!trapped) failures.push(`${name}: expected builtin trap`);
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  console.error(`${options.label}: ${passed} passed, ${failures.length} failed`);
  process.exitCode = 1;
} else if (filtered) {
  console.log(`${options.label} passed: ${passed} selected from ${tests.length}`);
} else {
  console.log(`${options.label} passed: ${passed}`);
}
