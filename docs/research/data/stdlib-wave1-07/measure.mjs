import fs from 'node:fs';
import crypto from 'node:crypto';

const { instance } = await WebAssembly.instantiate(
  fs.readFileSync('.tmp/consumer.wasm'),
  {},
);

for (const method of ['run', 'run_oneshot']) {
  instance.exports[method](1024);
  for (const bytes of [65536, 1048576, 4194304, 16777216]) {
    global.gc();
    const before = process.memoryUsage();
    const start = performance.now();
    const first = instance.exports[method](bytes / 64);
    const ms = performance.now() - start;
    const after = process.memoryUsage();
    const expected = crypto.createHash('sha256')
      .update(Buffer.alloc(bytes, 97))
      .digest()[0];
    if (first !== expected) {
      throw Error(`digest mismatch ${bytes}`);
    }
    console.log(JSON.stringify({
      method,
      bytes,
      ms,
      heapGrowth: after.heapUsed - before.heapUsed,
      rssGrowth: after.rss - before.rss,
      first,
    }));
  }
}
