const decoder = new TextDecoder("utf-8", { fatal: true });

function decodeHex(value, field) {
  if (!/^(?:[0-9a-f]{2})*$/.test(value)) {
    throw new Error(`invalid ${field} hex in Dew test metadata`);
  }
  return decoder.decode(Buffer.from(value, "hex"));
}

export function testIdentity(test) {
  return `${test.module}::${test.file}::${test.name}`;
}

export function decodeDewTestMetadata(sectionBytes) {
  const metadata = decoder.decode(sectionBytes);
  const metadataLines = metadata.split("\n");
  if (metadataLines.shift() !== "DEW_TESTS_V1") {
    throw new Error("unsupported Dew test metadata format");
  }
  const identities = new Set();
  return metadataLines.filter(Boolean).map((line) => {
    const fields = line.split("\t");
    if (fields.length !== 5 || !/^__dew_test_[0-9]+$/.test(fields[0])) {
      throw new Error(`invalid Dew test metadata record: ${line}`);
    }
    const test = {
      export: fields[0],
      module: fields[1],
      file: fields[2],
      name: decodeHex(fields[3], "name"),
      expectedTrap:
        fields[4] === "" ? null : decodeHex(fields[4], "expected trap"),
    };
    const identity = testIdentity(test);
    if (identities.has(identity)) {
      throw new Error(`duplicate Dew test identity: ${identity}`);
    }
    identities.add(identity);
    return test;
  });
}
