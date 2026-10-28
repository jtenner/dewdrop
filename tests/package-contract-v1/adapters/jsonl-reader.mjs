// Point at an existing narrow reader executable. No shell command is evaluated.
import { runReader } from '../jsonl.mjs';
const rawKinds = process.env.DEW_CONTRACT_KINDS;
if (!rawKinds) throw new Error('set DEW_CONTRACT_KINDS to supported kind names separated by commas');
export const kinds = rawKinds.split(',');
if (kinds.some(kind => !kind) || new Set(kinds).size !== kinds.length) throw new Error('DEW_CONTRACT_KINDS has empty or duplicate kinds');
let results;
export function prepare(cases) {
  let command;
  try { command = JSON.parse(process.env.DEW_CONTRACT_COMMAND ?? ''); }
  catch { throw new Error('set DEW_CONTRACT_COMMAND to a JSON argv array'); }
  results = runReader(command, cases);
}
export async function evaluate(_kind, _input, test) {
  const result = results?.get(test.id);
  if (!result) throw new Error(`JSONL reader has no prepared result for ${test.id}`);
  return result;
}
