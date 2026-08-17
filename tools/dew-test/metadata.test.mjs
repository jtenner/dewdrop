import assert from "node:assert/strict";
import test from "node:test";
import { decodeDewTestMetadata, testIdentity } from "./metadata.mjs";

const bytes = (text) => Buffer.from(text, "utf8");

test("decode V1 Unicode names and expected traps", () => {
  const tests = decodeDewTestMetadata(
    bytes(
      "DEW_TESTS_V1\n" +
        "__dew_test_0\tdew.std\tstd/tests/core_test.dew\tcf80\t756e726561636861626c65\n",
    ),
  );
  assert.deepEqual(tests, [
    {
      export: "__dew_test_0",
      module: "dew.std",
      file: "std/tests/core_test.dew",
      name: "π",
      expectedTrap: "unreachable",
    },
  ]);
  assert.equal(
    testIdentity(tests[0]),
    "dew.std::std/tests/core_test.dew::π",
  );
});

test("reject unsupported metadata versions", () => {
  assert.throws(
    () => decodeDewTestMetadata(bytes("DEW_TESTS_V0\n")),
    /unsupported Dew test metadata format/,
  );
});

test("reject malformed records and hexadecimal fields", () => {
  assert.throws(
    () => decodeDewTestMetadata(bytes("DEW_TESTS_V1\nbad\n")),
    /invalid Dew test metadata record/,
  );
  assert.throws(
    () =>
      decodeDewTestMetadata(
        bytes("DEW_TESTS_V1\n__dew_test_0\tm\tf_test.dew\tzz\t\n"),
      ),
    /invalid name hex/,
  );
});

test("reject duplicate complete identities", () => {
  assert.throws(
    () =>
      decodeDewTestMetadata(
        bytes(
          "DEW_TESTS_V1\n" +
            "__dew_test_0\tm\tf_test.dew\t73616d65\t\n" +
            "__dew_test_1\tm\tf_test.dew\t73616d65\t\n",
        ),
      ),
    /duplicate Dew test identity: m::f_test.dew::same/,
  );
});

test("reject non-UTF-8 custom section payloads", () => {
  const payload = Buffer.concat([bytes("DEW_TESTS_V1\n"), Buffer.from([0xff])]);
  assert.throws(() => decodeDewTestMetadata(payload), /encoded data was not valid/);
});
