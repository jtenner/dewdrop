import assert from "node:assert/strict";

// Keep these independent of the library declarations. These are the exact
// arguments in tests/module-snapshots/wasm/wasi-preview1-runtime.dew.
const calls = {
  args_get: [128, 256], args_sizes_get: [384, 388],
  environ_get: [512, 640], environ_sizes_get: [768, 772],
  clock_res_get: [1, 896], clock_time_get: [1, 7n, 904],
  fd_advise: [3, 11n, 13n, 2], fd_allocate: [3, 17n, 19n],
  fd_close: [9], fd_datasync: [3], fd_fdstat_get: [3, 1024],
  fd_fdstat_set_flags: [3, 1], fd_fdstat_set_rights: [3, 23n, 29n],
  fd_filestat_get: [3, 1088], fd_filestat_set_size: [3, 31n],
  fd_filestat_set_times: [3, 37n, 41n, 3],
  fd_pread: [3, 0, 1, 43n, 8], fd_prestat_get: [3, 1152],
  fd_prestat_dir_name: [3, 1216, 0], fd_pwrite: [3, 0, 1, 47n, 8],
  fd_read: [0, 0, 1, 8], fd_readdir: [3, 1280, 0, 53n, 1344],
  fd_renumber: [7, 8], fd_seek: [3, -59n, 2, 1408],
  fd_sync: [3], fd_tell: [3, 1472], fd_write: [9, 0, 1, 8],
  path_create_directory: [3, 1536, 0],
  path_filestat_get: [3, 1, 1600, 0, 1664],
  path_filestat_set_times: [3, 1, 1728, 0, 61n, 67n, 3],
  path_link: [3, 1, 1792, 0, 4, 1856, 0],
  path_open: [3, 1, 1920, 0, 1, 71n, 73n, 1, 1984],
  path_readlink: [3, 2048, 0, 2112, 0, 2176],
  path_remove_directory: [3, 2240, 0],
  path_rename: [3, 2304, 0, 4, 2368, 0],
  path_symlink: [2432, 0, 3, 2496, 0], path_unlink_file: [3, 2560, 0],
  poll_oneoff: [2624, 2688, 0, 2752], proc_exit: [23], proc_raise: [2],
  sched_yield: [], random_get: [2816, 0], sock_accept: [5, 1, 2880],
  sock_recv: [5, 0, 1, 0, 2944, 2948], sock_send: [5, 0, 1, 0, 3008],
  sock_shutdown: [5, 3],
};

export function wasiForeignProbe() {
  const seen = [];
  return {
    imports(module) {
      const imports = WebAssembly.Module.imports(module);
      for (const entry of imports) {
        assert.equal(entry.module, "wasi_snapshot_preview1", "unexpected host namespace");
        assert.equal(entry.kind, "function");
        assert.ok(Object.hasOwn(calls, entry.name), `unexpected host field ${entry.name}`);
      }
      assert.deepEqual(new Set(imports.map(entry => entry.name)), new Set(Object.keys(calls)));
      return { wasi_snapshot_preview1: Object.fromEntries(Object.entries(calls).map(([name, expected]) => [name, (...args) => {
        assert.deepEqual(args, expected, `${name}: full ordered ABI arguments`);
        seen.push(name);
        return name === "proc_exit" ? undefined : 0;
      }])) };
    },
    check(exports) {
      assert.ok(exports.memory instanceof WebAssembly.Memory, "host pointers require exported memory");
      assert.equal(exports.main(), 46);
      assert.deepEqual(seen, Object.keys(calls), "every host call runs once in source order");
      return seen.length;
    },
  };
}
