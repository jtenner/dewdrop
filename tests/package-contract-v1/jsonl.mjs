import { spawnSync } from 'node:child_process';

// Test-only batch protocol. This function never builds or selects a compiler.
export function runReader(command, cases) {
  if (!Array.isArray(command) || !command.length || command.some(part => typeof part !== 'string' || !part.length)) {
    throw new Error('reader command must be a nonempty argv array');
  }
  const requested = new Set(cases.map(test => test.id));
  if (!cases.length || requested.size !== cases.length) throw new Error('reader requests need unique, nonempty case IDs');
  const input = cases.map(({ id, kind, input }) => JSON.stringify({ schemaVersion: 1, id, kind, input })).join('\n') + '\n';
  const child = spawnSync(command[0], command.slice(1), {
    input, encoding: 'utf8', shell: false, timeout: 30000, killSignal: 'SIGKILL', maxBuffer: 8 * 1048576,
  });
  if (child.error) {
    throw new Error(`reader could not start or complete: ${child.error.code}: ${child.error.message}; stderr=${child.stderr ?? ''}`);
  }
  if (child.status !== 0) {
    throw new Error(`reader exit ${child.status}, signal ${child.signal ?? 'none'}; stderr=${child.stderr ?? ''}`);
  }
  if (child.stderr) process.stderr.write(child.stderr);
  const results = new Map();
  const lines = child.stdout.split('\n');
  // Permit the usual single final newline, but no blank result records.
  if (lines.at(-1) === '') lines.pop();
  for (let index = 0; index < lines.length; index++) {
    let result;
    try { result = JSON.parse(lines[index]); }
    catch { throw new Error(`reader invalid JSON at line ${index + 1}`); }
    if (!result || !requested.has(result.id)) throw new Error(`reader unexpected result: ${result?.id}`);
    if (results.has(result.id)) throw new Error(`reader duplicate result: ${result.id}`);
    if (typeof result.accept !== 'boolean' || (!result.accept && (typeof result.diagnostic !== 'string' || !result.diagnostic.trim()))) {
      throw new Error(`reader invalid result shape: ${result.id}`);
    }
    results.set(result.id, result);
  }
  for (const id of requested) if (!results.has(id)) throw new Error(`reader missing result: ${id}`);
  return results;
}
