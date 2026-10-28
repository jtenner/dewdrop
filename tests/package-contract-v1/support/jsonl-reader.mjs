// Harness fixture only. This is not a package contract implementation.
import { readFileSync } from 'node:fs';
const requests = readFileSync(0, 'utf8').trim().split('\n').filter(Boolean).map(line => JSON.parse(line));
const mode = process.argv[2] ?? 'valid';
if (mode === 'fail') { console.error('fixture reader failed before checking input'); process.exit(7); }
if (mode === 'malformed') { console.log('not JSON'); process.exit(0); }
for (const request of requests) {
  if ('expected' in request || 'rule' in request) throw new Error('answer leaked to reader');
  if (request.schemaVersion !== 1) throw new Error('wrong protocol version');
  if (mode === 'omit') continue;
  const response = {
    id: mode === 'unknown' ? 'manifest/not-requested' : request.id,
    accept: request.input === 'ok',
    diagnostic: 'fixture rejection',
    observedInput: request.input,
  };
  console.log(JSON.stringify(response));
  if (mode === 'duplicate') console.log(JSON.stringify(response));
}
