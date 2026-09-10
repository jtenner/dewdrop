"""Raw WASI calls are public foreign declarations, not compiler builtins."""

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIELDS = set("""
args_get args_sizes_get environ_get environ_sizes_get clock_res_get clock_time_get
fd_advise fd_allocate fd_close fd_datasync fd_fdstat_get fd_fdstat_set_flags
fd_fdstat_set_rights fd_filestat_get fd_filestat_set_size fd_filestat_set_times
fd_pread fd_prestat_get fd_prestat_dir_name fd_pwrite fd_write fd_read fd_readdir
fd_renumber fd_seek fd_sync fd_tell path_create_directory path_filestat_get
path_filestat_set_times path_link path_open path_readlink path_remove_directory
path_rename path_symlink path_unlink_file poll_oneoff proc_exit proc_raise
sched_yield random_get sock_accept sock_recv sock_send sock_shutdown
""".split())


class WasiForeignPolicyTests(unittest.TestCase):
    def test_bytes_adapter_is_library_code(self):
        source = (ROOT / "std/wasi.dew").read_text()
        self.assertNotRegex(source, r"\bbuiltin\b")
        self.assertIn('import dew.std.wasm.wasi as @wasi', source)
        self.assertIn('pub fn wasi_fd_write(fd: U32, value: Bytes) -> U32 {', source)
        self.assertIn('pub fn wasi_fd_read(fd: U32, limit: U32) -> Bytes {', source)
        self.assertIn('@wasi.fd_write(fd, 0u32, 1u32, 8u32)', source)
        self.assertIn('@wasi.fd_read(fd, 0u32, 1u32, 8u32)', source)

    def test_removed_read_runtime(self):
        for directory, suffix in [("src", "*.mbt"), ("self_host/compiler", "*.dew")]:
            for path in (ROOT / directory).rglob(suffix):
                with self.subTest(path=path.relative_to(ROOT)):
                    source = path.read_text()
                    # Negative emission tests must name the rejected opcode.
                    if not path.name.endswith(("_wbtest.mbt", "_test.mbt", "_test.dew")):
                        self.assertNotIn('"dew_wasi_fd_read"', source)
                    self.assertNotIn('starshine_wasi_fd_read_body', source)
        for path in ("starshine-mb/src/ffi_bridge/ffi_bridge.mbt",):
            with self.subTest(path=path):
                source = (ROOT / path).read_text()
                self.assertNotIn('"dew_wasi_fd_read"', source)
                self.assertNotIn('starshine_wasi_fd_read_body', source)

    def test_complete_foreign_surface(self):
        source = (ROOT / "std/wasm/wasi.dew").read_text()
        self.assertNotRegex(source, r"\bbuiltin\b")
        self.assertIn('foreign import "wasi_snapshot_preview1" as WasiPreview1 {', source)
        imports = re.findall(r'^  pub fn (\w+)\(([^)]*)\) -> (\w+) = "([^"]+)"$', source, re.M)
        self.assertEqual(len(imports), 46)
        self.assertEqual({name for name, *_ in imports}, FIELDS)
        for name, parameters, result, field in imports:
            with self.subTest(function=name):
                self.assertEqual(name, field)
                self.assertEqual(result, "Unit" if name == "proc_exit" else "WasiErrno")
        self.assertEqual(source.count("{"), 1, "raw imports need no wrapper bodies")


if __name__ == "__main__":
    unittest.main()
