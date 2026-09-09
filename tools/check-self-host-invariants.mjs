import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { decodeDewTestMetadata } from "./dew-test/metadata.mjs";

// These probes must trap for the intended reason, not merely trap somewhere.
function solverProbe(name, code, expected, actual, detail) {
  return {
    name,
    expected: [code, 2, 80n, 0n, 0n, 4294967295, BigInt(expected), BigInt(actual), BigInt(detail)],
  };
}
const probes = [
  {
    name: "BOD-610 callback signature scopes require defined bodies",
    expected: [610, 7, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 1n, 0n, 0n],
  },
  {
    name: "BOD-610 callback signature scopes require lambda bodies",
    expected: [610, 7, 5100n, 5100n << 32n, 18446744073709551615n, 4294967295, 1n, 0n, 0n],
  },
  {
    name: "BOD-610 callback signature scopes require initializer bodies",
    expected: [610, 7, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 1n, 0n, 1n],
  },
  {
    name: "ARN-102 callback signature targets belong to their body",
    expected: [102, 7, 5100n, 5100n << 32n, 5100n << 32n, 2, 3n, 4294967295n, 0n],
  },
  {
    name: "ARN-101 callback signature scopes require valid spans",
    expected: [101, 7, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 3n, 3n, 4294967295n],
  },
  {
    name: "ABI-704 missing callback types cannot be rebuilt from operands",
    expected: [704, 7, 5100n, 5100n << 32n, 5100n << 32n, 2, 1n, 0n, 0n],
  },
  ...[
    ["ABI-714 raw reference cast receiver cannot disappear", 45n],
    ["ABI-714 raw reference cast selected heap cannot change", 45n],
    ["ABI-714 raw reference cast result heap cannot change", 46n],
  ].map(([name, actual]) => ({
    name,
    expected: [714, 7, 5100n, (5100n << 32n) | 1n, 5100n << 32n,
      2, 0n, actual, 5100n << 32n],
  })),
  ...[
    ["ARN-103 linked call function arena cannot be short", 103, 1n, 0n, 1n],
    ["ARN-103 linked call next arena cannot be long", 103, 1n, 2n, 2n],
    ["ARN-105 linked call head must address an entry", 105, 1n, 99n, 0n],
    ["ARN-108 linked call chains cannot link to themselves", 108, 0n, 0n, 0n],
    ["LNK-504 linked call entries require a target", 504, 1n, 4294967295n, 0n],
    ["ARN-103 linked call owner arena cannot be short", 103, 1n, 0n, 3n],
    ["ARN-106 linked call entries retain their body", 106, 330712481809n, 330712481810n, 0n],
    ["SPC-303 linked call insertion cannot replace a target", 303, 31n, 32n, 7n],
    ["ARN-108 linked call edges cannot point past their entry", 108, 0n, 99n, 0n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 5, 77n, 0n, 330712481809n, 19, expected, actual, detail],
  })),
  {
    name: "ARN-106 linked call edges cannot enter another body",
    expected: [106, 5, 77n, 0n, 330712481809n, 20, 330712481809n, 330712481810n, 1n],
  },
  ...[
    ["ABI-714 raw struct storage cannot change to a packed field", 37n],
    ["ABI-714 raw struct receiver cannot disappear", 36n],
    ["ABI-714 raw struct heap cannot change", 36n],
  ].map(([name, actual]) => ({
    name,
    expected: [714, 7, 5100n, (5100n << 32n) | 1n, 5100n << 32n,
      2, 0n, actual, 5100n << 32n],
  })),
  ...[
    ["BOD-611 emitted evaluation prefixes cannot be empty", 1n, 0n, 0n],
    ["BOD-611 emitted evaluation prefixes cannot claim fallthrough", 0n, 1n, 1n],
    ["BOD-611 emitted evaluation prefixes stop at the first nonreturning child", 1n, 0n, 2n],
    ["BOD-611 emitted evaluation prefixes require a nonreturning last child", 0n, 1n, 4294967300n],
    ["BOD-611 emitted evaluation prefixes retain child return effects", 2n, 0n, 4294967295n],
  ].map(([name, expected, actual, detail]) => ({
    name,
    expected: [611, 7, 5100n, (5100n << 32n) | 1n, 5100n << 32n,
      6, expected, actual, detail],
  })),
  ...[
    ["BOD-611 evaluation prefixes cannot be empty", 1n, 0n, 0n],
    ["BOD-611 evaluation prefixes cannot claim fallthrough", 0n, 1n, 1n],
    ["BOD-611 evaluation prefixes stop at the first nonreturning child", 1n, 0n, 2n],
    ["BOD-611 evaluation prefixes require a nonreturning last child", 0n, 1n, 4294967300n],
    ["BOD-611 evaluation prefixes retain child return effects", 2n, 0n, 4294967295n],
  ].map(([name, expected, actual, detail]) => ({
    name,
    expected: [611, 6, 5100n, (5100n << 32n) | 1n, 5100n << 32n,
      6, expected, actual, detail],
  })),
  ...[
    ["ARN-103 specialization request links cannot be shorter than requests", 103, 1n, 0n, 0n],
    ["ARN-103 specialization request links cannot be longer than requests", 103, 1n, 2n, 0n],
    ["ARN-105 specialization request heads must address requests", 105, 1n, 99n, 1n],
    ["SPC-302 specialization chains retain declaration identity", 302, 377957122059n, 377957122060n, 0n],
    ["ARN-101 specialization request spans are checked before shape comparison", 101, 1n, 1n, 4294967295n],
    ["ARN-108 specialization request chains cannot link to themselves", 108, 0n, 0n, 0n],
    ["SPC-301 stored specialization shapes remain concrete", 301, 0n, 1n, 4294967296n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 5, 77n, 377957122059n, 330712481809n,
      19, expected, actual, detail],
  })),
  ...[
    ["BOD-610 discard reads require a body plan", 610, 1n, 0n, 0n],
    ["BOD-610 discard reads require expression evidence", 610, 1n, 0n, 1n],
    ["BOD-610 discard reads reject unknown carriers", 610, 1n, 0n, 2n],
    ["BOD-610 discard reads reject conflicting carriers", 610, 1n, 1n, 2n],
    ["ABI-712 discard reads require matching carrier copies", 712, 5n, 4n, 3n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 7, 5100n, 5100n << 32n, 5100n << 32n,
      0, expected, actual, detail],
  })),
  ...[
    ["ABI-710 emitted locals cannot replace unresolved evidence with a reference", 710, 5n, 0n, 0n],
    ["ABI-710 emitted locals cannot replace conflicting evidence with a reference", 710, 5n, 1n, 0n],
    ["ABI-710 emitted locals retain their saved scalar type", 710, 5n, 4n, 0n],
    ["ARN-103 emitted locals require the complete value table", 103, 1n, 0n, 0n],
    ["ARN-103 emitted locals require the complete slot table", 103, 1n, 0n, 2n],
    ["ABI-710 emitted local slots retain source order", 710, 0n, 1n, 2n << 32n],
    ["ABI-710 emitted local count equals the saved physical count", 710, 2n, 1n, 3n],
    ["ARN-103 emitted locals require the complete carrier table", 103, 1n, 0n, 1n],
    ["BOD-610 emitted local declarations require a body plan", 610, 1n, 0n, 0n],
    ["BOD-610 local slot reads require a frozen body plan", 610, 1n, 0n, 0n],
    ["BOD-610 local erasure reads require a frozen body plan", 610, 1n, 0n, 0n],
    ["ARN-103 local erasure reads cannot repair missing slots from source shapes", 103, 1n, 0n, 2n],
    ["ARN-106 local slot reads require the requested local identity", 106, 999n, 4294967295n, 5n],
    ["ABI-710 local slot reads reject slots beyond the frozen local count", 710, 1n, 99n, 4n << 32n],
    ["ABI-710 a stored scalar local cannot become erased", 710, 1n, 4294967295n, 4n << 32n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 7, 5100n, 5100n << 32n, 5100n << 32n,
      4294967295, expected, actual, detail],
  })),
  ...[
    ["ABI-701 emitted target cannot change to another linked function", 701, 2n, 3n, 0n],
    ["ABI-701 emitted calls require one saved recipe", 701, 1n, 2n, 0n],
    ["LNK-502 emitted target must be in the linked function table", 502, 2n, 99n, 0n],
    ["ABI-701 emitted calls retain the selected declaration", 701, (5100n << 32n) | 1n, 5100n << 32n, 2n],
    ["ARN-102 indirect call targets belong to the caller body", 102, 1n, 0n, 3n],
    ["BOD-607 missing emitted targets retain the caller context", 607, 1n, 0n, 1n],
    ["BOD-610 call evaluation cannot reconstruct a missing body plan", 610, 1n, 0n, 0n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 7, 5100n, (5100n << 32n) | 1n, (5100n << 32n) | 1n,
      3, expected, actual, detail],
  })),
  ...[
    ["ARN-106 global read initializer keeps its selected declaration", 106, 1, 5100n << 32n, (5100n << 32n) | 1n, 0n],
    ["BOD-610 global read cannot lose its initializer", 610, 1, 1n, 0n, 5100n << 32n],
    ["BOD-610 global read requires one initializer", 610, 1, 1n, 2n, 5100n << 32n],
    ["BOD-610 a missing global cannot become a named function", 610, 1, 1n, 0n, (5100n << 32n) | 1n],
    ["BOD-606 global lookup requires a module-value read", 606, 1, 1n, 0n, 0n],
    ["ARN-102 global lookup checks source body ownership", 102, 0, 1n, 0n, 1n],
  ].map(([name, code, expression, expected, actual, detail]) => ({
    name,
    expected: [code, 7, 5100n, (5100n << 32n) | 1n, (5100n << 32n) | 1n,
      expression, expected, actual, detail],
  })),
  ...[
    ["BOD-605 frozen variant constructor targets cannot change", 605, 7, 5, 2n, 3n, 253n << 32n],
    ["BOD-605 frozen variant operands cannot disappear", 605, 7, 4294967295, 3n, 2n, (258n << 32n) | 4294967295n],
    ["BOD-605 frozen variant constructors retain expression identities", 605, 7, 5, 5n, 6n, 251n << 32n],
    ["BOD-605 frozen variant constructors retain declaration identities", 605, 7, 5, 5100n << 32n, (5100n << 32n) | 1n, 252n << 32n],
    ["BOD-605 frozen variant constructors retain argument starts", 605, 7, 5, 0n, 1n, 254n << 32n],
    ["BOD-605 frozen variant constructors retain argument counts", 605, 7, 5, 3n, 2n, 255n << 32n],
    ["BOD-605 frozen variant constructors retain operand starts", 605, 7, 5, 0n, 1n, 256n << 32n],
    ["BOD-605 frozen variant constructors retain operand counts", 605, 7, 5, 3n, 2n, 257n << 32n],
    ["BOD-605 frozen variant operands retain source expressions", 605, 7, 2, 2n, 3n, 259n << 32n],
    ["BOD-605 frozen variant operands retain declaration identities", 605, 7, 2, 5100n << 32n, (5100n << 32n) | 1n, 260n << 32n],
    ["BOD-605 frozen variant operands retain source order", 605, 7, 2, 0n, 1n, 261n << 32n],
    ["BOD-605 frozen variant operands retain field indices", 605, 7, 2, 0n, 1n, 262n << 32n],
    ["BOD-605 frozen variant operands retain storage types", 605, 7, 2, 1n, 2n, 263n << 32n],
    ["BOD-605 frozen variant operands retain boxing choices", 605, 7, 2, 0n, 1n, 264n << 32n],
    ["BOD-605 frozen variant operands retain Unit markers", 605, 7, 2, 0n, 1n, 265n << 32n],
    ["BOD-605 frozen variant operands retain reference casts", 605, 7, 2, 0n, 1n, 266n << 32n],
    ["BOD-605 frozen variant constructors cannot disappear", 605, 7, 4294967295, 1n, 0n, (250n << 32n) | 4294967295n],
    ["BOD-608 variant recipe targets agree before freeze", 608, 6, 5, 2n, 3n, 253n << 32n],
    ["BOD-610 variant emission requires its exact recipe", 610, 7, 5, 1n, 0n, 40n],
    ["BOD-610 variant emission requires a unique recipe", 610, 7, 5, 1n, 2n, 40n],
  ].map(([name, code, phase, expression, expected, actual, detail]) => ({
    name,
    expected: [code, phase, 5100n, (5100n << 32n) | 1n, 5100n << 32n,
      expression, expected, actual, detail],
  })),
  ...[
    ["LNK-501 module startup SCCs cannot omit a value", 501, 0n, 2n, 1n, 8n],
    ["LNK-501 module startup SCCs cannot duplicate a value", 501, (993n << 32n) | 1n, 1n, 2n, 9n],
    ["ARN-101 module startup checks SCC spans before access", 101, 0n, 2n, 1n, (7n << 32n) | 4294967295n],
    ["ARN-103 module startup value types remain parallel", 103, 0n, 2n, 1n, 4n],
    ["BOD-610 module startup cannot select another value's body", 610, (993n << 32n) | 1n, 1n, 0n, 12n],
    ["LNK-501 module startup checks dependency component order", 501, (993n << 32n) | 1n, 1n, 2n, 993n << 32n],
  ].map(([name, code, declaration, expected, actual, detail]) => ({
    name,
    expected: [code, 3, 993n, declaration, 0n, 4294967295, expected, actual, detail],
  })),
  {
    name: "BOD-610 query startup graph requires its source body",
    expected: [610, 3, 5100n, 5100n << 32n, 5100n << 32n,
      4294967295, 0n, 0n, 2n],
  },
  {
    name: "ARN-102 query startup graph checks the root before scanning",
    expected: [102, 3, 5100n, 5100n << 32n, 5100n << 32n,
      1, 0n, 1n, (1n << 32n) | 1n],
  },
  ...[
    ["LNK-502 global reads require an assigned physical slot", 502, 1n, 1n],
    ["ABI-710 global reads match their planned value type", 710, 4n, 5n],
    ["LNK-502 erased global reads cannot use a physical slot", 502, 4294967295n, 0n],
    ["SPC-301 global reads cannot emit generic shapes", 301, 0n, 1n],
    ["SPC-301 global reads cannot emit erroneous shapes", 301, 0n, 2n],
  ].map(([name, code, expected, actual]) => ({
    name,
    expected: [code, 7, 5100n, (5100n << 32n) | 1n, (5100n << 32n) | 1n,
      1, expected, actual, 5100n << 32n],
  })),
  ...[
    ["LNK-502 initializer function handles cannot reach the missing sentinel", 4294967295n, 0n],
    ["LNK-502 initializer function handle addition cannot wrap", 4294967298n, 1n],
  ].map(([name, actual, slot]) => ({
    name,
    expected: [502, 5, 5100n, 5100n << 32n, 5100n << 32n,
      4294967295, 4294967294n, actual, (15n << 32n) | slot],
  })),
  ...[
    ["LNK-504 initializer module matches its source step", 504, 0n, 99n, 0n],
    ["LNK-504 initializer declaration matches its source step", 504, 5100n << 32n, (5100n << 32n) + 1n, 1n],
    ["ARN-106 initializer body matches its source step", 106, 5100n << 32n, (5100n << 32n) + 1n, 2n],
    ["SPC-301 initializer shape cannot contain an error", 301, 0n, 2n, 3n],
    ["SPC-301 initializer shape cannot remain generic", 301, 0n, 1n, 3n],
    ["ABI-709 initializer shape matches its source type", 709, 1n, 0n, 4n],
    ["ARN-106 initializer test role matches its source step", 106, 0n, 1n, 5n],
    ["LNK-502 initializer global index matches its table slot", 502, 0n, 1n, 6n],
    ["LNK-502 initializer order matches its source schedule", 502, 0n, 1n, 7n],
  ].map(([name, code, expected, actual, role]) => ({
    name,
    expected: [code, 5, 5100n, 5100n << 32n, 5100n << 32n,
      4294967295, expected, actual, role << 32n],
  })),
  {
    name: "LNK-502 initializer links cannot outlive their source steps",
    expected: [502, 5, 0n, 0n, 0n, 4294967295, 0n, 1n, 9n << 32n],
  },
  {
    name: "LNK-504 source initializer declaration keys are unique",
    expected: [504, 5, 5100n, 5100n << 32n, 5100n << 32n,
      4294967295, 1n, 2n, (16n << 32n) | 1n],
  },
  {
    name: "ARN-106 initializer body removal cannot shift stored IDs",
    expected: [106, 5, 5100n, 5100n << 32n, 5100n << 32n,
      4294967295, 5100n << 32n, (5100n << 32n) | 1n, 3n],
  },
  {
    name: "BOD-610 initializer body must be present",
    expected: [610, 5, 5100n, 5100n << 32n, 5100n << 32n,
      4294967295, 0n, 0n, 2n],
  },
  {
    name: "LNK-502 every selected Unit initializer must have a link",
    expected: [502, 5, 5100n, 5100n << 32n, 5100n << 32n,
      4294967295, 1n, 0n, 9n << 32n],
  },
  {
    name: "SPC-304 startup cannot use a generic query template without its call record",
    expected: [304, 5, 5100n, (5100n << 32n) | 1n, 5100n << 32n,
      4294967295, 1n, 0n, 23n],
  },
  ...[
    ["LNK-504 startup cannot lose a global dependency lookup", 504, 1n, 0n],
    ["ARN-101 startup bounds a global dependency index", 101, 2n, 99n],
    ["ARN-106 startup checks a global dependency declaration", 106, 5501n << 32n, (5500n << 32n) | 1n],
  ].map(([name, code, expected, actual]) => ({
    name,
    expected: [code, 5, 5501n, (5501n << 32n) | 2n, (5501n << 32n) | 2n,
      3, expected, actual, 5501n << 32n],
  })),
  {
    name: "ARN-106 startup called body lookup checks stored identity",
    expected: [106, 5, 5501n, (5501n << 32n) | 2n, (5501n << 32n) | 2n,
      4294967295, (5501n << 32n) | 2n, (5501n << 32n) | 3n, 3n],
  },
  ...[
    ["ARN-106 startup call record keeps its caller body", 106, 5500n << 32n, (5500n << 32n) | 1n, 25n],
    ["ARN-106 startup call record keeps its expression", 106, 1n, 2n, 25n],
    ["SPC-303 startup call record keeps its caller instance", 303, 4294967295n, 0n, 25n],
    ["ARN-106 startup call record keeps its declaration", 106, (5501n << 32n) | 2n, (5501n << 32n) | 3n, 25n],
    ["SPC-304 startup call specialization must be present", 304, 0n, 99n, (5501n << 32n) | 2n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 5, 5500n, (5500n << 32n) | 1n, 5500n << 32n,
      1, expected, actual, detail],
  })),
  {
    name: "LNK-501 startup verifies every dependency precedes its reader",
    expected: [501, 5, 5501n, 5501n << 32n, 5501n << 32n,
      4294967295, 0n, 1n, 27n << 32n],
  },
  {
    name: "ARN-101 startup postcondition checks dependency indices",
    expected: [101, 5, 5500n, (5500n << 32n) | 1n, 5500n << 32n,
      4294967295, 2n, 99n, (27n << 32n) | 1n],
  },
  ...[
    ["ARN-103 startup dependency rows match candidates", 27n],
    ["ARN-103 startup output is a total candidate schedule", 28n],
  ].map(([name, detail]) => ({
    name,
    expected: [103, 5, 0n, 0n, 0n, 4294967295, 2n, 1n, detail],
  })),
  ...[
    ["ARN-103 initializer table cannot lose a global", 0n],
    ["ARN-103 initializer table cannot duplicate a global", 2n],
  ].map(([name, expected]) => ({
    name,
    expected: [103, 5, 0n, 0n, 0n, 4294967295, expected, 1n, 720n],
  })),
  ...[
    ["BOD-608 constructor propagation rejects a missing field identity", 0n],
    ["BOD-608 constructor propagation rejects another declaration's field", (5100n << 32n) | 1n],
  ].map(([name, actual]) => ({
    name,
    expected: [608, 6, 5100n, (5100n << 32n) | 2n, 5100n << 32n,
      2, 0n, actual, 0n],
  })),
  ...[
    ["BOD-605 capture access capture ID cannot change after freeze", 605, 7, 0n, 1n, 200n << 32n],
    ["BOD-605 capture access source kind cannot change after freeze", 605, 7, 0n, 1n, 201n << 32n],
    ["BOD-605 capture access source owner cannot change after freeze", 605, 7, 5100n << 32n, (5100n << 32n) + 1n, 202n << 32n],
    ["BOD-605 capture access source local cannot change after freeze", 605, 7, 1n, 0n, 203n << 32n],
    ["BOD-605 capture access erasure cannot change after freeze", 605, 7, 0n, 1n, 204n << 32n],
    ["BOD-605 capture access closure type cannot change after freeze", 605, 7, 2n, 0n, 205n << 32n],
    ["BOD-605 capture access field index cannot change after freeze", 605, 7, 1n, 0n, 206n << 32n],
    ["BOD-605 capture access field storage cannot change after freeze", 605, 7, 6n, 1n, 207n << 32n],
    ["BOD-605 capture access cell type cannot change after freeze", 605, 7, 1n, 0n, 208n << 32n],
    ["BOD-605 capture access cell storage cannot change after freeze", 605, 7, 2n, 1n, 209n << 32n],
    ["ARN-103 capture access tables cover every lambda capture", 103, 6, 1n, 0n, 719n],
    ["ARN-102 capture access stays in the frozen lambda frame", 102, 7, 1n, 1n, 0n],
    ["ARN-106 capture access retains its stored ID", 106, 7, 0n, 1n, 0n],
    ["BOD-610 capture reads require the frozen field storage", 610, 7, 1n, 0n, 0n],
    ["BOD-610 capture reads require the frozen cell storage", 610, 7, 1n, 0n, 1n << 32n],
    ["BOD-605 capture access table length cannot change after freeze", 605, 7, 1n, 0n, (200n << 32n) | 4294967295n],
  ].map(([name, code, phase, expected, actual, detail]) => ({
    name,
    expected: [code, phase, 5100n, 5100n << 32n, 5100n << 32n,
      4294967295, expected, actual, detail],
  })),
  ...[
    ["ARN-103 owned capture cell tables cover every logical local", 103, 6, 2n, 1n, 718n],
    ["BOD-610 a required owned capture cell cannot be omitted", 610, 6, 1n, 0n, 1n],
    ["BOD-605 owned capture cell local identity cannot change after freeze", 605, 7, 1n, 0n, (191n << 32n) | 1n],
    ["BOD-605 owned capture cell source index cannot change after freeze", 605, 7, 1n, 0n, (192n << 32n) | 1n],
    ["BOD-605 owned capture cell source slot cannot change after freeze", 605, 7, 1n, 0n, (193n << 32n) | 1n],
    ["BOD-605 owned capture cell physical slot cannot change after freeze", 605, 7, 2n, 3n, (194n << 32n) | 1n],
    ["BOD-605 owned capture cell heap type cannot change after freeze", 605, 7, 1n, 2n, (195n << 32n) | 1n],
    ["BOD-605 owned capture cell stored type cannot change after freeze", 605, 7, 2n, 1n, (196n << 32n) | 1n],
    ["BOD-605 owned capture cell parameter role cannot change after freeze", 605, 7, 0n, 1n, (197n << 32n) | 1n],
    ["BOD-605 owned capture cell presence cannot change after freeze", 605, 7, 1n, 0n, (190n << 32n) | 1n],
    ["BOD-605 owned capture cell table length cannot change after freeze", 605, 7, 2n, 1n, (190n << 32n) | 4294967295n],
  ].map(([name, code, phase, expected, actual, detail]) => ({
    name,
    expected: [code, phase, 5100n, 5100n << 32n, 5100n << 32n,
      4294967295, expected, actual, detail],
  })),
  ...[
    ["BOD-610 marker storage cannot hide unknown evidence", 610, 1n, 0n],
    ["BOD-610 marker storage cannot hide conflicting evidence", 610, 1n, 1n],
    ["BOD-611 Never marker storage requires divergent source flow", 611, 0n, 1n],
  ].map(([name, code, expected, actual]) => ({
    name,
    expected: [code, 6, 5100n, (5100n << 32n) | 3n, 5100n << 32n,
      3, expected, actual, 1n],
  })),
  ...[
    ["FRG-403 single temporary instructions reject another ordinal", 403, 1n, 1n, 0n],
    ["BOD-610 temporary slot lookup requires a body plan", 610, 1n, 0n, 0n],
    ["BOD-610 temporary slot lookup cannot invent a missing slot", 610, 1n, 0n, 0n],
    ["BOD-610 temporary slot lookup rejects duplicate slots", 610, 1n, 2n, 0n],
    ["ARN-106 temporary slots require the selected module", 106, 5100n, 5101n, 0n],
    ["ARN-106 temporary slots require the selected body", 106, 5100n << 32n, (5100n << 32n) + 1n, 1n],
    ["ABI-710 temporary slots cannot use the missing sentinel", 710, 4294967294n, 4294967295n, 0n],
    ["BOD-610 raw array allocation requires a body plan", 610, 1n, 0n, 0n],
    ["BOD-610 raw array length temporaries cannot be missing", 610, 1n, 0n, 0n],
    ["BOD-610 raw array length temporaries must be unique", 610, 1n, 2n, 0n],
    ["ABI-710 raw array length temporaries retain I32 storage", 710, 4n, 5n, 0n],
    ["ABI-710 raw array length carrier copies must agree", 710, 4n, 5n, 0n],
    ["BOD-605 frozen raw array length temporaries retain their type", 605, 4n, 5n, 133n << 32n],
    ["BOD-610 Unit is not a physical temporary type", 610, 1n, 2n, 0n],
    ["BOD-610 Never is not a physical temporary type", 610, 1n, 3n, 0n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 7, 5100n, (5100n << 32n) | 3n, 5100n << 32n,
      3, expected, actual, detail],
  })),
  ...[
    ["BOD-605 closure recipes retain expression identity", 605, 7, 0, 0n, 1n, 231n << 32n],
    ["BOD-605 closure recipes retain lambda identity", 605, 7, 0, 0n, 1n, 232n << 32n],
    ["BOD-605 closure recipes retain physical type", 605, 7, 0, 1n, 2n, 233n << 32n],
    ["BOD-605 closure recipes retain entry function", 605, 7, 0, 1n, 2n, 234n << 32n],
    ["BOD-605 closure recipes retain capture span start", 605, 7, 0, 0n, 1n, 235n << 32n],
    ["BOD-605 closure recipes retain capture span length", 605, 7, 0, 1n, 0n, 236n << 32n],
    ["BOD-605 closure captures retain expression identity", 605, 7, 0, 0n, 1n, 238n << 32n],
    ["BOD-605 closure captures retain capture identity", 605, 7, 0, 0n, 1n, 239n << 32n],
    ["BOD-605 closure captures retain source kind", 605, 7, 0, 0n, 1n, 240n << 32n],
    ["BOD-605 closure captures retain source owner", 605, 7, 0, 5100n << 32n, (5100n << 32n) | 1n, 241n << 32n],
    ["BOD-605 closure captures retain source local", 605, 7, 0, 0n, 1n, 242n << 32n],
    ["BOD-605 closure captures retain erasure", 605, 7, 0, 0n, 1n, 243n << 32n],
    ["BOD-605 closure captures retain field index", 605, 7, 0, 1n, 0n, 244n << 32n],
    ["BOD-605 closure captures retain field storage", 605, 7, 0, 2n, 1n, 245n << 32n],
    ["BOD-605 closure captures retain cell type", 605, 7, 0, 4294967295n, 0n, 246n << 32n],
    ["BOD-605 closure captures retain operand kind", 605, 7, 0, 1n, 2n, 247n << 32n],
    ["BOD-605 closure captures retain operand slot", 605, 7, 0, 0n, 1n, 248n << 32n],
    ["BOD-605 closure recipe tables cannot lose entries", 605, 7, 4294967295, 1n, 0n, (230n << 32n) | 4294967295n],
    ["BOD-605 closure capture tables cannot lose entries", 605, 7, 4294967295, 1n, 0n, (237n << 32n) | 4294967295n],
    ["ABI-701 closure recipe entry agrees before freeze", 701, 6, 0, 1n, 2n, 234n << 32n],
    ["BOD-610 closure emission requires its recipe", 610, 7, 0, 1n, 0n, 0n],
    ["BOD-610 closure emission requires a unique recipe", 610, 7, 0, 1n, 2n, 0n],
  ].map(([name, code, phase, expression, expected, actual, detail]) => ({
    name,
    expected: [code, phase, 5100n, 5100n << 32n, 5100n << 32n,
      expression, expected, actual, detail],
  })),
  ...[
    ["BOD-605 frozen object constructor targets cannot change", 605, 7, 4, 0n, 1n, 213n << 32n],
    ["BOD-605 frozen object constructor operands cannot disappear", 605, 7, 4294967295, 3n, 2n, (218n << 32n) | 4294967295n],
    ["BOD-610 object constructor emission requires its exact recipe", 610, 7, 4, 1n, 0n, 16n],
    ["BOD-610 object constructor recipes must be unique", 610, 7, 4, 1n, 2n, 16n],
    ["BOD-608 object recipe targets agree before freeze", 608, 6, 4, 0n, 1n, 213n << 32n],
    ["BOD-608 a missing constructor target cannot use result heap evidence", 608, 6, 4, 1n, 0n, 10n],
    ["BOD-605 frozen object operands retain source order", 605, 7, 3, 2n, 3n, 221n << 32n],
    ["BOD-605 frozen object operands retain storage types", 605, 7, 3, 1n, 2n, 223n << 32n],
    ["BOD-605 frozen object operands retain boxing choices", 605, 7, 3, 0n, 1n, 224n << 32n],
    ["BOD-605 frozen object operands retain Unit markers", 605, 7, 3, 0n, 1n, 225n << 32n],
    ["BOD-605 frozen object operands retain field indices", 605, 7, 3, 0n, 1n, 222n << 32n],
    ["BOD-605 frozen object operands retain source expressions", 605, 7, 3, 3n, 4n, 219n << 32n],
  ].map(([name, code, phase, expression, expected, actual, detail]) => ({
    name,
    expected: [code, phase, 5100n, (5100n << 32n) | 1n, 5100n << 32n,
      expression, expected, actual, detail],
  })),
  ...[
    ["BOD-610 constructor temporary records cannot be missing", 610, 1n, 0n, 2n],
    ["BOD-610 constructor emission requires a body plan", 610, 1n, 0n, 0n],
    ["BOD-610 constructor temporary records must be unique", 610, 1n, 2n, 0n],
    ["ABI-710 constructor temporary values must match their source", 710, 5n, 4n, 0n],
    ["ABI-710 constructor temporary carrier copies must agree", 710, 5n, 4n, 0n],
    ["BOD-605 frozen constructor temporaries retain their value type", 605, 5n, 4n, 133n << 32n],
    ["FRG-403 constructor temporary ordinals stay in the field span", 403, 3n, 3n, 0n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 7, 5100n, (5100n << 32n) | 1n, 5100n << 32n,
      4, expected, actual, detail],
  })),
  ...[
    ["ARN-101 constructor recipes require an owned source span", 101, 1n, 2n, 0n],
    ["ARN-101 constructor recipes require an owned physical span", 101, 2n, 1n, (1n << 32n) | 2n],
    ["BOD-608 constructor recipes require complete source fields", 608, 1n, 0n, 1n << 32n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 7, 5100n, (5100n << 32n) | 2n, 5100n << 32n,
      2, expected, actual, detail],
  })),
  {
    name: "BOD-608 constructor recipes cannot use a source field twice",
    expected: [608, 7, 5100n, (5100n << 32n) | 1n, 5100n << 32n,
      3, 0n, (5100n << 32n) | 1n, 1n],
  },
  ...[
    ["declaration identity", (5100n << 32n) | 1n],
    ["a missing identity", 0n],
  ].map(([kind, actual]) => ({
    name: kind === "declaration identity"
      ? "BOD-608 constructor field names cannot replace declaration identity"
      : "BOD-608 constructor field names cannot repair a missing identity",
    expected: [608, 6, 5100n, (5100n << 32n) | 2n, 5100n << 32n,
      2, 0n, actual, 0n],
  })),
  ...[
    ["declared field errors cannot use retained shape evidence", 1n, 3n, 3n],
    ["declared payload errors cannot use retained shape evidence", 0n, 5n, 5n],
    ["reference fields cannot hide erroneous type arguments", 2n, 47n, 5n],
    ["callback fields cannot hide erroneous result types", 3n, 48n, 5n],
  ].map(([name, owner, root, bad]) => ({
    name: `SPC-301 ${name}`,
    expected: [301, 4, 5100n, (5100n << 32n) | owner, 0n, 4294967295,
      0n, 1n, (root << 32n) | bad],
  })),
  {
    name: "FRG-403 packed field reads require a present source field",
    expected: [403, 5, 5100n, 0n, 0n, 1, 1n, 1n, 0n],
  },
  ...[
    ["SPC-303 call target updates reject concrete disagreement", 303, 3, 0n, 1n, 2n],
    ["ARN-102 call target updates reject another body's expression", 102, 0, 1n, 0n, 3n],
    ["ARN-103 call target updates require the complete expression table", 103, 3, 3n, 2n, 0n],
    ["ARN-106 call target updates check the stored expression identity", 106, 3, 3n, 2n, 2n],
  ].map(([name, code, expression, expected, actual, detail]) => ({
    name,
    expected: [code, 6, 5100n, (5100n << 32n) | 1n, (5100n << 32n) | 1n,
      expression, expected, actual, detail],
  })),
  {
    name: "ARN-101 carrier graph node totals cannot wrap U32",
    expected: [101, 6, 5100n, 5100n << 32n, 5100n << 32n, 4294967295,
      4294967295n, 8589934592n, (15n << 32n) | 4294967295n],
  },
  ...[
    ["BOD-604 final transfer audit detects a missing dependency", 604, 24, 0n, 1n, (0n << 32n) | 5n],
    ["ARN-103 carrier graph edge arrays remain parallel", 103, 4294967295, 8n, 9n, (10n << 32n) | 4294967295n],
    ["ARN-101 carrier graph heads stay in the edge arena", 101, 20, 9n, 9n, (11n << 32n) | 0n],
    ["ARN-101 carrier graph targets stay in the node arena", 101, 20, 10n, 10n, (12n << 32n) | 0n],
    ["ARN-104 carrier graph adjacency links strictly decrease", 104, 20, 0n, 0n, (13n << 32n) | 0n],
    ["BOD-604 a carrier transfer must finish before the next starts", 604, 4294967295, 4294967295n, 0n, (1n << 32n) | 0n],
    ["BOD-604 carrier completion must match the active transfer", 604, 4294967295, 0n, 1n, (2n << 32n) | 1n],
    ["BOD-604 a completion flag cannot replace the transfer audit", 604, 4294967295, 10n, 0n, (8n << 32n) | 4294967295n],
    ["ARN-101 queued carrier items are checked before pending lookup", 101, 4294967295, 10n, 10n, (7n << 32n) | 10n],
    ["BOD-604 a nonconverging carrier transfer has a resource diagnostic", 604, 4294967295, 64n, 65n, (4n << 32n) | 0n],
  ].map(([name, code, expression, expected, actual, detail]) => ({
    name,
    expected: [code, 6, 5100n, 5100n << 32n, 5100n << 32n,
      expression, expected, actual, detail],
  })),
  ...[
    ["selected physical target", 3, 2n, 3n, 154n],
    ["evaluation order", 2, 2n, 1n, 170n],
    ["operand source kind", 2, 0n, 1n, 180n],
    ["operand source identity", 2, 2n, 1n, 181n],
  ].map(([kind, expression, expected, actual, role]) => ({
    name: `BOD-605 frozen calls retain ${kind === "selected physical target" ? "the " : ""}${kind}`,
    expected: [605, 7, 5100n, (5100n << 32n) | 1n, (5100n << 32n) | 1n,
      expression, expected, actual, role << 32n],
  })),
  ...[
    ["BOD-605 frozen programs cannot lose a body", 4294967295, 1n, 0n, (0n << 32n) | 0n, true],
    ["BOD-605 frozen expressions retain their source identity", 0, 0n, 1n, (40n << 32n) | 0n, false],
    ["BOD-605 frozen locals retain their scalar carrier", 4294967295, 5n, 4n, (80n << 32n) | 1n, false],
    ["BOD-605 frozen locals retain their physical slot", 4294967295, 0n, 1n, (81n << 32n) | 1n, false],
    ["BOD-605 frozen expressions table length cannot change", 4294967295, 1n, 0n, (40n << 32n) | 4294967295n, false],
    ["BOD-605 frozen local_values table length cannot change", 4294967295, 3n, 2n, (70n << 32n) | 4294967295n, false],
    ["BOD-605 frozen locals table length cannot change", 4294967295, 3n, 2n, (80n << 32n) | 4294967295n, false],
    ["BOD-605 frozen local_slots table length cannot change", 4294967295, 3n, 2n, (81n << 32n) | 4294967295n, false],
    ["BOD-605 frozen control_state_values table length cannot change", 4294967295, 0n, 1n, (90n << 32n) | 4294967295n, false],
    ["BOD-605 frozen control_states table length cannot change", 4294967295, 0n, 1n, (100n << 32n) | 4294967295n, false],
    ["BOD-605 frozen control_result_values table length cannot change", 4294967295, 0n, 1n, (110n << 32n) | 4294967295n, false],
    ["BOD-605 frozen control_results table length cannot change", 4294967295, 0n, 1n, (120n << 32n) | 4294967295n, false],
    ["BOD-605 frozen call_evaluations table length cannot change", 4294967295, 0n, 1n, (170n << 32n) | 4294967295n, false],
    ["BOD-605 frozen call_operands table length cannot change", 4294967295, 0n, 1n, (180n << 32n) | 4294967295n, false],
    ["BOD-605 frozen body identity uses the original diagnostic owner", 4294967295, 5100n, 5101n, (4n << 32n) | 4294967295n, false],
  ].map(([name, expression, expected, actual, detail, global]) => ({
    name,
    expected: [605, 7, global ? 0n : 5100n, global ? 0n : 5100n << 32n,
      global ? 0n : 5100n << 32n, expression, expected, actual, detail],
  })),
  ...[
    ["ARN-101 source function lookup checks the fragment arena", 101, 2n, 2n, (70n << 32n) | 2n],
    ["LNK-504 source function lookup checks the stored declaration", 504, 5100n << 32n, (5100n << 32n) | 1n, (71n << 32n) | 1n],
    ["SPC-304 source function lookup cannot substitute a specialization", 304, 4294967295n, 7n, 73n << 32n],
    ["LNK-504 source function lookup cannot substitute a lambda", 504, 0n, 1n, 74n << 32n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 5, 5100n, 5100n << 32n, 0n, 4294967295, expected, actual, detail],
  })),
  ...[
    ["ABI-703 outlined builtin parameter count must match", 703, 2n, 1n, 0n],
    ["ABI-705 outlined builtin operands retain their scalar type", 705, 4n, 5n, 1n],
    ["ABI-709 outlined builtin result retains its scalar type", 709, 4n, 5n, 0n],
    ["ARN-101 outlined builtin parameter span is checked before reads", 101, 4n, (4294967295n << 32n) | 2n, 0n],
    ["ARN-101 outlined builtin result span is checked before reads", 101, 4n, (4n << 32n) | 1n, 1n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 7, 5100n, 5100n << 32n, 0n, 4294967295, expected, actual, detail],
  })),
  ...[["zero", 0n], ["reserved", 1n], ["missing", 4294967295n]].map(([kind, actual]) => ({
    name: `ARN-105 emitted function rejects ${kind} handle`,
    expected: [105, 7, 0n, 0n, 0n, 4294967295, 2n, actual, 0n],
  })),
  {
    name: "LNK-502 function handle encoding preserves the missing sentinel",
    expected: [502, 6, 0n, 0n, 0n, 4294967295, 4294967292n, 4294967293n, 0n],
  },
  ...[
    ["capture cells cannot use Generic evidence", 1n],
    ["capture cells cannot use Error evidence", 2n],
    ["capture cell products cannot hide Error evidence", 2n],
    ["specialized capture cells cannot use Generic evidence", 1n],
    ["specialized capture cells cannot use Error evidence", 2n],
    ["specialized capture products cannot hide Error evidence", 2n],
  ].map(([name, actual]) => ({
    name: `SPC-301 ${name}`,
    expected: [301, 4, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 0n, actual, 1n],
  })),
  ...[
    ["named physical parameters cannot use Generic evidence", 1n],
    ["named physical parameters cannot use Error evidence", 2n],
    ["named physical products cannot hide Error evidence", 2n],
  ].map(([name, actual]) => ({
    name: `SPC-301 ${name}`,
    expected: [301, 4, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 0n, actual, 0n],
  })),
  ...[
    ["named physical results cannot use Generic evidence", 1n],
    ["named physical results cannot use Error evidence", 2n],
    ["named physical products cannot hide Generic evidence", 1n],
  ].map(([name, actual]) => ({
    name: `SPC-301 ${name}`,
    expected: [301, 4, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 0n, actual, 4294967295n],
  })),
  {
    name: "ARN-101 named physical parameter spans are checked before reads",
    expected: [101, 4, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 0n, 1n, 0n],
  },
  ...[
    ["FRG-403 payload storage cannot read the next payload", 403, 1n, 1n, 0n],
    ["FRG-403 payload owner lookup cannot read the next payload", 403, 1n, 1n, 0n],
    ["ARN-101 payload storage checks span before addition", 101, 2n, 2n, (1n << 32n) | 4294967295n],
    ["ARN-101 payload owner lookup checks span before addition", 101, 2n, 1n, (1n << 32n) | 2n],
    ["ARN-103 payload type and shape arrays remain parallel", 103, 2n, 1n, 1n],
  ].map(([name, code, expected, actual, detail]) => ({
    name,
    expected: [code, 4, 5100n, 5100n << 32n, 0n, 4294967295, expected, actual, detail],
  })),
  ...[
    "lowered unary expressions cannot contain themselves",
    "lowered blocks cannot contain themselves",
    "physical work graphs reject cyclic syntax",
  ].map(name => ({
    name: `ARN-108 ${name}`,
    expected: [108, 6, 5100n, (5100n << 32n) + 1n, (5100n << 32n) + 1n, 1, 0n, 1n, (1n << 32n) | 1n],
  })),
  {
    name: "ARN-108 lowered expressions reject indirect cycles",
    expected: [108, 6, 5100n, 5100n << 32n, 5100n << 32n, 1, 0n, 1n, 1n << 32n],
  },
  {
    name: "ARN-108 lowered patterns cannot contain themselves",
    expected: [108, 6, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 0n, 1n, 4n << 32n],
  },
  {
    name: "ARN-104 emission rejects orphan captures before local planning",
    expected: [104, 7, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 0n, 1n, (17n << 32n) | 1n],
  },
  {
    name: "ARN-104 fragment metadata rejects orphan captures",
    expected: [104, 4, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 0n, 1n, (17n << 32n) | 1n],
  },
  {
    name: "ARN-104 fragment metadata rejects orphan locals",
    expected: [104, 4, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 0n, 2n, (2n << 32n) | 1n],
  },
  ...[
    ["lambda owner", 18n], ["relative identity", 17n],
  ].map(([name, tag]) => ({
    name: `ARN-106 fragment capture entries retain their ${name}`,
    expected: [106, 4, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 0n, 1n, tag << 32n],
  })),
  {
    name: "ARN-106 fragment capture sources retain their root body",
    expected: [106, 4, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 5100n << 32n, (5100n << 32n) + 1n, 22n << 32n],
  },
  {
    name: "ARN-104 closure captures require their enclosing environment",
    expected: [104, 6, 5100n, 18446744073709551615n, 5100n << 32n, 1, 1n, 0n, (23n << 32n) | 1n],
  },
  ...[
    "capture sources retain their root body",
    "erased captures still require their source owner",
  ].map(name => ({
    name: `ARN-106 ${name}`,
    expected: [106, 6, 5100n, 18446744073709551615n, 5100n << 32n, 4294967295, 5100n << 32n, (5100n << 32n) + 1n, 22n << 32n],
  })),
  ...[
    ["locals stay in their owning span", 2n],
    ["lambdas are present", 16n],
  ].map(([name, tag]) => ({
    name: `ARN-104 capture source ${name}`,
    expected: [104, 6, 5100n, 18446744073709551615n, 5100n << 32n, 4294967295, 0n, 1n, (tag << 32n) | 1n],
  })),
  ...[
    ["relative identity", 17n],
    ["lambda owner", 18n],
  ].map(([name, tag]) => ({
    name: `ARN-106 physical capture entries preserve their ${name}`,
    expected: [106, 6, 5100n, 18446744073709551615n, 5100n << 32n, 4294967295, 0n, 1n, tag << 32n],
  })),
  {
    name: "ARN-104 physical capture reads require an owning lambda",
    expected: [104, 6, 5100n, (5100n << 32n) + 1n, (5100n << 32n) + 1n, 1, 0n, 0n, 17n << 32n],
  },
  {
    name: "ARN-104 physical capture reads stay in the lambda capture span",
    expected: [104, 6, 5100n, 18446744073709551615n, 5100n << 32n, 1, 0n, 1n, (17n << 32n) | 1n],
  },
  {
    name: "ARN-106 lambda locals retain their exact owner",
    expected: [106, 6, 5100n, 18446744073709551615n, 5100n << 32n, 4294967295, 0n, 1n, 7n << 32n],
  },
  ...[
    ["lowered locals preserve their relative identity", 0n, 1n, 2n],
    ["lowered locals preserve their source body", (5100n << 32n) + 1n, 5100n << 32n, 6n],
    ["named body locals cannot belong to a lambda", 4294967295n, 0n, 7n],
  ].map(([name, expected, actual, tag]) => ({
    name: `ARN-106 ${name}`,
    expected: [106, 6, 5100n, (5100n << 32n) + 1n, (5100n << 32n) + 1n, 4294967295, expected, actual, (tag << 32n) | 1n],
  })),
  ...[
    ["lowered unary children cannot cross physical bodies", 1, 1n, 0n, 1n],
    ["required lowered children cannot be missing", 1, 1n, 4294967295n, 1n],
    ["only the exact lowered return sentinel can be erased", 1, 1n, 4294967294n, 1n],
    ["lowered local reads require an owned logical slot", 2, 0n, 1n, 1n],
    ["lowered block references cannot cross physical bodies", 3, 1n, 0n, 1n],
    ["an owned argument list cannot borrow another body value", 1, 1n, 0n, 1n],
    ["physical work graphs require owned source operands", 1, 1n, 0n, 1n],
  ].map(([name, tag, expected, actual, length]) => ({
    name: `ARN-104 ${name}`,
    expected: [104, 6, 5100n, (5100n << 32n) + 1n, (5100n << 32n) + 1n, 1, expected, actual, (BigInt(tag) << 32n) | length],
  })),
  ...[
    ["lowered argument spans are checked before reading", 1, 0n, 10n],
    ["lowered block item spans are checked before reading", 4294967295, 2n, 11n],
  ].map(([name, expression, expected, tag]) => ({
    name: `ARN-101 ${name}`,
    expected: [101, 6, 5100n, (5100n << 32n) + 1n, (5100n << 32n) + 1n, expression, expected, 1n, (tag << 32n) | 4294967295n],
  })),
  ...[
    ["aligned physical local tables cannot omit a logical local", 3n, 2n, 711n],
    ["physical local carriers remain complete", 3n, 2n, 712n],
    ["physical expressions cannot omit the body tail", 1n, 0n, 713n],
    ["physical control states require an owning loop", 0n, 1n, 714n],
    ["physical control state values require an owning loop", 0n, 1n, 715n],
    ["physical control results require an owning loop", 0n, 1n, 716n],
    ["physical control result values require an owning loop", 0n, 1n, 717n],
  ].map(([name, expected, actual, detail]) => ({
    name: `ARN-103 ${name}`,
    expected: [103, 6, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, expected, actual, detail],
  })),
  ...[
    ["belong to an earlier body", 0], ["follow its body", 2],
    ["be the missing sentinel", 4294967295],
  ].map(([name, expression]) => ({
    name: `ARN-102 frozen expression cannot ${name}`,
    expected: [102, 6, 5100n, (5100n << 32n) + 1n, (5100n << 32n) + 1n, expression, 1n, BigInt(expression), 1n],
  })),
  {
    name: "ARN-106 physical expression table preserves stored identity",
    expected: [106, 6, 5100n, 5100n << 32n, 5100n << 32n, 1, 0n, 1n, 713n],
  },
  {
    name: "EVD-211 implementation type cycles retain the type identity",
    expected: [211, 3, 6014n, 0n, 0n, 3, 0n, 3n, 1n],
  },
  {
    name: "EVD-211 interface type cycles retain the type identity",
    expected: [211, 3, 6000n, 0n, 0n, 3, 0n, 3n, 1n],
  },
  {
    name: "ARN-101 interface type child spans are owned",
    expected: [101, 3, 6000n, 0n, 0n, 3, 0n, 0n, 1n],
  },
  ...[
    ["LNK-502 linked function index must match its table slot", 502, 1, 0n, 99n, 0n],
    ["LNK-504 linked function fragment must exist", 504, 1, 1n, 99n, 2n],
    ["LNK-504 linked declaration must match its fragment", 504, 2, (5100n << 32n) + 1n, (5100n << 32n) + 2n, 3n],
    ["LNK-503 module type base cannot be missing", 503, null, 0n, 4294967295n, 0n],
    ["LNK-502 linked type index must match its table slot", 502, null, 0n, 99n, 1n],
    ["LNK-504 linked type fragment must match its owner", 504, null, 0n, 99n, 5n],
  ].map(([name, code, declaration, expected, actual, detail]) => ({
    name,
    expected: [code, 5, 5100n, declaration === null ? 0n : (5100n << 32n) + BigInt(declaration), 0n, 0, expected, actual, detail],
  })),
  {
    name: "BOD-610 linked definition must have a body",
    expected: [610, 5, 5100n, (5100n << 32n) + 1n, 5100n << 32n, 0, 5100n << 32n, 0n, 0n],
  },
  {
    name: "LNK-504 source bodies must have unique identities",
    expected: [504, 5, 5100n, (5100n << 32n) + 1n, 0n, 4294967295, 0n, 5100n << 32n, 12n],
  },
  {
    name: "ARN-101 physical body span must fit its arena",
    expected: [101, 6, 5100n, (5100n << 32n) + 1n, (5100n << 32n) + 1n, 4294967295, 2n, 1n, (1n << 32n) + 2n],
  },
  ...[
    ["physical expression cannot precede its body", 0],
    ["physical expression cannot follow its body", 2],
    ["missing expression cannot become a body slot", 4294967295],
  ].map(([name, expression]) => ({
    name: `ARN-102 ${name}`,
    expected: [102, 6, 5100n, (5100n << 32n) + 1n, (5100n << 32n) + 1n, expression, 1n, BigInt(expression), 1n],
  })),
  ...[
    ["repeated SCC module is rejected", 0, 4294967295, 0, 6],
    ["missing SCC module is rejected", 4294967295, 3, 2, 1],
    ["reversed dependency order is rejected", 1, 1, 2, 10],
    ["overlapping SCC spans are rejected", 1, 1, 0, 3],
    ["dependency span overflow is rejected", 1, 2, 4294967295, 8],
    ["out of range dependency is rejected", 1, 3, 3, 9],
    ["stored component identity must match", 1, 1, 2, 7],
  ].map(([name, expression, expected, actual, detail]) => ({
    name: `LNK-501 ${name}`,
    expected: [501, 5, 0n, 0n, 0n, expression, BigInt(expected), BigInt(actual), BigInt(detail)],
  })),
  {
    name: "SPC-303 source call declarations cannot disagree",
    expected: [303, 5, 77n, (88n << 32n) + 11n, (77n << 32n) + 17n, 19, (88n << 32n) + 11n, (88n << 32n) + 12n, 3n],
  },
  {
    name: "SPC-303 source call specializations cannot disagree",
    expected: [303, 5, 77n, (88n << 32n) + 11n, (77n << 32n) + 17n, 19, 7n, 9n, 3n],
  },
  {
    name: "ARN-104 compile-time storage requires prior child types",
    expected: [104, 2, 24702n, 0n, 0n, 4294967295, 1n, 1n, 0n],
  },
  {
    name: "ARN-101 compile-time storage rejects invalid spans",
    expected: [101, 2, 24702n, 0n, 0n, 4294967295, 1n, 2n, 1n],
  },
  ...["generic", "parameter"].map((kind, field) => ({
    name: `ARN-106 imported ${kind} spans cannot alias a local declaration`,
    expected: [106, 1, 5700n, 5701n << 32n, 0n, 4294967295, 5700n, 5701n, BigInt(field)],
  })),
  {
    name: "ARN-103 frozen physical local slots remain parallel",
    expected: [103, 6, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 3n, 2n, 710n],
  },
  {
    name: "FRG-401 lambda parameters cannot exceed their local span",
    expected: [401, 4, 5100n, (5100n << 32n) + 1n, 5100n << 32n, 4294967295, 3n, 4n, 0n],
  },
  {
    name: "FRG-401 lambda parameters require parameter locals",
    expected: [401, 4, 5100n, (5100n << 32n) + 1n, 5100n << 32n, 4294967295, 0n, 0n, 0n],
  },
  {
    name: "BOD-610 a linked function requires a source body",
    expected: [610, 5, 5100n, 5100n << 32n, 5100n << 32n, 0, 5100n << 32n, 0n, 0n],
  },
  {
    name: "LNK-504 two named physical functions cannot own one declaration",
    expected: [504, 5, 77n, (77n << 32n) + 11n, 0n, 4294967295, 4n, 5n, 5n],
  },
  ...[
    ["generic", 1n], ["erroneous", 2n],
    ["nested generic", 1n], ["nested erroneous", 2n],
  ].map(([kind, error]) => ({
    name: `SPC-301 ${kind} request shape is rejected`,
    expected: [301, 5, 77n, (88n << 32n) + 11n, (77n << 32n) + 17n, 19, 0n, error, 1n],
  })),
  {
    name: "SPC-303 one call key cannot select two targets",
    expected: [303, 5, 0n, 0n, 17n, 19, 23n, 29n, 3n],
  },
  {
    name: "INV-001 trap preserves complete numeric context",
    expected: [701, 7, 11n, 13n, 17n, 19, 23n, 29n, 31n],
  },
  {
    // The fixture has one module (5100), declaration/body zero, and literal
    // expression zero. Linked physical functions start after two imports.
    name: "BOD-605 emission cannot rewrite a frozen carrier",
    expected: [605, 6, 5100n, 5100n << 32n, 5100n << 32n, 0, 4n, 5n, 2n],
  },
  solverProbe("SOL-204 nested snapshots with identical state are distinct", 204, 1, 0, 2),
  solverProbe("SOL-204 a committed snapshot cannot be replayed", 204, 1, 0, 1),
  solverProbe("SOL-204 commit requires an open snapshot", 204, 1, 0, 0),
  solverProbe("SOL-205 undo arrays must remain parallel", 205, 1, 0, 1),
  solverProbe("SOL-205 undo kind must be valid", 205, 2, 3, 0),
  solverProbe("SOL-205 commit cannot discard an invalid undo record", 205, 2, 3, 0),
  solverProbe("SOL-206 reset cannot discard aligned pending work", 206, 0, 1, 40),
  solverProbe("SOL-205 reset cannot discard an unowned undo record", 205, 0, 1, 3),
  solverProbe("SOL-206 zonk rejects a later structural cycle", 206, 0, 1, 1),
  solverProbe("ARN-104 solver type reads cannot hide a missing sentinel", 104, 1, 4294967295, 0),
  solverProbe("ARN-104 unification cannot hide a missing sentinel", 104, 2, 4294967295, 0),
  solverProbe("SOL-201 representative checks the stored variable identity", 201, 0, 0, 4),
  {
    name: "ARN-102 name resolution checks body ownership before subtraction",
    expected: [102, 1, 6044n, (6044n << 32n) | 1n, (6044n << 32n) | 1n, 0, 1n, 0n, 1n],
  },
  {
    name: "ARN-101 name resolution checks spans before allocating work arrays",
    expected: [101, 1, 6045n, 6045n << 32n, 6045n << 32n, 4294967295, 1n, 4294967295n, 1n],
  },
  solverProbe("ARN-101 unification checks owned spans before identity", 101, 1, 1, 1),
  solverProbe("SOL-205 undo index must be in its arena", 205, 1, 1, 2),
  solverProbe("SOL-205 undo size must be positive", 205, 1, 0, 0),
  solverProbe("SOL-205 undo binding must name a present type", 205, 2, 2, 0),
  solverProbe("SOL-206 unify cannot discard a broken work stack", 206, 1, 0, 20),
  solverProbe("SOL-206 zonk cannot discard a broken work stack", 206, 1, 0, 21),
  solverProbe("SOL-206 type caches must remain parallel", 206, 1, 0, 12),
  solverProbe("SOL-206 zonk product must have its child results", 206, 1, 0, 23),
  solverProbe("ARN-101 zonk argument span must belong to its arena", 101, 1, 1, 1),
  solverProbe("SOL-206 zonk application must have the correct term", 206, 1, 0, 28),
  solverProbe("SOL-206 zonk function must have the correct term", 206, 2, 0, 28),
  solverProbe("SOL-206 zonk product must have the correct term", 206, 3, 0, 28),
  solverProbe("SOL-204 rollback cannot invent missing arena contents", 204, 1, 0, 12),
  solverProbe("SOL-206 reset requires closed snapshots", 206, 0, 1, 0),
  solverProbe("SOL-206 zonk requires closed snapshots", 206, 0, 1, 1),
  solverProbe("SOL-201 variable arrays must remain parallel", 201, 1, 0, 1),
  solverProbe("SOL-202 parent cycles have a bounded walk", 202, 2, 2, 0),
  solverProbe("SOL-202 parents must stay in the variable arena", 202, 1, 1, 0),
  solverProbe("SOL-202 type binding cycles have a bounded walk", 202, 2, 2, 1),
  solverProbe("SOL-203 union size cannot overflow", 203, 4294967294, 4294967295, 0),
  solverProbe("SOL-207 resolved type encoding cannot overflow", 207, 2147483646, 2147483647, 0),
];
const module = await WebAssembly.compile(await readFile(process.argv[2]));
const sections = WebAssembly.Module.customSections(module, "dew.tests");
assert.equal(sections.length, 1, "one Dew test manifest is required");
const tests = decodeDewTestMetadata(sections[0]);
for (const probe of probes) {
  const matches = tests.filter((test) => test.name === probe.name);
  assert.equal(matches.length, 1, `missing or duplicate probe: ${probe.name}`);
  let instance;
  const output = [];
  instance = await WebAssembly.instantiate(module, {
    wasi_snapshot_preview1: {
      fd_write(_fd, iovs, count, written) {
        const memory = instance.exports.memory;
        const view = new DataView(memory.buffer);
        let total = 0;
        for (let i = 0; i < count; i++) {
          const address = view.getUint32(iovs + i * 8, true);
          const length = view.getUint32(iovs + i * 8 + 4, true);
          output.push(Buffer.from(new Uint8Array(memory.buffer, address, length)));
          total += length;
        }
        view.setUint32(written, total, true);
        return 0;
      },
    },
  });
  instance.exports.__dew_init?.();
  assert.throws(
    () => instance.exports[matches[0].export](),
    (error) => error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
    probe.name,
  );
  const view = new DataView(instance.exports.memory.buffer);
  const context = `${probe.name}: ${Buffer.concat(output).toString("utf8")}`;
  assert.equal(view.getBigUint64(0, true), 4919706420659244884n, context);
  assert.equal(view.getBigUint64(8, true), 1n, context);
  assert.deepEqual([
    view.getUint32(16, true), view.getUint32(20, true),
    view.getBigUint64(24, true), view.getBigUint64(32, true),
    view.getBigUint64(40, true), view.getUint32(48, true),
    view.getBigUint64(56, true), view.getBigUint64(64, true),
    view.getBigUint64(72, true),
  ], probe.expected, context);
}
console.log(`self-host invariant trap records passed: ${probes.length}`);
