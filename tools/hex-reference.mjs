// Node Buffer is the independent reference. Fixed xorshift32 seed.
import { writeFileSync } from 'node:fs';
let state = 0x51a7c0de;
function next() { state ^= state << 13; state ^= state >>> 17; state ^= state << 5; return state >>> 0; }
function literal(bytes) { return 'b"' + [...bytes].map(x => '\\x' + x.toString(16).padStart(2, '0')).join('') + '"'; }
let source = 'open dew.std.encoding.hex\nopen dew.std.bytes\n';
for (let i = 0; i < 64; i++) {
  const input = i === 1 ? Buffer.from(Array.from({length: 256}, (_, x) => x))
    : Buffer.from(Array.from({length: i === 0 ? 0 : i === 63 ? 4096 : next() % 257}, () => next() & 255));
  const hex = input.toString('hex');
  source += `test "Node hex reference ${i}" {\n  let input = ${literal(input)}\n  let text = b"${hex}"\n  assert(encode(input) == text, "Node encode mismatch")\n  match decode(text) {\n    Ok(value) => assert(value == input, "Node round trip mismatch")\n    Err(_) => assert(false, "Node round trip failed")\n  }\n}\n`;
}
writeFileSync(process.argv[2], source);
console.log('Generated 64 deterministic Node reference tests; lengths 0..4096.');
